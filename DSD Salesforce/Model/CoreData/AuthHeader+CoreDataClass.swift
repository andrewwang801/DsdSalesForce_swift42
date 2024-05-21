//
//  AuthHeader+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class AuthHeader: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
    }

    static func getBy(context: NSManagedObjectContext, authType: String) -> [AuthHeader] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AuthHeader")
        request.predicate = NSPredicate(format: "authType=%@", authType)

        let result = try? context.fetch(request) as? [AuthHeader]

        if let result = result, let authHeaderArray = result {
            return authHeaderArray
        }
        return []
    }

    static func getBy(context: NSManagedObjectContext, authGrp: String) -> [AuthHeader] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AuthHeader")
        request.predicate = NSPredicate(format: "authGrp=%@", authGrp)

        let result = try? context.fetch(request) as? [AuthHeader]

        if let result = result, let authHeaderArray = result {
            return authHeaderArray
        }
        return []
    }

    static func getAll(context: NSManagedObjectContext) -> [AuthHeader] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AuthHeader")
        let result = try? context.fetch(request) as? [AuthHeader]

        if let result = result, let authHeaderArray = result {
            return authHeaderArray
        }
        return []
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.authGrp = xmlDictionary["AuthGrp"] ?? "0"
        self.authType = xmlDictionary["AuthType"] ?? "0"
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [AuthHeader] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "AUTHHEAD", xPath: "//AuthHead/Records/AuthHead")
        var authHeaderArray = [AuthHeader]()
        for dic in dicArray {
            let authHeader = AuthHeader(context: context, forSave: forSave)
            authHeader.updateBy(xmlDictionary: dic)
            authHeaderArray.append(authHeader)
        }
        return authHeaderArray
    }

    static func delete(context: NSManagedObjectContext, authHeader: AuthHeader) {
        context.delete(authHeader)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension AuthHeader {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AuthHeader> {
        return NSFetchRequest<AuthHeader>(entityName: "AuthHeader");
    }

    @NSManaged public var authGrp: String?
    @NSManaged public var authType: String?

}


