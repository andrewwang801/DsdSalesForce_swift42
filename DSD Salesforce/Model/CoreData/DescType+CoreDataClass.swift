//
//  DescType+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class DescType: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
    }


    static func getBy(context: NSManagedObjectContext, descTypeID: String, alphaKey: String) -> DescType? {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DescType")
        let predicate1 = NSPredicate(format: "descriptionTypeID=%@", descTypeID)
        let predicate2 = NSPredicate(format: "alphaKey=%@", alphaKey)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        request.fetchLimit = 1

        let result = try? context.fetch(request) as? [DescType]

        if let result = result, let descTypes = result {
            return descTypes.first
        }
        return nil
    }

    static func getBy(context: NSManagedObjectContext, descTypeID: String) -> [DescType] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DescType")
        let predicate1 = NSPredicate(format: "descriptionTypeID=%@", descTypeID)
        request.predicate = predicate1
        request.sortDescriptors = [NSSortDescriptor(key: "desc", ascending: true)]

        let result = try? context.fetch(request) as? [DescType]

        if let result = result, let descTypes = result {
            return descTypes
        }
        return []
    }

    static func getBy(context: NSManagedObjectContext, descTypeID: String, numericKey: String) -> DescType? {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DescType")
        let predicate1 = NSPredicate(format: "descriptionTypeID=%@", descTypeID)
        let predicate2 = NSPredicate(format: "numericKey=%@", numericKey)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        request.fetchLimit = 1

        let result = try? context.fetch(request) as? [DescType]

        if let result = result, let descTypes = result {
            return descTypes.first
        }
        return nil
    }

    static func getAll(context: NSManagedObjectContext) -> [DescType] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DescType")
        let result = try? context.fetch(request) as? [DescType]

        if let result = result, let descTypes = result {
            return descTypes
        }
        return []
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.descriptionEntryKey = xmlDictionary["DescriptionEntryKey"] ?? "0"
        self.systemDescriptionTypeYN = xmlDictionary["SystemDescriptionTypeYN"] ?? "0"
        self.descriptionTypeID = xmlDictionary["DescriptionTypeID"] ?? "0"
        self.numericCodeYN = xmlDictionary["NumericCodeYN"] ?? "0"
        self.numericKey = xmlDictionary["NumericKey"] ?? "0"
        self.alphaKey = xmlDictionary["AlphaKey"] ?? "0"
        self.desc = xmlDictionary["Description"] ?? ""
        self.alternateSeq = xmlDictionary["AlternateSeq"] ?? "0"
        self.value1 = xmlDictionary["Value1"] ?? ""
        self.value2 = xmlDictionary["Value2"] ?? ""
        self.value3 = xmlDictionary["Value3"] ?? ""
        self.value4 = xmlDictionary["Value4"] ?? ""
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [DescType] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "DESCTYPE", xPath: "//DescType/Records/DescType")
        var descTypeArray = [DescType]()
        for dic in dicArray {
            let descType = DescType(context: context, forSave: forSave)
            descType.updateBy(xmlDictionary: dic)
            descTypeArray.append(descType)
        }
        return descTypeArray
    }

    static func delete(context: NSManagedObjectContext, descType: DescType) {
        context.delete(descType)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension DescType {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DescType> {
        return NSFetchRequest<DescType>(entityName: "DescType");
    }

    @NSManaged public var descriptionEntryKey: String?
    @NSManaged public var systemDescriptionTypeYN: String?
    @NSManaged public var descriptionTypeID: String?
    @NSManaged public var numericCodeYN: String?
    @NSManaged public var numericKey: String?
    @NSManaged public var alphaKey: String?
    @NSManaged public var desc: String?
    @NSManaged public var alternateSeq: String?
    @NSManaged public var value1: String?
    @NSManaged public var value2: String?
    @NSManaged public var value3: String?
    @NSManaged public var value4: String?
}

