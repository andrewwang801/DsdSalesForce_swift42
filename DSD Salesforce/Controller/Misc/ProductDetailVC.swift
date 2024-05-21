//
//  ProductDetailVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 2/25/19.
//  Copyright © 2019 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class ProductDetailVC: UIViewController {

    @IBOutlet weak var itemNoLabel: UILabel!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var groupValueLabel: UILabel!
    @IBOutlet weak var brandValueLabel: UILabel!
    @IBOutlet weak var barcodeValueLabel: UILabel!
    @IBOutlet weak var unitsPerCaseValueLabel: UILabel!
    @IBOutlet weak var casePriceValueLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var lineValueLabel: UILabel!
    @IBOutlet weak var subBrandValueLabel: UILabel!
    @IBOutlet weak var subBrandLabel: UILabel!
    @IBOutlet weak var unitRRPValueLabel: UILabel!
    @IBOutlet weak var inventoryValueLabel: UILabel!
    @IBOutlet weak var grossMarginTitleLabel: UILabel!
    @IBOutlet weak var grossMarginValueLabel: UILabel!
    @IBOutlet weak var qtyText: AnimatableTextField!
    @IBOutlet weak var productImageScrollView: UIScrollView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var qtyView: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var unitPriceLabel: UILabel!
    @IBOutlet weak var unitPercaseLabel: UILabel!
    @IBOutlet weak var barcodeLabel: UILabel!
    @IBOutlet weak var inventoryLabel: UILabel!
    @IBOutlet weak var casePriceLabel: UILabel!
    @IBOutlet weak var doneButton: AnimatableButton!
    
    @IBOutlet weak var imageConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintRight: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintBottom: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintLeft: NSLayoutConstraint!

    @IBOutlet var retailLabel: UILabel!
    @IBOutlet var retailStackView: UIStackView!
    
    @IBOutlet weak var marketGoupDescLabel: UILabel!
    //heights
    @IBOutlet weak var lineHeight: NSLayoutConstraint!
    @IBOutlet weak var subBrandHeight: NSLayoutConstraint!
    @IBOutlet weak var marketGroupHeight: NSLayoutConstraint!
    @IBOutlet weak var groupHeight: NSLayoutConstraint!
    @IBOutlet weak var brandHeight: NSLayoutConstraint!
    
    let kProductImageSmallWidth: CGFloat = 180.0
    let kProductImageSmallHeight: CGFloat = 180.0
    let kProductImageScrollViewWidth: CGFloat = 500.0
    let kProductImageScrollViewHeight: CGFloat = 390.0

    let globalInfo = GlobalInfo.shared
    var productDetail: ProductDetail!
    var isForInputQty = false
    var inputedQty = 0
    var customerDetail: CustomerDetail!

    var lastZoomScale: CGFloat = -1

    enum DismissOption {
        case done
    }
    var dismissHandler: ((ProductDetailVC, DismissOption)->())?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
        updateConstraints()
    }

    func hideAllCatalog() {
        brandValueLabel.isHidden = true
        brandLabel.isHidden = true
        brandHeight.constant = 0
        
        subBrandValueLabel.isHidden = true
        subBrandLabel.isHidden = true
        subBrandHeight.constant = 0
        
        groupValueLabel.isHidden = true
        groupLabel.isHidden = true
        groupHeight.constant = 0
        
        lineValueLabel.isHidden = true
        lineLabel.isHidden = true
        //lineHeight.constant = 0
        
        /*marketGruop.isHidden = true
        marketGoupDescLabel.isHidden = true
        marketGroupHeight.constant = 0*/
    }
    
    func setDesctypeUI() {
        
        hideAllCatalog()
        
        if let catalogString:String = globalInfo.routeControl?.catalog {
            let trimmed = catalogString.replace(string: " ", replacement: "")
            let catalogArr = trimmed.components(separatedBy:",")
            
            for item in catalogArr {
                switch item {
                case "Brand":
                    brandValueLabel.isHidden = false
                    brandLabel.isHidden = false;
                    brandHeight.constant = 35
                case "SubBrand":
                    subBrandValueLabel.isHidden = false
                    subBrandLabel.isHidden = false
                    subBrandHeight.constant = 35
                case "ProductGroup":
                    groupValueLabel.isHidden = false
                    groupLabel.isHidden = false
                    groupHeight.constant = 50
                case "ProductLine":
                    lineValueLabel.isHidden = false
                    lineLabel.isHidden = false
                    lineHeight.constant = 35
                /*case "MarketGroup":
                    marketGruop.isHidden = false
                    marketGoupDescLabel.isHidden = false
                    marketGroupHeight.constant = 35*/
                default:
                    print("default block");
                }
            }
        }
        else {
            
        }
    }
    
    func initUI() {

        titleLabel.text = L10n.productDetails()
        groupLabel.text = L10n.group()
        brandLabel.text = L10n.brand()
        barcodeLabel.text = L10n.barcode()
        casePriceLabel.text = L10n.casePrice()
        inventoryLabel.text = L10n.inventory()
        lineLabel.text = L10n.line()
        subBrandLabel.text = L10n.SubBrand()
        unitPercaseLabel.text = L10n.unitsPerCase()
        unitPriceLabel.text = L10n.unitPrice()
        grossMarginTitleLabel.text = L10n.grossMargin()
        doneButton.setTitleForAllState(title: L10n.Done())
        
        // populate the all components
        let itemNo = productDetail.itemNo ?? ""
        itemNoLabel.text = itemNo
        descLabel.text = productDetail.desc ?? ""
        let prodGroup = productDetail.prodGrp ?? ""
        groupLabel.text = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "ProductGroup", alphaKey: prodGroup)?.desc ?? ""
        let brand = productDetail.brand ?? ""
        brandValueLabel.text = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "Brand", alphaKey: brand)?.desc ?? ""
        barcodeValueLabel.text = productDetail.itemUPC ?? ""
        let prodLine = productDetail.prodLine ?? ""
        lineValueLabel.text = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "ProductLine", alphaKey: prodLine)?.desc ?? ""
        let subBrand = productDetail.subBrand ?? ""
        subBrandValueLabel.text = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "SubBrand", alphaKey: subBrand)?.desc ?? ""
        
        //add by rsb 2019-11-30
        let marketGroup = productDetail.marketGrp ?? ""
        marketGoupDescLabel.text = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "MarketGroup", alphaKey: marketGroup)?.desc ?? ""
        
        //add by rsb 2020-2-17, retail price
        if let _retailPrice = ProductLocn.getBy(context: globalInfo.managedObjectContext, itemNo: itemNo).first?.retailPrice, _retailPrice != "0", let retailPrice = Double(_retailPrice) {

            retailStackView.isHidden = false
            retailLabel.text = Utils.getMoneyString(moneyValue: retailPrice / 100000)
        }
        else {
            retailStackView.isHidden = true
        }
        
        setDesctypeUI()
        
        let consumerUnitString = productDetail.consumerUnit ?? ""
        let consumerUnit = Double(consumerUnitString) ?? 0

        let _ = Utils.getCaseValue(itemNo: itemNo)
        unitsPerCaseValueLabel.text = "\(Int(consumerUnit))"

        let basePriceString = productDetail.productLocn?.basePrice ?? ""
        let basePrice = (Double(basePriceString) ?? 0) / Double(kXMLNumberDivider)

        let caseFactorString = productDetail.productLocn?.caseFactor ?? ""
        let caseFactor = Double(caseFactorString) ?? 0

        var price: Double = 0
        let chainNo = customerDetail.chainNo ?? "0"
        let custNo = customerDetail.custNo ?? "0"
        // let priceGroup = customerDetail.priceGrp ?? "0"

        let pricing = Pricing.getByForToday(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo, itemNo: itemNo)
        if pricing != nil {
            price = (Double(pricing!.price ?? "") ?? 0) / Double(kXMLNumberDivider)
        }
        else {
            let priceGrp = PriceGroup.getByForToday(context: globalInfo.managedObjectContext, priceGroup: custNo, itemNo: itemNo)
            if priceGrp != nil {
                price = (Double(priceGrp!.price ?? "") ?? 0) / Double(kXMLNumberDivider)
            }
            else {
                price = basePrice
            }
        }
        let casePrice = price*caseFactor

        casePriceValueLabel.text = Utils.getMoneyString(moneyValue: casePrice)

        var unitPrice: Double = 0
        if consumerUnit != 0 {
            unitPrice = casePrice/Double(consumerUnit)
        }
        else {
            unitPrice = casePrice
        }
        unitRRPValueLabel.text = Utils.getMoneyString(moneyValue: unitPrice)

        let productLevl = productDetail.productLevl
        if productLevl == nil {
            inventoryValueLabel.text = ""
        }
        else {
            let inventoryAmount = Utils.getXMLDivided(valueString: productLevl?.qty ?? "0")
            inventoryValueLabel.text = inventoryAmount.integerString
        }
        
        
        // gross margin
        let itemCost = Utils.getXMLDivided(valueString: productDetail?.productLocn?.costPrice ?? "0")
        if itemCost == 0 {
            grossMarginTitleLabel.isHidden = true
            grossMarginValueLabel.isHidden = true
        }
        else {
            grossMarginTitleLabel.isHidden = false
            grossMarginValueLabel.isHidden = false
            
            // get gross margin
            var grossMargin: Double = 0
            if casePrice == 0 {
                grossMargin = 0
            }
            else {
                grossMargin = (casePrice-itemCost)/casePrice*100
                grossMarginValueLabel.text = "\(grossMargin.oneDecimalString)%"
            }
        }
        
        productImageView.image = Utils.getProductImage(itemNo: itemNo)

        qtyText.text = "0"
        qtyText.delegate = self

        if isForInputQty == true {
            qtyView.isHidden = false
            qtyText.text = "\(inputedQty)"
            // qtyText.becomeFirstResponder()
        }
        else {
            qtyView.isHidden = true
        }

        productImageScrollView.delegate = self
        updateZoom()
    }

    @available(iOS 8.0, *)
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.updateZoom()
            }, completion: nil)
    }

    // Zoom to show as much image as possible unless image is smaller than the scroll view
    func updateZoom() {

        let image = productImageView.image
        if image == nil {
            return
        }

        var minZoom = min(kProductImageSmallWidth / image!.size.width,
                          kProductImageSmallHeight / image!.size.height)

        if minZoom > 1 { minZoom = 1 }

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
        let viewWidth: CGFloat = kProductImageScrollViewWidth
        let viewHeight: CGFloat = kProductImageScrollViewHeight

        // center image if it is smaller than the scroll view
        var hPadding = floor((viewWidth - productImageScrollView.zoomScale * imageWidth) / 2)
        if hPadding < 0 { hPadding = 0 }

        var vPadding = floor((viewHeight - productImageScrollView.zoomScale * imageHeight))
        if vPadding < 0 { vPadding = 0 }

        imageConstraintLeft.constant = hPadding
        imageConstraintRight.constant = hPadding

        imageConstraintTop.constant = vPadding
        imageConstraintBottom.constant = 0

        view.layoutIfNeeded()
    }
    
    @IBAction func onPlusQty(_ sender: Any) {
        let qty = Int(qtyText.text ?? "") ?? 0
        qtyText.text = "\(qty+1)"
    }

    @IBAction func onMinusQty(_ sender: Any) {
        var qty = (Int(qtyText.text ?? "") ?? 0)-1
        if qty <= 0 {
            qty = 0
        }
        qtyText.text = "\(qty)"
    }

    @IBAction func onBack(_ sender: Any) {
        inputedQty = Int(qtyText.text ?? "") ?? 0
        self.dismiss(animated: true) {
            self.dismissHandler?(self, .done)
        }
    }

}

extension ProductDetailVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == qtyText {
            textField.resignFirstResponder()
            return false
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == qtyText {
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

extension ProductDetailVC: UIScrollViewDelegate {

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraints()
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        /*
         if checkMedia!.mediaType == .Video {
         return nil
         }
         else {
         return self.pictureImageView
         }*/
        return self.productImageView
    }
}
