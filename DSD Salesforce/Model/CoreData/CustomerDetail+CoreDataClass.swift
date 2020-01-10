//
//  CustomerDetail+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class CustomerDetail: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)

        custNo = "0"
        name = ""
        companyTaxID = ""
        city = ""
        address1 = ""
        address2 = ""
        zip = ""
        phone = ""
        location = ""
        routeNo = "0"
        chainNo = "0"
        driverLatitude = "0"
        driverLongitude = "0"
        priceGrp = "0"
        authGrp = "0"
        visitReason = ""
        googlePlaceID = ""
        printType = "0"
        salesDistrict = ""
        orderType = "P"

        shipToState = ""
        shipToZip = ""
        payType = ""
        terms = ""
        orgSeqNo = "0"
        promoPlan = "99999"

        routeNumber = ""
        dayNo = "0"
        deliveryDate = ""
        periodNo = ""
        seqNo = "0"
        startTime1 = "0000"
        endTime1 = "0000"
        startTime2 = "0000"
        endTime2 = "0000"
        tripNumber = ""

        latitude = "0"
        longitude = "0"

        orderNo = 0
        isRouteScheduled = false
        isCompleted = false
        isFromSameNextVisit = false

        visitStartDate = ""
        visitEndDate = ""
        isCustomerUpdated = false
        isRangeChecked = false
        isOrderCreated = false
        isSurveyCompleted = false
        isAssetsChecked = false
        isAssetRequested = false

        arrivalTime = ""
    }

    static func getBy(context: NSManagedObjectContext, chainNo: String, custNo: String) -> CustomerDetail? {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDetail")
        let predicate1 = NSPredicate(format: "chainNo=%@", chainNo)
        let predicate2 = NSPredicate(format: "custNo=%@", custNo)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        request.fetchLimit = 1

        let result = try? context.fetch(request) as? [CustomerDetail]

        if let result = result, let customerDetails = result {
            return customerDetails.first
        }
        return nil
    }

    static func getBy(context: NSManagedObjectContext, type: String, zip: String) -> [CustomerDetail] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDetail")
        let typePredicate = NSPredicate(format: "type=%@", type)
        let zipPredicate1 = NSPredicate(format: "zip=%@", zip)
        let zipPredicate2 = NSPredicate(format: "zip=%@", "")
        let zipPredicate3 = NSPredicate(format: "zip=%@", "0")

        let zipPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [zipPredicate1, zipPredicate2, zipPredicate3])
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [typePredicate, zipPredicate])

        let result = try? context.fetch(request) as? [CustomerDetail]

        if let result = result, let customerDetails = result {
            return customerDetails
        }
        return []
    }

    static func getBy(context: NSManagedObjectContext, type: String) -> [CustomerDetail] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDetail")
        let typePredicate = NSPredicate(format: "type=%@", type)

        request.predicate = typePredicate

        let result = try? context.fetch(request) as? [CustomerDetail]

        if let result = result, let customerDetails = result {
            return customerDetails
        }
        return []
    }

    static func getBy(context: NSManagedObjectContext, substringOfName: String) -> [CustomerDetail] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDetail")
        let predicate1 = NSPredicate(format: "name contains[cd] %@", substringOfName)
        request.predicate = predicate1

        let result = try? context.fetch(request) as? [CustomerDetail]

        if let result = result, let customerDetails = result {
            return customerDetails
        }
        return []
    }

    static func getBy(context: NSManagedObjectContext, substringOfZip: String) -> [CustomerDetail] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDetail")
        let predicate1 = NSPredicate(format: "zip contains[cd] %@", substringOfZip)
        request.predicate = predicate1

        let result = try? context.fetch(request) as? [CustomerDetail]

        if let result = result, let customerDetails = result {
            return customerDetails
        }
        return []
    }

    static func getBy(context: NSManagedObjectContext, substringOfCity: String) -> [CustomerDetail] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDetail")
        let predicate1 = NSPredicate(format: "city contains[cd] %@", substringOfCity)
        request.predicate = predicate1

        let result = try? context.fetch(request) as? [CustomerDetail]

        if let result = result, let customerDetails = result {
            return customerDetails
        }
        return []
    }

    static func getBy(context: NSManagedObjectContext, salesDistrict: String) -> [CustomerDetail] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDetail")
        if salesDistrict != "" {
            let predicate1 = NSPredicate(format: "salesDistrict=%@", salesDistrict)
            request.predicate = predicate1
        }

        let result = try? context.fetch(request) as? [CustomerDetail]

        if let result = result, let customerDetails = result {
            return customerDetails
        }
        return []
    }

    static func getBy(context: NSManagedObjectContext, name: String) -> [CustomerDetail] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDetail")
        let predicate1 = NSPredicate(format: "name=%@", name)
        request.predicate = predicate1

        let result = try? context.fetch(request) as? [CustomerDetail]

        if let result = result, let customerDetails = result {
            return customerDetails
        }
        return []
    }

    static func getBy(context: NSManagedObjectContext, googlePlaceID: String) -> [CustomerDetail] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDetail")
        let predicate1 = NSPredicate(format: "googlePlaceID=%@", googlePlaceID)
        request.predicate = predicate1

        let result = try? context.fetch(request) as? [CustomerDetail]

        if let result = result, let customerDetails = result {
            return customerDetails
        }
        return []
    }

    static func getMaxSeqNo(context: NSManagedObjectContext) -> Int {
        let all = getAll(context: context)
        let sorted = all.sorted { (detail1, detail2) -> Bool in
            let seqNo1 = Int(detail1.seqNo ?? "0") ?? 0
            let seqNo2 = Int(detail2.seqNo ?? "0") ?? 0
            return seqNo1 > seqNo2
        }
        let maxSeqNo = Int(sorted.first?.storeNo ?? "0") ?? 0
        return maxSeqNo
    }

    static func getAll(context: NSManagedObjectContext) -> [CustomerDetail] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDetail")
        let result = try? context.fetch(request) as? [CustomerDetail]

        if let result = result, let customerDetails = result {
            return customerDetails
        }
        return []
    }

    static func getScheduled(context: NSManagedObjectContext, shouldExcludeCompleted: Bool = true) -> [CustomerDetail] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDetail")
        request.returnsObjectsAsFaults = false
        let predicate1 = NSPredicate(format: "isCompleted=false")
        let predicate2 = NSPredicate(format: "isRouteScheduled=true")
        if shouldExcludeCompleted == true {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        }
        else {
            request.predicate = predicate2
        }

        let result = try? context.fetch(request) as? [CustomerDetail]

        if let result = result, let customerDetails = result {
            return customerDetails
        }
        return []
    }

    static func getScheduled(context: NSManagedObjectContext, dayNo: String, shouldExcludeCompleted: Bool = true) -> [CustomerDetail] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDetail")
        request.returnsObjectsAsFaults = false
        let predicate1 = NSPredicate(format: "isCompleted=false")
        let predicate2 = NSPredicate(format: "isRouteScheduled=true")
        let predicate3 = NSPredicate(format: "dayNo=%@", dayNo)
        if shouldExcludeCompleted == true {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2, predicate3])
        }
        else {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate2, predicate3])
        }
        let result = try? context.fetch(request) as? [CustomerDetail]

        if let result = result, let customerDetails = result {
            return customerDetails
        }
        return []
    }

    static func getBy(context: NSManagedObjectContext, nextVisit: String) -> [CustomerDetail] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDetail")
        let predicate1 = NSPredicate(format: "isRouteScheduled=false")
        let predicate2 = NSPredicate(format: "nextVisitDate=%@", nextVisit)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])

        let result = try? context.fetch(request) as? [CustomerDetail]

        if let result = result, let customerDetails = result {
            return customerDetails
        }
        return []
    }

    static func sortByOrder(customerDetailArray: [CustomerDetail]) -> [CustomerDetail] {
        let sorted = customerDetailArray.sorted { (detail1, detail2) -> Bool in
            let orderNo1 = detail1.orderNo
            let orderNo2 = detail2.orderNo
            return orderNo1<orderNo2
        }
        return sorted
    }

    static func sortBySeqNo(customerDetailArray: [CustomerDetail]) -> [CustomerDetail] {
        let sorted = customerDetailArray.sorted { (detail1, detail2) -> Bool in
            let seqNo1 = Int(detail1.seqNo ?? "0") ?? 0
            let seqNo2 = Int(detail2.seqNo ?? "0") ?? 0
            return seqNo1 < seqNo2
        }
        return sorted
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.address1 = xmlDictionary["Address1"] ?? ""
        self.address2 = xmlDictionary["Address2"] ?? ""
        self.chainNo = xmlDictionary["ChainNo"] ?? "0"
        self.city = xmlDictionary["City"] ?? ""
        self.custNo = xmlDictionary["CustNo"] ?? "0"
        self.driverLatitude = xmlDictionary["DriverLatitude"] ?? ""
        self.driverLongitude = xmlDictionary["DriverLongitude"] ?? ""
        self.location = xmlDictionary["Location"] ?? ""
        self.name = xmlDictionary["Name"] ?? ""
        self.orderType = xmlDictionary["OrderType"] ?? "P"
        self.payType = xmlDictionary["PayType"] ?? ""
        self.phone = xmlDictionary["Phone"] ?? ""
        self.priceGrp = xmlDictionary["PriceGrp"] ?? ""
        self.routeNo = xmlDictionary["RouteNo"] ?? ""
        self.terms = xmlDictionary["Terms"] ?? ""
        self.type = xmlDictionary["Type"] ?? ""
        self.creditHold = xmlDictionary["CreditHold"] ?? "0"
        self.shipToState = xmlDictionary["ShipToState"] ?? ""
        self.shipToZip = xmlDictionary["ShipToZip"] ?? ""
        self.delivFreq = xmlDictionary["DeliveryFreq"] ?? "0"
        self.storeNo = xmlDictionary["StoreNo"] ?? ""
        self.zip = xmlDictionary["Zip"] ?? ""
        self.companyTaxID = xmlDictionary["CompanyTaxID"] ?? ""
        //self.seqNo = xmlDictionary["SeqNo"] ?? "0"
        self.orgSeqNo = xmlDictionary["OrgSeqNo"] ?? "0"
        self.promoPlan = xmlDictionary["PromoPlan"] ?? "99999"
        self.authGrp = xmlDictionary["AuthGrp"] ?? "0"
        self.salEntryMode = xmlDictionary["SalEntryMode"] ?? "0"
        self.taxCode = xmlDictionary["TaxCode"] ?? ""
        self.showPrice = xmlDictionary["ShowPrice"] ?? "0"
        self.altCustNo = xmlDictionary["AltCustNo"] ?? ""
        self.billName = xmlDictionary["BillName"] ?? ""
        self.custPriceMaintFlag = xmlDictionary["CustPriceMaintFlag"] ?? ""
        self.featGrp = xmlDictionary["FeatGrp"] ?? "0"
        self.tempGrp = xmlDictionary["TempGrp"] ?? "0"
        self.salesDistrict = xmlDictionary["SalesDistrict"] ?? ""
        self.nextVisitDate = xmlDictionary["NextVisit"] ?? ""

        self.googlePlaceID = xmlDictionary["GooglePlaceID"] ?? ""
        self.printType = xmlDictionary["PrintType"] ?? "0"

        //self.startTime1 = xmlDictionary["StartTime1"] ?? ""
        //self.endTime1 = xmlDictionary["EndTime1"] ?? ""
    }

    func updateByRouteSchedule(xmlDictionary: [String: String]) {

        self.routeNumber = xmlDictionary["RouteNumber"] ?? "0"
        self.dayNo = xmlDictionary["DayNo"] ?? "0"
        self.deliveryDate = xmlDictionary["DeliveryDate"] ?? ""
        self.periodNo = xmlDictionary["PeriodNo"] ?? "0"
        self.seqNo = xmlDictionary["SeqNo"] ?? "0"
        self.startTime1 = Utils.getFormattedTime(original: xmlDictionary["StartTime1"] ?? "")
        self.arrivalTime = startTime1
        self.endTime1 = Utils.getFormattedTime(original: xmlDictionary["EndTime1"] ?? "")
        self.startTime2 = Utils.getFormattedTime(original: xmlDictionary["StartTime2"] ?? "")
        self.endTime2 = Utils.getFormattedTime(original: xmlDictionary["EndTime2"] ?? "")
        self.tripNumber = xmlDictionary["TripNumber"] ?? ""
        self.isRouteScheduled = true
    }

    func updateByGPS(xmlDictionary: [String: String]) {

        self.longitude = xmlDictionary["Longitude"] ?? "0"
        self.latitude = xmlDictionary["Latitude"] ?? "0"
    }

    func updateBy(theSource: CustomerDetail) {

        self.address1 = theSource.address1
        self.address2 = theSource.address2
        self.chainNo = theSource.chainNo
        self.city = theSource.city
        self.custNo = theSource.custNo
        self.driverLatitude = theSource.driverLatitude
        self.driverLongitude = theSource.driverLongitude
        self.location = theSource.location
        self.name = theSource.name
        self.orderType = theSource.orderType
        self.payType = theSource.payType
        self.phone = theSource.phone
        self.priceGrp = theSource.priceGrp
        self.routeNo = theSource.routeNo
        self.terms = theSource.terms
        self.type = theSource.type
        self.creditHold = theSource.creditHold
        self.shipToState = theSource.shipToState
        self.shipToZip = theSource.shipToZip
        self.delivFreq = theSource.delivFreq
        self.storeNo = theSource.storeNo
        self.zip = theSource.zip
        self.companyTaxID = theSource.companyTaxID
        self.orgSeqNo = theSource.orgSeqNo
        self.promoPlan = theSource.promoPlan
        self.authGrp = theSource.authGrp
        self.salEntryMode = theSource.salEntryMode
        self.taxCode = theSource.taxCode
        self.showPrice = theSource.showPrice
        self.altCustNo = theSource.altCustNo
        self.billName = theSource.billName
        self.custPriceMaintFlag = theSource.custPriceMaintFlag
        self.featGrp = theSource.featGrp
        self.tempGrp = theSource.tempGrp
        self.visitReason = theSource.visitReason
        self.nextVisitDate = theSource.nextVisitDate
        self.visitNote = theSource.visitNote
        self.googlePlaceID = theSource.googlePlaceID
        self.printType = theSource.printType

        self.routeNumber = theSource.routeNumber
        self.dayNo = theSource.dayNo
        self.deliveryDate = theSource.deliveryDate
        self.periodNo = theSource.periodNo
        self.seqNo = theSource.seqNo
        self.startTime1 = theSource.startTime1
        self.endTime1 = theSource.endTime1
        self.startTime2 = theSource.startTime2
        self.endTime2 = theSource.endTime2

        self.latitude = theSource.latitude
        self.longitude = theSource.longitude

        self.isRouteScheduled = theSource.isRouteScheduled
        self.isCompleted = theSource.isCompleted
        self.orderNo = theSource.orderNo
        self.isFromSameNextVisit = theSource.isFromSameNextVisit
        self.arrivalTime = theSource.arrivalTime
        
        self.surveys = theSource.surveys
    }
    
    func updateByAfter(theSource: CustomerDetail) {

        self.address1 = theSource.address1
        self.address2 = theSource.address2
        self.chainNo = theSource.chainNo
        self.city = theSource.city
        self.custNo = theSource.custNo
        self.driverLatitude = theSource.driverLatitude
        self.driverLongitude = theSource.driverLongitude
        self.location = theSource.location
        self.name = theSource.name
        self.orderType = theSource.orderType
        self.payType = theSource.payType
        self.phone = theSource.phone
        self.priceGrp = theSource.priceGrp
        self.routeNo = theSource.routeNo
        self.terms = theSource.terms
        self.type = theSource.type
        self.creditHold = theSource.creditHold
        self.shipToState = theSource.shipToState
        self.shipToZip = theSource.shipToZip
        self.delivFreq = theSource.delivFreq
        self.storeNo = theSource.storeNo
        self.zip = theSource.zip
        self.companyTaxID = theSource.companyTaxID
        self.orgSeqNo = theSource.orgSeqNo
        self.promoPlan = theSource.promoPlan
        self.authGrp = theSource.authGrp
        self.salEntryMode = theSource.salEntryMode
        self.taxCode = theSource.taxCode
        self.showPrice = theSource.showPrice
        self.altCustNo = theSource.altCustNo
        self.billName = theSource.billName
        self.custPriceMaintFlag = theSource.custPriceMaintFlag
        self.featGrp = theSource.featGrp
        self.tempGrp = theSource.tempGrp
        self.visitReason = theSource.visitReason
        self.nextVisitDate = theSource.nextVisitDate
        self.visitNote = theSource.visitNote
        self.googlePlaceID = theSource.googlePlaceID
        self.printType = theSource.printType

        self.routeNumber = theSource.routeNumber
        self.dayNo = theSource.dayNo
        self.deliveryDate = theSource.deliveryDate
        self.periodNo = theSource.periodNo
        self.seqNo = theSource.seqNo
        self.startTime1 = theSource.startTime1
        self.endTime1 = theSource.endTime1
        self.startTime2 = theSource.startTime2
        self.endTime2 = theSource.endTime2

        self.latitude = theSource.latitude
        self.longitude = theSource.longitude

        self.isRouteScheduled = theSource.isRouteScheduled
        self.isCompleted = theSource.isCompleted
        self.orderNo = theSource.orderNo
        self.isFromSameNextVisit = theSource.isFromSameNextVisit
        self.arrivalTime = theSource.arrivalTime
        
    }

    func fillSurveys(context: NSManagedObjectContext, surveyArray: [Survey]) {

        let chainNo = self.chainNo ?? "0"
        let custNo = self.custNo ?? "0"

        for survey in surveyArray {
            let surveyChainNo = survey.chainNo ?? "0"
            let surveyCustNo = survey.custNo ?? "0"
            let createDate = survey.createDate ?? ""
            let completionDate = survey.completionDate ?? ""
            let surveyType = survey.surveyType ?? ""
            let today = Date().toDateString(format: kTightJustDateFormat) ?? ""
            if createDate == "" || completionDate == "" {
                continue
            }
            if createDate > today || completionDate < today {
                continue
            }
            if surveyType == "98" || surveyType == "99" {
                continue
            }
            if surveyChainNo == "0" && surveyCustNo == "0" {
                let newSurvey = Survey(context: context, forSave: true)
                newSurvey.updateBy(theSource: survey)
                newSurvey.customerDetail = self
            }
            else {
                if surveyChainNo == chainNo && surveyCustNo == custNo {
                    let newSurvey = Survey(context: context, forSave: true)
                    newSurvey.updateBy(theSource: survey)
                    newSurvey.customerDetail = self
                }
            }
        }
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [CustomerDetail] {

        // deleteAll(context: context)
        deleteAllExceptForVisitPlanned(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "CUSTDETL", xPath: "//CustDetl/Records/CustDetl")
        var customerDetailArray = [CustomerDetail]()
        for dic in dicArray {
            let customerDetail = CustomerDetail(context: context, forSave: forSave)
            customerDetail.updateBy(xmlDictionary: dic)
            customerDetailArray.append(customerDetail)
        }

        // update by CustomerGPS
        let customerGPSDicArray = Utils.loadFromXML(xmlName: "CUSTGPS", xPath: "//CustGPS/Records/CustGPS")
        for customerGPSDic in customerGPSDicArray {
            let chainNo = customerGPSDic["ChainNo"] ?? "0"
            let custNo = customerGPSDic["CustNo"] ?? "0"
            guard let customerDetail = getBy(context: context, chainNo: chainNo, custNo: custNo) else {continue}
            customerDetail.updateByGPS(xmlDictionary: customerGPSDic)
        }


        // update by RouteSch
        let routeScheduleDicArray = Utils.loadFromXML(xmlName: "ROUTESCH", xPath: "//RouteSch/Records/RouteSch")
        for routeScheduleDic in routeScheduleDicArray {
            let chainNo = routeScheduleDic["ChainNo"] ?? "0"
            let custNo = routeScheduleDic["CustNo"] ?? "0"
            guard let customerDetail = getBy(context: context, chainNo: chainNo, custNo: custNo) else {continue}
            let newCustomerDetail = CustomerDetail(managedObjectContext: context)

            newCustomerDetail.updateBy(theSource: customerDetail)
            newCustomerDetail.updateByRouteSchedule(xmlDictionary: routeScheduleDic)
            newCustomerDetail.orderNo = Int32(customerDetail.seqNo ?? "0") ?? 0
            newCustomerDetail.isFromSameNextVisit = false

            customerDetailArray.append(newCustomerDetail)
        }

        GlobalInfo.saveCache()

        // add customers by same next visit
        let todayString = Date().toDateString(format: kTightJustDateFormat) ?? ""
        var sameVisitArray = CustomerDetail.getBy(context: context, nextVisit: todayString)
        sameVisitArray = sameVisitArray.filter({ (customerDetail) -> Bool in
            return customerDetail.isRouteScheduled == false
        })
        sameVisitArray = sameVisitArray.sorted(by: { (customer1, customer2) -> Bool in
            let name1 = customer1.name ?? ""
            let name2 = customer2.name ?? ""
            return name1 < name2
        })
        for (index, customerDetail) in sameVisitArray.enumerated() {
            let newCustomerDetail = CustomerDetail(context: context)
            newCustomerDetail.updateBy(theSource: customerDetail)
            newCustomerDetail.seqNo = "\(index - sameVisitArray.count)"
            newCustomerDetail.isFromSameNextVisit = true
            newCustomerDetail.isRouteScheduled = true
            customerDetailArray.append(newCustomerDetail)
        }

        return customerDetailArray
    }

    static func delete(context: NSManagedObjectContext, customerDetail: CustomerDetail) {
        context.delete(customerDetail)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

    static func deleteAllExceptForVisitPlanned(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            if object.isVisitPlanned == false {
                context.delete(object)
            }
        }
    }

    func getCustomerTitle() -> String {
        
        var itemArray = [String]()
        let name = self.name ?? ""
        if name.isEmpty == false {
            itemArray.append(name)
        }

        let city = self.city ?? ""
        if city.isEmpty == false {
            itemArray.append(city)
        }

        let shipToState = self.shipToState ?? ""
        if shipToState.isEmpty == false {
            itemArray.append(shipToState)
        }

        let shipToZip = self.shipToZip ?? ""
        if shipToZip.isEmpty == false {
            itemArray.append(shipToZip)
        }

        return itemArray.joined(separator: ", ")
    }

    func getCustomerTag() -> String {
        let chainNo = self.chainNo ?? "0"
        let custNo = self.custNo ?? "0"
        if chainNo == "0" {
            return custNo
        }
        else {
            return chainNo + "/" + custNo
        }
    }

    func getTotalAddress() -> String {
        
        let address1 = self.address1 ?? ""
        let address2 = self.address2 ?? ""
        let city = self.city ?? ""
        var address1Array = [String]()
        var address2Array = [String]()
        var totalAddressArray = [String]()

        if address1.isEmpty == false {
            address1Array.append(address1)
        }
        if city.isEmpty == false {
            address1Array.append(city)
        }
        let addressLine1 = address1Array.joined(separator: ", ")
        if addressLine1.isEmpty == false {
            totalAddressArray.append(addressLine1)
        }

        if address2.isEmpty == false {
            address2Array.append(address2)
            if city.isEmpty == false {
                address2Array.append(city)
            }
            let addressLine2 = address2Array.joined(separator: ", ")
            if addressLine2.isEmpty == false {
                totalAddressArray.append(addressLine2)
            }
        }
        return totalAddressArray.joined(separator: "\n")
    }

    func getImageName() -> String {
        let custNo = Int(self.custNo ?? "0") ?? 0
        let chainNo = Int(self.chainNo ?? "0") ?? 0
        let custNoString = custNo.toLeftPaddedString(digitCount: 9) ?? ""
        let chainNoString = chainNo.toLeftPaddedString(digitCount: 5) ?? ""
        return "\(chainNoString)_\(custNoString).jpg"
    }

    func getSummaryType() -> String {
        let payType = self.payType ?? ""
        switch payType {
        case "1", "2", "3", "$":
            return kCustomerSummaryCod
        case "4", "5", "C":
            return kCustomerSummaryAccount
        case "6":
            return kCustomerSummaryPayOnOrder
        default:
            return kCustomerSummaryCod
        }
    }

}

