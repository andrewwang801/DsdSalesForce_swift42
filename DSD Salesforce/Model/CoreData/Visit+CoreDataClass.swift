//
//  Visit.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/31/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import CoreData

public class Visit: NSManagedObject {

    static var keyArray = ["TrxnNo", "DocType", "ChainNo", "CustNo", "TrxnDate", "TrxnTime", "VoidFlag", "PrintedFlag", "Reference", "TCOMStatus", "SaleDate", "VisitStart", "VisitEnd", "VisitReason", "NextVisit", "VisitMessage", "CustomerUpdated", "RangeChecked", "OrderCreated", "SurveyCompleted", "AssetChecked", "AssetRequested", "VisitFrequency", "PreferredVisitDay", "PlannedVisitTime"]

    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
    }

    static func getBy(context: NSManagedObjectContext, chainNo: String, custNo: String) -> Visit? {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Visit")
        let predicate1 = NSPredicate(format: "chainNo=%@", chainNo)
        let predicate2 = NSPredicate(format: "custNo=%@", custNo)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        request.fetchLimit = 1

        let result = try? context.fetch(request) as? [Visit]

        if let result = result, let visits = result {
            return visits.first
        }
        return nil
    }

    static func getAll(context: NSManagedObjectContext) -> [Visit] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Visit")
        let result = try? context.fetch(request) as? [Visit]

        if let result = result, let visits = result {
            return visits
        }
        return []
    }

    static func delete(context: NSManagedObjectContext, visit: Visit) {
        context.delete(visit)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

    func updateBy(theSource: Visit) {
        self.trxnNo = theSource.trxnNo
        self.docType = theSource.docType
        self.chainNo = theSource.chainNo
        self.custNo = theSource.custNo
        self.trxnDate = theSource.trxnDate
        self.trxnTime = theSource.trxnTime
        self.voidFlag = theSource.voidFlag
        self.printedFlag = theSource.printedFlag

        self.reference = theSource.reference
        self.tCOMStatus = theSource.tCOMStatus

        self.saleDate = theSource.saleDate
        self.visitStart = theSource.visitStart
        self.visitEnd = theSource.visitEnd
        self.visitReason = theSource.visitReason
        self.nextVisit = theSource.nextVisit
        self.visitMessage = theSource.visitMessage
        self.customerUpdated = theSource.customerUpdated
        self.rangeChecked = theSource.rangeChecked
        self.orderCreated = theSource.orderCreated
        self.surveyCompleted = theSource.surveyCompleted
        self.assetChecked = theSource.assetChecked
        self.assetRequested = theSource.assetRequested
        self.visitFrequency = theSource.visitFrequency
        self.preferredVisitDay = theSource.preferredVisitDay
        ///SF71
        self.plannedVisitTime = theSource.plannedVisitTime
    }

    func getDictionary() -> [String: String] {
        var dic = [String: String]()
        dic["TrxnNo"] = trxnNo
        dic["DocType"] = docType
        dic["ChainNo"] = chainNo
        dic["CustNo"] = custNo
        dic["TrxnDate"] = trxnDate
        dic["TrxnTime"] = trxnTime

        dic["VoidFlag"] = voidFlag
        dic["PrintedFlag"] = printedFlag
        dic["Reference"] = reference
        dic["TCOMStatus"] = tCOMStatus
        dic["SaleDate"] = saleDate
        dic["VisitStart"] = visitStart
        dic["VisitEnd"] = visitEnd
        dic["VisitReason"] = visitReason
        dic["NextVisit"] = nextVisit
        dic["VisitMessage"] = visitMessage
        dic["CustomerUpdated"] = customerUpdated
        dic["RangeChecked"] = rangeChecked
        dic["OrderCreated"] = orderCreated
        dic["SurveyCompleted"] = surveyCompleted
        dic["AssetChecked"] = assetChecked
        dic["AssetRequested"] = assetRequested
        dic["VisitFrequency"] = visitFrequency
        dic["PreferredVisitDay"] = preferredVisitDay
        ///SF71, 2020-3-13
        dic["PlannedVisitTime"] = plannedVisitTime
        return dic
    }

    static func make(chainNo: String, custNo: String, docType: String, date: Date, customerDetail: CustomerDetail, reference: String) -> Visit {

        let trxnDate = date.toDateString(format: kTightJustDateFormat) ?? ""
        let trxnTime = date.toDateString(format: kTightJustTimeFormat) ?? ""
        let trxnNo = "\(date.getTimestamp())"

        let managedObjectContext = GlobalInfo.shared.managedObjectContext!
        var visit: Visit!
        if let oldVisit = Visit.getBy(context: managedObjectContext, chainNo: chainNo, custNo: custNo) {
            visit = oldVisit
        }
        else {
            visit = Visit(context: managedObjectContext)
        }

        visit.trxnNo = trxnNo
        visit.docType = docType
        visit.chainNo = chainNo
        visit.custNo = custNo
        visit.trxnDate = trxnDate
        visit.trxnTime = trxnTime
        visit.voidFlag = "0"
        visit.printedFlag = "0"
        visit.reference = reference
        visit.tCOMStatus = "0"
        visit.saleDate = trxnDate
        let visitStartDate = Date.fromDateString(dateString: customerDetail.visitStartDate ?? "", format: kTightFullDateFormat)?.toDateString(format: kTightJustTimeFormat) ?? ""
        visit.visitStart = visitStartDate
        let visitEndDate = Date.fromDateString(dateString: customerDetail.visitEndDate ?? "", format: kTightFullDateFormat)?.toDateString(format: kTightJustTimeFormat) ?? ""
        visit.visitEnd = visitEndDate
        visit.visitReason = customerDetail.visitReason ?? ""
        visit.nextVisit = customerDetail.nextVisitDate ?? ""
        visit.visitMessage = customerDetail.visitNote ?? ""
        visit.customerUpdated = customerDetail.isCustomerUpdated.intString
        visit.rangeChecked = customerDetail.isRangeChecked.intString
        visit.orderCreated = customerDetail.isOrderCreated.intString
        visit.surveyCompleted = customerDetail.isSurveyCompleted.intString
        visit.assetChecked = customerDetail.isAssetsChecked.intString
        visit.assetRequested = customerDetail.isAssetRequested.intString
        visit.visitFrequency = String(customerDetail.visitFrequency)
        visit.preferredVisitDay = String(customerDetail.preferredVisitDay)
        ///SF71, 2020-3-13
        visit.plannedVisitTime = customerDetail.plannedVisitTime

        return visit
    }

    func makeTransaction() -> UTransaction {
        let trxnNoString = self.trxnNo ?? "0"
        let trxnNo = Int64(trxnNoString) ?? 0
        let date = Date.fromTimeStamp(timeStamp: trxnNo)
        let globalInfo = GlobalInfo.shared
        let trip = globalInfo.routeControl?.trip ?? ""
        return UTransaction.make(chainNo: self.chainNo ?? "0", custNo: self.custNo ?? "0", docType: self.docType ?? "", date: date, reference: "", trip: trip)
    }

    static func saveToXML(visitArray: [Visit], filePath: String) {
        var dicArray = [[String: String]]()
        for visit in visitArray {
            let dictionary = visit.getDictionary()
            dicArray.append(dictionary)
        }
        Utils.saveToXML(dicArray: dicArray, keyArray: keyArray, rootName: "Visits", branchName: "Visit", filePath: filePath)
    }

    static func saveToXML(visitArray: [Visit]) -> String {
        if visitArray.count == 0 {
            return ""
        }
        let nowString = Date().toDateString(format: kTightFullDateFormat) ?? ""
        let fileName = "Visit\(nowString).upl"
        let filePath = CommData.getFilePathAppended(byDocumentDir: fileName) ?? ""
        saveToXML(visitArray: visitArray, filePath: filePath)
        return filePath
    }

}

extension Visit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Visit> {
        return NSFetchRequest<Visit>(entityName: "Visit");
    }

    @NSManaged public var trxnNo: String?
    @NSManaged public var docType: String?
    @NSManaged public var chainNo: String?
    @NSManaged public var custNo: String?
    @NSManaged public var trxnDate: String?
    @NSManaged public var trxnTime: String?
    @NSManaged public var voidFlag: String?
    @NSManaged public var printedFlag: String?
    @NSManaged public var reference: String?
    @NSManaged public var tCOMStatus: String?
    @NSManaged public var saleDate: String?
    @NSManaged public var visitStart: String?
    @NSManaged public var visitEnd: String?
    @NSManaged public var visitReason: String?
    @NSManaged public var nextVisit: String?
    @NSManaged public var visitMessage: String?
    @NSManaged public var customerUpdated: String?
    @NSManaged public var rangeChecked: String?
    @NSManaged public var orderCreated: String?
    @NSManaged public var surveyCompleted: String?
    @NSManaged public var assetChecked: String?
    @NSManaged public var assetRequested: String?
    @NSManaged public var visitFrequency: String?
    @NSManaged public var preferredVisitDay: String?
    ///SF71, 2020-3-13
    @NSManaged public var plannedVisitTime: String?
}

