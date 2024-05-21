//
//  OrderSummaryVCLogic.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 9/9/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

extension OrderSummaryVC  {

    func initData() {

        let prefInventoryUOM = globalInfo.routeControl?.inventoryUOM ?? ""
        isShowCase = prefInventoryUOM != "U"

        let managedObjectContext = globalInfo.managedObjectContext!
        let chainNo = customerDetail.chainNo ?? ""
        let custNo = customerDetail.custNo ?? ""
        let arHeaderArray = ARHeader.getUnpaidBy(context: managedObjectContext, chainNo: chainNo, custNo: custNo)

        previousInvoices = 0
        for arHeader in arHeaderArray {
            let amount = Utils.getXMLDivided(valueString: arHeader.trxnAmount ?? "0")
            previousInvoices += amount
        }
        originalARHeaderArray = arHeaderArray

        distributorDescTypeArray = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: kDistributorDescTypeID)
        let customerLocation = customerDetail.location ?? ""
        distributorDescTypeArray = distributorDescTypeArray.filter({ descType -> Bool in
            let value1 = descType.value1 ?? ""
            return value1 == customerLocation
        })
        selectedDistributorDescType = distributorDescTypeArray.first

        fulfilbyDescTypeArray = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "FULFILBY")
        fulfilbyDescTypeArray = fulfilbyDescTypeArray.sorted(by: { (descType1, descType2) -> Bool in
            let numericKey1 = descType1.numericKey ?? ""
            let numericKey2 = descType2.numericKey ?? ""
            let numericKeyValue1 = Int(numericKey1) ?? 0
            let numericKeyValue2 = Int(numericKey2) ?? 0
            return numericKeyValue1 < numericKeyValue2
        })

        // populate delivery date array
        let orderDayWindow = Int(globalInfo.routeControl?.orderDayWindow ?? "") ?? 0
        var i = 0
        var theDay = Date().getDateAddedBy(days: 1)
        while i < orderDayWindow {
            if theDay.isWorkDay() == false {
                theDay = theDay.getDateAddedBy(days: 1)
                continue
            }
            deliveryDateArray.append(theDay)
            i += 1
            theDay = theDay.getDateAddedBy(days: 1)
        }

        summarizeOrderHeader()
    }

    func initUI() {

        salesLabel.text = L10n.sales()
        returnsLabel.text = L10n.Returns()
        freeLabel.text = L10n.free()
        totalLabel.text = L10n.total()
        priorBalance.text = L10n.priorBalance()
        thisOrderLabel.text = L10n.thisOrder()
        termsLabel.text = L10n.terms()
        total.text = L10n.total()
        cardLabel.text = L10n.card()
        cashLabel.text = L10n.cash()
        checkLabel.text = L10n.check()
        poReferenceNumberLabel.text = L10n.poReferenceNumber()
        deliveryDateLabel.text = L10n.deliveryDate()
        signatureLabel.text = L10n.signature()
        nameLabel.text = L10n.name()
        notesLabel.text = L10n.notes()
        returnToOrderLabel.setTitleForAllState(title: L10n.returnToOrder())
        printButton.setTitleForAllState(title: L10n.print())
        confirmButton.setTitleForAllState(title: L10n.CONFIRM())
        
        // Order review screen
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(OrderSummaryVC.onHeaderTapped))
        headerView.addGestureRecognizer(tapGestureRecognizer)

        // pay by views
        paybyRadioLabelArray = [cardRadioLabel, cashRadioLabel, chequeRadioLabel]
        paybyViewArray = [cardView, cashView, chequeView]
        for (index, view) in paybyViewArray.enumerated() {
            view.tag = 400+index
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(OrderSummaryVC.onTapPaybyView(_:)))
            view.addGestureRecognizer(tapGestureRecognizer)
        }
        selectedPaybyOption = .none

        let cardProc = globalInfo.routeControl?.cardProc ?? ""
        if cardProc == "0" {
            cardView.isHidden = true
            cardViewRightConstraint.constant = -66.5
        }
        else {
            cardView.isHidden = false
            cardViewRightConstraint.constant = 30.0
        }

        // fulfil by views
        fulfilbyRadioLabelArray = [fulfilSubView1RadioLabel, fulfilSubView2RadioLabel, fulfilSubView3RadioLabel]
        fulfilbyViewArray = [fulfilSubView1, fulfilSubView2, fulfilSubView3]
        fulfilbyTitleLabelArray = [fulfilSubView1TitleLabel, fulfilSubView2TitleLabel, fulfilSubView3TitleLabel]
        for i in 0..<3 {
            let subView = fulfilbyViewArray[i]
            subView.tag = 500+i

            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(OrderSummaryVC.onTapFulfilbyView(_:)))
            subView.addGestureRecognizer(tapGestureRecognizer)

            let radioLabel = fulfilbyRadioLabelArray[i]
            radioLabel.tag = 600+i
            let titleLabel = fulfilbyTitleLabelArray[i]
            titleLabel.tag = 700+i

            fulfilbyStackView.removeArrangedSubview(subView)
            subView.isHidden = true
        }
        fulfilbyStackView.removeArrangedSubview(distributorButton)
        distributorButton.isHidden = true

        // apply fulfulbydesc
        for fulfilbyDescType in fulfilbyDescTypeArray {
            let numericKey = fulfilbyDescType.numericKey ?? "0"
            let numericKeyValue = Int(numericKey) ?? 1
            let desc = fulfilbyDescType.desc ?? ""

            if numericKeyValue <= 0 || numericKeyValue > 3 {
                continue
            }

            let index = numericKeyValue-1
            let radioSubView = fulfilbyViewArray[index]
            let radioLabel = fulfilbyRadioLabelArray[index]
            let titleLabel = fulfilbyTitleLabelArray[index]

            titleLabel.text = desc
            fulfilbyStackView.addArrangedSubview(radioSubView)
            radioSubView.isHidden = false
        }

        let defaultFulfilbyOptionValue = globalInfo.routeControl?.orderFulfil ?? ""
        if let fulFilbyOptionIndex = kFulfilbyValueArray.index(of: defaultFulfilbyOptionValue) {
            selectedFulfilbyOption = FulfilbyOption(rawValue: fulFilbyOptionIndex) ?? .warehouse
        }
        else {
            if fulfilbyDescTypeArray.count == 0 {
                selectedFulfilbyOption = .warehouse
            }
            else {
                let firstDescType = distributorDescTypeArray.first!
                let numericKeyIndex = (Int(firstDescType.numericKey ?? "") ?? 1) - 1
                selectedFulfilbyOption = FulfilbyOption(rawValue: numericKeyIndex) ?? .warehouse
            }
        }

        if fulfilbyDescTypeArray.count <= 1 {
            fulfilbyView.isHidden = true
        }
        else {
            fulfilbyView.isHidden = false
        }

        setupDeliveryDateDropDown()
        setupDistributorDropDown()

        let countLabelArray: [UILabel] = [salesCountLabel, returnsCountLabel, samplesCountLabel, totalCountLabel]

        let salEntryMode = orderVC.customerDetail.salEntryMode ?? ""

        if isShowCase == true && salEntryMode == "B" {
            for (index, countLabel) in countLabelArray.enumerated() {
                let caseValue = caseArray[index]
                let qtyValue = qtyArray[index]

                let caseValueString = "\(caseValue)"
                let qtyValueString = "\(qtyValue)"
                let valueString = "\(caseValueString)/\(qtyValueString)"
                let attributedString = NSMutableAttributedString(string: valueString)
                let caseColor = caseValue >= 0 ? UIColor.white : UIColor.red
                let qtyColor = qtyValue >= 0 ? UIColor.white : UIColor.red
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: caseColor, range: NSMakeRange(0, caseValueString.count))
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: qtyColor, range: NSMakeRange(caseValueString.count+1, qtyValueString.count))

                if caseValue < 0 && qtyValue < 0 {
                    attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: qtyColor, range: NSMakeRange(caseValueString.count, 1))
                }
                countLabel.attributedText = attributedString
            }
        }
        else {
            for (index, countLabel) in countLabelArray.enumerated() {
                countLabel.text = "\(quantityArray[index])"
                let textColor = quantityArray[index] >= 0 ? UIColor.white : UIColor.red
                countLabel.textColor = textColor
            }
        }

        collectionText.delegate = self
        collectionText.addTarget(self, action: #selector(OrderSummaryVC.onChangeCollectionText(_:)), for: .editingChanged)

        updatePriceLabels()
        
        // date picker
        deliveryDatePicker = UIDatePicker()
        deliveryDatePicker.datePickerMode = .date
        deliveryDateText.inputView = deliveryDatePicker
        deliveryDateText.delegate = self

        let dateDismissAccessory = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 44))
        let itemCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(OrderSummaryVC.onDeliveryDateCancel(_:)))
        let itemFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let itemDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(OrderSummaryVC.onDeliveryDateDone(_:)))
        dateDismissAccessory.items = [itemCancel, itemFlexibleSpace, itemDone]
        deliveryDateText.inputAccessoryView = dateDismissAccessory

        let deliveryDate = Date().getNextWorkDay()
        deliveryDateText.text = deliveryDate.toDateString(format: kDeliveryDateFormat)

        let printType = globalInfo.routeControl?.printType ?? ""
        if printType == "0" || printType == "" {
            printButton.isHidden = true
        }
        else {
            printButton.isHidden = false
        }

        // set the distributor enability
        /*
        if distributorDescTypeArray.count > 0 {
            distributorView.isUserInteractionEnabled = true
        }
        else {
            distributorView.isUserInteractionEnabled = false
        }*/
        distributorButton.isHidden = true
    }

    func updatePriceLabels() {
        previousInvoicesLabel.text = Utils.getMoneyString(moneyValue: previousInvoices)
        thisOrderLabel.text = Utils.getMoneyString(moneyValue: thisOrderAmount)

        termsLabel.text = customerDetail.terms ?? ""

        let totalValue = previousInvoices+thisOrderAmount
        totalLabel.text = Utils.getMoneyString(moneyValue: totalValue)
        currencyLabel.text = globalInfo.routeControl?.currencySymbol ?? ""
    }

    func setupDeliveryDateDropDown() {
        deliveryDateDropDown.cellHeight = deliveryDateButton.bounds.height
        deliveryDateDropDown.anchorView = deliveryDateButton
        deliveryDateDropDown.bottomOffset = CGPoint(x: 0, y: deliveryDateButton.bounds.height)
        deliveryDateDropDown.backgroundColor = UIColor.white
        deliveryDateDropDown.textFont = deliveryDateButton.titleLabel!.font

        let deliveryDateStringArray = deliveryDateArray.map({ (deliveryDate) -> String in
            return deliveryDate.toDateString(format: kDeliveryDateFormat) ?? ""
        })
        deliveryDateDropDown.dataSource = deliveryDateStringArray
        deliveryDateDropDown.cellNib = UINib(nibName: "GeneralDropDownCell", bundle: nil)
        deliveryDateDropDown.customCellConfiguration = {_index, item, cell in
        }
        deliveryDateDropDown.selectionAction = { index, item in
            self.selectedDeliveryDate = self.deliveryDateArray[index]
        }
    }

    func setupDistributorDropDown() {
        distributorDropDown.cellHeight = distributorButton.bounds.height
        distributorDropDown.anchorView = distributorButton
        distributorDropDown.bottomOffset = CGPoint(x: 0, y: distributorButton.bounds.height)
        distributorDropDown.backgroundColor = UIColor.white
        distributorDropDown.textFont = distributorButton.titleLabel!.font

        let deliveryDateStringArray = distributorDescTypeArray.map({ (distributorDescType) -> String in
            return distributorDescType.desc ?? ""
        })
        distributorDropDown.dataSource = deliveryDateStringArray
        distributorDropDown.cellNib = UINib(nibName: "GeneralDropDownCell", bundle: nil)
        distributorDropDown.customCellConfiguration = {_index, item, cell in
        }
        distributorDropDown.selectionAction = { index, item in
            self.selectedDistributorDescType = self.distributorDescTypeArray[index]
        }
    }

    func updateByOrderHeader() {
        referenceNumberText.text = orderVC.orderHeader.poReference
        nameText.text = orderVC.orderHeader.orderName
        notesTextView.text = orderVC.orderHeader.specialInstruments
        self.signatureImageName = String.getFilenameFromPath(filePath: orderVC.orderHeader.signatureFilePath!)
        let photoUpload = orderVC.orderHeader.photoUpload ?? ""
        if photoUpload != "" {
            let filePathArray = photoUpload.components(separatedBy: ",")
            let photoName = String.getFilenameFromPath(filePath: filePathArray[0])
            self.photoPath = CommData.getFilePathAppended(byCacheDir: photoName)
        }

        let deliveryDate = Date.fromDateString(dateString: orderVC.orderHeader.deliveryDate, format: kTightJustDateFormat)
        selectedDeliveryDate = deliveryDate

        // order header
        uar = orderVC.orderHeader.uar
        if uar != nil {
            if let firstPayment = uar!.uarPaymentSet.firstObject as? UARPayment {
                let paymentType = Int(firstPayment.paymentType) ?? 0
                if paymentType == kCollectionCard {
                    selectedPaybyOption = .card
                }
                else if paymentType == kCollectionCheque {
                    selectedPaybyOption = .cheque
                }
                else if paymentType == kCollectionCash {
                    selectedPaybyOption = .cash
                }
                else {
                    selectedPaybyOption = .none
                }
            }
        }

        // fulfil by
        let fulfilby = orderVC.orderHeader.fulfilby ?? ""
        if let fulfilbyIndex = kFulfilbyValueArray.index(of: fulfilby) {
            selectedFulfilbyOption = FulfilbyOption(rawValue: fulfilbyIndex) ?? .warehouse
            if selectedFulfilbyOption == .distributor {
                let distributor = orderVC.orderHeader.distributor ?? ""
                selectedDistributorDescType = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: kDistributorDescTypeID, numericKey:  distributor)
            }
        }

        self.selectedARHeaderAmount = orderVC.orderHeader.realPayment
    }

    func summarizeOrderHeader() {

        let salEntryMode = orderVC.customerDetail.salEntryMode ?? ""

        quantityArray = []
        caseArray = []
        qtyArray = []
        priceArray = []
        subTotalArray = []
        taxArray = []

        pickupQuantity = 0
        buybackQuantity = 0
        samplesQuantity = 0
        freeQuantity = 0

        diffPriceTotal = 0

        for i in 0..<3 {

            var subTotal: Double = 0
            var taxTotal: Double = 0
            var quantityTotal: Int = 0
            var caseTotal: Int = 0
            var qtyTotal: Int = 0

            for _orderDetail in orderVC.orderDetailSetArray[i] {
                let orderDetail = _orderDetail as! OrderDetail
                let itemNo = orderDetail.itemNo!

                let qty = orderDetail.enterQty.int
                let price = orderDetail.price
                let budget = Double(qty)*price
                subTotal += budget

                let basePrice = orderDetail.basePrice
                let diffPrice = basePrice - price

                diffPriceTotal += diffPrice

                let nCase = Utils.getCaseValue(itemNo: itemNo)
                var nCaseValue = 0
                var nQtyValue = 0
                if nCase != 0 {
                    nCaseValue = qty / nCase
                    nQtyValue = qty % nCase
                }

                if isShowCase == true && salEntryMode == "B" {
                    caseTotal += nCaseValue
                    qtyTotal += nQtyValue
                }

                let trxnType = orderDetail.trxnType

                if i == 0 {
                    if trxnType == kTrxnSample {
                        samplesQuantity += qty
                    }
                    else if trxnType == kTrxnFree {
                        freeQuantity += qty
                    }
                }
                if i == 1 {
                    if trxnType == kTrxnPickup {
                        pickupQuantity += qty
                    }
                    else if trxnType == kTrxnBuyBack {
                        buybackQuantity += qty
                    }
                }

                quantityTotal += qty

                let taxRateString = orderDetail.tax?.taxRate ?? "0"
                let taxRateValue = Utils.getXMLDivided(valueString: taxRateString)
                let tax = budget*taxRateValue/100

                taxTotal += tax
            }

            let total = subTotal+taxTotal
            priceArray.append(total)
            quantityArray.append(quantityTotal)
            caseArray.append(caseTotal)
            qtyArray.append(qtyTotal)
            subTotalArray.append(subTotal)
            taxArray.append(taxTotal)
        }

        let totalQuantity = quantityArray[0]+quantityArray[2]-quantityArray[1]
        let totalCase = caseArray[0]+caseArray[2]-caseArray[1]
        let totalQty = qtyArray[0]+qtyArray[2]-qtyArray[1]
        quantityArray.append(totalQuantity)
        caseArray.append(totalCase)
        qtyArray.append(totalQty)

        orderVC.orderHeader.totalAmount = totalQuantity.int32
        orderVC.orderHeader.totalDump = pickupQuantity.int32
        orderVC.orderHeader.totalBuyback = buybackQuantity.int32
        orderVC.orderHeader.totalSale = caseArray[0].int32+caseArray[2].int32
        orderVC.orderHeader.saleAmount = subTotalArray[0]-subTotalArray[1]
        orderVC.orderHeader.taxAmount = taxArray[0]-taxArray[1]
        orderVC.orderHeader.pickupAmount = subTotalArray[1]

        thisOrderAmount = priceArray[0]-priceArray[1]
    }

    func loadARHeaderArray() {
        // Load invoice array
        arHeaderArray.removeAll()
        arHeaderArray.append(contentsOf: originalARHeaderArray)
        // add today order
        let tempARHeader = ARHeader(context: globalInfo.managedObjectContext, forSave: false)
        tempARHeader.custNo = customerDetail.custNo
        tempARHeader.chainNo = customerDetail.chainNo
        tempARHeader.invDate = Date().toDateString(format: kTightJustDateFormat) ?? ""
        tempARHeader.invNo = "0"

        if thisOrderAmount >= 0 {
            tempARHeader.arTrxnType = "INV"
        }
        else {
            tempARHeader.arTrxnType = "CRN"
        }
        tempARHeader.trxnAmount = Utils.getXMLMultipliedString(value: thisOrderAmount)
        arHeaderArray.append(tempARHeader)
        selectedARHeaderIndexArray.append(arHeaderArray.count-1)
    }

    func updatePaidTextFromInvoiceArray() {

        collectionTitleLabel.isHidden = true
        currencyLabel.isHidden = true
        collectionButton.isHidden = true
        collectionText.isHidden = true

        let payType = customerDetail.getSummaryType()
        self.selectedARHeaderAmount = getSelectedARHeaderAmount()
        var desc = ""
        if payType == kCustomerSummaryCod {
            desc = "Collect payment for the current order and outstanding balance of \(Utils.getMoneyString(moneyValue: self.selectedARHeaderAmount)) using"
        }
        else if payType == kCustomerSummaryAccount {
            desc = "Collect payment for the current order of \(Utils.getMoneyString(moneyValue: self.selectedARHeaderAmount)) using"
        }

        if selectedFulfilbyOption == .distributor {
            collectionDescLabel.text = ""
        }
        else {
            collectionDescLabel.text = desc
        }
    }

    func getSelectedARHeaderAmount() -> Double {
        var totalAmount: Double = 0
        for selectedIndex in selectedARHeaderIndexArray {
            let arHeader = arHeaderArray[selectedIndex]
            let amount = Utils.getXMLDivided(valueString: arHeader.trxnAmount ?? "0")
            totalAmount += amount
        }
        return totalAmount
    }

    func processARHeader() {

        let lastARHeader = arHeaderArray.last!
        var newARHeader: ARHeader?

        if selectedFulfilbyOption != .distributor {
            newARHeader = ARHeader(context: globalInfo.managedObjectContext, forSave: true)
            
            newARHeader!.updateBy(theSource: lastARHeader)
            if selectedFulfilbyOption == .warehouse {
                newARHeader!.arTrxnType = "ORD"
            }
            else {
                newARHeader!.arTrxnType = "INV"
            }
            if orderVC.orderHeader.arHeader != nil {
                ARHeader.delete(context: globalInfo.managedObjectContext, arHeader: orderVC.orderHeader.arHeader!)
            }
            orderVC.orderHeader.arHeader = newARHeader
        }

        var totalSelectedAmount: Double = 0
        for selectedIndex in selectedARHeaderIndexArray {
            let arHeader = arHeaderArray[selectedIndex]
            let amount = Utils.getXMLDivided(valueString: arHeader.trxnAmount ?? "0")
            totalSelectedAmount += amount
        }

        if selectedPaybyOption == .none {
            GlobalInfo.saveCache()
        }
        else {
            if totalSelectedAmount == realPayAmount {
                // if it is full payment, mark paid to existing arHeaders
                for arHeader in arHeaderArray {
                    if arHeader.managedObjectContext == nil {
                        continue
                    }
                    arHeader.nProcessStatus = kARPaidStatus
                }
                newARHeader?.nProcessStatus = kARPaidStatus
                GlobalInfo.saveCache()
            }
            else {
                // if it is partial payment,
                let partialARHeader = ARHeader(context: globalInfo.managedObjectContext, forSave: true)
                partialARHeader.updateBy(theSource: lastARHeader)
                partialARHeader.arTrxnType = "CRN"
                partialARHeader.trxnAmount = Utils.getXMLMultipliedString(value: realPayAmount * -1)
                GlobalInfo.saveCache()
            }
        }
    }

    func updateUAR() {

        let chainNo = customerDetail.chainNo ?? "0"
        let custNo = customerDetail.custNo ?? "0"
        let trip = globalInfo.routeControl?.trip ?? ""

        // update the payments
        /*
        var selectedARHeaderArray = [ARHeader]()
        for selectedIndex in selectedARHeaderIndexArray {
            selectedARHeaderArray.append(arHeaderArray[selectedIndex])
        }*/

        let managedObjectContext = globalInfo.managedObjectContext!
        // payment type
        var paymentType = 0
        if selectedPaybyOption == .card {
            paymentType = kCollectionCard
        }
        else if selectedPaybyOption == .cheque {
            paymentType = kCollectionCheque
        }
        else if selectedPaybyOption == .cash {
            paymentType = kCollectionCash
        }
        else {
            if uar != nil {
                UAR.delete(context: managedObjectContext, uar: uar!)
                uar = nil
            }
            return
        }

        if uar != nil {
            UAR.delete(context: managedObjectContext, uar: uar!)
        }
        let paidAmount = self.selectedARHeaderAmount
        let trxnAmount = Utils.getXMLMultipliedString(value: paidAmount)
        let trxnDate = Date()
        let uarPayment = UARPayment.make(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo, trnxDate: trxnDate, trxnAmount: trxnAmount, paymentType: paymentType, forSave: true)
        uar = UAR.make(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo, docType: "PAY", trnxDate: trxnDate, trip: trip, paymentArray: [uarPayment])

        uar!.printedFlag = isPrinted ? "1" : "0"
        uar!.reference = referenceNumberText.text ?? ""
        uar!.invTrxnNo = "0"

        realPayAmount = paidAmount
    }

    func onChangedOption() {

        if selectedFulfilbyOption == .warehouse {
            deliveryDateButton.isHidden = false
            deliveryDateText.isHidden = true

            fulfilbyStackView.removeArrangedSubview(distributorButton)
            distributorButton.isHidden = true

            confirmButton.isEnabled = true
        }
        else if selectedFulfilbyOption == .vehicle {

            let payType = customerDetail.payType ?? ""
            if payType == "2" {
                if selectedPaybyOption == .none {
                    confirmButton.isEnabled = false
                }
                else {
                    confirmButton.isEnabled = true
                }
            }
            else {
                confirmButton.isEnabled = true
            }

            deliveryDateButton.isHidden = true
            deliveryDateText.isHidden = false

            fulfilbyStackView.removeArrangedSubview(distributorButton)
            distributorButton.isHidden = true
        }
        else if selectedFulfilbyOption == .distributor {

            deliveryDateButton.isHidden = false
            deliveryDateText.isHidden = true

            fulfilbyStackView.addArrangedSubview(distributorButton)
            distributorButton.isHidden = false

            confirmButton.isEnabled = true
        }
    }

    func updateARCollection() {
        // enable or disable ar collection text value
        let summaryType = customerDetail.getSummaryType()
        selectedARHeaderIndexArray.removeAll()
        if summaryType == kCustomerSummaryCod {
            for (index, _) in arHeaderArray.enumerated() {
                selectedARHeaderIndexArray.append(index)
            }
        }
        else if summaryType == kCustomerSummaryPayOnOrder {
            for (index, arHeader) in arHeaderArray.enumerated() {
                if arHeader.managedObjectContext == nil {
                    selectedARHeaderIndexArray.append(index)
                }
            }
            // collectionText.isEnabled = false
        }
        else if summaryType == kCustomerSummaryAccount {
            for (index, arHeader) in arHeaderArray.enumerated() {
                if arHeader.managedObjectContext == nil {
                    selectedARHeaderIndexArray.append(index)
                }
            }
            // collectionText.isEnabled = true
        }
        else {
            for (index, arHeader) in arHeaderArray.enumerated() {
                if arHeader.managedObjectContext == nil {
                    selectedARHeaderIndexArray.append(index)
                }
            }
            // collectionText.isEnabled = false
        }
        updatePaidTextFromInvoiceArray()
    }

    func doCreatePdfTask() {

        let pdfFormat = self.globalInfo.routeControl?.uploadInvFmt ?? ""

        var fmtFileName = ""
        var nPrintType = 0
        var shortDescForFile = ""
        var longDescForFile = ""
        let showPrice = self.customerDetail.showPrice ?? ""

        if selectedFulfilbyOption == .warehouse {
            fmtFileName = kPrintOrderAcknowledgeTemplateFileName
            nPrintType = kSaleAcknowledgePrint
            shortDescForFile = "ACKNOWLEDGEMENT"
            longDescForFile = "ORDER ACKNOWLEDGEMENT"
        }
        else if selectedFulfilbyOption == .vehicle {
            fmtFileName = kPrintVehicleTemplateFileName
            nPrintType = kSaleVehiclePrint
            shortDescForFile = "INVOICE"
            longDescForFile = "TAX INVOICE"
        }
        else if selectedFulfilbyOption == .distributor {
            if showPrice == "1" || showPrice == "0" {
                fmtFileName = kPrintTemplateInvoiceFmtFileName
                nPrintType = kSalePrint
                shortDescForFile = "INVOICE"
                longDescForFile = "TAX INVOICE"
            }
            else if showPrice == "2" {
                fmtFileName = kPrintTemplateDeliveryFmtFileName
                nPrintType = kSaleDocketPrint
                shortDescForFile = "DELIVERY"
                longDescForFile = "DELIVERY DOCKET"
            }
            else {
                fmtFileName = kPrintTemplateInvoiceFmtFileName
                nPrintType = kSalePrint
                shortDescForFile = "INVOICE"
                longDescForFile = "TAX INVOICE"
            }
        }

        self.shortDescForFile = shortDescForFile
        self.longDescForFile = longDescForFile

        var orderDetailArray = [OrderDetail]()
        for i in 0..<3 {
            let orderDetailSet = orderVC.orderDetailSetArray[i]
            let detailArray = orderDetailSet.array as! [OrderDetail]
            orderDetailArray.append(contentsOf: detailArray)
        }

        self.printEngine = PrintEngine()

        let pdfName = self.pdfFileName
        orderVC.orderHeader.docNo = pdfName.subString(startIndex: 0, length: pdfName.length-4)

        let fmtFilePath = CommData.getFilePathAppended(byCacheDir: kReportsDirName + "/" + fmtFileName)

        globalInfo.orderHeader = orderVC.orderHeader

        if CommData.isExistingFile(atPath: fmtFilePath) == true {
            self.printEngine.preparePrint(customerDetail: self.customerDetail, printArray: orderDetailArray, nPayType: self.selectedPaybyOption.rawValue+1, previousInvoiceAmount: previousInvoices)
        }

        globalInfo.pageHeightWhenZero = kInvoiceEmptyDataHeight
        self.printEngine.isForOnePage = true

        let pdfPath = CommData.getFilePathAppended(byCacheDir: kPDFDirName+"/"+pdfName) ?? ""
        let pdfLocalPath = CommData.getFilePathAppended(byCacheDir: kPDFLocalDirName+"/"+pdfName) ?? ""

        if pdfFormat == "1" {
            let showPrice = self.customerDetail.showPrice ?? "0"
            if showPrice == "2" {
                self.printEngine.createPDF(webView: self.webView, isDuplicated: false, path: pdfPath, type: nPrintType, shouldShowHUD: true, completion: { (success) in
                    self.onPDFCompleted(success: success, pdfPath: self.printEngine.printPDFPath)
                })
            }
            else {
                self.printEngine.createPDF(webView: self.webView, isDuplicated: false, path: pdfPath, type: nPrintType, shouldShowHUD: true, completion: { (success) in
                    self.onPDFCompleted(success: success, pdfPath: self.printEngine.printPDFPath)
                })
            }
        }
        else {
            self.printEngine.createPDF(webView: self.webView, isDuplicated: false, path: pdfPath, type: nPrintType, shouldShowHUD: true, completion: { (success) in

                self.printEngine.createPDF(webView: self.webView, isDuplicated: true, path: pdfLocalPath, type: nPrintType, shouldShowHUD: true, completion: { (success) in

                })

                self.onPDFCompleted(success: success, pdfPath: self.printEngine.printPDFPath)
            })
        }

    }
    
    // schedule upload with postpone
    func scheduleUOrderUploadWithPostpone() {
        
        let uploadManager = globalInfo.uploadManager
        
        let managedObjectContext = globalInfo.managedObjectContext!
        let chainNo = customerDetail.chainNo ?? ""
        let custNo = customerDetail.custNo ?? ""
        let trip = globalInfo.routeControl?.trip ?? ""
        
        var fileTransactionArray = [FileTransaction]()
        var transactionArray = [UTransaction]()
        
        let fileTrxnDate = Date()
        let fileTrxnDateString = fileTrxnDate.toDateString(format: kTightJustDateFormat) ?? ""
        let fileTrxnTimeString = fileTrxnDate.toDateString(format: kTightJustTimeFormat) ?? ""
        
        let presoldOrHeader = PresoldOrHeader.getFirstBy(context: managedObjectContext, chainNo: chainNo, custNo: custNo)
        let orderNo = presoldOrHeader?.orderNo ?? ""
        
        // for pdf upload
        // order pdf
        if pdfFileName == "" {
            let invoiceNum = globalInfo.routeControl?.invoiceNum ?? ""
            if invoiceNum == "" {
                if orderNo.length > 3 {
                    pdfFileName = orderNo + ".pdf"
                }
                else {
                    pdfFileName = Utils.getPDFFileName()
                }
            }
            else {
                if presoldOrHeader != nil {
                    let qty = presoldOrHeader?.nQty ?? 0
                    pdfFileName = Utils.getOrderNo(value: "\(qty)", format: invoiceNum) + ".pdf"
                }
                else {
                    pdfFileName = Utils.getPDFFileName()
                }
            }
        }
        
        var docNo = ""
        if pdfFileName.length > 4 {
            docNo = pdfFileName.subString(startIndex: 0, length: pdfFileName.length-4)
        }
        else {
            docNo = pdfFileName
        }
        
        var fileTransaction: FileTransaction!
        if pdfFileName.length > 4 {
            fileTransaction = FileTransaction.make(chainNo: chainNo, custNo: custNo, docType: "FARC", fileTrxnDate: fileTrxnDate, trip: trip, trnxDate: Date(), fileDocNo: docNo, fileShortDesc: shortDescForFile, fileLongDesc: longDescForFile, fileCreateDate: fileTrxnDateString, fileCreateTime: fileTrxnTimeString, fileName: pdfFileName)
            fileTransactionArray.append(fileTransaction)
        }
        else {
            fileTransaction = FileTransaction.make(chainNo: chainNo, custNo: custNo, docType: "FARC", fileTrxnDate: fileTrxnDate, trip: trip, trnxDate: Date(), fileDocNo: docNo, fileShortDesc: shortDescForFile, fileLongDesc: longDescForFile, fileCreateDate: fileTrxnDateString, fileCreateTime: fileTrxnTimeString, fileName: pdfFileName)
            fileTransactionArray.append(fileTransaction)
        }
        
        let transaction1 = fileTransaction.makeTransaction()
        transactionArray.append(transaction1)
        
        orderVC.orderHeader.invoiceUpload = "\(kPDFDirName+"/"+fileTransaction.fileFileName),\(fileTransaction.fileFileName)"
        
        // order
        updateUOrder()
        let orderTransaction = uOrder!.makeTransaction()
        transactionArray.append(orderTransaction)
        
        // upload transaction
        var zipFilePathArray = [String]()
        
        // File UTransaction
        let fileTransactionPath = FileTransaction.saveToXML(fileTransactionArray: fileTransactionArray)
        if fileTransactionPath.isEmpty == false {
            zipFilePathArray.append(fileTransactionPath)
        }
        
        let orderPath = UOrder.saveToXML(orderArray: [self.uOrder!])
        if orderPath.isEmpty == false {
            zipFilePathArray.append(orderPath)
        }
        
        // UTransaction
        let transactionPath = UTransaction.saveToXML(transactionArray: transactionArray, shouldIncludeLog: true)
        zipFilePathArray.append(transactionPath)
        
        let zipFileName = uploadManager?.zipFiles(filePathArray: zipFilePathArray) ?? ""
        orderVC.orderHeader.zipUpload = "\(zipFileName),\(zipFileName)"
        
        orderVC.orderHeader.photoUpload = ""
        
        orderVC.orderHeader.isPostponed = true
        
        GlobalInfo.saveCache()
    }

    func doFinalizeOrder() {

        let uploadManager = globalInfo.uploadManager

        let managedObjectContext = globalInfo.managedObjectContext!
        let chainNo = customerDetail.chainNo ?? ""
        let custNo = customerDetail.custNo ?? ""
        let trip = globalInfo.routeControl?.trip ?? ""

        var fileTransactionArray = [FileTransaction]()
        var cameraTransactionArray = [CameraTransaction]()
        var transactionArray = [UTransaction]()
        var uarArray = [UAR]()

        let fileTrxnDate = Date()
        let fileTrxnDateString = fileTrxnDate.toDateString(format: kTightJustDateFormat) ?? ""
        let fileTrxnTimeString = fileTrxnDate.toDateString(format: kTightJustTimeFormat) ?? ""

        let presoldOrHeader = PresoldOrHeader.getFirstBy(context: managedObjectContext, chainNo: chainNo, custNo: custNo)
        let orderNo = presoldOrHeader?.orderNo ?? ""

        // for pdf upload
        if pdfFileName == "" {
            let invoiceNum = globalInfo.routeControl?.invoiceNum ?? ""
            if invoiceNum == "" {
                if orderNo.length > 3 {
                    pdfFileName = orderNo + ".pdf"
                }
                else {
                    pdfFileName = Utils.getPDFFileName()
                }
            }
            else {
                if presoldOrHeader != nil {
                    let qty = presoldOrHeader?.nQty ?? 0
                    pdfFileName = Utils.getOrderNo(value: "\(qty)", format: invoiceNum) + ".pdf"
                }
                else {
                    pdfFileName = Utils.getPDFFileName()
                }
            }
        }

        // finalize uar if needed
        var docNo = ""
        if pdfFileName.length > 4 {
            docNo = pdfFileName.subString(startIndex: 0, length: pdfFileName.length-4)
        }
        else {
            docNo = pdfFileName
        }
        orderVC.orderHeader.uar = uar
        if uar != nil {
            uar!.docNo = docNo
            uar!.updateInvNoForPayments(invNo: docNo)
            /*
            for _uarPayment in uar!.uarPaymentSet {
                let uarPayment = _uarPayment as! UARPayment
                if uarPayment.arHeader == nil {
                    uarPayment.invNo = docNo
                }
            }*/
            uarArray.append(uar!)
            let transaction = uar!.makeTransaction()
            transactionArray.append(transaction)
        }

        orderVC.orderHeader.deleteUploadFiles()

        var fileTransaction: FileTransaction!
        if pdfFileName.length > 4 {
            fileTransaction = FileTransaction.make(chainNo: chainNo, custNo: custNo, docType: "FARC", fileTrxnDate: fileTrxnDate, trip: trip, trnxDate: Date(), fileDocNo: docNo, fileShortDesc: shortDescForFile, fileLongDesc: longDescForFile, fileCreateDate: fileTrxnDateString, fileCreateTime: fileTrxnTimeString, fileName: pdfFileName)
            fileTransactionArray.append(fileTransaction)
        }
        else {
            fileTransaction = FileTransaction.make(chainNo: chainNo, custNo: custNo, docType: "FARC", fileTrxnDate: fileTrxnDate, trip: trip, trnxDate: Date(), fileDocNo: docNo, fileShortDesc: shortDescForFile, fileLongDesc: longDescForFile, fileCreateDate: fileTrxnDateString, fileCreateTime: fileTrxnTimeString, fileName: pdfFileName)
            fileTransactionArray.append(fileTransaction)
        }

        let transaction1 = fileTransaction.makeTransaction()
        transactionArray.append(transaction1)

        orderVC.orderHeader.invoiceUpload = "\(kPDFDirName+"/"+fileTransaction.fileFileName),\(fileTransaction.fileFileName)"
        /*
         uploadManager?.scheduleUpload(localFileName: kPDFDirName+"/"+fileTransaction.fileFileName, remoteFileName: fileTransaction.fileFileName, uploadItemType: .normalCustomerFile)*/
        // photo
        if photoPath.isEmpty == false {

            let cameraTransaction = CameraTransaction.make(chainNo: chainNo, custNo: custNo, docType: "CAM", photoPath: photoPath, reference: "", trip: trip, date: fileTrxnDate)
            cameraTransactionArray.append(cameraTransaction)
            let transaction1 = cameraTransaction.makeTransaction()
            transactionArray.append(transaction1)

            let fileTransaction = FileTransaction.make(chainNo: chainNo, custNo: custNo, docType: "FARC", fileTrxnDate: fileTrxnDate, trip: trip, trnxDate: Date(), fileDocNo: "", fileShortDesc: shortDescForFile, fileLongDesc: longDescForFile, fileCreateDate: fileTrxnDateString, fileCreateTime: fileTrxnTimeString, fileName: cameraTransaction.reference)
            fileTransactionArray.append(fileTransaction)

            orderVC.orderHeader.photoUpload = "\(cameraTransaction.reference),\(cameraTransaction.reference)"
            /*uploadManager?.scheduleUpload(localFileName: cameraTransaction.reference, remoteFileName: cameraTransaction.reference, uploadItemType: .normalCustomerFile)*/
        }

        // order
        updateUOrder()
        let orderTransaction = uOrder!.makeTransaction()
        transactionArray.append(orderTransaction)

        // upload transaction
        var zipFilePathArray = [String]()

        // GPS
        let gpsLog = GPSLog.make(chainNo: chainNo, custNo: custNo, docType: "GPS", date: Date(), location: globalInfo.getCurrentLocation())
        let gpsLogTransaction = gpsLog.makeTransaction()
        transactionArray.append(gpsLogTransaction)

        // Order Status
        let orderStatus = OrderStatusS.make(customerDetails: customerDetail, date: Date(), docType: "IVUP", reference: "", status: "1")
        transactionArray.append(orderStatus.makeTransaction())

        // Camera UTransaction
        let cameraTransactionPath = CameraTransaction.saveToXML(cameraArray: cameraTransactionArray)
        if cameraTransactionPath.isEmpty == false {
            zipFilePathArray.append(cameraTransactionPath)
        }

        // File UTransaction
        let fileTransactionPath = FileTransaction.saveToXML(fileTransactionArray: fileTransactionArray)
        if fileTransactionPath.isEmpty == false {
            zipFilePathArray.append(fileTransactionPath)
        }

        let uarPath = UAR.saveToXML(uarArray: uarArray)
        if uarPath.isEmpty == false {
            zipFilePathArray.append(uarPath)
        }

        let orderStatusPath = OrderStatusS.saveToXML(orderStatusArray: [orderStatus])
        if orderStatusPath.isEmpty == false {
            zipFilePathArray.append(orderStatusPath)
        }

        let orderPath = UOrder.saveToXML(orderArray: [self.uOrder!])
        if orderPath.isEmpty == false {
            zipFilePathArray.append(orderPath)
        }

        // GPS
        let gpsLogPath = GPSLog.saveToXML(gpsLogArray: [gpsLog])
        zipFilePathArray.append(gpsLogPath)

        // UTransaction
        let transactionPath = UTransaction.saveToXML(transactionArray: transactionArray, shouldIncludeLog: true)
        zipFilePathArray.append(transactionPath)

        /*
         uploadManager?.zipAndScheduleUpload(filePathArray: zipFilePathArray)*/
        let zipFileName = uploadManager?.zipFiles(filePathArray: zipFilePathArray) ?? ""
        orderVC.orderHeader.zipUpload = "\(zipFileName),\(zipFileName)"

        // save order header and details
        if orderVC.originalOrderHeader == nil {
            orderVC.orderHeader.saveHeader()
        }
        else {
            orderVC.originalOrderHeader!.updateBy(context: managedObjectContext, theSource: orderVC.orderHeader)
            orderVC.originalOrderHeader!.saveHeader()
        }

        orderVC.orderHeader.isPostponed = true
        
        customerDetail.isOrderCreated = true
        GlobalInfo.saveCache()

        mainVC.popChild(containerView: mainVC.containerView) { (finished) in
            self.dismissHandler?(self, .confirmed)
        }
    }

    func doValidate() -> Bool {

        let customerName = customerDetail.name ?? ""
        let name = nameText.text ?? ""
        if name.isEmpty == true {
            Utils.showAlert(vc: self, title: customerName, message: L10n.captureBoth(), failed: false, customerName: "", leftString: "", middleString: "", rightString: L10n.return(), dismissHandler: nil)
            return false
        }

        if self.signatureImageName == "" {
            Utils.showAlert(vc: self, title: customerName, message: L10n.captureBoth(), failed: false, customerName: "", leftString: "", middleString: "", rightString: L10n.return(), dismissHandler: nil)
            return false
        }

        let payType = customerDetail.getSummaryType()
        if payType == kCustomerSummaryCod && selectedFulfilbyOption == .vehicle && selectedPaybyOption == .none {
            Utils.showAlert(vc: self, title: customerName, message: L10n.paybyOption(), failed: false, customerName: "", leftString: "", middleString: "", rightString: L10n.return(), dismissHandler: nil)
            return false
        }

        return true
    }

    func processConfirm() {

        processARHeader()

        let managedObjectContext = globalInfo.managedObjectContext!
        let chainNo = customerDetail.chainNo ?? ""
        let custNo = customerDetail.custNo ?? ""
        let presoldOrHeader = PresoldOrHeader.getFirstBy(context: managedObjectContext, chainNo: chainNo, custNo: custNo)
        if pdfFileName == "" {
            let invoiceNum = globalInfo.routeControl?.invoiceNum ?? ""
            if invoiceNum == "" {
                let orderNo = presoldOrHeader?.orderNo ?? ""
                let isByPresoldHeader = orderVC.isByPresoldHeader
                if isByPresoldHeader == true && presoldOrHeader != nil && orderNo.length > 3 {
                    pdfFileName = orderNo + ".pdf"
                }
                else {
                    pdfFileName = Utils.getPDFFileName()
                }
            }
            else {
                if presoldOrHeader != nil {
                    let nQty = presoldOrHeader!.nQty
                    pdfFileName = Utils.getOrderNo(value: "\(nQty)", format: invoiceNum) + ".pdf"
                }
                else {
                    pdfFileName = Utils.getPDFFileName()
                }
            }
        }

        let trxnDateValue = Date()
        
        orderVC.orderHeader.chainNo = chainNo
        orderVC.orderHeader.custNo = custNo
        orderVC.orderHeader.periodNo = customerDetail.periodNo ?? ""
        orderVC.orderHeader.dayNo = customerDetail.dayNo ?? ""

        let trxnDate = trxnDateValue.toDateString(format: kTightJustDateFormat) ?? ""
        let trxnTime = trxnDateValue.toDateString(format: kTightJustTimeFormat) ?? ""
        orderVC.orderHeader.trxnDate = trxnDate
        orderVC.orderHeader.trxnTime = trxnTime

        orderVC.orderHeader.fulfilby = kFulfilbyValueArray[selectedFulfilbyOption.rawValue]
        if selectedFulfilbyOption == .distributor {
            orderVC.orderHeader.distributor = selectedDistributorDescType?.numericKey ?? ""
        }
        else {
            orderVC.orderHeader.distributor = ""
        }

        orderVC.orderHeader.poReference = referenceNumberText.text ?? ""
        orderVC.orderHeader.orderName = nameText.text ?? ""
        orderVC.orderHeader.reference = ""
        orderVC.orderHeader.deliveryDate = selectedDeliveryDate?.toDateString(format: kTightJustDateFormat) ?? ""
        orderVC.orderHeader.specialInstruments = notesTextView.text

        if self.signatureImageName != "" {
            orderVC.orderHeader.signatureFilePath = CommData.getFilePathAppended(byCacheDir: self.signatureImageName)
        }
        else {
            orderVC.orderHeader.signatureFilePath = ""
        }

        var dSalesValue = Utils.getDoubleSetting(key: kSalesToday)
        var dReturnsValue = Utils.getDoubleSetting(key: kReturnsToday)
        let dTaxValue = orderVC.orderHeader.taxAmount

        dSalesValue = orderVC.orderHeader.saleAmount
        dReturnsValue = orderVC.orderHeader.pickupAmount

        Utils.setDoubleSetting(key: kSalesToday, value: dSalesValue)
        Utils.setDoubleSetting(key: kReturnsToday
            , value: dReturnsValue)

        orderVC.orderHeader.realPayment = realPayAmount
        globalInfo.dCurrentTotalValue = previousInvoices+dSalesValue+dTaxValue
    }

    func updateUOrder() {

        let managedObjectContext = globalInfo.managedObjectContext!
        let chainNo = customerDetail.chainNo ?? ""
        let custNo = customerDetail.custNo ?? ""
        let now = Date()
        let trxnNo = "\(now.getTimestamp())"
        let trxnDateString = now.toDateString(format: kTightJustDateFormat) ?? ""
        let trxnTimeString = now.toDateString(format: kTightJustTimeFormat) ?? ""

        let pdfName = self.pdfFileName
        var docNo = ""
        if pdfName.length > 4 {
            docNo = pdfName.subString(startIndex: 0, length: pdfName.length-4)
        }
        else {
            docNo = pdfName
        }

        if orderVC.originalOrderHeader == nil {
            orderVC.orderHeader.orderNo = docNo
        }

        let presoldOrHeader = PresoldOrHeader.getFirstBy(context: managedObjectContext, chainNo: chainNo, custNo: custNo)

        let order = UOrder()
        order.docNo = docNo

        let salesAmount = orderVC.orderHeader.saleAmount

        let fulfilby = orderVC.orderHeader.fulfilby ?? ""
        if fulfilby == "V" {
            order.docType = "INV"
        }
        else {
            order.docType = salesAmount >= 0 ? "ORD" : "INV"
        }

        order.voidFlag = "0"
        order.printedFlag = isPrinted ? "1" : "0"
        order.trxnDate = trxnDateString
        order.trxnTime = trxnTimeString
        order.reference = ""
        order.tCOMStatus = "0"
        order.saleDate = trxnDateString
        order.trxnNo = trxnNo
        order.chainNo = chainNo
        order.custNo = custNo
        order.orderNo = orderVC.orderHeader.orderNo
        order.dayNo = orderVC.orderHeader.dayNo
        order.completedDate = trxnDateString
        order.completedTime = trxnTimeString

        var totalPromotionAmount = 0
        let totalAmount = quantityArray[0] + quantityArray[1] + quantityArray[2]
        let saleQuantity = quantityArray[0] + quantityArray[2]
        order.totalAmount = Utils.getXMLMultipliedString(value: totalAmount.double)
        order.totalDumps = Utils.getXMLMultipliedString(value: self.pickupQuantity.double)
        order.totalBuyBack = Utils.getXMLMultipliedString(value: self.buybackQuantity.double)
        order.saleAmount = Utils.getXMLMultipliedString(value: saleQuantity.double)
        order.dTotalAmount = "0"
        order.dTotalDumps = "0"
        order.dTotalBuyBack = "0"
        order.dTotalSales = "0"
        order.previousBal = ""
        let saleAmount = subTotalArray[0] - subTotalArray[1]
        order.saleAmount = Utils.getXMLMultipliedString(value: saleAmount)
        order.promotionAmount = "0"
        let taxAmount = taxArray[0] - taxArray[1]
        order.taxAmount = Utils.getXMLMultipliedString(value: taxAmount)
        order.centsRounding = "0"
        let invoiceTotal = saleAmount+taxAmount
        order.invoiceTotal = Utils.getXMLMultipliedString(value: invoiceTotal)
        order.discDumps = ""
        order.discBuybacks = ""
        order.discBuybacks = ""
        order.discSales = Utils.getXMLMultipliedString(value: diffPriceTotal)
        order.netDumps = ""
        order.netBuybacks = ""
        order.netSales = ""
        order.taxableAmount = Utils.getXMLMultipliedString(value: saleAmount)
        order.changeFlag = ""
        order.deliveryDate = orderVC.orderHeader.deliveryDate
        order.period = customerDetail.periodNo ?? ""
        order.driverNumber = globalInfo.routeControl?.routeNumber ?? ""
        order.detailFile = ""
        order.user1 = presoldOrHeader?.user1 ?? ""
        order.user2 = presoldOrHeader?.user2 ?? ""
        if saleAmount >= 0 {
            order.poRef = referenceNumberText.text ?? ""
            order.credRef = ""
        }
        else {
            order.poRef = ""
            order.credRef = referenceNumberText.text ?? ""
        }
        order.dsd = ""
        order.instrs = notesTextView.text
        order.arBeforeTrxnNo = ""
        order.distr = orderVC.orderHeader.distributor
        let distributorDesc = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: kDistributorDescTypeID, numericKey: order.distr)
        order.distrName = distributorDesc?.desc ?? ""

        order.splitNett = ""
        order.totalSamples = Utils.getXMLMultipliedString(value: samplesQuantity.double)
        order.totalFree = Utils.getXMLMultipliedString(value: freeQuantity.double)
        order.totalExchangeDU = ""
        order.discExchangeDU = ""
        order.netExchangeDU = ""
        order.dexStatus = ""
        order.sourceType = ""
        order.presoldChgd = "Y"
        order.reversed = ""
        order.discInLieuAmt = ""
        order.pallTrxnNo = ""
        order.ticketType = ""
        order.orderContact = nameText.text ?? ""

        for i in 0..<3 {
            for _orderDetail in orderVC.orderDetailSetArray[i] {
                let detail = _orderDetail as! OrderDetail
                let orderDetail = UOrderDetail()
                let itemNo = detail.itemNo!
                orderDetail.trxnNo = trxnNo
                orderDetail.trxnType = "\(detail.trxnType)"
                orderDetail.locnNo = detail.locnNo
                orderDetail.itemNo = itemNo
                orderDetail.priceOverride = ""

                let enterQty = detail.enterQty.int
                orderDetail.quantity = Utils.getXMLMultipliedString(value: enterQty.double)
                if i == 0 || i == 2 {
                    orderDetail.sales = Utils.getXMLMultipliedString(value: enterQty.double)
                    orderDetail.dumps = "0"
                }
                else {
                    orderDetail.sales = "0"
                    orderDetail.dumps = Utils.getXMLMultipliedString(value: enterQty.double)
                }

                orderDetail.grossPrice = Utils.getXMLMultipliedString(value: detail.basePrice)
                orderDetail.totalAllowance = ""
                orderDetail.retailPrice = Utils.getXMLMultipliedString(value: detail.price)
                orderDetail.retailOverride = ""
                orderDetail.reasonCode = detail.reasonCode
                orderDetail.weightedItem = ""

                let qty = detail.enterQty.int
                let price = detail.price
                let budget = Double(qty)*price

                let taxRateString = detail.tax?.taxRate ?? ""
                let taxRateValue = Utils.getXMLDivided(valueString: taxRateString)
                let taxAmount = budget*taxRateValue/100
                orderDetail.taxAmount = Utils.getXMLMultipliedString(value: taxAmount)

                if detail.isFromPresoldOrDetail == false {
                    orderDetail.presoldQuantity = ""
                }
                else {
                    orderDetail.presoldQuantity = Utils.getXMLMultipliedString(value: detail.planQty.int.double)
                }

                orderDetail.printOnOrder = ""
                orderDetail.isKitItem = ""
                orderDetail.extendAmount = Utils.getXMLMultipliedString(value: budget)
                orderDetail.user1 = ""
                orderDetail.user2 = ""
                orderDetail.totalWeight = ""
                orderDetail.forecastStartDate = ""
                orderDetail.forecastEndDate = ""
                orderDetail.origForecastQty = ""
                orderDetail.priceDiscFlag = ""
                orderDetail.retailPriceFlag = ""
                orderDetail.discRateEntered = ""
                orderDetail.user3 = ""

                if i == 2 {
                    orderDetail.custPrice = "0"
                }
                else {
                    orderDetail.custPrice = Utils.getXMLMultipliedString(value: detail.price)
                }

                orderDetail.offInvPromoAmtDtl = ""
                orderDetail.totalAllowExtended = ""
                orderDetail.quantityCompl = ""
                orderDetail.caseFactor = "1"
                orderDetail.discInLieuAmtDtl = ""
                orderDetail.custRetailPrice = Utils.getXMLMultipliedString(value: detail.price)
                orderDetail.custPriceExtended = ""
                orderDetail.extendAmount = "0"

                // tax
                let tax = detail.tax
                if tax != nil {
                    tax!.trxnNo = trxnNo
                    tax!.trxnType = "\(detail.trxnType)"
                    tax!.locnNo = detail.locnNo
                    tax!.itemNo = itemNo
                    //tax!.taxRateCode = taxRates!.taxRateCode ?? ""
                    tax!.taxAmount = Utils.getXMLMultipliedString(value: taxAmount)
                    //tax.cumulativeFlag = taxRates!.cumulativeFlag ?? ""
                    //tax.taxRate = taxRates!.taxRate ?? ""
                    tax!.reasonCode = detail.reasonCode

                    orderDetail.taxArray.append(tax!)
                }

                // promotion
                for _promotion in detail.promotionSet {
                    let promotion = _promotion as! UPromotion
                    promotion.trxnNo = trxnNo
                    promotion.itemNo = itemNo
                    //promotion.planNo = promotionPlan.promotionHeader.planNo ?? ""
                    //promotion.assignNo = promotionPlan.promotionHeader.assignNo ?? ""
                    promotion.trxnType = "\(detail.trxnType)"
                    let promotionAmount = Utils.getXMLDivided(valueString: promotion.amount)
                    totalPromotionAmount += Int(promotionAmount)
                    //promotion.amount = "\(promotionAmount)"
                    promotion.priceDiscFlag = "0"
                    promotion.reasonCode = detail.reasonCode
                    //promotion.promoAppMethod = promotionPlan.promotionAss?.promoAppMethod ?? ""
                    //promotion.promoType = promotionPlan.promotionAss?.promoType ?? ""
                    //promotion.promoMethod = promotionPlan.promotionAss?.promoMethod ?? ""
                    //promotion.discAmt = promotionPlan.promotionNoVo.promoDiscount ?? "0"
                    promotion.trxnAmt = ""
                    //promotion.dateStart = promotionPlan.promotionHeader.dateStart ?? ""

                    orderDetail.promotionArray.append(promotion)
                }
                order.uOrderDetailArray.append(orderDetail)
            }
        }
        order.promotionAmount = Utils.getXMLMultipliedString(value: totalPromotionAmount.double)
        self.uOrder = order
    }
}
