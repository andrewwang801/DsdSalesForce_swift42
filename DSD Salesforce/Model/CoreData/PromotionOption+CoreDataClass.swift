//
//  PromotionOption+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class PromotionOption: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
    }

    static func getBy(context: NSManagedObjectContext, assignNo: String) -> [PromotionOption] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PromotionOption")
        request.predicate = NSPredicate(format: "assignNo=%@", assignNo)

        let result = try? context.fetch(request) as? [PromotionOption]

        if let result = result, let promotionOptions = result {
            return promotionOptions
        }
        return []
    }

    static func getAll(context: NSManagedObjectContext) -> [PromotionOption] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PromotionOption")
        let result = try? context.fetch(request) as? [PromotionOption]

        if let result = result, let promotionOptions = result {
            return promotionOptions
        }
        return []
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.assignNo = xmlDictionary["AssignNo"] ?? "0"
        self.planNo = xmlDictionary["PlanNo"] ?? "0"
        self.optionalDesc = xmlDictionary["OptionalDesc"] ?? ""
        self.planDesc = xmlDictionary["PlanDesc"] ?? ""
        self.assignDesc = xmlDictionary["AssignDesc"] ?? ""
        self.inStoreFromDate = xmlDictionary["InStoreFromDate"] ?? ""
        self.inStoreToDate = xmlDictionary["InStoreToDate"] ?? ""
        self.hostRefNo = xmlDictionary["HostRefNo"] ?? ""
        self.featurePrice = xmlDictionary["FeaturePrice"] ?? ""
        self.antLift = xmlDictionary["AntLift"] ?? ""
        self.note = xmlDictionary["Note"] ?? ""
        self.mandatory = xmlDictionary["Mandatory"] ?? ""
        self.igrDesc = xmlDictionary["IGRDesc"] ?? ""
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [PromotionOption] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "PROMOPT", xPath: "//PromOpt/Records/PromOpt")
        var promotionOptionArray = [PromotionOption]()
        for dic in dicArray {
            let promotionOption = PromotionOption(context: context, forSave: forSave)
            promotionOption.updateBy(xmlDictionary: dic)
            promotionOptionArray.append(promotionOption)
        }
        return promotionOptionArray
    }

    static func delete(context: NSManagedObjectContext, promotionOption: PromotionOption) {
        context.delete(promotionOption)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension PromotionOption {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PromotionOption> {
        return NSFetchRequest<PromotionOption>(entityName: "PromotionOption");
    }

    @NSManaged public var planNo: String?
    @NSManaged public var assignNo: String?
    @NSManaged public var optionalDesc: String?
    @NSManaged public var planDesc: String?
    @NSManaged public var assignDesc: String?
    @NSManaged public var inStoreFromDate: String?
    @NSManaged public var inStoreToDate: String?
    @NSManaged public var hostRefNo: String?
    @NSManaged public var featurePrice: String?
    @NSManaged public var antLift: String?
    @NSManaged public var note: String?
    @NSManaged public var mandatory: String?
    @NSManaged public var igrDesc: String?
}

