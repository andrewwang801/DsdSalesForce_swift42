//
//  ChatMainVC.swift
//  DSDConnect
//
//  Created by iOS Developer on 3/22/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class ChatMainVC: ButtonBarPagerTabStripViewController {

    @IBOutlet weak var topBarSeparators: UIView!

    var chatsVC: ChatsVC!
    var groupsVC: GroupsVC!
    var contactsVC: ContactsVC!

    var containerVC: ChatContainerVC!

    private var observer: NSObjectProtocol?

    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        settings.style.buttonBarBackgroundColor = kOrangeColor
        settings.style.buttonBarMinimumLineSpacing = 0.0
        settings.style.buttonBarItemBackgroundColor = kMenuBackgroundColor
        settings.style.buttonBarMinimumInteritemSpacing = 0.0
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.selectedBarBackgroundColor = kOrangeColor
        settings.style.selectedBarHeight = 5.0
        settings.style.buttonBarItemFont = UIFont.boldSystemFont(ofSize: 16.0)
        settings.style.buttonBarItemTitleColor = UIColor.white
        settings.style.buttonBarHeight = 60.0

        initViewControllers()

        super.viewDidLoad()

        self.perform(#selector(ChatMainVC.placeSeparators), with: nil, afterDelay: 0.3)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        ServicesManager.instance().chatService.addDelegate(self)
        
        self.observer = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: OperationQueue.main) { (notification) -> Void in

            if !QBChat.instance.isConnected {
                SVProgressHUD.show(withStatus: L10n.connectingToChat(), maskType: SVProgressHUDMaskType.none)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self.observer!)

        ServicesManager.instance().chatService.removeDelegate(self)

        SVProgressHUD.dismiss()
    }

    func initViewControllers() {
        chatsVC = UIViewController.getViewController(storyboardName: "Chat", storyboardID: "ChatsVC") as! ChatsVC
        groupsVC = UIViewController.getViewController(storyboardName: "Chat", storyboardID: "GroupsVC") as! GroupsVC
        contactsVC = UIViewController.getViewController(storyboardName: "Chat", storyboardID: "ContactsVC") as! ContactsVC
        contactsVC.chatMainVC = self
    }

    @objc func placeSeparators() {
        DispatchQueue.main.async {
            self.view.bringSubviewToFront(self.topBarSeparators)
        }
    }

    override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return [chatsVC, groupsVC, contactsVC]
    }

}

extension ChatMainVC: QMChatServiceDelegate {

    // MARK: - QMChatServiceDelegate

    func chatService(_ chatService: QMChatService, didUpdateChatDialogInMemoryStorage chatDialog: QBChatDialog) {
    }

    func chatService(_ chatService: QMChatService,didUpdateChatDialogsInMemoryStorage dialogs: [QBChatDialog]){
    }

    func chatService(_ chatService: QMChatService, didAddChatDialogsToMemoryStorage chatDialogs: [QBChatDialog]) {
    }

    func chatService(_ chatService: QMChatService, didAddChatDialogToMemoryStorage chatDialog: QBChatDialog) {
    }

    func chatService(_ chatService: QMChatService, didDeleteChatDialogWithIDFromMemoryStorage chatDialogID: String) {
    }

    func chatService(_ chatService: QMChatService, didAddMessagesToMemoryStorage messages: [QBChatMessage], forDialogID dialogID: String) {
    }

    func chatService(_ chatService: QMChatService, didAddMessageToMemoryStorage message: QBChatMessage, forDialogID dialogID: String){
    }

}

// MARK: QMChatConnectionDelegate
extension ChatMainVC: QMChatConnectionDelegate {

    func chatServiceChatDidFail(withStreamError error: Error) {
        SVProgressHUD.showError(withStatus: error.localizedDescription)
    }

    func chatServiceChatDidAccidentallyDisconnect(_ chatService: QMChatService) {
        SVProgressHUD.showError(withStatus: L10n.disconnected())
    }

    func chatServiceChatDidConnect(_ chatService: QMChatService) {
        SVProgressHUD.showSuccess(withStatus: L10n.connected(), maskType:.clear)
    }

    func chatService(_ chatService: QMChatService,chatDidNotConnectWithError error: Error){
        SVProgressHUD.showError(withStatus: error.localizedDescription)
    }


    func chatServiceChatDidReconnect(_ chatService: QMChatService) {
        SVProgressHUD.showSuccess(withStatus: L10n.connected(), maskType: .clear)
    }
}
