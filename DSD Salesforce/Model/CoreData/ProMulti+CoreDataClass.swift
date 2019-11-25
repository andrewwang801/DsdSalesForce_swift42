//
//  ProMulti+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class ProMulti: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
    }

    static func getByForToday(context: NSManagedObjectContext, chainNo: String, custNo: String) -> [ProMulti] {

        let now = Date()
        let nowString = now.toDateString(format: kTightJustDateFormat) ?? ""
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ProMulti")
        let predicate1 = NSPredicate(format: "chainNo=%@", chainNo)
        let predicate2 = NSPredicate(format: "custNo=%@", custNo)
        let predicate3 = NSPredicate(format: "dateStart<=%@", nowString)
        let predicate4 = NSPredicate(format: "dateEnd>=%@", nowString)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2, predicate3, predicate4])

        let result = try? context.fetch(request) as? [ProMulti]

        if let result = result, let proMultiArray = result {
            return proMultiArray
        }
        return []
    }

    static func getAll(context: NSManagedObjectContext) -> [ProMulti] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ProMulti")
        let result = try? context.fetch(request) as? [ProMulti]

        if let result = result, let proMultiArray = result {
            return proMultiArray
        }
        return []
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.chainNo = xmlDictionary["ChainNo"] ?? "0"
        self.custNo = xmlDictionary["CustNo"] ?? "0"
        self.planNo = xmlDictionary["PlanNo"] ?? "0"
        self.dateStart = xmlDictionary["DateStart"] ?? ""
        self.dateEnd = xmlDictionary["DateEnd"] ?? ""
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [ProMulti] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "PROMULTI", xPath: "//ProMulti/Records/ProMulti")
        var proMultiArray = [ProMulti]()
        for dic in dicArray {
            let proMulti = ProMulti(context: context, forSave: forSave)
            proMulti.updateBy(xmlDictionary: dic)
            proMultiArray.append(proMulti)
        }
        return proMultiArray
    }

    static func delete(context: NSManagedObjectContext, proMulti: ProMulti) {
        context.delete(proMulti)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension ProMulti {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProMulti> {
        return NSFetchRequest<ProMulti>(entityName: "ProMulti");
    }

    @NSManaged public var chainNo: String?
    @NSManaged public var custNo: String?
    @NSManaged public var planNo: String?
    @NSManaged public var dateStart: String?
    @NSManaged public var dateEnd: String?
    @NSManaged public var seqNo: String?
}


