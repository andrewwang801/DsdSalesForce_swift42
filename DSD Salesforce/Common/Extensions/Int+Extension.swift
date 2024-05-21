//
//  Int+Extension.swift
//  MyTaxPal
//
//  Created by iOS Developer on 5/21/16.
//  Copyright © 2016 Q-Scope. All rights reserved.
//

import Foundation
import UIKit

extension Int {
    var int32: Int32 {
        return Int32(self)
    }

    var double: Double {
        return Double(self)
    }

    func toNSNumber() -> NSNumber? {
        return NSNumber(value: self)
    }

    func toLeftPaddedString(digitCount: Int) -> String? {

        let number = self.toNSNumber()
        let numberFormat = NumberFormatter()
        numberFormat.paddingCharacter = "0"
        numberFormat.minimumIntegerDigits = digitCount
        return numberFormat.string(from: number!)
    }

    func normalizedString() -> String {
        let number = self.toNSNumber()
        let numberFormat = NumberFormatter()
        numberFormat.usesGroupingSeparator = true
        numberFormat.groupingSize = 3
        numberFormat.groupingSeparator = ","
        numberFormat.maximumFractionDigits = 0
        return numberFormat.string(from: number!) ?? "0"
    }
}

extension Int32 {
    var int: Int {
        return Int(self)
    }
}

extension Int64 {

    var int: Int {
        return Int(self)
    }

    func toNSNumber() -> NSNumber? {
        return NSNumber(value: self)
    }

    func toLeftPaddedString(digitCount: Int) -> String? {

        let number = self.toNSNumber()
        let numberFormat = NumberFormatter()
        numberFormat.paddingCharacter = "0"
        numberFormat.minimumIntegerDigits = digitCount
        return numberFormat.string(from: number!)
    }
}
