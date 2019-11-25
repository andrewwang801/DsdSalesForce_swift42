//
//  AssetManagementAssetCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/16/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class AssetManagementAssetCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var leftIndicatorLabel: UILabel!
    @IBOutlet weak var rightIndicatorLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var tickedImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bottomSeparatorLabel: UILabel!

    var parentVC: AssetManagementVC?
    var indexPath: IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        let tapMainViewGesture = UITapGestureRecognizer(target: self, action: #selector(AssetManagementAssetCell.onTapMainView))
        mainView.addGestureRecognizer(tapMainViewGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {

    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {

        var unhighlightedColor = kCustomerCellNormalColor
        if indexPath != nil && parentVC != nil {
            let index = indexPath!.row
            let equipmentWithAss = parentVC!.currentEquipmentWithAssArray[index]
            if parentVC!.selectedEquipmentWithAss == equipmentWithAss {
                unhighlightedColor = kCustomerCellSelectedColor
            }
        }

        if animated == true {
            UIView.animate(withDuration: 1.0, animations: {
                if highlighted == true {
                    self.mainView.backgroundColor = kCustomerCellHighlightedColor
                }
                else {
                    self.mainView.backgroundColor = unhighlightedColor
                }
            })
        }
        else {
            if highlighted == true {
                self.mainView.backgroundColor = kCustomerCellHighlightedColor
            }
            else {
                self.mainView.backgroundColor = unhighlightedColor
            }
        }
    }

    func setupCell(parentVC: AssetManagementVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        configCell()
    }

    func configCell() {

        selectionStyle = .none

        let index = indexPath!.row
        let equipmentWithAss = parentVC!.currentEquipmentWithAssArray[index]

        let equipmentImage = equipmentWithAss.equipment?.getEquipmentImage()
        iconImageView.image = equipmentImage

        let desc = equipmentWithAss.equipment?.desc ?? ""
        let serialNo = equipmentWithAss.equipment?.serialNo ?? ""
        nameLabel.text = "\(desc)\n\(serialNo)"

        // background & indicators
        mainView.backgroundColor = kAssetCellNormalColor
        leftIndicatorLabel.isHidden = true
        rightIndicatorLabel.isHidden = false
        if parentVC!.selectedEquipmentWithAss?.equipment == equipmentWithAss.equipment {
            mainView.backgroundColor = kAssetCellSelectedColor
            leftIndicatorLabel.isHidden = false
            rightIndicatorLabel.isHidden = true
        }
        tickedImageView.isHidden = true
    }

    @objc func onTapMainView() {
        let index = indexPath!.row
        parentVC!.selectedEquipmentWithAss = parentVC!.currentEquipmentWithAssArray[index]
        parentVC!.refreshAssets()
    }

}
