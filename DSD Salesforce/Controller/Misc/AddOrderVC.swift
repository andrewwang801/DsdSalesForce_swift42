//
//  AddOrderVC.swift
//  DSD Salesforce
//
//  Created by Apple Developer on 2020/4/8.
//  Copyright © 2020 iOS Developer. All rights reserved.
//

import UIKit

class AddOrderVC: UIViewController {

    @IBOutlet weak var productDesc: UILabel!
    @IBOutlet weak var productIamge: UIImageView!
    @IBOutlet weak var aisleLabel: UILabel!
    @IBOutlet weak var aisleTextField: AnimatableTextField!
    @IBOutlet weak var shelfCountLabel: UILabel!
    @IBOutlet weak var shelfCountTextField: AnimatableTextField!
    @IBOutlet weak var orderQtyLabel: UILabel!
    @IBOutlet weak var orderQtyTextField: AnimatableTextField!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceDescLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var totalValueDescLabel: UILabel!
    
    var productDetail: ProductDetail!
    var customerDetail: CustomerDetail?
    
    let globalInfo = GlobalInfo.shared
    var shelfStatus: ShelfStatus?
    var aisle = ""
    var shelfCount = 0
    var orderQty = 0
    var price = 0.0
    var totalValue = 0.0
    
    enum DismissOption {
        case back, done
    }
    var dismissHandler: ((AddOrderVC, DismissOption) -> ())?
    
    ///MARK-  View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        updateUI()
    }
    
    func initUI() {
        aisleTextField.addTarget(self, action: #selector(onEditEnd(textField:)), for: .editingDidEnd)
        shelfCountTextField.addTarget(self, action: #selector(onEditEnd(textField:)), for: .editingDidEnd)
        orderQtyTextField.addTarget(self, action: #selector(onEditEnd(textField:)), for: .editingDidEnd)
    }
    
    func initData() {
        if let customerDetail = customerDetail {
            let custNo = customerDetail.custNo ?? ""
            let chainNo = customerDetail.chainNo ?? ""
            shelfStatus = ShelfStatus.getBy(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo).first
            
            if let shelfStatus = shelfStatus {
                aisle = shelfStatus.aisle ?? ""
                shelfCount = (shelfStatus.stockCount ?? "0").intValue
            }
        }

        orderQty = 0
        if let productDetail = productDetail {
            price = productDetail.price
            totalValue = 0.0
        }
    }
    
    func updateData() {
        aisle = aisleTextField.text ?? ""
        shelfCount = Int(shelfCountTextField.text ?? "0") ?? 0
        orderQty = Int(orderQtyTextField.text ?? "0") ?? 0
    }
    
    func updateUI() {
        let itemNo = productDetail?.itemNo ?? ""
        productIamge.image = Utils.getProductImage(itemNo: itemNo)
        aisleTextField.text = aisle
        shelfCountTextField.text = String(shelfCount)
        orderQtyTextField.text = String(orderQty)
        priceDescLabel.text = price.moneyString
        totalValueDescLabel.text = totalValue.moneyString
    }
    
    func updateShelfStatus() {
        if let shelfStatus = shelfStatus {
            shelfStatus.aisle = aisle
            shelfStatus.stockCount = String(shelfCount)
        }
        GlobalInfo.saveCache()
    }
    
    ///MARK-
    @objc func onEditEnd(textField: UITextField) {
        updateData()
    }
    
    ///MARK- IBActions
    @IBAction func onShelfCountMinus(_ sender: Any) {
        shelfCount = Int(shelfCountTextField.text ?? "") ?? 0
        shelfCount -= 1
        if shelfCount <= 0 {
            shelfCount = 0
        }
        shelfCountTextField.text = "\(shelfCount)"
    }
    
    @IBAction func onShelfCountPlus(_ sender: Any) {
        shelfCount = Int(shelfCountTextField.text ?? "") ?? 0
        shelfCount += 1
        shelfCountTextField.text = "\(shelfCount)"
    }
    
    @IBAction func onOrderQtyMinus(_ sender: Any) {
        orderQty = Int(orderQtyTextField.text ?? "") ?? 0
        orderQty -= 1
        if orderQty <= 0 {
            orderQty = 0
        }
        
        totalValue = Double(orderQty) * price
        updateUI()
    }
    
    @IBAction func onOrderQtyPlus(_ sender: Any) {
        orderQty = Int(orderQtyTextField.text ?? "") ?? 0
        orderQty += 1
        
        totalValue = Double(orderQty) * price
        updateUI()
    }
    
    @IBAction func onAdd(_ sender: Any) {
        updateData()
        //updateShelfStatus()
        self.dismiss(animated: true) {
            self.dismissHandler?(self, .done)
        }
    }
    
    @IBAction func onReturn(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?(self, .back)
        }
    }
}

extension AddOrderVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == orderQtyTextField || textField == shelfCountTextField {
            textField.resignFirstResponder()
            return false
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == orderQtyTextField || textField == shelfCountTextField {
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
