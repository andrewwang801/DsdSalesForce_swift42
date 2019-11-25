//
//  ARHeader+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class ARHeader: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
        nProcessStatus = 0
    }

    static func getBy(context: NSManagedObjectContext, chainNo: String, custNo: String) -> [ARHeader] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ARHeader")
        let predicate1 = NSPredicate(format: "chainNo=%@", chainNo)
        let predicate2 = NSPredicate(format: "custNo=%@", custNo)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])

        let result = try? context.fetch(request) as? [ARHeader]

        if let result = result, let arHeaderArray = result {
            return arHeaderArray
        }
        return []
    }

    static func getUnpaidBy(context: NSManagedObjectContext, chainNo: String, custNo: String) -> [ARHeader] {
        let all = getBy(context: context, chainNo: chainNo, custNo: custNo)
        let filtered = all.filter { (arHeader) -> Bool in
            let trxnAmount = Utils.getXMLDivided(valueString: arHeader.trxnAmount ?? "0")
            if trxnAmount == 0 {
                return false
            }
            if arHeader.nProcessStatus != kARPaidStatus {
                return true
            }
            return false
        }
        return filtered
    }

    static func getAll(context: NSManagedObjectContext) -> [ARHeader] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ARHeader")
        let result = try? context.fetch(request) as? [ARHeader]

        if let result = result, let arHeaderArray = result {
            return arHeaderArray
        }
        return []
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.chainNo = xmlDictionary["ChainNo"] ?? "0"
        self.custNo = xmlDictionary["CustNo"] ?? "0"
        self.arTrxnType = xmlDictionary["ARTrxnType"] ?? "INV"
        self.invDate = xmlDictionary["InvDate"] ?? ""
        self.invNo = xmlDictionary["InvNo"] ?? "0"
        self.trxnAmount = xmlDictionary["TrxnAmount"] ?? "0"
    }

    func updateBy(theSource: ARHeader) {
        self.chainNo = theSource.chainNo
        self.custNo = theSource.custNo
        self.arTrxnType = theSource.arTrxnType
        self.invDate = theSource.invDate
        self.invNo = theSource.invNo
        self.trxnAmount = theSource.trxnAmount
        self.nProcessStatus = theSource.nProcessStatus
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [ARHeader] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "ARHEADER", xPath: "//ARHeader/Records/ARHeader")
        var arHeaderArray = [ARHeader]()
        for dic in dicArray {
            let arHeader = ARHeader(context: context, forSave: forSave)
            arHeader.updateBy(xmlDictionary: dic)
            arHeaderArray.append(arHeader)
        }
        return arHeaderArray
    }

    static func delete(context: NSManagedObjectContext, arHeader: ARHeader) {
        context.delete(arHeader)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension ARHeader {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ARHeader> {
        return NSFetchRequest<ARHeader>(entityName: "ARHeader");
    }

    @NSManaged public var chainNo: String?
    @NSManaged public var custNo: String?
    @NSManaged public var invDate: String?
    @NSManaged public var invNo: String?
    @NSManaged public var trxnAmount: String?
    @NSManaged public var arTrxnType: String?
    @NSManaged public var nProcessStatus: Int32
}

