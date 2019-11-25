//
//  CustomerActivitySurveyCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 8/3/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class CustomerActivitySurveyCell: UICollectionViewCell {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var surveyNameLabel: UILabel!

    var parentVC: CustomerActivitiesVC!
    var indexPath: IndexPath!

    override func awakeFromNib() {
        super.awakeFromNib()
        backButton.addTarget(self, action: #selector(CustomerActivitySurveyCell.onTapSurveyButton(_:)), for: .touchUpInside)
    }

    func setupCell(parentVC: CustomerActivitiesVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        configCell()
    }

    func configCell() {

        let index = indexPath.row
        let surveySet = parentVC.customerDetail.surveySet
        let survey = surveySet[index] as! Survey

        self.backgroundColor = UIColor.clear
        self.surveyNameLabel.text = (survey.surveyTitle ?? "").uppercased()
        let isCompleted = survey.isCompleted
        if isCompleted == true {
            self.iconImageView.image = #imageLiteral(resourceName: "Activity_Check")
        }
        else {
            self.iconImageView.image = #imageLiteral(resourceName: "Activity_Uncheck")
        }
    }

    @objc func onTapSurveyButton(_ sender: Any) {
        let index = indexPath.row
        parentVC.onTapSurvey(index: index)
    }
}
