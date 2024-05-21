//
//  UploadService+CoreDataClass.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class UploadService: NSManagedObject {

    static var keyArray = ["TrxnNo", "ChainNo", "CustNo", "Period", "Seq", "Done", "Reason", "TrxnDate", "TrxnTime", "aTrxnNo", "aDocNo",   "DocType", "VoidFlag", "PrintedFlag", "aTrxnDate", "aTrxnTime", "Reference", "TCOMStatus", "SaleDate"]

    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
    }

    static func getBy(context: NSManagedObjectContext, chainNo: String, custNo: String) -> UploadService? {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UploadService")
        let predicate1 = NSPredicate(format: "chainNo=%@", chainNo)
        let predicate2 = NSPredicate(format: "custNo=%@", custNo)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        request.fetchLimit = 1

        let result = try? context.fetch(request) as? [UploadService]

        if let result = result, let uploadServices = result {
            return uploadServices.first
        }
        return nil
    }

    static func getAll(context: NSManagedObjectContext) -> [UploadService] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UploadService")
        let result = try? context.fetch(request) as? [UploadService]

        if let result = result, let uploadServices = result {
            return uploadServices
        }
        return []
    }

    static func delete(context: NSManagedObjectContext, uploadService: UploadService) {
        context.delete(uploadService)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

    func getDictionary() -> [String: String] {
        var dic = [String: String]()
        dic["TrxnNo"] = trxnNo
        dic["ChainNo"] = chainNo
        dic["CustNo"] = custNo
        dic["Period"] = period
        dic["Seq"] = seq
        dic["Done"] = done
        dic["Reason"] = reason
        dic["TrxnDate"] = trxnDate
        dic["TrxnTime"] = trxnTime
        dic["aTrxnNo"] = aTrxnNo
        dic["aDocNo"] = aDocNo
        dic["DocType"] = docType
        dic["VoidFlag"] = voidFlag
        dic["PrintedFlag"] = printedFlag
        dic["aTrxnDate"] = aTrxnDate
        dic["aTrxnTime"] = aTrxnTime
        dic["Reference"] = reference
        dic["TCOMStatus"] = tCOMStatus
        dic["SaleDate"] = saleDate
        return dic
    }

    static func make(chainNo: String, custNo: String, docType: String, date: Date, reason: String, done: String) -> UploadService {

        let trxnDate = date.toDateString(format: kTightJustDateFormat) ?? ""
        let trxnTime = date.toDateString(format: kTightJustTimeFormat) ?? ""
        let trxnNo = "\(date.getTimestamp())"

        let managedObjectContext = GlobalInfo.shared.managedObjectContext!
        var uService: UploadService!
        if let oldService = UploadService.getBy(context: managedObjectContext, chainNo: chainNo, custNo: custNo) {
            uService = oldService
        }
        else {
            uService = UploadService(context: managedObjectContext)
        }

        uService.trxnNo = trxnNo
        uService.chainNo = chainNo
        uService.custNo = custNo
        uService.period = "0"
        uService.seq = "0"
        uService.done = done
        uService.reason = reason
        uService.trxnDate = trxnDate
        uService.trxnTime = trxnTime
        uService.aTrxnNo = trxnNo
        uService.aDocNo = "0"
        uService.docType = docType
        uService.voidFlag = "0"
        uService.printedFlag = "0"
        uService.aTrxnDate = trxnDate
        uService.aTrxnTime = trxnTime
        uService.reference = ""
        uService.tCOMStatus = "0"
        uService.saleDate = trxnDate
        return uService
    }

    func makeTransaction() -> UTransaction {
        let trxnNoString = self.trxnNo ?? ""
        let trxnNo = Int64(trxnNoString) ?? 0
        let date = Date.fromTimeStamp(timeStamp: trxnNo)
        let globalInfo = GlobalInfo.shared
        let trip = globalInfo.routeControl?.trip ?? ""
        return UTransaction.make(chainNo: chainNo!, custNo: custNo!, docType: docType!, date: date, reference: "", trip: trip)
    }

    static func saveToXML(uServiceArray: [UploadService], filePath: String) {
        var dicArray = [[String: String]]()
        for uService in uServiceArray {
            let dictionary = uService.getDictionary()
            dicArray.append(dictionary)
        }
        Utils.saveToXML(dicArray: dicArray, keyArray: keyArray, rootName: "Services", branchName: "Service", filePath: filePath)
    }

    static func saveToXML(uServiceArray: [UploadService]) -> String {
        if uServiceArray.count == 0 {
            return ""
        }
        let nowString = Date().toDateString(format: kTightFullDateFormat) ?? ""
        let fileName = "Services\(nowString).upl"
        let filePath = CommData.getFilePathAppended(byCacheDir: fileName) ?? ""
        saveToXML(uServiceArray: uServiceArray, filePath: filePath)
        return filePath
    }

}

extension UploadService {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UploadService> {
        return NSFetchRequest<UploadService>(entityName: "UploadService");
    }

    @NSManaged public var trxnNo: String?
    @NSManaged public var chainNo: String?
    @NSManaged public var custNo: String?
    @NSManaged public var period: String?
    @NSManaged public var seq: String?
    @NSManaged public var done: String?
    @NSManaged public var reason: String?
    @NSManaged public var trxnDate: String?
    @NSManaged public var trxnTime: String?
    @NSManaged public var aTrxnNo: String?
    @NSManaged public var aDocNo: String?
    @NSManaged public var docType: String?
    @NSManaged public var voidFlag: String?
    @NSManaged public var printedFlag: String?
    @NSManaged public var aTrxnDate: String?
    @NSManaged public var aTrxnTime: String?
    @NSManaged public var reference: String?
    @NSManaged public var tCOMStatus: String?
    @NSManaged public var saleDate: String?
}

