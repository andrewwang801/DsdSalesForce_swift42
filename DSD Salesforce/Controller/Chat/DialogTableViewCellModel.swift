//
//  DialogsTableViewController.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/1/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import UIKit
import Quickblox

class DialogTableViewCellModel: NSObject {

    var detailTextLabelText: String = ""
    var textLabelText: String = ""
    var unreadMessagesCounterLabelText : String?
    var unreadMessagesCounterHiden = true
    var dialogIcon : UIImage?


    init(dialog: QBChatDialog) {
        super.init()

        switch (dialog.type){
        case .publicGroup:
            self.detailTextLabelText = L10n.publicGroup()
            break
        case .group:
            self.detailTextLabelText = L10n.group()
            break
        case .private:
            self.detailTextLabelText = L10n.private()
            break

            //if dialog.recipientID == -1 {
            //    return
            //}

            // Getting recipient from users service.
            /*
            if let recipient = ServicesManager.instance().usersService.usersMemoryStorage.user(withID: UInt(dialog.recipientID)) {
                self.textLabelText = recipient.login ?? recipient.email!
            }*/
            //self.
        }

        if self.textLabelText.isEmpty {
            // group chat

            if let dialogName = dialog.name {
                self.textLabelText = dialogName
            }
        }

        // Unread messages counter label

        if (dialog.unreadMessagesCount > 0) {

            var trimmedUnreadMessageCount : String

            if dialog.unreadMessagesCount > 99 {
                trimmedUnreadMessageCount = "99+"
            } else {
                trimmedUnreadMessageCount = String(format: "%d", dialog.unreadMessagesCount)
            }

            self.unreadMessagesCounterLabelText = trimmedUnreadMessageCount
            self.unreadMessagesCounterHiden = false

        }
        else {

            self.unreadMessagesCounterLabelText = nil
            self.unreadMessagesCounterHiden = true
        }

        // Dialog icon

        if dialog.type == .private {
            self.dialogIcon = UIImage(named: "user")
        }
        else {
            self.dialogIcon = UIImage(named: "group")
        }
    }
}

