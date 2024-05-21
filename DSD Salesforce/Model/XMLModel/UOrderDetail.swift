//
//  UOrderDetail.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 9/9/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class UOrderDetail: NSObject {

    var trxnNo = ""
    var trxnType = ""
    var locnNo = ""
    var itemNo = ""
    var priceOverride = ""
    var quantity = ""
    var dumps = ""
    var sales = ""
    var grossPrice = ""
    var totalAllowance = ""

    var retailPrice = ""
    var retailOverride = ""
    var reasonCode = ""
    var weightedItem = ""
    var taxAmount = ""
    var presoldQuantity = ""
    var printOnOrder = ""
    var isKitItem = ""
    var extendAmount = ""
    var user1 = ""

    var user2 = ""
    var totalWeight = ""
    var forecastStartDate = ""
    var forecastEndDate = ""
    var origForecastQty = ""
    var priceDiscFlag = ""
    var retailPriceFlag = ""
    var discRateEntered = ""
    var user3 = ""
    var custPrice = ""

    var offInvPromoAmtDtl = ""
    var totalAllowExtended = ""
    var quantityCompl = ""
    var caseFactor = ""
    var discInLieuAmtDtl = ""
    var custRetailPrice = ""
    var custPriceExtended = ""

    var promotionArray = [UPromotion]()
    var taxArray = [UTax]()

    static var keyArray = ["TrxnNo", "TrxnType", "LocnNo", "ItemNo", "PriceOverride", "Quantity", "Dumps", "Sales", "GrossPrice", "TotalAllowance", "RetailPrice", "RetailOverride", "ReasonCode", "WeightedItem", "TaxAmount", "PresoldQuantity", "PrintOnOrder", "IsKitItem", "ExtendAmount", "User1", "User2", "TotalWeight", "ForecastStartDate", "ForecastEndDate", "OrigForecastQty", "PriceDiscFlag", "RetailPriceFlag", "DiscRateEntered", "User3", "CustPrice", "OffInvPromoAmtDtl", "TotalAllowExtended", "QuantityCompl", "CaseFactor", "DiscInLieuAmtDtl", "CustRetailPrice", "CustPriceExtended", "ExtendAmount"]

    func getDictionary() -> [String: String] {
        var dic = [String: String]()
        dic["TrxnNo"] = trxnNo
        dic["TrxnType"] = trxnType
        dic["LocnNo"] = locnNo
        dic["ItemNo"] = itemNo
        dic["PriceOverride"] = priceOverride
        dic["Quantity"] = quantity
        dic["Dumps"] = dumps
        dic["Sales"] = sales
        dic["GrossPrice"] = grossPrice
        dic["TotalAllowance"] = totalAllowance
        dic["RetailPrice"] = retailPrice
        dic["RetailOverride"] = retailOverride
        dic["ReasonCode"] = reasonCode
        dic["WeightedItem"] = weightedItem
        dic["TaxAmount"] = taxAmount
        dic["PresoldQuantity"] = presoldQuantity
        dic["PrintOnOrder"] = printOnOrder
        dic["IsKitItem"] = isKitItem
        dic["ExtendAmount"] = extendAmount
        dic["User1"] = user1
        dic["User2"] = user2
        dic["TotalWeight"] = totalWeight
        dic["ForecastStartDate"] = forecastStartDate
        dic["ForecastEndDate"] = forecastEndDate
        dic["OrigForecastQty"] = origForecastQty
        dic["PriceDiscFlag"] = priceDiscFlag
        dic["RetailPriceFlag"] = retailPriceFlag
        dic["DiscRateEntered"] = discRateEntered
        dic["User3"] = user3
        dic["CustPrice"] = custPrice
        dic["OffInvPromoAmtDtl"] = offInvPromoAmtDtl
        dic["TotalAllowExtended"] = totalAllowExtended
        dic["QuantityCompl"] = totalAllowExtended
        dic["CaseFactor"] = caseFactor
        dic["DiscInLieuAmtDtl"] = discInLieuAmtDtl
        dic["CustRetailPrice"] = custRetailPrice
        dic["CustPriceExtended"] = custPriceExtended
        dic["ExtendAmount"] = extendAmount
        return dic
    }
}
