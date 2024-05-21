//
//  UploadItem+CoreDataClass.swift
//  Clockster
//
//  Created by iOS Developer on 11/24/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

import Foundation
import CoreData

public class UploadItem: NSManagedObject {

    convenience init(context: NSManagedObjectContext, forSave: Bool = true) {
        self.init(managedObjectContext: context, forSave: forSave)
        shouldPostpone = false
    }
    
    static func getAll(context: NSManagedObjectContext, shouldExcludePostponed: Bool) -> [UploadItem] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UploadItem")
        if shouldExcludePostponed == true {
            request.predicate = NSPredicate(format: "shouldPostpone=false")
        }
        request.sortDescriptors = [NSSortDescriptor(key: "queuedDate", ascending: true)]
        let result = try? context.fetch(request) as? [UploadItem]

        if let result = result, let uploadItems = result {
            return uploadItems
        }
        return []
    }

    static func getFirst(context: NSManagedObjectContext) -> UploadItem? {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UploadItem")
        request.predicate = NSPredicate(format: "shouldPostpone=false")
        request.sortDescriptors = [NSSortDescriptor(key: "queuedDate", ascending: true)]
        request.fetchLimit = 1
        let result = try? context.fetch(request) as? [UploadItem]

        if let result = result, let uploadItems = result {
            return uploadItems.first
        }
        return nil
    }

    static func delete(context: NSManagedObjectContext, uploadItem: UploadItem) {
        let localPath = CommData.getFilePathAppended(byDocumentDir: uploadItem.localName ?? "") ?? ""
        CommData.deleteFileIfExist(localPath)
        context.delete(uploadItem)
    }
    
    static func deleteUploadItem(context: NSManagedObjectContext, uploadItem: UploadItem) {
        context.delete(uploadItem)
    }

    static func deleteAll(context: NSManagedObjectContext) {
        let all = getAll(context: context, shouldExcludePostponed: false)
        for object in all {
            context.delete(object)
        }
    }
    
    static func resetAllPostpones(context: NSManagedObjectContext) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UploadItem")
        request.predicate = NSPredicate(format: "shouldPostpone=true")
        let result = try? context.fetch(request) as? [UploadItem]
        if let result = result, let uploadItems = result {
            for uploadItem in uploadItems {
                uploadItem.shouldPostpone = false
            }
            GlobalInfo.saveCache()
        }
        return
    }

}

extension UploadItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UploadItem> {
        return NSFetchRequest<UploadItem>(entityName: "UploadItem");
    }

    @NSManaged public var ftpHostname: String?
    @NSManaged public var ftpPassword: String?
    @NSManaged public var ftpPath: String?
    @NSManaged public var ftpUsername: String?
    @NSManaged public var localName: String?
    @NSManaged public var queuedDate: Date?
    @NSManaged public var companyName: String?
    @NSManaged public var shouldPostpone: Bool
    @NSManaged public var shouldRemoved: Bool
}


