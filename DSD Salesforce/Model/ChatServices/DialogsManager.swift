//
//  DialogsManager.swift
//  DSDConnect
//
//  Created by iOS Developer on 3/27/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import Quickblox

class DialogsManager {

    let PROPERTY_OCCUPANTS_IDS = "occupants_ids";
    let PROPERTY_DIALOG_TYPE = "dialog_type";
    let PROPERTY_DIALOG_NAME = "dialog_name";
    let PROPERTY_NOTIFICATION_TYPE = "notification_type";
    let CREATING_DIALOG = "creating_dialog";

    func getUnreadMessageCount() -> Int {
        var unreadMessageCount = 0
        let dialogs = ServicesManager.instance().chatService.dialogsMemoryStorage.dialogs(with: [])
        for dialog in dialogs {
            unreadMessageCount += Int(dialog.unreadMessagesCount)
        }
        return unreadMessageCount
    }

    func getUsersFromDialog(dialog: QBChatDialog, completion: (([QBUUser]?, Any?)->())?) {
        let userIds = dialog.occupantIDs ?? []
        var users = [QBUUser]()
        for id in userIds {
            let user = ServicesManager.instance().usersService.usersMemoryStorage.user(withID: id.uintValue)
            if user != nil {
                users.append(user!)
            }
        }

        if users.count == userIds.count {
            completion?(users, nil)
            return
        }

        let generalResponsePage = QBGeneralResponsePage(currentPage: 1, perPage: UInt(userIds.count))
        ServicesManager.instance().usersService.getUsersWithIDs(userIds, page: generalResponsePage).continueOnSuccessWith { (bfTask) -> Any? in
            if let users = bfTask.result as? [QBUUser] {
                completion?(users, nil)
            }
            else {
                completion?(nil, nil)
            }
            return nil
        }
    }

    func sendSystemMessageAboutCreatingDialog(chat: QBChat, dialog: QBChatDialog) {
        let systemMessageCreatingDialog = buildSystemMessageAboutCreatingGroupDialog(dialog: dialog)
        let currentUser = QBSession.current.currentUser
        for recipientId in dialog.occupantIDs! {
            if recipientId.intValue != currentUser!.id {
                systemMessageCreatingDialog.recipientID = recipientId.uintValue
                chat.sendSystemMessage(systemMessageCreatingDialog, completion: { (error) in

                })
            }
        }
    }

    func buildSystemMessageAboutCreatingGroupDialog(dialog: QBChatDialog) -> QBChatMessage {
        let qbChatMessage = QBChatMessage()
        qbChatMessage.dialogID = dialog.id ?? ""
        qbChatMessage.customParameters[PROPERTY_OCCUPANTS_IDS] = DialogUtils.getOccupantsIdsStringFromList(occupantIdsList: dialog.occupantIDs ?? [])
        qbChatMessage.customParameters[PROPERTY_DIALOG_TYPE] = dialog.type.rawValue
        qbChatMessage.customParameters[PROPERTY_DIALOG_NAME] = dialog.name ?? ""
        qbChatMessage.customParameters[PROPERTY_NOTIFICATION_TYPE] = CREATING_DIALOG
        return qbChatMessage
    }

    func buildChatDialogFromSystemMessage(message: QBChatMessage) -> QBChatDialog {
        let dialogID = message.dialogID
        let dialogType = message.customParameters[PROPERTY_DIALOG_TYPE] as? String ?? ""
        let type = QBChatDialogType(rawValue: UInt(dialogType) ?? 0)!
        let chatDialog = QBChatDialog(dialogID: dialogID, type: type)
        let occupants_ids = message.customParameters[PROPERTY_OCCUPANTS_IDS] as? String ?? ""
        chatDialog.occupantIDs = DialogUtils.getOccupantsIdsListFromString(occupantIds: occupants_ids)
        chatDialog.name = message.customParameters[PROPERTY_DIALOG_NAME] as? String ?? ""
        chatDialog.unreadMessagesCount = 0
        return chatDialog
    }

}
