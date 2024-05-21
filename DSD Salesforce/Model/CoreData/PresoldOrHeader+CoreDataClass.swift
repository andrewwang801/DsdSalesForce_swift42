//
//  PresoldOrHeader+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class PresoldOrHeader: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
        isVisited = false
        nQty = 0
    }

    static func getFirstBy(context: NSManagedObjectContext, chainNo: String, custNo: String) -> PresoldOrHeader? {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PresoldOrHeader")
        let predicate1 = NSPredicate(format: "chainNo=%@", chainNo)
        let predicate2 = NSPredicate(format: "custNo=%@", custNo)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        request.fetchLimit = 1

        let result = try? context.fetch(request) as? [PresoldOrHeader]

        if let result = result, let presoldOrHeaders = result {
            return presoldOrHeaders.first
        }
        return nil
    }

    static func getBy(context: NSManagedObjectContext, chainNo: String, custNo: String, periodNo: String, deliverySequence: String) -> [PresoldOrHeader] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PresoldOrHeader")
        let predicate1 = NSPredicate(format: "chainNo=%@", chainNo)
        let predicate2 = NSPredicate(format: "custNo=%@", custNo)
        let predicate3 = NSPredicate(format: "periodNo=%@", periodNo)
        let predicate4 = NSPredicate(format: "deliverySequence=%@", deliverySequence)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2, predicate3, predicate4])

        let result = try? context.fetch(request) as? [PresoldOrHeader]

        if let result = result, let presoldOrHeaders = result {
            let filtered = presoldOrHeaders.filter { (presoldOrHeader) -> Bool in
                let type = presoldOrHeader.type ?? ""
                if type == "P" || type == "4" || type == "N" || type == "W" {
                    return true
                }
                else {
                    return false
                }
            }
            return filtered
        }
        return []
    }

    static func getByForReturns(context: NSManagedObjectContext, chainNo: String, custNo: String, periodNo: String, deliverySequence: String) -> [PresoldOrHeader] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PresoldOrHeader")
        let predicate1 = NSPredicate(format: "chainNo=%@", chainNo)
        let predicate2 = NSPredicate(format: "custNo=%@", custNo)
        let predicate3 = NSPredicate(format: "periodNo=%@", periodNo)
        let predicate4 = NSPredicate(format: "deliverySequence=%@", deliverySequence)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2, predicate3, predicate4])

        let result = try? context.fetch(request) as? [PresoldOrHeader]

        if let result = result, let presoldOrHeaders = result {
            let filtered = presoldOrHeaders.filter { (presoldOrHeader) -> Bool in
                let type = presoldOrHeader.type ?? ""
                if type == "R" {
                    return true
                }
                else {
                    return false
                }
            }
            return filtered
        }
        return []
    }

    static func getByForReturns(context: NSManagedObjectContext, chainNo: String, custNo: String) -> [PresoldOrHeader] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PresoldOrHeader")
        let predicate1 = NSPredicate(format: "chainNo=%@", chainNo)
        let predicate2 = NSPredicate(format: "custNo=%@", custNo)

        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])

        let result = try? context.fetch(request) as? [PresoldOrHeader]

        if let result = result, let presoldOrHeaders = result {
            let filtered = presoldOrHeaders.filter { (presoldOrHeader) -> Bool in
                let type = presoldOrHeader.type ?? ""
                if type == "R" {
                    return true
                }
                else {
                    return false
                }
            }
            return filtered
        }
        return []
    }

    static func getByForSales(context: NSManagedObjectContext, chainNo: String, custNo: String, periodNo: String, deliverySequence: String) -> [PresoldOrHeader] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PresoldOrHeader")
        let predicate1 = NSPredicate(format: "chainNo=%@", chainNo)
        let predicate2 = NSPredicate(format: "custNo=%@", custNo)
        let predicate3 = NSPredicate(format: "periodNo=%@", periodNo)
        let predicate4 = NSPredicate(format: "deliverySequence=%@", deliverySequence)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2, predicate3, predicate4])

        let result = try? context.fetch(request) as? [PresoldOrHeader]

        if let result = result, let presoldOrHeaders = result {
            let filtered = presoldOrHeaders.filter { (presoldOrHeader) -> Bool in
                let type = presoldOrHeader.type ?? ""
                if type == "P" || type == "B" || type == "4" || type == "C" {
                    return true
                }
                else {
                    return false
                }
            }
            return filtered
        }
        return []
    }

    static func getByForSales(context: NSManagedObjectContext, chainNo: String, custNo: String) -> [PresoldOrHeader] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PresoldOrHeader")
        let predicate1 = NSPredicate(format: "chainNo=%@", chainNo)
        let predicate2 = NSPredicate(format: "custNo=%@", custNo)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])

        let result = try? context.fetch(request) as? [PresoldOrHeader]

        if let result = result, let presoldOrHeaders = result {
            let filtered = presoldOrHeaders.filter { (presoldOrHeader) -> Bool in
                let type = presoldOrHeader.type ?? ""
                if type == "P" || type == "B" || type == "4" || type == "C" {
                    return true
                }
                else {
                    return false
                }
            }
            return filtered
        }
        return []
    }

    static func getBy(context: NSManagedObjectContext, chainNo: String, custNo: String, periodNo: String) -> [PresoldOrHeader] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PresoldOrHeader")
        let predicate1 = NSPredicate(format: "chainNo=%@", chainNo)
        let predicate2 = NSPredicate(format: "custNo=%@", custNo)
        let predicate3 = NSPredicate(format: "periodNo=%@", periodNo)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2, predicate3])

        let result = try? context.fetch(request) as? [PresoldOrHeader]

        if let result = result, let presoldOrHeaders = result {
            let filtered = presoldOrHeaders.filter { (presoldOrHeader) -> Bool in
                let type = presoldOrHeader.type ?? ""
                if type == "P" || type == "B" || type == "C" || type == "4" || type == "N" || type == "W" {
                    return true
                }
                else {
                    return false
                }
            }
            return filtered
        }
        return []
    }

    static func getAll(context: NSManagedObjectContext) -> [PresoldOrHeader] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PresoldOrHeader")
        let result = try? context.fetch(request) as? [PresoldOrHeader]

        if let result = result, let presoldOrHeaders = result {
            return presoldOrHeaders
        }
        return []
    }

    func updateBy(theSource: PresoldOrHeader) {

        self.detailFile = theSource.detailFile
        self.dayNo = theSource.dayNo
        self.deliveryDate = theSource.deliveryDate
        self.periodNo = theSource.periodNo
        self.deliverySequence = theSource.deliverySequence
        self.orderNo = theSource.orderNo
        self.orderBarcode = theSource.orderBarcode
        self.modifiable = theSource.modifiable
        self.type = theSource.type
        self.routeNumber = theSource.routeNumber
        self.poRef = theSource.poRef
        self.credRef = theSource.credRef
        self.instrs = theSource.instrs
        self.dsd = theSource.dsd
        self.distr = theSource.distr
        self.user1 = theSource.user1
        self.user2 = theSource.user2
        self.tripNumber = theSource.tripNumber
        self.custNo = theSource.custNo
        self.chainNo = theSource.chainNo
        self.isVisited = theSource.isVisited
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.detailFile = xmlDictionary["DetailFile"] ?? ""
        self.dayNo = xmlDictionary["DayNo"] ?? "0"
        self.deliveryDate = xmlDictionary["DeliveryDate"] ?? ""
        self.periodNo = xmlDictionary["PeriodNo"] ?? "0"
        self.deliverySequence = xmlDictionary["DeliverySequence"] ?? ""
        self.orderNo = xmlDictionary["OrderNo"] ?? "0"
        self.orderBarcode = xmlDictionary["OrderBarcode"] ?? ""
        self.modifiable = xmlDictionary["Modifiable"] ?? ""
        self.type = xmlDictionary["Type"] ?? ""
        self.routeNumber = xmlDictionary["RouteNumber"] ?? "0"
        self.poRef = xmlDictionary["PORef"] ?? ""
        self.credRef = xmlDictionary["CredRef"] ?? ""
        self.instrs = xmlDictionary["Instrs"] ?? ""
        self.dsd = xmlDictionary["DSD"] ?? ""
        self.distr = xmlDictionary["Distr"] ?? ""
        self.user1 = xmlDictionary["User1"] ?? ""
        self.user2 = xmlDictionary["User2"] ?? ""
        self.tripNumber = xmlDictionary["TripNumber"] ?? ""
        self.custNo = xmlDictionary["CustNo"] ?? "0"
        self.chainNo = xmlDictionary["ChainNo"] ?? "0"

        self.nQty = Int32(self.user2 ?? "") ?? 0
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [PresoldOrHeader] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "PRESOLDH", xPath: "//PresoldOrh/Records/PresoldOrh")
        var presoldOrHeaderArray = [PresoldOrHeader]()
        for dic in dicArray {
            let presoldOrHeader = PresoldOrHeader(context: context, forSave: forSave)
            presoldOrHeader.updateBy(xmlDictionary: dic)
            presoldOrHeaderArray.append(presoldOrHeader)
        }
        return presoldOrHeaderArray
    }

    static func delete(context: NSManagedObjectContext, presoldOrHeader: PresoldOrHeader) {
        context.delete(presoldOrHeader)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension PresoldOrHeader {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PresoldOrHeader> {
        return NSFetchRequest<PresoldOrHeader>(entityName: "PresoldOrHeader");
    }

    @NSManaged public var chainNo: String?
    @NSManaged public var custNo: String?
    @NSManaged public var credRef: String?
    @NSManaged public var dayNo: String?
    @NSManaged public var deliveryDate: String?
    @NSManaged public var deliverySequence: String?
    @NSManaged public var detailFile: String?
    @NSManaged public var distr: String?
    @NSManaged public var dsd: String?
    @NSManaged public var instrs: String?
    @NSManaged public var modifiable: String?
    @NSManaged public var orderBarcode: String?
    @NSManaged public var orderNo: String?
    @NSManaged public var periodNo: String?
    @NSManaged public var poRef: String?
    @NSManaged public var routeNumber: String?
    @NSManaged public var tripNumber: String?
    @NSManaged public var type: String?
    @NSManaged public var user1: String?
    @NSManaged public var user2: String?

    @NSManaged public var isVisited: Bool
    @NSManaged public var nQty: Int32
}

