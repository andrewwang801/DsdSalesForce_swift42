//
//  PresoldOrDetail+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class PresoldOrDetail: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
        longDesc = ""
        shortDesc = ""
        requestedQty = 0
        suggestedQty = 0
    }

    static func getBy(context: NSManagedObjectContext, itemNo: String) -> [PresoldOrDetail] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PresoldOrDetail")
        let predicate1 = NSPredicate(format: "itemNo=%@", itemNo)
        request.predicate = predicate1

        let result = try? context.fetch(request) as? [PresoldOrDetail]

        if let result = result, let presoldOrDetailArray = result {
            return presoldOrDetailArray
        }
        return []
    }

    static func getBy(context: NSManagedObjectContext, detailFile: String) -> [PresoldOrDetail] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PresoldOrDetail")
        let predicate1 = NSPredicate(format: "detailFile=%@", detailFile)
        request.predicate = predicate1

        let result = try? context.fetch(request) as? [PresoldOrDetail]

        if let result = result, let presoldOrDetailArray = result {
            let ordered = presoldOrDetailArray.sorted { (presoldOrDetail1, presoldOrDetail2) -> Bool in
                let itemNo1 = presoldOrDetail1.itemNo ?? ""
                let itemNo2 = presoldOrDetail2.itemNo ?? ""
                return itemNo1 < itemNo2
            }
            return ordered
        }
        return []
    }

    static func getAll(context: NSManagedObjectContext) -> [PresoldOrDetail] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PresoldOrDetail")
        let result = try? context.fetch(request) as? [PresoldOrDetail]

        if let result = result, let presoldOrDetailArray = result {
            return presoldOrDetailArray
        }
        return []
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.detailFile = xmlDictionary["DetailFile"] ?? ""
        self.itemNo = xmlDictionary["ItemNo"] ?? "0"
        self.qtyOption = xmlDictionary["QtyOption"] ?? ""
        self.orderQty = xmlDictionary["OrderQty"] ?? "0"
        self.price = xmlDictionary["Price"] ?? ""
        self.pickLocationCode = xmlDictionary["PickLocationCode"] ?? ""
        self.reasonCode = xmlDictionary["ReasonCode"] ?? ""
        self.trxnType = xmlDictionary["TrxnType"] ?? ""
    }

    var nOrderQty: Int {
        get {
            let orderQtyValue = Int64(orderQty ?? "") ?? 0
            let divided = orderQtyValue/Int64(kXMLNumberDivider)
            return Int(divided)
        }
    }

    var dOrderQty: Double {
        get {
            let orderQtyValue = Double(orderQty ?? "") ?? 0
            let divided = orderQtyValue/Double(kXMLNumberDivider)
            return divided
        }
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [PresoldOrDetail] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "PRESOLDD", xPath: "//PresoldOrd/Records/PresoldOrd")
        var presoldOrDetailArray = [PresoldOrDetail]()
        for dic in dicArray {
            let presoldOrDetail = PresoldOrDetail(context: context, forSave: forSave)
            presoldOrDetail.updateBy(xmlDictionary: dic)
            presoldOrDetailArray.append(presoldOrDetail)
        }
        return presoldOrDetailArray
    }

    static func delete(context: NSManagedObjectContext, presoldOrDetail: PresoldOrDetail) {
        context.delete(presoldOrDetail)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension PresoldOrDetail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PresoldOrDetail> {
        return NSFetchRequest<PresoldOrDetail>(entityName: "PresoldOrDetail");
    }

    @NSManaged public var detailFile: String?
    @NSManaged public var itemNo: String?
    @NSManaged public var qtyOption: String?
    @NSManaged public var orderQty: String?
    @NSManaged public var price: String?
    @NSManaged public var pickLocationCode: String?
    @NSManaged public var reasonCode: String?
    @NSManaged public var trxnType: String?

    @NSManaged public var longDesc: String?
    @NSManaged public var shortDesc: String?
    @NSManaged public var requestedQty: Int32
    @NSManaged public var suggestedQty: Int32
}

