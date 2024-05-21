//
//  CamerasTransaction.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/31/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class CameraTransaction: NSObject {

    var chainNo = ""
    var custNo = ""
    var trxnNo = ""
    var docNo = ""
    var docType = ""
    var voidFlag = ""
    var printedFlag = ""
    var trxnDate = ""
    var trxnTime = ""
    var reference = ""
    var tComStatus = ""

    static var keyArray = ["ChainNo", "CustNo", "TrxnNo", "DocNo", "DocType", "VoidFlag", "PrintedFlag", "TrxnDate", "TrxnTime", "Reference", "TCOMStatus"]

    func getDictionary() -> [String: String] {
        var dic = [String: String]()
        dic["ChainNo"] = chainNo
        dic["CustNo"] = custNo
        dic["TrxnNo"] = trxnNo
        dic["DocNo"] = docNo
        dic["DocType"] = docType
        dic["VoidFlag"] = voidFlag
        dic["PrintedFlag"] = printedFlag
        dic["TrxnDate"] = trxnDate
        dic["TrxnTime"] = trxnTime
        dic["Reference"] = reference
        dic["TCOMStatus"] = tComStatus
        return dic
    }

    /// For camera transaction (CAM)
    static func make(chainNo: String, custNo: String, docType: String, photoPath: String, reference: String, trip: String, date: Date) -> CameraTransaction {

        let dateString = date.toDateString(format: kTightJustDateFormat) ?? ""
        let timeString = date.toDateString(format: kTightJustTimeFormat) ?? ""
        let dateFullString = date.toDateString(format: kTightFullDateFormat) ?? ""
        let trxnNo = date.getTimestamp()
        let trxnNoString = "\(trxnNo)"
        let fileExtension = String.getFileExtensionFromPath(filePath: photoPath)
        var _reference = reference
        if _reference.isEmpty == true {
            _reference = "\(trip)\(dateFullString)\(trxnNo.toLeftPaddedString(digitCount: 12) ?? "")01.\(fileExtension)"
            let newPath = CommData.getFilePathAppended(byCacheDir: _reference) ?? ""
            let fileManager = FileManager.default
            try? fileManager.copyItem(atPath: photoPath, toPath: newPath)
            CommData.deleteFileIfExist(photoPath)
        }

        let cameraTransaction = CameraTransaction()
        cameraTransaction.chainNo = chainNo
        cameraTransaction.custNo = custNo
        cameraTransaction.trxnNo = trxnNoString
        cameraTransaction.docNo = "0"
        cameraTransaction.docType = docType
        cameraTransaction.voidFlag = "0"
        cameraTransaction.printedFlag = "0"
        cameraTransaction.trxnDate = dateString
        cameraTransaction.trxnTime = timeString
        cameraTransaction.reference = _reference
        cameraTransaction.tComStatus = "0"

        return cameraTransaction
    }

    /// For normal camera transaction (MAIT)
    static func make(chainNo: String, custNo: String, docType: String, reference: String, date: Date) -> CameraTransaction {

        let dateString = date.toDateString(format: kTightJustDateFormat) ?? ""
        let timeString = date.toDateString(format: kTightJustTimeFormat) ?? ""
        let trxnNo = date.getTimestamp()
        let trxnNoString = "\(trxnNo)"

        let cameraTransaction = CameraTransaction()
        cameraTransaction.chainNo = chainNo
        cameraTransaction.custNo = custNo
        cameraTransaction.trxnNo = trxnNoString
        cameraTransaction.docNo = "0"
        cameraTransaction.docType = docType
        cameraTransaction.voidFlag = "0"
        cameraTransaction.printedFlag = "0"
        cameraTransaction.trxnDate = dateString
        cameraTransaction.trxnTime = timeString
        cameraTransaction.reference = reference
        cameraTransaction.tComStatus = "0"

        return cameraTransaction
    }

    func makeTransaction() -> UTransaction {
        let trxnNoString = self.trxnNo
        let trxnNo = Int64(trxnNoString) ?? 0
        let date = Date.fromTimeStamp(timeStamp: trxnNo)
        let globalInfo = GlobalInfo.shared
        let trip = globalInfo.routeControl?.trip ?? ""
        return UTransaction.make(chainNo: self.chainNo, custNo: self.custNo, docType: self.docType, date: date, reference: reference, trip: trip)
    }

    static func saveToXML(cameraArray: [CameraTransaction], filePath: String) {

        var dicArray = [[String: String]]()
        for cameraTransaction in cameraArray {
            let dictionary = cameraTransaction.getDictionary()
            dicArray.append(dictionary)
        }
        Utils.saveToXML(dicArray: dicArray, keyArray: keyArray, rootName: "Cameras", branchName: "Camera", filePath: filePath)
    }

    static func saveToXML(cameraArray: [CameraTransaction]) -> String {
        if cameraArray.count == 0 {
            return ""
        }
        let nowString = Date().toDateString(format: kTightFullDateFormat) ?? ""
        let fileName = "Cameras\(nowString).upl"
        let filePath = CommData.getFilePathAppended(byCacheDir: fileName) ?? ""
        saveToXML(cameraArray: cameraArray, filePath: filePath)
        return filePath
    }

}
