//
//  OrderVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/10/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class OrderVC: UIViewController {

    class TreeItem: NSObject {
        var depth: Int = 0
        var parentNode: TreeItem?
        var childNodeArray: [TreeItem]?
        var isProductNode = false
        var data: ProductStruct?
        var productDetail: ProductDetail?
        var isValid = true
    }

    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var productTreeView: RATreeView!

    @IBOutlet weak var salesButton: UIButton!
    @IBOutlet weak var returnsButton: UIButton!
    @IBOutlet weak var samplesButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var promotionsButton: UIButton!
    @IBOutlet weak var notAvailableLabel: UILabel!
    @IBOutlet weak var completedButton: AnimatableButton!
    @IBOutlet weak var returnButton: AnimatableButton!
    @IBOutlet weak var productCatalogButton: AnimatableButton!
    
    @IBOutlet var marginCalculatorTab: UIView!
    @IBOutlet var priceLabel: UITextField!
    @IBOutlet var costLabel: UITextField!
    @IBOutlet var marginLabel: UITextField!
    var costVal = 0.0
    var priceVal = 0.0
    var marginVal = 0.0
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var topTabView: UIView!
    
    var hud: MBProgressHUD?
    var isFromMarginCalculator = 0
    
    enum TopOption: Int {
        case sales = 0
        case returns = 1
        case samples = 2
        case history = 3
        case promotions = 4
    }

    let kOrderSales = 0
    let kOrderReturns = 1
    let kOrderSamples = 2

    static let kProductTreeMaxLevel = 10

    let globalInfo = GlobalInfo.shared
    var mainVC: MainVC!
    var customerDetail: CustomerDetail!

    var isSearchExpanded = false
    var topOptionButtonArray = [UIButton]()
    var selectedTopOption: TopOption = .sales

    var selectedIndexPath: IndexPath?
    var orderCategoryGroupArray = [OrderCategoryGroup]()

    // for tree
    var authHeader: AuthHeader?
    var authDetailArray = [AuthDetail]()
    var authItemDictionary = [String: AuthDetail]()
    var uInvenH: UInvenH?

    var isReverseMode = false
    var isEnableFilterAuthorizedItem = false
    var isByPresoldHeader = false

    var productStructArray = [ProductStruct?]()
    var nodeArray = [Int]()
    var productTreeDictionary = [String: TreeItem]()

    var productItemDictionary = [String: ProductDetail]()
    var productUPCDictionary = [String: ProductDetail]()

    //var orderNoArray = ["", "", ""]
    var salesPresoldOrHeader: PresoldOrHeader?
    var returnsPresoldOrHeader: PresoldOrHeader?
    var salesPresoldOrDetailArray = [PresoldOrDetail]()
    var returnsPresoldOrDetailArray = [PresoldOrDetail]()
    var samplesPresoldOrDetailArray = [PresoldOrDetail]()

    var originalOrderHeader: OrderHeader?
    var orderHeader: OrderHeader!
    var orderDetailSetArray = [NSMutableOrderedSet]()
    var isEdit = false

    var stockMapD = [String: Double]()

    var reasonCodeDescTypeArray = [[DescType]]()

    var rootItemArray = [TreeItem]()

    var productSeqDictionary = [String: Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
        initUI()
        if isFromMarginCalculator == 1 {
            let marginCalculatorVC = UIViewController.getViewController(storyboardName: "Order", storyboardID: "MarginCalculatorVC") as! MarginCalculatorVC
            marginCalculatorVC.orderVC = self
            self.changeChild(newVC: marginCalculatorVC, containerView: containerView, isRemovePrevious: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFromMarginCalculator == 1 {
            mainVC.setTitleBarText(title: "MARGIN CALCULATOR")
            topTabView.isHidden = true
            marginCalculatorTab.isHidden = false
        }
        else {
            mainVC.setTitleBarText(title: L10n.order())
            topTabView.isHidden = false
            marginCalculatorTab.isHidden = true
        }
        reloadProductTree()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let orderSalesVC = segue.destination as? OrderSalesVC {
            orderSalesVC.orderVC = self
        }
    }
    
    @IBAction func onCalc(_ sender: Any) {
        getValAndStartCalculate()
    }
    
    @IBAction func onSearch(_ sender: Any) {
        if isReverseMode == false {
            let searchProductVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "SearchProductVC") as! SearchProductVC
            searchProductVC.setDefaultModalPresentationStyle()
            searchProductVC.isEnableFilterAuthorizedItem = true
            searchProductVC.customerDetail = customerDetail
            searchProductVC.dismissHandler = { vc, dismissOption in
                if dismissOption == .added {
                    let type = vc.selectedType
                    let itemNo = vc.selectedItemNo
                    self.selectProduct(selectType: type, itemNo: itemNo, itemUPC: "")
                }
            }
            self.present(searchProductVC, animated: true, completion: nil)
        }
    }

    @IBAction func onBarcodeScan(_ sender: Any) {
        if isReverseMode == false {
            let barcodeScanVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "BarcodeScanVC") as! BarcodeScanVC
            barcodeScanVC.setFullScreenPresentation()
            barcodeScanVC.dismissHandler = { vc, dismissOption in
                if dismissOption == .scanned {
                    let itemUPC = vc.itemUPC
                    self.selectProduct(selectType: kSelectProductItemUPC, itemNo: "", itemUPC: itemUPC)
                }
            }
            self.present(barcodeScanVC, animated: true, completion: nil)
        }
    }

    @IBAction func onReturn(_ sender: Any) {
        mainVC.popChild(containerView: mainVC.containerView)
    }

    @IBAction func onCompleted(_ sender: Any) {
        // check if order quantity compared by the inventory amount
        let wholeOrderDetailSetArray = [orderDetailSetArray[0], orderDetailSetArray[2]]
        let routeLocNo = globalInfo.routeControl?.defLocNo ?? ""
        let _ = ProductLevl.getAll(context: globalInfo.managedObjectContext)

        var orderDetailArrayInAlert = [OrderDetail]()
        for orderDetailSet in wholeOrderDetailSetArray {
            for (_, _orderDetail) in orderDetailSet.enumerated() {
                let orderDetail = _orderDetail as! OrderDetail
                let enterQty = orderDetail.enterQty.int
                let itemNo = orderDetail.itemNo ?? ""
                let prodLevl = ProductLevl.getBy(context: globalInfo.managedObjectContext, itemNo: itemNo, locNo: routeLocNo)
                var inventoryQty = 0
                if prodLevl == nil {
                    continue
                }

                inventoryQty = Int(Utils.getXMLDivided(valueString: prodLevl!.qty ?? "0"))
                if enterQty > inventoryQty {
                    orderDetailArrayInAlert.append(orderDetail)
                }
            }
        }

        if orderDetailArrayInAlert.count > 0 {
            let itemNoArray = orderDetailArrayInAlert.compactMap { (orderDetail) -> String? in
                return orderDetail.itemNo
            }
            let itemNoString = itemNoArray.joined(separator: ", ")
            let alert = UIAlertController(title: L10n.inventoryAmountIssue(), message: "\(L10n.thereMayNotBeInventoryOfTheseItemsInTheWarehouse()): \(itemNoString)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: L10n.continue(), style: .default, handler: { _ in
                // continue
                self.doComplete()
            }))
            alert.addAction(UIAlertAction(title: L10n.remove(), style: .default, handler: { _ in
                // remove
                for orderDetailSet in wholeOrderDetailSetArray {
                    orderDetailSet.removeObjects(in: orderDetailArrayInAlert)
                }
                NotificationCenter.default.post(name: NSNotification.Name(kOrderProductUpdateNotificationName), object: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }

        // check if we need to complete the reason code array
        doComplete()
    }

    @IBAction func onProductCatalog(_ sender: Any) {
        let productCatalogVC = UIViewController.getViewController(storyboardName: "ProductCatalog", storyboardID: "ProductCatalogVC") as! ProductCatalogVC
        productCatalogVC.mainVC = self.mainVC
        productCatalogVC.orderVC = self
        productCatalogVC.customerDetail = self.customerDetail
        productCatalogVC.onAddToOrderHandler = { itemNo, amount in
            // add item with the amount
            let info: [String: Any] = ["itemNo": itemNo, "amount": amount]
            NotificationCenter.default.post(name: Notification.Name(rawValue: kOrderProductAddNotificationName), object: nil, userInfo: info)
        }
        mainVC.pushChild(newVC: productCatalogVC, containerView: mainVC.containerView)
    }
}

extension OrderVC: RATreeViewDataSource {

    func treeView(_ treeView: RATreeView, numberOfChildrenOfItem item: Any?) -> Int {

        if let item = item as? TreeItem {
            return item.childNodeArray?.count ?? 0
        }
        else {
            return rootItemArray.count
        }

    }

    func treeView(_ treeView: RATreeView, child index: Int, ofItem item: Any?) -> Any {

        if let treeItem = item as? TreeItem {
            return treeItem.childNodeArray![index]
        }
        else {
            return rootItemArray[index]
            //return productTreeDictionary["1"] as! TreeItem
        }
    }

    func treeView(_ treeView: RATreeView, cellForItem item: Any?) -> UITableViewCell {

        if let item = item as? TreeItem {
            let cell = treeView.dequeueReusableCell(withIdentifier: String(describing: OrderProductCell.self)) as! OrderProductCell
            cell.parentVC = self
            cell.treeItem = item

            let depth = item.depth
            if let prodStruct = item.data {
                cell.titleLabel.text = prodStruct.desc ?? ""
            }
            else {
                if depth == 0 {
                    cell.titleLabel.text = "Opportunities"
                }
                else {
                    let treeDesc = globalInfo.routeControl?.treeDesc ?? ""
                    let productDetail = item.productDetail
                    let reference = productDetail?.itemNo ?? ""
                    let shortDesc = productDetail?.shortDesc ?? ""
                    let fullDesc = productDetail?.desc ?? ""
                    if treeDesc != "1" {
                        cell.titleLabel.text = reference+" "+shortDesc
                    }
                    else {
                        cell.titleLabel.text = fullDesc
                    }
                }
            }

            if depth == 0 {
                cell.titleLabel.font = UIFont(name: "Roboto-Medium", size: 15.0)
            }
            else {
                cell.titleLabel.font = UIFont(name: "Roboto-Regular", size: 15.0)
            }

            let childNodeCount = item.childNodeArray?.count ?? 0
            if childNodeCount > 0 {
                cell.expandImageView.isHidden = false
                let expanded = treeView.isCell(forItemExpanded: item)
                if expanded == true {
                    cell.expandImageView.image = UIImage(named: "Tree_Minus")
                }
                else {
                    cell.expandImageView.image = UIImage(named: "Tree_Plus")
                }
            }
            else {
                cell.expandImageView.isHidden = true
            }

            let indent: CGFloat = CGFloat(depth)*15.0+10.0
            cell.leftMarginConstraint.constant = indent

            return cell
        }
        else {
            return UITableViewCell()
        }

    }

}

extension OrderVC: RATreeViewDelegate {

    func treeView(_ treeView: RATreeView, heightForRowForItem item: Any) -> CGFloat {
        return 35.0
    }

    func treeView(_ treeView: RATreeView, indentationLevelForRowForItem item: Any) -> Int {
        let treeItem = item as! TreeItem
        return treeItem.depth+1
    }

    func treeView(_ treeView: RATreeView, didSelectRowForItem item: Any) {
        treeView.deselectRow(forItem: item, animated: true)

        let forItem = item as! TreeItem
        let childNodeArray = forItem.childNodeArray

        if childNodeArray != nil && childNodeArray!.count > 0 {
            return
        }

        if forItem.depth == 0 {
            return
        }

        var itemNo = ""
        if let productStruct = forItem.data {
            itemNo = productStruct.reference ?? ""
        }
        else {
            itemNo = forItem.productDetail?.itemNo ?? ""
        }

        selectProduct(selectType: kSelectProductItemNo, itemNo: itemNo, itemUPC: "")
    }

    func treeView(_ treeView: RATreeView, canEditRowForItem item: Any) -> Bool {
        return false
    }

    func onLongPress(forItem: TreeItem) {

        let childNodeArray = forItem.childNodeArray

        if childNodeArray != nil && childNodeArray!.count > 0 {
            return
        }

        if forItem.depth == 0 {
            return
        }

        var itemNo = ""
        if let productStruct = forItem.data {
            itemNo = productStruct.reference ?? ""
        }
        else {
            itemNo = forItem.productDetail?.itemNo ?? ""
        }

        selectProductAndShowDetail(selectType: kSelectProductItemNo, itemNo: itemNo, itemUPC: "")
    }

    func treeView(_ treeView: RATreeView, didCollapseRowForItem item: Any) {
        //let treeItem = item as! TreeItem
        //let entryID = treeItem.data!.entryID ?? ""
        treeView.reloadRows(forItems: [item], with: RATreeViewRowAnimationNone)
    }

    func treeView(_ treeView: RATreeView, didExpandRowForItem item: Any) {
        //let treeItem = item as! TreeItem
        //let entryID = treeItem.data!.entryID ?? ""
        treeView.reloadRows(forItems: [item], with: RATreeViewRowAnimationNone)
    }
    
}

extension OrderVC {
    
    func getValAndStartCalculate() {
        if let _ = Double(priceLabel.text ?? ""), let _ = Double(costLabel.text ?? ""), let _ = Double(marginLabel.text ?? "") {
            
            let font:UIFont? = UIFont(name: "Helvetica", size:20)
            let fontSuper:UIFont? = UIFont(name: "Helvetica", size:10)
            let attString:NSMutableAttributedString = NSMutableAttributedString(string: L10n.ValuesAreInputed(), attributes: [.font:font!])
            attString.setAttributes([.font:fontSuper!,.baselineOffset:10], range: NSRange(location:28,length:2))
            
            Utils.showAlert(vc: self, title: L10n.dataInputIsInvalid(), attMessage: attString, failed: false, customerName: "", leftString: "", middleString: L10n.ok(), rightString: "", dismissHandler: nil)
            return
        }
        
        if let _priceVal = Double(priceLabel.text ?? ""), let _costVal = Double(costLabel.text ?? "") {
            priceVal = _priceVal
            costVal = _costVal
            doCalculateAndUpdateUI(1)
            return
        }
        
        if let _costVal = Double(costLabel.text ?? ""), let _marginVal = Double(marginLabel.text ?? "") {
            costVal = _costVal
            marginVal = _marginVal
            doCalculateAndUpdateUI(2)
            return
        }
        
        if let _priceVal = Double(priceLabel.text ?? ""), let _marginVal = Double(marginLabel.text ?? "") {
            priceVal = _priceVal
            marginVal = _marginVal
            doCalculateAndUpdateUI(3)
            return
        }
    }
    
    func doCalculateAndUpdateUI(_ caseVal: Int) {
        switch caseVal {
        case 1:
            if self.priceVal == 0 && self.costVal == 0 {
                self.marginVal = 0.0
            }
            else if self.priceVal == 0 {
                self.marginVal = kInitVal
            }
            else {
                self.marginVal = (1 - self.costVal / self.priceVal) * 100
            }
            self.updateCalcUI()

        case 2:
            if self.marginVal == 100.0 {
                self.priceVal = 0.0
            }
            else {
                self.priceVal = self.costVal / (1 - self.marginVal / 100)
            }
            self.updateCalcUI()

        case 3:
            if self.marginVal == 0.0 {
                self.costVal = self.priceVal
            }
            else {
                self.costVal = self.priceVal * (1 - self.marginVal / 100)
            }
            self.updateCalcUI()
        default:
            break
        }
    }

    func updateCalcUI() {
        if marginVal == kInitVal {
            marginLabel.text = "Invalid"
        }
        else {
            marginLabel.text = Utils.getDecimalString(moneyValue: marginVal)
        }
        priceLabel.text = Utils.getDecimalString(moneyValue: priceVal)
        costLabel.text = Utils.getDecimalString(moneyValue: costVal)
    }
}
