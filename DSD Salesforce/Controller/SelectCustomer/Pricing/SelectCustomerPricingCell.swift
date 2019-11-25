//
//  SelectCustomerPricingCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/10/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class SelectCustomerPricingCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var pricingLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!

    var parentVC: SelectCustomerPricingVC!
    var indexPath: IndexPath!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(SelectCustomerPricingCell.onLongPressMainView(_:)))
        mainView.addGestureRecognizer(longPressGestureRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {

    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {

        if animated == true {
            UIView.animate(withDuration: 1.0, animations: {
                if highlighted == true {
                    self.mainView.backgroundColor = kProductCellNormalColor
                }
                else {
                    self.mainView.backgroundColor = kProductCellSelectedColor
                }
            })
        }
        else {
            if highlighted == true {
                self.mainView.backgroundColor = kProductCellNormalColor
            }
            else {
                self.mainView.backgroundColor = kProductCellSelectedColor
            }
        }
    }

    func setupCell(parentVC: SelectCustomerPricingVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        configCell()
    }

    func configCell() {
        selectionStyle = .none
        let index = indexPath.row
        var price: Double = 0

        let pricingItem = parentVC.filteredPricingItemArray[index]
        if pricingItem.pricing != nil {
            let pricing = pricingItem.pricing!
            let priceString = pricing.price ?? "0"
            price = (Double(priceString) ?? 0)/100000
        }
        else {
            let basePrice = pricingItem.productDetail!.productLocn?.basePrice ?? "0"
            price = (Double(basePrice) ?? 0)/100000
        }

        let productDetail = pricingItem.productDetail!
        let itemNo = productDetail.itemNo ?? ""
        pricingLabel.text = Utils.getMoneyString(moneyValue: price)
        if pricingItem.pricing != nil {
            pricingLabel.textColor = kRedTextColor
        }
        else {
            pricingLabel.textColor = kBlackTextColor
        }
        nameLabel.text = productDetail.desc ?? ""
        descLabel.text = itemNo
        productImageView.image = productDetail.getProductImage()
    }

    @objc func onLongPressMainView(_ sender: Any) {
        let longPressGestureRecognizer = sender as! UILongPressGestureRecognizer
        if longPressGestureRecognizer.state != .began {
            return
        }
        let index = indexPath.row
        let productDetail = parentVC.filteredPricingItemArray[index].productDetail
        if productDetail == nil {
            return
        }
        Utils.showProductDetailVC(vc: self.parentVC, productDetail: productDetail!, customerDetail: parentVC.selectCustomerVC.selectedCustomer!, isForInputQty: false, inputQty: 0, dismissHandler: nil)
    }

}
