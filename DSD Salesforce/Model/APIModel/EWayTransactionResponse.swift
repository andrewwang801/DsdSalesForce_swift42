//
//  EWayTransactionResponse.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 5/29/19.
//  Copyright © 2019 iOS Developer. All rights reserved.
//

import Foundation


/*
 class RoutificSolution {

 var vehicle_1 = [RoutificLocation]()

 init(json: JSON) {
 vehicle_1.removeAll()
 if let jsonArray = json["vehicle_1"].array {
 for locationJSON in jsonArray {
 let location = RoutificLocation(json: locationJSON)
 vehicle_1.append(location)
 }
 }
 }
 }*/

class EWayTransactionResponse {

    class Transaction {
        var authorisationCode = ""
        var responseCode = ""
        var responseMessage = ""
        var invoiceNumber = ""
        var transactionID = ""
        var transactionStatus = ""

        init(json: JSON) {
            authorisationCode = json["AuthorisationCode"].stringValue
            responseCode = json["ResponseCode"].stringValue
            responseMessage = json["ResponseMessage"].stringValue
            invoiceNumber = json["InvoiceNumber"].stringValue
            transactionID = json["TransactionID"].stringValue
            transactionStatus = json["TransactionStatus"].stringValue
        }
    }

    var transactions = [Transaction]()
    var errors = ""

    init(json: JSON) {
        transactions.removeAll()
        errors = json["Errors"].stringValue

        if let jsonArray = json["Transactions"].array {
            for transactionJSON in jsonArray {
                let transaction = Transaction(json: transactionJSON)
                transactions.append(transaction)
            }
        }
    }
}
