//
//  SearchCustomerCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/31/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class SearchCustomerCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var topSeparatorLabel: UILabel!
    @IBOutlet weak var bottomSeparatorLabel: UILabel!
    @IBOutlet weak var addButton: AnimatableButton!
    
    var parentVC: SearchCustomerVC?
    var indexPath: IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell(parentVC: SearchCustomerVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        configCell()
    }

    func configCell() {
        addButton.setTitleForAllState(title: L10n.add())

        let index = indexPath!.row
        let customerDetail = parentVC!.customerDetailArray[index]

        selectionStyle = .none

        // customer item
        let itemTitle = customerDetail.getCustomerTitle()
        nameLabel.text = itemTitle

        if index == 0 {
            topSeparatorLabel.isHidden = false
        }
        else {
            topSeparatorLabel.isHidden = true
        }

    }

    @IBAction func onAddCustomer(_ sender: Any) {
        parentVC!.addCustomer(row: indexPath!.row)

    }

}
