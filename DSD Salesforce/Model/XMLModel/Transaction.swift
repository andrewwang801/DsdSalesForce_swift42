//
//  UTransaction.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/31/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class UTransaction: NSObject {

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

    static var keyArray = ["TrxnNo", "DocNo", "DocType", "VoidFlag", "PrintedFlag", "TrxnDate", "TrxnTime", "Reference", "TCOMStatus", "ChainNo", "CustNo", "SaleDate", "PhysAvail", "VirtAvail", "Trip"]

    func updateBy(theSource: UTransaction) {
        self.trxnNo = theSource.trxnNo
        self.docNo = theSource.docNo
        self.docType = theSource.docType
        self.voidFlag = theSource.voidFlag
        self.printedFlag = theSource.printedFlag
        self.trxnDate = theSource.trxnDate
        self.trxnTime = theSource.trxnTime
        self.reference = theSource.reference
        self.tCOMStatus = theSource.tCOMStatus
        self.chainNo = theSource.chainNo
        self.custNo = theSource.custNo
        self.saleDate = theSource.saleDate
        self.physAvail = theSource.physAvail
        self.virtAvail = theSource.virtAvail
        self.trip = theSource.trip
    }

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
        return dic
    }

    static func make(chainNo: String, custNo: String, docType: String, date: Date, reference: String, trip: String) -> UTransaction {

        let trxnDate = date.toDateString(format: kTightJustDateFormat) ?? ""
        let trxnTime = date.toDateString(format: kTightJustTimeFormat) ?? ""
        let trxnNo = "\(date.getTimestamp())"

        let transaction = UTransaction()
        transaction.trxnNo = trxnNo
        transaction.docNo = ""
        transaction.docType = docType
        transaction.voidFlag = "0"
        transaction.printedFlag = "0"
        transaction.trxnDate = trxnDate
        transaction.trxnTime = trxnTime
        transaction.reference = reference
        transaction.tCOMStatus = "0"
        transaction.chainNo = chainNo
        transaction.custNo = custNo
        transaction.saleDate = trxnDate
        transaction.physAvail = "0"
        transaction.virtAvail = "0"
        transaction.trip = trip
        return transaction
    }

    static func saveToXML(transactionArray: [UTransaction], filePath: String) {
        var dicArray = [[String: String]]()
        for transaction in transactionArray {
            let dictionary = transaction.getDictionary()
            dicArray.append(dictionary)
        }
        Utils.saveToXML(dicArray: dicArray, keyArray: keyArray, rootName: "Transactions", branchName: "Transaction", filePath: filePath)
    }

    static func saveToXML(transaction: UTransaction, filePath: String) {
        let logTransaction = UTransaction()
        logTransaction.updateBy(theSource: transaction)
        logTransaction.docType = "LOG"
        saveToXML(transactionArray: [transaction, logTransaction], filePath: filePath)
    }

    static func saveToXML(transactionArray: [UTransaction], shouldIncludeLog: Bool) -> String {
        if transactionArray.count == 0 {
            return ""
        }
        let nowString = Date().toDateString(format: kTightFullDateFormat) ?? ""
        let fileName = "Transactions\(nowString).upl"
        let filePath = CommData.getFilePathAppended(byCacheDir: fileName) ?? ""

        var newTransactionArray = transactionArray
        if shouldIncludeLog == true {
            let logTransaction = UTransaction()
            logTransaction.updateBy(theSource: newTransactionArray.last!)
            logTransaction.docType = "LOG"
            newTransactionArray.append(logTransaction)
        }

        saveToXML(transactionArray: newTransactionArray, filePath: filePath)
        return filePath
    }
    
}