extension CustomerDetail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CustomerDetail> {
        return NSFetchRequest<CustomerDetail>(entityName: "CustomerDetail");
    }

    @NSManaged public var address1: String?
    @NSManaged public var address2: String?
    @NSManaged public var chainNo: String?
    @NSManaged public var city: String?
    @NSManaged public var custNo: String?
    @NSManaged public var driverLatitude: String?
    @NSManaged public var driverLongitude: String?
    @NSManaged public var location: String?
    @NSManaged public var name: String?
    @NSManaged public var orderType: String?
    @NSManaged public var payType: String?
    @NSManaged public var phone: String?
    @NSManaged public var priceGrp: String?
    @NSManaged public var routeNo: String?
    @NSManaged public var terms: String?
    @NSManaged public var type: String?
    @NSManaged public var creditHold: String?
    @NSManaged public var shipToState: String?
    @NSManaged public var shipToZip: String?
    @NSManaged public var delivFreq: String?
    @NSManaged public var storeNo: String?
    @NSManaged public var zip: String?
    @NSManaged public var promoPlan: String?
    @NSManaged public var authGrp: String?
    @NSManaged public var salEntryMode: String?
    @NSManaged public var taxCode: String?
    @NSManaged public var showPrice: String?
    @NSManaged public var altCustNo: String?
    @NSManaged public var billName: String?
    @NSManaged public var custPriceMaintFlag: String?
    @NSManaged public var featGrp: String?
    @NSManaged public var tempGrp: String?
    @NSManaged public var visitReason: String?
    @NSManaged public var nextVisitDate: String?
    @NSManaged public var visitNote: String?
    @NSManaged public var googlePlaceID: String?
    @NSManaged public var printType: String?
    @NSManaged public var salesDistrict: String?

    // route schedule
    @NSManaged public var routeNumber: String?
    @NSManaged public var dayNo: String?
    @NSManaged public var deliveryDate: String?
    @NSManaged public var periodNo: String?
    @NSManaged public var seqNo: String?
    @NSManaged public var startTime1: String?
    @NSManaged public var endTime1: String?
    @NSManaged public var startTime2: String?
    @NSManaged public var endTime2: String?
    @NSManaged public var tripNumber: String?

    @NSManaged public var companyTaxID: String?
    @NSManaged public var orgSeqNo: String?

    // customer gps
    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?

    // etc
    @NSManaged public var orderNo: Int32
    @NSManaged public var isRouteScheduled: Bool
    @NSManaged public var isCompleted: Bool
    @NSManaged public var isFromSameNextVisit: Bool
    @NSManaged public var arrivalTime: String?

    // for visit upload
    @NSManaged public var visitStartDate: String?
    @NSManaged public var visitEndDate: String?
    @NSManaged public var isCustomerUpdated: Bool
    @NSManaged public var isRangeChecked: Bool
    @NSManaged public var isOrderCreated: Bool
    @NSManaged public var isSurveyCompleted: Bool
    @NSManaged public var isAssetsChecked: Bool
    @NSManaged public var isAssetRequested: Bool

    // for visit
    @NSManaged public var isVisitPlanned: Bool

    @NSManaged public var surveys: NSOrderedSet?
}

extension CustomerDetail {

    var surveySet: NSMutableOrderedSet {
        return self.mutableOrderedSetValue(forKey: "surveys")
    }
}
