//
//  Terms.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 8/13/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import Foundation

class Terms: NSObject {

    static func loadFromXML() -> String? {

        let filePath = CommData.getFilePathAppended(byCacheDir: "\(kReportsDirName)/\(kPrintTermsTemplateFileName)") ?? ""
        let url = URL(fileURLWithPath: filePath)
        guard let xmlData = try? Data(contentsOf: url) else {return nil}
        var totalTerms = ""

        do {
            let doc = try GDataXMLDocument(data: xmlData, options: 0)
            let elementArray = try doc.nodes(forXPath: "//Table[@property='terms']/Cell/Phrase")

            for _childElement in elementArray {
                let childElement = _childElement as! GDataXMLElement
                guard let _theTextElement = childElement.children().first else {continue}
                let textNode = _theTextElement as! GDataXMLNode
                let termsItemText = textNode.stringValue() ?? ""
                totalTerms += termsItemText + "\n"
            }
            if totalTerms.isEmpty == false {
                totalTerms = "\n" + totalTerms
            }
            return totalTerms
        }
        catch let error as NSError {
            NSLog("Load \(kPrintTermsTemplateFileName) failed: \(error.localizedDescription)")
            return nil
        }
    }
}
