//
//  ProductDetail+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class ProductDetail: NSManagedObject {

    static var productDetailDic = [String: ProductDetail]()
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
        self.desc1 = ""
        self.desc2 = ""
        self.desc3 = ""
        self.desc4 = ""
        self.desc5 = ""
        self.desc6 = ""
        self.price = 0
    }

    static func getByFromDic(context: NSManagedObjectContext, itemNo: String) -> ProductDetail? {

        guard let productDetail = productDetailDic[itemNo] else {return nil}
        return productDetail
    }
    
    static func getBy(context: NSManagedObjectContext, itemNo: String) -> ProductDetail? {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ProductDetail")
        request.predicate = NSPredicate(format: "itemNo=%@", itemNo)
        request.fetchLimit = 1

        let result = try? context.fetch(request) as? [ProductDetail]

        if let result = result, let productDetails = result {
            return productDetails.first
        }
        return nil
    }
    
    static func getBy(context: NSManagedObjectContext, itemUPC: String) -> ProductDetail? {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ProductDetail")
        let predicate1 = NSPredicate(format: "itemUPC=%@", itemUPC)
        let predicate2 = NSPredicate(format: "itemUPC20=%@", itemUPC)
        request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate1, predicate2])

        let result = try? context.fetch(request) as? [ProductDetail]

        if let result = result, let productDetailArray = result {
            for productDetail in productDetailArray {
                if productDetail.productLocn != nil {
                    return productDetail
                }
            }
            return nil
        }
        return nil
    }

    static func getBy(context: NSManagedObjectContext, brandArray: [String], subBrandArray: [String], itemTypeArray: [String], productGroupArray: [String], productLineArray: [String], marketGroupArray: [String]) -> [ProductDetail] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ProductDetail")
        var predicateArray = [NSPredicate]()
        if brandArray.count > 0 {
            let subPredicateArray = brandArray.map { (brand) -> NSPredicate in
                return NSPredicate(format: "brand=%@", brand)
            }
            let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: subPredicateArray)
            predicateArray.append(predicate)
        }
        if subBrandArray.count > 0 {
            let subPredicateArray = subBrandArray.map { (subBrand) -> NSPredicate in
                return NSPredicate(format: "subBrand=%@", subBrand)
            }
            let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: subPredicateArray)
            predicateArray.append(predicate)
        }
        if itemTypeArray.count > 0 {
            let subPredicateArray = itemTypeArray.map { (itemType) -> NSPredicate in
                return NSPredicate(format: "itemType=%@", itemType)
            }
            let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: subPredicateArray)
            predicateArray.append(predicate)
        }
        if productGroupArray.count > 0 {
            let subPredicateArray = productGroupArray.map { (productGroup) -> NSPredicate in
                return NSPredicate(format: "prodGrp=%@", productGroup)
            }
            let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: subPredicateArray)
            predicateArray.append(predicate)
        }
        if productLineArray.count > 0 {
            let subPredicateArray = productLineArray.map { (productLine) -> NSPredicate in
                return NSPredicate(format: "prodLine=%@", productLine)
            }
            let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: subPredicateArray)
            predicateArray.append(predicate)
        }
        if marketGroupArray.count > 0 {
            let subPredicateArray = marketGroupArray.map { (marketGroup) -> NSPredicate in
                return NSPredicate(format: "marketGrp=%@", marketGroup)
            }
            let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: subPredicateArray)
            predicateArray.append(predicate)
        }

        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicateArray)

        let result = try? context.fetch(request) as? [ProductDetail]

        if let result = result, let productDetailArray = result {
            let filtered = productDetailArray.filter { (productDetail) -> Bool in
                return productDetail.productLocn != nil
            }
            return filtered
        }
        return []
    }

    /*
    static func getBy(context: NSManagedObjectContext, itemUPC: String) -> ProductDetail? {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ProductDetail")
        request.predicate = NSPredicate(format: "itemNo=%@", itemNo)
        request.fetchLimit = 1

        let result = try? context.fetch(request) as? [ProductDetail]

        if let result = result, let productDetails = result {
            return productDetails.first
        }
        return nil
    }*/

    static func getAll(context: NSManagedObjectContext) -> [ProductDetail] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ProductDetail")
        let result = try? context.fetch(request) as? [ProductDetail]

        if let result = result, let productDetails = result {
            return productDetails
        }
        return []
    }

    static func getProductItemDictionary(context: NSManagedObjectContext) -> [String: ProductDetail] {

        let globalInfo = GlobalInfo.shared
        if globalInfo.productItemDictionary.isEmpty == false {
            return globalInfo.productItemDictionary
        }

        var productItemDictionary = [String: ProductDetail]()
        let allProductDetails = getAll(context: context)
        for productDetail in allProductDetails {
            guard let _ = productDetail.productLocn else {continue}
            let itemNo = productDetail.itemNo ?? ""
            productItemDictionary[itemNo] = productDetail
        }
        globalInfo.productItemDictionary = productItemDictionary
        return globalInfo.productItemDictionary
    }

    static func getProductUPCDictionary(context: NSManagedObjectContext) -> [String: ProductDetail] {

        let globalInfo = GlobalInfo.shared
        if globalInfo.productUPCDictionary.isEmpty == false {
            return globalInfo.productUPCDictionary
        }

        var productItemDictionary = [String: ProductDetail]()
        let allProductDetails = getAll(context: context)
        for productDetail in allProductDetails {
            guard let _ = productDetail.productLocn else {continue}
            let itemUPC = productDetail.itemUPC ?? ""
            productItemDictionary[itemUPC] = productDetail
        }
        globalInfo.productUPCDictionary = productItemDictionary
        return globalInfo.productUPCDictionary
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.altItemNo = xmlDictionary["AltItemNo"] ?? "0"
        self.brand = xmlDictionary["Brand"] ?? ""
        self.desc = xmlDictionary["Description"] ?? ""
        self.dumpsAllowed = xmlDictionary["DumpsAllowed"] ?? ""
        self.group1 = xmlDictionary["Group1"] ?? ""
        self.group2 = xmlDictionary["Group2"] ?? ""
        self.groupFilterKey = xmlDictionary["GroupFilterKey"] ?? ""
        self.inactive = xmlDictionary["Inactive"] ?? ""
        self.itemNo = xmlDictionary["ItemNo"] ?? ""
        self.itemNoCompl = xmlDictionary["ItemNoCompl"] ?? ""
        self.itemType = xmlDictionary["ItemType"] ?? ""
        self.marketGrp = xmlDictionary["MarketGroup"] ?? ""
        self.packSize = xmlDictionary["PackSize"] ?? ""
        self.priceConsol = xmlDictionary["PriceConsol"] ?? ""
        self.prodLine = xmlDictionary["ProdLine"] ?? ""
        self.salesAllowed = xmlDictionary["SalesAllowed"] ?? ""
        self.serviceFee = xmlDictionary["ServiceFee"] ?? "0"
        self.shortDesc = xmlDictionary["ShortDesc"] ?? ""
        self.subBrand = xmlDictionary["SubBrand"] ?? ""
        self.type = xmlDictionary["Type"] ?? "0"
        self.prodGrp = xmlDictionary["ProdGroup"] ?? "000"
        self.itemUPC = xmlDictionary["ItemUPC"] ?? ""
        self.itemUPC20 = xmlDictionary["ItemUPC20"] ?? ""
        self.consumerUnit = xmlDictionary["ConsumerUnit"] ?? ""
        self.imageURL = xmlDictionary["ImageURL"] ?? ""
    }

    func updateBy(theSource: ProductDetail) {

        self.altItemNo = theSource.altItemNo
        self.brand = theSource.brand
        self.desc = theSource.desc
        self.dumpsAllowed = theSource.dumpsAllowed
        self.group1 = theSource.group1
        self.group2 = theSource.group2
        self.groupFilterKey = theSource.groupFilterKey
        self.inactive = theSource.inactive
        self.itemNo = theSource.itemNo
        self.itemNoCompl = theSource.itemNoCompl
        self.itemType = theSource.itemType
        self.marketGrp = theSource.marketGrp
        self.packSize = theSource.packSize
        self.priceConsol = theSource.priceConsol
        self.prodLine = theSource.prodLine
        self.salesAllowed = theSource.salesAllowed
        self.serviceFee = theSource.serviceFee
        self.shortDesc = theSource.shortDesc
        self.subBrand = theSource.subBrand
        self.type = theSource.type
        self.prodGrp = theSource.prodGrp
        self.itemUPC = theSource.itemUPC
        self.itemUPC20 = theSource.itemUPC20
        self.desc1 = theSource.desc1
        self.desc2 = theSource.desc2
        self.desc3 = theSource.desc3
        self.desc4 = theSource.desc4
        self.desc5 = theSource.desc5
        self.desc6 = theSource.desc6
        self.price = theSource.price
        self.discountValue = theSource.discountValue
        self.consumerUnit = theSource.consumerUnit
        self.imageURL = theSource.imageURL
    }

    func calculatePrice(context: NSManagedObjectContext, customerDetail: CustomerDetail) -> [UPromotion]{
        let chainNo = customerDetail.chainNo ?? ""
        let custNo = customerDetail.custNo ?? ""
        let basePriceString = productLocn?.basePrice ?? ""
        let basePrice = (Double(basePriceString) ?? 0) / Double(kXMLNumberDivider)
        var price: Double = 0
        var priceFillRecord = ""

        let itemNo = self.itemNo ?? ""
        //let _pricing = Pricing.getByForToday(context: context, chainNo: chainNo, custNo: custNo, itemNo: itemNo)
        //let _priceGrp = PriceGroup.getByForToday(context: context, priceGroup: custNo, itemNo: itemNo)
        
        let pricing = Pricing.getByForTodayFromDic(context: context, chainNo: chainNo, custNo: custNo, itemNo: itemNo)
        let priceGrp = PriceGroup.getByForToday(context: context, priceGroup: custNo, itemNo: itemNo)
        if pricing != nil {
            price = (Double(pricing!.price ?? "") ?? 0) / Double(kXMLNumberDivider)
            priceFillRecord = pricing!.prcFilRecord ?? ""
        }
        else {
            if priceGrp != nil {
                price = (Double(priceGrp!.price ?? "") ?? 0) / Double(kXMLNumberDivider)
                priceFillRecord = priceGrp!.prcFilRecord ?? ""
            }
        }

        if priceFillRecord.isEmpty == true {
            self.price = basePrice
        }
        else if priceFillRecord == "N" {
            self.price = price
        }
        else if priceFillRecord == "O" {
            self.price = basePrice - price
        }
        else if priceFillRecord == "P" {
            self.price = basePrice/100*(100-price)
        }

        // promotion
        let promotionDictionary = UPromotion.getPromotionDictionary(context: context, customerDetail: customerDetail)
        var promotionArray = promotionDictionary[itemNo] ?? []
        let allPromotionArray = promotionDictionary["*ALL"]
        if allPromotionArray != nil {
            for prom in allPromotionArray! {
                promotionArray.append(prom)
            }
        }

        promotionArray = promotionArray.sorted(by: { (promotion1, promotion2) -> Bool in
            let seqNo1String = promotion1.seqNo ?? ""
            let seqNo2String = promotion2.seqNo ?? ""
            let seqNo1Value = Int(seqNo1String) ?? 0
            let seqNo2Value = Int(seqNo2String) ?? 0
            let promoType1 = promotion1.promoType!
            let promoType2 = promotion2.promoType!
            let promoType1Value = Int(promoType1) ?? 0
            let promoType2Value = Int(promoType2) ?? 0
            if seqNo1Value != seqNo2Value {
                return seqNo1Value < seqNo2Value
            }
            else {
                return promoType1Value < promoType2Value
            }
        })

        for prom in promotionArray {
            let tempPrice = self.price
            let promoType = prom.promoType ?? ""
            let promoTypeValue = Int(promoType) ?? 0
            if promoTypeValue == kPromoTypeCentsOff {
                let discCount = prom.discAmt ?? ""
                let discValue = Utils.getXMLDivided(valueString: discCount)
                self.price = tempPrice-discValue
                prom.amount = discCount
            }
            else if promoTypeValue == kPromoTypePercentageOff {
                let discCount = prom.discAmt ?? ""
                let discValue = Utils.getXMLDivided(valueString: discCount)
                let fPro = 100-discValue
                self.price = tempPrice/100*fPro
                prom.amount = Utils.getXMLMultipliedString(value: tempPrice-self.price)
            }
            else if promoTypeValue == kPromoTypeReplacePrice {
                let discCount = prom.discAmt ?? ""
                let discValue = Utils.getXMLDivided(valueString: discCount)
                self.price = discValue
                prom.amount = Utils.getXMLMultipliedString(value: tempPrice-self.price)
            }
        }
        self.discountValue = basePrice-self.price
        return promotionArray
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [ProductDetail] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "PRODDETL", xPath: "//ProdDetl/Records/ProdDetl")
        var productDetailArray = [ProductDetail]()
        for dic in dicArray {
            let productDetail = ProductDetail(context: context, forSave: forSave)
            productDetail.updateBy(xmlDictionary: dic)
            productDetailArray.append(productDetail)
            productDetailDic[dic["ItemNo"]!] = productDetail
        }
        return productDetailArray
    }

    static func delete(context: NSManagedObjectContext, productDetail: ProductDetail) {
        context.delete(productDetail)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

    func getProductImage() -> UIImage? {
        let itemNo = self.itemNo ?? ""
        return Utils.getProductImage(itemNo: itemNo)
    }

}

