//
//  UOrderHeader.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 9/1/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class OrderHeader: NSManagedObject {

    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
        trxnNo = "0"
        docNo = "0"
        chainNo = "0"
        custNo = "0"
        orderNo = ""
        dayNo = "0"
        trxnDate = ""
        trxnTime = ""
        totalAmount = 0
        totalDump = 0
        totalBuyback = 0
        totalFree = 0
        totalSale = 0
        reference = ""
        specialInstruments = ""
        distributor = ""
        poReference = ""
        deliveryDate = ""
        orderName = ""
        user1 = ""
        user2 = ""
        presoldChgd = ""
        totalSamples = 0
        dDiscSales = 0
        dSaleAmount = 0
        dTaxAmount = 0
        dPromotionAmount = 0
        pickupAmount = 0
        saleAmount = 0
        taxAmount = 0
        promotionAmount = 0
        signatureFilePath = ""
        printedFlag = "0"
        voidFlag = "0"
        isCentsRound = false
        isPrinted = false
        isUploaded = false
        periodNo = "0"
        orderType = "0"
        dTotalAmount = 0
        dTotalDumps = 0
        dTotalBuybacks = 0
        dTotalFree = 0

        invoiceUpload = ""
        photoUpload = ""
        zipUpload = ""

        fulfilby = ""

        realPayment = 0

        isSaved = false
        isPostponed = false
    }

    static func getBy(context: NSManagedObjectContext, chainNo: String, custNo: String) -> [OrderHeader] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderHeader")
        let predicate1 = NSPredicate(format: "chainNo=%@", chainNo)
        let predicate2 = NSPredicate(format: "custNo=%@", custNo)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])

        let result = try? context.fetch(request) as? [OrderHeader]

        if let result = result, let orderHeaderArray = result {
            let ordered = orderHeaderArray.sorted { (orderHeader1, orderHeader2) -> Bool in
                let orderNo1 = orderHeader1.orderNo!
                let orderNo2 = orderHeader2.orderNo!
                return orderNo1 < orderNo2
            }
            return ordered
        }
        return []
    }

    static func getAll(context: NSManagedObjectContext) -> [OrderHeader] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderHeader")
        let result = try? context.fetch(request) as? [OrderHeader]

        if let result = result, let orderHeaderArray = result {
            return orderHeaderArray
        }
        return []
    }

    func updateBy(context: NSManagedObjectContext, theSource: OrderHeader) {

        self.trxnNo = theSource.trxnNo
        self.docNo = theSource.docNo
        self.chainNo = theSource.chainNo
        self.custNo = theSource.custNo
        self.orderNo = theSource.orderNo
        self.dayNo = theSource.dayNo
        self.trxnDate = theSource.trxnDate
        self.trxnTime = theSource.trxnTime
        self.totalAmount = theSource.totalAmount
        self.totalDump = theSource.totalDump
        self.totalSale = theSource.totalSale

        self.totalBuyback = theSource.totalBuyback
        self.totalFree = theSource.totalFree
        self.reference = theSource.reference
        self.specialInstruments = theSource.specialInstruments
        self.distributor = theSource.distributor
        self.poReference = theSource.poReference
        self.deliveryDate = theSource.deliveryDate
        self.orderName = theSource.orderName
        self.user1 = theSource.user1
        self.user2 = theSource.user2

        self.presoldChgd = theSource.presoldChgd
        self.totalSamples = theSource.totalSamples
        self.dDiscSales = theSource.dDiscSales
        self.dSaleAmount = theSource.dSaleAmount
        self.dTaxAmount = theSource.dTaxAmount
        self.dPromotionAmount = theSource.dPromotionAmount
        self.saleAmount = theSource.saleAmount
        self.pickupAmount = theSource.pickupAmount
        self.taxAmount = theSource.taxAmount
        self.promotionAmount = theSource.promotionAmount
        self.signatureFilePath = theSource.signatureFilePath
        self.printedFlag = theSource.printedFlag
        self.voidFlag = theSource.voidFlag
        self.isCentsRound = theSource.isCentsRound

        self.isPrinted = theSource.isPrinted
        self.isUploaded = theSource.isUploaded
        self.isPostponed = theSource.isPostponed
        self.periodNo = theSource.periodNo
        self.orderType = theSource.orderType
        self.dTotalAmount = theSource.dTotalAmount
        self.dTotalDumps = theSource.dTotalDumps
        self.dTotalBuybacks = theSource.dTotalBuybacks
        self.dTotalFree = theSource.dTotalFree

        self.invoiceUpload = theSource.invoiceUpload
        self.photoUpload = theSource.photoUpload
        self.zipUpload = theSource.zipUpload

        self.realPayment = theSource.realPayment
        self.fulfilby = theSource.fulfilby

        deleteOrderDetails(context: context)

        for _orderDetail in theSource.deliverySet {
            let orderDetail = _orderDetail as! OrderDetail
            let newOrderDetail = OrderDetail(context: context, forSave: true)
            newOrderDetail.updateBy(context: context, theSource: orderDetail)
            deliverySet.add(newOrderDetail)
        }
        for _orderDetail in theSource.pickupSet {
            let orderDetail = _orderDetail as! OrderDetail
            let newOrderDetail = OrderDetail(context: context, forSave: true)
            newOrderDetail.updateBy(context: context, theSource: orderDetail)
            pickupSet.add(newOrderDetail)
        }
        for _orderDetail in theSource.sampleSet {
            let orderDetail = _orderDetail as! OrderDetail
            let newOrderDetail = OrderDetail(context: context, forSave: true)
            newOrderDetail.updateBy(context: context, theSource: orderDetail)
            sampleSet.add(newOrderDetail)
        }

        if uar != nil {
            UAR.delete(context: context, uar: uar!)
            uar = nil
        }

        if theSource.uar != nil {
            uar = UAR(context: context, forSave: true)
            uar?.updateBy(context: context, theSource: theSource.uar!)
        }

        if theSource.arHeader != nil {
            arHeader = ARHeader(context: context, forSave: true)
            arHeader?.updateBy(theSource: theSource.arHeader!)
        }
    }

    func saveHeader() {
        self.isSaved = true
        for _orderDetail in deliverySet {
            let orderDetail = _orderDetail as! OrderDetail
            orderDetail.isSaved = true
        }
        for _orderDetail in pickupSet {
            let orderDetail = _orderDetail as! OrderDetail
            orderDetail.isSaved = true
        }
        for _orderDetail in sampleSet {
            let orderDetail = _orderDetail as! OrderDetail
            orderDetail.isSaved = true
        }
    }

    func scheduleUpload() {
        let globalInfo = GlobalInfo.shared
        
        let uploadManager = globalInfo.uploadManager!
        if invoiceUpload != "" {
            let fileNameArray = invoiceUpload.components(separatedBy: ",")
            uploadManager.scheduleUpload(localFileName: fileNameArray[0], remoteFileName: fileNameArray[1], uploadItemType: .normalCustomerFile)
        }
        if photoUpload != "" {
            let fileNameArray = photoUpload.components(separatedBy: ",")
            uploadManager.scheduleUpload(localFileName: fileNameArray[0], remoteFileName: fileNameArray[1], uploadItemType: .normalCustomerFile)
        }
        if zipUpload != "" {
            let fileNameArray = zipUpload.components(separatedBy: ",")
            uploadManager.scheduleUpload(localFileName: fileNameArray[0], remoteFileName: fileNameArray[1], uploadItemType: .normalCustomerFile)
        }
        
        self.isUploaded = true
        self.isPostponed = false
    }

    func deleteUploadFiles() {
        // invoice file
        let invoiceFileNameArray = invoiceUpload.components(separatedBy: ",")
        if invoiceFileNameArray.count == 2 {
            // remove local file
            let filePath = CommData.getFilePathAppended(byCacheDir: invoiceFileNameArray[0])
            CommData.deleteFileIfExist(filePath)
            self.invoiceUpload = ""
        }

        // photo file
        let photoFileNameArray = photoUpload.components(separatedBy: ",")
        if photoFileNameArray.count == 2 {
            // remove local file
            let filePath = CommData.getFilePathAppended(byCacheDir: photoFileNameArray[0])
            CommData.deleteFileIfExist(filePath)
            self.photoUpload = ""
        }

        // zip file
        let zipFileNameArray = zipUpload.components(separatedBy: ",")
        if zipFileNameArray.count == 2 {
            // remove local file
            let filePath = CommData.getFilePathAppended(byCacheDir: zipFileNameArray[0])
            CommData.deleteFileIfExist(filePath)
            self.zipUpload = ""
        }
    }

    static func delete(context: NSManagedObjectContext, orderHeader: OrderHeader) {
        orderHeader.deleteUploadFiles()
        context.delete(orderHeader)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            OrderHeader.delete(context: context, orderHeader: object)
        }
    }

    func deleteOrderDetails(context: NSManagedObjectContext) {

        for _orderDetails in deliverySet {
            let orderDetail = _orderDetails as! OrderDetail
            OrderDetail.delete(context: context, orderDetail: orderDetail)
        }
        for _orderDetails in pickupSet {
            let orderDetail = _orderDetails as! OrderDetail
            OrderDetail.delete(context: context, orderDetail: orderDetail)
        }
        for _orderDetails in sampleSet {
            let orderDetail = _orderDetails as! OrderDetail
            OrderDetail.delete(context: context, orderDetail: orderDetail)
        }
        deliverySet.removeAllObjects()
        pickupSet.removeAllObjects()
        sampleSet.removeAllObjects()
    }
}

