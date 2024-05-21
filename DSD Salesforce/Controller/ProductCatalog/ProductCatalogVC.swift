//
//  ProductCatalogVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 6/10/19.
//  Copyright © 2019 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class ProductCatalogVC: UIViewController {

    @IBOutlet var productView: UIView!
    @IBOutlet weak var filterCV: UICollectionView!
    @IBOutlet weak var productCV: UICollectionView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var leftScrollButton: UIButton!
    @IBOutlet weak var rightScrollButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var itemNoLabel: UILabel!
    @IBOutlet weak var itemDescLabel: UILabel!
    @IBOutlet weak var barcodeLabel: UILabel!
    @IBOutlet weak var baseCasePriceLabel: UILabel!
    @IBOutlet weak var noProductLabel: UILabel!

    @IBOutlet weak var productImageScrollView: UIScrollView!
    @IBOutlet weak var productImageView: UIImageView!

    @IBOutlet weak var imageConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintRight: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintBottom: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintLeft: NSLayoutConstraint!
    @IBOutlet weak var marketGroup: UILabel!
    
    @IBOutlet weak var baseCasePriceTitleLabel: UILabel!
    @IBOutlet weak var qtyView: UIView!
    @IBOutlet weak var qtyTextField: AnimatableTextField!
    @IBOutlet weak var addToOrderButton: AnimatableButton!
    @IBOutlet weak var unitsPerCaseLabel: UILabel!
    @IBOutlet weak var unitPriceLabel: UILabel!
    @IBOutlet weak var barcodeTitleLabel: UILabel!
    @IBOutlet weak var unitsPerCaseTitleLabel: UILabel!
    @IBOutlet weak var unitPriceTitleLabel: UILabel!
    @IBOutlet var retailLabel: UILabel!
    @IBOutlet var retailStackView: UIStackView!
    
    @IBOutlet var viewSwitchButton: AnimatableButton!
    //titleProductView
    @IBOutlet var tileView: UIView!
    @IBOutlet var tileProductCV: UICollectionView!
    @IBOutlet var tileBaseCasePriceLabel: UILabel!
    @IBOutlet var tileUnitPerCaseLabel: UILabel!
    @IBOutlet var tileUnitPriceLabel: UILabel!
    @IBOutlet var tileQtyTextField: AnimatableTextField!
    @IBOutlet var tileQtyView: UIView!
    @IBOutlet var tileAddToOrder: AnimatableButton!
    @IBOutlet var tileRetailLabel: UILabel!
    @IBOutlet var tileRetailStackView: UIStackView!
    
    
    var mainVC: MainVC!
    let globalInfo = GlobalInfo.shared

    var orderVC: OrderVC?
    var customerDetail: CustomerDetail?
    var caseFactor: Int32 = 1

    var productDetailArray = [ProductDetail]()
    var isSearched = false
    
    let kBrandTitle = L10n.BRAND()
    let kSubBrandTitle = L10n.SUBBRAND()
    let kTypeTitle = L10n.type()
    let kGroupTitle = L10n.GROUP()
    let kProductLineTitle = L10n.ProductLine()
    let kMarketGroupTitle = L10n.MARKETGROUP()

    let kBrandDescTypeID = "Brand"
    let kSubBrandDescTypeID = "SubBrand"
    let kItemTypeDescTypeID = "ItemType"
    let kProductGroupDescTypeID = "ProductGroup"
    let kProductLineDescTypeID = "ProductLine"
    let kMarketGroupDescTypeID = "MarketGroup"
    
    var kCatalogDic = ["Brand":L10n.BRAND(),
                       "SubBrand":L10n.SUBBRAND(),
                       "ItemType":L10n.type(),
                       "ProductGroup":L10n.GROUP(),
                       "ProductLine":L10n.ProductLine(),
                       "MarketGroup":L10n.MARKETGROUP()]
    
    var kFilterTitleArray = [String]()
    var kFilterDescTypeIDArray = [String]()

    var filterDescTypeArray = [[DescType]]()
    var selectedFilterIndexArray = [[Int]]()

    var selectedProductIndex: Int = -1

    var lastZoomScale: CGFloat = -1

    var productImageScrollViewWidth: CGFloat = 0
    var productImageScrollViewHeight: CGFloat = 0

    var onAddToOrderHandler: ((String, Int)->())?
    
    private let sectionInsets = UIEdgeInsets(top: 50.0,
                                             left: 20.0,
                                             bottom: 50.0,
                                             right: 20.0)
    private let itemsPerRow: CGFloat = 4
    private let itemsPerCol: CGFloat = 3
    
    private var viewMode = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
        initUI()
        // updateConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        mainVC.setTitleBarText(title: L10n.productCatalog())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        globalInfo.isFromProductCatalog = 0
    }
    
    func getCatalogTypes() {
        if let catalogString:String = globalInfo.routeControl?.catalog {
            if catalogString != "" {
                let trimmed = catalogString.replace(string: " ", replacement: "")
                let catalogArr = trimmed.components(separatedBy:",")
                
                for item in catalogArr {
                    kFilterDescTypeIDArray.append(item)
                    kFilterTitleArray.append(kCatalogDic[item] ?? "")
                }
            }
            else {
                kFilterTitleArray = [kBrandTitle, kSubBrandTitle, kTypeTitle, kGroupTitle, kProductLineTitle, kMarketGroupTitle]
                kFilterDescTypeIDArray = [kBrandDescTypeID, kSubBrandDescTypeID, kItemTypeDescTypeID, kProductGroupDescTypeID, kProductLineDescTypeID, kMarketGroupDescTypeID]
            }
        }
    }

    func initData() {
        //kFilterTitleArray = [kBrandTitle, kSubBrandTitle, kTypeTitle, kGroupTitle, kProductLineTitle, kMarketGroupTitle]
        //kFilterDescTypeIDArray = [kBrandDescTypeID, kSubBrandDescTypeID, kItemTypeDescTypeID, kProductGroupDescTypeID, kProductLineDescTypeID, kMarketGroupDescTypeID]
        
        getCatalogTypes();
        
        // load filter desc type array
        filterDescTypeArray.removeAll()
        selectedFilterIndexArray.removeAll()
        for descTypeID in kFilterDescTypeIDArray {
            let descTypeArray = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: descTypeID)
            filterDescTypeArray.append(descTypeArray)
            selectedFilterIndexArray.append([])
        }
        
    }

    func initUI() {
        
        initViewMode()
        toggleView()
        
        barcodeTitleLabel.text = L10n.barcode()
        baseCasePriceTitleLabel.text = L10n.baseCasePrice()
        unitsPerCaseTitleLabel.text = L10n.unitsPerCase()
        unitPriceTitleLabel.text = L10n.unitPrice()
        addToOrderButton.setTitleForAllState(title: L10n.addToOrder())
        noDataLabel.text = L10n.thereIsNoData()
        noProductLabel.text = L10n.pleaseSelectAProduct()
        
        // get UI constants
        let screenBounds = UIScreen.main.bounds
        productImageScrollViewWidth = screenBounds.width/2-20.0
        productImageScrollViewHeight = screenBounds.height-68.0-70.0-100.0-40.0

        productImageScrollView.maximumZoomScale = 2.0

        filterCV.dataSource = self
        filterCV.delegate = self
        filterCV.delaysContentTouches = false
        
        productCV.dataSource = self
        productCV.delegate = self
        productCV.backgroundView?.backgroundColor = .clear
        productCV.backgroundColor = .clear
        
        tileProductCV.dataSource = self
        tileProductCV.delegate = self

        filterCV.reloadData()
        reloadProduct()

        // if the window came from Order Screen
        if orderVC != nil {
            baseCasePriceTitleLabel.text = "Customer Price"
            qtyView.isHidden = false
            addToOrderButton.isHidden = false
            
            tileQtyView.isHidden = false
            tileAddToOrder.isHidden = false
        }
        else {
            baseCasePriceTitleLabel.text = "Base Case Price"
            qtyView.isHidden = true
            addToOrderButton.isHidden = true
            
            tileQtyView.isHidden = true
            tileAddToOrder.isHidden = true
        }

        qtyTextField.text = String(caseFactor)
        tileQtyTextField.text = String(caseFactor)
        qtyTextField.delegate = self
        tileQtyTextField.delegate = self
        qtyTextField.addTarget(self, action: #selector(onQtyEditingChanged(_:)), for: .editingDidEnd)
        tileQtyTextField.addTarget(self, action: #selector(onTileQtyEditingChanged(_:)), for: .editingDidEnd)
    }
    
    @objc func onQtyEditingChanged(_ sender: Any) {
        
        let newQty = Int(qtyTextField.text ?? "") ?? 0

        if newQty.int32 % caseFactor == 0 {
            qtyTextField.text = String(newQty)
            self.qty = newQty
        }
        else {
            qtyTextField.text = String(self.qty)
            Utils.showAlert(vc: self, title: "", message: "This item must be ordered in multiples of \(caseFactor) as it can only be returned in full cases", failed: false, customerName: "", leftString: "", middleString: "", rightString: L10n.return(), dismissHandler: nil)
        }
    }
    
    @objc func onTileQtyEditingChanged(_ sender: Any) {
        
        let newQty = Int(tileQtyTextField.text ?? "") ?? 0
        
        switch orderVC!.selectedTopOption {
        case .returns:
            switch customerDetail!.rtnEntryMode {
            case "C":
                if newQty.int32 % caseFactor == 0 {
                    tileQtyTextField.text = String(newQty)
                    self.tileQty = newQty
                }
                else {
                    tileQtyTextField.text = String(self.tileQty)
                    Utils.showAlert(vc: self, title: "", message: "This item must be ordered in multiples of \(caseFactor) as it can only be returned in full cases", failed: false, customerName: "", leftString: "", middleString: "", rightString: L10n.return(), dismissHandler: nil)
                }
                break
            default:
                tileQtyTextField.text = String(newQty)
                break
            }
            break
            
        default:
            switch customerDetail!.salEntryMode {
                case "C":
                if newQty.int32 % caseFactor == 0 {
                    tileQtyTextField.text = String(newQty)
                    self.tileQty = newQty
                }
                else {
                    tileQtyTextField.text = String(self.tileQty)
                    Utils.showAlert(vc: self, title: "", message: "This item must be ordered in multiples of \(caseFactor) as it can only be sold in full cases", failed: false, customerName: "", leftString: "", middleString: "", rightString: L10n.return(), dismissHandler: nil)
                }
                break
            default:
                tileQtyTextField.text = String(newQty)
                break
            }
            break
        }
    }
    
    func initViewMode() {
        if globalInfo.routeControl?.catalogView == "SHOW" || globalInfo.routeControl?.catalogView == "" {
            self.viewMode = true
        }
        else if globalInfo.routeControl?.catalogView == "TILE" {
            self.viewMode = false
        }
    }
    
    func toggleView() {
        
        if viewMode {
            tileView.isHidden = true
            productView.isHidden = false
            contentView.isHidden = false
            viewSwitchButton.setImage(UIImage(named: "icon_tile_view"), for: .normal)
        }
        else {
            tileView.isHidden = false
            productView.isHidden = true
            contentView.isHidden = true
            viewSwitchButton.setImage(UIImage(named: "icon_showcase_view"), for: .normal)
        }
    }

    func reloadProduct() {

        var brandKeyArray = [String]()
        var subBrandKeyArray = [String]()
        var itemTypeKeyArray = [String]()
        var productGroupKeyArray = [String]()
        var productLineKeyArray = [String]()
        var marketGroupKeyArray = [String]()

        for (descTypeGroupIndex, selectedIndexArray) in selectedFilterIndexArray.enumerated() {
            if selectedIndexArray.count == 0 {
                continue
            }
            let descTypeID = kFilterDescTypeIDArray[descTypeGroupIndex]
            if descTypeID == kBrandDescTypeID {
                brandKeyArray = selectedIndexArray.map { (selectedIndex) -> String in
                    return self.filterDescTypeArray[descTypeGroupIndex][selectedIndex].alphaKey ?? ""
                }
            }
            else if descTypeID == kSubBrandDescTypeID {
                subBrandKeyArray = selectedIndexArray.map { (selectedIndex) -> String in
                    return self.filterDescTypeArray[descTypeGroupIndex][selectedIndex].alphaKey ?? ""
                }
            }
            else if descTypeID == kItemTypeDescTypeID {
                itemTypeKeyArray = selectedIndexArray.map { (selectedIndex) -> String in
                    return self.filterDescTypeArray[descTypeGroupIndex][selectedIndex].alphaKey ?? ""
                }
            }
            else if descTypeID == kProductGroupDescTypeID {
                productGroupKeyArray = selectedIndexArray.map { (selectedIndex) -> String in
                    return self.filterDescTypeArray[descTypeGroupIndex][selectedIndex].alphaKey ?? ""
                }
            }
            else if descTypeID == kProductLineDescTypeID {
                productLineKeyArray = selectedIndexArray.map { (selectedIndex) -> String in
                    return self.filterDescTypeArray[descTypeGroupIndex][selectedIndex].alphaKey ?? ""
                }
            }
            else if descTypeID == kMarketGroupDescTypeID {
                marketGroupKeyArray = selectedIndexArray.map { (selectedIndex) -> String in
                    return self.filterDescTypeArray[descTypeGroupIndex][selectedIndex].alphaKey ?? ""
                }
            }
        }

        productDetailArray = ProductDetail.getBy(context: globalInfo.managedObjectContext, brandArray: brandKeyArray, subBrandArray: subBrandKeyArray, itemTypeArray: itemTypeKeyArray, productGroupArray: productGroupKeyArray, productLineArray: productLineKeyArray, marketGroupArray: marketGroupKeyArray)
        /*
        productDetailArray = productDetailArray.filter({ (productDetail) -> Bool in
            if productDetail.productLevl == nil {
                return false
            }
            else {
                return true
            }
        })*/
        productDetailArray = productDetailArray.sorted(by: { (productDetail1, productDetail2) -> Bool in
            let itemNo1 = productDetail1.itemNo ?? ""
            let itemNo2 = productDetail2.itemNo ?? ""
            return itemNo1 < itemNo2
        })

        if productDetailArray.count > 0 {
            onProductTapped(index: 0)
        }
        else {
            onProductTapped(index: -1)
        }

        if productDetailArray.count > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.productCV.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: true)
            }
        }
    }

    func refreshProduct() {
        productCV.reloadData()
        tileProductCV.reloadData()

        if productDetailArray.count == 0 {
            noDataLabel.isHidden = false
        }
        else {
            noDataLabel.isHidden = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.checkScrollButtons()
        }
    }

    func checkScrollButtons() {

        if productDetailArray.count == 0 {
            leftScrollButton.isEnabled = false
            rightScrollButton.isEnabled = false
            return
        }

        let contentOffset = productCV.contentOffset
        if contentOffset.x <= 0 {
            leftScrollButton.isEnabled = false
        }
        else {
            leftScrollButton.isEnabled = true
        }

        let contentLastPos = -contentOffset.x+productCV.contentSize.width
        if contentLastPos > productCV.bounds.size.width {
            rightScrollButton.isEnabled = true
        }
        else {
            rightScrollButton.isEnabled = false
        }
    }

    func updateProduct() {
        if selectedProductIndex == -1 {
            contentView.isHidden = true
            noProductLabel.isHidden = false
            return
        }
        else {
            contentView.isHidden = false
            noProductLabel.isHidden = true
        }

        // update product values
        let productDetail = productDetailArray[selectedProductIndex]

        let itemNo = productDetail.itemNo ?? ""
        itemNoLabel.text = itemNo
        itemDescLabel.text = productDetail.desc ?? ""

        barcodeLabel.text = productDetail.itemUPC ?? ""
        //marketGroup.text = productDetail.marketGrp ?? ""
        
        //add by rsb 2019-11-30
        let marketGrp = productDetail.marketGrp ?? ""
        marketGroup.text = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "MarketGroup", alphaKey: marketGrp)?.desc ?? ""
        
        productImageView.image = Utils.getProductImage(itemNo: itemNo)

        lastZoomScale = -1
        productImageScrollView.delegate = self
        updateZoom()
        updateConstraints()

        let consumerUnitString = productDetail.consumerUnit ?? ""
        let consumerUnit = Double(consumerUnitString) ?? 0

        let _ = Utils.getCaseValue(itemNo: itemNo)
        unitsPerCaseLabel.text = "\(Int(consumerUnit))"
        //tileView
        tileUnitPerCaseLabel.text = "\(Int(consumerUnit))"

        let caseFactorString = productDetail.productLocn?.caseFactor ?? ""
        let caseFactor = Double(caseFactorString) ?? 0

        if orderVC == nil {
            let basePriceString = productDetail.productLocn?.basePrice ?? ""
            let basePrice = (Double(basePriceString) ?? 0) / Double(kXMLNumberDivider)

            let casePrice = basePrice*caseFactor
            baseCasePriceLabel.text = Utils.getMoneyString(moneyValue: casePrice)
            //tileView
            tileBaseCasePriceLabel.text = Utils.getMoneyString(moneyValue: casePrice)

            var unitPrice: Double = 0
            if consumerUnit != 0 {
                unitPrice = casePrice/Double(consumerUnit)
            }
            else {
                unitPrice = casePrice
            }
            unitPriceLabel.text = Utils.getMoneyString(moneyValue: unitPrice)
            //tileView
            tileUnitPriceLabel.text = Utils.getMoneyString(moneyValue: unitPrice)
        }
        else {
            let _ = productDetail.calculatePrice(context: globalInfo.managedObjectContext, customerDetail: customerDetail!)
            let price = productDetail.price
            let casePrice = price*caseFactor
            baseCasePriceLabel.text = Utils.getMoneyString(moneyValue: casePrice)
            //tileView
            tileBaseCasePriceLabel.text = Utils.getMoneyString(moneyValue: casePrice)

            var unitPrice: Double = 0
            if consumerUnit != 0 {
                unitPrice = casePrice/Double(consumerUnit)
            }
            else {
                unitPrice = casePrice
            }
            unitPriceLabel.text = Utils.getMoneyString(moneyValue: unitPrice)
            //tileView
            tileUnitPriceLabel.text = Utils.getMoneyString(moneyValue: unitPrice)

            let selectedTabIndex = orderVC!.selectedTopOption.rawValue
            if selectedTabIndex >= 0 && selectedTabIndex <= 2 {
                let orderDetailArray = orderVC!.orderDetailSetArray[selectedTabIndex]
                var orderQty = 0
                for _orderDetail in orderDetailArray {
                    let orderDetail = _orderDetail as! OrderDetail
                    let _itemNo = orderDetail.itemNo
                    if itemNo == _itemNo {
                        orderQty = orderDetail.enterQty.int
                        break
                    }
                }
                if orderQty > 0 {
                    addToOrderButton.setTitleForAllState(title: L10n.updateOrder())
                    tileAddToOrder.setTitleForAllState(title: L10n.updateOrder())
                    qtyTextField.text = "\(orderQty)"
                    tileQtyTextField.text = "\(orderQty)"
                }
                else {
                    addToOrderButton.setTitleForAllState(title: L10n.addToOrder())
                    tileAddToOrder.setTitleForAllState(title: L10n.addToOrder())
                    qtyTextField.text = String(self.caseFactor)
                    tileQtyTextField.text = String(self.caseFactor)
                }
            }
            else {
                addToOrderButton.setTitleForAllState(title: L10n.addToOrder())
                tileAddToOrder.setTitleForAllState(title: L10n.addToOrder())
                qtyTextField.text = String(self.caseFactor)
                tileQtyTextField.text = String(self.caseFactor)
            }
        }
        if let _retailPrice = ProductLocn.getBy(context: globalInfo.managedObjectContext, itemNo: itemNo).first?.retailPrice, _retailPrice != "0", let retailPrice = Double(_retailPrice) {
            tileRetailStackView.isHidden = false
            retailStackView.isHidden = false
            tileRetailLabel.text = Utils.getMoneyString(moneyValue: retailPrice / 100000)
            retailLabel.text = Utils.getMoneyString(moneyValue: retailPrice / 100000)
        }
        else {
            tileRetailStackView.isHidden = true
            retailStackView.isHidden = true
        }
    }

    // Zoom to show as much image as possible unless image is smaller than the scroll view
    func updateZoom() {

        let image = productImageView.image
        if image == nil {
            return
        }

        var minZoom = min(productImageScrollViewWidth / image!.size.width,
                          productImageScrollViewHeight / image!.size.height)

        // if minZoom > 1 { minZoom = 1 }

        productImageScrollView.minimumZoomScale = minZoom

        // Force scrollViewDidZoom fire if zoom did not change
        if minZoom == lastZoomScale { minZoom += 0.000001 }

        productImageScrollView.zoomScale = minZoom
        lastZoomScale = minZoom
    }

    func updateConstraints() {

        let image = productImageView.image
        if image == nil {
            return
        }

        let imageWidth = image!.size.width
        let imageHeight = image!.size.height

        // let originalBounds = UIScreen.main.bounds
        let viewWidth: CGFloat = productImageScrollViewWidth
        let viewHeight: CGFloat = productImageScrollViewHeight

        // center image if it is smaller than the scroll view
        var hPadding = floor((viewWidth - productImageScrollView.zoomScale * imageWidth) / 2)
        if hPadding < 0 { hPadding = 0 }

        var vPadding = floor((viewHeight - productImageScrollView.zoomScale * imageHeight) / 2)
        if vPadding < 0 { vPadding = 0 }

        imageConstraintLeft.constant = hPadding
        imageConstraintRight.constant = hPadding

        imageConstraintTop.constant = vPadding
        imageConstraintBottom.constant = vPadding

        view.layoutIfNeeded()
    }

    func onFilterSelected(index: Int, selectedIndexArray: [Int]) {

        selectedFilterIndexArray[index] = selectedIndexArray
        filterCV.reloadData()

        reloadProduct()
    }

    func onProductTapped(index: Int) {
        selectedProductIndex = index
        
        if selectedProductIndex == -1 {
            return
        }
        let productDetail = productDetailArray[selectedProductIndex]
        let itemNo = productDetail.itemNo ?? ""
        
        if orderVC!.selectedTopOption == .returns {
            if customerDetail!.rtnEntryMode == "C" {
                if let prodLocn = ProductLocn.getBy(context: globalInfo.managedObjectContext, itemNo: itemNo).first {
                    caseFactor = Int32(prodLocn.caseFactor ?? "1") ?? 1
                }
            }
        }
        else {
            if customerDetail!.salEntryMode == "C" {
                if let prodLocn = ProductLocn.getBy(context: globalInfo.managedObjectContext, itemNo: itemNo).first {
                    caseFactor = Int32(prodLocn.caseFactor ?? "1") ?? 1
                }
            }
        }
        qty = caseFactor.int
        tileQty = caseFactor.int
        
        refreshProduct()
        updateProduct()
    }

    func onFilterTapped(index: Int) {
        // need to adjust collection view's scroll
    }

    @IBAction func onLeftScrollTapped(_ sender: Any) {
        if productDetailArray.count == 0 {
            return
        }
        var visibleIndexPaths = productCV.indexPathsForVisibleItems
        visibleIndexPaths = visibleIndexPaths.sorted(by: { (indexPath1, indexPath2) -> Bool in
            return indexPath1<indexPath2
        })
        guard let firstIndexPath = visibleIndexPaths.first else { return }
        let targetIndex = max(0, firstIndexPath.row-(visibleIndexPaths.count-1))
        productCV.scrollToItem(at: IndexPath(row: targetIndex, section: 0), at: .left, animated: true)
    }

    @IBAction func onRightScrollTapped(_ sender: Any) {
        if productDetailArray.count == 0 {
            return
        }
        var visibleIndexPaths = productCV.indexPathsForVisibleItems
        visibleIndexPaths = visibleIndexPaths.sorted(by: { (indexPath1, indexPath2) -> Bool in
            return indexPath1<indexPath2
        })
        guard let lastIndexPath = visibleIndexPaths.last else { return }
        let targetIndex = min(productDetailArray.count-1, lastIndexPath.row+(visibleIndexPaths.count-1))
        productCV.scrollToItem(at: IndexPath(row: targetIndex, section: 0), at: .right, animated: true)
    }

    @IBAction func onPlusQty(_ sender: Any) {

//        var qty = Int(qtyTextField.text ?? "") ?? 0
//        var tileQty = Int(tileQtyTextField.text ?? "") ?? 0

        qty += caseFactor.int
        tileQty += caseFactor.int
        qtyTextField.text = "\(qty)"
        tileQtyTextField.text = "\(tileQty)"
    }

    @IBAction func onMinusQty(_ sender: Any) {

//        var qty = Int(qtyTextField.text ?? "") ?? 0
//        var tileQty = Int(tileQtyTextField.text ?? "") ?? 0
 
        qty = max(qty-caseFactor.int, 0)
        tileQty = max(tileQty-caseFactor.int, 0)
        qtyTextField.text = "\(qty)"
        tileQtyTextField.text = "\(tileQty)"
    }

    var qty = 0
    var tileQty = 0
    @IBAction func onAddToOrder(_ sender: Any) {
    
        if selectedProductIndex == -1 {
            return
        }
        
        let newQty = Int(qtyTextField.text ?? "") ?? 0
        if newQty % caseFactor.int == 0 {
            qty = newQty
        }
        if newQty % caseFactor.int != 0 {
            qtyTextField.text = String(qty)
            Utils.showAlert(vc: self, title: "", message: "This item must be ordered in multiples of \(caseFactor) as it can only be returned in full cases", failed: false, customerName: "", leftString: "", middleString: "", rightString: L10n.return(), dismissHandler: nil)
            return
        }
        
        let tileNewQty = Int(tileQtyTextField.text ?? "") ?? 0
        if tileNewQty % caseFactor.int == 0 {
            tileQty = tileNewQty
        }
        if tileNewQty % caseFactor.int != 0 {
            tileQtyTextField.text = String(tileQty)
            Utils.showAlert(vc: self, title: "", message: "This item must be ordered in multiples of \(caseFactor) as it can only be returned in full cases", failed: false, customerName: "", leftString: "", middleString: "", rightString: L10n.return(), dismissHandler: nil)
            return
        }
        
        //let qty = Int(qtyTextField.text ?? "") ?? 0
        if qty == 0 {
            return
        }
        
//        let tileQty = Int(tileQtyTextField.text ?? "") ?? 0
        if tileQty == 0 {
            return
        }

        let productDetail = productDetailArray[selectedProductIndex]
        let itemNo = productDetail.itemNo ?? ""
        
        if viewMode {
            self.onAddToOrderHandler?(itemNo, qty)
        }
        else {
            self.onAddToOrderHandler?(itemNo, tileQty)
        }

        SVProgressHUD.showSuccess(withStatus: "The product has been added to the Order.")

        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.updateProduct()
        }
    }
    
    @IBAction func onSearch(_ sender: Any) {
        let searchProductVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "SearchProductVC") as! SearchProductVC
        searchProductVC.setDefaultModalPresentationStyle()
        searchProductVC.isEnableFilterAuthorizedItem = true
        searchProductVC.isFromCatalog = true
        searchProductVC.customerDetail = customerDetail
        searchProductVC.dismissHandler = { vc, dismissOption in
            if dismissOption == .cancelled {
                self.isSearched = true
                self.filterCV.reloadData()
                
                for (index, _) in self.kFilterTitleArray.enumerated()
                {
                    self.onFilterSelected(index: index, selectedIndexArray: [])
                }
                
                self.productDetailArray = vc.searchedArray
                self.productDetailArray = self.productDetailArray.sorted(by: { (productDetail1, productDetail2) -> Bool in
                    let itemNo1 = productDetail1.itemNo ?? ""
                    let itemNo2 = productDetail2.itemNo ?? ""
                    return itemNo1 < itemNo2
                })

                if self.productDetailArray.count > 0 {
                    self.onProductTapped(index: -1)
                }
                else {
                    self.onProductTapped(index: -1)
                }
            }
        }
        self.present(searchProductVC, animated: true, completion: nil)
    }
    
    @IBAction func onSwitch(_ sender: Any) {
        self.viewMode = !viewMode
        self.toggleView()
    }
    
    @IBAction func onClose(_ sender: Any) {
        mainVC.popChild(containerView: mainVC.containerView)
    }
    
}

