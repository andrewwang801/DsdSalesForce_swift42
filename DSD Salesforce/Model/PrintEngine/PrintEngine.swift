//
//  PrintEngine.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 8/14/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import Foundation

class PrintMetaData: NSObject {
    var pageSize: String = ""
    var pageWidth: CGFloat = 0
    var pageHeight: CGFloat = 0
    var marginLeft: CGFloat = 0
    var marginRight: CGFloat = 0
    var marginTop: CGFloat = 0
    var marginBottom: CGFloat = 0
}

class PrintEngine: NSObject {

    let globalInfo = GlobalInfo.shared
    var dictionary = [String: Any]()
    var dictionaryArray = [String: Any]()
    var printMetaData = PrintMetaData()
    var printPDFPath = ""
    var htmlContent = ""
    var isRMA = false
    static var templatePath = ""
    var isForOnePage = false

    var completionHandler: ((Bool)->())?
    var hud: MBProgressHUD?

    override init() {

    }

    func prepareTermsPrint(filePath: String, name: String, customerDetail: CustomerDetail, equipment: Equipment) {

        dictionary = [:]
        dictionary["logo"] = CommData.getFilePathAppended(byDocumentDir: kReportsDirName+"/"+kCompanyLogoFileName)
        dictionary["Sign"] = filePath

        let docTextArray = DocText.getBy(context: globalInfo.managedObjectContext, textType: "6")
        var headerDocTextArray = [String]()
        for docText in docTextArray {
            let _docText = docText.docText ?? ""
            if _docText.isEmpty == true {
                headerDocTextArray.append(" ")
            }
            else {
                headerDocTextArray.append(_docText)
            }
        }
        dictionary["HeaderDocText"] = headerDocTextArray

        let now = Date()
        let dateString = now.toDateString(format: "dd/MM/yyyy") ?? ""
        dictionary["PrintedName"] = name
        dictionary["SignedDate"] = dateString
        dictionary["BusinessName"] = "Business Name: " + (customerDetail.name ?? "")
        let address1 = customerDetail.address1 ?? ""
        let address2 = customerDetail.address2 ?? ""
        dictionary["BusinessAddress"] = "Business Address: " + address1 + " " + address2
        dictionary["OnDate"] = "On date: " + dateString
        let model = equipment.model ?? ""
        let equipmentDesc = equipment.desc ?? ""
        dictionary["Refrigerator"] = "For provision of refrigerator (please specify model, size): " + model + ", " + equipmentDesc
    }

    func prepareCashPrint(customerDetail: CustomerDetail, uar: UAR) {

        dictionary = [:]
        dictionaryArray = [:]

        dictionary["logo"] = CommData.getFilePathAppended(byDocumentDir: kReportsDirName+"/"+kCompanyLogoFileName)

        let managedObjectContext = globalInfo.managedObjectContext!
        let chainNo = customerDetail.chainNo ?? ""
        let custNo = customerDetail.custNo ?? ""
        var docTextArray = [DocText]()
        for i in 6...7 {
            var _docTextArray = DocText.getBy(context: managedObjectContext, chainNo: chainNo, custNo: custNo, textType: "\(i)")
            if _docTextArray.count == 0 {
                _docTextArray = DocText.getBy(context: managedObjectContext, textType: "\(i)")
            }
            if _docTextArray.count == 0 {
                _docTextArray = DocText.getBy(context: managedObjectContext, textType: "\(i)")
            }
            if _docTextArray.count > 0 {
                docTextArray.append(contentsOf: _docTextArray)
            }
        }

        var headerDocTextArray = [String]()
        for docText in docTextArray {
            let textType = docText.textType ?? ""
            let docText = docText.docText ?? ""
            if textType == "6" {
                if docText.length == 0 {
                    headerDocTextArray.append(" ")
                }
                else {
                    headerDocTextArray.append(docText)
                }
            }
        }
        dictionary["HeaderDocText"] = headerDocTextArray
        dictionary["InvoiceNo"] = uar.docNo

        // Cash Date
        let cashDateString = Date().toDateString(format: "dd/MM/yyyy") ?? " "
        dictionary["CashDate"] = cashDateString

        // Time
        let tiemString = Date().toDateString(format: "HH:mm") ?? " "
        dictionary["Time"] = tiemString

        // InvoiceCustomerCode
        let altCustNo = customerDetail.altCustNo ?? ""
        if altCustNo == "" {
            if chainNo == "0" {
                dictionary["InvoiceCustomerCode"] = custNo
            }
            else {
                dictionary["InvoiceCustomerCode"] = chainNo + "/" + custNo
            }
        }
        else {
            dictionary["InvoiceCustomerCode"] = altCustNo
        }

        // InvoiceTo1
        let name = customerDetail.name ?? ""
        dictionary["InvoiceTo1"] = name != "" ? name : " "

        let address1 = customerDetail.address1 ?? ""
        dictionary["InvoiceTo2"] = address1 != "" ? address1 : " "

        let city = customerDetail.city ?? ""
        let shipToState = customerDetail.shipToState ?? ""
        let shipToZip = customerDetail.shipToState ?? ""
        dictionary["InvoiceTo3"] = city + " " + shipToState + " " + shipToZip

        dictionary["DeliverAccount"] = customerDetail.billName ?? ""

        var cashPayment: UARPayment?
        var chequePayment: UARPayment?
        var cardPayment: UARPayment?
        let paymentSet = uar.uarPaymentSet
        for _payment in paymentSet {
            let payment = _payment as! UARPayment
            if payment.paymentType == "\(kCollectionCash)" {
                cashPayment = payment
            }
            if payment.paymentType == "\(kCollectionCheque)" {
                chequePayment = payment
            }
            if payment.paymentType == "\(kCollectionCard)" {
                cardPayment = payment
            }
        }

        var paymentArray = [[String: String]]()
        let nTotalCash = Utils.getXMLDivided(valueString: cashPayment?.trxnAmount ?? "0")
        let nChequeAmount = Utils.getXMLDivided(valueString: chequePayment?.trxnAmount ?? "0")
        let nCardAmount = Utils.getXMLDivided(valueString: cardPayment?.trxnAmount ?? "0")
        let currentSymbol = globalInfo.routeControl?.currencySymbol ?? "$"
        if nTotalCash > 0 {
            var itemMap = [String: String]()
            itemMap["first"] = "Cash"
            itemMap["second"] = " "
            itemMap["third"] = " "
            paymentArray.append(itemMap)

            itemMap = [:]
            itemMap["first"] = " "
            itemMap["second"] = " "
            itemMap["third"] = currentSymbol + nTotalCash.exactTwoDecimalString
            paymentArray.append(itemMap)
        }
        if nChequeAmount > 0 {
            var itemMap = [String: String]()
            itemMap["first"] = "Cheque"
            itemMap["second"] = " "
            itemMap["third"] = " "
            paymentArray.append(itemMap)

            itemMap = [:]
            itemMap["first"] = "Account #"
            itemMap["second"] = chequePayment!.account
            itemMap["third"] = " "
            paymentArray.append(itemMap)

            itemMap = [:]
            itemMap["first"] = "Cheque #"
            itemMap["second"] = chequePayment!.checkNo
            itemMap["third"] = " "
            paymentArray.append(itemMap)

            itemMap = [:]
            itemMap["first"] = " "
            itemMap["second"] = " "
            itemMap["third"] = currentSymbol + nChequeAmount.exactTwoDecimalString
            paymentArray.append(itemMap)
        }
        if nCardAmount > 0 {
            var itemMap = [String: String]()
            itemMap["first"] = "Card"
            itemMap["second"] = " "
            itemMap["third"] = " "
            paymentArray.append(itemMap)

            itemMap = [:]
            itemMap["first"] = " "
            itemMap["second"] = "Reference Number"
            itemMap["third"] = cardPayment!.invNo
            paymentArray.append(itemMap)

            itemMap = [:]
            itemMap["first"] = " "
            itemMap["second"] = "AR Notes"
            itemMap["third"] = cardPayment!.arNotes
            paymentArray.append(itemMap)

            itemMap = [:]
            itemMap["first"] = " "
            itemMap["second"] = " "
            itemMap["third"] = currentSymbol + nCardAmount.exactTwoDecimalString
            paymentArray.append(itemMap)
        }

        dictionary["Payment"] = paymentArray

        let totalAmount = Utils.getXMLDivided(valueString: uar.invAmt)
        dictionary["Total"] = currentSymbol + totalAmount.exactTwoDecimalString

        var footerDocText = [String]()
        for docText in docTextArray {
            let textType = docText.textType ?? ""
            let _docText = docText.docText ?? ""
            if textType == "7" {
                if _docText == "" {
                    footerDocText.append(" ")
                }
                else {
                    footerDocText.append(_docText)
                }
            }
        }
        dictionary["FooterDocText"] = footerDocText
    }

