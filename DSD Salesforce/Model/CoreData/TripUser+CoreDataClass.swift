//
//  TripUser+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class TripUser: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)

        desc = ""
        routeNumber = ""
        security1 = ""
        trip = ""
        userName = ""
    }

    static func getAll(context: NSManagedObjectContext) -> [TripUser] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TripUser")
        let result = try? context.fetch(request) as? [TripUser]

        if let result = result, let tripUsers = result {
            let sorted = tripUsers.sorted { (tripUser1, tripUser2) -> Bool in
                let routeNumber1 = Int(tripUser1.routeNumber ?? "") ?? 0
                let routeNumber2 = Int(tripUser2.routeNumber ?? "") ?? 0
                return routeNumber1 < routeNumber2
            }
            return sorted
        }
        return []
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.desc = xmlDictionary["Description"] ?? ""
        self.routeNumber = xmlDictionary["RouteNumber"] ?? ""
        self.security1 = xmlDictionary["Security1"] ?? ""
        self.trip = xmlDictionary["Trip"] ?? ""
        self.userName = xmlDictionary["UserName"] ?? ""
    }

    func updateBy(theSource: TripUser) {
        self.desc = theSource.desc
        self.routeNumber = theSource.routeNumber
        self.security1 = theSource.security1
        self.trip = theSource.trip
        self.userName = theSource.userName
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [TripUser] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "TRIPUSER", xPath: "//TripUser/Records/TripUser")
        var tripUserArray = [TripUser]()
        for dic in dicArray {
            let tripUser = TripUser(context: context, forSave: forSave)
            tripUser.updateBy(xmlDictionary: dic)
            tripUserArray.append(tripUser)
        }
        return tripUserArray
    }

    static func delete(context: NSManagedObjectContext, tripUser: TripUser) {
        context.delete(tripUser)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension TripUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TripUser> {
        return NSFetchRequest<TripUser>(entityName: "TripUser");
    }

    @NSManaged public var desc: String?
    @NSManaged public var routeNumber: String?
    @NSManaged public var security1: String?
    @NSManaged public var trip: String?
    @NSManaged public var userName: String?

}
