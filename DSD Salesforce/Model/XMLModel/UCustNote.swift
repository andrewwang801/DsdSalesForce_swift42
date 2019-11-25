//
//  UCustNote.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/31/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class UCustNoteAttachment: NSObject {

    var trxnNo = ""
    var fileName = ""

    static var keyArray = ["TrxnNo", "FileName"]

    func getDictionary() -> [String: String] {
        var dic = [String: String]()
        dic["TrxnNo"] = trxnNo
        dic["FileName"] = fileName
        return dic
    }

}

class UCustNote: NSObject {

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
    var period = ""
    var trip = ""
    var transactionType = ""
    var user = ""
    var noteType = ""
    var message = ""
    var attachmentArray = [UCustNoteAttachment]()

    static var keyArray = ["TrxnNo", "DocNo", "DocType", "VoidFlag", "PrintedFlag", "TrxnDate", "TrxnTime", "Reference", "TCOMStatus", "ChainNo", "CustNo",   "SaleDate", "PhysAvail", "VirtAvail", "Period", "Trip", "TransactionType", "User", "NoteType", "Message"]

    func updateBy(theSource: UCustNote) {
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
        self.period = theSource.period
        self.trip = theSource.trip
        self.transactionType = theSource.transactionType
        self.user = theSource.user
        self.noteType = theSource.noteType
        self.message = theSource.message

        self.attachmentArray.removeAll()
        self.attachmentArray.append(contentsOf: theSource.attachmentArray)
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
        dic["Period"] = period
        dic["Trip"] = trip
        dic["TransactionType"] = transactionType
        dic["User"] = user
        dic["NoteType"] = noteType
        dic["Message"] = message
        return dic
    }

    static func make(chainNo: String, custNo: String, docType: String, date: Date, noteType: String, note: String, attachmentString: String) -> UCustNote {

        let trxnDate = date.toDateString(format: kTightJustDateFormat) ?? ""
        let trxnTime = date.toDateString(format: kTightJustTimeFormat) ?? ""
        let trxnNo = "\(date.getTimestamp())"

        let uCustNote = UCustNote()
        uCustNote.trxnNo = trxnNo
        uCustNote.docNo = "0"
        uCustNote.docType = docType
        uCustNote.chainNo = chainNo
        uCustNote.custNo = custNo
        uCustNote.trxnDate = trxnDate
        uCustNote.trxnTime = trxnTime
        uCustNote.voidFlag = "0"
        uCustNote.printedFlag = "0"
        uCustNote.reference = ""
        uCustNote.tCOMStatus = "0"
        uCustNote.saleDate = trxnDate
        uCustNote.physAvail = "0"
        uCustNote.virtAvail = "0"
        uCustNote.period = "0"
        uCustNote.trip = GlobalInfo.shared.routeControl?.trip ?? ""
        uCustNote.transactionType = "A"
        uCustNote.user = GlobalInfo.shared.routeControl?.userName ?? ""
        uCustNote.noteType = noteType
        uCustNote.message = note

        var attachmentArray = [String]()
        if attachmentString != "" {
            attachmentArray = attachmentString.components(separatedBy: ",")
        }
        for attachment in attachmentArray {
            let noteAttachment = UCustNoteAttachment()
            noteAttachment.trxnNo = trxnNo
            noteAttachment.fileName = attachment
            uCustNote.attachmentArray.append(noteAttachment)
        }
        return uCustNote
    }

    func makeTransaction() -> UTransaction {
        let trxnNoString = self.trxnNo
        let trxnNo = Int64(trxnNoString) ?? 0
        let date = Date.fromTimeStamp(timeStamp: trxnNo)
        let globalInfo = GlobalInfo.shared
        let trip = globalInfo.routeControl?.trip ?? ""
        return UTransaction.make(chainNo: self.chainNo, custNo: self.custNo, docType: self.docType, date: date, reference: "", trip: trip)
    }

    static func saveToXML(uCustNoteArray: [UCustNote]) -> String {

        if uCustNoteArray.count == 0 {
            return ""
        }

        let rootName = "CustNotes"
        let branchName = "CustNote"
        let rootElement = GDataXMLNode.element(withName: rootName)
        for uCustNote in uCustNoteArray {
            let branchElement = GDataXMLNode.element(withName: branchName)
            let dic = uCustNote.getDictionary()
            for key in keyArray {
                let value = dic[key]
                let leafElement = GDataXMLNode.element(withName: key, stringValue: value)
                branchElement!.addChild(leafElement!)
            }
            let detailBranchName = "Attachment"
            for noteAttachment in uCustNote.attachmentArray {
                let detailBranchElement = GDataXMLNode.element(withName: detailBranchName)
                let detailDic = noteAttachment.getDictionary()
                for key in UCustNoteAttachment.keyArray {
                    let value = detailDic[key]
                    let leafElement = GDataXMLNode.element(withName: key, stringValue: value)
                    detailBranchElement!.addChild(leafElement!)
                }
                branchElement!.addChild(detailBranchElement!)
            }
            rootElement!.addChild(branchElement!)
        }
        let document = GDataXMLDocument(rootElement: rootElement)
        guard let xmlData = document!.xmlData() else {return ""}

        let nowString = Date().toDateString(format: kTightFullDateFormat) ?? ""
        let fileName = "CustNote\(nowString).upl"
        let filePath = CommData.getFilePathAppended(byCacheDir: fileName) ?? ""

        CommData.deleteFileIfExist(filePath)
        let fileURL = URL(fileURLWithPath: filePath)
        try? xmlData.write(to: fileURL, options: [NSData.WritingOptions.atomic])

        return filePath
    }

}