    func prepareCollectionPrint(uarPaymentArray: [[UARPayment]], docNo: String) {

        dictionary = [:]
        dictionaryArray = [:]

        var cashArray = [[String: String]]()
        var chequeArray = [[String: String]]()
        var cardArray = [[String: String]]()

        var nCashTotal: Double = 0
        var nChequeTotal: Double = 0
        var nCardTotal: Double = 0
        var nTotal: Double = 0

        var paymentArray = [UARPayment]()
        paymentArray.append(contentsOf: uarPaymentArray[0])
        paymentArray.append(contentsOf: uarPaymentArray[1])
        paymentArray.append(contentsOf: uarPaymentArray[2])

        let currentSymbol = globalInfo.routeControl?.currencySymbol ?? "$"
        var customerDictionary = [String: CustomerDetail]()
        for payment in paymentArray {
            let chainNo = payment.chainNo ?? "0"
            let custNo = payment.custNo ?? "0"
            let customerKey = "\(chainNo)_\(custNo)"

            var customerDetail = customerDictionary[customerKey]
            if customerDetail == nil {
                customerDetail = CustomerDetail.getBy(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo)
            }
            if customerDetail == nil {
                continue
            }

            var params = [String: String]()
            let date = Date.fromDateString(dateString: payment.trxnDate, format: kTightJustDateFormat) ?? Date()
            params["date"] = date.toDateString(format: "dd/MM/yy") ?? " "

            let customerName = customerDetail!.name ?? ""
            params["customer"] = customerName

            let trxnAmount = Utils.getXMLDivided(valueString: payment.trxnAmount)

            params["amount"] = currentSymbol+trxnAmount.exactTwoDecimalString

            let paymentType = payment.paymentType ?? ""

            if paymentType == "\(kCollectionCash)" {
                nCashTotal += trxnAmount
                cashArray.append(params)
            }
            else if paymentType == "\(kCollectionCheque)" {
                nChequeTotal += trxnAmount
                chequeArray.append(params)
            }
            else if paymentType == "\(kCollectionCard)" {
                nCardTotal += trxnAmount
                cardArray.append(params)
            }
            nTotal += trxnAmount
        }

        dictionary["Cash"] = cashArray
        dictionary["Cheque"] = chequeArray
        dictionary["Card"] = cardArray
        dictionary["CashAmount"] = currentSymbol+nCashTotal.exactTwoDecimalString
        dictionary["ChequeAmount"] = currentSymbol+nChequeTotal.exactTwoDecimalString
        dictionary["CardAmount"] = currentSymbol+nCardTotal.exactTwoDecimalString
        dictionary["CollectionAmount"] = currentSymbol+nTotal.exactTwoDecimalString
    }

