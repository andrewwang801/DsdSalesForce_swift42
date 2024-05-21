//
//  TripStatusInfo.swift
//  DSDConnect
//
//  Created by iOS Developer on 3/16/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import Foundation

class TripStatusInfo {
    var detailId = ""
    var chainNumber = 0
    var customerNumber = 0
    var customerName = ""
    var city = ""
    var docNo = ""
    var docType = ""
    var routeNumber = 0
    var tripNo = 0
    var dayNumber = 0
    var orderNumber = ""
    var reference = ""
    var status = ""
    var trxnNo: Int64 = 0
    var deliverySequence = 0
    var deliveryDate = ""
    var state = ""
    var zipCode = ""
    var addressLineOne = ""
    var time = ""
    var statusMessage = ""
    var trxnDateTime = ""
    var trxnDate = ""
    var receivedBy = ""
    var transactionValue: Float = 0

    static func arrayFrom(json: JSON) -> [TripStatusInfo]? {

        guard let jsonArray = json.array else {return nil}
        let infoArray = jsonArray.map { (json) -> TripStatusInfo in
            let info = TripStatusInfo.from(json: json)
            return info
        }
        return infoArray
    }

    static func from(json: JSON) -> TripStatusInfo {

        let statusInfo = TripStatusInfo()
        statusInfo.detailId = json["detailId"].stringValue
        statusInfo.chainNumber = json["chainNumber"].intValue
        statusInfo.customerNumber = json["customerNumber"].intValue
        statusInfo.customerName = json["customerName"].stringValue
        statusInfo.city = json["city"].stringValue
        statusInfo.docNo = json["docNo"].stringValue
        statusInfo.docType = json["docType"].stringValue
        statusInfo.routeNumber = json["routeNumber"].intValue
        statusInfo.tripNo = json["tripNo"].intValue
        statusInfo.dayNumber = json["dayNumber"].intValue
        statusInfo.orderNumber = json["orderNumber"].stringValue
        statusInfo.reference = json["reference"].stringValue
        statusInfo.status = json["status"].stringValue
        statusInfo.trxnNo = json["trxnNo"].int64Value
        statusInfo.deliverySequence = json["deliverySequence"].intValue
        statusInfo.deliveryDate = json["deliveryDate"].stringValue
        statusInfo.state = json["state"].stringValue
        statusInfo.zipCode = json["zipCode"].stringValue
        statusInfo.addressLineOne = json["addressLineOne"].stringValue
        statusInfo.time = json["time"].stringValue
        statusInfo.statusMessage = json["statusMessage"].stringValue
        statusInfo.trxnDateTime = json["trxnDateTime"].stringValue
        statusInfo.trxnDate = json["trxnDate"].stringValue
        statusInfo.receivedBy = json["receivedBy"].stringValue
        statusInfo.transactionValue = json["transactionValue"].floatValue
        return statusInfo
    }

}
