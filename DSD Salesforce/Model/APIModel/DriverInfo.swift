//
//  DriverInfo.swift
//  DSDConnect
//
//  Created by iOS Developer on 3/16/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import Foundation

class DriverInfo {
    var id = ""
    var name = ""
    var mobileClientId = 0

    init(json: JSON) {
        id = json["id"].stringValue
        name = json["name"].stringValue
        mobileClientId = json["mobileClientId"].intValue
    }
}
