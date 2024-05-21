//
//  OrderSalesOrder.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/11/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import Foundation

class OrderSalesOrder: NSObject {

    var presoldOrDetail: PresoldOrDetail?
    var authDetail: AuthDetail?
    var productDetail: ProductDetail?
    var orderHistoryItem: OrderHistoryItem?
    var taxRates: TaxRates?
    var promotionPlanArray = [PromotionPlan]()
    var custNo: String = ""
    var planQty = 0
    var enterQty = 0
    var price: Double = 0
    var lastOrder: String = ""
    var trxnType: Int = 0
    var nDeliveryCount = 0
    var nCreditCount = 0
    var reasonCode = "0"

    func duplicate() -> OrderSalesOrder {
        let newOrderSalesOrder = OrderSalesOrder()
        newOrderSalesOrder.presoldOrDetail = presoldOrDetail
        newOrderSalesOrder.productDetail = productDetail
        newOrderSalesOrder.taxRates = taxRates
        newOrderSalesOrder.custNo = custNo
        newOrderSalesOrder.planQty = planQty
        newOrderSalesOrder.enterQty = enterQty
        newOrderSalesOrder.price = price
        newOrderSalesOrder.lastOrder = lastOrder
        newOrderSalesOrder.trxnType = trxnType
        newOrderSalesOrder.nDeliveryCount = nDeliveryCount
        newOrderSalesOrder.nCreditCount = nCreditCount
        newOrderSalesOrder.reasonCode = reasonCode
        return newOrderSalesOrder
    }

    func isFromOriginal() -> Bool {
        return presoldOrDetail != nil || authDetail != nil || orderHistoryItem != nil
    }

}
