//
//  GooglePoint.swift
//  DSDConnect
//
//  Created by iOS Developer on 12/12/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class GooglePoint {

    class GoogleLocation {

        var latitude: Double = 0
        var longitude: Double = 0

        init() {

        }

        init(json: JSON) {
            latitude = json["latitude"].doubleValue
            longitude = json["longitude"].doubleValue
        }
    }

    var originalIndex = -1
    var placeId = ""
    var location = GoogleLocation()

    init(json: JSON) {
        originalIndex = json["originalIndex"].int ?? -1
        placeId = json["placeId"].stringValue
        location = GoogleLocation(json: json["location"])
    }

    static func getArrayBy(pointJSONArray: [JSON]) -> [GooglePoint] {
        var pointArray = [GooglePoint]()
        for pointJSON in pointJSONArray {
            let point = GooglePoint(json: pointJSON)
            pointArray.append(point)
        }
        return pointArray
    }
}
