//
//  OpportunitiesProductCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/9/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class OpportunitiesProductCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var rangingPercentLabel: UILabel!

    var parentVC: SelectCustomerOpportunitiesVC!
    var indexPath: IndexPath!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(OpportunitiesProductCell.onLongPressMainView(_:)))
        mainView.addGestureRecognizer(longPressGestureRecognizer)
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

    func setupCell(parentVC: SelectCustomerOpportunitiesVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        configCell()
    }

    func configCell() {
        selectionStyle = .none
        let index = indexPath.row
        let opportunity = parentVC.customerOpportunityArray[index]

        nameLabel.text = opportunity.productDetail?.desc ?? ""
        descLabel.text = opportunity.productDetail?.itemNo ?? ""
        productImageView.image = opportunity.productDetail?.getProductImage()
        let rangingPercent = opportunity.rangingPercent
        rangingPercentLabel.text = rangingPercent.integerString
    }

    @objc func onLongPressMainView(_ sender: Any) {
        let longPressGestureRecognizer = sender as! UILongPressGestureRecognizer
        if longPressGestureRecognizer.state != .began {
            return
        }
        let index = indexPath.row
        let opportunity = parentVC.customerOpportunityArray[index]
        let productDetail = opportunity.productDetail
        if productDetail == nil {
            return
        }
        Utils.showProductDetailVC(vc: parentVC, productDetail: productDetail!, customerDetail: parentVC.selectCustomerVC.selectedCustomer!, isForInputQty: false, inputQty: 0, dismissHandler: nil)
    }

}
