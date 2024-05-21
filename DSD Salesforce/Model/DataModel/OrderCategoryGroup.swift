//
//  OrderCategoryGroup.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/12/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import Foundation

class OrderCategory: NSObject {

    var name = ""
    var group: OrderCategoryGroup?

    init(name: String) {
        self.name = name
    }
}

class OrderCategoryGroup: NSObject {

    var name = ""
    var children = [OrderCategory]()

    init(name: String) {
        self.name = name
    }

    func addChildren(children: [OrderCategory]) {
        for child in children {
            child.group = self
            self.children.append(child)
        }
    }

    func addChild(_ child: OrderCategory) {
        child.group = self
        self.children.append(child)
    }

    func removeChild(_ child: OrderCategory) {
        self.children = self.children.filter( {$0 !== child})
    }
}
