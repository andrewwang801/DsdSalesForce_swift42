//
//  SalesReasonCodeCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 9/7/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class SalesReasonCodeCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var itemNoLabel: UILabel!
    @IBOutlet weak var reasonCodeButton: AnimatableButton!
    @IBOutlet weak var qtyLabel: UILabel!
    @IBOutlet weak var bottomSeparatorLabel: UILabel!

    var parentVC: OrderReasonCodeVC!
    var indexPath: IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell(parentVC: OrderReasonCodeVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        configCell()
    }

    func configCell() {
        reasonCodeButton.setTitleForAllState(title: L10n.saStrNoReasonCode())
        
        selectionStyle = .none
        let section = indexPath.section
        let row = indexPath.row
        let orderDetail = parentVC.orderDetailArray[section][row]

        if row < parentVC.orderDetailArray[section].count-1 {
            bottomSeparatorLabel.isHidden = false
        }
        else {
            bottomSeparatorLabel.isHidden = true
        }

        let shortDesc = orderDetail.shortDesc!
        let itemNo = orderDetail.itemNo!
        descLabel.text = shortDesc
        itemNoLabel.text = itemNo

        var diffQty: Int32 = 0
        let orderType = parentVC.orderTypeArray[section]
        if orderType == parentVC.orderVC.kOrderReturns {
            diffQty = orderDetail.enterQty
        }
        else {
            diffQty = orderDetail.enterQty - orderDetail.planQty
        }

        var qtyString = ""
        if parentVC.shouldUseCase == true {
            let nCase = Utils.getCaseValue(itemNo: itemNo)
            if diffQty > 0 {
                qtyString = "\(diffQty.int/nCase)/\(diffQty.int%nCase)"
                qtyLabel.textColor = kBlackTextColor
            }
            else {
                qtyString = "-\((-diffQty.int)/nCase)/\((-diffQty.int)%nCase)"
                qtyLabel.textColor = UIColor.red
            }
        }
        else {
            if diffQty > 0 {
                qtyString = "\(diffQty)"
                qtyLabel.textColor = kBlackTextColor
            }
            else {
                qtyString = "\(diffQty)"
                qtyLabel.textColor = UIColor.red
            }
        }
        qtyLabel.text = qtyString

        let reasonCodeIndex = parentVC.reasonCodeIndexArray[section][row]
        if reasonCodeIndex == -1 {
            reasonCodeButton.setTitleForAllState(title: parentVC.kNoReasonArray[section])
        }
        else {
            let reasonDesc = parentVC.reasonCodeDescArray[section][reasonCodeIndex].desc ?? ""
            reasonCodeButton.setTitleForAllState(title: reasonDesc)
        }
    }

    @IBAction func onReasonCode(_ sender: Any) {

        let menuComboVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "MenuComboPopoverVC") as! MenuComboPopoverVC
        menuComboVC.modalPresentationStyle = .popover

        let senderButton = sender as! UIButton

        let section = indexPath.section
        let row = indexPath.row
        let descTypeArray = parentVC.reasonCodeDescArray[section]
        let menuNames = descTypeArray.map { (descType) -> String in
            return descType.desc ?? ""
        }
        let menuItemCount = min(menuNames.count, 10)
        let totalHeight = kPopoverMenuCellHeight * CGFloat(menuItemCount)
        menuComboVC.preferredContentSize = CGSize(width: senderButton.bounds.width, height: totalHeight)
        menuComboVC.menuNamesArray = menuNames
        menuComboVC.dismissHandler = {vc, selectedIndex in
            self.parentVC.reasonCodeIndexArray[section][row] = selectedIndex
            self.configCell()
            self.parentVC.checkIfCanProceed()
        }

        let presentationPopoverVC = menuComboVC.popoverPresentationController
        presentationPopoverVC?.permittedArrowDirections = [.up]
        presentationPopoverVC?.delegate = self
        presentationPopoverVC?.sourceView = senderButton
        presentationPopoverVC?.sourceRect = senderButton.bounds
        presentationPopoverVC?.backgroundColor = kPopoverMenuBackgroundColor

        parentVC.present(menuComboVC, animated: true, completion: nil)
    }
}

extension SalesReasonCodeCell: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

