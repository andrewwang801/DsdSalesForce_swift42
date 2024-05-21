//
//  ExistingOrderCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 9/13/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class ExistingOrderCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var orderNoLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var editButton: AnimatableButton!
    @IBOutlet weak var bottomSeparatorLabel: UILabel!

    var parentVC: ExistingOrdersVC!
    var indexPath: IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ExistingOrderCell.onTapOrder(_:)))
        mainView.addGestureRecognizer(tapGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {

        if animated == true {
            UIView.animate(withDuration: 1.0, animations: {
                if highlighted == true {
                    self.mainView.backgroundColor = kMessageCellSelectedColor
                }
                else {
                    self.mainView.backgroundColor = kMessageCellNormalColor
                }
            })
        }
        else {
            if highlighted == true {
                self.mainView.backgroundColor = kMessageCellSelectedColor
            }
            else {
                self.mainView.backgroundColor = kMessageCellNormalColor
            }
        }
    }

    func setupCell(parentVC: ExistingOrdersVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        self.configCell()
    }

    func configCell() {

        selectionStyle = .none
        let rowIndex = indexPath.row
        let orderIndex = parentVC.getOrderHeaderIndex(rowIndex: rowIndex)
        let orderHeader = parentVC.orderHeaderArray[orderIndex]
        orderNoLabel.text = "Order \(orderHeader.orderNo ?? "")"
        let dateString = orderHeader.trxnDate!
        let timeString = orderHeader.trxnTime!
        let fullDateString = "\(dateString)\(timeString)"
        let date = Date.fromDateString(dateString: fullDateString, format: kTightFullDateFormat)

        let _dateString = date?.toDateString(format: "d-M-yyyy 'at' hh:mma") ?? ""
        dateLabel.text = _dateString.lowercased()

        if orderHeader.isUploaded == true {
            editButton.isHidden = true
        }
        else {
            let uar = orderHeader.uar
            if uar != nil {
                if let lastPayment = uar!.uarPayments?.lastObject as? UARPayment {
                    let paymentType = Int(lastPayment.paymentType) ?? 0
                    if paymentType == kCollectionCard {
                        editButton.isHidden = true
                    }
                    else {
                        editButton.isHidden = false
                    }
                }
                else {
                    editButton.isHidden = false
                }
            }
            else {
                editButton.isHidden = false
            }
        }

        if rowIndex == parentVC.rowCount-1 {
            bottomSeparatorLabel.isHidden = true
        }
        else {
            bottomSeparatorLabel.isHidden = false
        }
    }

    @IBAction func onEditOrder(_ sender: Any) {
        let orderIndex = parentVC.getOrderHeaderIndex(rowIndex: indexPath.row)
        parentVC.onEditOrder(orderIndex: orderIndex)
    }

    @objc func onTapOrder(_ sender: Any) {
        let orderIndex = parentVC.getOrderHeaderIndex(rowIndex: indexPath.row)
        parentVC.onViewOrder(orderIndex: orderIndex)
    }
}
