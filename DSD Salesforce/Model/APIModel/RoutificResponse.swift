//
//  RoutificResponse.swift
//  DSDConnect
//
//  Created by iOS Developer on 3/16/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import Foundation

class RoutificResponse {

    var id = ""
    var status = ""
    var region = ""
    var createdAt = ""
    var output: RoutificOutput?

    init(json: JSON) {
        id = json["id"].stringValue
        status = json["status"].stringValue
        region = json["region"].stringValue
        createdAt = json["createdAt"].stringValue
        output = RoutificOutput(json: json["output"])
    }
}
