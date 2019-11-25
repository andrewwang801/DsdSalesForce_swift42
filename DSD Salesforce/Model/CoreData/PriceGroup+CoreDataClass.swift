//
//  PriceGroup+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class PriceGroup: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
    }

    static func getBy(context: NSManagedObjectContext, priceGrp: String) -> [PriceGroup] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PriceGroup")
        request.predicate = NSPredicate(format: "priceGrp=%@", priceGrp)

        let result = try? context.fetch(request) as? [PriceGroup]

        if let result = result, let priceGroups = result {
            return priceGroups
        }
        return []
    }

    static func getByForToday(context: NSManagedObjectContext, priceGroup: String, itemNo: String) -> PriceGroup? {

        let now = Date()
        let nowString = now.toDateString(format: kTightJustDateFormat) ?? ""
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PriceGroup")
        let predicate1 = NSPredicate(format: "priceGrp=%@", priceGroup)
        let predicate2 = NSPredicate(format: "dateStart<=%@", nowString)
        let predicate3 = NSPredicate(format: "dateEnd>=%@", nowString)
        let predicate4 = NSPredicate(format: "itemNo=%@", itemNo)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2, predicate3, predicate4])

        let result = try? context.fetch(request) as? [PriceGroup]

        if let result = result, let priceGroupArray = result {
            return priceGroupArray.first
        }
        return nil
    }

    static func getAll(context: NSManagedObjectContext) -> [PriceGroup] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PriceGroup")
        let result = try? context.fetch(request) as? [PriceGroup]

        if let result = result, let priceGroups = result {
            return priceGroups
        }
        return []
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.dateEnd = xmlDictionary["DateEnd"] ?? ""
        self.dateStart = xmlDictionary["DateStart"] ?? ""
        self.itemNo = xmlDictionary["ItemNo"] ?? "0"
        self.prcFilRecord = xmlDictionary["PrcFilRecord"] ?? ""
        self.price = xmlDictionary["Price"] ?? "0"
        self.priceGrp = xmlDictionary["PriceGrp"] ?? "0"
        self.priceType = xmlDictionary["PriceType"] ?? "0"
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [PriceGroup] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "PRICEGRP", xPath: "//PriceGrp/Records/PriceGrp")
        var priceGroupArray = [PriceGroup]()
        for dic in dicArray {
            let priceGroup = PriceGroup(context: context, forSave: forSave)
            priceGroup.updateBy(xmlDictionary: dic)
            priceGroupArray.append(priceGroup)
        }
        return priceGroupArray
    }

    static func delete(context: NSManagedObjectContext, priceGroup: PriceGroup) {
        context.delete(priceGroup)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension PriceGroup {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PriceGroup> {
        return NSFetchRequest<PriceGroup>(entityName: "PriceGroup");
    }

    @NSManaged public var dateEnd: String?
    @NSManaged public var dateStart: String?
    @NSManaged public var itemNo: String?
    @NSManaged public var prcFilRecord: String?
    @NSManaged public var price: String?
    @NSManaged public var priceGrp: String?
    @NSManaged public var priceType: String?
}


