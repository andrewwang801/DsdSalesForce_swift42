//
//  OrderHistory+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class OrderHistory: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
    }
    
    static func getBy(context: NSManagedObjectContext, chainNo: String, custNo: String) -> [OrderHistory] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderHistory")

        let predicate1 = NSPredicate(format: "custNo=%@", custNo)
        let predicate2 = NSPredicate(format: "chainNo=%@", chainNo)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])

        let result = try? context.fetch(request) as? [OrderHistory]

        if let result = result, let orderHistorys = result {
            return orderHistorys
        }
        return []
    }

    static func getItemArrayBy(context: NSManagedObjectContext, chainNo: String, custNo: String) -> [OrderHistoryItem] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderHistory")

        let predicate1 = NSPredicate(format: "custNo=%@", custNo)
        let predicate2 = NSPredicate(format: "chainNo=%@", chainNo)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])

        let result = try? context.fetch(request) as? [OrderHistory]

        if let result = result, let orderHistoryArray = result {
            var orderHistoryItemArray = [OrderHistoryItem]()
            for orderHistory in orderHistoryArray {
                let items = orderHistory.getOrderHistoryItems()
                orderHistoryItemArray.append(contentsOf: items)
            }
            return orderHistoryItemArray
        }
        return []
    }

    static func getItemArrayBy(context: NSManagedObjectContext, custNo: String) -> [OrderHistoryItem] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderHistory")

        let predicate1 = NSPredicate(format: "custNo=%@", custNo)

        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1])

        let result = try? context.fetch(request) as? [OrderHistory]

        if let result = result, let orderHistoryArray = result {
            var orderHistoryItemArray = [OrderHistoryItem]()
            for orderHistory in orderHistoryArray {
                let items = orderHistory.getOrderHistoryItems()
                orderHistoryItemArray.append(contentsOf: items)
            }
            return orderHistoryItemArray
        }
        return []
    }
    
    static func getLastItem(context: NSManagedObjectContext, custNo: String, itemNo: String) -> OrderHistoryItem? {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderHistory")

        let predicate1 = NSPredicate(format: "custNo=%@", custNo)
        let predicate2 = NSPredicate(format: "itemNo=%@", itemNo)

        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])

        let result = try? context.fetch(request) as? [OrderHistory]

        if let result = result, let orderHistoryArray = result {
            var orderHistoryItemArray = [OrderHistoryItem]()
            for orderHistory in orderHistoryArray {
                let items = orderHistory.getOrderHistoryItems()
                orderHistoryItemArray = items.sorted(by: { $0.orderDate > $1.orderDate })
            }
            for item in orderHistoryItemArray {
                if item.nSAQty / Int(kOrderHistoryDivider) != 0 {
                    return item
                }
            }
        }
        return nil
    }
    
    static func getFirstBy(context: NSManagedObjectContext, chainNo: String, custNo: String, itemNo: String) -> OrderHistory? {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderHistory")
        let predicate1 = NSPredicate(format: "custNo=%@", custNo)
        let predicate2 = NSPredicate(format: "chainNo=%@", chainNo)
        let predicate3 = NSPredicate(format: "itemNo=%@", itemNo)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2, predicate3])
        request.fetchLimit = 1

        let result = try? context.fetch(request) as? [OrderHistory]

        if let result = result, let orderHistorys = result {
            return orderHistorys.first
        }
        return nil
    }
    
    func getOrderHistoryString() -> String {
        
        let qty1 = (Double(saQty1 ?? "") ?? 0)/kOrderHistoryDivider
        let qty2 = (Double(saQty2 ?? "") ?? 0)/kOrderHistoryDivider
        let qty3 = (Double(saQty3 ?? "") ?? 0)/kOrderHistoryDivider
        let qty4 = (Double(saQty4 ?? "") ?? 0)/kOrderHistoryDivider
        let qty5 = (Double(saQty5 ?? "") ?? 0)/kOrderHistoryDivider
        let qty6 = (Double(saQty6 ?? "") ?? 0)/kOrderHistoryDivider
        return qty1.integerString + "-" + qty2.integerString + "-" + qty3.integerString + "-" + qty4.integerString + "-" + qty5.integerString + "-" + qty6.integerString
    }

    static func getAll(context: NSManagedObjectContext) -> [OrderHistory] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderHistory")
        let result = try? context.fetch(request) as? [OrderHistory]

        if let result = result, let orderHistorys = result {
            return orderHistorys
        }
        return []
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.custNo = xmlDictionary["CustNo"] ?? "0"
        self.chainNo = xmlDictionary["ChainNo"] ?? "0"
        self.itemNo = xmlDictionary["ItemNo"] ?? "0"
        self.date1 = xmlDictionary["Date1"] ?? ""
        self.date2 = xmlDictionary["Date2"] ?? ""
        self.date3 = xmlDictionary["Date3"] ?? ""
        self.date4 = xmlDictionary["Date4"] ?? ""
        self.date5 = xmlDictionary["Date5"] ?? ""
        self.date6 = xmlDictionary["Date6"] ?? ""
        self.saQty1 = xmlDictionary["SAQty1"] ?? ""
        self.saQty2 = xmlDictionary["SAQty2"] ?? ""
        self.saQty3 = xmlDictionary["SAQty3"] ?? ""
        self.saQty4 = xmlDictionary["SAQty4"] ?? ""
        self.saQty5 = xmlDictionary["SAQty5"] ?? ""
        self.saQty6 = xmlDictionary["SAQty6"] ?? ""
        self.duQty1 = xmlDictionary["DUQty1"] ?? ""
        self.duQty2 = xmlDictionary["DUQty2"] ?? ""
        self.duQty3 = xmlDictionary["DUQty3"] ?? ""
        self.duQty4 = xmlDictionary["DUQty4"] ?? ""
        self.duQty5 = xmlDictionary["DUQty5"] ?? ""
        self.duQty6 = xmlDictionary["DUQty6"] ?? ""
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [OrderHistory] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "ORDHIST", xPath: "//OrdHist/Records/OrdHist")
        var orderHistoryArray = [OrderHistory]()
        for dic in dicArray {
            let orderHistory = OrderHistory(context: context, forSave: forSave)
            orderHistory.updateBy(xmlDictionary: dic)
            orderHistoryArray.append(orderHistory)
        }
        return orderHistoryArray
    }

    static func delete(context: NSManagedObjectContext, orderHistory: OrderHistory) {
        context.delete(orderHistory)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

    func getMonthAmount() -> Double {
        let qty1 = Double(self.saQty1 ?? "") ?? 0
        let qty2 = Double(self.saQty2 ?? "") ?? 0
        let qty3 = Double(self.saQty3 ?? "") ?? 0
        let qty4 = Double(self.saQty4 ?? "") ?? 0
        let qty5 = Double(self.saQty5 ?? "") ?? 0
        let qty6 = Double(self.saQty6 ?? "") ?? 0
        let qtyArray = [qty1, qty2, qty3, qty4, qty5, qty6]
        let dateArray = [date1!, date2!, date3!, date4!, date5!, date6!]

        var totalAmount:Double = 0
        let now = Date()
        for (index, qty) in qtyArray.enumerated() {
            let dateString = dateArray[index]
            guard let date = Date.fromDateString(dateString: dateString, format: kTightJustDateFormat) else {continue}
            if now.year == date.year && now.month == date.month {
                totalAmount += qty
            }
        }

        return totalAmount/kOrderHistoryDivider
    }

    func getTotal() -> Double {
        let qty1 = Double(self.saQty1 ?? "") ?? 0
        let qty2 = Double(self.saQty2 ?? "") ?? 0
        let qty3 = Double(self.saQty3 ?? "") ?? 0
        let qty4 = Double(self.saQty4 ?? "") ?? 0
        let qty5 = Double(self.saQty5 ?? "") ?? 0
        let qty6 = Double(self.saQty6 ?? "") ?? 0

        return (qty1+qty2+qty3+qty4+qty5+qty6)/kOrderHistoryDivider
    }

    func getLastOrderString() -> String {
        //var orders = [Double]()
        let qty1 = (Double(saQty1 ?? "") ?? 0)/kOrderHistoryDivider
        let qty2 = (Double(saQty2 ?? "") ?? 0)/kOrderHistoryDivider
        let qty3 = (Double(saQty3 ?? "") ?? 0)/kOrderHistoryDivider
        let qty4 = (Double(saQty4 ?? "") ?? 0)/kOrderHistoryDivider
        //let qty5 = (Double(saQty5 ?? "") ?? 0)/kOrderHistoryDivider
        //let qty6 = (Double(saQty6 ?? "") ?? 0)/kOrderHistoryDivider

        var orderStringArray = [String]()
        let kDefaultDateString = "20000101"
        if date1!.isEmpty == true || date1! == kDefaultDateString {
            orderStringArray.append(".")
        }
        else {
            orderStringArray.append(qty1.integerString)
        }
        if date2!.isEmpty == true || date2! == kDefaultDateString {
            orderStringArray.append(".")
        }
        else {
            orderStringArray.append(qty2.integerString)
        }
        if date3!.isEmpty == true || date3! == kDefaultDateString {
            orderStringArray.append(".")
        }
        else {
            orderStringArray.append(qty3.integerString)
        }
        if date4!.isEmpty == true || date4! == kDefaultDateString {
            orderStringArray.append(".")
        }
        else {
            orderStringArray.append(qty4.integerString)
        }

        return orderStringArray.joined(separator: " - ")
    }

    func getDate() -> String {

        let qty1 = (Double(saQty1 ?? "") ?? 0)/kOrderHistoryDivider
        let qty2 = (Double(saQty2 ?? "") ?? 0)/kOrderHistoryDivider
        let qty3 = (Double(saQty3 ?? "") ?? 0)/kOrderHistoryDivider
        let qty4 = (Double(saQty4 ?? "") ?? 0)/kOrderHistoryDivider
        let qty5 = (Double(saQty5 ?? "") ?? 0)/kOrderHistoryDivider
        let qty6 = (Double(saQty6 ?? "") ?? 0)/kOrderHistoryDivider

        if date1!.isEmpty == false && qty1 > 0 {
            return date1!
        }
        if date2!.isEmpty == false && qty2 > 0 {
            return date2!
        }
        if date3!.isEmpty == false && qty3 > 0 {
            return date3!
        }
        if date4!.isEmpty == false && qty4 > 0 {
            return date4!
        }
        if date5!.isEmpty == false && qty5 > 0 {
            return date5!
        }
        return date6!
    }

    func getOrderHistoryItems() -> [OrderHistoryItem] {
        let itemNo = self.itemNo ?? ""
        let custNo = self.custNo ?? ""
        var orderHistoryItemArray = [OrderHistoryItem]()
        for i in 1...6 {
            let dateValue = self.value(forKey: "date\(i)") as? String
            if dateValue == nil {
                continue
            }
            let bbQty = self.value(forKey: "duQty\(i)") as? String ?? ""
            let saQty = self.value(forKey: "saQty\(i)") as? String ?? ""
            let orderHistoryItem = OrderHistoryItem()
            orderHistoryItem.itemNo = itemNo
            orderHistoryItem.custNo = custNo
            orderHistoryItem.orderDate = dateValue ?? ""
            orderHistoryItem.nSAQty = Int(saQty) ?? 0
            orderHistoryItem.nBBQty = Int(bbQty) ?? 0
            orderHistoryItemArray.append(orderHistoryItem)
        }
        return orderHistoryItemArray
    }

}

extension OrderHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OrderHistory> {
        return NSFetchRequest<OrderHistory>(entityName: "OrderHistory");
    }

    @NSManaged public var custNo: String?
    @NSManaged public var chainNo: String?
    @NSManaged public var itemNo: String?
    @NSManaged public var date1: String?
    @NSManaged public var date2: String?
    @NSManaged public var date3: String?
    @NSManaged public var date4: String?
    @NSManaged public var date5: String?
    @NSManaged public var date6: String?
    @NSManaged public var saQty1: String?
    @NSManaged public var saQty2: String?
    @NSManaged public var saQty3: String?
    @NSManaged public var saQty4: String?
    @NSManaged public var saQty5: String?
    @NSManaged public var saQty6: String?
    @NSManaged public var duQty1: String?
    @NSManaged public var duQty2: String?
    @NSManaged public var duQty3: String?
    @NSManaged public var duQty4: String?
    @NSManaged public var duQty5: String?
    @NSManaged public var duQty6: String?

}

