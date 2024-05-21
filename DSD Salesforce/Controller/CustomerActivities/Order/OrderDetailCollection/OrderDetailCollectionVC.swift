//
//  OrderDetailCollectionVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 8/31/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class OrderDetailCollectionVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var allCheckImageView: UIImageView!
    @IBOutlet weak var allPriceLabel: UILabel!
    @IBOutlet weak var invoiceTableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var doneButton: AnimatableButton!
    @IBOutlet weak var collectionRequiredLabel: UILabel!
    @IBOutlet weak var backButton: AnimatableButton!
    
    var customerDetail: CustomerDetail!
    var arHeaderArray = [ARHeader]()
    var selectedIndexArray = [Int]()
    var isReadOnly = false
    //var invoiceArray = [OrderCollectionInvoice]()
    //var selectedArray = [Int]()

    enum DismissOption {
        case cancelled
        case done
    }

    var dismissHandler: ((OrderDetailCollectionVC, DismissOption) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshInvoices()
    }

    func initUI() {
        titleLabel.text = L10n.detailCollection()
        collectionRequiredLabel.text = L10n.collectionRequired()
        backButton.setTitleForAllState(title: L10n.back())
        doneButton.setTitleForAllState(title: L10n.Done())
        
        customerNameLabel.text = customerDetail.name ?? ""

        invoiceTableView.dataSource = self
        invoiceTableView.delegate = self

        allButton.isEnabled = !isReadOnly
        doneButton.isEnabled = !isReadOnly
    }

    func refreshInvoices() {
        invoiceTableView.reloadData()
        if arHeaderArray.count == 0 {
            noDataLabel.isHidden = false
        }
        else {
            noDataLabel.isHidden = true
        }

        if arHeaderArray.count == arHeaderArray.count {
            allCheckImageView.isHidden = false
        }
        else {
            allCheckImageView.isHidden = true
        }

        var totalAmount: Double = 0
        for index in selectedIndexArray {
            let amount = Utils.getXMLDivided(valueString: arHeaderArray[index].trxnAmount ?? "0")
            totalAmount += amount
        }
        if totalAmount >= 0 {
            allPriceLabel.text = Utils.getMoneyString(moneyValue: totalAmount)
        }
        else {
            allPriceLabel.text = "-"+Utils.getMoneyString(moneyValue: fabs(totalAmount))
        }
    }

    @IBAction func onTapAllCheck(_ sender: Any) {
        if selectedIndexArray.count == arHeaderArray.count {
            // deselect all
            selectedIndexArray.removeAll()
        }
        else {
            // select all
            selectedIndexArray.removeAll()
            for (index, _) in arHeaderArray.enumerated() {
                selectedIndexArray.append(index)
            }
        }
        refreshInvoices()
    }

    @IBAction func onDone(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?(self, .done)
        }
    }

    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?(self, .cancelled)
        }
    }
}

extension OrderDetailCollectionVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arHeaderArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderDetailCollectionCell", for: indexPath) as! OrderDetailCollectionCell
        cell.setupCell(parentVC: self, indexPath: indexPath)
        return cell
    }

}

extension OrderDetailCollectionVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

}
