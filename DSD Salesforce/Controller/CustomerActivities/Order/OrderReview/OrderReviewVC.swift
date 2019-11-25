//
//  OrderReviewVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 8/31/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class OrderReviewVC: UIViewController {

    @IBOutlet weak var typeCV: UICollectionView!
    @IBOutlet weak var orderTableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var adjustButton: AnimatableButton!
    @IBOutlet weak var toggleMarginButton: AnimatableButton!
    
    var orderVC: OrderVC!
    let globalInfo = GlobalInfo.shared
    var customerDetail: CustomerDetail!
    var originalOrderDetailArray = [[OrderDetail]]()
    var orderDetailArray = [[OrderDetail]]()
    var costPriceArray = [[Double]]()
    var adjustAllow: Bool = false

    let kTypeCount = 3
    let kTypeTitleArray = ["SALES", "RETURNS", "FREE"]
    
    var shouldShowMargin = false {
        didSet {
            if shouldShowMargin == true {
                toggleMarginButton.setTitleForAllState(title: "HIDE MARGIN")
            }
            else {
                toggleMarginButton.setTitleForAllState(title: "SHOW MARGIN")
            }
        }
    }

    enum DismissOption {
        case cancelled
        case done
    }

    enum OrderSalesType: Int {
        case sales = 0
        case returns = 1
        case free = 2
    }

    var selectedType: OrderSalesType = .sales
    var dismissHandler: ((OrderReviewVC, DismissOption) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
        initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshTypes()
        refreshOrderDetails()
    }

    func initData() {

        // adjust allow
        let adjustAllowString = globalInfo.routeControl?.adjustAllow ?? ""
        self.adjustAllow = adjustAllowString == "1"

        // order details
        originalOrderDetailArray.removeAll()
        orderDetailArray.removeAll()
        for i in 0..<3 {
            let orderDetailSet = orderVC.orderDetailSetArray[i]
            var orderDetailGroup = [OrderDetail]()
            var originalOrderDetailGroup = [OrderDetail]()
            var costPriceGroup = [Double]()
            for _orderDetail in orderDetailSet {
                let orderDetail = _orderDetail as! OrderDetail
                let enterQty = orderDetail.enterQty
                if enterQty == 0 {
                    continue
                }
                
                let itemNo = orderDetail.itemNo ?? ""
                let productDetail = ProductDetail.getBy(context: globalInfo.managedObjectContext, itemNo: itemNo)
                let costPrice = Utils.getXMLDivided(valueString: productDetail?.productLocn?.costPrice ?? "")
                costPriceGroup.append(costPrice)
                
                originalOrderDetailGroup.append(orderDetail)
                let newOrderDetail = OrderDetail(context: globalInfo.managedObjectContext, forSave: true)
                newOrderDetail.updateBy(context: globalInfo.managedObjectContext, theSource: orderDetail)
                orderDetailGroup.append(newOrderDetail)
            }
            originalOrderDetailArray.append(originalOrderDetailGroup)
            orderDetailArray.append(orderDetailGroup)
            costPriceArray.append(costPriceGroup)
        }
    }

    func initUI() {
        typeCV.dataSource = self
        typeCV.delegate = self
        typeCV.delaysContentTouches = false
        orderTableView.dataSource = self
        orderTableView.delegate = self

        adjustButton.isEnabled = adjustAllow
        
        // decide to show Show Margin button
        toggleMarginButton.isHidden = true
        shouldShowMargin = false
        for costPriceGroup in costPriceArray {
            for costPrice in costPriceGroup {
                if costPrice != 0 {
                    toggleMarginButton.isHidden = false
                    break
                }
            }
        }
    }

    func refreshTypes() {
        typeCV.reloadData()
    }

    func refreshOrderDetails() {
        orderTableView.reloadData()
        if orderDetailArray[selectedType.rawValue].count == 0 {
            noDataLabel.isHidden = false
        }
        else {
            noDataLabel.isHidden = true
        }
    }

    func removeOrderDetails() {
        for i in 0..<3 {
            for orderDetail in orderDetailArray[i] {
                OrderDetail.delete(context: globalInfo.managedObjectContext, orderDetail: orderDetail)
            }
        }
    }

    func scrollTableToTop() {
        let orderDetailGroup = orderDetailArray[selectedType.rawValue]
        if orderDetailGroup.count > 0 {
            orderTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }

    func onTypeTapped(index: Int) {
        let isTypeChanged = selectedType.rawValue != index
        selectedType = OrderSalesType(rawValue: index)!
        refreshTypes()
        refreshOrderDetails()
        if isTypeChanged == true {
            scrollTableToTop()
        }
    }

    func updateOriginalOrderDetails() {
        // update order details price
        for i in 0..<2 {
            let originalOrderDetailGroup = originalOrderDetailArray[i]
            let orderDetailGroup = orderDetailArray[i]
            for (index, orderDetail) in orderDetailGroup.enumerated() {
                let originalOrderDetail = originalOrderDetailGroup[index]
                originalOrderDetail.updateBy(context: globalInfo.managedObjectContext, theSource: orderDetail)
            }
        }
        GlobalInfo.saveCache()
    }
    
    @IBAction func onToggleMargin(_ sender: Any) {
        shouldShowMargin = !shouldShowMargin
        refreshOrderDetails()
    }
    
    @IBAction func onDone(_ sender: Any) {

        updateOriginalOrderDetails()
        removeOrderDetails()
        self.dismiss(animated: true) {
            self.dismissHandler?(self, .done)
        }
    }

    @IBAction func onBack(_ sender: Any) {
        removeOrderDetails()
        self.dismiss(animated: true) {
            self.dismissHandler?(self, .cancelled)
        }
    }
}

extension OrderReviewVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderDetailArray[selectedType.rawValue].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderReviewOrderCell", for: indexPath) as! OrderReviewOrderCell
        cell.setupCell(parentVC: self, indexPath: indexPath)
        return cell
    }

}

extension OrderReviewVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

}

extension OrderReviewVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderReviewTypeCell", for: indexPath) as! OrderReviewTypeCell
        cell.setupCell(parentVC: self, indexPath: indexPath)
        return cell
    }
}

extension OrderReviewVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = collectionView.bounds.width
        let totalHeight = collectionView.bounds.height
        let availableWidth = totalWidth-CGFloat(kTypeCount-1)*1
        let normalWidth = ceil((availableWidth/CGFloat(kTypeCount)))
        let lastWidth = availableWidth-normalWidth*CGFloat(kTypeCount-1)
        if indexPath.row != kTypeCount-1 {
            return CGSize(width: normalWidth, height: totalHeight)
        }
        else {
            return CGSize(width: lastWidth, height: totalHeight)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
