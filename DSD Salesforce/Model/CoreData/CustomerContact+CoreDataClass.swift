//
//  CustomerContact+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class CustomerContact: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)

        chainNo = "0"
        custNo = "0"
        contactType = "0"
        contactTypeDesc = ""
        contactName = ""
        contactPhoneNumber = ""
        contactEmailAddress = ""
        contactInfo = ""
    }

    static func getBy(context: NSManagedObjectContext, chainNo: String, custNo: String) -> [CustomerContact] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerContact")
        let predicate1 = NSPredicate(format: "chainNo=%@", chainNo)
        let predicate2 = NSPredicate(format: "custNo=%@", custNo)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])

        let result = try? context.fetch(request) as? [CustomerContact]

        if let result = result, let customerContacts = result {
            return customerContacts
        }
        return []
    }

    static func getAll(context: NSManagedObjectContext) -> [CustomerContact] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerContact")
        let result = try? context.fetch(request) as? [CustomerContact]

        if let result = result, let customerContacts = result {
            return customerContacts
        }
        return []
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.contactEmailAddress = xmlDictionary["ContactEmailAddress"] ?? ""
        self.contactInfo = xmlDictionary["ContactInfo"] ?? ""
        self.contactName = xmlDictionary["ContactName"] ?? ""
        self.contactPhoneNumber = xmlDictionary["ContactPhoneNumber"] ?? ""
        self.contactType = xmlDictionary["ContactType"] ?? ""
        self.contactTypeDesc = xmlDictionary["ContactTypeDesc"] ?? ""
        self.custNo = xmlDictionary["CustNo"] ?? "0"
        self.chainNo = xmlDictionary["ChainNo"] ?? "0"
    }

    func updateBy(theSource: CustomerContact) {
        self.contactEmailAddress = theSource.contactEmailAddress
        self.contactInfo = theSource.contactInfo
        self.contactName = theSource.contactName
        self.contactPhoneNumber = theSource.contactPhoneNumber
        self.contactType = theSource.contactType
        self.contactTypeDesc = theSource.contactTypeDesc
        self.custNo = theSource.custNo
        self.chainNo = theSource.chainNo
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [CustomerContact] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "CUSCONTACT", xPath: "//CustContact/Records/CustContact")
        var customerContactArray = [CustomerContact]()
        for dic in dicArray {
            let customerContact = CustomerContact(context: context, forSave: forSave)
            customerContact.updateBy(xmlDictionary: dic)
            customerContactArray.append(customerContact)
        }
        return customerContactArray
    }

    static func delete(context: NSManagedObjectContext, customerContact: CustomerContact) {
        context.delete(customerContact)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension CustomerContact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CustomerContact> {
        return NSFetchRequest<CustomerContact>(entityName: "CustomerContact");
    }

    @NSManaged public var contactEmailAddress: String?
    @NSManaged public var contactInfo: String?
    @NSManaged public var contactName: String?
    @NSManaged public var contactPhoneNumber: String?
    @NSManaged public var contactType: String?
    @NSManaged public var contactTypeDesc: String?
    @NSManaged public var custNo: String?
    @NSManaged public var chainNo: String?
}
