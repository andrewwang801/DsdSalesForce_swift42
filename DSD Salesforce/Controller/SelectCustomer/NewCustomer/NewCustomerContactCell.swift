//
//  NewCustomerContactCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 8/1/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class NewCustomerContactCell: UITableViewCell {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var nameText: AnimatableTextField!
    @IBOutlet weak var emailText: AnimatableTextField!
    @IBOutlet weak var phoneText: AnimatableTextField!
    @IBOutlet weak var nameTopConstraint: NSLayoutConstraint!

    var parentVC: NewCustomerVC!
    var indexPath: IndexPath!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nameText.addTarget(self, action: #selector(NewCustomerContactCell.onNameTextChanged(_:)), for: .editingChanged)
        emailText.addTarget(self, action: #selector(NewCustomerContactCell.onEmailTextChanged(_:)), for: .editingChanged)
        phoneText.addTarget(self, action: #selector(NewCustomerContactCell.onPhoneTextChanged(_:)), for: .editingChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell(parentVC: NewCustomerVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath
        configCell()
    }

    func configCell() {
        let index = indexPath.row
        let contact = parentVC.customerContactArray[index]
        selectionStyle = .none
        backgroundView?.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        nameText.text = contact.contactName ?? ""
        emailText.text = contact.contactEmailAddress ?? ""
        phoneText.text = contact.contactPhoneNumber ?? ""

        if parentVC.originalCustomerDetail == nil {
            nameTopConstraint.constant = 0
            typeLabel.text = ""
        }
        else {
            nameTopConstraint.constant = kNewCustomerContactTypeHeight
            typeLabel.text = contact.contactTypeDesc ?? ""
        }
    }

    @objc func onNameTextChanged(_ sender: Any) {
        let index = indexPath.row
        parentVC.customerContactArray[index].contactName = nameText.text ?? ""
    }

    @objc func onEmailTextChanged(_ sender: Any) {
        let index = indexPath.row
        parentVC.customerContactArray[index].contactEmailAddress = emailText.text ?? ""
    }

    @objc func onPhoneTextChanged(_ sender: Any) {
        let index = indexPath.row
        parentVC.customerContactArray[index].contactPhoneNumber = phoneText.text ?? ""
    }

}
