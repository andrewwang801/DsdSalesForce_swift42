//
//  ContactCell.swift
//  DSDConnect
//
//  Created by iOS Developer on 3/27/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class ContactCell: UITableViewCell {

    @IBOutlet weak var backLabel: UILabel!
    @IBOutlet weak var statusLabel: AnimatableLabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var nameLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameRightConstraint: NSLayoutConstraint!

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
                    self.backLabel.backgroundColor = kTripStatusCellSelectedColor
                }
                else {
                    self.backLabel.backgroundColor = kTripStatusCellNormalColor
                }
            })
        }
        else {
            if highlighted == true {
                self.backLabel.backgroundColor = kTripStatusCellSelectedColor
            }
            else {
                self.backLabel.backgroundColor = kTripStatusCellNormalColor
            }
        }
    }

}
