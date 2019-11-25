//
//  UService.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/31/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class UService: NSObject {

    var trxnNo = ""
    var chainNo = ""
    var custNo = ""
    var period = ""
    var seq = ""
    var done = ""
    var reason = ""
    var trxnDate = ""
    var trxnTime = ""
    var aTrxnNo = ""
    var aDocNo = ""
    var docType = ""
    var voidFlag = ""
    var printedFlag = ""
    var aTrxnDate = ""
    var aTrxnTime = ""
    var reference = ""
    var tCOMStatus = ""
    var saleDate = ""

    static var keyArray = ["TrxnNo", "ChainNo", "CustNo", "Period", "Seq", "Done", "Reason", "TrxnDate", "TrxnTime", "aTrxnNo", "aDocNo",   "DocType", "VoidFlag", "PrintedFlag", "aTrxnDate", "aTrxnTime", "Reference", "TCOMStatus", "SaleDate"]

    func updateBy(theSource: UService) {
        self.trxnNo = theSource.trxnNo
        self.chainNo = theSource.chainNo
        self.custNo = theSource.custNo
        self.period = theSource.period
        self.seq = theSource.seq
        self.done = theSource.done
        self.reason = theSource.reason
        self.trxnDate = theSource.trxnDate
        self.trxnTime = theSource.trxnTime
        self.aTrxnNo = theSource.aTrxnNo
        self.aDocNo = theSource.aDocNo
        self.docType = theSource.docType
        self.voidFlag = theSource.voidFlag
        self.printedFlag = theSource.printedFlag
        self.aTrxnDate = theSource.aTrxnDate
        self.aTrxnTime = theSource.aTrxnTime
        self.reference = theSource.reference
        self.tCOMStatus = theSource.tCOMStatus
        self.saleDate = theSource.saleDate
    }

    func getDictionary() -> [String: String] {
        var dic = [String: String]()
        dic["TrxnNo"] = trxnNo
        dic["ChainNo"] = chainNo
        dic["CustNo"] = custNo
        dic["Period"] = period
        dic["Seq"] = seq
        dic["Done"] = done
        dic["Reason"] = reason
        dic["TrxnDate"] = trxnDate
        dic["TrxnTime"] = trxnTime
        dic["aTrxnNo"] = aTrxnNo
        dic["aDocNo"] = aDocNo
        dic["DocType"] = docType
        dic["VoidFlag"] = voidFlag
        dic["PrintedFlag"] = printedFlag
        dic["aTrxnDate"] = aTrxnDate
        dic["aTrxnTime"] = aTrxnTime
        dic["Reference"] = reference
        dic["TCOMStatus"] = tCOMStatus
        dic["SaleDate"] = saleDate
        return dic
    }

    static func make(chainNo: String, custNo: String, docType: String, date: Date, reason: String, done: String) -> UService {

        let trxnDate = date.toDateString(format: kTightJustDateFormat) ?? ""
        let trxnTime = date.toDateString(format: kTightJustTimeFormat) ?? ""
        let trxnNo = "\(date.getTimestamp())"

        let uService = UService()
        uService.trxnNo = trxnNo
        uService.chainNo = chainNo
        uService.custNo = custNo
        uService.period = "0"
        uService.seq = "0"
        uService.done = done
        uService.reason = reason
        uService.trxnDate = trxnDate
        uService.trxnTime = trxnTime
        uService.aTrxnNo = trxnNo
        uService.aDocNo = "0"
        uService.docType = docType
        uService.voidFlag = "0"
        uService.printedFlag = "0"
        uService.aTrxnDate = trxnDate
        uService.aTrxnTime = trxnTime
        uService.reference = ""
        uService.tCOMStatus = "0"
        uService.saleDate = trxnDate

        return uService
    }

    func makeTransaction() -> Transaction {
        let trxnNoString = self.trxnNo
        let trxnNo = Int64(trxnNoString) ?? 0
        let date = Date.fromTimeStamp(timeStamp: trxnNo)
        let globalInfo = GlobalInfo.shared
        let trip = globalInfo.routeControl?.trip ?? ""
        return Transaction.make(chainNo: self.chainNo, custNo: self.custNo, docType: self.docType, date: date, reference: "", trip: trip)
    }

    static func saveToXML(uServiceArray: [UService], filePath: String) {
        var dicArray = [[String: String]]()
        for uService in uServiceArray {
            let dictionary = uService.getDictionary()
            dicArray.append(dictionary)
        }
        Utils.saveToXML(dicArray: dicArray, keyArray: keyArray, rootName: "Services", branchName: "Service", filePath: filePath)
    }

    static func saveToXML(uServiceArray: [UService]) -> String {
        if uServiceArray.count == 0 {
            return ""
        }
        let nowString = Date().toDateString(format: kTightFullDateFormat) ?? ""
        let fileName = "Services\(nowString).upl"
        let filePath = CommData.getFilePathAppended(byCacheDir: fileName) ?? ""
        saveToXML(uServiceArray: uServiceArray, filePath: filePath)
        return filePath
    }

}
