//
//  VisitPlannerWeekdayCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 5/12/19.
//  Copyright © 2019 iOS Developer. All rights reserved.
//

import UIKit

class VisitPlannerWeekdayCell: UICollectionViewCell, UIDropInteractionDelegate {
    
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weekdayButton: UIButton!
    
    let globalInfo = GlobalInfo.shared
    var selectedCustomer: CustomerDetail!
    
    var parentVC: VisitPlannerVC!
    var indexPath: IndexPath!

    let kSelectedTextColor = UIColor.white
    let kNormalTextColor = UIColor(red: 150.0/255, green: 150.0/255, blue: 150.0/255, alpha: 1.0)

    override func awakeFromNib() {
        super.awakeFromNib()
        weekdayButton.addTarget(self, action: #selector(VisitPlannerWeekdayCell.onWeekdayButtonTapped(_:)), for: .touchUpInside)
        
        let dropInteraction = UIDropInteraction(delegate: self)
        self.addInteraction(dropInteraction)
    }

    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        // Ensure the drop session has an object of the appropriate type
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
            // Propose to the system to copy the item from the source app
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        print("dropped")
        // Consume drag items (in this example, of type UIImage).
        session.loadObjects(ofClass: NSString.self) { indexItems in
            let indexes = indexItems as! [String]
            
            let selectedDay = self.parentVC.weekdayStart.getDateAddedBy(days: self.indexPath.row)
            let nowDateString = selectedDay.toDateString(format: kTightJustDateFormat) ?? ""
            let dayNo = Utils.getWeekday(date: selectedDay)
            let draggegdIndex = Int(indexes.first!)
            
            self.selectedCustomer = self.parentVC.customerDetailArray[draggegdIndex!]
            self.selectedCustomer.setValue(nowDateString, forKey: "deliveryDate")
            self.selectedCustomer.setValue(String(dayNo), forKey: "dayNo")
            self.selectedCustomer.nextVisitDate = nowDateString
            GlobalInfo.saveCache()
            
            self.parentVC.onWeekdayTapped(index: self.indexPath.row)
            self.globalInfo.uploadManager?.uploadVisit(selectedCustomer: self.selectedCustomer, completionHandler: nil)            
        }
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
            theDayTitle = L10n.today()
        }
        else if index == 1 {
            theDayTitle = L10n.tomorrow()
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
