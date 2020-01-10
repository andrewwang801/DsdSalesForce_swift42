//
//  ChatsVC.swift
//  DSDConnect
//
//  Created by iOS Developer on 3/22/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import Quickblox
import CCBottomRefreshControl
import XLPagerTabStrip

class ChatsVC: UIViewController, QMAuthServiceDelegate {

    @IBOutlet weak var tableView: UITableView!

    private var didEnterBackgroundDate: NSDate?
    var privateChatDialogs = [QBChatDialog]()

    var skipRecords = 0
    var isNewDataLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.delaysContentTouches = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        ServicesManager.instance().chatService.addDelegate(self)
        ServicesManager.instance().authService.add(self)

        updateDialogs()

        skipRecords = 0
        if (QBChat.instance.isConnected) {
            if privateChatDialogs.count > 0 {
                self.loadDialogsFromQb(isSilentUpdate: true, isClearDialogs: true)
            }
            else {
                self.loadDialogsFromQb(isSilentUpdate: false, isClearDialogs: true)
            }
        }

        // badge refresh
        DialogUtils.refreshAppBadge()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        ServicesManager.instance().chatService.removeDelegate(self)
        ServicesManager.instance().authService.remove(self)
    }

    // MARK: - Notification handling

    @objc func didEnterBackgroundNotification() {
        self.didEnterBackgroundDate = NSDate()
    }

    func onRefreshTable() {
        skipRecords += Int(kDialogsPageLimit)
        loadDialogsFromQb(isSilentUpdate: false, isClearDialogs: false)
    }

    func updateDialogsList() {
        skipRecords = 0
        loadDialogsFromQb(isSilentUpdate: true, isClearDialogs: true)
    }

    // MARK: - DataSource Action

    func loadDialogsFromQb(isSilentUpdate: Bool, isClearDialogs: Bool) {

        if isSilentUpdate == false {
            SVProgressHUD.show(withStatus: L10n.loadingDialogs(), maskType: SVProgressHUDMaskType.clear)
        }

        var dialogsToLoad = [QBChatDialog]()
        var userIDArray = [NSNumber]()

        var extendedRequest = [String:String]()
        extendedRequest["skip"] = "\(skipRecords)"

        self.isNewDataLoading = true

        ServicesManager.instance().chatService.allDialogs(withPageLimit: kDialogsPageLimit, extendedRequest: extendedRequest, iterationBlock: { (response: QBResponse?, dialogObjects: [QBChatDialog]?, dialogsUsersIDS: Set<NSNumber>?, stop: UnsafeMutablePointer<ObjCBool>) -> Void in

            dialogsToLoad.append(contentsOf: dialogObjects!)

            // load all users
            for userID in dialogsUsersIDS! {
                userIDArray.append(userID)
            }

        }, completion: { (response: QBResponse?) -> Void in

            if userIDArray.count == 0 {
                self.onCompleteGetDialogs(isSilentUpdate: isSilentUpdate, isClearDialogs: isClearDialogs, dialogs: dialogsToLoad, response: response)
            }
            else {
                ServicesManager.instance().usersService.getUsersWithIDs(userIDArray).continueOnSuccessWith(block: { (taslArray) -> Any? in
                    self.onCompleteGetDialogs(isSilentUpdate: isSilentUpdate, isClearDialogs: isClearDialogs, dialogs: dialogsToLoad, response: response)
                })
            }
        })
    }

    func onCompleteGetDialogs(isSilentUpdate: Bool, isClearDialogs: Bool, dialogs: [QBChatDialog], response: QBResponse?) {

        self.isNewDataLoading = false

        guard response != nil && response!.isSuccess else {
            SVProgressHUD.showError(withStatus: L10n.loadingDialogs())
            return
        }

        if isClearDialogs == true {
            ServicesManager.instance().chatService.dialogsMemoryStorage.free()
        }

        ServicesManager.instance().chatService.dialogsMemoryStorage.add(dialogs, andJoin: true)

        updateDialogs()

        if isSilentUpdate == false {
            SVProgressHUD.dismiss()
        }

        ServicesManager.instance().lastActivityDate = NSDate()
    }

    // MARK: - Helpers
    func reloadTableViewIfNeeded() {
        if !ServicesManager.instance().isProcessingLogOut! {
            self.tableView.bottomRefreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }

    func loadUpdatedDialog(dialogId: String) {

        ServicesManager.instance().chatService.fetchDialog(withID: dialogId) { (dialog) in
            if dialog != nil {
                self.updateDialogs()
            }
        }
    }

    func updateDialogs() {
        let dialogs = ServicesManager.instance().chatService.dialogsMemoryStorage.dialogs(with: [])
        let sortedDialogs = dialogs.sorted { (dialog1, dialog2) -> Bool in

            let dateSent1 = dialog1.lastMessageDate ?? Date.distantPast
            let dateSent2 = dialog2.lastMessageDate ?? Date.distantPast

            if dateSent2.compare(dateSent1) == .orderedAscending {
                return true
            }
            else {
                return false
            }
        }
        let privateDialogs = sortedDialogs.filter { (dialog) -> Bool in
            return dialog.type == QBChatDialogType.private
        }
        self.privateChatDialogs = privateDialogs
        self.reloadTableViewIfNeeded()
    }

}

