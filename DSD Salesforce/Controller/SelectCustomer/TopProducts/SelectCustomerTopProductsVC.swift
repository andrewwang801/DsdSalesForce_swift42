//
//  SelectCustomerTopProductsVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/5/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class SelectCustomerTopProductsVC: UIViewController {

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var numberLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var productTableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!

    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var lastOrdersLabel: UILabel!
    @IBOutlet weak var mtdLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    let globalInfo = GlobalInfo.shared
    var selectCustomerVC: SelectCustomerVC!
    var topProductArray = [CustomerTopProduct]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(SelectCustomerTopProductsVC.updateUI), name: NSNotification.Name(rawValue: kCustomerSelectedNotificationName), object: nil)

        initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isBeingDismissed == true || isMovingFromParent == true {
            NotificationCenter.default.removeObserver(self)
        }
    }

    func initUI() {
        itemLabel.text = L10n.item()
        lastOrdersLabel.text = L10n.lastOrders()
        mtdLabel.text = L10n.mtd()
        dateLabel.text = L10n.date()
        noDataLabel.text = L10n.thereIsNoData()
        
        productTableView.dataSource = self
        productTableView.delegate = self
    }

    @objc func updateUI() {
        guard let selectedCustomer = selectCustomerVC.selectedCustomer else {return}

        let tagNo = selectedCustomer.getCustomerTag()
        numberLabel.text = tagNo
        let estimatedWidth = tagNo.width(withConstraintedHeight: numberLabel.bounds.width, attributes: [NSAttributedString.Key.font: numberLabel.font])
        numberLabelWidthConstraint.constant = estimatedWidth+20

        let custTitle = selectedCustomer.getCustomerTitle()
        titleLabel.text = custTitle

        loadTopProducts()
        refreshProducts()
    }

    func loadTopProducts() {
        guard let selectedCustomer = selectCustomerVC.selectedCustomer else {return}

        let chainNo = selectedCustomer.chainNo ?? "0"
        let custNo = selectedCustomer.custNo ?? "0"

        var orderHistoryArray = OrderHistory.getBy(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo)
        orderHistoryArray = orderHistoryArray.sorted(by: { (history1, history2) -> Bool in
            let total1 = history1.getTotal()
            let total2 = history2.getTotal()
            return total1 > total2
        })

        let totalCount = orderHistoryArray.count
        let removeCount = max(totalCount-5,0)

        orderHistoryArray.removeLast(removeCount)

        topProductArray = []
        for orderHistory in orderHistoryArray {
            let itemNo = orderHistory.itemNo ?? "0"
            guard let productDetail = ProductDetail.getBy(context: globalInfo.managedObjectContext, itemNo: itemNo) else {continue}
            let topProduct = CustomerTopProduct()
            topProduct.orderHistory = orderHistory
            topProduct.productDetail = productDetail
            topProductArray.append(topProduct)
        }
    }

    func refreshProducts() {
        productTableView.reloadData()
        if topProductArray.count == 0 {
            noDataLabel.isHidden = false
        }
        else {
            noDataLabel.isHidden = true
        }
    }

}

extension SelectCustomerTopProductsVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topProductArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectCustomerProductCell", for: indexPath) as! SelectCustomerProductCell
        cell.setupCell(parentVC: self, indexPath: indexPath)
        return cell
    }

}

extension SelectCustomerTopProductsVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }

}
