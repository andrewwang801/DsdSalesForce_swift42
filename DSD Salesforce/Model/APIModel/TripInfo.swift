//
//  TripInfo.swift
//  DSDConnect
//
//  Created by iOS Developer on 3/16/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import Foundation

class TripInfo {

    var tripNumber = 0
    var tripDescription = ""
    var driver = ""
    var routeNumber = 0
    var mobileClient = 0

    static func arrayFrom(json: JSON) -> [TripInfo]? {

        guard let jsonArray = json.array else {return nil}
        let infoArray = jsonArray.map { (json) -> TripInfo in
            let info = TripInfo.from(json: json)
            return info
        }
        return infoArray
    }

    static func from(json: JSON) -> TripInfo {

        let newInfo = TripInfo()
        newInfo.tripNumber = json["tripNumber"].intValue
        newInfo.tripDescription = json["tripDescription"].stringValue
        newInfo.driver = json["driver"].stringValue
        newInfo.routeNumber = json["routeNumber"].intValue
        newInfo.mobileClient = json["mobileClient"].intValue
        return newInfo
    }

    func getTripString() -> String {
        return "\(self.tripNumber) - \(self.tripDescription)"
    }

}
