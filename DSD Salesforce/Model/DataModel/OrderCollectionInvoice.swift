//
//  OrderCollectionInvoice.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 9/1/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import Foundation

class OrderCollectionInvoice: NSObject {
    var invoiceDate: String = ""
    var trxnType: String = ""
    var trxnAmount: Double = 0
    var invoiceNo: String = ""
    var arHeader: ARHeader?

    func updateBy(arHeader: ARHeader) {
        
    }
}
