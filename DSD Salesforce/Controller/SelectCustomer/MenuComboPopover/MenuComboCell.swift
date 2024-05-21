//
//  MenuComboCell.swift
//  iRis
//
//  Created by iOS Developer on 5/23/16.
//  Copyright © 2016 Q-Scope. All rights reserved.
//

import UIKit

class MenuComboCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
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
