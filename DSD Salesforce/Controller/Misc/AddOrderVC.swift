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
    @IBOutlet weak var addButton: AnimatableButton!
    @IBOutlet weak var productCodeLabel: UILabel!
    
    @IBOutlet weak var stockCountValLabel: UILabel!
    @IBOutlet weak var orderQtyValLabel: UILabel!
    @IBOutlet weak var offTakeValLabel: UILabel!
    @IBOutlet weak var offTakeTitleLabel: UILabel!
    
    var parentVC: OrderSalesVC!
    var productDetail: ProductDetail!
    var customerDetail: CustomerDetail!
    var orderDetail: OrderDetail!
    var orderDetailForAdd: OrderDetail?
    
    let globalInfo = GlobalInfo.shared
    var shelfStatus: ShelfStatus?
    var productDescStr = ""
    var aisle = ""
    var shelfCount = 0
    var orderQty = 0
    var price = 0.0
    var totalValue = 0.0
    var isAdd = true
    var caseFactor = 1
    var lastOrderQty = 0
    var consumerOffTake = 0
    var stockCount = 0
    var itemNo = ""
    
    enum DismissOption {
        case back, done
    }
    var dismissHandler: ((AddOrderVC, DismissOption) -> ())?
    
    ///MARK-  View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initUI()
        updateUI()
    }
    
    func initUI() {
        orderQtyTextField.addTarget(self, action: #selector(onQtyEditingChanged), for: .editingDidEnd)
        if !isAdd {
            addButton.setTitleForAllState(title: "Done")
        }
        
        guard let _ = shelfStatus else {
            stockCountValLabel.isHidden = true
            orderQtyValLabel.isHidden = true
            offTakeValLabel.isHidden = true
            offTakeTitleLabel.isHidden = true
            return
        }
    }
    
    @objc func onQtyEditingChanged(_ sender: Any) {
        let newQty = Int(orderQtyTextField.text ?? "") ?? 0

        if newQty % caseFactor == 0 {
            if !isAdd {
                orderDetail.enterQty = newQty.int32
            }
            self.orderQty = newQty
        }
        else {
            orderQtyTextField.text = String(self.orderQty)
            Utils.showAlert(vc: self, title: "", message: "This item must be ordered in multiples of \(caseFactor) as it can only be returned in full cases", failed: false, customerName: "", leftString: "", middleString: "", rightString: L10n.return(), dismissHandler: nil)
        }

        GlobalInfo.saveCache()
        parentVC.refreshOrders()
    }
    
    func initData() {
        orderQty = 0
        let custNo = customerDetail.custNo ?? ""
        let chainNo = customerDetail.chainNo ?? ""
        if isAdd {
            itemNo = productDetail.itemNo ?? ""
            if let orderDetail = orderDetailForAdd {
                orderQty = orderDetail.enterQty.int
            }
            else {
                orderQty = 0
            }
            totalValue = Double(orderQty) * price
        }
        else {
            orderQty = orderDetail.enterQty.int
            itemNo = orderDetail.itemNo ?? ""
        }
        shelfStatus = ShelfStatus.getBy(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo, itemNo: itemNo).first
        
        if let shelfStatus = shelfStatus {
            aisle = shelfStatus.aisle ?? ""
            stockCount = (shelfStatus.stockCount ?? "0").intValue
        }

        if isAdd {
            productDetail.calculatePrice(context: globalInfo.managedObjectContext, customerDetail: customerDetail)
            price = productDetail.price
            productDescStr = productDetail.desc ?? ""
            totalValue = Double(orderQty) * price
        }
        else {
            price = orderDetail.price
            productDescStr = orderDetail.desc
            orderQty = orderDetail.enterQty.int
            totalValue = Double(orderQty) * price
        }
        
        if parentVC.selectedOrderType == .returns {
            if customerDetail!.rtnEntryMode == "C" {
                if let prodLocn = ProductLocn.getBy(context: globalInfo.managedObjectContext, itemNo: itemNo).first {
                    caseFactor = Int(prodLocn.caseFactor ?? "1") ?? 1
                }
            }
        }
        else {
            if customerDetail!.salEntryMode == "C" {
                if let prodLocn = ProductLocn.getBy(context: globalInfo.managedObjectContext, itemNo: itemNo).first {
                    caseFactor = Int(prodLocn.caseFactor ?? "1") ?? 1
                }
            }
        }
        
//        let orderDetails = OrderDetail.getBy(context: globalInfo.managedObjectContext, custNo: custNo, itemNo: itemNo)
//        if orderDetails.count > 0 {
//            let sortedOrderDetails = orderDetails.sorted(by: { $0.lastOrder > $1.lastOrder })
//            lastOrderQty = sortedOrderDetails[0].enterQty.int
//        }
        
        if let lastOrderHistory = OrderHistory.getLastItem(context: globalInfo.managedObjectContext, custNo: custNo, itemNo: itemNo) {
            //lastOrderQty = lastOrderHistory.nSAQty
            lastOrderQty = lastOrderHistory.nSAQty / Int(kOrderHistoryDivider)
        }
    }
    
    func updateData() {
        aisle = aisleTextField.text ?? ""
        shelfCount = Int(shelfCountTextField.text ?? "0") ?? 0
        orderQty = Int(orderQtyTextField.text ?? "0") ?? 0
        totalValue = Double(orderQty) * price
    }
    
    func updateUI() {
        productDesc.text = productDescStr
        productIamge.image = Utils.getProductImage(itemNo: itemNo)
        aisleTextField.text = aisle
        shelfCountTextField.text = String(shelfCount)
        if !isAdd {
            orderDetail.stockCount = "\(shelfCount)"
            orderDetail.aisle = aisle
        }
        orderQtyTextField.text = String(orderQty)
        priceDescLabel.text = price.moneyString
        totalValueDescLabel.text = totalValue.moneyString
        if isAdd {
            productCodeLabel.text = productDetail.itemNo ?? ""
        }
        else {
            productCodeLabel.text = orderDetail.itemNo ?? ""
        }
        stockCountValLabel.text = String(stockCount)
        orderQtyValLabel.text = String(lastOrderQty)
        offTakeValLabel.text = String(stockCount + lastOrderQty - shelfCount)
        
        totalValueDescLabel.text = totalValue.moneyString
        orderQtyTextField.text = "\(orderQty)"
    }
    
    func updateShelfStatus() {
        if let shelfStatus = shelfStatus {
            shelfStatus.aisle = aisle
            shelfStatus.stockCount = String(shelfCount)

            let now = Date()
            let nowString = now.toDateString(format: kTightFullDateFormat) ?? ""
                let shelfStatusTransaction = UTransaction.make(chainNo: customerDetail.chainNo ?? "", custNo: customerDetail.custNo ?? "", docType: "SURV", date: now, reference: "", trip: globalInfo.routeControl!.trip ?? "")
            let shelfAudit = ShelfAudit.make(chainNo: customerDetail.chainNo ?? "", custNo: customerDetail.custNo ?? "", docType: "SHF", date: now, reference: "", shelfStatusArray: [shelfStatus])

            let shelfAuditPath = CommData.getFilePathAppended(byDocumentDir: "ShelfAudits\(nowString).upl") ?? ""
            ShelfAudit.saveToXML(auditArray: [shelfAudit], filePath: shelfAuditPath)

            let transactionPath = UTransaction.saveToXML(transactionArray: [shelfStatusTransaction], shouldIncludeLog: true)

            globalInfo.uploadManager.zipAndScheduleUpload(filePathArray: [shelfAuditPath], completionHandler: nil)
        }
        else {
            let shelfStatus = ShelfStatus(context: globalInfo.managedObjectContext, forSave: true)
            shelfStatus.chainNo = customerDetail.chainNo ?? ""
            shelfStatus.custNo = customerDetail.custNo ?? ""
            shelfStatus.itemNo = itemNo
            shelfStatus.isSaved = false

            shelfStatus.aisle = aisle
            shelfStatus.stockCount = String(shelfCount)

            let now = Date()
            let nowString = now.toDateString(format: kTightFullDateFormat) ?? ""
                let shelfStatusTransaction = UTransaction.make(chainNo: customerDetail.chainNo ?? "", custNo: customerDetail.custNo ?? "", docType: "SURV", date: now, reference: "", trip: globalInfo.routeControl!.trip ?? "")
            let shelfAudit = ShelfAudit.make(chainNo: customerDetail.chainNo ?? "", custNo: customerDetail.custNo ?? "", docType: "SHF", date: now, reference: "", shelfStatusArray: [shelfStatus])

            let shelfAuditPath = CommData.getFilePathAppended(byDocumentDir: "ShelfAudits\(nowString).upl") ?? ""
            ShelfAudit.saveToXML(auditArray: [shelfAudit], filePath: shelfAuditPath)

            let transactionPath = UTransaction.saveToXML(transactionArray: [shelfStatusTransaction], shouldIncludeLog: true)

            globalInfo.uploadManager.zipAndScheduleUpload(filePathArray: [shelfAuditPath], completionHandler: nil)
        }
        parentVC.sortAndFilterOrders()
        GlobalInfo.saveCache()
    }
    
    ///MARK- IBActions
    @IBAction func onShelfCountMinus(_ sender: Any) {
        shelfCount = Int(shelfCountTextField.text ?? "") ?? 0
        shelfCount -= 1
        if shelfCount <= 0 {
            shelfCount = 0
        }
        shelfCountTextField.text = "\(shelfCount)"
        updateData()
        updateUI()
    }
    
    @IBAction func onShelfCountPlus(_ sender: Any) {
        shelfCount = Int(shelfCountTextField.text ?? "") ?? 0
        shelfCount += 1
        shelfCountTextField.text = "\(shelfCount)"
        updateData()
        updateUI()
    }
    
    @IBAction func onOrderQtyMinus(_ sender: Any) {
        orderQty = Int(orderQtyTextField.text ?? "") ?? 0
        var enterQty:Int32 = 0
        if !isAdd {
            enterQty = orderDetail.enterQty
        }
        
        orderQty -= caseFactor
        if orderQty <= 0 {
            orderQty = 0
        }
        if !isAdd {
            orderDetail.enterQty = max(enterQty-caseFactor.int32, 0)
        }
        orderQtyTextField.text = "\(orderQty)"
        updateData()
        updateUI()
        GlobalInfo.saveCache()
        parentVC.refreshOrders()
    }
    
    @IBAction func onOrderQtyPlus(_ sender: Any) {
        orderQty = Int(orderQtyTextField.text ?? "") ?? 0
//        orderQty += 1
   
        orderQty += caseFactor
        if !isAdd {
            orderDetail.enterQty += caseFactor.int32
        }
        orderQtyTextField.text = "\(orderQty)"
        updateData()
        updateUI()
    }
    
    @IBAction func onAdd(_ sender: Any) {
       
        let newQty = Int(orderQtyTextField.text ?? "") ?? 0
         
         if newQty % caseFactor == 0 {
             if !isAdd {
                 orderDetail.enterQty = newQty.int32
             }
             self.orderQty = newQty
         }
         else {
             orderQtyTextField.text = String(self.orderQty)
             Utils.showAlert(vc: self, title: "", message: "This item must be ordered in multiples of \(caseFactor) as it can only be returned in full cases", failed: false, customerName: "", leftString: "", middleString: "", rightString: L10n.return(), dismissHandler: nil)
            return
         }
    
        updateData()
        updateShelfStatus()
        
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
