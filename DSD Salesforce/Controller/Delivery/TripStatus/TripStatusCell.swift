//
//  TripStatusCell.swift
//  DSDConnect
//
//  Created by iOS Developer on 3/16/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class TripStatusCell: UITableViewCell {

    @IBOutlet weak var backLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

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
