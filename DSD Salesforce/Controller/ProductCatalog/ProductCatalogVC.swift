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
    @IBOutlet weak var unitsPerCaseLabel: UILabel!
    @IBOutlet weak var unitPriceLabel: UILabel!
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

    var mainVC: MainVC!
    let globalInfo = GlobalInfo.shared

    var orderVC: OrderVC?
    var customerDetail: CustomerDetail?

    var productDetailArray = [ProductDetail]()

    let kBrandTitle = "BRAND"
    let kSubBrandTitle = "SUB BRAND"
    let kTypeTitle = "TYPE"
    let kGroupTitle = "GROUP"
    let kProductLineTitle = "PRODUCT LINE"
    let kMarketGroupTitle = "MARKET GROUP"

    let kBrandDescTypeID = "Brand"
    let kSubBrandDescTypeID = "SubBrand"
    let kItemTypeDescTypeID = "ItemType"
    let kProductGroupDescTypeID = "ProductGroup"
    let kProductLineDescTypeID = "ProductLine"
    let kMarketGroupDescTypeID = "MarketGroup"
    
    //type dictionary
    var kCatalogDic = ["Brand":"BRAND",
                       "SubBrand":"SUB BRAND",
                       "ItemType":"TYPE",
                       "ProductGroup":"GROUP",
                       "ProductLine":"PRODUCT LINE",
                       "MarketGroup":"MARKET GROUP"]
    
    var kFilterTitleArray = [String]()
    var kFilterDescTypeIDArray = [String]()

    var filterDescTypeArray = [[DescType]]()
    var selectedFilterIndexArray = [[Int]]()

    var selectedProductIndex: Int = -1

    var lastZoomScale: CGFloat = -1

    var productImageScrollViewWidth: CGFloat = 0
    var productImageScrollViewHeight: CGFloat = 0

    var onAddToOrderHandler: ((String, Int)->())?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
        initUI()
        // updateConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        mainVC.setTitleBarText(title: "PRODUCT CATALOG")
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

        filterCV.reloadData()
        reloadProduct()

        // if the window came from Order Screen
        if orderVC != nil {
            baseCasePriceTitleLabel.text = "Customer Price"
            qtyView.isHidden = false
            addToOrderButton.isHidden = false
        }
        else {
            baseCasePriceTitleLabel.text = "Base Case Price"
            qtyView.isHidden = true
            addToOrderButton.isHidden = true
        }

        //qtyTextField.text = "1"
        qtyTextField.delegate = self
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

        let caseFactorString = productDetail.productLocn?.caseFactor ?? ""
        let caseFactor = Double(caseFactorString) ?? 0

        if orderVC == nil {
            let basePriceString = productDetail.productLocn?.basePrice ?? ""
            let basePrice = (Double(basePriceString) ?? 0) / Double(kXMLNumberDivider)

            let casePrice = basePrice*caseFactor
            baseCasePriceLabel.text = Utils.getMoneyString(moneyValue: casePrice)

            var unitPrice: Double = 0
            if consumerUnit != 0 {
                unitPrice = casePrice/Double(consumerUnit)
            }
            else {
                unitPrice = casePrice
            }
            unitPriceLabel.text = Utils.getMoneyString(moneyValue: unitPrice)
        }
        else {
            let _ = productDetail.calculatePrice(context: globalInfo.managedObjectContext, customerDetail: customerDetail!)
            let price = productDetail.price
            let casePrice = price*caseFactor
            baseCasePriceLabel.text = Utils.getMoneyString(moneyValue: casePrice)

            var unitPrice: Double = 0
            if consumerUnit != 0 {
                unitPrice = casePrice/Double(consumerUnit)
            }
            else {
                unitPrice = casePrice
            }
            unitPriceLabel.text = Utils.getMoneyString(moneyValue: unitPrice)

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
                    addToOrderButton.setTitleForAllState(title: "Update Order")
                    qtyTextField.text = "\(orderQty)"
                }
                else {
                    addToOrderButton.setTitleForAllState(title: "Add to Order")
                    qtyTextField.text = "1"
                }
            }
            else {
                addToOrderButton.setTitleForAllState(title: "Add to Order")
                qtyTextField.text = "1"
            }
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
        let qty = Int(qtyTextField.text ?? "") ?? 0
        qtyTextField.text = "\(qty+1)"
    }

    @IBAction func onMinusQty(_ sender: Any) {
        var qty = (Int(qtyTextField.text ?? "") ?? 0)-1
        if qty <= 0 {
            qty = 0
        }
        qtyTextField.text = "\(qty)"
    }

    @IBAction func onAddToOrder(_ sender: Any) {
        if selectedProductIndex == -1 {
            return
        }
        let qty = Int(qtyTextField.text ?? "") ?? 0
        if qty == 0 {
            return
        }

        let productDetail = productDetailArray[selectedProductIndex]
        let itemNo = productDetail.itemNo ?? ""

        self.onAddToOrderHandler?(itemNo, qty)

        SVProgressHUD.showSuccess(withStatus: "The product has been added to the Order.")

        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.updateProduct()
        }
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
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCatalogProductCell", for: indexPath) as! ProductCatalogProductCell
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
        else /*if collectionView == productCV*/ {
            let totalHeight = collectionView.bounds.height
            return CGSize(width: ProductCatalogProductCell.kProductCellWidth, height: totalHeight)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == productCV {
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
        if textField == qtyTextField {
            textField.resignFirstResponder()
            return false
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == qtyTextField {
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
