//
//  Equipment+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class Equipment: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)

        newPlacementDocPath = ""
    }

    static func getBy(context: NSManagedObjectContext, equipmentNo: String) -> [Equipment] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Equipment")
        let predicate1 = NSPredicate(format: "equipmentNo=%@", equipmentNo)
        request.predicate = predicate1

        let result = try? context.fetch(request) as? [Equipment]

        if let result = result, let equipments = result {
            return equipments
        }
        return []
    }

    static func getAll(context: NSManagedObjectContext) -> [Equipment] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Equipment")
        let result = try? context.fetch(request) as? [Equipment]

        if let result = result, let equipments = result {
            return equipments
        }
        return []
    }

    func updateBy(theSource: Equipment) {
        self.equipmentNo = theSource.equipmentNo
        self.serialNo = theSource.serialNo
        self.make = theSource.make
        self.model = theSource.model
        self.desc = theSource.desc
        self.assetType = theSource.assetType
        self.statusCode = theSource.statusCode
        self.equipmentType = theSource.equipmentType
        self.application = theSource.application
        self.dollarCapacity = theSource.dollarCapacity
        self.lastRepair = theSource.lastRepair
        self.totalSales = theSource.totalSales
        self.totalRent = theSource.totalRent
        self.altEquipment = theSource.altEquipment
        self.newPlacementDocPath = theSource.newPlacementDocPath
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.equipmentNo = xmlDictionary["EquipmentNo"] ?? "0"
        self.serialNo = xmlDictionary["SerialNo"] ?? ""
        self.make = xmlDictionary["Make"] ?? ""
        self.model = xmlDictionary["Model"] ?? ""
        self.desc = xmlDictionary["Description"] ?? ""
        self.assetType = xmlDictionary["AssetType"] ?? ""
        self.statusCode = xmlDictionary["StatusCode"] ?? "0"
        self.equipmentType = xmlDictionary["EquipmentType"] ?? "0"
        self.application = xmlDictionary["Application"] ?? "0"
        self.dollarCapacity = xmlDictionary["DollarCapacity"] ?? "0"
        self.lastRepair = xmlDictionary["LastRepair"] ?? "0"
        self.totalSales = xmlDictionary["TotalSales"] ?? "0"
        self.totalRent = xmlDictionary["TotalRent"] ?? "0"
        self.altEquipment = xmlDictionary["AltEquipment"] ?? ""
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [Equipment] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "EQUIPMNT", xPath: "//Equipmnt/Records/Equipmnt")
        var equipmentArray = [Equipment]()
        for dic in dicArray {
            let equipment = Equipment(context: context, forSave: forSave)
            equipment.updateBy(xmlDictionary: dic)
            equipmentArray.append(equipment)
        }
        return equipmentArray
    }

    static func delete(context: NSManagedObjectContext, equipment: Equipment) {
        context.delete(equipment)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

    func getEquipmentImagePath() -> String {
        let itemName = self.model ?? ""
        let catalogPath = CommData.getFilePathAppended(byDocumentDir: kEquipmentCatalogDirName) ?? ""
        let itemImagePath = catalogPath+"/"+itemName+".jpg"
        return itemImagePath
    }

    func getEquipmentImage() -> UIImage? {
        var productImage: UIImage?
        let imagePath = getEquipmentImagePath()
        productImage = UIImage.loadImageFromLocal(filePath: imagePath)
        return productImage
    }

}

extension Equipment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Equipment> {
        return NSFetchRequest<Equipment>(entityName: "Equipment");
    }

    @NSManaged public var equipmentNo: String?
    @NSManaged public var serialNo: String?
    @NSManaged public var make: String?
    @NSManaged public var model: String?
    @NSManaged public var desc: String?
    @NSManaged public var assetType: String?
    @NSManaged public var statusCode: String?
    @NSManaged public var equipmentType: String?
    @NSManaged public var application: String?
    @NSManaged public var dollarCapacity: String?
    @NSManaged public var lastRepair: String?
    @NSManaged public var totalSales: String?
    @NSManaged public var totalRent: String?
    @NSManaged public var altEquipment: String?
    @NSManaged public var newPlacementDocPath: String?

}

