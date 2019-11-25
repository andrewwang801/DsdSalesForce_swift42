//
//  OrderReviewTypeCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 5/12/19.
//  Copyright © 2019 iOS Developer. All rights reserved.
//

import UIKit

class OrderReviewTypeCell: UICollectionViewCell {
    
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var bottomSeparator: UILabel!

    var parentVC: OrderReviewVC!
    var indexPath: IndexPath!
    // var dropDown = DropDown()

    override func awakeFromNib() {
        super.awakeFromNib()
        typeButton.addTarget(self, action: #selector(OrderReviewTypeCell.onTypeButtonTapped(_:)), for: .touchUpInside)
        bottomSeparator.backgroundColor = kOrangeColor
    }

    func setupCell(parentVC: OrderReviewVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        configCell()
    }

    func configCell() {
        let index = indexPath.row
        let typeTitle = parentVC.kTypeTitleArray[index]
        typeButton.setTitleForAllState(title: typeTitle)
        bottomSeparator.isHidden = true

        let selectedIndex = parentVC.selectedType.rawValue
        if index == selectedIndex {
            typeButton.isSelected = true
        }
        else {
            typeButton.isSelected = false
        }
    }

    @objc func onTypeButtonTapped(_ sender: Any) {
        let index = indexPath.row
        typeButton.isSelected = true
        parentVC.onTypeTapped(index: index)
    }

}
