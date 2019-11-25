//
//  Utility.swift
//  MyTaxPal
//
//  Created by iOS Developer on 5/21/16.
//  Copyright © 2016 Q-Scope. All rights reserved.
//

import Foundation
import UIKit

class Utility {
    
    static func getAppVersion() -> String {
        
        //First get the nsObject by defining as an optional anyObject
        let versionObject = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        
        //Then just cast the object as a String, but be careful, you may want to double check for nil
        let version = versionObject as? String
        return version ?? ""
    }

    static func getDeviceUUID() -> String {

        let uuidString = UIDevice.current.identifierForVendor?.uuidString ?? ""
        return uuidString
    }

    static func call(phoneNumber: String) {
        let number = phoneNumber.replacingOccurrences(of: " ", with: "")
        let numberKey = "tel://\(number)"
        guard let numberURL = URL(string: numberKey) else {return}
        UIApplication.shared.open(numberURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }

    /*
    static func remove(object: NSObject, out fromArray: [NSObject]) {
        if let index = fromArray.index(of: object) {
            fromArray.remove(at: index)
        }
    }*/
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
