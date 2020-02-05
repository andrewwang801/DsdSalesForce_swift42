//
//  CustomerCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/5/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class CustomerCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var leftIndicatorLabel: UILabel!
    @IBOutlet weak var rightIndicatorLabel: UILabel!
    @IBOutlet weak var stopImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bottomSeparatorLabel: UILabel!
    
    let globalInfo = GlobalInfo.shared
    
    var parentVC: SelectCustomerVC?
    var indexPath: IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CustomerCell.onTapMainView))
        mainView.addGestureRecognizer(tapGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {

    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {

        /*
        var unhighlightedColor = kCustomerCellNormalColor
        if indexPath != nil && parentVC != nil {
            if let selectedCustomer = parentVC!.selectedCustomer {
                let customer = parentVC!.customerDetailArray[indexPath!.row]
                if selectedCustomer.custNo == customer.custNo {
                    unhighlightedColor = kCustomerCellSelectedColor
                }
            }

        }*/

        if animated == true {
            UIView.animate(withDuration: 1.0, animations: {
                if highlighted == true {
                    self.mainView.alpha = 0.7
                }
                else {
                    self.mainView.alpha = 1.0
                }
            })
        }
        else {
            if highlighted == true {
                self.mainView.alpha = 0.7
            }
            else {
                self.mainView.alpha = 1.0
            }
        }
    }

    func setupCell(parentVC: SelectCustomerVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        configCell()
    }

    func configCell() {

        let index = indexPath!.row
        let customerDetail = parentVC!.customerDetailArray[index]
        let presoldOrHeader = parentVC!.presoldOrHeaderArray[index]

        selectionStyle = .none

        // customer item
        let itemTitle = customerDetail.getCustomerTitle()
        nameLabel.text = itemTitle

        // customer text color
        let creditHold = Double(customerDetail.creditHold ?? "") ?? 0
        if customerDetail.isCompleted == true {
            nameLabel.textColor = kGreenTextColor
        }
        else {
            if creditHold > 0 {
                nameLabel.textColor = kRedTextColor
            }
            else {
                let type = (presoldOrHeader?.type ?? "").uppercased()
                if type == "P" {
                    nameLabel.textColor = kBlueTextColor
                }
                else if type == "N" || type == "W" {
                    nameLabel.textColor = kOrangeTextColor
                }
                else {
                    nameLabel.textColor = kBlackTextColor
                }
            }

            let orderType = customerDetail.orderType ?? ""
            if orderType == "P" {
                nameLabel.textColor = kOrangeTextColor
            }
        }

        // background & indicators
        if let selectedCustomer = parentVC!.selectedCustomer {
            let customer = parentVC!.customerDetailArray[indexPath!.row]
            if selectedCustomer.custNo == customer.custNo {
                mainView.backgroundColor = kCustomerCellSelectedColor
                leftIndicatorLabel.isHidden = false
                rightIndicatorLabel.isHidden = true
            }
            else {
                mainView.backgroundColor = kCustomerCellNormalColor
                leftIndicatorLabel.isHidden = true
                rightIndicatorLabel.isHidden = false
            }
        }
        else {
            mainView.backgroundColor = kCustomerCellNormalColor
            leftIndicatorLabel.isHidden = true
            rightIndicatorLabel.isHidden = false
        }
    }

    @objc func onTapMainView() {
        let index = indexPath!.row
        let customer = parentVC!.customerDetailArray[index]
        let presoldOrHeader = parentVC!.presoldOrHeaderArray[index]
        
        globalInfo.selectedCustomer = customer
        globalInfo.selectedPresoldOrHeader = presoldOrHeader
        
        parentVC!.selectedCustomer = customer
        parentVC!.selectedPresoldOrHeader = presoldOrHeader
        parentVC!.onSelectedCustomer()
    }

}
