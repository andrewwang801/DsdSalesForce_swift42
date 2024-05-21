//
//  DocText+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class DocText: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
    }

    static func getBy(context: NSManagedObjectContext, textType: String) -> [DocText] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DocText")
        let predicate1 = NSPredicate(format: "chainNo=%@", "0")
        let predicate2 = NSPredicate(format: "custNo=%@", "0")
        let predicate3 = NSPredicate(format: "textType=%@", textType)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2, predicate3])

        let result = try? context.fetch(request) as? [DocText]

        if let result = result, let docTextArray = result {
            let sortedDocTextArray = docTextArray.sorted { (docText1, docText2) -> Bool in
                let line1 = Int(docText1.line ?? "") ?? 0
                let line2 = Int(docText2.line ?? "") ?? 0
                return line1 < line2
            }
            return sortedDocTextArray
        }
        return []
    }

    static func getBy(context: NSManagedObjectContext, chainNo: String, custNo: String, textType: String) -> [DocText] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DocText")
        let predicate1 = NSPredicate(format: "chainNo=%@", chainNo)
        let predicate2 = NSPredicate(format: "custNo=%@", custNo)
        let predicate3 = NSPredicate(format: "textType=%@", textType)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2, predicate3])

        let result = try? context.fetch(request) as? [DocText]

        if let result = result, let docTextArray = result {
            let sortedDocTextArray = docTextArray.sorted { (docText1, docText2) -> Bool in
                let line1 = Int(docText1.line ?? "") ?? 0
                let line2 = Int(docText2.line ?? "") ?? 0
                return line1 < line2
            }
            return sortedDocTextArray
        }
        return []
    }

    static func getBy(context: NSManagedObjectContext, custNo: String, textType: String) -> [DocText] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DocText")
        let predicate1 = NSPredicate(format: "custNo=%@", custNo)
        let predicate2 = NSPredicate(format: "textType=%@", textType)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])

        let result = try? context.fetch(request) as? [DocText]

        if let result = result, let docTextArray = result {
            let sortedDocTextArray = docTextArray.sorted { (docText1, docText2) -> Bool in
                let line1 = Int(docText1.line ?? "") ?? 0
                let line2 = Int(docText2.line ?? "") ?? 0
                return line1 < line2
            }
            return sortedDocTextArray
        }
        return []
    }

    static func getAll(context: NSManagedObjectContext) -> [DocText] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DocText")
        let result = try? context.fetch(request) as? [DocText]

        if let result = result, let docTextArray = result {
            return docTextArray
        }
        return []
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.chainNo = xmlDictionary["ChainNo"] ?? "0"
        self.custNo = xmlDictionary["CustNo"] ?? "0"
        self.textType = xmlDictionary["TextType"] ?? "0"
        self.subType = xmlDictionary["SubType"] ?? ""
        self.line = xmlDictionary["Line"] ?? "0"
        self.docText = xmlDictionary["DocText"] ?? ""
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [DocText] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "DOCTEXT", xPath: "//DocText/Records/DocText")
        var docTextArray = [DocText]()
        for dic in dicArray {
            let docText = DocText(context: context, forSave: forSave)
            docText.updateBy(xmlDictionary: dic)
            docTextArray.append(docText)
        }
        return docTextArray
    }

    static func delete(context: NSManagedObjectContext, docText: DocText) {
        context.delete(docText)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension DocText {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DocText> {
        return NSFetchRequest<DocText>(entityName: "DocText");
    }

    @NSManaged public var chainNo: String?
    @NSManaged public var custNo: String?
    @NSManaged public var textType: String?
    @NSManaged public var subType: String?
    @NSManaged public var line: String?
    @NSManaged public var docText: String?

}

