//
//  OrderHistoryTitleCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 2/25/19.
//  Copyright © 2019 iOS Developer. All rights reserved.
//

import UIKit

class OrderHistoryTitleCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var itemCodeLabel: UILabel!
    
    var parentVC: OrderHistoryBaseVC!
    var indexPath: IndexPath!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(OrderHistoryTitleCell.onLongPressMainView(_:)))
        mainView.addGestureRecognizer(longPressGestureRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {

    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {

        if animated == true {
            UIView.animate(withDuration: 1.0, animations: {
                if highlighted == true {
                    self.mainView.backgroundColor = kMessageCellSelectedColor
                }
                else {
                    self.mainView.backgroundColor = kMessageCellNormalColor
                }
            })
        }
        else {
            if highlighted == true {
                self.mainView.backgroundColor = kMessageCellSelectedColor
            }
            else {
                self.mainView.backgroundColor = kMessageCellNormalColor
            }
        }
    }

    @objc func onLongPressMainView(_ sender: Any) {
        let longPressGestureRecognizer = sender as! UILongPressGestureRecognizer
        if longPressGestureRecognizer.state != .began {
            return
        }
        let index = indexPath.row
        var productDetail: ProductDetail?
        if parentVC.isDeliver == true {
            let saItem = parentVC.saItemArray[index]
            productDetail = parentVC.productDetailDictionary[saItem]
        }
        else {
            let bbItem = parentVC.bbItemArray[index]
            productDetail = parentVC.productDetailDictionary[bbItem]
        }
        if productDetail == nil {
            return
        }
        Utils.showProductDetailVC(vc: parentVC, productDetail: productDetail!, customerDetail: parentVC.customerDetail, isForInputQty: false, inputQty: 0, dismissHandler: nil)
    }

}