extension ProductDetail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductDetail> {
        return NSFetchRequest<ProductDetail>(entityName: "ProductDetail");
    }

    @NSManaged public var altItemNo: String?
    @NSManaged public var brand: String?
    @NSManaged public var desc: String?
    @NSManaged public var dumpsAllowed: String?
    @NSManaged public var group1: String?
    @NSManaged public var group2: String?
    @NSManaged public var groupFilterKey: String?
    @NSManaged public var inactive: String?
    @NSManaged public var itemNo: String?
    @NSManaged public var itemNoCompl: String?
    @NSManaged public var itemType: String?
    @NSManaged public var marketGrp: String?
    @NSManaged public var packSize: String?
    @NSManaged public var priceConsol: String?
    @NSManaged public var prodLine: String?
    @NSManaged public var salesAllowed: String?
    @NSManaged public var serviceFee: String?
    @NSManaged public var shortDesc: String?
    @NSManaged public var subBrand: String?
    @NSManaged public var type: String?
    @NSManaged public var prodGrp: String?
    @NSManaged public var itemUPC: String?
    @NSManaged public var itemUPC20: String?
    @NSManaged public var desc1: String?
    @NSManaged public var desc2: String?
    @NSManaged public var desc3: String?
    @NSManaged public var desc4: String?
    @NSManaged public var desc5: String?
    @NSManaged public var desc6: String?
    @NSManaged public var price: Double
    @NSManaged public var discountValue: Double
    @NSManaged public var consumerUnit: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var productLocn: ProductLocn?
    @NSManaged public var productLevl: ProductLevl?
    
}

