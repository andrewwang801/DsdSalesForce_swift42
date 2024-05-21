//
//  InputDialogVC.swift
//  DSDConnect
//
//  Created by iOS Developer on 3/17/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class DropDownDialogVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var middleButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var dropDownButton: AnimatableButton!

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
        initDropDownData()
    }

    var dropDown = DropDown()
    var selectedItem: String = ""
    var dropDownArray: [String] = []
    var dropDownDic: [String: String] = [:]
    
    func initDropDownData() {
        dropDown.cellHeight = dropDownButton.bounds.height
        dropDown.anchorView = dropDownButton
        dropDown.bottomOffset = CGPoint(x: 0, y: dropDownButton.bounds.height)
        dropDown.backgroundColor = .white
        dropDown.textFont = dropDownButton.titleLabel!.font
        dropDown.dataSource = dropDownArray
        dropDown.selectRow(0)
        dropDownButton.setTitleForAllState(title: dropDownArray[0])
        self.selectedItem = self.dropDownDic[self.dropDownArray[0]] ?? ""
        dropDown.cellNib = UINib(nibName: "GeneralDropDownCell", bundle: nil)
        dropDown.customCellConfiguration = {_index, item, cell in
        }
        dropDown.selectionAction = { index, item in
            self.selectedItem = self.dropDownDic[self.dropDownArray[index]] ?? ""
            self.dropDownButton.setTitleForAllState(title: self.dropDownArray[index])
        }
    }
    
    @IBAction func onVisitTime(_ sender: Any) {
        dropDown.show()
    }
    
    @IBAction func onTapLeft(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?(.left, self.selectedItem)
        }
    }

    @IBAction func onTapMiddle(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?(.middle, self.selectedItem)
        }
    }

    @IBAction func onTapRight(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?(.right, self.selectedItem)
        }
    }

}
