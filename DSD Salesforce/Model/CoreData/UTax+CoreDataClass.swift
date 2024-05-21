//
//  UTax.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 9/1/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class UTax: NSManagedObject {

    static var keyArray = ["TrxnNo", "TrxnType", "LocnNo", "ItemNo", "TaxRateCode", "TaxAmount", "CumulativeFlag", "TaxRate", "ReasonCode"]

    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
        trxnNo = ""
        trxnType = ""
        locnNo = ""
        itemNo = ""
        taxRateCode = ""
        taxAmount = ""
        cumulativeFlag = ""
        taxRate = ""
        reasonCode = ""
    }

    func updateBy(theSource: UTax) {
        self.trxnNo = theSource.trxnNo
        self.trxnType = theSource.trxnType
        self.locnNo = theSource.locnNo
        self.itemNo = theSource.itemNo
        self.taxRateCode = theSource.taxRateCode
        self.taxAmount = theSource.taxAmount
        self.cumulativeFlag = theSource.cumulativeFlag
        self.taxRate = theSource.taxRate
        self.reasonCode = theSource.reasonCode
    }

    func getDictionary() -> [String: String] {
        var dic = [String: String]()
        dic["TrxnNo"] = trxnNo
        dic["TrxnType"] = trxnType
        dic["LocnNo"] = locnNo
        dic["ItemNo"] = itemNo
        dic["TaxRateCode"] = taxRateCode
        dic["TaxAmount"] = taxAmount
        dic["CumulativeFlag"] = cumulativeFlag
        dic["TaxRate"] = taxRate
        dic["ReasonCode"] = reasonCode
        return dic
    }

    static func getAll(context: NSManagedObjectContext) -> [UTax] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UTax")
        let result = try? context.fetch(request) as? [UTax]

        if let result = result, let taxArray = result {
            return taxArray
        }
        return []
    }

    static func delete(context: NSManagedObjectContext, tax: UTax) {
        context.delete(tax)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension UTax {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UTax> {
        return NSFetchRequest<UTax>(entityName: "UTax");
    }

    @NSManaged public var trxnNo: String!
    @NSManaged public var trxnType: String!
    @NSManaged public var locnNo: String!
    @NSManaged public var itemNo: String!
    @NSManaged public var taxRateCode: String!
    @NSManaged public var taxAmount: String!
    @NSManaged public var cumulativeFlag: String!
    @NSManaged public var taxRate: String!
    @NSManaged public var reasonCode: String!
}
