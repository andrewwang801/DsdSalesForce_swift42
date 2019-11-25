//
//  RoutificLocation.swift
//  DSDConnect
//
//  Created by iOS Developer on 3/16/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import Foundation

class RoutificLocation {

    var location_id = ""
    var location_name = ""
    var arrival_time = ""
    var finish_time = ""

    init(json: JSON) {
        location_id = json["location_id"].stringValue
        location_name = json["location_name"].stringValue
        arrival_time = json["arrival_time"].stringValue
        finish_time = json["finish_time"].stringValue
    }

}
