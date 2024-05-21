//
//  EquipAss+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class EquipAss: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)

        chainNo = "0"
        custNo = "0"
        equipmentNo = ""
        installed = ""
        agreementNo = ""
        agreementDate = ""
        ownership = ""
        billType = ""
        billFreq = ""
        verifyFlag = ""
        verified = ""
        features = ""
        repairReason = ""
        repairNotes = ""
        repairImage = ""
        payRentAmt = "0"
        oldEquipmentType = ""
        oldEquipmentNo = ""
        status = "V"
    }

    static func getBy(context: NSManagedObjectContext, chainNo: String, custNo: String) -> [EquipAss] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "EquipAss")
        let predicate1 = NSPredicate(format: "chainNo=%@", chainNo)
        let predicate2 = NSPredicate(format: "custNo=%@", custNo)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])

        let result = try? context.fetch(request) as? [EquipAss]

        if let result = result, let equipAsses = result {
            return equipAsses
        }
        return []
    }

    static func getAll(context: NSManagedObjectContext) -> [EquipAss] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "EquipAss")
        let result = try? context.fetch(request) as? [EquipAss]

        if let result = result, let equipAsses = result {
            return equipAsses
        }
        return []
    }

    func updateBy(theSource: EquipAss) {
        self.chainNo = theSource.chainNo
        self.custNo = theSource.custNo
        self.equipmentNo = theSource.equipmentNo
        self.installed = theSource.installed
        self.agreementNo = theSource.agreementNo
        self.agreementDate = theSource.agreementDate
        self.ownership = theSource.ownership
        self.billType = theSource.billType
        self.billFreq = theSource.billFreq
        self.payRentAmt = theSource.payRentAmt
        self.verifyFlag = theSource.verifyFlag
        self.verified = theSource.verified
        self.features = theSource.features
        self.repairReason = theSource.repairReason
        self.repairNotes = theSource.repairNotes
        self.repairImage = theSource.repairImage
        self.oldEquipmentType = theSource.oldEquipmentType
        self.oldEquipmentNo = theSource.oldEquipmentNo
        self.status = theSource.status
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.chainNo = xmlDictionary["ChainNo"] ?? "0"
        self.custNo = xmlDictionary["CustNo"] ?? "0"
        self.equipmentNo = xmlDictionary["EquipmentNo"] ?? "0"
        self.installed = xmlDictionary["Installed"] ?? ""
        self.agreementNo = xmlDictionary["AgreementNo"] ?? "0"
        self.agreementDate = xmlDictionary["AgreementDate"] ?? ""
        self.ownership = xmlDictionary["Ownership"] ?? ""
        self.billType = xmlDictionary["BillType"] ?? ""
        self.billFreq = xmlDictionary["BillFreq"] ?? ""
        self.payRentAmt = xmlDictionary["PayRentAmt"] ?? ""
        self.verifyFlag = xmlDictionary["VerifyFlag"] ?? ""
        self.verified = xmlDictionary["Verified"] ?? ""
        self.features = xmlDictionary["Features"] ?? ""
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [EquipAss] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "EQUIPASS", xPath: "//EquipAss/Records/EquipAss")
        var equipAssArray = [EquipAss]()
        for dic in dicArray {
            let equipAss = EquipAss(context: context, forSave: forSave)
            equipAss.updateBy(xmlDictionary: dic)
            equipAssArray.append(equipAss)
        }
        return equipAssArray
    }

    static func delete(context: NSManagedObjectContext, equipAss: EquipAss) {
        context.delete(equipAss)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension EquipAss {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EquipAss> {
        return NSFetchRequest<EquipAss>(entityName: "EquipAss");
    }

    @NSManaged public var chainNo: String?
    @NSManaged public var custNo: String?
    @NSManaged public var equipmentNo: String?
    @NSManaged public var installed: String?
    @NSManaged public var agreementNo: String?
    @NSManaged public var agreementDate: String?
    @NSManaged public var ownership: String?
    @NSManaged public var billType: String?
    @NSManaged public var billFreq: String?
    @NSManaged public var payRentAmt: String?
    @NSManaged public var verifyFlag: String?
    @NSManaged public var verified: String?
    @NSManaged public var features: String?
    @NSManaged public var repairReason: String?
    @NSManaged public var repairNotes: String?
    @NSManaged public var repairImage: String?
    @NSManaged public var oldEquipmentType: String?
    @NSManaged public var oldEquipmentNo: String?
    @NSManaged public var status: String?

}

