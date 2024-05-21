//
//  CustomerContactCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/29/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class CustomerContactCell: UITableViewCell {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var phoneWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
