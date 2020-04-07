//
//  UOrderDetail.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 9/1/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class OrderDetail: NSManagedObject {

    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
        trxnNo = "0"
        trxnType = 0
        custNo = "0"
        locnNo = "0"
        itemNo = ""
        planQty = 0
        enterQty = 0
        price = 0
        lastOrder = ""
        deliveryCount = 0
        creditCount = 0
        reasonCode = "0"
        basePrice = 0
        desc = ""
        shortDesc = ""
        isFromPresoldOrDetail = false
        isFromAuthDetail = false
        isFromOrderHistoryItem = false
        isInProgress = false

        isSaved = false
        orderType = 0
    }

    func isFromOriginal() -> Bool {
        return isFromPresoldOrDetail || isFromAuthDetail || isFromOrderHistoryItem
    }
    
    static func getUnsaved(context: NSManagedObjectContext, isSaved: Bool, custNo: String, isFromPresoldOrDetail: Bool, isFromOrderHistoryItem: Bool) -> [OrderDetail] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderDetail")
        let predicate1 = NSPredicate(format: "isSaved == %@", NSNumber(value: isSaved))
        let predicate2 = NSPredicate(format: "custNo=%@", custNo)
        let predicate3 = NSPredicate(format: "isFromPresoldOrDetail == %@", NSNumber(value: isFromPresoldOrDetail))
        let predicate4 = NSPredicate(format: "isFromOrderHistoryItem == %@", NSNumber(value: isFromOrderHistoryItem))
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2, predicate3, predicate4])
        let result = try? context.fetch(request) as? [OrderDetail]
        
        if let result = result, let orderDetailArray = result {
            return orderDetailArray
        }
        return []
    }
    
    func updateBy(context: NSManagedObjectContext, theSource: OrderDetail) {
        self.trxnNo = theSource.trxnNo
        self.trxnType = theSource.trxnType
        self.custNo = theSource.custNo
        self.locnNo = theSource.locnNo
        self.itemNo = theSource.itemNo
        self.planQty = theSource.planQty
        self.enterQty = theSource.enterQty
        self.price = theSource.price
        self.lastOrder = theSource.lastOrder
        self.deliveryCount = theSource.deliveryCount
        self.creditCount = theSource.creditCount
        self.reasonCode = theSource.reasonCode
        self.basePrice = theSource.basePrice

        self.desc = theSource.desc
        self.shortDesc = theSource.shortDesc
        self.isFromPresoldOrDetail = theSource.isFromPresoldOrDetail
        self.isFromAuthDetail = theSource.isFromAuthDetail
        self.isFromOrderHistoryItem = theSource.isFromOrderHistoryItem
        self.orderType = theSource.orderType

        self.isSaved = theSource.isSaved
        self.isInProgress = theSource.isInProgress
        
        // promotions
        self.deletePromotions(context: context)
        for _promotion in theSource.promotionSet {
            let promotion = _promotion as! UPromotion
            let newPromotion = UPromotion(context: context, forSave: true)
            newPromotion.updateBy(theSource: promotion)
            promotionSet.add(newPromotion)
        }

        // tax rates
        if tax != nil {
            UTax.delete(context: context, tax: tax!)
        }
        self.tax = UTax(context: context, forSave: true)
        if theSource.tax != nil {
            self.tax!.updateBy(theSource: theSource.tax!)
        }
    }

    static func getAll(context: NSManagedObjectContext) -> [OrderDetail] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderDetail")
        let result = try? context.fetch(request) as? [OrderDetail]

        if let result = result, let orderDetailArray = result {
            return orderDetailArray
        }
        return []
    }

    static func delete(context: NSManagedObjectContext, orderDetail: OrderDetail) {
        context.delete(orderDetail)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            OrderDetail.delete(context: context, orderDetail: object)
        }
    }

    func deletePromotions(context: NSManagedObjectContext) {

        for _promotion in promotionSet {
            let promotion = _promotion as! UPromotion
            UPromotion.delete(context: context, promotion: promotion)
        }
        promotionSet.removeAllObjects()
    }

}

extension OrderDetail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OrderDetail> {
        return NSFetchRequest<OrderDetail>(entityName: "OrderDetail");
    }

    @NSManaged public var trxnNo: String!
    @NSManaged public var trxnType: Int32
    @NSManaged public var custNo: String!
    @NSManaged public var locnNo: String!
    @NSManaged public var itemNo: String!
    @NSManaged public var planQty: Int32
    @NSManaged public var enterQty: Int32
    @NSManaged public var price: Double
    @NSManaged public var lastOrder: String!
    @NSManaged public var deliveryCount: Int32
    @NSManaged public var creditCount: Int32
    @NSManaged public var reasonCode: String!
    @NSManaged public var basePrice: Double

    @NSManaged public var desc: String!
    @NSManaged public var shortDesc: String!

    @NSManaged public var isFromPresoldOrDetail: Bool
    @NSManaged public var isFromAuthDetail: Bool
    @NSManaged public var isFromOrderHistoryItem: Bool

    @NSManaged public var isSaved: Bool
    @NSManaged public var isInProgress: Bool
    
    @NSManaged public var orderType: Int32
    @NSManaged public var tax: UTax?
    @NSManaged public var promotions: NSOrderedSet?

    var promotionSet: NSMutableOrderedSet {
        return self.mutableOrderedSetValue(forKey: "promotions")
    }
}