    func preparePrint(customerDetail: CustomerDetail, printArray: [OrderDetail], nPayType: Int, previousInvoiceAmount: Double) {

        dictionary = [:]
        dictionaryArray = [:]

        dictionary["logo"] = CommData.getFilePathAppended(byDocumentDir: kReportsDirName+"/"+kCompanyLogoFileName)

        let inventoryUOM = globalInfo.routeControl?.inventoryUOM ?? ""
        let isShowCase = inventoryUOM != "U"

        let managedObjectContext = globalInfo.managedObjectContext!
        let chainNo = customerDetail.chainNo ?? ""
        let custNo = customerDetail.custNo ?? ""
        var docTextArray = [DocText]()
        for i in 6...7 {
            var _docTextArray = DocText.getBy(context: managedObjectContext, chainNo: chainNo, custNo: custNo, textType: "\(i)")
            if _docTextArray.count == 0 {
                _docTextArray = DocText.getBy(context: managedObjectContext, textType: "\(i)")
            }
            if _docTextArray.count == 0 {
                _docTextArray = DocText.getBy(context: managedObjectContext, textType: "\(i)")
            }
            if _docTextArray.count > 0 {
                docTextArray.append(contentsOf: _docTextArray)
            }
        }

        var headerDocTextArray = [String]()
        for docText in docTextArray {
            let textType = docText.textType ?? ""
            let docText = docText.docText ?? ""
            if textType == "6" {
                if docText.length == 0 {
                    headerDocTextArray.append(" ")
                }
                else {
                    headerDocTextArray.append(docText)
                }
            }
        }
        dictionary["HeaderDocText"] = headerDocTextArray

        // invoice No
        dictionary["InvoiceNo"] = globalInfo.orderHeader.docNo != "" ? globalInfo.orderHeader.docNo ?? "" : " "
        dictionary["PONo"] = globalInfo.orderHeader.poReference != "" ? globalInfo.orderHeader.poReference : " "

        let trxnDateValue = Date.fromDateString(dateString: globalInfo.orderHeader.trxnDate, format: kTightJustDateFormat) ?? Date()
        let trxnDateString = trxnDateValue.toDateString(format: "dd/MM/yyyy") ?? ""
        dictionary["InvoiceDate"] = trxnDateString != "" ? trxnDateString : " "

        let trxnTimeValue = Date.fromDateString(dateString: globalInfo.orderHeader.trxnTime, format: kTightJustTimeFormat) ?? Date()
        let trxnTimeString = trxnTimeValue.toDateString(format: "HH:mm") ?? ""
        dictionary["Time"] = trxnTimeString != "" ? trxnTimeString : " "

        let terms = customerDetail.terms ?? ""
        dictionary["Terms"] = terms != "" ? terms : " "

        let altCustNo = customerDetail.altCustNo ?? ""
        if altCustNo == "" {
            if chainNo == "0" {
                dictionary["InvoiceCustomerCode"] = custNo
            }
            else {
                dictionary["InvoiceCustomerCode"] = chainNo + "/" + custNo
            }
        }
        else {
            dictionary["InvoiceCustomerCode"] = altCustNo
        }

        // InvoiceTo1
        let name = customerDetail.name ?? ""
        dictionary["InvoiceTo1"] = name != "" ? name : " "

        let address1 = customerDetail.address1 ?? ""
        dictionary["InvoiceTo2"] = address1 != "" ? address1 : " "

        let address2 = customerDetail.address2 ?? ""
        dictionary["InvoiceTo4"] = address2 != "" ? address2 : " "

        let city = customerDetail.city ?? ""
        let shipToState = customerDetail.shipToState ?? ""
        let shipToZip = customerDetail.shipToState ?? ""
        dictionary["InvoiceTo3"] = city + " " + shipToState + " " + shipToZip

        dictionary["DeliverAccount"] = customerDetail.billName ?? ""

        let currencySymbol = globalInfo.routeControl?.currencySymbol ?? ""
        dictionary["PreviousAccountBalance"] = currencySymbol + previousInvoiceAmount.exactTwoDecimalString

        // order item list
        var deliveryArray = [OrderDetail]()
        var replaceArray = [OrderDetail]()
        var containerArray = [OrderDetail]()
        var buybackArray = [OrderDetail]()

        for orderDetail in printArray {
            let enterQty = orderDetail.enterQty
            if enterQty == 0 {
                continue
            }
            let itemNo = orderDetail.itemNo!
            let trxnType = orderDetail.trxnType.int
            let scwType = Utils.getProductLoconSCWType(itemNo: itemNo)
            if (scwType == kInventoryTruck || scwType == kWeightItem) && (trxnType == kTrxnDeliver || trxnType == kTrxnFree || trxnType == kTrxnSample) {
                deliveryArray.append(orderDetail)

                // get free item
            }
            else if (scwType == kInventoryTruck || scwType == kWeightItem) && (trxnType == kTrxnPickup) {
                replaceArray.append(orderDetail)
            }
            else if (scwType == kInventoryTruck || scwType == kWeightItem) && (trxnType == kTrxnBuyBack) {
                buybackArray.append(orderDetail)
            }
            else if scwType == kInventoryContainers {
                containerArray.append(orderDetail)
            }
        }

        var itemArray = [OrderDetail]()
        var itemDictionary = [String: OrderDetail]()
        var nDeliveryCount = 0
        var nCreditCount = 0
        var dDeliveryValue: Double = 0
        var dCreditValue: Double = 0

        // Delivery
        if deliveryArray.count > 0 {
            var deliveryDictionaryArray = [[String: String]]()
            for delivery in deliveryArray {
                var deliveryDictionary = [String: String]()
                let itemNo = delivery.itemNo!
                deliveryDictionary["code"] = itemNo
                deliveryDictionary["description"] = delivery.desc
                let scwType = Utils.getProductLoconSCWType(itemNo: itemNo)
                if scwType != kWeightItem {
                    if isShowCase == true {
                        let nCase = Utils.getCaseValue(itemNo: itemNo)
                        let nCaseValue = delivery.enterQty.int / nCase
                        let nQty = delivery.enterQty.int % nCase
                        deliveryDictionary["qty"] = "\(nCaseValue)/\(nQty)"
                        deliveryDictionary["qty_cs_un"] = "\(nCaseValue)/\(nQty)"
                        deliveryDictionary["qty_un"] = "\(delivery.enterQty)"

                        var price = delivery.price
                        price += 0
                        // promotion info
                        deliveryDictionary["price"] = Utils.getMoneyString(moneyValue: price)
                        deliveryDictionary["total"] = Utils.getMoneyString(moneyValue: price*Double(delivery.enterQty))
                        deliveryDictionaryArray.append(deliveryDictionary)
                    }
                    else {
                        let nQty = delivery.enterQty
                        deliveryDictionary["qty"] = "\(nQty)"
                        deliveryDictionary["qty_cs_un"] = "\(nQty)"
                        deliveryDictionary["qty_un"] = "\(nQty)"

                        var price = delivery.price
                        price += 0
                        // promotion info
                        deliveryDictionary["price"] = Utils.getMoneyString(moneyValue: price)
                        deliveryDictionary["total"] = Utils.getMoneyString(moneyValue: price*Double(delivery.enterQty))
                        deliveryDictionaryArray.append(deliveryDictionary)
                    }
                }

                if scwType != kWeightItem {
                    if itemDictionary[itemNo] == nil {
                        let item = OrderDetail(context: managedObjectContext, forSave: true)
                        item.updateBy(context: managedObjectContext, theSource: delivery)
                        item.deliveryCount += delivery.enterQty
                        itemArray.append(item)
                        itemDictionary[itemNo] = item
                        nDeliveryCount += delivery.enterQty.int
                    }
                    else {
                        itemDictionary[itemNo]!.deliveryCount += delivery.enterQty
                        nDeliveryCount += delivery.enterQty.int
                    }
                }
            }
            dictionary["Delivery"] = deliveryDictionaryArray
        }

        // Replace
        if replaceArray.count > 0 {
            var replaceDictionaryArray = [[String: String]]()
            for replace in replaceArray {
                var replaceDictionary = [String: String]()
                let itemNo = replace.itemNo!
                replaceDictionary["code"] = itemNo
                replaceDictionary["description"] = replace.desc!
                let scwType = Utils.getProductLoconSCWType(itemNo: itemNo)
                if scwType != kWeightItem {
                    if isShowCase == true {
                        let nCase = Utils.getCaseValue(itemNo: itemNo)
                        let nCaseValue = replace.enterQty.int / nCase
                        let nQty = replace.enterQty.int % nCase
                        replaceDictionary["qty"] = "\(nCaseValue)/\(nQty)"
                        replaceDictionary["qty_cs_un"] = "\(nCaseValue)/\(nQty)"
                        replaceDictionary["qty_un"] = "\(replace.enterQty)"
                    }
                    else {
                        let nQty = replace.enterQty
                        replaceDictionary["qty"] = "\(nQty)"
                        replaceDictionary["qty_cs_un"] = "\(nQty)"
                        replaceDictionary["qty_un"] = "\(nQty)"
                    }

                    var price = replace.price
                    price += 0
                    if price != 0 {
                        replaceDictionary["price"] = "-"+Utils.getMoneyString(moneyValue: price)
                        replaceDictionary["total"] = "-"+Utils.getMoneyString(moneyValue: price*Double(replace.enterQty))
                    }
                    else {
                        replaceDictionary["price"] = Utils.getMoneyString(moneyValue: price)
                        replaceDictionary["total"] = Utils.getMoneyString(moneyValue: price*Double(replace.enterQty))
                    }
                    replaceDictionaryArray.append(replaceDictionary)

                    if itemDictionary[itemNo] == nil {
                        let item = OrderDetail(context: managedObjectContext, forSave: true)
                        item.updateBy(context: managedObjectContext, theSource: replace)
                        item.creditCount = replace.enterQty
                        itemArray.append(item)
                        itemDictionary[itemNo] = item
                        nCreditCount += replace.enterQty.int
                    }
                    else {
                        itemDictionary[itemNo]!.creditCount += replace.enterQty
                        nCreditCount += replace.enterQty.int
                    }
                }
            }
            dictionary["Credits"] = replaceDictionaryArray
        }

        // Buyback
        if buybackArray.count > 0 {
            var buybackDictionaryArray = [[String: String]]()
            for buyback in buybackArray {
                var buybackDictionary = [String: String]()
                let itemNo = buyback.itemNo!
                buybackDictionary["code"] = itemNo
                buybackDictionary["description"] = buyback.desc!
                let scwType = Utils.getProductLoconSCWType(itemNo: itemNo)
                if scwType != kWeightItem {
                    if isShowCase == true {
                        let nCase = Utils.getCaseValue(itemNo: itemNo)
                        let nCaseValue = buyback.enterQty.int / nCase
                        let nQty = buyback.enterQty.int % nCase
                        buybackDictionary["qty"] = "\(nCaseValue)/\(nQty)"
                        buybackDictionary["qty_cs_un"] = "\(nCaseValue)/\(nQty)"
                        buybackDictionary["qty_un"] = "\(buyback.enterQty)"
                    }
                    else {
                        let nQty = buyback.enterQty
                        buybackDictionary["qty"] = "\(nQty)"
                        buybackDictionary["qty_cs_un"] = "\(nQty)"
                        buybackDictionary["qty_un"] = "\(nQty)"
                    }

                    var price = buyback.price
                    price += 0
                    if price != 0 {
                        buybackDictionary["price"] = "-"+Utils.getMoneyString(moneyValue: price)
                        buybackDictionary["total"] = "-"+Utils.getMoneyString(moneyValue: price*Double(buyback.enterQty))
                    }
                    else {
                        buybackDictionary["price"] = Utils.getMoneyString(moneyValue: price)
                        buybackDictionary["total"] = Utils.getMoneyString(moneyValue: price*Double(buyback.enterQty))
                    }
                    buybackDictionaryArray.append(buybackDictionary)

                    if itemDictionary[itemNo] == nil {
                        let item = OrderDetail(context: managedObjectContext, forSave: true)
                        item.updateBy(context: managedObjectContext, theSource: buyback)
                        item.creditCount = buyback.enterQty
                        itemArray.append(item)
                        itemDictionary[itemNo] = item
                        nCreditCount += buyback.enterQty.int
                    }
                    else {
                        itemDictionary[itemNo]!.creditCount += buyback.enterQty
                        nCreditCount += buyback.enterQty.int
                    }
                }
            }
            dictionary["BuyBacks"] = buybackDictionaryArray
        }

        var itemDictionaryArray = [[String: String]]()
        for item in itemArray {
            var buybackDictionary = [String: String]()
            let itemNo = item.itemNo!
            buybackDictionary["code"] = itemNo
            buybackDictionary["description"] = item.desc

            if item.deliveryCount > 0 {
                buybackDictionary["dlvd_qty"] = "\(item.deliveryCount)"
            }
            else {
                buybackDictionary["dlvd_qty"] = " "
            }
            if item.deliveryCount > 0 {
                buybackDictionary["crdt_qty"] = "\(item.creditCount)"
            }
            else {
                buybackDictionary["crdt_qty"] = " "
            }

            var nPrice = item.price
            nPrice += 0
            // promotions

            let nCustPriceMainFlag = Int(customerDetail.custPriceMaintFlag ?? "") ?? 0
            if nCustPriceMainFlag > 0 {
                buybackDictionary["unit_price"] = Utils.getMoneyString(moneyValue: nPrice)
            }
            else {
                buybackDictionary["unit_price"] = " "
            }

            if nPrice != 0 {
                buybackDictionary["price"] = "-"+Utils.getMoneyString(moneyValue: nPrice)
                buybackDictionary["total"] = "-"+Utils.getMoneyString(moneyValue: nPrice*Double(item.enterQty))
            }
            else {
                buybackDictionary["price"] = Utils.getMoneyString(moneyValue: nPrice)
                buybackDictionary["total"] = Utils.getMoneyString(moneyValue: nPrice*Double(item.enterQty))
            }

            itemDictionaryArray.append(buybackDictionary)
        }

        dictionary["Item"] = itemDictionaryArray

        var nSalesAmount = 0.0
        if customerDetail.invoiceFmt == "2" {
            if isRMA {
                nSalesAmount -= globalInfo.orderHeader.pickupAmount
            }
            else {
                nSalesAmount = globalInfo.orderHeader.saleAmountOri
            }
        }
        else {
            nSalesAmount = globalInfo.orderHeader.saleAmount
        }
        
        var nQty = 0
        var nUnit = 0
        var dValue: Double = 0
        let salEntryMode = customerDetail.salEntryMode ?? ""

        for item in deliveryArray {
            let itemNo = item.itemNo!
            // promotion
            if isShowCase == true {
                if salEntryMode == "B" {
                    let nCase = Utils.getCaseValue(itemNo: itemNo)
                    nUnit += item.enterQty.int / nCase
                    nQty += item.enterQty.int % nCase
                }
                else {
                    nQty += item.enterQty.int
                }
            }
            else {
                nQty += item.enterQty.int
            }
        }

        for item in replaceArray {
            let itemNo = item.itemNo!
            // promotion
            if isShowCase == true {
                if salEntryMode == "B" {
                    let nCase = Utils.getCaseValue(itemNo: itemNo)
                    nUnit -= item.enterQty.int / nCase
                    nQty -= item.enterQty.int % nCase
                }
                else {
                    nQty -= item.enterQty.int
                }
            }
            else {
                nQty -= item.enterQty.int
            }
        }
        
        if customerDetail.invoiceFmt == "2" && isRMA {
            nQty = abs(nQty)
        }
        
        if isShowCase == true {
            if salEntryMode == "B" {
                if dValue > 0 && (nUnit > 0 || nQty > 0) {
                    dictionary["TotalQty"] = "\(nUnit)/\(nQty)\(dValue.exactTwoDecimalString)"
                }
                else if dValue > 0 {
                    dictionary["TotalQty"] = "\(dValue.exactTwoDecimalString)"
                }
                else {
                    dictionary["TotalQty"] = "\(nUnit)/\(nQty)"
                }
            }
            else {
                if dValue > 0 && nQty > 0 {
                    dictionary["TotalQty"] = "\(nQty)\(dValue.exactTwoDecimalString)"
                }
                else if dValue > 0 {
                    dictionary["TotalQty"] = "\(dValue.exactTwoDecimalString)"
                }
                else {
                    dictionary["TotalQty"] = "\(nQty)"
                }
            }
        }
        else {
            if dValue > 0 && nQty > 0 {
                dictionary["TotalQty"] = "\(nQty)\(dValue.exactTwoDecimalString)"
            }
            else if dValue > 0 {
                dictionary["TotalQty"] = "\(dValue.exactTwoDecimalString)"
            }
            else {
                dictionary["TotalQty"] = "\(nQty)"
            }
        }

        dictionary["SubTotal"] = nSalesAmount.exactTwoDecimalString
        if dDeliveryValue > 0 && nDeliveryCount > 0 {
            dictionary["DeliveryCount"] = "\(nDeliveryCount)\(dDeliveryValue.exactTwoDecimalString)"
        }
        else if dDeliveryValue > 0 {
            dictionary["DeliveryCount"] = "\(dDeliveryValue.exactTwoDecimalString)"
        }
        else {
            dictionary["DeliveryCount"] = "\(nDeliveryCount)"
        }

        if dCreditValue > 0 && nCreditCount > 0 {
            dictionary["CreditCount"] = "\(nCreditCount)\(dCreditValue.exactTwoDecimalString)"
        }
        else if dCreditValue > 0 {
            dictionary["CreditCount"] = "\(dCreditValue.exactTwoDecimalString)"
        }
        else {
            dictionary["CreditCount"] = "\(nCreditCount)"
        }

        var gstValueArray = [String]()
        var nTaxAmount = 0.0
        if customerDetail.invoiceFmt == "2" {
            if isRMA {
                nTaxAmount -= globalInfo.orderHeader.pickupTax
            }
            else {
                nTaxAmount = globalInfo.orderHeader.saleTax
            }
        }
        else {
            nTaxAmount = globalInfo.orderHeader.taxAmount
        }
        
        gstValueArray.append(nTaxAmount.exactTwoDecimalString)
        dictionary["GST"] = gstValueArray

        var centsRoundValueArray = [String]()
        let centsRound = globalInfo.routeControl?.centsRound ?? ""
        let payType = customerDetail.payType ?? ""
        if centsRound.trimed() == "1" && (payType == "1" || payType == "2") {
            var nTotal = Int((nSalesAmount+nTaxAmount)*Double(kXMLNumberDivider))
            var nOffset = nTotal%5000
            let nInvoiceTotal = ((nTotal/5000)+((nOffset>=2500) ? 1 : 0))*5000
            nOffset = nTotal % 1000
            nTotal = ((nTotal/1000)+((nOffset>=500) ? 1 : 0))*1000
            nOffset = nInvoiceTotal-nTotal
            let dOffset = Double(nOffset)/Double(kXMLNumberDivider)
            let dTotal = Double(nTotal)/Double(kXMLNumberDivider)
            centsRoundValueArray.append(dOffset.exactTwoDecimalString)
            let invoiceTotal = Double(nInvoiceTotal)/Double(kXMLNumberDivider)
            dictionary["InvoiceGSTTotal"] = invoiceTotal.exactTwoDecimalString
        }
        else {
            dictionary["InvoiceGSTTotal"] = (nSalesAmount+nTaxAmount).exactTwoDecimalString
        }
        dictionary["CentsRounding"] = centsRoundValueArray

        dictionary["Sign"] = globalInfo.orderHeader.signatureFilePath
        dictionary["ReceivedBy"] = "Received by: " + globalInfo.orderHeader.orderName

        if nPayType == 0 {
            dictionary["TotalPaid"] = "0.00"
        }
        else {
            dictionary["TotalPaid"] = globalInfo.orderHeader.realPayment.exactTwoDecimalString
        }

        dictionary["TotalDue"] = (globalInfo.dCurrentTotalValue-globalInfo.orderHeader.realPayment).exactTwoDecimalString

        let specialInstrument = globalInfo.orderHeader.specialInstruments ?? ""
        if specialInstrument != "" {
            var nStart = 0
            let textArray = specialInstrument.components(separatedBy: "  ")
            if textArray.count > 2 {
                let orderTemp = textArray[0]
                nStart = orderTemp.length
            }
//            dictionary["InvoiceNote"] = specialInstrument.subString(startIndex: nStart+2, length: specialInstrument.length-nStart-2)
            dictionary["InvoiceNote"] = specialInstrument
        }

        var footerDocText = [String]()
        for docText in docTextArray {
            let textType = docText.textType ?? ""
            let subType = docText.subType ?? ""
            let _docText = docText.docText ?? ""
            if textType == "7" && (subType == "" || subType == "P") {
                if _docText == "" {
                    footerDocText.append(" ")
                }
                else {
                    footerDocText.append(_docText)
                }
            }
        }
        dictionary["FooterDocText"] = footerDocText
    }

