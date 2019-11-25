//
//  ComboCell.swift
//  MyTaxPal
//
//  Created by iOS Developer on 5/23/16.
//  Copyright © 2017 Q-Scope. All rights reserved.
//

import UIKit

class ComboCell: UITableViewCell {

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
