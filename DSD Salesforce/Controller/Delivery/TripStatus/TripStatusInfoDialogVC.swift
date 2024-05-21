//
//  TripStatusInfoDialogVC.swift
//  DSDConnect
//
//  Created by iOS Developer on 3/17/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class TripStatusInfoDialogVC: UIViewController {

    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var middleButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!

    @IBOutlet weak var customerNameTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTopConstraint: NSLayoutConstraint!

    enum ReturnCode {
        case middle
        case left
        case right
    }

    var dismissHandler: ((ReturnCode) -> ())?
    var tripStatusInfo: TripStatusInfo?

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }

    func initUI() {
        middleButton.setTitleForAllState(title: L10n.ok())
        rightButton.setTitleForAllState(title: L10n.return())
        
        // Do any additional setup after loading the view.
        if tripStatusInfo != nil {
            customerNameLabel.text = tripStatusInfo!.customerName
            if tripStatusInfo!.status == "5" {
                leftButton.isHidden = false
                /*
                 if tripStatusInfo!.docNo == nil {
                 tripStatusInfo!.docNo = ""
                 }*/
                messageLabel.text = "Docket : \(tripStatusInfo!.docNo)\nValue : \(Double(tripStatusInfo!.transactionValue).moneyString)\nReceived By : \(tripStatusInfo!.receivedBy)"
            }
            else if tripStatusInfo!.status == "4" {
                leftButton.isHidden = true
                messageLabel.text = "Order : \(tripStatusInfo!.orderNumber)\n\(tripStatusInfo!.reference)"
            }
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
