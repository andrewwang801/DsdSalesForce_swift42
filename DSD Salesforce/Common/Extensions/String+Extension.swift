//
//  String+Extension.swift
//  MyTaxPal
//
//  Created by iOS Developer on 5/21/16.
//  Copyright © 2016 Q-Scope. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    subscript (i: Int) -> String {
        let c = self;
        let r = c.index(c.startIndex, offsetBy: i)..<c.index(c.endIndex, offsetBy: i+1)
        return String(self[r])
    }
    
    var length:Int {
        return self.count
    }
    
    var localized:String {
        return NSLocalizedString(self, tableName:"Localizable", comment:"")
    }
    
    // parse string as yyyy-MM-dd HH:mm:ss into NSDate
    func toNormalDate() -> NSDate? {
        let result = toNormalDate(format: "yyyy-MM-dd HH:mm:ss")
        return result
    }
    
    func toNormalDate(format: String) -> NSDate? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self) as NSDate?
    }
    
    func leftTrim() -> String {
        var vsString = self
        while vsString.count > 0 {
            if vsString.first == " " {
                vsString.remove(at: startIndex)
            }
            else {
                break
            }
        }
        return vsString
    }

    func trimed() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    static func getStringIndex(stringArray: [String], stringToFind: String) -> Int {
        for (index, item) in stringArray.enumerated() {
            if item == stringToFind {
                return index
            }
        }
        return -1
    }
    
    mutating func addValue(newValue: String) {
        
        if newValue == "" {
            return
        }
        if self.strictContains(value: newValue) == false {
            if self == "" {
                self = newValue
            }
            else {
                self = "\(self),\(newValue)"
            }
        }
    }
    
    mutating func removeValue(removeValue: String) {
        
        if removeValue == "" {
            return
        }
        if self.strictContains(value: removeValue) == true {
            let components = self.components(separatedBy: ",")
            var newComponents:[String] = []
            for part in components {
                if part != removeValue {
                    newComponents.append(part)
                }
            }
            self = newComponents.joined(separator: ",")
        }
    }
    
    mutating func addOrRemoveValue(value: String) -> Bool {
        if value == "" {
            return false
        }
        
        if self.strictContains(value: value) == false {
            addValue(newValue: value)
            return true
        }
        else {
            removeValue(removeValue: value)
            return false
        }
    }
    
    func strictContains(value: String) -> Bool {
        
        if self == "" || value == "" {
            return false
        }
        
        let components = self.components(separatedBy: ",")
        
        for part in components {
            if part == value {
                return true
            }
        }
        return false
    }
    
    var isValidEmail: Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: self)
        
        return result
    }
    
    var isValidPwd: Bool {
        return self.count != 0
    }
    
    var isNumeric: Bool {
        let scanner = Scanner(string: self)
        let isNumeric = scanner.scanInt(nil) && scanner.isAtEnd
        return isNumeric
    }
    
    static func getWrappedString(value: String?, defaultValue: String = "") -> String {
        if value == nil {
            return defaultValue
        }
        else {
            return value!
        }
    }
}

// MARK: -file operation related
extension String {
    
    static func getFilenameFromPath(filePath: String) -> String {
        let theFileName = (filePath as NSString).lastPathComponent
        return theFileName
    }

    static func getFileDir(filePath: String) -> String {
        let theFileName = (filePath as NSString).lastPathComponent
        return filePath.subString(startIndex: 0, length: filePath.length-theFileName.length-1)
    }
    
    static func getFileExtensionFromPath(filePath: String) -> String {
        let filename = getFilenameFromPath(filePath: filePath)
        let components = filename.components(separatedBy: ".")
        if components.count == 1 {
            return ""
        }
        guard let lastComponent = components.last else {return ""}
        return lastComponent
    }
}

// MARK: -String size
extension String {

    /*
    func height(withConstrainedWidth width: CGFloat, attributes: [String: Any]) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary(attributes), context: nil)

        return boundingBox.height
    }

    func width(withConstraintedHeight height: CGFloat, attributes: [String: Any]) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary(attributes), context: nil)

        return boundingBox.width
    }*/

    func height(withConstrainedWidth width: CGFloat, attributes: [NSAttributedString.Key: Any]) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)

        return boundingBox.height
    }

    func width(withConstraintedHeight height: CGFloat, attributes: [NSAttributedString.Key: Any]) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)

        return boundingBox.width
    }
}

extension String {

    var pairs: [String] {
        var result: [String] = []
        let characters = Array(self)
        stride(from: 0, to: characters.count, by: 2).forEach {
            result.append(String(characters[$0..<min($0+2, characters.count)]))
        }
        return result
    }

    mutating func insertFromBack(separator: String, every n: Int) {
        self = insertingFromBack(separator: separator, every: n)
    }

    func insertingFromBack(separator: String, every n: Int) -> String {
        var result: String = ""
        let characters = Array(self)
        var index = characters.count-1
        while index >= 0 {
            result = String(characters[max(index-n+1, 0)...index]) + result
            if index-n >= 0 {
                result = separator + result
            }
            index -= n
        }
        return result
    }

    func uppercasedPrefix() -> String {
        if self.count == 0 {
            return ""
        }
        let firstCharactor = String(self.first!)
        return firstCharactor.uppercased()
    }

    func subString(startIndex: Int, length: Int) -> String {
        let nsString = self as NSString
        let range = NSMakeRange(startIndex, length)
        return nsString.substring(with: range)
    }

    static func isNullOrEmpty(value: String?) -> Bool {
        guard let _value = value else {return true}
        if _value == "" {
            return true
        }
        else {
            return false
        }
    }

    func unescapeSpecialCharacters() -> String {
        var newString = self

        // newString = newString.replacingOccurrences(of: "&amp;", with: "&")
        let char_dictionary = [
            "&amp;lt;": "&lt;",
            "&amp;gt;": "&gt;",
            "&amp;quot;": "&quot;",
            "&amp;apos;": "&apos;"
        ];
        for (escaped_char, unescaped_char) in char_dictionary {
            newString = newString.replacingOccurrences(of: escaped_char, with: unescaped_char)
        }
        //newString = newString.replacingOccurrences(of: "&amp;", with: "&")
        return newString
    }

}
