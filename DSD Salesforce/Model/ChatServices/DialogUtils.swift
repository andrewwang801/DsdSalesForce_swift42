//
//  DialogUtils.swift
//  DSDConnect
//
//  Created by iOS Developer on 3/27/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import UserNotifications

class DialogUtils {
    
    static func getOccupantsIdsStringFromList(occupantIdsList: [NSNumber]) -> String {
        let idArray = occupantIdsList.map {"\($0.intValue)"}
        return idArray.joined(separator: ",")
    }

    static func getOccupantsIdsListFromString(occupantIds: String) -> [NSNumber] {
        var occupantIdsList = [NSNumber]()
        let occupantIdsArray = occupantIds.components(separatedBy: ",")
        for occupantId in occupantIdsArray {
            occupantIdsList.append(NSNumber(value: Int(occupantId) ?? 0))
        }
        return occupantIdsList
    }

    /*
    static func createDialog(users: [QBUUser]) -> QBChatDialog {
        let currentUser = QBSession.current.currentUser!
        var _users = users
        for (index,user) in _users.enumerated() {
            if user.id == currentUser.id {
                _users.remove(at: index)
            }
        }

    }*/


    static func createDialogWithSelectedUsers(users: [QBUUser], completion: ((QBChatDialog?)->())?) {

    }

    static func sendPushNotification(userIdsList: [NSNumber], dialogId: String, message: String, sender: String) {
        let idsString = getOccupantsIdsStringFromList(occupantIdsList: userIdsList)
        var payload = [String: Any]()
        var aps = [String: Any]()
        var alert = [String: String]()
        alert["title"] = sender
        alert["body"] = message
        aps[QBMPushMessageAlertKey] = alert
        aps[QBMPushMessageSoundKey] = "default"
        aps[kQBMDialogIDKey] = dialogId
        payload[QBMPushMessageApsKey] = aps

        let pushMessage = QBMPushMessage()
        pushMessage.payloadDict = [QBMPushMessageApsKey:aps]
        QBRequest.sendPush(pushMessage, toUsers: idsString, successBlock: { (response, event) in
            NSLog("Push sent to \(idsString) with \(aps)")
        }) { (error) in
            NSLog("Failed to send push to \(idsString) with \(aps)")
        }
    }

    static func refreshAppBadge() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpdateBadgeNotificationName), object: nil)
    }

    /*
    static func refreshAppBadge() {

        if Utils.dialogsManager != nil {
            let badgeNumber = Utils.dialogsManager?.getUnreadMessageCount() ?? 0
            UIApplication.shared.applicationIconBadgeNumber = badgeNumber
        }

    }*/
}
