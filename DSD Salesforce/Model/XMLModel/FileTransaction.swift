//
//  FileTransaction.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/31/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class FileTransaction: NSObject {

    var trxnNo = ""
    var docNo = ""
    var docType = ""
    var voidFlag = ""
    var printedFlag = ""
    var trxnDate = ""
    var trxnTime = ""
    var reference = ""
    var tCOMStatus = ""
    var chainNo = ""
    var custNo = ""
    var saleDate = ""
    var physAvail = ""
    var virtAvail = ""
    var trip = ""
    var fileTrxnNo = ""
    var fileDocNo = ""
    var fileShortDescription = ""
    var fileLongDescription = ""
    var fileCreateDate = ""
    var fileCreateTime = ""
    var fileFileName = ""

    static var keyArray = ["TrxnNo", "DocNo", "DocType", "VoidFlag", "PrintedFlag", "TrxnDate", "TrxnTime", "Reference", "TCOMStatus", "ChainNo", "CustNo", "SaleDate", "PhysAvail", "VirtAvail", "Trip", "FileTrxnNo", "FileDocNo", "FileShortDescription", "FileLongDescription", "FileCreateDate", "FileCreateTime", "FileFileName"]

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
        dic["ChainNo"] = chainNo
        dic["CustNo"] = custNo
        dic["SaleDate"] = saleDate
        dic["PhysAvail"] = physAvail
        dic["VirtAvail"] = virtAvail
        dic["Trip"] = trip
        dic["FileTrxnNo"] = fileTrxnNo
        dic["FileDocNo"] = fileDocNo
        dic["FileShortDescription"] = fileShortDescription
        dic["FileLongDescription"] = fileLongDescription
        dic["FileCreateDate"] = fileCreateDate
        dic["FileCreateTime"] = fileCreateTime
        dic["FileFileName"] = fileFileName
        return dic
    }

    static func make(chainNo: String, custNo: String, docType: String, fileTrxnDate: Date, trip: String, trnxDate: Date, fileDocNo: String, fileShortDesc: String, fileLongDesc: String, fileCreateDate: String, fileCreateTime: String, fileName: String) -> FileTransaction {

        let trxnDateString = trnxDate.toDateString(format: kTightJustDateFormat) ?? ""
        let trxnTimeString = trnxDate.toDateString(format: kTightJustTimeFormat) ?? ""
        let trxnNo = "\(trnxDate.getTimestamp())"

        let fileTransaction = FileTransaction()
        fileTransaction.trxnNo = trxnNo
        fileTransaction.docNo = ""
        fileTransaction.docType = docType
        fileTransaction.voidFlag = "0"
        fileTransaction.printedFlag = "0"
        fileTransaction.trxnDate = trxnDateString
        fileTransaction.trxnTime = trxnTimeString
        fileTransaction.reference = ""
        fileTransaction.tCOMStatus = "0"
        fileTransaction.chainNo = chainNo
        fileTransaction.custNo = custNo
        fileTransaction.saleDate = trxnDateString
        fileTransaction.physAvail = "0"
        fileTransaction.virtAvail = "0"
        fileTransaction.trip = trip

        let fileTrxnDateString = fileTrxnDate.toDateString(format: kTightJustDateFormat) ?? ""
        let fileTrxnTimeString = fileTrxnDate.toDateString(format: kTightJustTimeFormat) ?? ""
        let fileTrxnNo = "\(fileTrxnDate.getTimestamp())"
        fileTransaction.fileTrxnNo = fileTrxnNo
        fileTransaction.fileDocNo = fileDocNo
        fileTransaction.fileShortDescription = fileShortDesc
        fileTransaction.fileLongDescription = fileLongDesc
        fileTransaction.fileCreateDate = fileTrxnDateString
        fileTransaction.fileCreateTime = fileTrxnTimeString
        fileTransaction.fileFileName = fileName

        return fileTransaction
    }

    func makeTransaction() -> UTransaction {
        let trxnNoString = self.trxnNo
        let trxnNo = Int64(trxnNoString) ?? 0
        let date = Date.fromTimeStamp(timeStamp: trxnNo)
        let globalInfo = GlobalInfo.shared
        let trip = globalInfo.routeControl?.trip ?? ""
        return UTransaction.make(chainNo: self.chainNo, custNo: self.custNo, docType: self.docType, date: date, reference: fileFileName, trip: trip)
    }

    static func saveToXML(fileTransactionArray: [FileTransaction], filePath: String) {

        var dicArray = [[String: String]]()
        for fileTransaction in fileTransactionArray {
            let dictionary = fileTransaction.getDictionary()
            dicArray.append(dictionary)
        }
        Utils.saveToXML(dicArray: dicArray, keyArray: keyArray, rootName: "Files", branchName: "File", filePath: filePath)
    }

    static func saveToXML(fileTransactionArray: [FileTransaction]) -> String {
        if fileTransactionArray.count == 0 {
            return ""
        }
        let nowString = Date().toDateString(format: kTightFullDateFormat) ?? ""
        let fileName = "Files\(nowString).upl"
        let filePath = CommData.getFilePathAppended(byCacheDir: fileName) ?? ""
        saveToXML(fileTransactionArray: fileTransactionArray, filePath: filePath)
        return filePath
    }

}
