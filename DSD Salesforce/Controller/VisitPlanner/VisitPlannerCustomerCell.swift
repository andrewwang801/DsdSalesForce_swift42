//
//  VisitPlannerCustomerCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 5/11/19.
//  Copyright © 2019 iOS Developer. All rights reserved.
//

import UIKit

class VisitPlannerCustomerCell: UITableViewCell {

    @IBOutlet weak var noLabel: UILabel!
    @IBOutlet weak var noLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var noteButton: UIButton!
    @IBOutlet weak var locateButton: UIButton!
    @IBOutlet weak var bottomSeparator: UILabel!

    let globalInfo = GlobalInfo.shared
    var parentVC: VisitPlannerVC!
    var indexPath: IndexPath!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell(parentVC: VisitPlannerVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        configCell()
    }

    func configCell() {
        self.selectionStyle = .none

        let index = indexPath.row
        let customerDetail = parentVC.customerDetailArray[index]
        let presoldOrHeader = parentVC.presoldOrHeaderArray[index]

        let tagNo = customerDetail.getCustomerTag()
        noLabel.text = tagNo
        let estimatedWidth = tagNo.width(withConstraintedHeight: noLabel.bounds.height, attributes: [NSAttributedString.Key.font: noLabel.font])
        noLabelWidthConstraint.constant = estimatedWidth+20

        let custTitle = customerDetail.getCustomerTitle()
        titleLabel.text = custTitle

        var cellTextColor = kBlackTextColor
        let creditHold = Double(customerDetail.creditHold ?? "") ?? 0
        if customerDetail.isCompleted == true {
            cellTextColor = kGreenTextColor
        }
        else {
            if creditHold > 0 {
                cellTextColor = kRedTextColor
            }
            else {
                let type = (presoldOrHeader?.type ?? "").uppercased()
                if type == "P" {
                    cellTextColor = kBlueTextColor
                }
                else if type == "N" || type == "W" {
                    cellTextColor = kOrangeTextColor
                }
                else {
                    cellTextColor = kBlackTextColor
                }
            }

            let orderType = customerDetail.orderType ?? ""
            if orderType == "P" {
                cellTextColor = kOrangeTextColor
            }
        }
        noLabel.backgroundColor = cellTextColor
        titleLabel.textColor = cellTextColor

        let chainNo = customerDetail.chainNo ?? "0"
        let custNo = customerDetail.custNo ?? "0"
        let custNoteArray = CustNote.getBy(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo)
        if custNoteArray.count > 0 {
            noteButton.isHidden = false
        }
        else {
            noteButton.isHidden = true
        }

        if index == parentVC.customerDetailArray.count-1 {
            bottomSeparator.isHidden = true
        }
        else {
            bottomSeparator.isHidden = false
        }
    }

    @IBAction func onNoteButton(_ sender: Any) {
        parentVC.onNoteCustomerTapped(index: indexPath.row)
    }

    @IBAction func onLocateButton(_ sender: Any) {
        parentVC.onLocateCustomerTapped(index: indexPath.row)
    }

}

