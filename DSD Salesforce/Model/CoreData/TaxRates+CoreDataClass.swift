//
//  ProMulti+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class TaxRates: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
        cumulativeFlag = ""
    }

    static func getByForToday(context: NSManagedObjectContext, custTaxCode: String, itemNo: String) -> TaxRates? {

        let prodLocn = ProductLocn.getBy(context: context, itemNo: itemNo).first
        if prodLocn == nil {
            return TaxRates(context: context, forSave: false)
        }
        let itemTaxCode = prodLocn!.itemTaxCode ?? ""
        if itemTaxCode.isEmpty == true {
            return TaxRates(context: context, forSave: false)
        }
        let taxCodes = TaxCodes.getBy(context: context, custTaxCode: custTaxCode, itemTaxCode: itemTaxCode)
        let taxRateCode = taxCodes?.taxRateCode ?? ""

        let now = Date()
        let nowString = now.toDateString(format: kTightJustDateFormat) ?? ""
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TaxRates")
        let predicate1 = NSPredicate(format: "taxRateCode=%@", taxRateCode)
        let predicate2 = NSPredicate(format: "startDate<=%@", nowString)
        let predicate3 = NSPredicate(format: "endDate>=%@", nowString)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2, predicate3])

        let result = try? context.fetch(request) as? [TaxRates]

        if let result = result, let taxRatesArray = result {
            return taxRatesArray.first
        }
        return nil
    }

    static func getUTaxByForToday(context: NSManagedObjectContext, custTaxCode: String, itemNo: String) -> UTax? {

        let prodLocn = ProductLocn.getBy(context: context, itemNo: itemNo).first
        if prodLocn == nil {
            return nil
        }
        let itemTaxCode = prodLocn!.itemTaxCode ?? ""
        if itemTaxCode.isEmpty == true {
            return nil
        }

        let taxCodes = TaxCodes.getBy(context: context, custTaxCode: custTaxCode, itemTaxCode: itemTaxCode)
        let taxRateCode = taxCodes?.taxRateCode ?? ""

        let now = Date()
        let nowString = now.toDateString(format: kTightJustDateFormat) ?? ""
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TaxRates")
        let predicate1 = NSPredicate(format: "taxRateCode=%@", taxRateCode)
        let predicate2 = NSPredicate(format: "startDate<=%@", nowString)
        let predicate3 = NSPredicate(format: "endDate>=%@", nowString)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2, predicate3])

        let result = try? context.fetch(request) as? [TaxRates]

        if let result = result, let taxRatesArray = result {
            let firstTaxRates = taxRatesArray.first
            if firstTaxRates == nil {
                return nil
            }
            let tax = UTax(context: context, forSave: true)
            tax.trxnNo = ""
            tax.trxnType = ""
            tax.locnNo = prodLocn!.locnNo ?? ""
            tax.itemNo = itemNo
            tax.taxRateCode = taxRateCode
            tax.taxAmount = ""
            tax.cumulativeFlag = taxCodes?.cumulativeFlag ?? ""
            tax.taxRate = firstTaxRates!.taxRate ?? ""
            tax.reasonCode = ""
            return tax
        }
        return nil
    }

    static func getAll(context: NSManagedObjectContext) -> [TaxRates] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TaxRates")
        let result = try? context.fetch(request) as? [TaxRates]

        if let result = result, let taxRatesArray = result {
            return taxRatesArray
        }
        return []
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.taxRateCode = xmlDictionary["TaxRateCode"] ?? ""
        self.startDate = xmlDictionary["StartDate"] ?? ""
        self.endDate = xmlDictionary["EndDate"] ?? ""
        self.taxRate = xmlDictionary["TaxRate"] ?? "0"
        self.rateDesc = xmlDictionary["RateDescription"] ?? ""
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [TaxRates] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "TAXRATES", xPath: "//TaxRates/Records/TaxRates")
        var taxRatesArray = [TaxRates]()
        for dic in dicArray {
            let taxRates = TaxRates(context: context, forSave: forSave)
            taxRates.updateBy(xmlDictionary: dic)
            taxRatesArray.append(taxRates)
        }
        return taxRatesArray
    }

    static func delete(context: NSManagedObjectContext, taxRates: TaxRates) {
        context.delete(taxRates)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension TaxRates {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaxRates> {
        return NSFetchRequest<TaxRates>(entityName: "TaxRates");
    }

    @NSManaged public var taxRateCode: String?
    @NSManaged public var startDate: String?
    @NSManaged public var endDate: String?
    @NSManaged public var taxRate: String?
    @NSManaged public var rateDesc: String?
    @NSManaged public var cumulativeFlag: String?
}


