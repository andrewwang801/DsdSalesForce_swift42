//
//  OrderReasonCodeVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 9/7/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class OrderReasonCodeVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var reasonCodeTableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var doneButton: AnimatableButton!

    let globalInfo = GlobalInfo.shared
    var orderVC: OrderVC!

    var orderDetailArray = [[OrderDetail]]()
    var reasonCodeIndexArray = [[Int]]()
    var reasonCodeDescArray = [[DescType]]()
    var orderTypeArray = [Int]()
    var shouldUseCase = false
    let kSectionHeight: CGFloat = 40.0

    let kTitleArray = ["ORDER ADJUSTMENTS", "RETURN REASONS", "FREE REASONS"]
    let kNoReasonArray = ["Select Reason", "Select Reason", "Select Reason"]

    enum DismissOption {
        case completed
        case cancelled
    }

    var dismissHander: ((OrderReasonCodeVC, DismissOption)->())?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
        initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reasonCodeTableView.reloadData()
    }

    func initData() {
        let inventoryUOM = globalInfo.routeControl?.inventoryUOM ?? ""
        let isShowCase = inventoryUOM != "U"
        let salEntryMode = orderVC.customerDetail.salEntryMode ?? ""
        if isShowCase == true && salEntryMode == "B" {
            shouldUseCase = true
        }
        else {
            shouldUseCase = false
        }

        for (groupIndex, orderDetailGroup) in orderDetailArray.enumerated() {
            var reasonArray = [Int]()
            for orderDetail in orderDetailGroup {
                let reasonCode = orderDetail.reasonCode ?? ""
                var foundIndex = -1
                for (descTypeIndex, descType) in reasonCodeDescArray[groupIndex].enumerated() {
                    if descType.numericKey == reasonCode {
                        foundIndex = descTypeIndex
                        break
                    }
                }
                reasonArray.append(foundIndex)
            }
            reasonCodeIndexArray.append(reasonArray)
        }
    }

    func initUI() {
        noDataLabel.isHidden = true
        reasonCodeTableView.dataSource = self
        reasonCodeTableView.delegate = self
        checkIfCanProceed()
    }

    func checkIfCanProceed() {
        var isReasonEmpty = false
        for reasonCodeGroup in reasonCodeIndexArray {
            for reasonCodeIndex in reasonCodeGroup {
                if reasonCodeIndex == -1 {
                    isReasonEmpty = true
                    break
                }
            }
        }
        doneButton.isEnabled = !isReasonEmpty
    }

    @IBAction func onReturn(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHander?(self, .cancelled)
        }
    }

    @IBAction func onDone(_ sender: Any) {

        for (section, reasonCodeGroup) in reasonCodeIndexArray.enumerated() {
            for (row, reasonCodeIndex) in reasonCodeGroup.enumerated() {
                let reasonDescType = reasonCodeDescArray[section][reasonCodeIndex]
                orderDetailArray[section][row].reasonCode = reasonDescType.numericKey ?? ""
                let descTypeID = reasonDescType.descriptionTypeID ?? ""
                if descTypeID == "RETURNRSN" {
                    orderDetailArray[section][row].trxnType = kTrxnPickup.int32
                }
                else if descTypeID == "BUYBACKRSN" {
                    orderDetailArray[section][row].trxnType = kTrxnBuyBack.int32
                }
            }
        }

        GlobalInfo.saveCache()

        self.dismiss(animated: true) {
            self.dismissHander?(self, .completed)
        }
    }
}

extension OrderReasonCodeVC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return orderDetailArray.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderDetailArray[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SalesReasonCodeCell", for: indexPath) as! SalesReasonCodeCell
        cell.setupCell(parentVC: self, indexPath: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kSectionHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let bounds = tableView.bounds
        let view = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: kSectionHeight))
        view.backgroundColor = UIColor(red: 200.0/255, green: 200.0/255, blue: 200.0/255, alpha: 1.0)
        let viewBounds = view.bounds.insetBy(dx: 10.0, dy: 0)
        let titleLabel = UILabel(frame: viewBounds)
        titleLabel.font = UIFont(name: "Roboto-Medium", size: 16.0)
        titleLabel.text = kTitleArray[orderTypeArray[section]]
        titleLabel.textColor = kBlackTextColor
        titleLabel.backgroundColor = UIColor.clear
        view.addSubview(titleLabel)
        return view
    }

}

extension OrderReasonCodeVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }

}
