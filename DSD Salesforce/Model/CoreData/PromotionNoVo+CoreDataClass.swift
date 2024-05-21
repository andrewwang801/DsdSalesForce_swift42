//
//  PromotionNoVo+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class PromotionNoVo: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
    }

    static func getBy(context: NSManagedObjectContext, assignNo: String) -> [PromotionNoVo] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PromotionNoVo")
        request.predicate = NSPredicate(format: "assignNo=%@", assignNo)

        let result = try? context.fetch(request) as? [PromotionNoVo]

        if let result = result, let promotionNoVos = result {
            return promotionNoVos
        }
        return []
    }

    static func getAll(context: NSManagedObjectContext) -> [PromotionNoVo] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PromotionNoVo")
        let result = try? context.fetch(request) as? [PromotionNoVo]

        if let result = result, let promotionNoVos = result {
            return promotionNoVos
        }
        return []
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.assignNo = xmlDictionary["AssignNo"] ?? "0"
        self.itemNo = xmlDictionary["ItemNo"] ?? "0"
        self.promoDiscount = xmlDictionary["PromoDiscount"] ?? "0"
        self.freeItemNo = xmlDictionary["FreeItemNo"] ?? "0"
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [PromotionNoVo] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "PROMNOVO", xPath: "//PromNoVo/Records/PromNoVo")
        var promotionNoVoArray = [PromotionNoVo]()
        for dic in dicArray {
            let promotionNoVo = PromotionNoVo(context: context, forSave: forSave)
            promotionNoVo.updateBy(xmlDictionary: dic)
            promotionNoVoArray.append(promotionNoVo)
        }
        return promotionNoVoArray
    }

    static func delete(context: NSManagedObjectContext, promotionNoVo: PromotionNoVo) {
        context.delete(promotionNoVo)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension PromotionNoVo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PromotionNoVo> {
        return NSFetchRequest<PromotionNoVo>(entityName: "PromotionNoVo");
    }

    @NSManaged public var assignNo: String?
    @NSManaged public var itemNo: String?
    @NSManaged public var promoDiscount: String?
    @NSManaged public var freeItemNo: String?

}

