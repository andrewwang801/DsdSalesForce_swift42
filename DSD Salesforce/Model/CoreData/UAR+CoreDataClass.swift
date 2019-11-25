//
//  UAR.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 9/1/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class UAR: NSManagedObject {

    static var keyArray = ["DocNo", "DocType", "VoidFlag", "PrintedFlag", "TCOMStatus", "Trip", "TrxnNo", "ChainNo", "CustNo", "TrxnDate", "TrxnTime", "SaleDate", "Reference", "TotalDue", "TotalUnalloc", "TotalCsh", "TotalChq", "InvTrxnNo", "InvAmt"]

    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
        docNo = ""
        docType = ""
        voidFlag = ""
        printedFlag = ""
        tComStatus = ""
        trip = ""
        trxnNo = ""
        chainNo = ""
        custNo = ""
        trxnDate = ""
        trxnTime = ""
        saleDate = ""
        reference = ""
        totalDue = ""
        totalUnalloc = ""
        totalCsh = ""
        totalChq = ""
        invTrxnNo = ""
        invAmt = ""
        isVisitedDelivery = false
        isVisitedPickup = false
        deliveryTrxnNo = 0
        pickupTrxnNo = 0
    }

    func updateBy(context: NSManagedObjectContext, theSource: UAR) {
        docNo = theSource.docNo
        docType = theSource.docType
        voidFlag = theSource.voidFlag
        printedFlag = theSource.printedFlag
        tComStatus = theSource.tComStatus
        trip = theSource.trip
        trxnNo = theSource.trxnNo
        chainNo = theSource.chainNo
        custNo = theSource.custNo
        trxnDate = theSource.trxnDate
        trxnTime = theSource.trxnTime
        saleDate = theSource.saleDate
        reference = theSource.reference
        totalDue = theSource.totalDue
        totalUnalloc = theSource.totalUnalloc
        totalCsh = theSource.totalCsh
        totalChq = theSource.totalChq
        invTrxnNo = theSource.invTrxnNo
        invAmt = theSource.invAmt
        isVisitedDelivery = theSource.isVisitedDelivery
        isVisitedPickup = theSource.isVisitedPickup
        deliveryTrxnNo = theSource.deliveryTrxnNo
        pickupTrxnNo = theSource.pickupTrxnNo

        deleteARPayments(context: context)

        for _uarPayment in theSource.uarPaymentSet {
            let uarPayment = _uarPayment as! UARPayment
            let newUARPayment = UARPayment(context: context, forSave: true)
            newUARPayment.updateBy(theSource: uarPayment)
            uarPaymentSet.add(newUARPayment)
        }
    }

    func getDictionary() -> [String: String] {
        var dic = [String: String]()
        dic["DocNo"] = docNo
        dic["DocType"] = docType
        dic["VoidFlag"] = voidFlag
        dic["PrintedFlag"] = printedFlag
        dic["TCOMStatus"] = tComStatus
        dic["Trip"] = trip
        dic["TrxnNo"] = trxnNo
        dic["ChainNo"] = chainNo
        dic["CustNo"] = custNo
        dic["TrxnDate"] = trxnDate
        dic["TrxnTime"] = trxnTime
        dic["SaleDate"] = saleDate
        dic["Reference"] = reference
        dic["TotalDue"] = totalDue
        dic["TotalUnalloc"] = totalUnalloc
        dic["TotalCsh"] = totalCsh
        dic["TotalChq"] = totalChq
        dic["InvTrxnNo"] = invTrxnNo
        dic["InvAmt"] = invAmt
        return dic
    }

    static func getAll(context: NSManagedObjectContext) -> [UAR] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UAR")
        let result = try? context.fetch(request) as? [UAR]

        if let result = result, let uarArray = result {
            return uarArray
        }
        return []
    }

    func deleteARPayments(context: NSManagedObjectContext) {

        for _uarPayment in uarPaymentSet {
            let uarPayment = _uarPayment as! UARPayment
            UARPayment.delete(context: context, uarPayment: uarPayment)
        }
        uarPaymentSet.removeAllObjects()
    }

    func updateInvNoForPayments(invNo: String) {
        for _payment in uarPaymentSet {
            let payment = _payment as! UARPayment
            payment.invNo = invNo
        }
        GlobalInfo.saveCache()
    }

    static func delete(context: NSManagedObjectContext, uar: UAR) {
        context.delete(uar)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

    static func make(context: NSManagedObjectContext, chainNo: String, custNo: String, docType: String, trnxDate: Date, trip: String, paymentArray: [UARPayment]) -> UAR {

        let trxnDateString = trnxDate.toDateString(format: kTightJustDateFormat) ?? ""
        let trxnTimeString = trnxDate.toDateString(format: kTightJustTimeFormat) ?? ""
        let trxnNo = "\(trnxDate.getTimestamp())"

        let uar = UAR(context: context, forSave: true)
        uar.docType = docType
        uar.voidFlag = "0"
        uar.tComStatus = "0"
        uar.trip = trip
        uar.trxnNo = trxnNo
        uar.chainNo = chainNo
        uar.custNo = custNo
        uar.trxnDate = trxnDateString
        uar.trxnTime = trxnTimeString
        uar.saleDate = trxnDateString
        uar.totalDue = "0"
        uar.totalUnalloc = "0"
        uar.totalCsh = "0"
        uar.totalChq = "0"
        uar.invTrxnNo = trxnNo

        var totalAmount: Double = 0
        var totalCash: Double = 0
        var totalCheque: Double = 0
        for payment in paymentArray {
            let paymentAmount = Utils.getXMLDivided(valueString: payment.trxnAmount)
            totalAmount += paymentAmount
            uar.uarPaymentSet.add(payment)

            let paymentType = Int(payment.paymentType) ?? 0
            if paymentType == kCollectionCash {
                totalCash += paymentAmount
            }
            else if paymentType == kCollectionCheque {
                totalCheque += paymentAmount
            }
        }

        uar.totalCsh = Utils.getXMLMultipliedString(value: totalCash)
        uar.totalChq = Utils.getXMLMultipliedString(value: totalCheque)
        uar.invAmt = Utils.getXMLMultipliedString(value: totalAmount)

        return uar
    }

    func update(context: NSManagedObjectContext, chainNo: String, custNo: String, docType: String, trnxDate: Date, trip: String, invoiceArray: [OrderCollectionInvoice], paymentType: Int) {

        let trxnDateString = trnxDate.toDateString(format: kTightJustDateFormat) ?? ""
        let trxnTimeString = trnxDate.toDateString(format: kTightJustTimeFormat) ?? ""
        let trxnNo = "\(trnxDate.getTimestamp())"

        self.docType = docType
        self.voidFlag = "0"
        self.tComStatus = "0"
        self.trip = trip
        self.trxnNo = trxnNo
        self.chainNo = chainNo
        self.custNo = custNo
        self.trxnDate = trxnDateString
        self.trxnTime = trxnTimeString
        self.saleDate = trxnDateString
        self.totalDue = "0"
        self.totalUnalloc = "0"
        self.totalCsh = "0"
        self.totalChq = "0"

        self.deleteARPayments(context: context)

        for invoice in invoiceArray {
            let uarPayment = UARPayment(context: context, forSave: true)
            uarPayment.trxnNo = self.trxnNo
            uarPayment.chainNo = self.chainNo
            uarPayment.custNo = self.custNo
            uarPayment.paymentType = "\(paymentType)"
            uarPayment.trxnDate = self.trxnDate
            uarPayment.trxnType = "PMT"
            uarPayment.trxnAmount = Utils.getXMLMultipliedString(value: invoice.trxnAmount)
            uarPayment.origTrxnNo = ""
            uarPayment.arHeader = invoice.arHeader

            if invoice.arHeader != nil {
                uarPayment.invNo = invoice.arHeader!.invNo ?? ""
            }
            else {
                uarPayment.invNo = ""
            }
            self.uarPaymentSet.add(uarPayment)
        }
    }

    func makeTransaction() -> UTransaction {
        let trxnNoString = self.trxnNo!
        let trxnNo = Int64(trxnNoString) ?? 0
        let date = Date.fromTimeStamp(timeStamp: trxnNo)
        let globalInfo = GlobalInfo.shared
        let trip = globalInfo.routeControl?.trip ?? ""
        return UTransaction.make(chainNo: self.chainNo, custNo: self.custNo, docType: self.docType, date: date, reference: "", trip: trip)
    }

    static func saveToXML(uarArray: [UAR]) -> String {

        if uarArray.count == 0 {
            return ""
        }
        let rootName = "AR"
        let branchName = "ARHeader"
        let rootElement = GDataXMLNode.element(withName: rootName)
        for uar in uarArray {
            let branchElement = GDataXMLNode.element(withName: branchName)
            let dic = uar.getDictionary()
            for key in keyArray {
                let value = dic[key]
                let leafElement = GDataXMLNode.element(withName: key, stringValue: value)
                branchElement!.addChild(leafElement!)
            }

            for _payment in uar.uarPaymentSet {
                // add payment
                let payment = _payment as! UARPayment
                let paymentBranchElement = GDataXMLNode.element(withName: "Payment")
                let paymentDic = payment.getDictionary()
                for key in UARPayment.keyArray {
                    let value = paymentDic[key]
                    let leafElement = GDataXMLNode.element(withName: key, stringValue: value)
                    paymentBranchElement!.addChild(leafElement!)
                }
                branchElement!.addChild(paymentBranchElement!)

                // add allocation
                let allocationBranchElement = GDataXMLNode.element(withName: "Allocation")
                let allocationDic = payment.getAllocationDictionary()
                for key in UARPayment.allocationKeyArray {
                    let value = allocationDic[key]
                    let leafElement = GDataXMLNode.element(withName: key, stringValue: value)
                    allocationBranchElement!.addChild(leafElement!)
                }
                branchElement!.addChild(allocationBranchElement!)
            }
            rootElement!.addChild(branchElement!)
        }
        let document = GDataXMLDocument(rootElement: rootElement)
        guard let xmlData = document!.xmlData() else {return ""}

        let nowString = Date().toDateString(format: kTightFullDateFormat) ?? ""
        let fileName = "AR\(nowString).upl"
        let filePath = CommData.getFilePathAppended(byCacheDir: fileName) ?? ""

        CommData.deleteFileIfExist(filePath)
        let fileURL = URL(fileURLWithPath: filePath)
        try? xmlData.write(to: fileURL, options: [NSData.WritingOptions.atomic])

        return filePath
    }

}

