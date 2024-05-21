//
//  AssetAddAssetCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/16/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class AssetAddAssetCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var leftIndicatorLabel: UILabel!
    @IBOutlet weak var rightIndicatorLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var tickedImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bottomSeparatorLabel: UILabel!

    var parentVC: AssetAddBaseVC?
    var indexPath: IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        let tapMainViewGesture = UITapGestureRecognizer(target: self, action: #selector(AssetAddAssetCell.onTapMainView))
        mainView.addGestureRecognizer(tapMainViewGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {

    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {

        var unhighlightedColor = kCustomerCellNormalColor
        if indexPath != nil && parentVC != nil {
            let index = indexPath!.row
            let equipment = parentVC?.equipmentArray[index]
            if parentVC!.selectedEquipment == equipment {
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

    func setupCell(parentVC: AssetAddBaseVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        configCell()
    }

    func configCell() {

        selectionStyle = .none

        let index = indexPath!.row
        let equipment = parentVC!.equipmentArray[index]

        let equipmentImage = equipment.getEquipmentImage()
        iconImageView.image = equipmentImage

        let desc = equipment.desc ?? ""
        let serialNo = equipment.serialNo ?? ""
        nameLabel.text = "\(desc)\n\(serialNo)"

        // background & indicators
        if parentVC!.selectedEquipment == equipment {
            mainView.backgroundColor = kAssetCellSelectedColor
            leftIndicatorLabel.isHidden = false
            rightIndicatorLabel.isHidden = true
            tickedImageView.image = UIImage(named: "Add_Asset_Ticked")
        }
        else {
            mainView.backgroundColor = kAssetCellNormalColor
            leftIndicatorLabel.isHidden = true
            rightIndicatorLabel.isHidden = false
            tickedImageView.image = UIImage(named: "Add_Asset_Unticked")
        }

    }

    @objc func onTapMainView() {
        let index = indexPath!.row
        let equipment = parentVC!.equipmentArray[index]
        if equipment == parentVC!.selectedEquipment {
            return
        }
        parentVC!.selectedEquipment = equipment
        parentVC!.refreshAssets()
    }

    /*
    func onTapTickView() {
        let index = indexPath!.row
        if let _index = parentVC!.tickedAssetIndexArray.index(of: index) {
            parentVC!.tickedAssetIndexArray.remove(at: _index)
        }
        else {
            parentVC!.tickedAssetIndexArray.append(index)
        }
        parentVC!.refreshAssets()
    }*/

}
