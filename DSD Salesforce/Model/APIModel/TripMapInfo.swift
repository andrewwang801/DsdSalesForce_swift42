//
//  TripMapInfo.swift
//  DSDConnect
//
//  Created by iOS Developer on 3/16/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import Foundation

class TripMapInfo: NSObject {
    var customerChain = 0
    var customerNumber = 0
    var customerName = ""
    var longitude: Double = 0
    var latitude: Double = 0
    var deliveryDate = ""
    var mobileClientName = ""
    var mobileClientId = 0
    var docNo = ""
    var totalInvoiceAmount: Float = 0
    var receivedBy = ""
    var time = ""

    static func arrayFrom(json: JSON) -> [TripMapInfo]? {

        guard let jsonArray = json.array else {return nil}
        let infoArray = jsonArray.map { (json) -> TripMapInfo in
            let info = TripMapInfo.from(json: json)
            return info
        }
        return infoArray
    }

    static func from(json: JSON) -> TripMapInfo {
        let newInfo = TripMapInfo()
        newInfo.customerChain = json["customerChain"].intValue
        newInfo.customerNumber = json["customerNumber"].intValue
        newInfo.customerName = json["customerName"].stringValue
        newInfo.longitude = json["longitude"].doubleValue
        newInfo.latitude = json["latitude"].doubleValue
        newInfo.deliveryDate = json["deliveryDate"].stringValue
        newInfo.mobileClientName = json["mobileClientName"].stringValue
        newInfo.mobileClientId = json["mobileClientId"].intValue
        newInfo.docNo = json["docNo"].stringValue
        newInfo.totalInvoiceAmount = json["totalInvoiceAmount"].floatValue
        newInfo.receivedBy = json["receivedBy"].stringValue
        newInfo.time = json["time"].stringValue
        return newInfo
    }
}
