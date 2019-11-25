//
//  Pricing+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class Pricing: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
    }

    static func getBy(context: NSManagedObjectContext, chainNo: String, custNo: String) -> [Pricing] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Pricing")
        let predicate1 = NSPredicate(format: "chainNo=%@", chainNo)
        let predicate2 = NSPredicate(format: "custNo=%@", custNo)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])

        let result = try? context.fetch(request) as? [Pricing]

        if let result = result, let pricings = result {
            return pricings
        }
        return []
    }

    static func getByForToday(context: NSManagedObjectContext, chainNo: String, custNo: String, itemNo: String) -> Pricing? {

        let now = Date()
        let nowString = now.toDateString(format: kTightJustDateFormat) ?? ""
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Pricing")
        let predicate1 = NSPredicate(format: "chainNo=%@", chainNo)
        let predicate2 = NSPredicate(format: "custNo=%@", custNo)
        let predicate3 = NSPredicate(format: "dateStart<=%@", nowString)
        let predicate4 = NSPredicate(format: "dateEnd>=%@", nowString)
        let predicate5 = NSPredicate(format: "itemNo=%@", itemNo)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2, predicate3, predicate4, predicate5])

        let sortDescriptor = NSSortDescriptor(key: "dateStart", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.fetchLimit = 1

        let result = try? context.fetch(request) as? [Pricing]

        if let result = result, let pricings = result {
            return pricings.first
        }
        return nil
    }

    static func getAll(context: NSManagedObjectContext) -> [Pricing] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Pricing")
        let result = try? context.fetch(request) as? [Pricing]

        if let result = result, let pricings = result {
            return pricings
        }
        return []
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.chainNo = xmlDictionary["ChainNo"] ?? "0"
        self.custNo = xmlDictionary["CustNo"] ?? "0"
        self.dateEnd = xmlDictionary["DateEnd"] ?? ""
        self.dateStart = xmlDictionary["DateStart"] ?? ""
        self.itemNo = xmlDictionary["ItemNo"] ?? "0"
        self.prcFilRecord = xmlDictionary["PrcFilRecord"] ?? ""
        self.price = xmlDictionary["Price"] ?? "0"
        self.priceType = xmlDictionary["PriceType"] ?? "0"
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [Pricing] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "PRICING", xPath: "//Pricing/Records/Pricing")
        var pricingArray = [Pricing]()
        for dic in dicArray {
            let pricing = Pricing(context: context, forSave: forSave)
            pricing.updateBy(xmlDictionary: dic)
            pricingArray.append(pricing)
        }
        return pricingArray
    }

    static func delete(context: NSManagedObjectContext, pricing: Pricing) {
        context.delete(pricing)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension Pricing {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pricing> {
        return NSFetchRequest<Pricing>(entityName: "Pricing");
    }

    @NSManaged public var chainNo: String?
    @NSManaged public var custNo: String?
    @NSManaged public var dateEnd: String?
    @NSManaged public var dateStart: String?
    @NSManaged public var itemNo: String?
    @NSManaged public var prcFilRecord: String?
    @NSManaged public var price: String?
    @NSManaged public var priceType: String?
}
