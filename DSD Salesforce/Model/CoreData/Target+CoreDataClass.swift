//
//  Target+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class Target: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
    }

    /*
    static func getBy(context: NSManagedObjectContext, custNo: String) -> RouteSchedule? {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RouteSchedule")
        request.predicate = NSPredicate(format: "custNo=%@", custNo)
        request.fetchLimit = 1

        let result = try? context.fetch(request) as? [CustomerDetail]

        if let result = result, let customerDetails = result {
            return customerDetails.first
        }
        return nil
    }*/

    static func getAll(context: NSManagedObjectContext) -> [Target] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Target")
        let result = try? context.fetch(request) as? [Target]

        if let result = result, let targets = result {
            return targets
        }
        return []
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.salesMTD = xmlDictionary["SalesMTD"] ?? "0"
        self.monthTarget = xmlDictionary["MonthTarget"] ?? "0"
        self.salesWTD = xmlDictionary["SalesWTD"] ?? "0"
        self.salesLWTD = xmlDictionary["SalesLWTD"] ?? "0"
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [Target] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "TARGET", xPath: "//TARGET/Records/TARGET")
        var targetArray = [Target]()
        for dic in dicArray {
            let target = Target(context: context, forSave: forSave)
            target.updateBy(xmlDictionary: dic)
            targetArray.append(target)
        }
        return targetArray
    }

    static func delete(context: NSManagedObjectContext, target: Target) {
        context.delete(target)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension Target {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Target> {
        return NSFetchRequest<Target>(entityName: "Target");
    }

    @NSManaged public var salesMTD: String?
    @NSManaged public var monthTarget: String?
    @NSManaged public var salesWTD: String?
    @NSManaged public var salesLWTD: String?

}

