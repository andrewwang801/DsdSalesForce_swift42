//
//  ProductLevl+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class ProductLevl: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
    }

    static func getBy(context: NSManagedObjectContext, itemNo: String) -> [ProductLevl] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ProductLevl")
        request.predicate = NSPredicate(format: "itemNo=%@", itemNo)

        let result = try? context.fetch(request) as? [ProductLevl]

        if let result = result, let productLevlArray = result {
            return productLevlArray
        }
        return []
    }

    static func getBy(context: NSManagedObjectContext, itemNo: String, locNo: String) -> ProductLevl? {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ProductLevl")
        let predicate1 = NSPredicate(format: "itemNo=%@", itemNo)
        let predicate2 = NSPredicate(format: "locNo=%@", locNo)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        request.fetchLimit = 1

        let result = try? context.fetch(request) as? [ProductLevl]
        if let result = result, let productLevlArray = result {
            return productLevlArray.first
        }
        return nil
    }

    static func getAll(context: NSManagedObjectContext) -> [ProductLevl] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ProductLevl")
        let result = try? context.fetch(request) as? [ProductLevl]

        if let result = result, let productLevlArray = result {
            return productLevlArray
        }
        return []
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.locNo = xmlDictionary["LocNo"] ?? "0"
        self.itemNo = xmlDictionary["ItemNo"] ?? ""
        self.qty = xmlDictionary["Qty"] ?? "0"
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [ProductLevl] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "PRODLEVL", xPath: "//ProdLevl/Records/ProdLevl")
        var productLevlArray = [ProductLevl]()
        for dic in dicArray {
            let productLevl = ProductLevl(context: context, forSave: forSave)
            productLevl.updateBy(xmlDictionary: dic)
            productLevlArray.append(productLevl)
        }
        return productLevlArray
    }

    static func delete(context: NSManagedObjectContext, productLevl: ProductLevl) {
        context.delete(productLevl)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension ProductLevl {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductLevl> {
        return NSFetchRequest<ProductLevl>(entityName: "ProductLevl");
    }

    @NSManaged public var locNo: String?
    @NSManaged public var itemNo: String?
    @NSManaged public var qty: String?
}

