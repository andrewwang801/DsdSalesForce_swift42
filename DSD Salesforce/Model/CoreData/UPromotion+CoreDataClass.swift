//
//  UPromotion.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 9/1/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class UPromotion: NSManagedObject {

    static var keyArray = ["TrxnNo", "ItemNo", "PlanNo", "AssignNo", "TrxnType", "Amount", "PriceDiscFlag", "ReasonCode", "PromoAppMethod", "PromoType", "PromoMethod", "DiscAmt", "TrxnAmt", "DateStart"]

    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
        trxnNo = ""
        itemNo = ""
        planNo = ""
        assignNo = ""
        trxnType = ""
        amount = ""
        priceDiscFlag = ""
        reasonCode = ""
        promoAppMethod = ""
        promoType = ""
        promoMethod = ""
        discAmt = ""
        trxnAmt = ""
        dateStart = ""
        seqNo = ""
    }

    func updateBy(theSource: UPromotion) {
        self.trxnNo = theSource.trxnNo
        self.itemNo = theSource.itemNo
        self.planNo = theSource.planNo
        self.assignNo = theSource.assignNo
        self.trxnType = theSource.trxnType
        self.amount = theSource.amount
        self.priceDiscFlag = theSource.priceDiscFlag
        self.reasonCode = theSource.reasonCode
        self.promoAppMethod = theSource.promoAppMethod
        self.promoType = theSource.promoType
        self.promoMethod = theSource.promoMethod
        self.discAmt = theSource.discAmt
        self.trxnAmt = theSource.trxnAmt
        self.dateStart = theSource.dateStart
        self.seqNo = theSource.seqNo
    }

    func getDictionary() -> [String: String] {
        var dic = [String: String]()
        dic["TrxnNo"] = trxnNo
        dic["ItemNo"] = itemNo
        dic["PlanNo"] = planNo
        dic["AssignNo"] = assignNo
        dic["TrxnType"] = trxnType
        dic["Amount"] = amount
        dic["PriceDiscFlag"] = priceDiscFlag
        dic["ReasonCode"] = reasonCode
        dic["PromoAppMethod"] = promoAppMethod
        dic["PromoType"] = promoType
        dic["PromoMethod"] = promoMethod
        dic["DiscAmt"] = discAmt
        dic["TrxnAmt"] = trxnAmt
        dic["DateStart"] = dateStart
        return dic
    }

    static func getAll(context: NSManagedObjectContext) -> [UPromotion] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UPromotion")
        let result = try? context.fetch(request) as? [UPromotion]

        if let result = result, let promotionArray = result {
            return promotionArray
        }
        return []
    }

    static func delete(context: NSManagedObjectContext, promotion: UPromotion) {
        context.delete(promotion)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

    static func getPromotionDictionary(context: NSManagedObjectContext, customerDetail: CustomerDetail) -> [String: [UPromotion]] {
        var dictionary = [String: [UPromotion]]()
        var seqNoDictionary = [String: String]()
        var promoHeaderArray = [PromotionHeader]()
        let promoPlan = customerDetail.promoPlan ?? ""
        if promoPlan == "999999" {
            let proMultiArray = ProMulti.getByForToday(context: context, chainNo: customerDetail.chainNo ?? "", custNo: customerDetail.custNo ?? "")
            for proMulti in proMultiArray {
                let planNo = proMulti.planNo ?? ""
                let seqNo = proMulti.seqNo ?? ""
                let multiArray = PromotionHeader.getByForToday(context: context, planNo: planNo)
                promoHeaderArray.append(contentsOf: multiArray)
                seqNoDictionary[planNo] = seqNo
            }
        }
        else {
            promoHeaderArray = PromotionHeader.getByForToday(context: context, planNo: promoPlan)
        }

        for promoHeader in promoHeaderArray {
            let assArray = PromotionAss.getBy(context: context, assignNo: promoHeader.assignNo ?? "")
            let seqNoObject = seqNoDictionary[promoHeader.planNo ?? ""]
            var seqNo = "0"
            if seqNoObject != nil {
                seqNo = seqNoObject!
            }
            for ass in assArray {
                let assignNo = ass.assignNo ?? ""
                let novoArray = PromotionNoVo.getBy(context: context, assignNo: assignNo)
                for novo in novoArray {
                    let itemNo = novo.itemNo ?? ""
                    let promotion = UPromotion(context: context, forSave: true)
                    promotion.trxnNo = ""
                    promotion.itemNo = itemNo
                    promotion.planNo = promoHeader.planNo ?? ""
                    promotion.assignNo = ass.assignNo ?? ""
                    promotion.trxnType = ""
                    promotion.amount = ""
                    promotion.priceDiscFlag = ""
                    promotion.reasonCode = ""
                    promotion.promoAppMethod = ass.promoAppMethod ?? ""
                    promotion.promoType = ass.promoType ?? ""
                    promotion.promoMethod = ass.promoMethod ?? ""
                    promotion.discAmt = novo.promoDiscount ?? ""
                    promotion.trxnAmt = ""
                    promotion.dateStart = promoHeader.dateStart ?? ""
                    promotion.seqNo = seqNo

                    if dictionary[itemNo] == nil {
                        dictionary[itemNo] = [promotion]
                    }
                    else {
                        dictionary[itemNo]!.append(promotion)
                    }
                }
            }
        }
        return dictionary
    }
}

extension UPromotion {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UPromotion> {
        return NSFetchRequest<UPromotion>(entityName: "UPromotion");
    }

    @NSManaged public var trxnNo: String!
    @NSManaged public var itemNo: String!
    @NSManaged public var planNo: String!
    @NSManaged public var assignNo: String!
    @NSManaged public var trxnType: String!
    @NSManaged public var amount: String!
    @NSManaged public var priceDiscFlag: String!
    @NSManaged public var reasonCode: String!
    @NSManaged public var promoAppMethod: String!
    @NSManaged public var promoType: String!
    @NSManaged public var promoMethod: String!
    @NSManaged public var discAmt: String!
    @NSManaged public var trxnAmt: String!
    @NSManaged public var dateStart: String!
    @NSManaged public var seqNo: String!
}
