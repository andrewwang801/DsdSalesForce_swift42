//
//  VisitPlannerWeekdayCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 5/12/19.
//  Copyright © 2019 iOS Developer. All rights reserved.
//

import UIKit

class VisitPlannerWeekdayCell: UICollectionViewCell {
    
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weekdayButton: UIButton!

    var parentVC: VisitPlannerVC!
    var indexPath: IndexPath!

    let kSelectedTextColor = UIColor.white
    let kNormalTextColor = UIColor(red: 150.0/255, green: 150.0/255, blue: 150.0/255, alpha: 1.0)

    override func awakeFromNib() {
        super.awakeFromNib()
        weekdayButton.addTarget(self, action: #selector(VisitPlannerWeekdayCell.onWeekdayButtonTapped(_:)), for: .touchUpInside)
    }

    func setupCell(parentVC: VisitPlannerVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        configCell()
    }

    func configCell() {
        let index = indexPath.row
        var theDayTitle = ""
        let theDay = parentVC.weekdayStart.getDateAddedBy(days: index)
        if index == 0 {
            theDayTitle = "Today"
        }
        else if index == 1 {
            theDayTitle = "Tomorrow"
        }
        else {
            theDayTitle = theDay.toDateString(format: "EEEE") ?? ""
        }
        weekdayLabel.text = theDayTitle.uppercased()
        dayLabel.text = theDay.toDateString(format: "d MMMM")!.uppercased()

        if index == parentVC.selectedWeekdayIndex {
            weekdayButton.isSelected = true
            weekdayLabel.textColor = kSelectedTextColor
            dayLabel.textColor = kSelectedTextColor
        }
        else {
            weekdayButton.isSelected = false
            weekdayLabel.textColor = kNormalTextColor
            dayLabel.textColor = kNormalTextColor
        }
    }

    @objc func onWeekdayButtonTapped(_ sender: Any) {
        parentVC.onWeekdayTapped(index: indexPath.row)
    }

}
