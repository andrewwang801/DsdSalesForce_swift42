//
//  FTPLoginInfo.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 10/25/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import Foundation

class FTPLoginInfo {

    var port = ""
    var chatCompanyCode = ""
    var username = ""
    var password = ""
    var ipAddress = ""
    var root = ""

    static func from(json: JSON) -> FTPLoginInfo? {
        guard let port = json["port"].int,
            let chatCompanyCode = json["chatCompanyCode"].string,
            let username = json["username"].string,
            let password = json["password"].string,
            let ipAddress = json["ipAddress"].string else {return nil}
        let ftpLoginInfo = FTPLoginInfo()
        ftpLoginInfo.port = "\(port)"
        ftpLoginInfo.chatCompanyCode = chatCompanyCode
        ftpLoginInfo.username = username
        ftpLoginInfo.password = password
        ftpLoginInfo.ipAddress = ipAddress
        return ftpLoginInfo
    }

}