extension ChatsVC: UIScrollViewDelegate {

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // bottom refresh
        if scrollView == tableView {
            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
                if !isNewDataLoading{
                    onRefreshTable()
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension ChatsVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if privateChatDialogs.count > 0 {
            return privateChatDialogs.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "DialogCell", for: indexPath) as! DialogCell

        if (privateChatDialogs.count < indexPath.row) {
            return cell
        }

        let chatDialog = privateChatDialogs[indexPath.row]

        //cell.isExclusiveTouch = true
        //cell.contentView.isExclusiveTouch = true

        cell.tag = indexPath.row
        //cell.dialogID = chatDialog.id!

        let cellModel = DialogTableViewCellModel(dialog: chatDialog)

        cell.nameLabel.text = cellModel.textLabelText
        cell.lastMessageLabel.text = chatDialog.lastMessageText ?? ""

        let unreadCountText = cellModel.unreadMessagesCounterLabelText ?? ""
        if unreadCountText == "" {
            cell.unreadCountLabel.isHidden = true
            cell.unreadCountLabel.text = unreadCountText
            cell.nameRightConstraint.constant = -10.0
        }
        else {
            cell.unreadCountLabel.isHidden = false
            cell.unreadCountLabel.text = unreadCountText
            cell.nameRightConstraint.constant = 10.0
        }

        // status
        cell.statusLabel.isHidden = true
        cell.nameLeftConstraint.constant = 0.0

        return cell
    }

}

// MARK: - UITableViewDelegate
extension ChatsVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        if (ServicesManager.instance().isProcessingLogOut!) {
            return
        }

        DispatchQueue.main.async {
            let dialog = self.privateChatDialogs[indexPath.row]
            let chatVC = UIViewController.getViewController(storyboardName: "Chat", storyboardID: "ChatVC") as! ChatVC
            chatVC.dialog = dialog
            chatVC.dismissHandler = { dialog in
                let dialogId = dialog.id ?? ""
                self.loadUpdatedDialog(dialogId: dialogId)
            }
            let navVC = UINavigationController(rootViewController: chatVC)
            navVC.setDefaultModalPresentationStyle()
            self.present(navVC, animated: true, completion: nil)
        }
    }

}

extension ChatsVC: QMChatServiceDelegate {

    // MARK: - QMChatServiceDelegate

    func chatService(_ chatService: QMChatService, didUpdateChatDialogInMemoryStorage chatDialog: QBChatDialog) {

        self.reloadTableViewIfNeeded()
    }

    func chatService(_ chatService: QMChatService,didUpdateChatDialogsInMemoryStorage dialogs: [QBChatDialog]){

        self.reloadTableViewIfNeeded()
    }

    func chatService(_ chatService: QMChatService, didAddChatDialogsToMemoryStorage chatDialogs: [QBChatDialog]) {

        self.reloadTableViewIfNeeded()
    }

    func chatService(_ chatService: QMChatService, didAddChatDialogToMemoryStorage chatDialog: QBChatDialog) {

        self.reloadTableViewIfNeeded()
    }

    func chatService(_ chatService: QMChatService, didDeleteChatDialogWithIDFromMemoryStorage chatDialogID: String) {

        self.reloadTableViewIfNeeded()
    }

    func chatService(_ chatService: QMChatService, didAddMessagesToMemoryStorage messages: [QBChatMessage], forDialogID dialogID: String) {

        self.reloadTableViewIfNeeded()
    }

    func chatService(_ chatService: QMChatService, didAddMessageToMemoryStorage message: QBChatMessage, forDialogID dialogID: String){

        self.reloadTableViewIfNeeded()
    }

}

// MARK: QMChatConnectionDelegate
extension ChatsVC: QMChatConnectionDelegate {

    func chatServiceChatDidFail(withStreamError error: Error) {
    }

    func chatServiceChatDidAccidentallyDisconnect(_ chatService: QMChatService) {
    }

    func chatServiceChatDidConnect(_ chatService: QMChatService) {
        if !ServicesManager.instance().isProcessingLogOut! {
            self.loadDialogsFromQb(isSilentUpdate: false, isClearDialogs: true)
        }
    }

    func chatService(_ chatService: QMChatService,chatDidNotConnectWithError error: Error){
    }


    func chatServiceChatDidReconnect(_ chatService: QMChatService) {
        if !ServicesManager.instance().isProcessingLogOut! {
            self.loadDialogsFromQb(isSilentUpdate: false, isClearDialogs: true)
        }
    }
}

extension ChatsVC: IndicatorInfoProvider {

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return "CHATS"
    }
}

