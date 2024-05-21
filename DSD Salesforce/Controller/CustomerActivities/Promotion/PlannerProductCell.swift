//
//  PlannerProductCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/17/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class PlannerProductCell: UITableViewCell {

    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var promotionBarLabel: UILabel!
    @IBOutlet weak var promotionBarLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var promotionBarWidthConstraint: NSLayoutConstraint!

    var parentVC: PromotionPlannerVC!
    var indexPath: IndexPath!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        let tapPromotionBarGesture = UITapGestureRecognizer(target: self, action: #selector(PlannerProductCell.onTapPromotionBar(_:)))
        promotionBarLabel.isUserInteractionEnabled = true
        promotionBarLabel.addGestureRecognizer(tapPromotionBarGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell(parentVC: PromotionPlannerVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        configCell()
    }

    func configCell() {

        self.backgroundColor = UIColor.clear
        self.backgroundView?.backgroundColor = UIColor.clear

        let index = indexPath.row
        let promotionPlan = parentVC.promotionPlanArray[index]
        productNameLabel.text = promotionPlan.productDetail?.desc ?? ""
        if index == parentVC.selectedPromotionPlanIndex {
            promotionBarLabel.backgroundColor = kPromotionBarSelectedColor
        }
        else {
            let typeIndex = index % 4
            promotionBarLabel.backgroundColor = kPromotionBarColorArray[typeIndex]
        }
        let promotionWeekStartDate = parentVC.promotionWeekStartDate

        let promotionStartDateString = promotionPlan.promotionHeader.dateStart ?? ""
        let promotionStartDate = Date.fromDateString(dateString: promotionStartDateString, format: kTightJustDateFormat) ?? Date()
        var startDayOffset = promotionWeekStartDate.numberOfDaysUntilDateTime(toDateTime: promotionStartDate)
        if startDayOffset < 0 {
            startDayOffset = 0
        }
        promotionBarLeftConstraint.constant = CGFloat(startDayOffset)*PromotionPlannerVC.kPixelsPerDay

        let promotionEndDateString = promotionPlan.promotionHeader.dateEnd ?? ""
        let promotionEndDate = Date.fromDateString(dateString: promotionEndDateString, format: kTightJustDateFormat) ?? Date()

        var visibleStartDate = Date()
        if promotionWeekStartDate.compare(promotionStartDate) == .orderedAscending {
            visibleStartDate = promotionStartDate
        }
        else {
            visibleStartDate = promotionWeekStartDate
        }
        var durationDays = visibleStartDate.numberOfDaysUntilDateTime(toDateTime: promotionEndDate)
        if durationDays > 7*kPromotionWeekCount {
            durationDays = 7*kPromotionWeekCount
        }
        promotionBarWidthConstraint.constant = CGFloat(durationDays)*PromotionPlannerVC.kPixelsPerDay
    }

    @objc func onTapPromotionBar(_ sender: Any) {
        let index = indexPath.row
        parentVC.selectedPromotionPlanIndex = index
        parentVC.rightInfoView.isHidden = false
        parentVC.updateUI()
    }

}
