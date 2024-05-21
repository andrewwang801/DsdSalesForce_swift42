//
//  OrderSalesOrderCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/11/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class OrderSalesOrderCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var productImageVIew: UIImageView!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var lastOrderLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var qtyText: AnimatableTextField!

    @IBOutlet weak var plusQtyButton: UIButton!
    @IBOutlet weak var minusQtyButton: UIButton!

    var parentVC: OrderSalesVC!
    var indexPath: IndexPath!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(OrderSalesOrderCell.onLongPressMainView(_:)))
        mainView.addGestureRecognizer(longPressGestureRecognizer)

        qtyText.delegate = self
        qtyText.addTarget(self, action: #selector(OrderSalesOrderCell.onQtyEditingChanged(_:)), for: .editingChanged)
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

    func setupCell(parentVC: OrderSalesVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        configCell()
    }

    func configCell() {
        selectionStyle = .none
        let index = indexPath.row
        //let selectedOrderIndex = parentVC.selectedOrderType.rawValue
        //let _orderDetail = parentVC.orderVC.orderDetailSetArray[selectedOrderIndex][index]
        //let orderDetail = _orderDetail as! OrderDetail
        let orderDetail = parentVC.orderDetailArray[index]
        let itemNo = orderDetail.itemNo ?? ""
        codeLabel.text = itemNo
        descLabel.text = orderDetail.desc ?? ""
        if orderDetail.lastOrder == "01/01/2000" {
            orderDetail.lastOrder = ""
        }
        lastOrderLabel.text = orderDetail.lastOrder

        if parentVC.selectedOrderType != .samples {
            priceLabel.text = Utils.getMoneyString(moneyValue: orderDetail.price)
        }
        else {
            priceLabel.text = Utils.getMoneyString(moneyValue: 0)
        }

        let qty = orderDetail.enterQty.int
        qtyText.text = "\(qty)"
        /*
        if parentVC.isShowCase == true {
            let salEntryMode = parentVC.orderVC.customerDetail.salEntryMode ?? ""
            if salEntryMode == "B" {
                let nCase = Utils.getCaseValue(itemNo: itemNo)
                qtyLabel.text = "\(qty / nCase)/\(qty % nCase)"
            }
            else if salEntryMode == "" || salEntryMode == "U" {
                qtyLabel.text = "\(qty)"
            }
        }
        else {
            qtyLabel.text = "\(qty)"
        }*/

        if parentVC.orderVC.isEdit == false {
            plusQtyButton.isHidden = true
            minusQtyButton.isHidden = true
        }
        else {
            plusQtyButton.isHidden = false
            minusQtyButton.isHidden = false
        }
        productImageVIew.image = Utils.getProductImage(itemNo: itemNo)
    }

    @objc func onQtyEditingChanged(_ sender: Any) {
        let newQty = Int(qtyText.text ?? "") ?? 0
        let index = indexPath.row
        //let selectedOrderIndex = parentVC.selectedOrderType.rawValue
        //let _orderDetail = parentVC.orderVC.orderDetailSetArray[selectedOrderIndex][index]
        //let orderDetail = _orderDetail as! OrderDetail
        let orderDetail = parentVC.orderDetailArray[index]
        orderDetail.enterQty = newQty.int32
        GlobalInfo.saveCache()
    }

    @IBAction func onPlusQty(_ sender: Any) {
        let index = indexPath.row
        //let selectedOrderIndex = parentVC.selectedOrderType.rawValue
        //let _orderDetail = parentVC.orderVC.orderDetailSetArray[selectedOrderIndex][index]
        //let orderDetail = _orderDetail as! OrderDetail
        let orderDetail = parentVC.orderDetailArray[index]
        orderDetail.enterQty += 1
        GlobalInfo.saveCache()
        parentVC.refreshOrders()
    }

    @IBAction func onMinusQty(_ sender: Any) {
        let index = indexPath.row
        //let selectedOrderIndex = parentVC.selectedOrderType.rawValue
        //let _orderDetail = parentVC.orderVC.orderDetailSetArray[selectedOrderIndex][index]
        //let orderDetail = _orderDetail as! OrderDetail
        let orderDetail = parentVC.orderDetailArray[index]
        let enterQty = orderDetail.enterQty
        orderDetail.enterQty = max(enterQty-1, 0)
        GlobalInfo.saveCache()
        parentVC.refreshOrders()
    }

    @objc func onLongPressMainView(_ sender: Any) {
        let longPressGestureRecognizer = sender as! UILongPressGestureRecognizer
        if longPressGestureRecognizer.state != .began {
            return
        }
        let index = indexPath.row
        let orderDetail = parentVC.orderDetailArray[index]
        //let _orderDetail = parentVC.orderVC.orderDetailSetArray[parentVC.selectedOrderType.rawValue][index]
        //let orderDetail = _orderDetail as! OrderDetail
        let itemNo = orderDetail.itemNo ?? ""

        let info: [String: Any] = ["itemNo": itemNo, "type": kSelectProductItemNo, "itemUPC": "", "showDetail": true]
        NotificationCenter.default.post(name: Notification.Name(rawValue: kOrderProductSelectedNotificationName), object: nil, userInfo: info)
    }
}

extension OrderSalesOrderCell: UITextFieldDelegate {

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
