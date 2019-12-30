//
//  RouteControl+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class RouteControl: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)

        treeDesc = ""
        invoiceNum = ""
        invoiceNumFormat = "RRRYJJJSSS"
        profile = ""
        orderDayWindow = "0"

        visitDuration = "0"
        loconNoGPSLatitude = 0
        loconNoGPSLongitude = 0
    }

    /*
    static func getBy(context: NSManagedObjectContext, custNo: String) -> RouteSchedule? {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RouteSchedule")
        request.predicate = NSPredicate(format: "custNo=%@", custNo)
        request.fetchLimit = 1

        let result = try? context.fetch(request) as? [CustomerDetail]

        if let result = result, let customerDetails = result {
            return customerDetails.first
        }
        return nil
    }*/

    static func getAll(context: NSManagedObjectContext) -> [RouteControl] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RouteControl")
        let result = try? context.fetch(request) as? [RouteControl]

        if let result = result, let routeControls = result {
            return routeControls
        }
        return []
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.company = xmlDictionary["COMPANY"] ?? ""
        self.desc = xmlDictionary["Description"] ?? ""
        self.routeNumber = xmlDictionary["RouteNumber"] ?? "0"
        self.security1 = xmlDictionary["Security1"] ?? ""
        self.security2 = xmlDictionary["Security2"] ?? ""
        self.security3 = xmlDictionary["Security3"] ?? ""
        self.security4 = xmlDictionary["Security4"] ?? ""
        self.security5 = xmlDictionary["Security5"] ?? ""
        self.trip = xmlDictionary["Trip"] ?? ""
        self.tripUser = xmlDictionary["TRIPUSER"] ?? ""
        self.userName = xmlDictionary["UserName"] ?? ""
        self.tempCustChain = xmlDictionary["TEMPCUSTCHAIN"] ?? ""
        self.tempCustPrefix = xmlDictionary["TEMPCUSTPREFIX"] ?? ""
        self.templateChain = xmlDictionary["TEMPLATECHAIN"] ?? "0"
        self.templateCustomer = xmlDictionary["TEMPLATECUSTOMER"] ?? "0"
        self.primeContact = xmlDictionary["PRIMECONTACT"] ?? "0"
        self.gpsPoll = xmlDictionary["GPSPOLL"] ?? "0"
        self.equipCheck = xmlDictionary["EQUIPCHECK"] ?? "9"
        self.treeDesc = xmlDictionary["TreeDesc"] ?? ""
        self.inventoryUOM = xmlDictionary["INVENTORYUOM"] ?? ""
        self.currencySymbol = xmlDictionary["CurrencySymbol"] ?? "$"
        self.uploadInvFmt = xmlDictionary["UPLOADINVFMT"] ?? ""
        self.centsRound = xmlDictionary["CENTSROUND"] ?? ""
        self.orderFulfil = xmlDictionary["OrderFulFil"] ?? "W"
        self.printType = xmlDictionary["PRINTTYPE"] ?? "0"
        self.defLocNo = xmlDictionary["DefLocnNo"] ?? ""
        self.vehicleInventory = xmlDictionary["VehicleInventory"] ?? "0"
        self.profile = xmlDictionary["Profile"] ?? ""
        self.orderDayWindow = xmlDictionary["OrderDayWindow"] ?? "0"
        self.vehicleNumber = xmlDictionary["VehicleNumber"] ?? ""
        self.routificAPI = xmlDictionary["ROUTIFICAPI"] ?? ""
        self.visitDuration = xmlDictionary["VISITDURATION"] ?? "0"
        self.cardProc = xmlDictionary["CARDPROC"] ?? "0"
        self.visitNotes = xmlDictionary["VisitNotes"] ?? "0"
        self.ewayAPI = xmlDictionary["EWAY_API"] ?? ""
        self.ewaySystem = xmlDictionary["EWAY_SYSTEM"] ?? ""
        self.rapidAPIKey = xmlDictionary["RAPIDAPIKEY"] ?? ""
        self.rapidAPIPwd = xmlDictionary["RAPIDAPIPWD"] ?? ""
        self.paymentAdjust = xmlDictionary["PAYMENTADJUST"] ?? ""
        self.adjustAllow = xmlDictionary["ADJUSTALLOW"] ?? ""
        
        self.custaddNew = xmlDictionary["CUSTADDNEW"] ?? "0"
        self.catalog = xmlDictionary["CATALOG"] ?? ""
        
        self.prodSearchDef = xmlDictionary["PRODSEARCHDEF"] ?? ""

        let locnNoGPS = xmlDictionary["LocnNoGPS"] ?? ""
        let parts = locnNoGPS.components(separatedBy: ",")
        if parts.count == 2 {
            let latitude = Double(parts[0]) ?? 0
            let longitude = Double(parts[1]) ?? 0
            self.loconNoGPSLatitude = latitude
            self.loconNoGPSLongitude = longitude
        }

        let invoiceNum = xmlDictionary["INVOICENUM"] ?? "0"
        if invoiceNum.isEmpty == false && invoiceNum != "0" {
            if invoiceNum.contains("U") == true {
                self.invoiceNum = invoiceNum
            }
            else {
                self.invoiceNumFormat = invoiceNum
            }
        }

    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [RouteControl] {
        
        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "ROUTECTL", xPath: "//RouteCtl/Records/RouteCtl")
        var routeControlArray = [RouteControl]()
        for dic in dicArray {
            let routeControl = RouteControl(context: context, forSave: forSave)
            routeControl.updateBy(xmlDictionary: dic)
            routeControlArray.append(routeControl)
        }
        return routeControlArray
    }

    static func delete(context: NSManagedObjectContext, routeControl: RouteControl) {
        context.delete(routeControl)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }
}

