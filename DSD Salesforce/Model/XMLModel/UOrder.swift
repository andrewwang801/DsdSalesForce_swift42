//
//  UOrder.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 9/9/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class UOrder: NSObject {

    var docNo = ""
    var docType = ""
    var voidFlag = ""
    var printedFlag = ""
    var trxnDate = ""
    var trxnTime = ""
    var reference = ""
    var tCOMStatus = ""
    var saleDate = ""
    var trxnNo = ""
    var chainNo = ""
    var custNo = ""
    var orderNo = ""
    var dayNo = ""
    var completedDate = ""
    var completedTime = ""
    var totalAmount = ""
    var totalDumps = ""
    var totalBuyBack = ""
    var totalSales = ""
    var dTotalAmount = ""
    var dTotalDumps = ""
    var dTotalBuyBack = ""
    var dTotalSales = ""
    var previousBal = ""
    var saleAmount = ""
    var promotionAmount = ""
    var taxAmount = ""
    var centsRounding = ""
    var invoiceTotal = ""
    var discDumps = ""
    var discBuybacks = ""
    var discSales = ""
    var netDumps = ""
    var netBuybacks = ""
    var netSales = ""
    var taxableAmount = ""
    var changeFlag = ""
    var deliveryDate = ""
    var period = ""
    var driverNumber = ""
    var detailFile = ""
    var offInvPromoAmt = ""
    var user1 = ""
    var user2 = ""
    var poRef = ""
    var credRef = ""
    var instrs = ""
    var dsd = ""
    var arBeforeTrxnNo = ""
    var distr = ""
    var splitNett = ""
    var totalSamples = ""
    var totalFree = ""
    var distrName = ""
    var totalExchangeDU = ""
    var discExchangeDU = ""
    var netExchangeDU = ""
    var dexStatus = ""
    var sourceType = ""
    var presoldChgd = ""
    var reversed = ""
    var discInLieuAmt = ""
    var pallTrxnNo = ""
    var ticketType = ""
    var orderContact = ""

    var uOrderDetailArray = [UOrderDetail]()

    static var keyArray = ["DocNo", "DocType", "VoidFlag", "PrintedFlag", "TrxnDate", "TrxnTime", "Reference", "TCOMStatus", "SaleDate", "TrxnNo", "ChainNo", "CustNo", "OrderNo", "DayNo", "CompletedDate", "CompletedTime", "TotalAmount", "TotalDumps", "TotalBuyBack", "TotalSales", "DTotalAmount", "DTotalDumps", "DTotalBuyBack", "DTotalSales", "PreviousBal", "SaleAmount", "PromotionAmount", "TaxAmount", "CentsRounding", "InvoiceTotal", "DiscDumps", "DiscBuybacks", "DiscSales", "NetDumps", "NetBuybacks", "NetSales", "TaxableAmount", "ChangeFlag", "DeliveryDate", "Period", "DriverNumber", "DetailFile", "OffInvPromoAmt", "User1", "User2", "PORef", "CredRef", "Instrs", "DSD", "ARBeforeTrxnNo", "Distr", "SplitNett", "TotalSamples", "TotalFree", "DistrName", "TotalExchangeDU", "DiscExchangeDU", "NetExchangeDU", "DexStatus", "SourceType", "PresoldChgd", "Reversed", "DiscInLieuAmt", "PALLTrxnNo", "TicketType", "OrderContact"]

    func getDictionary() -> [String: String] {
        var dic = [String: String]()
        dic["DocNo"] = docNo
        dic["DocType"] = docType
        dic["VoidFlag"] = voidFlag
        dic["PrintedFlag"] = printedFlag
        dic["TrxnDate"] = trxnDate
        dic["TrxnTime"] = trxnTime
        dic["Reference"] = reference
        dic["TCOMStatus"] = tCOMStatus
        dic["SaleDate"] = saleDate
        dic["TrxnNo"] = trxnNo

        dic["ChainNo"] = chainNo
        dic["CustNo"] = custNo
        dic["OrderNo"] = orderNo
        dic["DayNo"] = dayNo
        dic["CompletedDate"] = completedDate
        dic["CompletedTime"] = completedTime
        dic["TotalAmount"] = totalAmount
        dic["TotalDumps"] = totalDumps
        dic["TotalBuyBack"] = totalBuyBack
        dic["TotalSales"] = totalSales

        dic["DTotalAmount"] = dTotalAmount
        dic["DTotalDumps"] = dTotalDumps
        dic["DTotalBuyBack"] = dTotalBuyBack
        dic["DTotalSales"] = dTotalSales
        dic["PreviousBal"] = previousBal
        dic["SaleAmount"] = saleAmount
        dic["PromotionAmount"] = promotionAmount
        dic["TaxAmount"] = taxAmount
        dic["CentsRounding"] = centsRounding
        dic["InvoiceTotal"] = invoiceTotal

        dic["DiscDumps"] = discDumps
        dic["DiscBuybacks"] = discBuybacks
        dic["DiscSales"] = discSales
        dic["NetDumps"] = netDumps
        dic["NetBuybacks"] = netBuybacks
        dic["NetSales"] = netSales
        dic["TaxableAmount"] = taxableAmount
        dic["ChangeFlag"] = changeFlag
        dic["DeliveryDate"] = deliveryDate
        dic["Period"] = period

        dic["DriverNumber"] = driverNumber
        dic["DetailFile"] = detailFile
        dic["OffInvPromoAmt"] = offInvPromoAmt
        dic["User1"] = user1
        dic["User2"] = user2
        dic["PORef"] = poRef
        dic["CredRef"] = credRef
        dic["Instrs"] = instrs
        dic["DSD"] = dsd
        dic["ARBeforeTrxnNo"] = arBeforeTrxnNo
        dic["Distr"] = distr

        dic["SplitNett"] = splitNett
        dic["TotalSamples"] = totalSamples
        dic["TotalFree"] = totalFree
        dic["DistrName"] = distrName
        dic["TotalExchangeDU"] = totalExchangeDU
        dic["DiscExchangeDU"] = discExchangeDU
        dic["NetExchangeDU"] = netExchangeDU
        dic["DexStatus"] = dexStatus
        dic["SourceType"] = sourceType
        dic["PresoldChgd"] = presoldChgd

        dic["Reversed"] = reversed
        dic["DiscInLieuAmt"] = discInLieuAmt
        dic["PALLTrxnNo"] = pallTrxnNo
        dic["TicketType"] = ticketType
        dic["OrderContact"] = orderContact

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

    static func saveToXML(orderArray: [UOrder]) -> String {

        if orderArray.count == 0 {
            return ""
        }
        let rootName = "Orders"
        let branchName = "Order"
        let rootElement = GDataXMLNode.element(withName: rootName)
        for order in orderArray {
            let branchElement = GDataXMLNode.element(withName: branchName)
            let dic = order.getDictionary()
            for key in keyArray {
                let value = dic[key]
                let leafElement = GDataXMLNode.element(withName: key, stringValue: value)
                branchElement!.addChild(leafElement!)
            }
            // detail
            let detailBranchName = "Detail"
            for uOrderDetail in order.uOrderDetailArray {
                let detailBranchElement = GDataXMLNode.element(withName: detailBranchName)
                let detailDic = uOrderDetail.getDictionary()
                for key in UOrderDetail.keyArray {
                    let value = detailDic[key]
                    let leafElement = GDataXMLNode.element(withName: key, stringValue: value)
                    detailBranchElement!.addChild(leafElement!)
                }
                branchElement!.addChild(detailBranchElement!)

                // promotion
                var innerBranchName = "Promotion"
                for uPromotion in uOrderDetail.promotionArray {
                    let innerBranchElement = GDataXMLNode.element(withName: innerBranchName)
                    let innerDic = uPromotion.getDictionary()
                    for key in UPromotion.keyArray {
                        let value = innerDic[key]
                        let leafElement = GDataXMLNode.element(withName: key, stringValue: value)
                        innerBranchElement!.addChild(leafElement!)
                    }
                    branchElement!.addChild(innerBranchElement)
                }

                // tax
                innerBranchName = "Tax"
                for uTax in uOrderDetail.taxArray {
                    let innerBranchElement = GDataXMLNode.element(withName: innerBranchName)
                    let innerDic = uTax.getDictionary()
                    for key in UTax.keyArray {
                        let value = innerDic[key]
                        let leafElement = GDataXMLNode.element(withName: key, stringValue: value)
                        innerBranchElement!.addChild(leafElement!)
                    }
                    branchElement!.addChild(innerBranchElement)
                }
            }
            rootElement!.addChild(branchElement!)
        }

        let document = GDataXMLDocument(rootElement: rootElement)
        guard let xmlData = document!.xmlData() else {return ""}

        let nowString = Date().toDateString(format: kTightFullDateFormat) ?? ""
        let fileName = "Orders\(nowString).upl"
        let filePath = CommData.getFilePathAppended(byCacheDir: fileName) ?? ""

        CommData.deleteFileIfExist(filePath)
        let fileURL = URL(fileURLWithPath: filePath)
        try? xmlData.write(to: fileURL, options: [NSData.WritingOptions.atomic])

        return filePath
    }

}
