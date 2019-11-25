//
//  ExistingOrdersVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 9/13/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class ExistingOrdersVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var orderTableView: UITableView!

    let globalInfo = GlobalInfo.shared
    var customerDetail: CustomerDetail!
    var orderHeaderArray = [OrderHeader]()
    var selectedOrderHeader: OrderHeader?
    var presoldOrderHeader: PresoldOrHeader?
    var isFirstPresoldOrder = false

    var rowCount: Int {
        get {
            if presoldOrderHeader == nil {
                return orderHeaderArray.count
            }
            else {
                if isFirstPresoldOrder == true {
                    return orderHeaderArray.count
                }
                else {
                    return orderHeaderArray.count+1
                }
            }
        }
    }

    enum DismissOption {
        case back
        case select
        case selectEdition
        case newOrder
        case newOrderByPresold
    }

    var dismissHandler: ((ExistingOrdersVC, DismissOption)->())?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
        initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshOrders()
    }

    func initData() {
        let chainNo = customerDetail.chainNo ?? ""
        let custNo = customerDetail.custNo ?? ""

        // check if we need to add presoldorder
        let managedObjectContext = globalInfo.managedObjectContext!
        let presoldOrder = PresoldOrHeader.getFirstBy(context: managedObjectContext, chainNo: chainNo, custNo: custNo)
        if presoldOrder != nil {
            let type = presoldOrder?.type ?? ""
            if type.uppercased() == "P" {
                presoldOrderHeader = presoldOrder
            }
        }

        orderHeaderArray = OrderHeader.getBy(context: managedObjectContext, chainNo: chainNo, custNo: custNo)
        isFirstPresoldOrder = false
        if presoldOrderHeader != nil {
            let orderNo = presoldOrderHeader?.orderNo ?? ""
            if orderHeaderArray.count > 0 {
                orderHeaderArray = orderHeaderArray.sorted(by: { (orderHeader1, orderHeader2) -> Bool in
                    let orderNo1 = orderHeader1.orderNo!
                    let orderNo2 = orderHeader2.orderNo!
                    if orderNo1 == orderNo {
                        return true
                    }
                    else if orderNo2 == orderNo {
                        return true
                    }
                    else {
                        return orderNo1 < orderNo2
                    }
                })
                let firstOrderHeader = orderHeaderArray.first!
                if firstOrderHeader.orderNo == orderNo {
                    isFirstPresoldOrder = true
                }
            }
        }
    }

    func initUI() {
        customerNameLabel.text = customerDetail.name ?? ""
        orderTableView.dataSource = self
        orderTableView.delegate = self
    }

    func refreshOrders() {
        orderTableView.reloadData()

        if rowCount == 0 {
            noDataLabel.isHidden = false
        }
        else {
            noDataLabel.isHidden = true
        }
    }

    func getOrderHeaderIndex(rowIndex: Int) -> Int {
        if presoldOrderHeader == nil {
            return rowIndex
        }
        else {
            if isFirstPresoldOrder == true {
                return rowIndex
            }
            else {
                return rowIndex-1
            }
        }
    }

    func isOrderHeaderPresoldOrder(rowIndex: Int) -> Bool {
        if presoldOrderHeader == nil {
            return false
        }
        else {
            if rowIndex == 0 {
                return true
            }
            else {
                return false
            }
        }
    }

    func onEditOrderByPresoldHeader() {
        self.dismiss(animated: true) {
            self.dismissHandler?(self, .newOrderByPresold)
        }
    }

    func onEditOrder(orderIndex: Int) {
        let orderHeader = orderHeaderArray[orderIndex]
        selectedOrderHeader = orderHeader
        self.dismiss(animated: true) {
            self.dismissHandler?(self, .selectEdition)
        }
    }

    func onViewOrder(orderIndex: Int) {
        let orderHeader = orderHeaderArray[orderIndex]
        if orderHeader.isUploaded == false {
            return
        }
        selectedOrderHeader = orderHeader
        self.dismiss(animated: true) {
            self.dismissHandler?(self, .select)
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?(self, .back)
        }
    }

    @IBAction func onNewOrder(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?(self, .newOrder)
        }
    }

}

extension ExistingOrdersVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let isPresoldOrder = isOrderHeaderPresoldOrder(rowIndex: index)
        if isPresoldOrder == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PresoldOrderCell") as! PresoldOrderCell
            cell.setupCell(parentVC: self, indexPath: indexPath)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExistingOrderCell") as! ExistingOrderCell
            cell.setupCell(parentVC: self, indexPath: indexPath)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

}
