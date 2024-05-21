//
//  UInvenH.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 8/22/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import Foundation

class UInvenH: NSObject {
    var trxnNo = "0"
    var custNo = "0"
    var trxnDate = ""
    var trxnTime = ""
    var reference = ""
    var signatureFilePath = ""
    var docType = "IVUP"

    var uInvenDArray = [UInvenD]()
    var truckArray = [UInvenD]()
    var containerArray = [UInvenD]()
}
