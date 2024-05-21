//
//  SelectCustomerProductCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/6/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class SelectCustomerProductCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var lastOrdersLabel: UILabel!
    @IBOutlet weak var mtdLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    var parentVC: SelectCustomerTopProductsVC!
    var indexPath: IndexPath!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(SelectCustomerProductCell.onLongPressMainView(_:)))
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

    func setupCell(parentVC: SelectCustomerTopProductsVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        configCell()
    }

    func configCell() {
        selectionStyle = .none
        let index = indexPath.row
        let topProduct = parentVC.topProductArray[index]
        let orderHistory = topProduct.orderHistory!
        let productDetail = topProduct.productDetail!
        let itemNo = productDetail.itemNo ?? "0"
        lastOrdersLabel.text = orderHistory.getLastOrderString()
        mtdLabel.text = orderHistory.getMonthAmount().integerString
        let dateString = orderHistory.getDate()
        let date = Date.fromDateString(dateString: dateString, format: kTightJustDateFormat) ?? Date()
        dateLabel.text = date.toDateString(format: "dd-MM-yyyy") ?? ""
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
        let productDetail = parentVC.topProductArray[index].productDetail
        if productDetail == nil {
            return
        }
        Utils.showProductDetailVC(vc: self.parentVC, productDetail: productDetail!, customerDetail: parentVC.selectCustomerVC.selectedCustomer!, isForInputQty: false, inputQty: 0, dismissHandler: nil)
    }

}
