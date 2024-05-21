//
//  SelectPrintersCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 9/10/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class SelectPrintersCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var topSeparatorLabel: UILabel!
    @IBOutlet weak var bottomSeparatorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