extension UAR {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UAR> {
        return NSFetchRequest<UAR>(entityName: "UAR");
    }

    @NSManaged public var docNo: String!
    @NSManaged public var docType: String!
    @NSManaged public var voidFlag: String!
    @NSManaged public var printedFlag: String!
    @NSManaged public var tComStatus: String!
    @NSManaged public var trip: String!
    @NSManaged public var trxnNo: String!
    @NSManaged public var chainNo: String!
    @NSManaged public var custNo: String!
    @NSManaged public var trxnDate: String!
    @NSManaged public var trxnTime: String!
    @NSManaged public var saleDate: String!
    @NSManaged public var reference: String!
    @NSManaged public var totalDue: String!
    @NSManaged public var totalUnalloc: String!
    @NSManaged public var totalCsh: String!
    @NSManaged public var totalChq: String!
    @NSManaged public var invTrxnNo: String!
    @NSManaged public var invAmt: String!
    @NSManaged public var isVisitedDelivery: Bool
    @NSManaged public var isVisitedPickup: Bool
    @NSManaged public var deliveryTrxnNo: Int32
    @NSManaged public var pickupTrxnNo: Int32

    @NSManaged public var uarPayments: NSOrderedSet?

    var uarPaymentSet: NSMutableOrderedSet {
        return self.mutableOrderedSetValue(forKey: "uarPayments")
    }
}
