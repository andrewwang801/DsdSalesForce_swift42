//
//  ChatContainerVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/20/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class ChatContainerVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var logoButton: UIButton!
    @IBOutlet weak var badgeLabel: AnimatableLabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setTitleBarText(title: "CHATTER")

        NotificationCenter.default.addObserver(self, selector: #selector(MainVC.updateChatBadge), name: NSNotification.Name(rawValue: kUpdateBadgeNotificationName), object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if (isBeingDismissed || isMovingFromParent) {
            NotificationCenter.default.removeObserver(self)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateChatBadge()
    }

    /*
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let notification = MPGNotification(title: "Greetings!", subtitle: "Did you know we have Notifications now?", backgroundColor: UIColor.red, iconImage: UIImage())
        notification?.animationType = .drop
        notification?.fullWidthMessages = true
        notification?.hostViewController = self
        notification?.show()
    }*/

    func setTitleBarText(title: String) {
        let attributedString = NSMutableAttributedString(string: title)
        let titleSpacing: CGFloat = 2.5
        attributedString.addAttributes([NSAttributedString.Key.kern: titleSpacing], range: NSMakeRange(0, title.length))
        titleLabel.attributedText = attributedString
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let chatMainVC = segue.destination as? ChatMainVC {
            chatMainVC.containerVC = self
        }
    }

    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    func updateChatBadge() {

        if Utils.dialogsManager != nil {
            let badgeNumber = Utils.dialogsManager?.getUnreadMessageCount() ?? 0
            if badgeNumber > 0 {
                badgeLabel.isHidden = false
            }
            else {
                badgeLabel.isHidden = true
            }
        }
        else {
            badgeLabel.isHidden = true
        }
    }

}
