//
//  ProductStruct+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class ProductStruct: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
        sortOrder = 0
    }

    static func getBy(context: NSManagedObjectContext, entryID: String) -> [ProductStruct] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ProductStruct")
        request.predicate = NSPredicate(format: "entryID=%@", entryID)

        let result = try? context.fetch(request) as? [ProductStruct]

        if let result = result, let productStructArray = result {
            return productStructArray
        }
        return []
    }

    static func getAll(context: NSManagedObjectContext) -> [ProductStruct] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ProductStruct")
        let result = try? context.fetch(request) as? [ProductStruct]

        if let result = result, let productStructArray = result {

            let ordered = productStructArray.sorted { (productStruct1, productStruct2) -> Bool in
                let sortOrder1 = productStruct1.sortOrder
                let sortOrder2 = productStruct2.sortOrder
                return sortOrder1 < sortOrder2
            }
            return ordered
        }
        return []
    }

    static func getProductStructObjectEntryIDDictionary(context: NSManagedObjectContext) -> [String: Int] {
        var dictionary = [String: Int]()
        let all = getAll(context: context)
        for productStruct in all {
            let itemNo = productStruct.reference ?? ""
            let entryID = Int(productStruct.entryID ?? "") ?? 0
            dictionary[itemNo] = entryID
        }
        return dictionary
    }

    static func getProductStructParentIDEntryDictionary(context: NSManagedObjectContext) -> [Int: Int] {
        var dictionary = [Int: Int]()
        let all = getAll(context: context)
        for productStruct in all {
            let entryID = Int(productStruct.entryID ?? "") ?? 0
            let parentID = Int(productStruct.parentID ?? "") ?? 0
            dictionary[entryID] = parentID
        }
        return dictionary
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.entryID = xmlDictionary["EntryID"] ?? ""
        self.desc = xmlDictionary["Description"] ?? ""
        self.parentID = xmlDictionary["ParentID"] ?? ""
        self.objectType = xmlDictionary["ObjectType"] ?? ""
        self.reference = xmlDictionary["Reference"] ?? ""
        self.groupNo = xmlDictionary["GroupNo"] ?? ""
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [ProductStruct] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "PRODSTRU", xPath: "//ProdStru/Records/ProdStru")
        var productStructArray = [ProductStruct]()
        for (index, dic) in dicArray.enumerated() {
            let productStruct = ProductStruct(context: context, forSave: forSave)
            productStruct.updateBy(xmlDictionary: dic)
            productStruct.sortOrder = Int32(index)
            productStructArray.append(productStruct)
        }
        return productStructArray
    }

    static func delete(context: NSManagedObjectContext, productStruct: ProductStruct) {
        context.delete(productStruct)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension ProductStruct {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductStruct> {
        return NSFetchRequest<ProductStruct>(entityName: "ProductStruct");
    }

    @NSManaged public var entryID: String?
    @NSManaged public var desc: String?
    @NSManaged public var fullDesc: String?
    @NSManaged public var parentID: String?
    @NSManaged public var objectType: String?
    @NSManaged public var reference: String?
    @NSManaged public var groupNo: String?
    @NSManaged public var shortDesc: String?
    @NSManaged public var sortOrder: Int32
}

