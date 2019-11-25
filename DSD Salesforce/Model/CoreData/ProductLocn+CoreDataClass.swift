//
//  ProductLocn+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class ProductLocn: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
    }

    static func getBy(context: NSManagedObjectContext, itemNo: String) -> [ProductLocn] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ProductLocn")
        request.predicate = NSPredicate(format: "itemNo=%@", itemNo)

        let result = try? context.fetch(request) as? [ProductLocn]

        if let result = result, let productLocnArray = result {
            return productLocnArray
        }
        return []
    }

    static func getProdLocnSCWType(context: NSManagedObjectContext, itemNo: String) -> Int {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ProductLocn")
        request.predicate = NSPredicate(format: "itemNo=%@", itemNo)
        request.fetchLimit = 1

        let result = try? context.fetch(request) as? [ProductLocn]

        if let result = result, let productLocnArray = result {
            return Int(productLocnArray.first?.scwType ?? "0") ?? 0
        }
        return 0
    }

    static func getCaseDictionary(context: NSManagedObjectContext) -> [String: Int] {
        let all = getAll(context: context)
        var caseDictionary = [String: Int]()
        for productLocn in all {
            let caseValue = Int(productLocn.caseFactor ?? "") ?? 0
            let itemNo = productLocn.itemNo ?? ""
            caseDictionary[itemNo] = caseValue
        }
        return caseDictionary
    }

    static func getAll(context: NSManagedObjectContext) -> [ProductLocn] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ProductLocn")
        let result = try? context.fetch(request) as? [ProductLocn]

        if let result = result, let productLocnArray = result {
            return productLocnArray
        }
        return []
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.locnNo = xmlDictionary["LocnNo"] ?? "0"
        self.itemNo = xmlDictionary["ItemNo"] ?? ""
        self.scwType = xmlDictionary["SCWType"] ?? "9"
        self.basePrice = xmlDictionary["BasePrice"] ?? "0"
        self.caseFactor = xmlDictionary["CaseFactor"] ?? "0"
        self.retailPrice = xmlDictionary["RetailPrice"] ?? "0"
        self.returnPrice = xmlDictionary["ReturnPrice"] ?? "0"
        self.taxFlag = xmlDictionary["TaxFlag"] ?? "0"
        self.driverPrice = xmlDictionary["DriverPrice"] ?? "0"
        self.itemTaxCode = xmlDictionary["ItemTaxCode"] ?? ""
        self.fullCase = xmlDictionary["FullCase"] ?? "N"
        self.palletFactor = xmlDictionary["PalletFactor"] ?? "0"
        self.stackFactor = xmlDictionary["StackFactor"] ?? "0"
        self.caseUOM = xmlDictionary["CaseUOM"] ?? ""
        self.unitUOM = xmlDictionary["UnitUOM"] ?? ""
        self.weightType = xmlDictionary["WeightType"] ?? "R"
        self.custDiscountValid = xmlDictionary["CustDiscountValid"] ?? "1"
        self.discInLieuItem = xmlDictionary["DiscInLieuItem"] ?? "N"
        self.orderSeq = xmlDictionary["CaseUOM"] ?? "99999"
        self.minimumSalePrice = xmlDictionary["MinimumSalePrice"] ?? ""
        self.costPrice = xmlDictionary["CostPrice"] ?? ""
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [ProductLocn] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "PRODLOCN", xPath: "//ProdLocn/Records/ProdLocn")
        var productLocnArray = [ProductLocn]()
        for dic in dicArray {
            let productLocn = ProductLocn(context: context, forSave: forSave)
            productLocn.updateBy(xmlDictionary: dic)
            productLocnArray.append(productLocn)
        }
        return productLocnArray
    }

    static func delete(context: NSManagedObjectContext, productLocn: ProductLocn) {
        context.delete(productLocn)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension ProductLocn {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductLocn> {
        return NSFetchRequest<ProductLocn>(entityName: "ProductLocn");
    }

    @NSManaged public var locnNo: String?
    @NSManaged public var itemNo: String?
    @NSManaged public var scwType: String?
    @NSManaged public var basePrice: String?
    @NSManaged public var caseFactor: String?
    @NSManaged public var retailPrice: String?
    @NSManaged public var returnPrice: String?
    @NSManaged public var taxFlag: String?
    @NSManaged public var driverPrice: String?
    @NSManaged public var itemTaxCode: String?
    @NSManaged public var fullCase: String?
    @NSManaged public var palletFactor: String?
    @NSManaged public var stackFactor: String?
    @NSManaged public var caseUOM: String?
    @NSManaged public var unitUOM: String?
    @NSManaged public var weightType: String?
    @NSManaged public var custDiscountValid: String?
    @NSManaged public var discInLieuItem: String?
    @NSManaged public var orderSeq: String?
    @NSManaged public var minimumSalePrice: String?
    @NSManaged public var costPrice: String?
}

