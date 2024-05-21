//
//  ShelfStatus+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class ShelfStatus: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
        self.isSaved = true
    }

    static func getBy(context: NSManagedObjectContext, chainNo: String, custNo: String) -> [ShelfStatus] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ShelfStatus")
        let predicate1 = NSPredicate(format: "chainNo=%@", chainNo)
        let predicate2 = NSPredicate(format: "custNo=%@", custNo)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])

        let result = try? context.fetch(request) as? [ShelfStatus]

        if let result = result, let shelfStatuses = result {
            return shelfStatuses
        }
        return []
    }
    
    static func getBy(context: NSManagedObjectContext, chainNo: String, custNo: String, itemNo: String) -> [ShelfStatus] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ShelfStatus")
        let predicate1 = NSPredicate(format: "chainNo=%@", chainNo)
        let predicate2 = NSPredicate(format: "custNo=%@", custNo)
        let predicate3 = NSPredicate(format: "itemNo=%@", itemNo)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2, predicate3])

        let result = try? context.fetch(request) as? [ShelfStatus]

        if let result = result, let shelfStatuses = result {
            return shelfStatuses
        }
        return []
    }

    static func getAll(context: NSManagedObjectContext) -> [ShelfStatus] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ShelfStatus")
        let result = try? context.fetch(request) as? [ShelfStatus]

        if let result = result, let shelfStatuses = result {
            return shelfStatuses
        }
        return []
    }

    func updateBy(theSource: ShelfStatus) {
        self.chainNo = theSource.chainNo
        self.custNo = theSource.custNo
        self.trxnType = theSource.trxnType
        self.itemNo = theSource.itemNo
        self.shelfPrice = theSource.shelfPrice
        self.oos = theSource.oos
        self.stockCount = theSource.stockCount
        self.aisle = theSource.aisle
        self.expiry = theSource.expiry
        self.facings = theSource.facings
        self.promo = theSource.promo
        self.promoPrice = theSource.promoPrice
        self.promoType = theSource.promoType
        self.marketingNotes = theSource.marketingNotes
        self.otherNotes = theSource.otherNotes
        self.delisted = theSource.delisted
        self.isSaved = theSource.isSaved
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.chainNo = xmlDictionary["ChainNo"] ?? "0"
        self.custNo = xmlDictionary["CustNo"] ?? "0"
        self.trxnType = xmlDictionary["TrxnType"] ?? ""
        self.itemNo = xmlDictionary["ItemNo"] ?? "0"
        self.shelfPrice = xmlDictionary["ShelfPrice"] ?? ""
        self.oos = xmlDictionary["OOS"] ?? ""
        self.stockCount = xmlDictionary["StockCount"] ?? "0"
        self.aisle = xmlDictionary["MarketingNotes"] ?? "0"
        self.expiry = xmlDictionary["OtherNotes"] ?? "0"
        self.facings = xmlDictionary["Facings"] ?? "0"
        self.promo = xmlDictionary["Promo"] ?? "0"
        self.promoPrice = xmlDictionary["PromoPrice"] ?? "0"
        self.promoType = xmlDictionary["PromoType"] ?? ""
        self.marketingNotes = xmlDictionary["MarketingNotes"] ?? ""
        self.otherNotes = xmlDictionary["OtherNotes"] ?? ""
        self.delisted = xmlDictionary["Delisted"] ?? "0"
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [ShelfStatus] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "SHELFSTA", xPath: "//ShelfStatus/Records/ShelfStatus")
        var shelfStatusArray = [ShelfStatus]()
        for dic in dicArray {
            let shelfStatus = ShelfStatus(context: context, forSave: forSave)
            shelfStatus.updateBy(xmlDictionary: dic)
            shelfStatusArray.append(shelfStatus)
        }
        return shelfStatusArray
    }

    static func delete(context: NSManagedObjectContext, shelfStatus: ShelfStatus) {
        context.delete(shelfStatus)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

    var isOnShelf: Bool {
        let oos = self.oos ?? "0"
        let stockCount = self.stockCount ?? "0"
        return (oos == "0" && stockCount != "0")
    }

}

extension ShelfStatus {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ShelfStatus> {
        return NSFetchRequest<ShelfStatus>(entityName: "ShelfStatus");
    }

    @NSManaged public var chainNo: String?
    @NSManaged public var custNo: String?
    @NSManaged public var trxnType: String?
    @NSManaged public var itemNo: String?
    @NSManaged public var shelfPrice: String?
    @NSManaged public var oos: String?
    @NSManaged public var stockCount: String?
    @NSManaged public var aisle: String?
    @NSManaged public var expiry: String?
    @NSManaged public var facings: String?
    @NSManaged public var promo: String?
    @NSManaged public var promoPrice: String?
    @NSManaged public var promoType: String?
    @NSManaged public var marketingNotes: String?
    @NSManaged public var otherNotes: String?
    @NSManaged public var delisted: String?
    @NSManaged public var isSaved: Bool
}

