//
//  AuthDetail+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class AuthDetail: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
    }

    static func getBy(context: NSManagedObjectContext, authGrp: String) -> [AuthDetail] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AuthDetail")
        request.predicate = NSPredicate(format: "authGrp=%@", authGrp)

        let result = try? context.fetch(request) as? [AuthDetail]

        if let result = result, let authDetailArray = result {
            return authDetailArray
        }
        return []
    }

    static func getAll(context: NSManagedObjectContext) -> [AuthDetail] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AuthDetail")
        let result = try? context.fetch(request) as? [AuthDetail]

        if let result = result, let authDetailArray = result {
            return authDetailArray
        }
        return []
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.authGrp = xmlDictionary["AuthGrp"] ?? "0"
        self.itemNo = xmlDictionary["ItemNo"] ?? "0"
        self.startDate = xmlDictionary["StartDate"] ?? ""
        self.endDate = xmlDictionary["EndDate"] ?? ""
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [AuthDetail] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "AUTHDETL", xPath: "//AuthDetl/Records/AuthDetl")
        var authDetailArray = [AuthDetail]()
        for dic in dicArray {
            let authDetail = AuthDetail(context: context, forSave: forSave)
            authDetail.updateBy(xmlDictionary: dic)
            authDetailArray.append(authDetail)
        }
        return authDetailArray
    }

    static func delete(context: NSManagedObjectContext, authDetail: AuthDetail) {
        context.delete(authDetail)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension AuthDetail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AuthDetail> {
        return NSFetchRequest<AuthDetail>(entityName: "AuthDetail");
    }

    @NSManaged public var authGrp: String?
    @NSManaged public var itemNo: String?
    @NSManaged public var startDate: String?
    @NSManaged public var endDate: String?
}

