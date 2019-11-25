//
//  PresoldOrderCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 9/13/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class PresoldOrderCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var orderNoLabel: UILabel!
    @IBOutlet weak var poNumberLabel: UILabel!
    @IBOutlet weak var deliverInstructionLabel: UILabel!
    @IBOutlet weak var editButton: AnimatableButton!
    @IBOutlet weak var bottomSeparatorLabel: UILabel!

    var parentVC: ExistingOrdersVC!
    var indexPath: IndexPath!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PresoldOrderCell.onTapOrder(_:)))
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
        let presoldOrderHeader = parentVC.presoldOrderHeader!
        var orderHeader: OrderHeader?
        if parentVC.isFirstPresoldOrder == true {
            orderHeader = parentVC.orderHeaderArray.first!
        }

        orderNoLabel.text = "Order \(presoldOrderHeader.orderNo ?? "")"
        poNumberLabel.text = "PO Number  \(presoldOrderHeader.poRef ?? "")"
        deliverInstructionLabel.text = presoldOrderHeader.instrs ?? ""

        if orderHeader == nil {
            editButton.isHidden = false
        }
        else {
            if orderHeader!.isUploaded == true {
                editButton.isHidden = true
            }
            else {
                let uar = orderHeader!.uar
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
        }

        let rowIndex = indexPath.row
        if rowIndex == parentVC.rowCount-1 {
            bottomSeparatorLabel.isHidden = true
        }
        else {
            bottomSeparatorLabel.isHidden = false
        }
    }

    @IBAction func onEditOrder(_ sender: Any) {

        if parentVC.isFirstPresoldOrder == false {
            parentVC.onEditOrderByPresoldHeader()
        }
        else {
            parentVC.onEditOrder(orderIndex: 0)
        }

    }

    @objc func onTapOrder(_ sender: Any) {
        if parentVC.isFirstPresoldOrder == false {
            return
        }
        else {
            parentVC.onViewOrder(orderIndex: 0)
        }
    }

}
