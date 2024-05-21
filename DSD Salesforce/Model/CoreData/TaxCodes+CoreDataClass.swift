//
//  TaxCodes+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class TaxCodes: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
    }
    
    static func getBy(context: NSManagedObjectContext, custTaxCode: String, itemTaxCode: String) -> TaxCodes? {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TaxCodes")
        let predicate1 = NSPredicate(format: "custTaxCode=%@", custTaxCode)
        let predicate2 = NSPredicate(format: "itemTaxCode=%@", itemTaxCode)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])

        let result = try? context.fetch(request) as? [TaxCodes]

        if let result = result, let taxCodesArray = result {
            return taxCodesArray.first
        }
        return nil
    }

    static func getAll(context: NSManagedObjectContext) -> [TaxCodes] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TaxCodes")
        let result = try? context.fetch(request) as? [TaxCodes]

        if let result = result, let taxCodesArray = result {
            return taxCodesArray
        }
        return []
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.custTaxCode = xmlDictionary["CustTaxCode"] ?? ""
        self.itemTaxCode = xmlDictionary["ItemTaxCode"] ?? ""
        self.taxRateCode = xmlDictionary["TaxRateCode"] ?? ""
        self.cumulativeFlag = xmlDictionary["CumulativeFlag"] ?? ""
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [TaxCodes] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "TAXCODES", xPath: "//TaxCodes/Records/TaxCodes")
        var taxCodesArray = [TaxCodes]()
        for dic in dicArray {
            let taxCodes = TaxCodes(context: context, forSave: forSave)
            taxCodes.updateBy(xmlDictionary: dic)
            taxCodesArray.append(taxCodes)
        }
        return taxCodesArray
    }

    static func delete(context: NSManagedObjectContext, taxCodes: TaxCodes) {
        context.delete(taxCodes)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension TaxCodes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaxCodes> {
        return NSFetchRequest<TaxCodes>(entityName: "TaxCodes");
    }

    @NSManaged public var custTaxCode: String?
    @NSManaged public var itemTaxCode: String?
    @NSManaged public var taxRateCode: String?
    @NSManaged public var cumulativeFlag: String?
}

