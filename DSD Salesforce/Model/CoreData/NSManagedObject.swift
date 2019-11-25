//
//  NSManagedObject.swift
//  DietScience
//
//  Created by iOS Developer on 2/18/16.
//  Copyright © 2016 Lee Jackson. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {

    public class func entityName() -> String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }

    convenience init(managedObjectContext: NSManagedObjectContext, forSave: Bool = true) {
        let entityName = type(of: self).entityName()
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)!
        if forSave == true {
            self.init(entity: entity, insertInto: managedObjectContext)
        }
        else {
            self.init(entity: entity, insertInto: nil)
        }
    }

}
