//
//  RoutificErrorResponse.swift
//  DSDConnect
//
//  Created by iOS Developer on 3/16/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import Foundation

class RoutificErrorResponse {
    var error = ""
    var error_type = ""

    init(json: JSON) {
        error = json["error"].stringValue
        error_type = json["error_type"].stringValue
    }
}
