//
//  KPI+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class KPI: NSManagedObject {
    
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

    static func getAll(context: NSManagedObjectContext) -> [KPI] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "KPI")
        let result = try? context.fetch(request) as? [KPI]

        if let result = result, let targets = result {
            return targets
        }
        return []
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.metricDay = xmlDictionary["MetricDay"] ?? "0"
        self.metricKey = xmlDictionary["MetricKey"] ?? ""
        self.metricValue = xmlDictionary["MetricValue"] ?? "0"
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [KPI] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "KPI", xPath: "//KPI/Records/KPI")
        var kpiArray = [KPI]()
        for dic in dicArray {
            let kpi = KPI(context: context, forSave: forSave)
            kpi.updateBy(xmlDictionary: dic)
            kpiArray.append(kpi)
        }
        return kpiArray
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

extension KPI {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KPI> {
        return NSFetchRequest<KPI>(entityName: "KPI");
    }

    @NSManaged public var metricDay: String?
    @NSManaged public var metricKey: String?
    @NSManaged public var metricValue: String?

}

