//
//  SelectCustomerPromotionCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/10/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class SelectCustomerPromotionCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var pricingLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var untilLabel: UILabel!

    var parentVC: PromotionBaseVC!
    var indexPath: IndexPath!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {

    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {

        if animated == true {
            UIView.animate(withDuration: 1.0, animations: {
                if highlighted == true {
                    self.mainView.backgroundColor = kProductCellNormalColor
                }
                else {
                    self.mainView.backgroundColor = kProductCellSelectedColor
                }
            })
        }
        else {
            if highlighted == true {
                self.mainView.backgroundColor = kProductCellNormalColor
            }
            else {
                self.mainView.backgroundColor = kProductCellSelectedColor
            }
        }
    }

    func setupCell(parentVC: PromotionBaseVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        configCell()
    }

    func configCell() {
        selectionStyle = .none
        let index = indexPath.row
        let promotionPlan = parentVC.promotionPlanArray[index]
        let productDetail = promotionPlan.productDetail

        nameLabel.text = productDetail?.desc ?? ""
        descLabel.text = productDetail?.itemNo ?? ""
        pricingLabel.text = promotionPlan.promotionOption?.featurePrice ?? ""

        let validStartDate = Date.fromDateString(dateString: promotionPlan.promotionHeader.dateStart ?? "", format: kTightJustDateFormat) ?? Date()
        let validEndDate = Date.fromDateString(dateString: promotionPlan.promotionHeader.dateEnd ?? "", format: kTightJustDateFormat) ?? Date()

        fromLabel.text = "\(validStartDate.toDateString(format: "dd-MM-yyyy") ?? "")"
        untilLabel.text = "\(validEndDate.toDateString(format: "dd-MM-yyyy") ?? "")"
    }

}