extension ProductCatalogVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == filterCV {
            return filterDescTypeArray.count
        }
        else {
            return productDetailArray.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == filterCV {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCatalogFilterCell", for: indexPath) as! ProductCatalogFilterCell
            cell.setupCell(parentVC: self, indexPath: indexPath)
            return cell
        }
        else if collectionView == productCV {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCatalogProductCell", for: indexPath) as! ProductCatalogProductCell
            cell.setupCell(parentVC: self, indexPath: indexPath)
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tileProductCatalogProductCell", for: indexPath) as! tileProductCatalogProductCell
            cell.setupCell(parentVC: self, indexPath: indexPath)
            return cell
        }
    }
}

extension ProductCatalogVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == filterCV {
            let totalWidth = collectionView.bounds.width
            let totalHeight = collectionView.bounds.height
            let kFilterCount = filterDescTypeArray.count
            let availableWidth = totalWidth-CGFloat(kFilterCount-1)*1
            let normalWidth = ceil((availableWidth/CGFloat(kFilterCount)))
            let lastWidth = availableWidth-normalWidth*CGFloat(kFilterCount-1)
            if indexPath.row != kFilterCount-1 {
                return CGSize(width: normalWidth, height: totalHeight)
            }
            else {
                return CGSize(width: lastWidth, height: totalHeight)
            }
        }
        else if collectionView == productCV {
            let totalHeight = collectionView.bounds.height
            return CGSize(width: ProductCatalogProductCell.kProductCellWidth, height: totalHeight)
        }
        else {
            let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
            let availableWidth = collectionView.frame.width - paddingSpace
            let widthPerItem = availableWidth / itemsPerRow
            return CGSize(width: widthPerItem, height: widthPerItem)
        }
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == tileProductCV {
            return sectionInsets
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == tileProductCV {
            return sectionInsets.left
        }
        return CGFloat(0)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == productCV || collectionView == tileProductCV{
            collectionView.deselectItem(at: indexPath, animated: false)
            onProductTapped(index: indexPath.row)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == productCV {
            // check if the button's enablity
            checkScrollButtons()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == productCV {
            // check if the button's enablity
            checkScrollButtons()
        }
    }
}

extension ProductCatalogVC: UIScrollViewDelegate {

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraints()
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.productImageView
    }
}

extension ProductCatalogVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == qtyTextField || textField == tileQtyTextField{
            textField.resignFirstResponder()
            return false
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == qtyTextField || textField == tileQtyTextField {
            switch string {
            case "0","1","2","3","4","5","6","7","8","9":
                return true
            case "":
                return true
            default:
                return false
            }
        }
        return true
    }

}

extension String {
   func replace(string:String, replacement:String) -> String {
       return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
   }

   func removeWhitespace() -> String {
       return self.replace(string: " ", replacement: "")
   }
 }
