//
//  RoutificSolution.swift
//  DSDConnect
//
//  Created by iOS Developer on 3/16/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import Foundation

class RoutificSolution {

    var vehicle_1 = [RoutificLocation]()

    init(json: JSON) {
        vehicle_1.removeAll()
        if let jsonArray = json["vehicle_1"].array {
            for locationJSON in jsonArray {
                let location = RoutificLocation(json: locationJSON)
                vehicle_1.append(location)
            }
        }
    }
}
