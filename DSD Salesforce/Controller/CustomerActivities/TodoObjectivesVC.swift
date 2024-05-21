//
//  TodoObjectivesVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/9/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class TodoObjectivesVC: UIViewController {

    @IBOutlet weak var completeButton: AnimatableButton!
    @IBOutlet weak var notCompleteButton: AnimatableButton!
    @IBOutlet weak var partCompleteButton: AnimatableButton!

    var mainVC: MainVC!
    var customerDetail: CustomerDetail!
    var statusButtonArray = [AnimatableButton]()
    var selectedButtonIndex = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        statusButtonArray = [completeButton, notCompleteButton, partCompleteButton]
        for (index, button) in statusButtonArray.enumerated() {
            button.tag = 300+index
            button.addTarget(self, action: #selector(TodoObjectivesVC.onTapStatusButton(_:)), for: .touchUpInside)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainVC.setTitleBarText(title: "TO DO OBJECTIVES")
    }

    @objc func onTapStatusButton(_ sender: Any) {
        let button = sender as! UIButton
        let index = button.tag-300
        selectedButtonIndex = index
        for i in 0...2 {
            if selectedButtonIndex == i {
                statusButtonArray[i].isSelected = true
            }
            else {
                statusButtonArray[i].isSelected = false
            }
        }
    }

}