    func createPDF(webView: UIWebView, isDuplicated: Bool, path: String, type: Int, shouldShowHUD: Bool, completion: ((Bool)->())?) {

        let pdfDirPath = CommData.getFilePathAppended(byDocumentDir: kPDFDirName) ?? ""
        CommData.createDirectory(pdfDirPath)
        let pdfLocalDirPath = CommData.getFilePathAppended(byDocumentDir: kPDFLocalDirName) ?? ""
        CommData.createDirectory(pdfLocalDirPath)

        printPDFPath = path
        completionHandler = completion

        if shouldShowHUD == true {
            hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow, animated: true)
        }

        let htmlString = createHTML(isDuplicated: isDuplicated, type: type)
        if htmlString == "" {
            self.printPDFPath = ""
            hud?.hide(true)
            completionHandler?(true)
        }
        else {
            self.htmlContent = htmlString
            self.printPDFPath = path
            webView.delegate = self
            webView.loadHTMLString(htmlString, baseURL: nil)
        }

    }

    func createPDF(webView: UIWebView, isDuplicated: Bool, path: String, xmlDocument: GDataXMLDocument, shouldShowHUD: Bool, completion: ((Bool)->())?) {

        let pdfDirPath = CommData.getFilePathAppended(byDocumentDir: kPDFDirName) ?? ""
        CommData.createDirectory(pdfDirPath)
        let pdfLocalDirPath = CommData.getFilePathAppended(byDocumentDir: kPDFLocalDirName) ?? ""
        CommData.createDirectory(pdfLocalDirPath)

        printPDFPath = path
        completionHandler = completion

        if shouldShowHUD == true {
            hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow, animated: true)
        }

        let htmlString = createHTML(document: xmlDocument, isDuplicated: isDuplicated)
        self.htmlContent = htmlString
        //self.htmlContent = "<!DOCTYPE html><html><head></head><body>12334</body></html>"
        self.printPDFPath = path

        webView.delegate = self
        webView.loadHTMLString(htmlString, baseURL: nil)
    }

    func exportHTMLContentToPDF(htmlContent: String, webView: UIWebView, path: String) {

        var printPageRenderer: CustomPrintPageRenderer!
        printPageRenderer = CustomPrintPageRenderer(pageWidth: printMetaData.pageWidth, pageHeight: printMetaData.pageHeight)
        printPageRenderer.addPrintFormatter(webView.viewPrintFormatter(), startingAtPageAt: 0)

        let pdfData = drawPDFUsingPrintPageRenderer(printPageRenderer: printPageRenderer)
        pdfData?.write(toFile: path, atomically: true)

        print("Wrote PDF in \(path)")
    }

    func drawPDFUsingPrintPageRenderer(printPageRenderer: UIPrintPageRenderer) -> NSData! {

        let data = NSMutableData()
        UIGraphicsBeginPDFContextToData(data, CGRect(x: 0, y: 0, width: printMetaData.pageWidth, height: printMetaData.pageHeight), nil)
        //UIGraphicsBeginPDFContextToData(data, CGRect.zero, nil)
        for i in 0..<printPageRenderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            printPageRenderer.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        UIGraphicsEndPDFContext()

        return data
    }

    func getPageHeightForOnePage(webView: UIWebView) -> CGFloat {
        var numberOfPages = 0
        var pageHeight: CGFloat = 100.0
        while numberOfPages != 1 && pageHeight < 2000.0 {
            pageHeight += 5.0
            var printPageRenderer: CustomPrintPageRenderer!
            printPageRenderer = CustomPrintPageRenderer(pageWidth: printMetaData.pageWidth, pageHeight: pageHeight)
            printPageRenderer.addPrintFormatter(webView.viewPrintFormatter(), startingAtPageAt: 0)
            numberOfPages = printPageRenderer.numberOfPages
        }
        return pageHeight
    }

    func drawPDFUsingPrintPageRenderer(printPageRenderer: UIPrintPageRenderer, webView: UIWebView) -> NSData! {

        let data = NSMutableData()
        UIGraphicsBeginPDFContextToData(data, CGRect(x: 0, y: 0, width: printMetaData.pageWidth, height: printMetaData.pageHeight), nil)
        //UIGraphicsBeginPDFContextToData(data, CGRect.zero, nil)
        for i in 0..<printPageRenderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            printPageRenderer.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        UIGraphicsEndPDFContext()

        return data
    }

    func createHTML(isDuplicated: Bool, type: Int) -> String {

//        let xmlDirPath = CommData.getFilePathAppended(byCacheDir: "\(kReportsDirName)") ?? ""
        let xmlDirPath = CommData.getFilePathAppended(byDocumentDir: "\(kReportsDirName)") ?? ""
        var xmlFilePath = ""

        if type == kSalePrint {
            xmlFilePath = xmlDirPath+"/"+kPrintTemplateInvoiceFmtFileName
        }
        else if type == kSaleAcknowledgePrint {
            if isRMA {
                xmlFilePath = xmlDirPath+"/"+kPrintRMATemplateFileName
            }
            else {
                xmlFilePath = xmlDirPath+"/"+kPrintOrderAcknowledgeTemplateFileName
            }
        }
        else if type == kSaleVehiclePrint {
            xmlFilePath = xmlDirPath+"/"+kPrintVehicleTemplateFileName
        }
        else if type == kSaleDocketPrint {
            xmlFilePath = xmlDirPath+"/"+kPrintTemplateDeliveryFmtFileName
        }
        else if type == kLoadSheetPrint {
            xmlFilePath = xmlDirPath+"/"+kPrintLoadSheetTemplateFileName
        }
        else if type == kTruckInventoryPrint {
            xmlFilePath = xmlDirPath+"/"+kPrintTruckInventoryTemplateFileName
        }
        else if type == kLoadRequestPrint {
            xmlFilePath = xmlDirPath+"/"+kPrintLoadRequestTemplateFileName
        }
        else if type == kLoadAdjustmentPrint {
            xmlFilePath = xmlDirPath+"/"+kPrintLoadRequestTemplateFileName
        }
        else if type == kLoadStockTakePrint {
            xmlFilePath = xmlDirPath+"/"+kPrintStockTakeCountTemplateFileName
        }
        else if type == kPickSlipPrint {
            xmlFilePath = xmlDirPath+"/"+kPrintPickSlipTemplateFileName
        }
        else if type == kTermsPrint {
            xmlFilePath = xmlDirPath+"/"+kPrintTermsTemplateFileName
        }
        else if type == kSalesPlanPrint {
            xmlFilePath = xmlDirPath+"/"+kPrintSalesPlanTemplateFileName
        }
        else if type == kPaymentCollectionPrint {
            xmlFilePath = xmlDirPath+"/"+kPrintCashTemplateFileName
        }
        else if type == kCollectionConfirmPrint {
            xmlFilePath = xmlDirPath+"/"+kPrintCollectionConfirmTemplateFileName
        }

        if CommData.isExistingFile(atPath: xmlFilePath) == false {
            return ""
        }

        let url = URL(fileURLWithPath: xmlFilePath)
        let xmlData = try! Data(contentsOf: url)
        let doc = try! GDataXMLDocument(data: xmlData, options: 0)
        let htmlString = createHTML(document: doc, isDuplicated: isDuplicated)
        return htmlString
    }

    func createHTML(document: GDataXMLDocument, isDuplicated: Bool) -> String {

        var pageWidthString = ""
        let rootElement = try! document.nodes(forXPath: "//Document").first as! GDataXMLElement
        let docPageWidthNode = rootElement.attribute(forName: "pageWidth")
        pageWidthString = docPageWidthNode?.stringValue() ?? ""
        printMetaData.pageWidth = floor(CGFloat(Int(pageWidthString) ?? 0)*kPrintPixelFactor)

        if pageWidthString.isEmpty == true {
            let docPageSizeNode = rootElement.attribute(forName: "pageSize")
            pageWidthString = docPageSizeNode?.stringValue() ?? ""
            printMetaData.pageSize = pageWidthString
        }

        let marginLeftString = rootElement.attribute(forName: "marginLeft")?.stringValue() ?? ""
        let marginRightString = rootElement.attribute(forName: "marginRight")?.stringValue() ?? ""
        let marginTopString = rootElement.attribute(forName: "marginTop")?.stringValue() ?? ""
        let marginBottomString = rootElement.attribute(forName: "marginBottom")?.stringValue() ?? ""

        printMetaData.marginLeft = CGFloat(Int(marginLeftString) ?? 0)
        printMetaData.marginRight = CGFloat(Int(marginRightString) ?? 0)
        printMetaData.marginTop = CGFloat(Int(marginTopString) ?? 0)
        printMetaData.marginBottom = CGFloat(Int(marginBottomString) ?? 0)

        // create html document
        var bodyString = "<body"
        var styleArray = [String]()
        if marginLeftString.isEmpty == false {
            styleArray.append("padding-left:\(marginLeftString)px;")
        }
        if marginRightString.isEmpty == false {
            styleArray.append("padding-right:\(marginRightString)px;")
        }
        if marginTopString.isEmpty == false {
            styleArray.append("padding-top:\(marginTopString)px;")
        }
        if marginBottomString.isEmpty == false {
            styleArray.append("padding-bottom:\(marginBottomString)px;")
        }

        if styleArray.count > 0 {
            bodyString += " style=\"\(styleArray.joined(separator: ""))\">"
        }
        else {
            bodyString += ">"
        }

        if pageWidthString == "A4" {
            printMetaData.pageWidth = 595.0
            printMetaData.pageHeight = 842.0
        }
        else {
            if isDuplicated == true {
                let tableString = "<table style=\"width:100%;\"><tr><td style=\"width:100.0%;font-size:7px;padding-top:5px;padding-bottom:10px;\" valign=\"top\" align=\"center\"><b>DUPLICATE</td></tr></table>"
                bodyString += tableString
            }
        }

        let nodes = rootElement.children() as! [GDataXMLElement]

        for node in nodes {
            if node.name().uppercased() == "TABLE" {
                let tableString = createHTMLTable(tableElement: node)
                bodyString += ""+tableString
            }
        }

        bodyString += "</body>"

        let htmlString = "<!DOCTYPE html><html><head></head>\(bodyString)</html>"
        return htmlString
    }

    func createHTMLTable(tableElement: GDataXMLElement) -> String {

        var tableStyleArray = [String]()
        tableStyleArray.append("width:100%;")

        var columnCount = 1
        let columnCountNode = tableElement.attribute(forName: "columnCount")
        if columnCountNode != nil {
            columnCount = Int(columnCountNode!.stringValue()) ?? 1
        }

        var percentArray = [Double]()

        if columnCount > 1 {
            var weightArray: [CGFloat] = Array.init(repeating: 0, count: columnCount)
            var totalWeight: CGFloat = 0
            for i in 1...columnCount {
                let columnWeightNode = tableElement.attribute(forName: "column\(i)Weight")
                let columnWeight = Int(columnWeightNode?.stringValue() ?? "") ?? 1
                weightArray[i-1] = CGFloat(columnWeight)
                totalWeight += CGFloat(columnWeight)
            }

            var percentSum: Double = 0
            for i in 0..<columnCount {
                let percent = 100/totalWeight*weightArray[i]
                if i < columnCount-1 {
                    let realPercent = Double(percent).twoDecimalValue
                    percentSum += realPercent
                    percentArray.append(realPercent)
                }
                else {
                    let realPercent = 100-percentSum
                    percentArray.append(realPercent)
                }
            }
        }
        else {
            percentArray.append(100)
        }

        // complete style
        let styleString = "style=\"\(tableStyleArray.joined(separator: ""))\""
        var tableString = "<table \(styleString)>"

        let nodes = tableElement.children() as! [GDataXMLNode]
        var cellNodeIndex = 0

        for node in nodes {

            guard let nodeElement = node as? GDataXMLElement else {continue}

            if nodeElement.name().uppercased() == "CELL" {

                var cellColumnIndex = cellNodeIndex % columnCount
                if cellColumnIndex == 0 {
                    tableString += "<tr>"
                }

                let spanString = nodeElement.attribute(forName: "span")?.stringValue() ?? ""
                let span = Int(spanString) ?? 1

                let cellWidthPercent = percentArray[cellColumnIndex]
                let cellString = createHTMLCell(cellElement: nodeElement, cellWidthPercent: cellWidthPercent)
                tableString += "\(cellString)"

                cellNodeIndex += span
                cellColumnIndex = cellNodeIndex % columnCount

                if cellColumnIndex == 0 {
                    tableString += "</tr>"
                }
            }
            else if nodeElement.name().uppercased() == "OBJECTARRAY" {
                let cellArrayString = createHTMLCellArray(cellArrayElement: nodeElement, columnCount: columnCount, percentArray: percentArray)
                tableString += cellArrayString
            }
        }

        if tableString.hasSuffix("</tr>") == false {
            tableString += "</tr>"
        }

        tableString += "</table>"
        return tableString
    }

    func createHTMLCellArray(cellArrayElement: GDataXMLElement, columnCount: Int, percentArray: [Double]) -> String {
        var nameString = cellArrayElement.attribute(forName: "name")?.stringValue() ?? ""
        var isCheckMode = false
        if nameString.starts(with: "Is") == true {
            nameString = nameString.subString(startIndex: 2, length: nameString.length-2)
            isCheckMode = true
        }

        var cellArrayString = ""
        if isCheckMode == true {
            let object = dictionary[nameString]
            if object != nil {
                if let itemArray = object as? [Any] {
                    if itemArray.count > 0 {
                        let childNodeArray = cellArrayElement.children() as! [GDataXMLNode]
                        var cellNodeIndex = 0
                        for childNode in childNodeArray {
                            if childNode.kind() != GDataXMLElementKind {
                                continue
                            }
                            let elementNode = childNode as! GDataXMLElement
                            var cellColumnIndex = cellNodeIndex % columnCount
                            if cellColumnIndex == 0 {
                                cellArrayString += "<tr>"
                            }

                            // check colspan
                            let spanString = elementNode.attribute(forName: "span")?.stringValue() ?? ""
                            let span = Int(spanString) ?? 1

                            let cellString = createHTMLCell(cellElement: elementNode, cellWidthPercent: percentArray[cellColumnIndex])

                            cellArrayString += "\(cellString)"

                            cellNodeIndex += span
                            cellColumnIndex = cellNodeIndex % columnCount

                            if cellColumnIndex == 0 {
                                cellArrayString += "</tr>"
                            }
                        }
                    }
                }
                else {
                    let childNodeArray = cellArrayElement.children() as! [GDataXMLNode]
                    var cellNodeIndex = 0
                    for childNode in childNodeArray {
                        if childNode.kind() != GDataXMLElementKind {
                            continue
                        }
                        let elementNode = childNode as! GDataXMLElement
                        var cellColumnIndex = cellNodeIndex % columnCount
                        if cellColumnIndex == 0 {
                            cellArrayString += "<tr>"
                        }

                        // check colspan
                        let spanString = elementNode.attribute(forName: "span")?.stringValue() ?? ""
                        let span = Int(spanString) ?? 1

                        let cellString = createHTMLCell(cellElement: elementNode, cellWidthPercent: percentArray[cellColumnIndex])

                        cellArrayString += "\(cellString)"

                        cellNodeIndex += span
                        cellColumnIndex = cellNodeIndex % columnCount

                        if cellColumnIndex == 0 {
                            cellArrayString += "</tr>"
                        }
                    }
                }
            }
        }
        else {
            //let object = dictionary[nameString]
            if let object = dictionary[nameString] as? [Any] {
                let itemArrary = object as [Any]
                for item in itemArrary {
                    dictionaryArray[nameString] = item
                    let childNodeArray = cellArrayElement.children() as! [GDataXMLNode]
                    var cellNodeIndex = 0
                    for childNode in childNodeArray {
                        if childNode.kind() != GDataXMLElementKind {
                            continue
                        }
                        let elementNode = childNode as! GDataXMLElement
                        var cellColumnIndex = cellNodeIndex % columnCount
                        if cellColumnIndex == 0 {
                            cellArrayString += "<tr>"
                        }

                        // check colspan
                        let spanString = elementNode.attribute(forName: "span")?.stringValue() ?? ""
                        let span = Int(spanString) ?? 1

                        let cellString = createHTMLCell(cellElement: elementNode, cellWidthPercent: percentArray[cellColumnIndex])

                        cellArrayString += "\(cellString)"

                        cellNodeIndex += span
                        cellColumnIndex = cellNodeIndex % columnCount

                        if cellColumnIndex == 0 {
                            cellArrayString += "</tr>"
                        }
                    }
                }
            }
        }
        return cellArrayString
    }

    func createHTMLCell(cellElement: GDataXMLElement, cellWidthPercent: Double) -> String {

        var cellString = "<td"
        var attributeArray = [String]()

        var styleArray = [String]()
        styleArray.append("width:\(cellWidthPercent)%;")

        let spanString = cellElement.attribute(forName: "span")?.stringValue() ?? ""
        let borderString = cellElement.attribute(forName: "border")?.stringValue() ?? ""
        let paddingString = cellElement.attribute(forName: "padding")?.stringValue() ?? ""
        let paddingLeftString = cellElement.attribute(forName: "paddingLeft")?.stringValue() ?? ""
        let paddingRightString = cellElement.attribute(forName: "paddingRight")?.stringValue() ?? ""
        let paddingTopString = cellElement.attribute(forName: "paddingTop")?.stringValue() ?? ""
        let paddingBottomString = cellElement.attribute(forName: "paddingBottom")?.stringValue() ?? ""

        let horzAlignmentString = cellElement.attribute(forName: "horzAlignment")?.stringValue() ?? ""
        let vertAlignmentString = cellElement.attribute(forName: "vertAlignment")?.stringValue() ?? ""

        // padding
        if paddingString.isEmpty == false {
            styleArray.append("padding:\(paddingString)px;")
        }
        if paddingLeftString.isEmpty == false {
            styleArray.append("padding-left:\(paddingLeftString)px;")
        }
        if paddingRightString.isEmpty == false {
            styleArray.append("padding-right:\(paddingRightString)px;")
        }
        if paddingTopString.isEmpty == false {
            styleArray.append("padding-top:\(paddingTopString)px;")
        }
        if paddingBottomString.isEmpty == false {
            styleArray.append("padding-bottom:\(paddingBottomString)px;")
        }

        // border
        let borderStringArray = borderString.components(separatedBy: ",")
        for border in borderStringArray {
            if border == "top" {
                styleArray.append("border-top:0.5px solid black;")
            }
            if border == "bottom" {
                styleArray.append("border-bottom:0.5px solid black;")
            }
            if border == "left" {
                styleArray.append("border-left:0.5px solid black;")
            }
            if border == "right" {
                styleArray.append("border-right:0.5px solid black;")
            }
            if border == "box" {
                styleArray.append("border:0.5px solid black;")
            }
        }

        var nodes = cellElement.children() as! [GDataXMLElement]
        for node in nodes {
            if node.name().uppercased() == "PHRASE" {
                let sizeString = node.attribute(forName: "size")?.stringValue() ?? ""
                if sizeString.isEmpty == false {
                    styleArray.append("font-size:\(sizeString)px;")
                    break
                }
            }
        }
        styleArray.append("font-family:\(kPrintTextFontName);")

        let styleString = "style=\"\(styleArray.joined(separator: ""))\""
        attributeArray.append(styleString)

        attributeArray.append("valign=\"top\"")

        // horzAlignment
        if horzAlignmentString.isEmpty == false {
            attributeArray.append("align=\"\(horzAlignmentString)\"")
        }

        // span
        if spanString.isEmpty == false {
            attributeArray.append("colspan=\"\(spanString)\"")
        }

        let attributeString = attributeArray.joined(separator: " ")
        cellString += " " + attributeString + ">"

        // child values
        nodes = cellElement.children() as! [GDataXMLElement]
        for node in nodes {
            if node.name().uppercased() == "TABLE" {
                let tableString = createHTMLTable(tableElement: node)
                cellString += "\(tableString)"
            }
            if node.name().uppercased() == "PHRASE" {
                let phraseString = createHTMLPhrase(phraseElement: node)
                cellString += "\(phraseString)"
            }
            if node.name().uppercased() == "IMAGE" {
                let imageString = createHTMLImage(imageElement: node)
                cellString += "\(imageString)"
            }
        }

        cellString += "</td>"
        return cellString
    }

    func createHTMLPhrase(phraseElement: GDataXMLElement) -> String {

        var phraseString = ""
        let typeString = phraseElement.attribute(forName: "type")?.stringValue() ?? ""
        let typeArray = typeString.components(separatedBy: ",")
        for type in typeArray {
            if type == "bold" {
                phraseString += "<b>"
            }
            if type == "italic" {
                phraseString += "<i>"
            }
        }

        let childNodeArray = phraseElement.children() as? [GDataXMLNode] ?? []
        var value = ""
        var isPhaseAddress2 = false
        for childNode in childNodeArray {
            if childNode.kind() == GDataXMLTextKind {
                value += childNode.stringValue().trimed()
            }
            else if childNode.kind() == GDataXMLElementKind && childNode.name() == "Object" {
                let childElement = childNode as! GDataXMLElement
                let object = getObject(element: childElement)
                if object is String {
                    let objName = childElement.attribute(forName: "name")?.stringValue() ?? ""
                    if objName == "InvoiceTo4" {
                        isPhaseAddress2 = true
                    }
                    value += object as! String
                }
            }
        }

        if value.trimed().isEmpty == true {
            if isPhaseAddress2 == false {
                value = "   "
            }
            else {
                value = ""
            }
        }

        let phraseValue = value
        phraseString += phraseValue
        return phraseString
    }

    func getObject(element: GDataXMLElement) -> Any? {

        let nameString = element.attribute(forName: "name")?.stringValue() ?? ""
        let propertyString = element.attribute(forName: "property")?.stringValue() ?? ""

        if nameString.isEmpty == false {
            var object = dictionaryArray[nameString]
            if object == nil {
                object = dictionary[nameString]
            }
            if object == nil {
                return ""
            }
            if propertyString.isEmpty == false && object is [String: Any] {
                let objectDictionary = object as! [String: Any]
                object = objectDictionary[propertyString]
                if object != nil {
                    return object
                }
                else {
                    return ""
                }
            }
            else {
                return object
            }
        }
        else {
            return ""
        }
    }

    func createHTMLImage(imageElement: GDataXMLElement) -> String {
        let widthString = imageElement.attribute(forName: "width")?.stringValue() ?? ""
        let heightString = imageElement.attribute(forName: "height")?.stringValue() ?? ""

        let width = Int(widthString) ?? 100
        let height = Int(heightString) ?? 100
        var image: UIImage?
        var imagePath: String = ""
        var imageString = ""

        let childNodeArray = imageElement.children() as! [GDataXMLNode]
        for childNode in childNodeArray {
            if childNode.kind() == GDataXMLElementKind && childNode.name().uppercased() == "OBJECT" {
                let childElement = childNode as! GDataXMLElement
                let object = getObject(element: childElement)
                if object is String {
                    imagePath = object as! String
                    image = UIImage.loadImageFromLocal(filePath: imagePath)

                    var imageBase64String = ""
                    if image != nil {
                        //let sizedImage = UIImage.imageWithImage(image: image!, scaledSize: CGSize(width: width, height: height))
                        let imageData = image!.jpegData(compressionQuality: 1.0)
                        imageBase64String = imageData?.base64EncodedString() ?? ""
                        imageBase64String = "data:image/jpg;base64," + imageBase64String
                    }
                    imageString = "<img"
                    imageString += " src=\"\(imageBase64String)\""
                    imageString += " width=\"\(width)\""
                    imageString += " height=\"\(height)\">"
                    imageString += "</img>"
                    break
                }
            }
            if childNode.kind() == GDataXMLTextKind {
                let imageBase64String = childNode.stringValue() ?? ""
                imageString = "<img"
                imageString += " src=\"\(imageBase64String)\""
                imageString += " width=\"\(width)\""
                imageString += " height=\"\(height)\">"
                imageString += "</img>"
                break
            }
        }
        return imageString
    }

}

extension PrintEngine: UIWebViewDelegate {

    func webViewDidStartLoad(_ webView: UIWebView) {
        NSLog("Web view loading started")
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {

        NSLog("Web view loading finished")

        if isForOnePage == true {
            printMetaData.pageHeight = getPageHeightForOnePage(webView: webView)
            //printMetaData.pageHeight = 700
        }

        exportHTMLContentToPDF(htmlContent: self.htmlContent, webView: webView, path: self.printPDFPath)

        hud?.hide(true)
        completionHandler?(true)
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        hud?.hide(true)
        completionHandler?(false)
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        return true
    }

}




