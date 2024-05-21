//
//  AboutVC.swift
//  DSDConnect
//
//  Created by iOS Developer on 3/15/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import SafariServices
import MessageUI

class AboutVC: UIViewController {

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var companyWebButton: UIButton!
    @IBOutlet weak var companyEmailButton: UIButton!
    @IBOutlet weak var companyPhone1Button: UIButton!
    @IBOutlet weak var companyPhone2Button: UIButton!
    @IBOutlet weak var phone1HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var phone2HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var companyInfoLabel: UILabel!

    @IBOutlet weak var designedByLabel: UILabel!
    @IBOutlet weak var termsLabel: UILabel!
    
    @IBOutlet weak var exitButton: UIButton!
    
    let globalInfo = GlobalInfo.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
    }

    override func viewWillAppear(_ animated: Bool) {

        loadContact()
    }

    func loadContact() {

        let contact = CompanyContact.getAll(context: globalInfo.managedObjectContext).first

        self.companyNameLabel.text = contact?.companyName ?? ""
        self.companyWebButton.setTitleForAllState(title: contact?.companyWeb ?? "")
        self.companyEmailButton.setTitleForAllState(title: contact?.companyEmail ?? "")
        self.companyPhone1Button.setTitleForAllState(title: contact?.companyPhone1 ?? "")
        self.companyPhone2Button.setTitleForAllState(title: contact?.companyPhone2 ?? "")
        self.companyInfoLabel.text = contact?.companyInfo ?? ""

        let phone1 = contact?.companyPhone1 ?? ""
        if phone1 == "" {
            self.phone1HeightConstraint.constant = 0
        }
        else {
            self.phone1HeightConstraint.constant = 35
        }

        let phone2 = contact?.companyPhone2 ?? ""
        if phone2 == "" {
            self.phone2HeightConstraint.constant = 0
        }
        else {
            self.phone2HeightConstraint.constant = 35
        }
    }

    func initUI() {
        
        designedByLabel.text = L10n.dsdConnectIsDesignedBy()
        termsLabel.text = L10n.termsOfUseAndPricacyAreGovernedByTheAgreementBetweenNumericComputerSystemsAndTheClientAndOurPoliciesMadeAvailableToTheClientAndAsMayBeAmendedFromTimeToTime()
        exitButton.setTitleForAllState(title: L10n.exit())
        
        // app version
        let version = Utility.getAppVersion()
        versionLabel.text = version
    }

    @IBAction func onWebButton(_ sender: Any) {
        let companyWeb = companyWebButton.titleLabel?.text ?? ""
        if companyWeb == "" {
            return
        }
        if let url = URL(string: "https://"+companyWeb) {
            let webVC = SFSafariViewController(url: url)
            webVC.setFullScreenPresentation()
            self.present(webVC, animated: true, completion: nil)
        }
    }

    @IBAction func onEmailButton(_ sender: Any) {
        let companyEmail = companyEmailButton.titleLabel?.text ?? ""
        if MFMailComposeViewController.canSendMail() == true {
            let picker = MFMailComposeViewController()
            picker.mailComposeDelegate = self
            picker.setSubject("")
            picker.setToRecipients([companyEmail])
            picker.setMessageBody("", isHTML: false)

            present(picker, animated: true, completion: nil)
        }
        else {
            SVProgressHUD.showInfo(withStatus: "Can't send email.")
        }
    }

    @IBAction func onPhone1Button(_ sender: Any) {
        let companyPhone1 = companyPhone1Button.titleLabel?.text ?? ""
        Utility.call(phoneNumber: companyPhone1)
    }

    @IBAction func onPhone2Button(_ sender: Any) {
        let companyPhone2 = companyPhone2Button.titleLabel?.text ?? ""
        Utility.call(phoneNumber: companyPhone2)
    }

    @IBAction func onExit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension AboutVC: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if result == .sent {
            SVProgressHUD.showInfo(withStatus: "Email sent")
        }
        controller.dismiss(animated: true, completion: nil)
    }
}
