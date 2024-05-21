//
//  OrderSalesVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/11/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class OrderSalesVC: UIViewController {

    @IBOutlet weak var orderTableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!

    @IBOutlet weak var filterOptionButton: AnimatableButton!
    @IBOutlet weak var codeSortButton: AnimatableButton!
    @IBOutlet weak var descSortButton: AnimatableButton!
    @IBOutlet weak var lastOrderSortButton: AnimatableButton!
    @IBOutlet weak var priceSortButton: AnimatableButton!
    @IBOutlet weak var qtySortButton: AnimatableButton!
    @IBOutlet weak var aisleSortButton: AnimatableButton!
    @IBOutlet weak var aisleLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var aisleTitleLabel: UILabel!
    
    @IBOutlet weak var codeSortLabel: UILabel!
    @IBOutlet weak var descSortLabel: UILabel!
    @IBOutlet weak var lastOrderLabel: UILabel!
    @IBOutlet weak var priceSortLabel: UILabel!
    @IBOutlet weak var qtySortLabel: UILabel!
    @IBOutlet weak var subTotalTitleLabel: UILabel!
    @IBOutlet weak var subTotalLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var taxTitleLabel: UILabel!
    @IBOutlet weak var totalTitleLabel: UILabel!
    
    var orderDetailArray = [OrderDetail]()

    var sortTypeButtonArray = [AnimatableButton]()

    var bShouldConfirmInventoryAmount = false
    
    enum SortType: Int {
        case code = 0
        case desc = 1
        case lastOrder = 2
        case price = 3
        case qty = 4
        case aisle = 5
        case input = 6
    }

    enum SortOrder: Int {
        case ascending = 0
        case descending = 1
    }

    enum FilterOption: Int {
        case showAll = 0
        case showOrdered = 1
    }

    let sortAscendingImage = UIImage(named: "Sort_Ascending_Arrow")
    let sortDescendingImage = UIImage(named: "Sort_Descending_Arrow")

    let filterAllImage = UIImage(named: "Order_Sales_Filter_All")
    let filterOrderedImage = UIImage(named: "Order_Sales_Filter_Ordered")

    var selectedSortType: SortType = .code {
        didSet {
            updateSortButtonUI()
        }
    }
    var selectedSortOrder: SortOrder = .ascending {
        didSet {
            updateSortButtonUI()
        }
    }
    var selectedFilterOption: FilterOption = .showAll {
        didSet {
            updateFilterOptionUI()
        }
    }

    let kMiddleViewShowWidth: CGFloat = 136.0
    let kMiddleViewHideWidth: CGFloat = 0

    let globalInfo = GlobalInfo.shared
    var orderVC: OrderVC!
    
    var isShowCase = false
    var isModified = false

    var selectedIndex = -1
    var selectedProductDetail: ProductDetail?
    var selectedQty = 0
    
    enum OrderType: Int {
        case sales = 0
        case returns = 1
        case samples = 2
        case none = 3
    }

    var selectedOrderType: OrderType = .sales
    var trxnTypeArray = [kTrxnDeliver, kTrxnPickup, kTrxnSample]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sortTypeButtonArray = [codeSortButton, descSortButton, lastOrderSortButton, priceSortButton, qtySortButton, aisleSortButton]
        initUI()
        
        if globalInfo.isFromMarginCalculator == 0 {
             
             NotificationCenter.default.addObserver(self, selector: #selector(OrderSalesVC.onProductSelected(notification:)), name: Notification.Name(rawValue: kOrderProductSelectedNotificationName), object: nil)

             NotificationCenter.default.addObserver(self, selector: #selector(OrderSalesVC.onProductAdd(notification:)), name: Notification.Name(rawValue: kOrderProductAddNotificationName), object: nil)

             NotificationCenter.default.addObserver(self, selector: #selector(OrderSalesVC.onProductUpdate(notification:)), name: Notification.Name(rawValue: kOrderProductUpdateNotificationName), object: nil)
             
             NotificationCenter.default.addObserver(self, selector: #selector(OrderSalesVC.onUnsavedOrderDetailsLoaded(notification:)), name: Notification.Name(rawValue: kUnsavedOrderDetailsLoaded), object: nil)
         }
        
    }

    ///RSB 2020-3-9
    func initData() {
        if orderVC.orderHeader != nil && globalInfo.isFromMarginCalculator == 0 {
            orderVC.orderDetailSetArray = [orderVC.orderHeader.deliverySet, orderVC.orderHeader.pickupSet, orderVC.orderHeader.sampleSet]
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //initData()

        sortAndFilterOrders()
        refreshOrders()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setOrderDetailSetArrayForMargin()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ///2020-3-18
//        NotificationCenter.default.removeObserver(self)
        if isBeingDismissed == true || isMovingFromParent == true {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    override func updateViewConstraints() {
        aisleLabelWidthConstraint.constant = 0
        super.updateViewConstraints()
    }

    func initUI() {
        codeSortLabel.text = L10n.code()
        descSortLabel.text = L10n.description()
        lastOrderLabel.text = L10n.lastOrder()
        priceSortLabel.text = L10n.price()
        qtySortLabel.text = L10n.qty()
        subTotalTitleLabel.text = L10n.subtotal()
        taxTitleLabel.text = L10n.tax()
        totalTitleLabel.text = L10n.total()
        noDataLabel.text = L10n.thereIsNoData()
        
        if globalInfo.routeControl?.detailEntry != "1" || selectedOrderType != .sales {
            aisleSortButton.isHidden = true
            aisleTitleLabel.isHidden = true
            self.view.setNeedsUpdateConstraints()
            self.view.layoutIfNeeded()
        }
        
        let prefInventoryUOM = globalInfo.routeControl?.inventoryUOM ?? ""
        isShowCase = prefInventoryUOM != "U"

        orderTableView.dataSource = self
        orderTableView.delegate = self
        
        for (index, sortButton) in sortTypeButtonArray.enumerated() {
            sortButton.tag = index+500
            sortButton.addTarget(self, action: #selector(OrderSalesVC.onSortTypeButton(_:)), for: .touchUpInside)
        }

        selectedSortType = .code
        selectedSortOrder = .ascending
        selectedFilterOption = .showAll
        sortAndFilterOrders()
    }

    func refreshOrders() {

        orderTableView.reloadData()
        if orderVC.orderDetailSetArray[selectedOrderType.rawValue].count > 0 {
            noDataLabel.isHidden = true
        }
        else {
            noDataLabel.isHidden = false
        }

        // update bottom total and tax
        var subTotal: Double = 0
        var taxTotal: Double = 0

        for i in 0...1 {
            for _orderDetail in orderVC.orderDetailSetArray[i] {
                let orderDetail = _orderDetail as! OrderDetail
                let qty = orderDetail.enterQty
                let price = orderDetail.price
                let budget = Double(qty)*price
                if i == 0 {
                    subTotal += budget
                }
                else {
                    subTotal -= budget
                }

                let taxRateString = orderDetail.tax?.taxRate ?? "0"
                let taxRateValue = Utils.getXMLDivided(valueString: taxRateString)
                let tax = budget*taxRateValue/100
                if i == 0 {
                    taxTotal += tax
                }
                else {
                    taxTotal -= tax
                }
            }
        }
        orderVC.orderHeader.saleAmount = subTotal
        orderVC.orderHeader.taxAmount = taxTotal

        GlobalInfo.saveCache()

        subTotalLabel.text = Utils.getMoneyString(moneyValue: subTotal)
        taxLabel.text = Utils.getMoneyString(moneyValue: taxTotal)
        totalLabel.text = Utils.getMoneyString(moneyValue: (subTotal+taxTotal))
        
        setOrderDetailSetArrayForMargin()

    }
    
    func setOrderDetailSetArrayForMargin() {
    
        ///RSB 2020-3-9
        if globalInfo.isFromMarginCalculator == 0 {
            globalInfo.orderDetailSetArray[0].removeAllObjects()
            for _orderDetail in orderVC.orderDetailSetArray[selectedOrderType.rawValue] {

                let orderDetailOri = _orderDetail as! OrderDetail
                var isContain = false
                for (index, item) in globalInfo.orderDetailSetArray[selectedOrderType.rawValue].enumerated() {
                    let _item = item as! OrderDetail

                    if _item.itemNo == "" {
                        globalInfo.orderDetailSetArray[selectedOrderType.rawValue].removeObject(at: index)
                    }
                    else if _item.itemNo == orderDetailOri.itemNo {
                        isContain = true
                        break
                    }
                }

                if !isContain && orderDetailOri.itemNo != "" {
                    let orderDetail = OrderDetail(context: globalInfo.managedObjectContext)
                    orderDetail.updateBy(context: globalInfo.managedObjectContext, theSource: orderDetailOri)
                    globalInfo.orderDetailSetArray[selectedOrderType.rawValue].insert(orderDetail, at: 0)
                }
            }
        }
    }
    
    @objc func onUnsavedOrderDetailsLoaded(notification: NSNotification) {
        DispatchQueue.main.async {
            self.sortAndFilterOrders()
            self.refreshOrders()
        }
    }
    @objc func onProductSelected(notification: NSNotification) {
        
        let userInfo = notification.userInfo
        var itemNo = userInfo!["itemNo"] as? String ?? ""
        let type = userInfo!["type"] as? Int ?? 0
        let itemUPC = userInfo!["itemUPC"] as? String ?? ""
        let showDetail = userInfo!["showDetail"] as? Bool ?? false
        
        var qty = 0
        //var isUnit = false
        if type == kSelectProductItemNo {
            qty = 0
        }
        else if type == kSelectProductItemUPC {
            qty = 1
            //isUnit = true
            let productDetail = ProductDetail.getBy(context: globalInfo.managedObjectContext, itemUPC: itemUPC)
            if productDetail != nil {
                itemNo = productDetail?.itemNo ?? ""
            }
        }

        selectedProductDetail = nil
        selectedIndex = -1

        if itemNo.length == 0 {
            Utils.printDebug(message: "Order no product found")
            return
        }
        else {
            selectedProductDetail = orderVC.productItemDictionary[itemNo]
            if selectedProductDetail == nil {
                selectedProductDetail = orderVC.productUPCDictionary[itemNo]
            }
            if selectedProductDetail != nil {
                itemNo = selectedProductDetail?.itemNo ?? ""
            }
            else {
                Utils.printDebug(message: "Order no product found")
                return
            }

            for (index, _orderDetail) in orderVC.orderDetailSetArray[selectedOrderType.rawValue].enumerated() {
                let orderDetail = _orderDetail as! OrderDetail
                let _itemNo = orderDetail.itemNo ?? ""
                if _itemNo == itemNo {
                    qty = orderDetail.enterQty.int
                    selectedIndex = index
                    break
                }
            }
        }
        selectedQty = qty
        isModified = true

        let salesAllowed = selectedProductDetail?.salesAllowed ?? ""
        if salesAllowed.uppercased() == "Y" {
            
            if showDetail == true {
                self.doOpenProductDetail()
            }
            else {
//                self.addProduct(shouldRemoveZeroAmount: true)
                DispatchQueue.main.async {
                    Utils.showAddOrderVC(vc: self, productDetail: self.selectedProductDetail!, customerDetail: self.orderVC.customerDetail, isAdd: true, dismissHandler: { addOrderVC, dismissOption in
                        // we should replace the qty by the input
                        if dismissOption == AddOrderVC.DismissOption.done {
                            let inputedQty = addOrderVC.orderQty
                            self.selectedQty = inputedQty

                            // we should do Add
                            self.addProduct(shouldRemoveZeroAmount: false)
                        }
                    })
                }
            }
        }
        else {
            if selectedOrderType == .sales {
                Utils.showAlert(vc: self.orderVC, title: "", message: L10n.thisItemIsNotAvaiableToBeSold(), failed: false, customerName: "", leftString: "", middleString: "Return", rightString: "", dismissHandler: nil)
            }
            else if selectedOrderType == .returns {
                Utils.showAlert(vc: self.orderVC, title: "", message: L10n.thisItemIsNotAvaiableToBeReturned(), failed: false, customerName: "", leftString: "", middleString: "Return", rightString: "", dismissHandler: nil)
            }
            return
        }
    }

    @objc func onProductAdd(notification: NSNotification) {

        let userInfo = notification.userInfo
        var itemNo = userInfo!["itemNo"] as? String ?? ""
        let amount = userInfo!["amount"] as? Int ?? 0

        var qty = amount

        selectedProductDetail = nil
        selectedIndex = -1

        if itemNo.length == 0 {
            Utils.printDebug(message: L10n.orderNoProduct())
            return
        }
        else {
            selectedProductDetail = orderVC.productItemDictionary[itemNo]
            if selectedProductDetail == nil {
                selectedProductDetail = orderVC.productUPCDictionary[itemNo]
            }
            if selectedProductDetail != nil {
                itemNo = selectedProductDetail?.itemNo ?? ""
            }
            else {
                Utils.printDebug(message: "Order no product found")
                return
            }

            for (index, _orderDetail) in orderVC.orderDetailSetArray[selectedOrderType.rawValue].enumerated() {
                let orderDetail = _orderDetail as! OrderDetail
                let _itemNo = orderDetail.itemNo ?? ""
                if _itemNo == itemNo {
//                    qty = orderDetail.enterQty.int
                    orderDetail.enterQty = qty.int32
                    selectedIndex = index
                    break
                }
            }
        }
        selectedQty = qty

        let salesAllowed = selectedProductDetail?.salesAllowed ?? ""
        if salesAllowed.uppercased() == "Y" {
            self.addProduct(shouldRemoveZeroAmount: true)
        }
        else {
            if selectedOrderType == .sales {
                Utils.showAlert(vc: self.orderVC, title: "", message: L10n.thisItemIsNotAvaiableToBeSold(), failed: false, customerName: "", leftString: "", middleString: "Return", rightString: "", dismissHandler: nil)
            }
            else if selectedOrderType == .returns {
                Utils.showAlert(vc: self.orderVC, title: "", message: L10n.thisItemIsNotAvaiableToBeReturned(), failed: false, customerName: "", leftString: "", middleString: "Return", rightString: "", dismissHandler: nil)
            }
            return
        }
    }

    @objc func onProductUpdate(notification: NSNotification) {
        DispatchQueue.main.async {
            self.sortAndFilterOrders()
            self.refreshOrders()
        }
    }

    func addProduct(shouldRemoveZeroAmount: Bool) {

        if selectedProductDetail == nil {
            Utils.printDebug(message: L10n.selectValidProduct())
            return
        }

        let itemNo = selectedProductDetail?.itemNo ?? ""
        if orderVC.isAuthorizedItem(itemNo: itemNo) == false {
            Utils.printDebug(message: L10n.itemNotAuthorised())
            return
        }

        let routeLocNo = globalInfo.routeControl?.defLocNo ?? ""
        if selectedIndex == -1 {
            let enterQty = selectedQty
            let prodLevl = ProductLevl.getBy(context: globalInfo.managedObjectContext, itemNo: itemNo, locNo: routeLocNo)
            var inventoryQty = 0
            if prodLevl != nil {
                inventoryQty = Int(Utils.getXMLDivided(valueString: prodLevl!.qty ?? "0"))
            }
            if enterQty > inventoryQty && bShouldConfirmInventoryAmount == true {
                let alert = UIAlertController(title: itemNo, message: L10n.thereMayNotBeInventoryOfTheseItemsInTheWarehouse(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: L10n.continue(), style: .default, handler: { _ in

                    self.doAddSelectedProduct()
                    GlobalInfo.saveCache()
                    self.sortAndFilterOrders()
                    self.refreshOrders()
                }))
                alert.addAction(UIAlertAction(title: L10n.cancel(), style: .default, handler: { _ in
                    // remove
                }))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                
                doAddSelectedProduct()
                GlobalInfo.saveCache()
                sortAndFilterOrders()
                refreshOrders()
            }
        }
        else {
            let _selectedOrderDetail = orderVC.orderDetailSetArray[selectedOrderType.rawValue][selectedIndex]
            let selectedOrderDetail = _selectedOrderDetail as! OrderDetail
            if selectedQty == 0 && selectedOrderDetail.isFromOriginal() == false && shouldRemoveZeroAmount == true {
                orderVC.orderDetailSetArray[selectedOrderType.rawValue].removeObject(at: selectedIndex)
            }
            else {
                let enterQty = selectedQty
                let itemNo = selectedOrderDetail.itemNo ?? ""
                let prodLevl = ProductLevl.getBy(context: globalInfo.managedObjectContext, itemNo: itemNo, locNo: routeLocNo)
                var inventoryQty = 0
                if prodLevl != nil {
                    inventoryQty = Int(Utils.getXMLDivided(valueString: prodLevl!.qty ?? "0"))
                }
                if enterQty > inventoryQty && bShouldConfirmInventoryAmount == true {
                    let alert = UIAlertController(title: itemNo, message: L10n.thereMayNotBeInventoryOfTheseItemsInTheWarehouse(), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: L10n.continue(), style: .default, handler: { _ in
                        selectedOrderDetail.enterQty = enterQty.int32

                        GlobalInfo.saveCache()
                        self.sortAndFilterOrders()
                        self.refreshOrders()
                    }))
                    alert.addAction(UIAlertAction(title: L10n.remove(), style: .default, handler: { _ in
                        // remove
                        self.orderVC.orderDetailSetArray[self.selectedOrderType.rawValue].removeObject(at: self.selectedIndex)

                        GlobalInfo.saveCache()
                        self.sortAndFilterOrders()
                        self.refreshOrders()
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    selectedOrderDetail.enterQty = selectedQty.int32

                    GlobalInfo.saveCache()
                    sortAndFilterOrders()
                    refreshOrders()
                }
            }
        }

    }

    func doAddSelectedProduct() {
            
        let chainNo = orderVC.customerDetail.chainNo ?? ""
        let custNo = orderVC.customerDetail.custNo ?? ""
        let managedObjectContext = globalInfo.managedObjectContext!
        // not found a sales order
        let orderDetail = OrderDetail(context: managedObjectContext, forSave: true)

        orderDetail.isInProgress = true
        orderDetail.isFromPresoldOrDetail = false
        orderDetail.isFromOrderHistoryItem = false
        orderDetail.isFromAuthDetail = false
        orderDetail.itemNo = selectedProductDetail?.itemNo ?? ""
        orderDetail.desc = selectedProductDetail?.desc ?? ""
        orderDetail.shortDesc = selectedProductDetail?.shortDesc ?? ""
        orderDetail.custNo = custNo
        orderDetail.planQty = 0

        let promotionArray = selectedProductDetail!.calculatePrice(context: managedObjectContext, customerDetail: orderVC.customerDetail)
        orderDetail.promotionSet.addObjects(from: promotionArray)
        orderDetail.price = selectedProductDetail!.price

        let taxCode = orderVC.customerDetail.taxCode ?? ""
        let itemNo = selectedProductDetail?.itemNo ?? ""

        let taxRates = TaxRates.getByForToday(context: managedObjectContext, custTaxCode: taxCode, itemNo: itemNo)
        var tax: UTax?
        if taxRates != nil {
            tax = TaxRates.getUTaxByForToday(context: managedObjectContext, custTaxCode: taxCode, itemNo: itemNo)
        }
        orderDetail.tax = tax

        orderDetail.trxnType = trxnTypeArray[selectedOrderType.rawValue].int32
        orderDetail.enterQty = selectedQty.int32

        let orderHistory = OrderHistory.getFirstBy(context: managedObjectContext, chainNo: chainNo, custNo: custNo, itemNo: itemNo)

        let orderDate = orderHistory?.getDate() ?? ""
        let dateValue = Date.fromDateString(dateString: orderDate, format: kTightJustDateFormat)
        orderDetail.lastOrder = dateValue?.toDateString(format: "dd/MM/yyyy") ?? ""

        self.selectedSortType = .input
        orderDetail.orderType = Int32(selectedOrderType.rawValue)

        orderVC.orderDetailSetArray[selectedOrderType.rawValue].insert(orderDetail, at: 0)
    
    }

    func doOpenProductDetail() {

        let qty = selectedQty
        DispatchQueue.main.async {
            Utils.showProductDetailVC(vc: self, productDetail: self.selectedProductDetail!, customerDetail: self.orderVC.customerDetail, isForInputQty: self.orderVC.isEdit, inputQty: qty, selectedOrderType: self.selectedOrderType, dismissHandler: { productDetailVC, dismissOption in
                // we should replace the qty by the input
                let inputedQty = productDetailVC.inputedQty
                self.selectedQty = inputedQty

                // we should do Add
                self.addProduct(shouldRemoveZeroAmount: false)
            })
        }
    }

    func onSelectedOrderHistoryItemArray(orderHistoryItemArray: [OrderHistoryItem]) {

        let managedObjectContext = globalInfo.managedObjectContext!
        var orderDetailArray = [OrderDetail]()
        for orderHistoryItem in orderHistoryItemArray {
            let itemNo = orderHistoryItem.itemNo
            let productDetail = orderVC.productItemDictionary[itemNo]
            if orderHistoryItem.nSAQty > 0 && productDetail != nil {
                let orderDetail = OrderDetail(context: managedObjectContext, forSave: true)
                if orderVC.authHeader != nil && orderVC.isAuthorizedItem(itemNo: itemNo) == false {
                    continue
                }
                orderDetail.itemNo = itemNo
                orderDetail.custNo = orderVC.customerDetail.custNo ?? ""
                orderDetail.desc = productDetail?.desc ?? ""
                orderDetail.shortDesc = productDetail?.shortDesc ?? ""

                let prodLoconSCWType = Utils.getProductLoconSCWType(itemNo: itemNo)
                if prodLoconSCWType != kWeightItem {
                    orderDetail.enterQty = orderHistoryItem.nSAQty.int32/1000
                }
                orderDetail.price = productDetail!.price
                orderDetail.trxnType = trxnTypeArray[selectedOrderType.rawValue].int32
                
                isModified = true
                orderDetailArray.append(orderDetail)
            }
        }
        if orderDetailArray.count > 0 {
            let orderNo = orderVC.orderHeader.orderNo
            if orderNo == "0" || orderNo == "" {
                var dictionary = [String: OrderDetail]()
                for _orderDetail in orderVC.orderDetailSetArray[selectedOrderType.rawValue] {
                    let orderDetail = _orderDetail as! OrderDetail
                    let _itemNo = orderDetail.itemNo ?? ""
                    dictionary[_itemNo] = orderDetail
                }
                for historyInfo in orderDetailArray {
                    let _itemNo = historyInfo.itemNo!
                    let orderDetail = dictionary[_itemNo]
                    if orderDetail != nil {
                        let prodLoconSCWType = Utils.getProductLoconSCWType(itemNo: _itemNo)
                        if prodLoconSCWType != kWeightItem {
                            orderDetail!.enterQty = historyInfo.enterQty
                        }
                    }
                    else {
                        orderVC.orderDetailSetArray[selectedOrderType.rawValue].add(historyInfo)
                    }
                }
                GlobalInfo.saveCache()
                sortAndFilterOrders()
                refreshOrders()
            }
            else {
                orderVC.orderDetailSetArray[selectedOrderType.rawValue].removeAllObjects()
                orderVC.orderDetailSetArray[selectedOrderType.rawValue].addObjects(from: orderDetailArray)
                GlobalInfo.saveCache()
                sortAndFilterOrders()
                refreshOrders()
            }
        }
    }

    func updateSortButtonUI() {
        for (index, sortTypeButton) in sortTypeButtonArray.enumerated() {
            if index == selectedSortType.rawValue {
                if selectedSortOrder == .ascending {
                    sortTypeButton.setImageForAllState(image: sortAscendingImage)
                }
                else {
                    sortTypeButton.setImageForAllState(image: sortDescendingImage)
                }
            }
            else {
                sortTypeButton.setImageForAllState(image: nil)
            }
        }
    }

    func updateFilterOptionUI() {
        if selectedFilterOption == .showAll {
            filterOptionButton.setImageForAllState(image: filterAllImage)
        }
        else {
            filterOptionButton.setImageForAllState(image: filterOrderedImage)
        }
    }

    @objc func onSortTypeButton(_ sender: Any) {
        let button = sender as! UIButton
        let index = button.tag - 500
        if selectedSortType.rawValue == index {
            if selectedSortOrder == .ascending {
                selectedSortOrder = .descending
            }
            else {
                selectedSortOrder = .ascending
            }
        }
        else {
            selectedSortType = SortType(rawValue: index)!
            selectedSortOrder = .ascending
        }
        sortAndFilterOrders()
        refreshOrders()
    }

    func sortAndFilterOrders() {

        if orderVC.orderDetailSetArray.count == 0 {
            return
        }
        let orderTypeIndex = selectedOrderType.rawValue
        let orderDetailSet = orderVC.orderDetailSetArray[orderTypeIndex]
        var orderDetailArray = [OrderDetail]()

        for _orderDetail in orderDetailSet {
            let orderDetail = _orderDetail as! OrderDetail
            
            ///SF79
            let shelfStatus = ShelfStatus.getBy(context: globalInfo.managedObjectContext, chainNo: orderVC.customerDetail.chainNo ?? "", custNo: orderDetail.custNo, itemNo: orderDetail.itemNo).first
            
            if let shelfStatus = shelfStatus {
                let aisle = shelfStatus.aisle ?? ""
                let stockCount = shelfStatus.stockCount ?? "0"
                orderDetail.aisle = aisle
                orderDetail.stockCount = stockCount
            }
            let orderHistory = OrderHistory.getFirstBy(context: globalInfo.managedObjectContext, chainNo: orderVC.customerDetail.chainNo ?? "", custNo: orderDetail.custNo, itemNo: orderDetail.itemNo)
            if let _orderHisory = orderHistory {
                orderDetail.orderHistory = _orderHisory.getOrderHistoryString()
            }
            orderDetailArray.append(orderDetail)
        }

        if selectedSortType == .code {
            orderDetailArray = orderDetailArray.sorted(by: { (orderDetail1, orderDetail2) -> Bool in
                let code1 = orderDetail1.itemNo ?? ""
                let code2 = orderDetail2.itemNo ?? ""
                if selectedSortOrder == .ascending {
                    return code1 < code2
                }
                else {
                    return code1 > code2
                }
            })
        }
        else if selectedSortType == .desc {
            orderDetailArray = orderDetailArray.sorted(by: { (orderDetail1, orderDetail2) -> Bool in
                let desc1 = orderDetail1.desc ?? ""
                let desc2 = orderDetail2.desc ?? ""
                if selectedSortOrder == .ascending {
                    return desc1 < desc2
                }
                else {
                    return desc1 > desc2
                }
            })
        }
        else if selectedSortType == .lastOrder {
            orderDetailArray = orderDetailArray.sorted(by: { (orderDetail1, orderDetail2) -> Bool in
                let lastOrder1 = orderDetail1.lastOrder ?? ""
                let lastOrder2 = orderDetail2.lastOrder ?? ""
                if selectedSortOrder == .ascending {
                    return lastOrder1 < lastOrder2
                }
                else {
                    return lastOrder1 > lastOrder2
                }
            })
        }
        else if selectedSortType == .price {
            orderDetailArray = orderDetailArray.sorted(by: { (orderDetail1, orderDetail2) -> Bool in
                let price1 = orderDetail1.price
                let price2 = orderDetail2.price
                if selectedSortOrder == .ascending {
                    return price1 < price2
                }
                else {
                    return price1 > price2
                }
            })
        }
        else if selectedSortType == .qty {
            orderDetailArray = orderDetailArray.sorted(by: { (orderDetail1, orderDetail2) -> Bool in
                let qty1 = orderDetail1.enterQty
                let qty2 = orderDetail2.enterQty
                if selectedSortOrder == .ascending {
                    return qty1 < qty2
                }
                else {
                    return qty1 > qty2
                }
            })
        }
        else if selectedSortType == .aisle {
            if selectedSortOrder == .ascending {
                orderDetailArray = orderDetailArray.sorted{ $0.aisle.localizedStandardCompare($1.aisle) == .orderedAscending }
            }
            else {
                orderDetailArray = orderDetailArray.sorted{ $0.aisle.localizedStandardCompare($1.aisle) == .orderedDescending }
            }
        }
        else if selectedSortType == .input {
            // we do nothing

        }

        orderDetailSet.removeAllObjects()
        orderDetailSet.addObjects(from: orderDetailArray)

        self.orderDetailArray.removeAll()
        for orderDetail in orderDetailArray {
            if selectedFilterOption == .showOrdered {
                let qty = orderDetail.enterQty
                if qty == 0 {
                    continue
                }
            }
            self.orderDetailArray.append(orderDetail)
        }
    }

    @IBAction func onFilterOption(_ sender: Any) {

        let menuComboVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "MenuComboPopoverVC") as! MenuComboPopoverVC
        menuComboVC.modalPresentationStyle = .popover

        let senderButton = sender as! UIButton

        let menuNames = ["Show all items", "Show only items ordered"]
        let menuItemCount = min(menuNames.count, 10)
        let totalHeight = kPopoverMenuCellHeight * CGFloat(menuItemCount)
        menuComboVC.preferredContentSize = CGSize(width: 200.0, height: totalHeight)
        menuComboVC.menuNamesArray = menuNames
        menuComboVC.dismissHandler = {vc, selectedIndex in
            self.selectedFilterOption = FilterOption(rawValue: selectedIndex)!
            self.updateFilterOptionUI()
            self.sortAndFilterOrders()
            self.refreshOrders()
        }

        let presentationPopoverVC = menuComboVC.popoverPresentationController
        presentationPopoverVC?.permittedArrowDirections = [.up]
        presentationPopoverVC?.delegate = self
        presentationPopoverVC?.sourceView = senderButton
        presentationPopoverVC?.sourceRect = senderButton.bounds
        presentationPopoverVC?.backgroundColor = kPopoverMenuBackgroundColor
        self.present(menuComboVC, animated: true, completion: nil)
    }
}

extension OrderSalesVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderDetailArray.count
        // return orderVC.orderDetailSetArray[selectedOrderType.rawValue].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderSalesOrderCell", for: indexPath) as! OrderSalesOrderCell
        cell.setupCell(parentVC: self, indexPath: indexPath)
        return cell
    }

}

extension OrderSalesVC: UITableViewDelegate {
                
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }

}

extension OrderSalesVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension OrderSalesVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
       textField.resignFirstResponder()
       return true
    }
}
