//
//  MultiSelectMenuCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 6/11/19.
//  Copyright © 2019 iOS Developer. All rights reserved.
//

import UIKit

class MultiSelectMenuCell: UITableViewCell {

    @IBOutlet weak var backLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var separatorLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