extension OrderHeader {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OrderHeader> {
        return NSFetchRequest<OrderHeader>(entityName: "OrderHeader");
    }

    @NSManaged public var trxnNo: String!
    @NSManaged public var docNo: String!
    @NSManaged public var chainNo: String!
    @NSManaged public var custNo: String!
    @NSManaged public var orderNo: String!
    @NSManaged public var dayNo: String!
    @NSManaged public var trxnDate: String!
    @NSManaged public var trxnTime: String!
    @NSManaged public var totalAmount: Int32
    @NSManaged public var totalSale: Int32
    @NSManaged public var totalDump: Int32
    @NSManaged public var totalBuyback: Int32
    @NSManaged public var totalFree: Int32
    @NSManaged public var reference: String!
    @NSManaged public var specialInstruments: String!
    @NSManaged public var distributor: String!
    @NSManaged public var poReference: String!
    @NSManaged public var deliveryDate: String!
    @NSManaged public var orderName: String!
    @NSManaged public var user1: String!
    @NSManaged public var user2: String!
    @NSManaged public var presoldChgd: String!
    @NSManaged public var totalSamples: Int32
    @NSManaged public var dDiscSales: Double
    @NSManaged public var dSaleAmount: Double
    @NSManaged public var dTaxAmount: Double
    @NSManaged public var dPromotionAmount: Double
    @NSManaged public var saleAmount: Double
    @NSManaged public var pickupAmount: Double
    @NSManaged public var taxAmount: Double
    @NSManaged public var promotionAmount: Double
    @NSManaged public var signatureFilePath: String!
    @NSManaged public var printedFlag: String!
    @NSManaged public var voidFlag: String!
    @NSManaged public var isCentsRound: Bool
    @NSManaged public var isPrinted: Bool
    @NSManaged public var isUploaded: Bool
    @NSManaged public var periodNo: String!
    @NSManaged public var orderType: String!
    @NSManaged public var dTotalAmount: Double
    @NSManaged public var dTotalDumps: Double
    @NSManaged public var dTotalBuybacks: Double
    @NSManaged public var dTotalFree: Double
    @NSManaged public var invoiceUpload: String!
    @NSManaged public var photoUpload: String!
    @NSManaged public var zipUpload: String!
    @NSManaged public var realPayment: Double
    @NSManaged public var fulfilby: String!

    @NSManaged public var isSaved: Bool
    @NSManaged public var isPostponed: Bool

    @NSManaged public var uar: UAR?
    @NSManaged public var arHeader: ARHeader?

    @NSManaged public var deliverys: NSOrderedSet?
    @NSManaged public var pickups: NSOrderedSet?
    @NSManaged public var samples: NSOrderedSet?

    var deliverySet: NSMutableOrderedSet {
        return self.mutableOrderedSetValue(forKey: "deliverys")
    }
    var pickupSet: NSMutableOrderedSet {
        return self.mutableOrderedSetValue(forKey: "pickups")
    }
    var sampleSet: NSMutableOrderedSet {
        return self.mutableOrderedSetValue(forKey: "samples")
    }
}

