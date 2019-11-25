//
//  CustNote+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class CustNote: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)

        chainNo = "0"
        custNo = "0"
        noteType = ""
        noteDate = ""
        noteTime = ""
        createdby = ""
        note = ""
        noteId = ""
        attachment = ""
    }

    static func getAll(context: NSManagedObjectContext) -> [CustNote] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CustNote")
        let result = try? context.fetch(request) as? [CustNote]

        if let result = result, let custNotes = result {
            return custNotes
        }
        return []
    }

    static func getBy(context: NSManagedObjectContext, chainNo: String, custNo: String) -> [CustNote] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CustNote")
        let predicate1 = NSPredicate(format: "chainNo=%@", chainNo)
        let predicate2 = NSPredicate(format: "custNo=%@", custNo)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])

        let result = try? context.fetch(request) as? [CustNote]

        if let result = result, let custNoteArray = result {
            let sorted = custNoteArray.sorted { (custNote1, custNote2) -> Bool in
                let date1 = custNote1.noteDate ?? ""
                let date2 = custNote2.noteDate ?? ""
                let time1 = custNote1.noteTime ?? ""
                let time2 = custNote2.noteTime ?? ""
                let dateTime1 = date1 + time1
                let dateTime2 = date2 + time2
                return dateTime1 > dateTime2
            }
            return sorted
        }
        return []
    }

    func updateBy(xmlDictionary: [String: String]) {

        self.chainNo = xmlDictionary["ChainNo"] ?? ""
        self.custNo = xmlDictionary["CustNo"] ?? ""
        self.noteType = xmlDictionary["NoteType"] ?? ""
        self.noteDate = xmlDictionary["NoteDate"] ?? ""
        self.noteTime = xmlDictionary["NoteTime"] ?? ""
        self.createdby = xmlDictionary["Createdby"] ?? ""
        self.note = xmlDictionary["Note"] ?? ""
        self.noteId = xmlDictionary["NoteId"] ?? ""
        self.attachment = xmlDictionary["Attachment"] ?? ""
    }

    func updateBy(theSource: CustNote) {
        self.chainNo = theSource.chainNo
        self.custNo = theSource.custNo
        self.noteType = theSource.noteType
        self.noteDate = theSource.noteDate
        self.noteTime = theSource.noteTime
        self.createdby = theSource.createdby
        self.note = theSource.note
        self.noteId = theSource.noteId
        self.attachment = theSource.attachment
    }

    static func loadFromXML(context: NSManagedObjectContext, forSave: Bool) -> [CustNote] {

        deleteAll(context: context)

        let dicArray = Utils.loadFromXML(xmlName: "CUSTNOTE", xPath: "//CustNote/Records/CustNote")
        var custNoteArray = [CustNote]()
        for dic in dicArray {
            let custNote = CustNote(context: context, forSave: forSave)
            custNote.updateBy(xmlDictionary: dic)
            custNoteArray.append(custNote)
        }
        return custNoteArray
    }

    static func delete(context: NSManagedObjectContext, custNote: CustNote) {
        context.delete(custNote)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension CustNote {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CustNote> {
        return NSFetchRequest<CustNote>(entityName: "CustNote");
    }

    @NSManaged public var chainNo: String?
    @NSManaged public var custNo: String?
    @NSManaged public var noteType: String?
    @NSManaged public var noteDate: String?
    @NSManaged public var noteTime: String?
    @NSManaged public var createdby: String?
    @NSManaged public var note: String?
    @NSManaged public var noteId: String?
    @NSManaged public var attachment: String?
    @NSManaged public var fileNames: String?
    @NSManaged public var fileTypes: String?

}
