//
//  OrderSalesOrderCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/11/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class MarginCalculatorOrderCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var productImageVIew: UIImageView!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var priceLabel: UITextView!
    @IBOutlet weak var qtyText: AnimatableTextField!
    @IBOutlet var marginLabel: UILabel!
    
    @IBOutlet weak var plusQtyButton: UIButton!
    @IBOutlet weak var minusQtyButton: UIButton!

    var cost = 0.0
    var margin = 0.0
    var price = 0.0
    var parentVC: MarginCalculatorVC!
    var indexPath: IndexPath!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MarginCalculatorOrderCell.onLongPressMainView(_:)))
        mainView.addGestureRecognizer(longPressGestureRecognizer)

        qtyText.delegate = self
        qtyText.addTarget(self, action: #selector(MarginCalculatorOrderCell.onQtyEditingChanged(_:)), for: .editingChanged)
        
        priceLabel.delegate = self
        
        if GlobalInfo.shared.routeControl?.adjustAllow == "1" {
            priceLabel.isEditable = true
        }
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

    func setupCell(parentVC: MarginCalculatorVC, indexPath: IndexPath) {
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
        
        //marginCalculator part
        let prodLocn = ProductLocn.getBy(context: parentVC.globalInfo.managedObjectContext, itemNo: itemNo).first
        cost = ((Double(prodLocn?.costPrice ?? "0") ?? 0)) / 100000
        price = Double(orderDetail.price)
        margin = doCalculate(costVal: cost, priceVal: price)
        updateMarginUI(margin: margin)
        codeLabel.text = itemNo
        descLabel.text = orderDetail.desc ?? ""
        if orderDetail.lastOrder == "01/01/2000" {
            orderDetail.lastOrder = ""
        }

        if parentVC.selectedOrderType != .samples {
            priceLabel.text = Utils.getDecimalString(moneyValue: orderDetail.price)
        }
        else {
            priceLabel.text = Utils.getDecimalString(moneyValue: 0)
        }

        let qty = orderDetail.enterQty.int
        qtyText.text = "\(qty)"

        plusQtyButton.isHidden = false
        minusQtyButton.isHidden = false
        productImageVIew.image = Utils.getProductImage(itemNo: itemNo)
    }
    
    func doCalculate(costVal: Double, priceVal: Double) -> Double {
        if priceVal == 0 && costVal == 0 {
            let marginVal = 0.0
            return marginVal
        }
        else if priceVal == 0 {
            let marginVal = kInitVal
            return marginVal
        }
        else {
            let marginVal = (1 - costVal / priceVal) * 100
            return marginVal
        }
    }
    
    func updateMarginUI(margin: Double) {
        if margin == -1.0 {
            marginLabel.text = L10n.invalid()
        }
        else {
            marginLabel.text = Utils.getMarginString(moneyValue: margin)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let newPrice = Double(textView.text ?? "") ?? 0
        margin = doCalculate(costVal: cost, priceVal: newPrice)
        updateMarginUI(margin: margin)
        let index = indexPath.row
        let orderDetail = parentVC.orderDetailArray[index]
        orderDetail.price = newPrice
        GlobalInfo.saveCache()
        parentVC.refreshOrders()
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
        parentVC.refreshOrders()
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

extension MarginCalculatorOrderCell: UITextFieldDelegate, UITextViewDelegate {

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

