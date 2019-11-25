//
//  Bool+Extension.swift
//  MyTaxPal
//
//  Created by iOS Developer on 5/21/16.
//  Copyright © 2016 Q-Scope. All rights reserved.
//

import Foundation

extension Bool {
    func toNSNumber() -> NSNumber? {
        return NSNumber(value: self)
    }

    var intValue: Int {
        if self == true {
            return 1
        }
        else {
            return 0
        }
    }

    var intString: String {
        if self == true {
            return "1"
        }
        else {
            return "0"
        }
    }
}
