//
//  ShelfAudit.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 8/2/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class ShelfAuditDetail: NSObject {

    var trxnNo = ""
    var trxnType = ""
    var itemNo = ""
    var facings = ""
    var shelfPrice = ""
    var promo = ""
    var promoPrice = ""
    var promoType = ""
    var stockCount = ""
    var oos = ""
    var delisted = ""
    var marketing = ""
    var other = ""
    var aisle = ""
    var expiry = ""

    static var keyArray = ["TrxnNo", "TrxnType", "ItemNo", "Facings", "ShelfPrice", "Promo", "PromoPrice", "PromoType", "StockCount", "OOS", "Delisted", "Marketing", "Other", "Aisle", "Expiry"]

    func getDictionary() -> [String: String] {
        var dic = [String: String]()
        dic["TrxnNo"] = trxnNo
        dic["TrxnType"] = trxnType
        dic["ItemNo"] = itemNo
        dic["Facings"] = facings
        dic["ShelfPrice"] = shelfPrice
        dic["Promo"] = promo
        dic["PromoPrice"] = promoPrice
        dic["PromoType"] = promoType
        dic["StockCount"] = stockCount
        dic["OOS"] = oos
        dic["Delisted"] = delisted
        dic["Marketing"] = marketing
        dic["Other"] = other
        dic["Aisle"] = aisle
        dic["Expiry"] = expiry
        return dic
    }
}

class ShelfAudit: NSObject {

    var trxnNo = ""
    var chainNo = ""
    var custNo = ""
    var filterDesc = ""
    var docNo = ""
    var docType = ""
    var voidFlag = ""
    var printedFlag = ""
    var trxnDate = ""
    var trxnTime = ""
    var reference = ""
    var tCOMStatus = ""
    var saleDate = ""

    var auditDetailArray = [ShelfAuditDetail]()

    static var keyArray = ["TrxnNo", "ChainNo", "CustNo", "FilterDesc", "DocNo", "DocType", "VoidFlag", "PrintedFlag", "TrxnDate", "TrxnTime", "Reference", "TCOMStatus", "SaleDate"]

    static func make(chainNo: String, custNo: String, docType: String, date: Date, reference: String, shelfStatusArray: [ShelfStatus]) -> ShelfAudit {

        let trxnDate = date.toDateString(format: kTightJustDateFormat) ?? ""
        let trxnTime = date.toDateString(format: kTightJustTimeFormat) ?? ""
        let trxnNo = "\(date.getTimestamp())"

        let shelfAudit = ShelfAudit()
        shelfAudit.trxnNo = trxnNo
        shelfAudit.chainNo = chainNo
        shelfAudit.custNo = custNo
        shelfAudit.filterDesc = ""
        shelfAudit.docNo = "0"
        shelfAudit.docType = docType
        shelfAudit.voidFlag = "0"
        shelfAudit.printedFlag = "0"
        shelfAudit.trxnDate = trxnDate
        shelfAudit.trxnTime = trxnTime
        shelfAudit.reference = reference
        shelfAudit.tCOMStatus = "0"
        shelfAudit.saleDate = trxnDate

        for shelfStatus in shelfStatusArray {
            let auditDetail = ShelfAuditDetail()
            auditDetail.trxnNo = trxnNo
            auditDetail.trxnType = shelfStatus.trxnType ?? ""
            auditDetail.itemNo = shelfStatus.itemNo ?? ""
            auditDetail.facings = shelfStatus.facings ?? ""
            auditDetail.shelfPrice = shelfStatus.shelfPrice ?? ""
            auditDetail.promo = shelfStatus.promo ?? ""
            auditDetail.promoPrice = shelfStatus.promoPrice ?? ""
            auditDetail.promoType = shelfStatus.promoType ?? ""
            auditDetail.stockCount = shelfStatus.stockCount ?? ""
            auditDetail.oos = shelfStatus.oos ?? ""
            auditDetail.delisted = shelfStatus.delisted ?? ""
            auditDetail.marketing = shelfStatus.marketingNotes ?? ""
            auditDetail.other = shelfStatus.otherNotes ?? ""
            auditDetail.aisle = shelfStatus.aisle ?? ""
            auditDetail.expiry = shelfStatus.expiry ?? ""
            shelfAudit.auditDetailArray.append(auditDetail)
        }

        return shelfAudit
    }

    func getDictionary() -> [String: String] {
        var dic = [String: String]()
        dic["TrxnNo"] = trxnNo
        dic["ChainNo"] = chainNo
        dic["CustNo"] = custNo
        dic["FilterDesc"] = filterDesc
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

    static func saveToXML(auditArray: [ShelfAudit], filePath: String) {

        let rootName = "ShelfAudits"
        let branchName = "ShelfAudit"
        let rootElement = GDataXMLNode.element(withName: rootName)
        for audit in auditArray {
            let branchElement = GDataXMLNode.element(withName: branchName)
            let dic = audit.getDictionary()
            for key in keyArray {
                let value = dic[key]
                let leafElement = GDataXMLNode.element(withName: key, stringValue: value)
                branchElement!.addChild(leafElement!)
            }
            let detailBranchName = "Detail"
            for auditDetail in audit.auditDetailArray {
                let detailBranchElement = GDataXMLNode.element(withName: detailBranchName)
                let detailDic = auditDetail.getDictionary()
                for key in ShelfAuditDetail.keyArray {
                    let value = detailDic[key]
                    let leafElement = GDataXMLNode.element(withName: key, stringValue: value)
                    detailBranchElement!.addChild(leafElement!)
                }
                branchElement!.addChild(detailBranchElement!)
            }
            rootElement!.addChild(branchElement!)
        }
        let document = GDataXMLDocument(rootElement: rootElement)
        guard let xmlData = document!.xmlData() else {return}

        CommData.deleteFileIfExist(filePath)
        let fileURL = URL(fileURLWithPath: filePath)
        try? xmlData.write(to: fileURL, options: [NSData.WritingOptions.atomic])
    }

}
