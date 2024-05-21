//
//  UARPayment.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 9/1/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class UARPayment: NSManagedObject {

    static var keyArray = ["TrxnNo", "ChainNo", "CustNo", "PaymentType", "TrxnDate", "TrxnType", "TrxnAmount", "InvNo", "BankNo", "Account", "CheckNo", "CheckDate", "OrigTrxnNo", "SeqNo", "ReconTrxnNo", "ARNotes"]

    static var allocationKeyArray = ["TrxnNo", "ChainNo", "CustNo", "InvDate", "InvNo", "TrxnType", "TrxnAmount", "InvROAAmt", "CheckNo", "OrigTrxnNo", "BankNo", "Account", "User1", "User2"]

    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
        trxnNo = "0"
        chainNo = "0"
        custNo = "0"
        paymentType = ""
        trxnDate = ""
        trxnType = ""
        trxnAmount = ""
        invNo = "0"
        bankNo = "0"
        account = "0"
        checkNo = "0"
        checkDate = ""
        origTrxnNo = "0"
        seqNo = "0"
        reconTrxnNo = "0"
        arNotes = ""
        arHeader = nil
    }

    func updateBy(theSource: UARPayment) {
        trxnNo = theSource.trxnNo
        chainNo = theSource.chainNo
        custNo = theSource.custNo
        paymentType = theSource.paymentType
        trxnDate = theSource.trxnDate
        trxnType = theSource.trxnType
        trxnAmount = theSource.trxnAmount
        invNo = theSource.invNo
        bankNo = theSource.bankNo
        account = theSource.account
        checkNo = theSource.checkNo
        checkDate = theSource.checkDate
        origTrxnNo = theSource.origTrxnNo
        seqNo = theSource.seqNo
        reconTrxnNo = theSource.reconTrxnNo
        arNotes = theSource.arNotes
        arHeader = theSource.arHeader
    }

    func getDictionary() -> [String: String] {
        var dic = [String: String]()
        dic["TrxnNo"] = trxnNo
        dic["ChainNo"] = chainNo
        dic["CustNo"] = custNo
        dic["PaymentType"] = paymentType
        dic["TrxnDate"] = trxnDate
        dic["TrxnType"] = trxnType
        dic["TrxnAmount"] = trxnAmount
        dic["InvNo"] = invNo
        dic["BankNo"] = bankNo
        dic["Account"] = account
        dic["CheckNo"] = checkNo
        dic["CheckDate"] = checkDate
        dic["OrigTrxnNo"] = origTrxnNo
        dic["SeqNo"] = seqNo
        dic["ReconTrxnNo"] = reconTrxnNo
        dic["ARNotes"] = arNotes
        return dic
    }

    func getAllocationDictionary() -> [String: String] {

        var dic = [String: String]()
        dic["TrxnNo"] = trxnNo
        dic["ChainNo"] = chainNo
        dic["CustNo"] = custNo
        dic["InvDate"] = trxnDate
        dic["InvNo"] = invNo

        let invAmount = Double(trxnAmount) ?? 0
        if invAmount > 0 {
            dic["TrxnType"] = "INV"
        }
        else {
            dic["TrxnType"] = "PAY"
        }
        dic["TrxnAmount"] = trxnAmount
        dic["InvROAAmt"] = trxnAmount
        dic["CheckNo"] = checkNo
        dic["OrigTrxnNo"] = "0"
        dic["BankNo"] = bankNo
        dic["Account"] = account
        dic["User1"] = " "
        dic["User2"] = " "

        return dic
    }

    static func make(context: NSManagedObjectContext, chainNo: String, custNo: String, trnxDate: Date, trxnAmount: String, paymentType: Int, forSave: Bool) -> UARPayment {

        let trxnDateString = trnxDate.toDateString(format: kTightJustDateFormat) ?? ""
        let trxnNo = "\(trnxDate.getTimestamp())"

        let uarPayment = UARPayment(context: context, forSave: forSave)
        uarPayment.trxnNo = trxnNo
        uarPayment.chainNo = chainNo
        uarPayment.custNo = custNo
        uarPayment.paymentType = "\(paymentType)"
        uarPayment.trxnDate = trxnDateString
        uarPayment.trxnType = "PMT"
        uarPayment.trxnAmount = trxnAmount
        uarPayment.arHeader = nil
        uarPayment.invNo = ""
        uarPayment.checkDate = trxnDateString

        return uarPayment
    }

    static func getAll(context: NSManagedObjectContext) -> [UARPayment] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UARPayment")
        let result = try? context.fetch(request) as? [UARPayment]

        if let result = result, let uarPaymentArray = result {
            return uarPaymentArray
        }
        return []
    }

    static func delete(context: NSManagedObjectContext, uarPayment: UARPayment) {
        context.delete(uarPayment)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension UARPayment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UARPayment> {
        return NSFetchRequest<UARPayment>(entityName: "UARPayment");
    }

    @NSManaged public var trxnNo: String!
    @NSManaged public var chainNo: String!
    @NSManaged public var custNo: String!
    @NSManaged public var paymentType: String!
    @NSManaged public var trxnDate: String!
    @NSManaged public var trxnType: String!
    @NSManaged public var trxnAmount: String!
    @NSManaged public var invNo: String!
    @NSManaged public var bankNo: String!
    @NSManaged public var account: String!
    @NSManaged public var checkNo: String!
    @NSManaged public var checkDate: String!
    @NSManaged public var origTrxnNo: String!
    @NSManaged public var seqNo: String!
    @NSManaged public var reconTrxnNo: String!
    @NSManaged public var arNotes: String!
    @NSManaged public var arHeader: ARHeader?
}
