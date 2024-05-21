//
//  OrderReviewOrderCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 8/31/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class OrderReviewOrderCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var itemDescLabel: UILabel!
    @IBOutlet weak var itemNoLabel: UILabel!
    @IBOutlet weak var qtyLabel: UILabel!
    @IBOutlet weak var grossPercentLabel: UILabel!
    @IBOutlet weak var priceText: AnimatableTextField!

    var parentVC: OrderReviewVC!
    var indexPath: IndexPath!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        priceText.delegate = self
        priceText.addTarget(self, action: #selector(OrderReviewOrderCell.onPriceEditingChanged(_:)), for: .editingChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell(parentVC: OrderReviewVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        configCell()
    }

    func configCell() {

        selectionStyle = .none
        let typeIndex = parentVC.selectedType.rawValue
        let index = indexPath.row
        let orderDetail = parentVC.orderDetailArray[typeIndex][index]
        itemDescLabel.text = orderDetail.desc
        itemNoLabel.text = orderDetail.itemNo
        qtyLabel.text = "\(orderDetail.enterQty)"
        
        // show gross margin
        // gross margin
        if parentVC.shouldShowMargin == false {
            grossPercentLabel.text = ""
        }
        else {
            let itemCost = parentVC.costPriceArray[typeIndex][index]
            if itemCost == 0 {
                grossPercentLabel.text = "-"
            }
            else {
                let casePrice = orderDetail.price
                var grossMargin: Double = 0
                if casePrice == 0 {
                    grossPercentLabel.text = "-"
                }
                else {
                    grossMargin = (casePrice-itemCost)/casePrice*100
                    grossPercentLabel.text = "\(grossMargin.oneDecimalString)%"
                }
            }
        }

        if parentVC.selectedType != .free {
            priceText.text = orderDetail.price.exactTwoDecimalString
            priceText.isEnabled = parentVC.adjustAllow
        }
        else {
            priceText.text = 0.exactTwoDecimalString
            priceText.isEnabled = false
        }
        productImageView.image = Utils.getProductImage(itemNo: orderDetail.itemNo)
    }

    @objc func onPriceEditingChanged(_ sender: Any) {
        var inputText = priceText.text ?? ""
        inputText = inputText.replacingOccurrences(of: ".", with: "")
        let inputPrice = (Double(inputText) ?? 0)/100
        let inputPriceString = inputPrice.exactTwoDecimalString
        priceText.text = inputPriceString
    }

}

extension OrderReviewOrderCell: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == priceText {
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

    func textFieldDidBeginEditing(_ textField: UITextField) {

        NSLog("TextField Did Begin Editing")
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == priceText {
            let globalInfo = GlobalInfo.shared
            var inputText = priceText.text ?? ""
            inputText = inputText.replacingOccurrences(of: ".", with: "")
            let inputPrice = (Double(inputText) ?? 0)/100
            let inputPriceString = inputPrice.exactTwoDecimalString

            // we need to check if this new value is available
            let typeIndex = parentVC.selectedType.rawValue
            let index = indexPath.row
            let orderDetail = parentVC.orderDetailArray[typeIndex][index]
            let originalPrice = orderDetail.price
            let originalPriceString = originalPrice.exactTwoDecimalString
            let itemNo = orderDetail.itemNo ?? ""
            guard let productDetail = ProductDetail.getBy(context: globalInfo.managedObjectContext, itemNo: itemNo) else {
                priceText.text = originalPriceString
                return
            }

            let minimumSalePrice = productDetail.productLocn?.minimumSalePrice ?? ""
            let minimumSalePriceValue = Utils.getXMLDivided(valueString: minimumSalePrice)
            if minimumSalePriceValue == 0 {
                priceText.text = inputPriceString
                orderDetail.price = inputPrice
                GlobalInfo.saveCache()
                parentVC.refreshOrderDetails()
            }
            else {
                if inputPrice < minimumSalePriceValue {
                    SVProgressHUD.showInfo(withStatus: "The price entered is less than the minimum sales price")
                    priceText.text = originalPriceString
                    return
                }
                else {
                    priceText.text = inputPriceString
                    orderDetail.price = inputPrice
                    GlobalInfo.saveCache()
                    parentVC.refreshOrderDetails()
                }
            }
        }
    }
}
