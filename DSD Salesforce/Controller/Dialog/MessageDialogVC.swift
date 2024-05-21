//
//  MessageDialogVC.swift
//  DSDConnect
//
//  Created by iOS Developer on 3/17/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class MessageDialogVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var failedLabel: UILabel!
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var middleButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!

    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var failedTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var customerNameTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTopConstraint: NSLayoutConstraint!

    enum ReturnCode {
        case middle
        case left
        case right
    }

    var dismissHandler: ((ReturnCode) -> ())?

    var strMessage = ""
    var strTitle = ""
    var strLeft = ""
    var strMiddle = ""
    var strRight = ""
    var isFailed = false
    var strCustomerName = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
    }

    func initUI() {

        if strTitle.isEmpty == true {
            titleTopConstraint.constant = 0
        }
        else {
            titleTopConstraint.constant = 20
        }
        titleLabel.text = strTitle

        if isFailed == false {
            failedLabel.text = ""
            failedTopConstraint.constant = 0
        }
        else {
            failedLabel.text = L10n.failed()
            failedTopConstraint.constant = 10
        }

        if strCustomerName.isEmpty == true {
            customerNameTopConstraint.constant = 0
        }
        else {
            customerNameTopConstraint.constant = 10
        }
        customerNameLabel.text = strCustomerName
        messageLabel.text = strMessage

        if strMiddle.isEmpty == true {
            middleButton.isHidden = true
        }
        else {
            middleButton.isHidden = false
            middleButton.setTitleForAllState(title: strMiddle)
        }

        if strLeft.isEmpty == true {
            leftButton.isHidden = true
        }
        else {
            leftButton.isHidden = false
            leftButton.setTitleForAllState(title: strLeft)
        }

        if strRight.isEmpty == true {
            rightButton.isHidden = true
        }
        else {
            rightButton.isHidden = false
            rightButton.setTitleForAllState(title: strRight)
        }
    }

    @IBAction func onTapLeft(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?(.left)
        }
    }

    @IBAction func onTapMiddle(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?(.middle)
        }
    }

    @IBAction func onTapRight(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?(.right)
        }
    }

}
