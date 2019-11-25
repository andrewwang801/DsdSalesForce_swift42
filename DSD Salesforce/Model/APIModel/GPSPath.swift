//
//  GPSPath.swift
//  DSDConnect
//
//  Created by iOS Developer on 12/12/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class GPSPath {

    class GPSPosition {
        var lat: Double = 0
        var lng: Double = 0

        init() {

        }

        init(json: JSON) {
            lat = json["lat"].doubleValue
            lng = json["lng"].doubleValue
        }
    }

    var distance: Int64 = 0
    var duration: Int64 = 0
    var start_location = GPSPosition()
    var end_location = GPSPosition()
    var pathList = [GPSPath]()

    init(json: JSON) {
        distance = json["distance"].int64Value
        duration = json["duration"].int64Value
        start_location = GPSPosition(json: json["start_location"])
        end_location = GPSPosition(json: json["end_location"])
        if let pathJSONArray = json["pathList"].array {
            var newPathArray = [GPSPath]()
            for pathJSON in pathJSONArray {
                let newPath = GPSPath(json: pathJSON)
                newPathArray.append(newPath)
            }
            pathList = newPathArray
        }
    }

    init() {

    }
}
