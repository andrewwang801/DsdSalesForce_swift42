//
//  OrderProductCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/11/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class OrderProductCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var expandImageView: AnimatableImageView!
    @IBOutlet weak var leftMarginConstraint: NSLayoutConstraint!

    var parentVC: OrderVC!
    var treeItem: OrderVC.TreeItem!

    override func awakeFromNib() {
        super.awakeFromNib()

        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(OrderProductCell.onLongTapView(_:)))
        self.contentView.addGestureRecognizer(longTapGesture)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @objc func onLongTapView(_ sender: Any) {
        let longPressGestureRecognizer = sender as! UILongPressGestureRecognizer
        if longPressGestureRecognizer.state != .began {
            return
        }
        parentVC.onLongPress(forItem: treeItem)
    }

}
