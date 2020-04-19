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
    ///SF79
    @IBOutlet weak var aisleLabel: UILabel!
    @IBOutlet weak var shelfLabel: UILabel!
    @IBOutlet weak var orderHistoryLabel: UILabel!
    @IBOutlet weak var aisleStackView: UIStackView!
    @IBOutlet weak var descStackView: UIStackView!
    
    @IBOutlet weak var plusQtyButton: UIButton!
    @IBOutlet weak var minusQtyButton: UIButton!

    var parentVC: OrderSalesVC!
    var indexPath: IndexPath!
    var orderDetail: OrderDetail!
    var caseFactor: Int32 = 1
    var customerDetail: CustomerDetail!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(OrderSalesOrderCell.onLongPressMainView(_:)))
        mainView.addGestureRecognizer(longPressGestureRecognizer)

        qtyText.delegate = self
        qtyText.addTarget(self, action: #selector(OrderSalesOrderCell.onQtyEditingChanged(_:)), for: .editingDidEnd)
        
        let descTapGesture = UITapGestureRecognizer(target: self, action: #selector(onDesc))
        descStackView.isUserInteractionEnabled = true
        descStackView.addGestureRecognizer(descTapGesture)
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

    func initData() {
        let index = indexPath.row
        orderDetail = parentVC.orderDetailArray[index]
        customerDetail = parentVC!.orderVC.customerDetail!
        if let prodLocn = ProductLocn.getBy(context: parentVC!.globalInfo.managedObjectContext, itemNo: orderDetail.itemNo).first {
            caseFactor = Int32(prodLocn.caseFactor ?? "1") ?? 1
        }
    }
    func setupCell(parentVC: OrderSalesVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        initData()
        configCell()
    }

    func configCell() {
        selectionStyle = .none
        let index = indexPath.row
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

        if parentVC.orderVC.isEdit == false {
            plusQtyButton.isHidden = true
            minusQtyButton.isHidden = true
            qtyText.borderWidth = 0
            qtyText.isEnabled = false
            qtyText.isUserInteractionEnabled = false
        }
        else {
            plusQtyButton.isHidden = false
            minusQtyButton.isHidden = false
            qtyText.borderWidth = 1
            qtyText.isEnabled = true
            qtyText.isUserInteractionEnabled = true
        }
        productImageVIew.image = Utils.getProductImage(itemNo: itemNo)
        
        ///SF79
        if parentVC.globalInfo.routeControl?.detailEntry == "1" && parentVC.selectedOrderType == .sales {
            aisleStackView.isHidden = false
            orderHistoryLabel.isHidden = false
            aisleLabel.text = "Aisle:  " + orderDetail.aisle
            shelfLabel.text = "On Shelf:  " + orderDetail.stockCount
            orderHistoryLabel.text = orderDetail.orderHistory
        }
        else {
            aisleStackView.isHidden = true
            orderHistoryLabel.isHidden = true
        }
    }

    @objc func onDesc() {
        if self.parentVC.orderVC.isEdit {
            DispatchQueue.main.async {
                Utils.showAddOrderVC(vc: self.parentVC, orderDetail: self.orderDetail, customerDetail: self.customerDetail, isAdd: false, dismissHandler: { addOrderVC, dismissOption in
                    // we should replace the qty by the input
                    if dismissOption == AddOrderVC.DismissOption.done {
                        let inputedQty = addOrderVC.orderQty
                        self.parentVC.selectedQty = inputedQty
                        self.parentVC.refreshOrders()
                        // we should do Add
                        //self.addProduct(shouldRemoveZeroAmount: false)
                    }
                })
            }
        }
    }
    
    @objc func onQtyEditingChanged(_ sender: Any) {
        let newQty = Int(qtyText.text ?? "") ?? 0
        let index = indexPath.row
        let orderDetail = parentVC.orderDetailArray[index]
        
        switch parentVC!.selectedOrderType.rawValue {
        case 1:
            switch customerDetail.rtnEntryMode {
            case "C":
                if newQty.int32 % caseFactor == 0 {
                    orderDetail.enterQty = newQty.int32
                }
                else {
                    Utils.showAlert(vc: parentVC!, title: "", message: "This item must be ordered in multiples of \(caseFactor) as it can only be returned in full cases", failed: false, customerName: "", leftString: "", middleString: "", rightString: L10n.return(), dismissHandler: nil)
                }
                break
            default:
                orderDetail.enterQty = newQty.int32
                break
            }
            break
            
        case 0, 2:
            switch customerDetail.salEntryMode {
                case "C":
                if newQty.int32 % caseFactor == 0 {
                    orderDetail.enterQty = newQty.int32
                }
                else {
                    Utils.showAlert(vc: parentVC!, title: "", message: "This item must be ordered in multiples of \(caseFactor) as it can only be sold in full cases", failed: false, customerName: "", leftString: "", middleString: "", rightString: L10n.return(), dismissHandler: nil)
                }
                break
            default:
                orderDetail.enterQty = newQty.int32
                break
            }
            break
            
        default:
            break
        }
        GlobalInfo.saveCache()
        parentVC.refreshOrders()
    }

    @IBAction func onPlusQty(_ sender: Any) {
        
        switch parentVC!.selectedOrderType.rawValue {
        case 1:
            switch customerDetail.rtnEntryMode {
            case "B", "U":
                orderDetail.enterQty += 1
                break
            case "C":
                orderDetail.enterQty += caseFactor
                break
            default:
                orderDetail.enterQty += 1
                break
            }
            break
            
        case 0, 2:
            switch customerDetail.salEntryMode {
            case "B", "U":
                orderDetail.enterQty += 1
                break
            case "C":
                orderDetail.enterQty += caseFactor
                break
            default:
                orderDetail.enterQty += 1
                break
            }
            break
            
        default:
            break
        }
        GlobalInfo.saveCache()
        parentVC.refreshOrders()
    }

    @IBAction func onMinusQty(_ sender: Any) {
        
        let enterQty = orderDetail.enterQty
        
        switch parentVC!.selectedOrderType.rawValue {
        case 1:
            switch customerDetail.rtnEntryMode {
            case "B", "U":
                orderDetail.enterQty = max(enterQty-1, 0)
                break
            case "C":
                orderDetail.enterQty = max(enterQty-caseFactor, 0)
                break
            default:
                orderDetail.enterQty = max(enterQty-1, 0)
                break
            }
            break
            
        case 0, 2:
            switch customerDetail.salEntryMode {
            case "B", "U":
                orderDetail.enterQty = max(enterQty-1, 0)
                break
            case "C":
                orderDetail.enterQty = max(enterQty-caseFactor, 0)
                break
            default:
                orderDetail.enterQty = max(enterQty-1, 0)
                break
            }
            break
            
        default:
            break
        }
        
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == qtyText {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
}
