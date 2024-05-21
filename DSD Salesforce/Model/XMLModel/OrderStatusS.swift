//
//  OrderStatusS.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 8/2/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class OrderStatusDetail: NSObject {

    var trxnNo = ""
    var chainNo = ""
    var custNo = ""
    var dayNo = ""
    var deliveryDate = ""
    var deliverySequence = ""
    var deliveryOrderNo = ""
    var orderNo = ""
    var orderBarcode = ""
    var poRef = ""
    var status = ""
    var reference = ""

    static var keyArray = ["TrxnNo", "ChainNo", "CustNo", "DayNo", "DeliveryDate", "DeliverySequence", "OrderNo", "OrderBarcode", "PORef", "Status", "Reference"]

    func getDictionary() -> [String: String] {
        var dic = [String: String]()
        dic["TrxnNo"] = trxnNo
        dic["ChainNo"] = chainNo
        dic["CustNo"] = custNo
        dic["DayNo"] = dayNo
        dic["DeliveryDate"] = deliveryDate
        dic["DeliverySequence"] = deliverySequence
        dic["OrderNo"] = orderNo
        dic["OrderBarcode"] = orderBarcode
        dic["PORef"] = poRef
        dic["Status"] = status
        dic["Reference"] = reference
        return dic
    }
}

class OrderStatusS: NSObject {

    var trxnNo = ""
    var docNo = ""
    var docType = ""
    var voidFlag = ""
    var printedFlag = ""
    var reference = ""
    var tCOMStatus = ""
    var trxnDate = ""
    var trxnTime = ""
    var routeNumber = ""
    var tripNumber = ""
    var orderStatusDetailArray = [OrderStatusDetail]()

    static var keyArray = ["TrxnNo", "DocNo", "DocType", "VoidFlag", "PrintedFlag", "Reference", "TCOMStatus", "TrxnDate", "TrxnTime", "RouteNumber", "TripNumber"]

    func getDictionary() -> [String: String] {
        var dic = [String: String]()
        dic["TrxnNo"] = trxnNo
        dic["DocNo"] = docNo
        dic["DocType"] = docType
        dic["VoidFlag"] = voidFlag
        dic["PrintedFlag"] = printedFlag
        dic["Reference"] = reference
        dic["TCOMStatus"] = tCOMStatus
        dic["TrxnDate"] = trxnDate
        dic["TrxnTime"] = trxnTime
        dic["RouteNumber"] = routeNumber
        dic["TripNumber"] = tripNumber
        return dic
    }

    static func make(customerDetails: CustomerDetail, date: Date, docType: String, reference: String, status: String) -> OrderStatusS {

        let globalInfo = GlobalInfo.shared
        let trxnDate = date.toDateString(format: kTightJustDateFormat) ?? ""
        let trxnTime = date.toDateString(format: kTightJustTimeFormat) ?? ""
        let trxnNo = "\(date.getTimestamp())"

        let orderStatus = OrderStatusS()
        orderStatus.trxnNo = trxnNo
        orderStatus.docNo = ""
        orderStatus.docType = docType
        orderStatus.trxnDate = trxnDate
        orderStatus.trxnTime = trxnTime
        orderStatus.routeNumber = globalInfo.routeControl?.routeNumber ?? "0"
        orderStatus.tripNumber = globalInfo.routeControl?.trip ?? "0"

        let orderStatusDetail = OrderStatusDetail()
        orderStatusDetail.chainNo = customerDetails.chainNo ?? "0"
        orderStatusDetail.custNo = customerDetails.custNo ?? "0"

        orderStatusDetail.dayNo = customerDetails.dayNo ?? "0"
        orderStatusDetail.status = status
        orderStatusDetail.reference = reference
        orderStatusDetail.deliveryDate = customerDetails.deliveryDate ?? ""
        orderStatusDetail.trxnNo = trxnNo

        let presoldOrHeaders = PresoldOrHeader.getBy(context: globalInfo.managedObjectContext, chainNo: customerDetails.chainNo ?? "", custNo: customerDetails.custNo ?? "", periodNo: customerDetails.periodNo ?? "", deliverySequence: customerDetails.seqNo ?? "")
        if presoldOrHeaders.count > 0 {
            orderStatusDetail.orderNo = presoldOrHeaders[0].orderNo ?? ""
            orderStatusDetail.deliverySequence = presoldOrHeaders[0].deliverySequence ?? ""
            orderStatusDetail.orderBarcode = presoldOrHeaders[0].orderBarcode ?? ""
            orderStatusDetail.poRef = presoldOrHeaders[0].poRef ?? ""
        }
        orderStatus.orderStatusDetailArray.append(orderStatusDetail)

        return orderStatus
    }

    func makeTransaction() -> UTransaction {
        let trxnNoString = self.trxnNo
        let trxnNo = Int64(trxnNoString) ?? 0
        let date = Date.fromTimeStamp(timeStamp: trxnNo)
        let globalInfo = GlobalInfo.shared
        let trip = globalInfo.routeControl?.trip ?? ""
        let chainNo = self.orderStatusDetailArray.first?.chainNo ?? ""
        let custNo = self.orderStatusDetailArray.first?.custNo ?? ""
        return UTransaction.make(chainNo: chainNo, custNo: custNo, docType: self.docType, date: date, reference: "", trip: trip)
    }

    static func saveToXML(orderStatusArray: [OrderStatusS]) -> String {

        if orderStatusArray.count == 0 {
            return ""
        }

        let rootName = "OrderStatusS"
        let branchName = "OrderStatus"
        let rootElement = GDataXMLNode.element(withName: rootName)
        for orderStatus in orderStatusArray {
            let branchElement = GDataXMLNode.element(withName: branchName)
            let dic = orderStatus.getDictionary()
            for key in keyArray {
                let value = dic[key]
                let leafElement = GDataXMLNode.element(withName: key, stringValue: value)
                branchElement!.addChild(leafElement!)
            }
            let detailBranchName = "Detail"
            for orderStatusDetail in orderStatus.orderStatusDetailArray {
                let detailBranchElement = GDataXMLNode.element(withName: detailBranchName)
                let detailDic = orderStatusDetail.getDictionary()
                for key in OrderStatusDetail.keyArray {
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
        let fileName = "OrderStatus\(nowString).upl"
        let filePath = CommData.getFilePathAppended(byCacheDir: fileName) ?? ""

        CommData.deleteFileIfExist(filePath)
        let fileURL = URL(fileURLWithPath: filePath)
        try? xmlData.write(to: fileURL, options: [NSData.WritingOptions.atomic])

        return filePath
    }

}
