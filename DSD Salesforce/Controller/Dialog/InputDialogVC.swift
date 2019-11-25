//
//  InputDialogVC.swift
//  DSDConnect
//
//  Created by iOS Developer on 3/17/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class InputDialogVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var middleButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var inputText: AnimatableTextField!
    @IBOutlet weak var inputContainerView: AnimatableView!

    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!

    enum ReturnCode {
        case middle
        case left
        case right
    }

    var dismissHandler: ((ReturnCode, String) -> ())?

    var strTitle = ""
    var strEnteredString = ""
    var strPlaceholder = ""
    var strLeft = ""
    var strMiddle = ""
    var strRight = ""

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
        inputText.placeholderText = strPlaceholder
        inputText.text = strEnteredString

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
            self.dismissHandler?(.left, self.inputText.text ?? "")
        }
    }

    @IBAction func onTapMiddle(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?(.middle, self.inputText.text ?? "")
        }
    }

    @IBAction func onTapRight(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?(.right, self.inputText.text ?? "")
        }
    }

}
