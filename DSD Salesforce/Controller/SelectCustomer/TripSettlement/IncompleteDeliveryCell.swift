//
//  IncompleteDeliveryCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 12/26/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class IncompleteDeliveryCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var custNameLabel: UILabel!
    @IBOutlet weak var custNoLabel: UILabel!
    @IBOutlet weak var reasonCodeButton: AnimatableButton!
    @IBOutlet weak var caseLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var bottomSeparatorLabel: UILabel!

    var parentVC: IncompleteDeliveriesVC!
    var indexPath: IndexPath!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell(parentVC: IncompleteDeliveriesVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        configCell()
    }

    func configCell() {
        selectionStyle = .none
        let index = indexPath.row
        let incompleteInfo = parentVC.incompleteInfoArray[index]

        if index < parentVC.incompleteInfoArray.count-1 {
            bottomSeparatorLabel.isHidden = false
        }
        else {
            bottomSeparatorLabel.isHidden = true
        }

        let custName = incompleteInfo.customerDetail?.name ?? ""
        let custNo = incompleteInfo.customerDetail?.custNo ?? ""
        custNameLabel.text = custName
        custNoLabel.text = custNo

        let nReasonIndex = incompleteInfo.nReasonIdx
        if nReasonIndex == -1 {
            reasonCodeButton.setTitleForAllState(title: L10n.noSaleReason())
            reasonCodeButton.setTitleColor(UIColor.lightGray, for: .normal)
        }
        else {
            let reasonDescType = parentVC.reasonDescTypeArray[nReasonIndex]
            reasonCodeButton.setTitleForAllState(title: reasonDescType.desc ?? "")
            reasonCodeButton.setTitleColor(kBlackTextColor, for: .normal)
        }

        caseLabel.text = "\(incompleteInfo.nCases) \(L10n.cases())"
        unitLabel.text = "\(incompleteInfo.nUnits) \(L10n.units())"
    }

    @IBAction func onReasonCode(_ sender: Any) {

        let menuComboVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "MenuComboPopoverVC") as! MenuComboPopoverVC
        menuComboVC.modalPresentationStyle = .popover

        let senderButton = sender as! UIButton

        let index = indexPath.row
        let menuNames = parentVC.reasonDescTypeArray.map { (descType) -> String in
            return descType.desc ?? ""
        }
        let menuItemCount = min(menuNames.count, 10)
        let totalHeight = kPopoverMenuCellHeight * CGFloat(menuItemCount)
        menuComboVC.preferredContentSize = CGSize(width: senderButton.bounds.width, height: totalHeight)
        menuComboVC.menuNamesArray = menuNames
        menuComboVC.dismissHandler = {vc, selectedIndex in
            self.parentVC.incompleteInfoArray[index].nReasonIdx = selectedIndex
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

extension IncompleteDeliveryCell: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
