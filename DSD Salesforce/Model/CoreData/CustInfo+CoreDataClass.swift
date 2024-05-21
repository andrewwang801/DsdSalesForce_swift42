//
//  CustInfo+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class CustInfo: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)

        infoType = ""
        chainNo = "0"
        custNo = "0"
        info = ""
    }

    static func getAll(context: NSManagedObjectContext) -> [CustInfo] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CustInfo")
        let result = try? context.fetch(request) as? [CustInfo]

        if let result = result, let custInfos = result {
            return custInfos
        }
        return []
    }

    static func getBy(context: NSManagedObjectContext, infoType: String, custNo: String) -> CustInfo? {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CustInfo")
        let predicate1 = NSPredicate(format: "infoType=%@", infoType)
        let predicate2 = NSPredicate(format: "custNo=%@", custNo)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        request.fetchLimit = 1

        let result = try? context.fetch(request) as? [CustInfo]

        if let result = result, let custInfoArray = result {
            return custInfoArray.first
        }
        return nil
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.infoType = xmlDictionary["InfoType"] ?? ""
        self.chainNo = xmlDictionary["ChainNo"] ?? ""
        self.custNo = xmlDictionary["CustNo"] ?? ""
        self.info = xmlDictionary["Info"] ?? ""
    }

    func updateBy(theSource: CustInfo) {
        self.infoType = theSource.infoType
        self.chainNo = theSource.chainNo
        self.custNo = theSource.custNo
        self.info = theSource.info
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [CustInfo] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "CUSTINFO", xPath: "//CustInfo/Records/CustInfo")
        var custInfoArray = [CustInfo]()
        for dic in dicArray {
            let custInfo = CustInfo(context: context, forSave: forSave)
            custInfo.updateBy(xmlDictionary: dic)
            custInfoArray.append(custInfo)
        }
        return custInfoArray
    }

    static func delete(context: NSManagedObjectContext, custInfo: CustInfo) {
        context.delete(custInfo)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension CustInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CustInfo> {
        return NSFetchRequest<CustInfo>(entityName: "CustInfo");
    }

    @NSManaged public var infoType: String?
    @NSManaged public var chainNo: String?
    @NSManaged public var custNo: String?
    @NSManaged public var info: String?

}
