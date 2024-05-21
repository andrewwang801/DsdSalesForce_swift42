//
//  UAsset.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/31/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class UAsset: NSObject {

    var trxnNo = ""
    var docNo = ""
    var docType = ""
    var voidFlag = ""
    var printedFlag = ""
    var trxnDate = ""
    var trxnTime = ""
    var reference = ""
    var tCOMStatus = ""
    var saleDate = ""
    var chainNo = ""
    var custNo = ""
    var equipmentNo = ""
    var serialNo = ""
    var equipmentType = ""
    var requestDate = ""
    var reason = ""
    var features = ""
    var response = ""
    var make = ""
    var model = ""
    var application = ""
    var statusCode = ""
    var assetType = ""
    var repairReason = ""
    var repairNotes = ""
    var altEquipment = ""

    static var keyArray = ["TrxnNo", "DocNo", "DocType", "VoidFlag", "PrintedFlag", "TrxnDate", "TrxnTime", "Reference", "TCOMStatus", "SaleDate", "ChainNo", "CustNo", "EquipmentNo", "SerialNo", "EquipmentType", "RequestDate", "Reason", "Features", "Response", "Make", "Application", "StatusCode", "AssetType", "RepairReason", "RepairNotes", "AltEquipment"]

    func getDictionary() -> [String: String] {
        var dic = [String: String]()
        dic["TrxnNo"] = trxnNo
        dic["DocNo"] = docNo
        dic["DocType"] = docType
        dic["VoidFlag"] = voidFlag
        dic["PrintedFlag"] = printedFlag
        dic["TrxnDate"] = trxnDate
        dic["TrxnTime"] = trxnTime
        dic["Reference"] = reference
        dic["TCOMStatus"] = tCOMStatus
        dic["SaleDate"] = saleDate
        dic["ChainNo"] = chainNo
        dic["CustNo"] = custNo
        dic["EquipmentNo"] = equipmentNo
        dic["SerialNo"] = serialNo
        dic["EquipmentType"] = equipmentType
        dic["RequestDate"] = requestDate
        dic["Reason"] = reason
        dic["Features"] = features
        dic["Response"] = response
        dic["Make"] = make
        dic["Application"] = application
        dic["StatusCode"] = statusCode
        dic["AssetType"] = assetType
        dic["RepairReason"] = repairReason
        dic["RepairNotes"] = repairNotes
        dic["AltEquipment"] = altEquipment
        return dic
    }

    func makeTransaction() -> UTransaction {
        let trxnNoString = self.trxnNo
        let trxnNo = Int64(trxnNoString) ?? 0
        let date = Date.fromTimeStamp(timeStamp: trxnNo)
        let globalInfo = GlobalInfo.shared
        let trip = globalInfo.routeControl?.trip ?? ""
        return UTransaction.make(chainNo: self.chainNo, custNo: self.custNo, docType: self.docType, date: date, reference: "", trip: trip)
    }

    static func saveToXML(assetArray: [UAsset], filePath: String) {

        var dicArray = [[String: String]]()
        for asset in assetArray {
            let dictionary = asset.getDictionary()
            dicArray.append(dictionary)
        }
        Utils.saveToXML(dicArray: dicArray, keyArray: keyArray, rootName: "Assets", branchName: "Asset", filePath: filePath)
    }

    static func saveToXML(assetArray: [UAsset]) -> String {
        if assetArray.count == 0 {
            return ""
        }
        let nowString = Date().toDateString(format: kTightFullDateFormat) ?? ""
        let fileName = "Assets\(nowString).upl"
        let filePath = CommData.getFilePathAppended(byDocumentDir: fileName) ?? ""
        saveToXML(assetArray: assetArray, filePath: filePath)
        return filePath
    }

}
