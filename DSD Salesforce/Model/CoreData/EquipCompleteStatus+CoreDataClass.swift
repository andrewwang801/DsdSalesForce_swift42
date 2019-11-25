//
//  EquipCompleteStatus+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class EquipCompleteStatus: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
    }

    static func getBy(context: NSManagedObjectContext, chainNo: String, custNo: String) -> EquipCompleteStatus? {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "EquipCompleteStatus")
        let predicate1 = NSPredicate(format: "chainNo=%@", chainNo)
        let predicate2 = NSPredicate(format: "custNo=%@", custNo)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])

        let result = try? context.fetch(request) as? [EquipCompleteStatus]

        if let result = result, let equipCompleteStatusArray = result {
            return equipCompleteStatusArray.first
        }
        return nil
    }

    static func setCompleted(context: NSManagedObjectContext, chainNo: String, custNo: String, isCompleted: Bool) {
        let existing = getBy(context: context, chainNo: chainNo, custNo: custNo)
        if existing == nil {
            let status = EquipCompleteStatus(context: context, forSave: true)
            status.chainNo = chainNo
            status.custNo = custNo
            status.isCompleted = isCompleted
        }
        else {
            existing!.isCompleted = true
        }
        GlobalInfo.saveCache()
    }

    static func getAll(context: NSManagedObjectContext) -> [EquipCompleteStatus] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "EquipCompleteStatus")
        let result = try? context.fetch(request) as? [EquipCompleteStatus]

        if let result = result, let statusArray = result {
            return statusArray
        }
        return []
    }

    static func delete(context: NSManagedObjectContext, equipeCompleteStatus: EquipCompleteStatus) {
        context.delete(equipeCompleteStatus)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context)
        for object in all {
            context.delete(object)
        }
    }

}

extension EquipCompleteStatus {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EquipCompleteStatus> {
        return NSFetchRequest<EquipCompleteStatus>(entityName: "EquipCompleteStatus");
    }

    @NSManaged public var chainNo: String?
    @NSManaged public var custNo: String?
    @NSManaged public var isCompleted: Bool

}