extension RouteControl {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RouteControl> {
        return NSFetchRequest<RouteControl>(entityName: "RouteControl");
    }

    @NSManaged public var company: String?
    @NSManaged public var desc: String?
    @NSManaged public var routeNumber: String?
    @NSManaged public var security1: String?
    @NSManaged public var security2: String?
    @NSManaged public var security3: String?
    @NSManaged public var security4: String?
    @NSManaged public var security5: String?
    @NSManaged public var trip: String?
    @NSManaged public var tripUser: String?
    @NSManaged public var userName: String?
    @NSManaged public var tempCustChain: String?
    @NSManaged public var tempCustPrefix: String?
    @NSManaged public var templateCustomer: String?
    @NSManaged public var templateChain: String?
    @NSManaged public var primeContact: String?
    @NSManaged public var gpsPoll: String?
    @NSManaged public var equipCheck: String?
    @NSManaged public var treeDesc: String?
    @NSManaged public var inventoryUOM: String?
    @NSManaged public var currencySymbol: String?
    @NSManaged public var uploadInvFmt: String?
    @NSManaged public var centsRound: String?
    @NSManaged public var orderFulfil: String?
    @NSManaged public var printType: String?
    @NSManaged public var defLocNo: String?
    @NSManaged public var vehicleInventory: String?
    @NSManaged public var profile: String?
    @NSManaged public var orderDayWindow: String?
    @NSManaged public var vehicleNumber: String?
    @NSManaged public var routificAPI: String?
    @NSManaged public var loconNoGPSLatitude: Double
    @NSManaged public var loconNoGPSLongitude: Double
    @NSManaged public var visitDuration: String?
    @NSManaged public var cardProc: String?
    @NSManaged public var visitNotes: String?
    @NSManaged public var ewayAPI: String?
    @NSManaged public var ewaySystem: String?
    @NSManaged public var rapidAPIKey: String?
    @NSManaged public var rapidAPIPwd: String?
    @NSManaged public var paymentAdjust: String?
    @NSManaged public var adjustAllow: String?
    
    @NSManaged public var custaddNew: String?
    @NSManaged public var catalog: String?

    @NSManaged public var invoiceNum: String?
    @NSManaged public var invoiceNumFormat: String?
    
    @NSManaged public var prodSearchDef: String?
}
