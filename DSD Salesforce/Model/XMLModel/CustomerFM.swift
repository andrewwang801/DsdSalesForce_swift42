//
//  CustomerFM.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 8/1/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class CustomerContactFM: NSObject {
    var contactType = ""
    var contactName = ""
    var contactPhoneNumber = ""
    var contactEmailAddress = ""
}

class CustomerFM: NSObject {

    var chainNo = ""
    var custNo = ""
    var trxnNo = ""
    var docType = ""
    var startDate = ""
    var startTime = ""
    var endDate = ""
    var endTime = ""
    var trxnDate = ""
    var trxnTime = ""
    var voidFlag = ""
    var printedFlag = ""
    var reference = ""
    var tCOMStatus = ""
    var editType = ""
    var name = ""
    var address1 = ""
    var address2 = ""
    var city = ""
    var shipToState = ""
    var shipToZip = ""
    var phone = ""
    var taxID = ""
    var deliveryWindowFrom = ""
    var deliveryWindowTo = ""
    var orderType = ""

    var contactFMArray = [CustomerContactFM]()

    static var keyArray = ["TrxnNo", "ChainNo", "CustNo", "DocType", "StartDate", "StartTime", "EndDate", "EndTime", "TrxnDate", "TrxnTime", "VoidFlag", "PrintedFlag", "Reference", "TCOMStatus", "EditType", "Name", "Address1", "Address2", "City", "ShipToState", "ShipToZip", "Phone", "TaxID", "DeliveryWindowFrom", "DeliveryWindowTo", "OrderType", "ContactType1", "ContactName1", "ContactPhoneNumber1", "ContactEmailAddress1", "ContactType2", "ContactName2", "ContactPhoneNumber2", "ContactEmailAddress2", "ContactType3", "ContactName3", "ContactPhoneNumber3", "ContactEmailAddress3", "ContactType4", "ContactName4", "ContactPhoneNumber4", "ContactEmailAddress4", "ContactType5", "ContactName5", "ContactPhoneNumber5", "ContactEmailAddress5", "ContactType6", "ContactName6", "ContactPhoneNumber6", "ContactEmailAddress6"]

    func getDictionary() -> [String: String] {
        var dic = [String: String]()
        dic["ChainNo"] = chainNo
        dic["CustNo"] = custNo
        dic["TrxnNo"] = trxnNo
        dic["DocType"] = docType
        dic["StartDate"] = startDate
        dic["StartTime"] = startTime
        dic["EndDate"] = endDate
        dic["EndTime"] = endTime
        dic["TrxnDate"] = trxnDate
        dic["TrxnTime"] = trxnTime
        dic["VoidFlag"] = voidFlag
        dic["PrintedFlag"] = printedFlag
        dic["Reference"] = reference
        dic["TCOMStatus"] = tCOMStatus
        dic["EditType"] = editType
        dic["Name"] = name
        dic["Address1"] = address1
        dic["Address2"] = address2
        dic["City"] = city
        dic["ShipToState"] = shipToState
        dic["ShipToZip"] = shipToZip
        dic["Phone"] = phone
        dic["TaxID"] = taxID
        dic["DeliveryWindowFrom"] = deliveryWindowFrom
        dic["DeliveryWindowTo"] = deliveryWindowTo
        dic["OrderType"] = orderType

        for index in 0..<6 {
            if index < contactFMArray.count {
                let contact = contactFMArray[index]
                dic["ContactType\(index+1)"] = contact.contactType
                dic["ContactName\(index+1)"] = contact.contactName
                dic["ContactPhoneNumber\(index+1)"] = contact.contactPhoneNumber
                dic["ContactEmailAddress\(index+1)"] = contact.contactEmailAddress
            }
            else {
                dic["ContactType\(index+1)"] = ""
                dic["ContactName\(index+1)"] = ""
                dic["ContactPhoneNumber\(index+1)"] = ""
                dic["ContactEmailAddress\(index+1)"] = ""
            }
        }
        return dic
    }

    static func saveToXML(customerFMArray: [CustomerFM], filePath: String) {

        var dicArray = [[String: String]]()
        for customerFM in customerFMArray {
            let dictionary = customerFM.getDictionary()
            dicArray.append(dictionary)
        }
        Utils.saveToXML(dicArray: dicArray, keyArray: keyArray, rootName: "CustomerFMs", branchName: "CustomerFM", filePath: filePath)
    }
}
