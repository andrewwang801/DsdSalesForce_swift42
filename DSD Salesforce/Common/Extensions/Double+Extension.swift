//
//  Double+Extension.swift
//  MyTaxPal
//
//  Created by iOS Developer on 5/21/16.
//  Copyright © 2016 Q-Scope. All rights reserved.
//

import Foundation

extension Double {
    func toNSDecimalNumber() -> NSDecimalNumber? {
        return NSDecimalNumber.init(value: self)
    }
    
    func toNSNumber() -> NSNumber? {
        return NSNumber.init(value: self)
    }
    
    var integerString:String {
        get {
            let numberFormat = NumberFormatter()
            numberFormat.maximumFractionDigits = 0
            numberFormat.minimumFractionDigits = 0
            if let returnString = numberFormat.string(from: NSNumber.init(value:self)) {
                return returnString
            }
            else {
                return "0"
            }
        }
    }
    
    var oneDecimalString:String {
        get {
            let numberFormat = NumberFormatter()
            numberFormat.maximumFractionDigits = 1
            numberFormat.minimumFractionDigits = 0
            numberFormat.decimalSeparator = "."
            if let returnString = numberFormat.string(from: NSNumber.init(value:self)) {
                return returnString
            }
            else {
                return "0"
            }
        }
    }
    
    var twoDecimalString:String {
        get {
            let numberFormat = NumberFormatter()
            numberFormat.maximumFractionDigits = 2
            numberFormat.minimumFractionDigits = 0
            numberFormat.minimumIntegerDigits = 1
            numberFormat.decimalSeparator = "."
            if let returnString = numberFormat.string(from: NSNumber.init(value:self)) {
                return returnString
            }
            else {
                return "0"
            }
        }
    }

    var exactTwoDecimalString:String {
        get {
            let numberFormat = NumberFormatter()
            numberFormat.maximumFractionDigits = 2
            numberFormat.minimumFractionDigits = 2
            numberFormat.minimumIntegerDigits = 1
            numberFormat.decimalSeparator = "."
            if let returnString = numberFormat.string(from: NSNumber.init(value:self)) {
                return returnString
            }
            else {
                return "0"
            }
        }
    }

    var twoGroupedExactDecimalString:String {
        get {
            let numberFormat = NumberFormatter()
            numberFormat.usesGroupingSeparator = true
            numberFormat.groupingSeparator = ","
            numberFormat.groupingSize = 3
            numberFormat.maximumFractionDigits = 2
            numberFormat.minimumFractionDigits = 2
            numberFormat.minimumIntegerDigits = 1
            numberFormat.decimalSeparator = "."
            if let returnString = numberFormat.string(from: NSNumber.init(value:self)) {
                return returnString
            }
            else {
                return "0"
            }
        }
    }
    
    var moneyString:String {
        get {
            let numberFormat = NumberFormatter()
            numberFormat.maximumFractionDigits = 2
            numberFormat.minimumFractionDigits = 2
            numberFormat.minimumIntegerDigits = 1
            numberFormat.usesGroupingSeparator = true
            numberFormat.groupingSeparator = ","
            numberFormat.groupingSize = 3
            let result = numberFormat.string(from: NSNumber(value: self)) ?? "0.00"
            return "$\(result)"
        }
    }
    
    var signDecimalString:String {

        let numberFormat = NumberFormatter()
        numberFormat.maximumFractionDigits = 2
        numberFormat.minimumFractionDigits = 0
        numberFormat.minimumIntegerDigits = 1
        numberFormat.decimalSeparator = "."
        numberFormat.plusSign = "+"
        numberFormat.positivePrefix = "+"
        numberFormat.minusSign = "-"
        
        if let returnString = numberFormat.string(from: NSNumber.init(value:self)) {
            return returnString
        }
        else {
            return "0.00"
        }
    }
    
    var timeString:String {
        get {
            let numberFormat = NumberFormatter()
            numberFormat.maximumFractionDigits = 2
            numberFormat.minimumFractionDigits = 2
            numberFormat.minimumIntegerDigits = 1
            numberFormat.maximumIntegerDigits = 2
            numberFormat.decimalSeparator = ":"
            if let returnString = numberFormat.string(from: NSNumber.init(value:self)) {
                let items = returnString.components(separatedBy: ":")
                let hour = Int(items[0]) ?? 0
                var amString = ""
                if hour >= 12 {
                    amString = "pm"
                }
                else {
                    amString = "am"
                }
                return "\(returnString)\(amString)"
            }
            else {
                return ""
            }
        }
    }
    
    var currencyString: String {
        get {
            let numberFormat = NumberFormatter()
            numberFormat.numberStyle = .currency
            let returnString = numberFormat.string(from: NSNumber.init(value:self)) ?? "0"
            return returnString
        }
    }
    
    func getDecimalString(digits: Int) -> String {
        let numberFormat = NumberFormatter()
        numberFormat.maximumFractionDigits = 5
        numberFormat.minimumFractionDigits = 0
        numberFormat.decimalSeparator = "."
        if let returnString = numberFormat.string(from: NSNumber.init(value:self)) {
            return returnString
        }
        else {
            return "0"
        }
    }
    
    func equalsApproximately(compareValue: Double) -> Bool {
        
        let diff = fabs(self-compareValue)
        if diff < Double.ulpOfOne {
            return true
        }
        else {
            return false
        }
    }
    
    var integerValue:Double {
        get {
            return Double(self.integerString)!
        }
    }
    
    var oneDecimalValue:Double {
        get {
            return Double(self.oneDecimalString)!
        }
    }
    
    var twoDecimalValue:Double {
        get {
            return Double(self.twoDecimalString)!
        }
    }

}
