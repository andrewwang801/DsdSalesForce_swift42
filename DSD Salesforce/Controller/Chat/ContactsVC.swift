//
//  ChatsVC.swift
//  DSDConnect
//
//  Created by iOS Developer on 3/22/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Quickblox
import CCBottomRefreshControl

class ContactsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var chatMainVC: ChatMainVC!

    var users = [QBUUser]()
    var currentUser: QBUUser?

    // MARK: - ViewController overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        // table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.delaysContentTouches = false

        currentUser = QBSession.current.currentUser
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadUsersFromQb()

        DialogUtils.refreshAppBadge()
    }

    // MARK: - DataSource Action
    func loadUsersFromQb() {
        var tags = [String]()

        let userDefaults = UserDefaults.standard
        let companyName = userDefaults.string(forKey: kCompanyNameKey) ?? ""
        tags.append(companyName)

        SVProgressHUD.show(with: .clear)

        ServicesManager.instance().usersService.searchUsers(withTags: tags).continueOnSuccessWith { (bfTask) -> Any? in
            var users = bfTask.result as? [QBUUser]
            if users != nil {
                var currentUser = QBSession.current.currentUser
                var currentUserIndex = -1
                for (index,user) in users!.enumerated() {
                    if user.id == currentUser?.id {
                        currentUser = user
                        currentUserIndex = index
                    }
                    else {
                        // refresh online status
                    }
                }
                if currentUserIndex != -1 {
                    users?.remove(at: currentUserIndex)
                }

                users?.sort(by: { (user1, user2) -> Bool in
                    let fullName1 = user1.fullName ?? ""
                    let fullName2 = user2.fullName ?? ""
                    return fullName1 < fullName2
                })

                self.users = users!
                self.reloadTableViewIfNeeded()

                SVProgressHUD.dismiss()
            }
            else {
                SVProgressHUD.showError(withStatus: L10n.gettingUserFailed())
                SVProgressHUD.dismiss()
            }
            return nil
        }

    }

    // MARK: - Helpers
    func reloadTableViewIfNeeded() {
        self.tableView.reloadData()
    }

    func isUserMe(user: QBUUser) -> Bool {
        if currentUser != nil {
            return currentUser!.id == user.id
        }
        else {
            return false
        }
    }

    func openPrivateChat(privateDialog: QBChatDialog) {

        let chatsVC = chatMainVC.chatsVC
        let chatVC = UIViewController.getViewController(storyboardName: "Chat", storyboardID: "ChatVC") as! ChatVC
        chatVC.dialog = privateDialog
        chatVC.dismissHandler = { dialog in
            let dialogId = dialog.id ?? ""
            chatsVC?.loadUpdatedDialog(dialogId: dialogId)
        }
        let navVC = UINavigationController(rootViewController: chatVC)
        navVC.setDefaultModalPresentationStyle()
        chatMainVC.present(navVC, animated: true, completion: nil)
    }

}

// MARK: - UITableViewDataSource

extension ContactsVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell

        if (users.count < indexPath.row) {
            return cell
        }

        let user = users[indexPath.row]
        cell.tag = indexPath.row

        if isUserMe(user: user) {
            cell.nameLabel.text = "\(user.fullName ?? "") (you)"
        }
        else {
            cell.nameLabel.text = user.fullName ?? ""
        }

        // status
        cell.statusLabel.isHidden = true
        cell.nameLeftConstraint.constant = 0.0

        // checkbox
        cell.checkImageView.isHidden = true
        cell.nameRightConstraint.constant = -10.0

        return cell
    }

}

// MARK: - UITableViewDelegate
extension ContactsVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        if (ServicesManager.instance().isProcessingLogOut!) {
            return
        }

        DispatchQueue.main.async {

            self.chatMainVC.moveToViewController(at: 0)
            let targetUser = self.users[indexPath.row]
            let privateDialog =  ServicesManager.instance().chatService.dialogsMemoryStorage.privateChatDialog(withOpponentID: targetUser.id)
            if privateDialog != nil {
                self.openPrivateChat(privateDialog: privateDialog!)
            }
            else {
                SVProgressHUD.show(withStatus: L10n.creatingDialogs(), maskType: .clear)

                ServicesManager.instance().chatService.createPrivateChatDialog(withOpponent: targetUser).continueOnSuccessWith(block: { (bfTask) -> Any? in
                    SVProgressHUD.dismiss()
                    let dialog = bfTask.result
                    if dialog != nil {
                        Utils.dialogsManager?.sendSystemMessageAboutCreatingDialog(chat: QBChat.instance, dialog: dialog!)
                        self.openPrivateChat(privateDialog: dialog!)
                    }
                    return nil
                })
            }
        }
    }



}

extension ContactsVC: IndicatorInfoProvider {

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return "CONTACTS"
    }
}


