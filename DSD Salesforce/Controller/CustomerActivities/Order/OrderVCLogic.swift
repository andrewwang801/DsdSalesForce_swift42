//
//  OrderVCLogic.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 8/21/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import Foundation

extension OrderVC {

    func initData() {
        // load product detail dictionary
        // load product detail
        productSeqDictionary = ProductStruct.getProductStructObjectEntryIDDictionary(context: globalInfo.managedObjectContext)

        productItemDictionary = ProductDetail.getProductItemDictionary(context: globalInfo.managedObjectContext)
        productUPCDictionary = ProductDetail.getProductUPCDictionary(context: globalInfo.managedObjectContext)

        productStructArray.removeAll()
        nodeArray.removeAll()
        productTreeDictionary = [:]

        let authGrp = customerDetail.authGrp ?? ""

        // load auth header
        if isEnableFilterAuthorizedItem == true && authGrp.isEmpty == false {
            authHeader = AuthHeader.getBy(context: globalInfo.managedObjectContext, authGrp: authGrp).first
            if authHeader != nil {
                authDetailArray = AuthDetail.getBy(context: globalInfo.managedObjectContext, authGrp: authHeader!.authGrp ?? "")
                authItemDictionary = [:]
                for authDetil in authDetailArray {
                    authItemDictionary[authDetil.itemNo ?? ""] = authDetil
                }
            }
        }

        loadReasonCodeDescType()

        loadTreeItems()

        initDataForSubVC()
    }

    func loadTreeItems() {

        let _prodStructArray = ProductStruct.getAll(context: globalInfo.managedObjectContext)
        rootItemArray.removeAll()
    
        var rootNode: ProductStruct?
        var parentNodes: [ProductStruct] = []
        var childNodes: [ProductStruct] = []
        var prodStructArray: [ProductStruct] = []
        var index = 0
        
        for prodStruct in _prodStructArray {
            if prodStruct.parentID == "0"{
                rootNode = prodStruct
            }
            else if prodStruct.groupNo == "0"{
                childNodes.append(prodStruct)
            }
            else {
                parentNodes.append(prodStruct)
            }
        }
        
        //sort according to TreeOrder
        var sortedChildNodes: [ProductStruct] = []
        var sortedParentNodes: [ProductStruct] = []
        
        if let treeOrder = self.globalInfo.routeControl?.treeOrder, treeOrder == "DESC" {
            sortedChildNodes = childNodes.sorted(by: { $0.desc ?? "" < $1.desc ?? "" })
            sortedParentNodes = parentNodes.sorted(by: { $0.desc ?? "" < $1.desc ?? "" })
        }
        else {
            sortedChildNodes = childNodes.sorted(by: { $0.entryID ?? "" < $1.entryID ?? "" })
            sortedParentNodes = parentNodes.sorted(by: { $0.entryID ?? "" < $1.entryID ?? "" })
        }
        
        if let _rootNode = rootNode {
            prodStructArray.insert(_rootNode, at: index)
            index += 1
        }
        prodStructArray.insert(contentsOf: sortedParentNodes, at: index)
        index += sortedParentNodes.count
    
        prodStructArray.insert(contentsOf: sortedChildNodes, at: index)
        
        for prodStruct in prodStructArray {

            let objectType = prodStruct.objectType ?? ""
            if objectType.isEmpty == false {
                let itemNo = prodStruct.reference ?? ""
                guard let _ = productItemDictionary[itemNo] else {
                    continue
                }
            }

            let item = TreeItem()
            item.data = prodStruct
            //let entryID = prodStruct.entryID ?? ""
            //let parentID = prodStruct.parentID ?? ""

            let parentItem = productTreeDictionary[prodStruct.parentID ?? ""]
            if parentItem != nil {
                item.depth = parentItem!.depth+1
                item.parentNode = parentItem

                let objectType = prodStruct.objectType ?? ""
                if objectType.isEmpty == true {
                    item.isProductNode = false
                    item.childNodeArray = [TreeItem]()
                }
                else {
                    item.isProductNode = true
                    let treeDesc = globalInfo.routeControl?.treeDesc ?? ""
                    let reference = prodStruct.reference ?? ""
                    let shortDesc = prodStruct.shortDesc ?? ""
                    let fullDesc = prodStruct.fullDesc ?? ""
                    if treeDesc != "1" {
                        prodStruct.desc = reference+" "+shortDesc
                    }
                    else {
                        prodStruct.desc = fullDesc
                    }
                }
                if isEnableFilterAuthorizedItem == true && item.isProductNode == true {
                    if authHeader != nil {
                        if isAuthorizedItem(itemNo: item.data?.reference ?? "") == true {
                            item.parentNode?.childNodeArray?.append(item)
                        }
                    }
                    else {
                        item.parentNode?.childNodeArray?.append(item)
                    }
                }
                else {
                    item.parentNode?.childNodeArray?.append(item)
                }
            }
            else {
                item.depth = 0
                item.parentNode = nil
                item.isProductNode = false
                item.childNodeArray = [TreeItem]()
                rootItemArray.append(item)
            }
            
            if isEnableFilterAuthorizedItem == true && item.isProductNode == true {
                if authHeader != nil {
                    if isAuthorizedItem(itemNo: item.data?.reference ?? "") == true {
                        productTreeDictionary[prodStruct.entryID ?? ""] = item
                    }
                }
                else {
                    productTreeDictionary[prodStruct.entryID ?? ""] = item
                }
            }
            else {
                productTreeDictionary[prodStruct.entryID ?? ""] = item
            }
        }
        
        // add opportunities
        let opportunityRootItem = TreeItem()
        opportunityRootItem.data = nil
        opportunityRootItem.depth = 0
        opportunityRootItem.productDetail = nil
        opportunityRootItem.parentNode = nil
        opportunityRootItem.isProductNode = false
        opportunityRootItem.isValid = true

        for customerOpportunity in globalInfo.customerOpportunityArray {
            let childItem = TreeItem()
            childItem.data = nil
            childItem.depth = 1
            childItem.productDetail = customerOpportunity.productDetail
            childItem.parentNode = opportunityRootItem
            childItem.isProductNode = true
            childItem.isValid = false

            if opportunityRootItem.childNodeArray == nil {
                opportunityRootItem.childNodeArray = [TreeItem]()
            }
            opportunityRootItem.childNodeArray?.append(childItem)
        }

        rootItemArray.insert(opportunityRootItem, at: 0)
    }

