//
//  LoginInfo.swift
//  DSDConnect
//
//  Created by iOS Developer on 3/16/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import Foundation

class LoginInfo {
    var token = ""
    var chatCompanyCode = ""
    var chatPassword = ""

    static func from(json: JSON) -> LoginInfo? {
        guard let token = json["token"].string,
        let chatCompanyCode = json["chatCompanyCode"].string,
        let chatPassword = json["chatPassword"].string else {return nil}
        let loginInfo = LoginInfo()
        loginInfo.token = token
        loginInfo.chatCompanyCode = chatCompanyCode
        loginInfo.chatPassword = chatPassword
        return loginInfo
    }

}
