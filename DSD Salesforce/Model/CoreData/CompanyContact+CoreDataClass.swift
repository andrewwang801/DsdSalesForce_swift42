//
//  CompanyContact+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class CompanyContact: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)

        companyEmail = ""
        companyInfo = ""
        companyName = ""
        self.companyNumber = "0"
        self.companyPhone1 = ""
        self.companyPhone2 = ""
        self.companyWeb = ""
    }

    static func getAll(context: NSManagedObjectContext) -> [CompanyContact] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CompanyContact")
        let result = try? context.fetch(request) as? [CompanyContact]

        if let result = result, let companyContacts = result {
            return companyContacts
        }
        return []
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.companyEmail = xmlDictionary["CompanyEmail"] ?? ""
        self.companyInfo = xmlDictionary["CompanyInfo"] ?? ""
        self.companyName = xmlDictionary["CompanyName"] ?? ""
        self.companyNumber = xmlDictionary["CompanyNumber"] ?? "0"
        self.companyPhone1 = xmlDictionary["CompanyPhone1"] ?? ""
        self.companyPhone2 = xmlDictionary["CompanyPhone2"] ?? ""
        self.companyWeb = xmlDictionary["CompanyWeb"] ?? ""
    }

    func updateBy(theSource: CompanyContact) {
        self.companyEmail = theSource.companyEmail
        self.companyInfo = theSource.companyInfo
        self.companyName = theSource.companyName
        self.companyNumber = theSource.companyNumber
        self.companyPhone1 = theSource.companyPhone1
        self.companyPhone2 = theSource.companyPhone2
        self.companyWeb = theSource.companyWeb
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [CompanyContact] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "CMPYCONTACT", xPath: "//CmpyContact/Records/CmpyContact")
        var companyContactArray = [CompanyContact]()
        for dic in dicArray {
            let companyContact = CompanyContact(context: context, forSave: forSave)
            companyContact.updateBy(xmlDictionary: dic)
            companyContactArray.append(companyContact)
        }
        return companyContactArray
    }

    static func delete(context: NSManagedObjectContext, companyContact: CompanyContact) {
        context.delete(companyContact)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension CompanyContact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CompanyContact> {
        return NSFetchRequest<CompanyContact>(entityName: "CompanyContact");
    }

    @NSManaged public var companyEmail: String?
    @NSManaged public var companyInfo: String?
    @NSManaged public var companyName: String?
    @NSManaged public var companyNumber: String?
    @NSManaged public var companyPhone1: String?
    @NSManaged public var companyPhone2: String?
    @NSManaged public var companyWeb: String?
}
