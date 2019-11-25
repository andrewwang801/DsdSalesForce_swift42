//
//  PromotionAss+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class PromotionAss: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
    }

    static func getBy(context: NSManagedObjectContext, assignNo: String) -> [PromotionAss] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PromotionAss")
        request.predicate = NSPredicate(format: "assignNo=%@", assignNo)

        let result = try? context.fetch(request) as? [PromotionAss]

        if let result = result, let promotionAsses = result {
            return promotionAsses
        }
        return []
    }

    static func getAll(context: NSManagedObjectContext) -> [PromotionAss] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PromotionAss")
        let result = try? context.fetch(request) as? [PromotionAss]

        if let result = result, let promotionAsses = result {
            return promotionAsses
        }
        return []
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.assignNo = xmlDictionary["AssignNo"] ?? "0"
        self.promoAppMethod = xmlDictionary["PromoAppMethod"] ?? "0"
        self.promoType = xmlDictionary["PromoType"] ?? "0"
        self.promoMethod = xmlDictionary["PromoMethod"] ?? "0"
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [PromotionAss] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "PROMASS", xPath: "//PromAss/Records/PromAss")
        var promotionAssArray = [PromotionAss]()
        for dic in dicArray {
            let promotionAss = PromotionAss(context: context, forSave: forSave)
            promotionAss.updateBy(xmlDictionary: dic)
            promotionAssArray.append(promotionAss)
        }
        return promotionAssArray
    }

    static func delete(context: NSManagedObjectContext, promotionAss: PromotionAss) {
        context.delete(promotionAss)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension PromotionAss {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PromotionAss> {
        return NSFetchRequest<PromotionAss>(entityName: "PromotionAss");
    }

    @NSManaged public var assignNo: String?
    @NSManaged public var promoAppMethod: String?
    @NSManaged public var promoType: String?
    @NSManaged public var promoMethod: String?

}

