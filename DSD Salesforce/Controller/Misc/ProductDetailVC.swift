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
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var groupValueLabel: UILabel!
    @IBOutlet weak var brandValueLabel: UILabel!
    @IBOutlet weak var barcodeValueLabel: UILabel!
    @IBOutlet weak var unitsPerCaseValueLabel: UILabel!
    @IBOutlet weak var casePriceValueLabel: UILabel!
    @IBOutlet weak var lineValueLabel: UILabel!
    @IBOutlet weak var subBrandValueLabel: UILabel!
    @IBOutlet weak var unitRRPValueLabel: UILabel!
    @IBOutlet weak var inventoryValueLabel: UILabel!
    @IBOutlet weak var grossMarginTitleLabel: UILabel!
    @IBOutlet weak var grossMarginValueLabel: UILabel!
    @IBOutlet weak var qtyText: AnimatableTextField!
    @IBOutlet weak var productImageScrollView: UIScrollView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var qtyView: UIView!

    @IBOutlet weak var imageConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintRight: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintBottom: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintLeft: NSLayoutConstraint!

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

    func initUI() {

        // populate the all components
        let itemNo = productDetail.itemNo ?? ""
        itemNoLabel.text = itemNo
        descLabel.text = productDetail.desc ?? ""
        let prodGroup = productDetail.prodGrp ?? ""
        groupValueLabel.text = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "ProductGroup", alphaKey: prodGroup)?.desc ?? ""
        let brand = productDetail.brand ?? ""
        brandValueLabel.text = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "Brand", alphaKey: brand)?.desc ?? ""
        barcodeValueLabel.text = productDetail.itemUPC ?? ""
        let prodLine = productDetail.prodLine ?? ""
        lineValueLabel.text = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "ProductLine", alphaKey: prodLine)?.desc ?? ""
        let subBrand = productDetail.subBrand ?? ""
        subBrandValueLabel.text = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "SubBrand", alphaKey: subBrand)?.desc ?? ""

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
