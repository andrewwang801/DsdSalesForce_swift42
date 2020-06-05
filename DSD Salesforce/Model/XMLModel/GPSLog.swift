//
//  GPSLog.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 8/6/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import Foundation

import UIKit

class GPSLog: NSObject {

    var trxnNo = ""
    var chainNo = ""
    var custNo = ""
    var startDate = ""
    var startTime = ""
    var endDate = ""
    var endTime = ""
    var startTrxnNo = ""
    var latitude: Double = 0
    var longitude: Double = 0
    var docNo = ""
    var docType = ""
    var voidFlag = ""
    var printedFlag = ""
    var trxnDate = ""
    var trxnTime = ""
    var reference = ""
    var tCOMStatus = ""
    var saleDate = ""

    static var keyArray = ["TrxnNo", "ChainNo", "CustNo", "StartDate", "StartTime", "EndDate", "EndTime", "StartTrxnNo", "GPSData", "DocNo", "DocType", "VoidFlag", "PrintedFlag", "TrxnDate", "TrxnTime", "Reference", "TCOMStatus", "SaleDate"]

    func getDictionary() -> [String: String] {
        var dic = [String: String]()
        dic["TrxnNo"] = trxnNo
        dic["ChainNo"] = chainNo
        dic["CustNo"] = custNo
        dic["StartDate"] = startDate
        dic["StartTime"] = startTime
        dic["EndDate"] = endDate
        dic["EndTime"] = endTime
        dic["StartTrxnNo"] = startTrxnNo
        dic["GPSData"] = "\(latitude), \(longitude)"
        dic["DocNo"] = docNo
        dic["DocType"] = docType
        dic["VoidFlag"] = voidFlag
        dic["PrintedFlag"] = printedFlag
        dic["TrxnDate"] = trxnDate
        dic["TrxnTime"] = trxnTime
        dic["Reference"] = reference
        dic["TCOMStatus"] = tCOMStatus
        dic["SaleDate"] = saleDate
        return dic
    }

    static func make(chainNo: String, custNo: String, docType: String, date: Date, location: CLLocationCoordinate2D) -> GPSLog {

        let trxnDate = date.toDateString(format: kTightJustDateFormat) ?? ""
        let trxnTime = date.toDateString(format: kTightJustTimeFormat) ?? ""
        let trxnNo = "\(date.getTimestamp())"

        let gpsLog = GPSLog()
        gpsLog.trxnNo = trxnNo
        gpsLog.chainNo = chainNo
        gpsLog.custNo = custNo
        gpsLog.startDate = trxnDate
        gpsLog.startTime = trxnTime
        gpsLog.endDate = trxnDate
        gpsLog.endTime = trxnTime
        gpsLog.startTrxnNo = trxnNo

        gpsLog.latitude = location.latitude
        gpsLog.longitude = location.longitude
        gpsLog.docNo = "0"
        gpsLog.docType = docType
        gpsLog.voidFlag = "0"
        gpsLog.printedFlag = "0"
        gpsLog.trxnDate = trxnDate
        gpsLog.trxnTime = trxnTime
        gpsLog.reference = ""
        gpsLog.tCOMStatus = "0"
        gpsLog.saleDate = trxnDate
        return gpsLog
    }

    func makeTransaction() -> UTransaction {
        let trxnNoString = self.trxnNo
        let trxnNo = Int64(trxnNoString) ?? 0
        let date = Date.fromTimeStamp(timeStamp: trxnNo)
        let globalInfo = GlobalInfo.shared
        let trip = globalInfo.routeControl?.trip ?? ""
        return UTransaction.make(chainNo: self.chainNo, custNo: self.custNo, docType: self.docType, date: date, reference: reference, trip: trip)
    }

    static func saveToXML(gpsLogArray: [GPSLog], filePath: String) {
        var dicArray = [[String: String]]()
        for gpsLog in gpsLogArray {
            let dictionary = gpsLog.getDictionary()
            dicArray.append(dictionary)
        }
        Utils.saveToXML(dicArray: dicArray, keyArray: keyArray, rootName: "GPS", branchName: "GPSLog", filePath: filePath)
    }

    static func saveToXML(gpsLogArray: [GPSLog]) -> String {
        if gpsLogArray.count == 0 {
            return ""
        }
        let nowString = Date().toDateString(format: kTightFullDateFormat) ?? ""
        let fileName = "GPS\(nowString).upl"
        let filePath = CommData.getFilePathAppended(byDocumentDir: fileName) ?? ""
        saveToXML(gpsLogArray: gpsLogArray, filePath: filePath)
        return filePath
    }

}
