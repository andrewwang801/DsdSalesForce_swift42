//
//  DistributionCheckCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/8/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class DistributionCheckCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var asileText: AnimatableTextField!
    @IBOutlet weak var onShelfSwitch: CustomSwitch!
    @IBOutlet weak var shelfText: AnimatableTextField!
    @IBOutlet weak var expiryText: AnimatableTextField!

    var parentVC: DistributionCheckVC!
    var indexPath: IndexPath!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        onShelfSwitch.addTarget(self, action: #selector(DistributionCheckCell.onChangeOnShelfValue(_:)), for: .valueChanged)

        asileText.addTarget(self, action: #selector(DistributionCheckCell.onChangeAisle(_:)), for: .editingChanged)
        shelfText.addTarget(self, action: #selector(DistributionCheckCell.onChangeShelf(_:)), for: .editingChanged)
        expiryText.addTarget(self, action: #selector(DistributionCheckCell.onChangeExpiry(_:)), for: .editingChanged)

        asileText.delegate = self
        shelfText.delegate = self
        expiryText.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {

    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {

        if animated == true {
            UIView.animate(withDuration: 1.0, animations: {
                if highlighted == true {
                    self.mainView.backgroundColor = kProductCellNormalColor
                }
                else {
                    self.mainView.backgroundColor = kProductCellSelectedColor
                }
            })
        }
        else {
            if highlighted == true {
                self.mainView.backgroundColor = kProductCellNormalColor
            }
            else {
                self.mainView.backgroundColor = kProductCellSelectedColor
            }
        }
    }

    func setupCell(parentVC: DistributionCheckVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        configCell()
    }

    func configCell() {
        selectionStyle = .none
        let index = indexPath.row
        let distributionCheck = parentVC.distributionCheckArray[index]
        let productDetail = distributionCheck.productDetail
        let shelfStatus = distributionCheck.shelfStatus!
        categoryLabel.text = distributionCheck.category
        nameLabel.text = productDetail?.desc ?? ""
        descLabel.text = productDetail?.itemNo ?? ""
        productImageView.image = productDetail?.getProductImage()
        asileText.text = shelfStatus.aisle ?? "0"
        onShelfSwitch.setOn(on: shelfStatus.isOnShelf, animated: false)
        shelfText.isEnabled = shelfStatus.isOnShelf
        shelfText.text = shelfStatus.stockCount ?? "0"
        expiryText.text = shelfStatus.expiry ?? ""
    }

    @objc func onChangeOnShelfValue(_ sender: Any) {
        let isOn = onShelfSwitch.isOn
        let index = indexPath.row
        parentVC.distributionCheckArray[index].shelfStatus!.oos = isOn ? "0" : "1"

        if isOn == false {
            parentVC.distributionCheckArray[index].shelfStatus!.stockCount = "0"
            shelfText.text = parentVC.distributionCheckArray[index].shelfStatus!.stockCount ?? "0"
            shelfText.isEnabled = false
        }
        else {
            shelfText.isEnabled = true
        }
        parentVC.updateRightUI()
    }

    @objc func onChangeAisle(_ sender: Any) {
        let index = indexPath.row
        parentVC.distributionCheckArray[index].shelfStatus!.aisle = asileText.text!
    }

    @objc func onChangeShelf(_ sender: Any) {
        let index = indexPath.row
        parentVC.distributionCheckArray[index].shelfStatus!.stockCount = shelfText.text!
    }

    @objc func onChangeExpiry(_ sender: Any) {
        let index = indexPath.row
        parentVC.distributionCheckArray[index].shelfStatus!.expiry = expiryText.text!
    }

}

extension DistributionCheckCell: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == shelfText {

            switch string {
            case "0","1","2","3","4","5","6","7","8","9":
                return true
            case "":
                return true
            default:
                return false
            }
        }
        return true
    }
}