    func loadReasonCodeDescType() {
        reasonCodeDescTypeArray = Array.init(repeating: [], count: 3)
        let deliveryReasonCodeArray = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "NODLVRYRSN")
        let returnReasonCodeArray = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "RETURNRSN")
        let buyBackReasonCodeArray = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "BUYBACKRSN")
        let samplesReasonCodeArray = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "FREERSN")
        reasonCodeDescTypeArray[0].append(contentsOf: deliveryReasonCodeArray)
        reasonCodeDescTypeArray[1].append(contentsOf: returnReasonCodeArray)
        reasonCodeDescTypeArray[1].append(contentsOf: buyBackReasonCodeArray)
        reasonCodeDescTypeArray[2].append(contentsOf: samplesReasonCodeArray)
    }

    /*
    func buildNodeArray(item: TreeItem?) {

        guard let item = item else {return}

        let pos = nodeArray.count
        if item.childNodeArray != nil {
            var delChild = [TreeItem]()
            for child in item.childNodeArray! {
                buildNodeArray(item: child)
                if child.isValid == false {
                    delChild.append(child)
                }
            }
            for child in delChild {
                if let index = item.childNodeArray!.index(of: child) {
                    item.childNodeArray!.remove(at: index)
                }
            }

            if item.childNodeArray!.count > 0 {
                nodeArray.insert(item.depth, at: pos)
                productStructArray.insert(item.data, at: pos)
            }
            else {
                item.isValid = false
            }
        }
        else {
            nodeArray.insert(item.depth, at: pos)
            productStructArray.insert(item.data, at: pos)
        }
    }*/

    func initDataForSubVC() {

        // prepare order header and details
        let managedObjectContext = globalInfo.managedObjectContext!

        orderHeader = OrderHeader(context: managedObjectContext, forSave: true)
        orderHeader.custNo = customerDetail.custNo ?? ""
        orderHeader.chainNo = customerDetail.chainNo ?? ""

        if originalOrderHeader != nil {
            orderHeader.updateBy(context: managedObjectContext, theSource: originalOrderHeader!)
        }
        else {
            loadSalesSamplesOrders()
            loadReturnsOrders()
        }

        orderDetailSetArray = [orderHeader.deliverySet, orderHeader.pickupSet, orderHeader.sampleSet]
    }

    func loadSalesSamplesOrders() {

        let managedObjectContext = globalInfo.managedObjectContext!
        let chainNo = customerDetail.chainNo ?? ""
        let custNo = customerDetail.custNo ?? ""
        let taxCode = customerDetail.taxCode ?? ""
        //let periodNo = customerDetail.periodNo ?? ""
        //let deliverySequence = customerDetail.seqNo ?? ""

        orderHeader.deliverySet.removeAllObjects()
        orderHeader.sampleSet.removeAllObjects()

        // try to load orders
        var orderHistoryOrderDetailArray = [OrderDetail]()
        if isByPresoldHeader == false {
            orderHistoryOrderDetailArray = loadOrderDetailsFromOrderHistory(orderType: 0) ?? []
            orderHeader.deliverySet.addObjects(from: orderHistoryOrderDetailArray)
        }

        salesPresoldOrHeader = PresoldOrHeader.getByForSales(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo).first
        //salesPresoldOrHeader = PresoldOrHeader.getByForSales(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo, periodNo: periodNo, deliverySequence: deliverySequence).first
        if salesPresoldOrHeader != nil {
            salesPresoldOrDetailArray = PresoldOrDetail.getBy(context: globalInfo.managedObjectContext, detailFile: salesPresoldOrHeader!.detailFile ?? "")
        }
        // orderHeader.orderNo = salesPresoldOrHeader?.orderNo ?? ""

        for presoldOrDetail in salesPresoldOrDetailArray {

            let trxnType = presoldOrDetail.trxnType ?? ""

            if trxnType != "4" && trxnType != "11" && trxnType != "12" {
                continue
            }

            let itemNo = presoldOrDetail.itemNo ?? ""
            
            let productDetail = ProductDetail.getByFromDic(context: managedObjectContext, itemNo: itemNo)
            let orderDetail = OrderDetail(context: managedObjectContext, forSave: true)
            orderDetail.itemNo = itemNo
            orderDetail.desc = productDetail?.desc ?? ""
            orderDetail.shortDesc = productDetail?.shortDesc ?? ""
            orderDetail.isFromPresoldOrDetail = true
            orderDetail.custNo = custNo
            orderDetail.price = 0.0
            orderDetail.planQty = presoldOrDetail.nOrderQty.int32
            if isByPresoldHeader == true {
                orderDetail.enterQty = presoldOrDetail.nOrderQty.int32
            }
            else {
                orderDetail.enterQty = 0
            }

            /*if productDetail != nil {
                let promotionArray = productDetail!.calculatePrice(context: managedObjectContext, customerDetail: customerDetail)
                orderDetail.promotionSet.addObjects(from: promotionArray)
                orderDetail.price = productDetail!.price
            }*/

            let orderHistory = OrderHistory.getFirstBy(context: managedObjectContext, chainNo: chainNo, custNo: custNo, itemNo: itemNo)
            //let orderHistory = OrderHistory.getFirstByFromDic(chainNo: chainNo, custNo: custNo, itemNo: itemNo)
            if orderHistory != nil {
                let orderDate = orderHistory!.getDate()
                let dateValue = Date.fromDateString(dateString: orderDate, format: kTightJustDateFormat)
                orderDetail.lastOrder = dateValue?.toDateString(format: "dd/MM/yyyy") ?? ""
            }

            let taxRates = TaxRates.getByForToday(context: managedObjectContext, custTaxCode: taxCode, itemNo: itemNo)
            //let taxRates = TaxRates.getByForTodayFromDic(context: managedObjectContext, custTaxCode: taxCode, itemNo: itemNo)
            var tax: UTax?
            if taxRates != nil {
                tax = TaxRates.getUTaxByForToday(context: managedObjectContext, custTaxCode: taxCode, itemNo: itemNo)
                //tax = TaxRates.getUTaxByForTodayFromDic(context: managedObjectContext, custTaxCode: taxCode, itemNo: itemNo)
            }
            orderDetail.tax = tax

            orderDetail.trxnType = Int32(trxnType) ?? 0

            if trxnType == "4" && orderHistoryOrderDetailArray.count == 0 {
                orderHeader.deliverySet.add(orderDetail)
            }
            else if trxnType == "11" || trxnType == "12" {
                orderHeader.sampleSet.add(orderDetail)
            }
        }
        GlobalInfo.saveCache()
    }

    func loadReturnsOrders() {

        let managedObjectContext = globalInfo.managedObjectContext!
        let chainNo = customerDetail.chainNo ?? ""
        let custNo = customerDetail.custNo ?? ""
        let taxCode = customerDetail.taxCode ?? ""
        //let periodNo = customerDetail.periodNo ?? ""
        //let deliverySequence = customerDetail.seqNo ?? ""

        orderHeader.pickupSet.removeAllObjects()

        var orderHistoryOrderDetailArray = [OrderDetail]()
        if isByPresoldHeader == false {
            orderHistoryOrderDetailArray = loadOrderDetailsFromOrderHistory(orderType: 1) ?? []
            orderHeader.pickupSet.addObjects(from: orderHistoryOrderDetailArray)
            if orderHeader.pickupSet.count > 0 {
                return
            }
        }

        returnsPresoldOrHeader = PresoldOrHeader.getByForReturns(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo).first
        //returnsPresoldOrHeader = PresoldOrHeader.getByForReturns(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo, periodNo: periodNo, deliverySequence: deliverySequence).first
        if returnsPresoldOrHeader != nil {
            returnsPresoldOrDetailArray = PresoldOrDetail.getBy(context: globalInfo.managedObjectContext, detailFile: returnsPresoldOrHeader!.detailFile ?? "")
        }

        /*
        let orderNo = returnsPresoldOrHeader?.orderNo ?? ""
        if orderNo != "" {
            orderHeader.orderNo = orderNo
        }*/

        for presoldOrDetail in returnsPresoldOrDetailArray {

            let trxnType = presoldOrDetail.trxnType ?? ""

            let itemNo = presoldOrDetail.itemNo ?? ""
            let productDetail = ProductDetail.getBy(context: managedObjectContext, itemNo: itemNo)

            let orderDetail = OrderDetail(context: managedObjectContext, forSave: true)
            orderDetail.itemNo = itemNo
            orderDetail.desc = productDetail?.desc ?? ""
            orderDetail.shortDesc = productDetail?.shortDesc ?? ""
            orderDetail.isFromPresoldOrDetail = true
            orderDetail.custNo = custNo
            orderDetail.price = 0.0
            orderDetail.planQty = presoldOrDetail.nOrderQty.int32

            if isByPresoldHeader == true {
                orderDetail.enterQty = presoldOrDetail.nOrderQty.int32
            }
            else {
                orderDetail.enterQty = 0
            }

            if productDetail != nil {
                let promotionArray = productDetail!.calculatePrice(context: managedObjectContext, customerDetail: customerDetail)
                orderDetail.promotionSet.addObjects(from: promotionArray)
                orderDetail.price = productDetail!.price
            }

            let orderHistory = OrderHistory.getFirstBy(context: managedObjectContext, chainNo: chainNo, custNo: custNo, itemNo: itemNo)
            if orderHistory != nil {
                let orderDate = orderHistory!.getDate()
                let dateValue = Date.fromDateString(dateString: orderDate, format: kTightJustDateFormat)
                orderDetail.lastOrder = dateValue?.toDateString(format: "dd/MM/yyyy") ?? ""
            }

            let taxRates = TaxRates.getByForToday(context: managedObjectContext, custTaxCode: taxCode, itemNo: itemNo)
            var tax: UTax?
            if taxRates != nil {
                tax = TaxRates.getUTaxByForToday(context: managedObjectContext, custTaxCode: taxCode, itemNo: itemNo)
            }
            orderDetail.tax = tax

            orderDetail.trxnType = Int32(trxnType) ?? 0

            orderHeader.pickupSet.add(orderDetail)
        }
        GlobalInfo.saveCache()
    }

    func initUI() {
        salesButton.setTitleForAllState(title: L10n.sales())
        returnsButton.setTitleForAllState(title: L10n.Returns())
        samplesButton.setTitleForAllState(title: L10n.free())
        historyButton.setTitleForAllState(title: L10n.HISTORY())
        promotionsButton.setTitleForAllState(title: L10n.promotions())
        returnButton.setTitleForAllState(title: L10n.Return())
        productCatalogButton.setTitleForAllState(title: L10n.productCatalog())
        completedButton.setTitleForAllState(title: L10n.COMPLETED())
        notAvailableLabel.text = L10n.notAvailable()
        
        // top option buttons
        topOptionButtonArray = [salesButton, returnsButton, samplesButton, historyButton, promotionsButton]
        for (index, button) in topOptionButtonArray.enumerated() {
            button.tag = 300+index
            button.addTarget(self, action: #selector(OrderVC.onTapTopOptionButton(_:)), for: .touchUpInside)
        }

        // setup tree view
        productTreeView.register(UINib(nibName: String(describing: OrderProductCell.self), bundle: nil), forCellReuseIdentifier: String(describing: OrderProductCell.self))
        productTreeView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        productTreeView.delegate = self
        productTreeView.dataSource = self;
        productTreeView.treeFooterView = UIView()
        productTreeView.backgroundColor = .clear
        productTreeView.separatorStyle = RATreeViewCellSeparatorStyleNone
        productTreeView.allowsSelection = true
        productTreeView.expandsChildRowsWhenRowExpands = false
        productTreeView.collapsesChildRowsWhenRowCollapses = true

        if isEdit == false {
            completedButton.isHidden = true
        }
        else {
            completedButton.isHidden = false
        }
    }

    func reloadProductTree() {
        productTreeView.reloadRows()
        if rootItemArray.count == 0 {
            notAvailableLabel.isHidden = false
        }
        else {
            for rootItem in rootItemArray {
                productTreeView.expandRow(forItem: rootItem)
            }
            notAvailableLabel.isHidden = true
        }
    }

    @objc func onTapTopOptionButton(_ sender: Any) {
        let button = sender as! UIButton
        let index = button.tag-300
        let _topOption = TopOption(rawValue: index)!

        for (_index, button) in topOptionButtonArray.enumerated() {
            if _index == index {
                button.isSelected = true
            }
            else {
                button.isSelected = false
            }
        }

        if selectedTopOption == _topOption {
            return
        }

        selectedTopOption = TopOption(rawValue: index)!
        onSelectedTopOption(index: index)
    }

    func selectSaleButtonWithItemSelection(itemNo: String) {
        onTapTopOptionButton(salesButton)
        selectProduct(selectType: kSelectProductItemNo, itemNo: itemNo, itemUPC: "")
    }

    func onSelectedTopOption(index: Int) {
        // show/hide sub view controllers
        let option = TopOption(rawValue: index)!
        if option == .sales || option == .returns || option == .samples {
            let orderSalesVC = UIViewController.getViewController(storyboardName: "Order", storyboardID: "OrderSalesVC") as! OrderSalesVC
            orderSalesVC.orderVC = self
            orderSalesVC.selectedOrderType = OrderSalesVC.OrderType(rawValue: index)!
            self.changeChild(newVC: orderSalesVC, containerView: containerView, isRemovePrevious: true)
        }
        else if option == .history {
            let orderSalesHistoryVC = UIViewController.getViewController(storyboardName: "Order", storyboardID: "OrderSalesHistoryVC") as! OrderSalesHistoryVC
            orderSalesHistoryVC.orderVC = self
            orderSalesHistoryVC.customerDetail = customerDetail
            self.changeChild(newVC: orderSalesHistoryVC, containerView: containerView, isRemovePrevious: true)
        }
        else if option == .promotions {
            let orderPromotionVC = UIViewController.getViewController(storyboardName: "Order", storyboardID: "OrderPromotionVC") as! OrderPromotionVC
            orderPromotionVC.orderVC = self
            self.changeChild(newVC: orderPromotionVC, containerView: containerView, isRemovePrevious: true)
        }
    }

    func isAuthorizedItem(itemNo: String) -> Bool {

        if authHeader == nil {
            return true
        }

        let authType = authHeader!.authType ?? ""
        if authType == "A" {
            let authDetail = authItemDictionary[itemNo]
            if authDetail != nil {
                return true
            }
            else {
                return false
            }
        }
        else if authType == "U" {
            let authDetail = authItemDictionary[itemNo]
            if authDetail != nil {
                return false
            }
            else {
                return true
            }
        }
        else {
            return true
        }
    }

    func selectProduct(selectType: Int, itemNo: String, itemUPC: String) {

        let info: [String: Any] = ["itemNo": itemNo, "type": selectType, "itemUPC": itemUPC]
        NotificationCenter.default.post(name: Notification.Name(rawValue: kOrderProductSelectedNotificationName), object: nil, userInfo: info)
    }

    func selectProductAndShowDetail(selectType: Int, itemNo: String, itemUPC: String) {

        let info: [String: Any] = ["itemNo": itemNo, "type": selectType, "itemUPC": itemUPC, "showDetail": true]
        NotificationCenter.default.post(name: Notification.Name(rawValue: kOrderProductSelectedNotificationName), object: nil, userInfo: info)
    }

    func doComplete() {
        // check if we need to complete the orders
        var reasonCodeOrderArray = [[OrderDetail]]()
        reasonCodeOrderArray = Array.init(repeating: [], count: 3)
        var shouldCompleteReasonCode = false
        for i in 0...2 {
            let reasonCodeArray = reasonCodeDescTypeArray[i]
            let orderDetailSetArray = [orderHeader.deliverySet, orderHeader.pickupSet, orderHeader.sampleSet]
            for _orderDetail in orderDetailSetArray[i] {
                let orderDetail = _orderDetail as! OrderDetail
                let reasonCodeCount = reasonCodeArray.count
                if reasonCodeCount == 0 {
                    orderDetail.reasonCode = "0"
                }
                else if reasonCodeCount == 1 {
                    orderDetail.reasonCode = reasonCodeArray[0].numericKey ?? ""
                }
                else {
                    var diffQty: Int32 = 0
                    if i == kOrderReturns {
                        diffQty = orderDetail.enterQty
                    }
                    else {
                        diffQty = orderDetail.enterQty - orderDetail.planQty
                    }

                    if diffQty == 0 {
                        orderDetail.reasonCode = "0"
                    }
                    else {
                        if i == kOrderSales || i == kOrderReturns {
                            reasonCodeOrderArray[i].append(orderDetail)
                            shouldCompleteReasonCode = true
                        }
                        else {
                            // samples
                            if orderDetail.isFromOriginal() == true {
                                if diffQty > 0 {
                                    reasonCodeOrderArray[i].append(orderDetail)
                                    shouldCompleteReasonCode = true
                                }
                                else {
                                    orderDetail.reasonCode = "0"
                                }
                            }
                            else {
                                reasonCodeOrderArray[i].append(orderDetail)
                                shouldCompleteReasonCode = true
                            }
                        }
                    }
                }
            }
        }

        var orderTypeArray = [Int]()
        var _reasonCodeOrderArray = [[OrderDetail]]()
        var _reasonCodeArray = [[DescType]]()
        for i in 0...2 {
            if reasonCodeOrderArray[i].count != 0 {
                _reasonCodeOrderArray.append(reasonCodeOrderArray[i])
                _reasonCodeArray.append(reasonCodeDescTypeArray[i])
                orderTypeArray.append(i)
            }
        }

        if shouldCompleteReasonCode == true {
            let orderReasonCodeVC = UIViewController.getViewController(storyboardName: "Order", storyboardID: "OrderReasonCodeVC") as! OrderReasonCodeVC
            orderReasonCodeVC.orderVC = self
            orderReasonCodeVC.orderDetailArray = _reasonCodeOrderArray
            orderReasonCodeVC.reasonCodeDescArray = _reasonCodeArray
            orderReasonCodeVC.orderTypeArray = orderTypeArray

            orderReasonCodeVC.dismissHander = {vc, dismissOption in
                if dismissOption == .completed {
                    self.openOrderSummary()
                }
            }
            orderReasonCodeVC.setDefaultModalPresentationStyle()
            self.present(orderReasonCodeVC, animated: true, completion: nil)
        }
        else {
            openOrderSummary()
        }
    }

    func openOrderSummary() {
        let orderSummaryVC = UIViewController.getViewController(storyboardName: "Order", storyboardID: "OrderSummaryVC") as! OrderSummaryVC
        orderSummaryVC.mainVC = mainVC
        orderSummaryVC.orderVC = self
        orderSummaryVC.customerDetail = customerDetail
        orderSummaryVC.dismissHandler = { vc, dismissOption in
            if dismissOption == .confirmed {
                self.mainVC.popChild(containerView: self.mainVC.containerView, completionHandler: nil)
            }
        }
        mainVC.pushChild(newVC: orderSummaryVC, containerView: mainVC.containerView)
    }

    func loadOrderDetailsFromOrderHistory(orderType: Int) -> [OrderDetail]? {
        let managedObjectContext = globalInfo.managedObjectContext!
        let chainNo = customerDetail.chainNo ?? ""
        let custNo = customerDetail.custNo ?? ""
        let taxCode = customerDetail.taxCode ?? ""
        let orderHistoryItemArray = OrderHistory.getItemArrayBy(context: managedObjectContext, custNo: custNo)
        var templateAuthDetailArray = [AuthDetail]()
        var featureAuthDetailArray = [AuthDetail]()
        var orderDetailArray = [OrderDetail]()

        let featGrp = customerDetail.featGrp ?? "0"
        if featGrp != "0" {
            let authDetailArray = AuthDetail.getBy(context: managedObjectContext, authGrp: featGrp)
            featureAuthDetailArray.append(contentsOf: authDetailArray)
            var orderDictionary = [String: AuthDetail]()
            for authDetail in featureAuthDetailArray {

                let itemNo = authDetail.itemNo ?? ""
                if orderDictionary[itemNo] != nil {
                    continue
                }
                orderDictionary[itemNo] = authDetail
                guard let productDetail = productItemDictionary[itemNo] else {
                    continue
                }

                let orderDetail = OrderDetail(context: managedObjectContext, forSave: true)

                orderDetail.itemNo = itemNo
                orderDetail.desc = productDetail.desc ?? ""
                orderDetail.shortDesc = productDetail.shortDesc ?? ""
                orderDetail.isFromAuthDetail = true
                orderDetail.custNo = custNo
                orderDetail.enterQty = 0
                orderDetail.planQty = 0
                orderDetail.price = 0.0

                let promotionArray = productDetail.calculatePrice(context: managedObjectContext, customerDetail: customerDetail)
                orderDetail.promotionSet.addObjects(from: promotionArray)
                orderDetail.price = productDetail.price

                let orderHistory = OrderHistory.getFirstBy(context: managedObjectContext, chainNo: chainNo, custNo: custNo, itemNo: itemNo)
                if orderHistory != nil {
                    let orderDate = orderHistory!.getDate()
                    let dateValue = Date.fromDateString(dateString: orderDate, format: kTightJustDateFormat)
                    orderDetail.lastOrder = dateValue?.toDateString(format: "dd/MM/yyyy") ?? ""
                }

                let taxRates = TaxRates.getByForToday(context: managedObjectContext, custTaxCode: taxCode, itemNo: itemNo)
                var tax: UTax?
                if taxRates != nil {
                    tax = TaxRates.getUTaxByForToday(context: managedObjectContext, custTaxCode: taxCode, itemNo: itemNo)
                }
                orderDetail.tax = tax

                if kOrderSales == 0 || kOrderSales == 2 {
                    orderDetail.trxnType = kTrxnDeliver.int32
                }
                else {
                    orderDetail.trxnType = kTrxnPickup.int32
                }
                orderDetailArray.append(orderDetail)
            }
        }

        let tempGrp = customerDetail.tempGrp ?? "0"
        if tempGrp != "0" {
            let authDetailArray = AuthDetail.getBy(context: managedObjectContext, authGrp: tempGrp)
            templateAuthDetailArray.append(contentsOf: authDetailArray)
            var orderDictionary = [String: AuthDetail]()
            for authDetail in templateAuthDetailArray {

                let itemNo = authDetail.itemNo ?? ""
                if orderDictionary[itemNo] != nil {
                    continue
                }
                orderDictionary[itemNo] = authDetail
                guard let productDetail = productItemDictionary[itemNo] else {continue}

                let orderDetail = OrderDetail(context: managedObjectContext, forSave: true)
                orderDetail.itemNo = itemNo
                orderDetail.desc = productDetail.desc ?? ""
                orderDetail.shortDesc = productDetail.shortDesc ?? ""
                orderDetail.isFromAuthDetail = true
                orderDetail.custNo = custNo
                orderDetail.enterQty = 0
                orderDetail.planQty = 0
                orderDetail.price = 0.0

                let promotionArray = productDetail.calculatePrice(context: managedObjectContext, customerDetail: customerDetail)
                orderDetail.promotionSet.addObjects(from: promotionArray)
                orderDetail.price = productDetail.price

                let orderHistory = OrderHistory.getFirstBy(context: managedObjectContext, chainNo: chainNo, custNo: custNo, itemNo: itemNo)
                if orderHistory != nil {
                    let orderDate = orderHistory!.getDate()
                    let dateValue = Date.fromDateString(dateString: orderDate, format: kTightJustDateFormat)
                    orderDetail.lastOrder = dateValue?.toDateString(format: "dd/MM/yyyy") ?? ""
                }

                let taxRates = TaxRates.getByForToday(context: managedObjectContext, custTaxCode: taxCode, itemNo: itemNo)
                var tax: UTax?
                if taxRates != nil {
                    tax = TaxRates.getUTaxByForToday(context: managedObjectContext, custTaxCode: taxCode, itemNo: itemNo)
                }
                orderDetail.tax = tax

                if kOrderSales == 0 || kOrderSales == 2 {
                    orderDetail.trxnType = kTrxnDeliver.int32
                }
                else {
                    orderDetail.trxnType = kTrxnPickup.int32
                }
                orderDetailArray.append(orderDetail)
            }

            if orderDetailArray.count > 0 {
                return orderDetailArray
            }
            else {
                return nil
            }
        }

        if orderHistoryItemArray.count == 0 {
            if orderDetailArray.count > 0 {
                return orderDetailArray
            }
            else {
                return nil
            }
        }

        var orderHistoryTempArray = [OrderDetail]()
        var orderDictionary = [String: OrderHistoryItem]()
        for orderHistoryItem in orderHistoryItemArray {
            let itemNo = orderHistoryItem.itemNo
            if orderDictionary[itemNo] != nil {
                continue
            }

            let nBBQty = orderHistoryItem.nBBQty
            let nSAQty = orderHistoryItem.nSAQty
            if kOrderSales == 0 || kOrderSales == 2 {
                if nSAQty == 0 {
                    continue
                }
            }
            else {
                if nBBQty == 0 {
                    continue
                }
            }
            orderDictionary[itemNo] = orderHistoryItem

            guard let productDetail = productItemDictionary[itemNo] else {continue}

            let orderDetail = OrderDetail(context: managedObjectContext, forSave: true)
            orderDetail.itemNo = itemNo
            orderDetail.desc = productDetail.desc ?? ""
            orderDetail.shortDesc = productDetail.shortDesc ?? ""
            orderDetail.isFromOrderHistoryItem = true
            orderDetail.custNo = custNo
            orderDetail.enterQty = 0
            orderDetail.planQty = 0
            orderDetail.price = 0.0

            if kOrderSales == 0 || kOrderSales == 2 {
                orderDetail.planQty = nSAQty.int32
            }
            else {
                orderDetail.planQty = nBBQty.int32
            }

            let promotionArray = productDetail.calculatePrice(context: managedObjectContext, customerDetail: customerDetail)
            orderDetail.promotionSet.addObjects(from: promotionArray)
            orderDetail.price = productDetail.price

            let orderHistory = OrderHistory.getFirstBy(context: managedObjectContext, chainNo: chainNo, custNo: custNo, itemNo: itemNo)
            if orderHistory != nil {
                let orderDate = orderHistory!.getDate()
                let dateValue = Date.fromDateString(dateString: orderDate, format: kTightJustDateFormat)
                orderDetail.lastOrder = dateValue?.toDateString(format: "dd/MM/yyyy") ?? ""
            }

            let taxRates = TaxRates.getByForToday(context: managedObjectContext, custTaxCode: taxCode, itemNo: itemNo)
            var tax: UTax?
            if taxRates != nil {
                tax = TaxRates.getUTaxByForToday(context: managedObjectContext, custTaxCode: taxCode, itemNo: itemNo)
            }
            orderDetail.tax = tax

            if kOrderSales == 0 || kOrderSales == 2 {
                orderDetail.trxnType = kTrxnDeliver.int32
            }
            else {
                orderDetail.trxnType = kTrxnPickup.int32
            }
            orderHistoryTempArray.append(orderDetail)
        }
        orderHistoryTempArray = orderHistoryTempArray.sorted(by: { (orderDetail1, orderDetail2) -> Bool in
            let itemNo1 = orderDetail1.itemNo!
            let itemNo2 = orderDetail2.itemNo!
            let entryID1 = productSeqDictionary[itemNo1] ?? 999999
            let entryID2 = productSeqDictionary[itemNo2] ?? 999999
            return entryID1 < entryID2
        })
        orderDetailArray.append(contentsOf: orderHistoryTempArray)
        return orderDetailArray
    }
}
