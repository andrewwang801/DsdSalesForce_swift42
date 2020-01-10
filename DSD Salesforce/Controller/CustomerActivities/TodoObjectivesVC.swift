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

    @IBOutlet weak var objective: UILabel!
    @IBOutlet weak var setBy: UILabel!
    @IBOutlet weak var dueBy: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var createNewObjective: AnimatableButton!
    @IBOutlet weak var createNewObjectiveForSomeone: AnimatableButton!
    
    var mainVC: MainVC!
    var customerDetail: CustomerDetail!
    var statusButtonArray = [AnimatableButton]()
    var selectedButtonIndex = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        // Do any additional setup after loading the view.
        statusButtonArray = [completeButton, notCompleteButton, partCompleteButton]
        for (index, button) in statusButtonArray.enumerated() {
            button.tag = 300+index
            button.addTarget(self, action: #selector(TodoObjectivesVC.onTapStatusButton(_:)), for: .touchUpInside)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        mainVC.setTitleBarText(title: "TO DO OBJECTIVES")
        mainVC.setTitleBarText(title: L10n.toDoObjectives())
    }
    
    func initUI() {
        objective.text = L10n.objective()
        setBy.text = L10n.setBy()
        dueBy.text = L10n.dueBy()
        details.text = L10n.Details()
        status.text = L10n.Status()
        createNewObjective.setTitleForAllState(title: L10n.createNewObjectiveForNextVisit())
        createNewObjectiveForSomeone.setTitleForAllState(title: L10n.createNewObjectiveForSomeoneElse())
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
