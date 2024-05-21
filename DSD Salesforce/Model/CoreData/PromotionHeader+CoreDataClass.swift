//
//  PromotionHeader+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class PromotionHeader: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
    }

    static func getBy(context: NSManagedObjectContext, planNo: String, endAfter: Date) -> [PromotionHeader] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PromotionHeader")
        let predicate1 = NSPredicate(format: "planNo=%@", planNo)
        let endAfterString = endAfter.toDateString(format: kTightJustDateFormat) ?? ""
        let predicate2 = NSPredicate(format: "dateEnd>=%@", endAfterString)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])

        let result = try? context.fetch(request) as? [PromotionHeader]

        if let result = result, let promotionHeaders = result {
            return promotionHeaders
        }
        return []
    }

    static func getByForToday(context: NSManagedObjectContext, planNo: String) -> [PromotionHeader] {

        let now = Date()
        let nowString = now.toDateString(format: kTightJustDateFormat) ?? ""
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PromotionHeader")
        let predicate1 = NSPredicate(format: "planNo=%@", planNo)
        let predicate2 = NSPredicate(format: "dateStart<=%@", nowString)
        let predicate3 = NSPredicate(format: "dateEnd>=%@", nowString)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2, predicate3])

        let result = try? context.fetch(request) as? [PromotionHeader]

        if let result = result, let promotionHeaders = result {
            return promotionHeaders
        }
        return []
    }

    static func getAll(context: NSManagedObjectContext) -> [PromotionHeader] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PromotionHeader")
        let result = try? context.fetch(request) as? [PromotionHeader]

        if let result = result, let promotionHeaders = result {
            return promotionHeaders
        }
        return []
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.planNo = xmlDictionary["PlanNo"] ?? "0"
        self.assignNo = xmlDictionary["AssignNo"] ?? "0"
        self.dateStart = xmlDictionary["DateStart"] ?? ""
        self.dateEnd = xmlDictionary["DateEnd"] ?? "0"
        self.availableVal = xmlDictionary["AvailableVal"] ?? "0"
        self.overflowCtl = xmlDictionary["OverflowCtl"] ?? "0"
        self.desc = xmlDictionary["Description"] ?? ""
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [PromotionHeader] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "PROMHEAD", xPath: "//PromHead/Records/PromHead")
        var promotionHeaderArray = [PromotionHeader]()
        for dic in dicArray {
            let promotionHeader = PromotionHeader(context: context, forSave: forSave)
            promotionHeader.updateBy(xmlDictionary: dic)
            promotionHeaderArray.append(promotionHeader)
        }
        return promotionHeaderArray
    }

    static func delete(context: NSManagedObjectContext, promotionHeader: PromotionHeader) {
        context.delete(promotionHeader)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension PromotionHeader {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PromotionHeader> {
        return NSFetchRequest<PromotionHeader>(entityName: "PromotionHeader");
    }

    @NSManaged public var planNo: String?
    @NSManaged public var assignNo: String?
    @NSManaged public var dateStart: String?
    @NSManaged public var dateEnd: String?
    @NSManaged public var availableVal: String?
    @NSManaged public var overflowCtl: String?
    @NSManaged public var desc: String?

}

