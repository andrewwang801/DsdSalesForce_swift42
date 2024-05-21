//
//  MainVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/4/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import SafariServices

class MainVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var logoButton: UIButton!
    @IBOutlet weak var badgeLabel: AnimatableLabel!

    let globalInfo = GlobalInfo.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(MainVC.updateChatBadge), name: NSNotification.Name(rawValue: kUpdateBadgeNotificationName), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainVC.onChangedChatService), name: NSNotification.Name(rawValue: kChatServiceChangedNotificationName), object: nil)
        
        // upload postponed objects
        scheduleUploadPostponed()
        
        globalInfo.uploadManager.startIfNeeded()
        
        let gpsLoggerInterval = (Double(globalInfo.routeControl?.gpsPoll ?? "0") ?? 0) * 60
        globalInfo.gpsLogger.startLogger(interval: gpsLoggerInterval)

        logoButton.isEnabled = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if (isBeingDismissed || isMovingFromParent) {
            NotificationCenter.default.removeObserver(self)
        }
    }

    var isFirstAppear = true
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateChatBadge()

        if isFirstAppear == true {
            let kpiArray = KPI.getAll(context: globalInfo.managedObjectContext)
            if kpiArray.count == 0 {
                let selectCustomerVC = UIViewController.getViewController(storyboardName: "SelectCustomer", storyboardID: "SelectCustomerVC") as! SelectCustomerVC
                selectCustomerVC.mainVC = self
                self.changeChild(newVC: selectCustomerVC, containerView: containerView, isRemovePrevious: true)
            }
        }
        isFirstAppear = false
    }
    
    func scheduleUploadPostponed() {
        let allOrderHeaders = OrderHeader.getAll(context: globalInfo.managedObjectContext)
        let postponedHeaders = allOrderHeaders.filter { (orderHeader) -> Bool in
            return orderHeader.isSaved == true && orderHeader.isPostponed == true
        }
        for orderHeader in postponedHeaders {
            orderHeader.scheduleUpload()
        }
    }

    func setTitleBarText(title: String) {
        let attributedString = NSMutableAttributedString(string: title)
        let titleSpacing: CGFloat = 2.5
        attributedString.addAttributes([NSAttributedString.Key.kern: titleSpacing], range: NSMakeRange(0, title.length))
        titleLabel.attributedText = attributedString
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dashboardVC = segue.destination as? DashboardVC {
            dashboardVC.mainVC = self
        }
    }

    @IBAction func onHamburger(_ sender: Any) {
        let hamburgerMenuVC = UIViewController.getViewController(storyboardName: "Main", storyboardID: "HamburgerMenuVC") as! HamburgerMenuVC
        hamburgerMenuVC.setDefaultModalPresentationStyle()
        hamburgerMenuVC.dismissHandler = { dismissOption in

            if dismissOption == .dashboard {
                let dashboardVC = UIViewController.getViewController(storyboardName: "Main", storyboardID: "DashboardVC") as! DashboardVC
                dashboardVC.mainVC = self
                self.cycleChild(newVC: dashboardVC, containerView: self.containerView, isLeftSlide: true, isRemovePrevious: true)
            }
            else if dismissOption == .deliveriesToday {
                let todaysDeliveriesVC = UIViewController.getViewController(storyboardName: "Delivery", storyboardID: "TodaysDeliveriesVC") as! TodaysDeliveriesVC
                todaysDeliveriesVC.mainVC = self
                self.pushChild(newVC: todaysDeliveriesVC, containerView: self.containerView)
                //self.cycleChild(newVC: todaysDeliveriesVC, containerView: self.containerView, isLeftSlide: true, isRemovePrevious: true)
            }
            else if dismissOption == .deliveryTripStatus {
                let tripStatusVC = UIViewController.getViewController(storyboardName: "Delivery", storyboardID: "TripStatusVC") as! TripStatusVC
                tripStatusVC.mainVC = self
                self.pushChild(newVC: tripStatusVC, containerView: self.containerView)
                //self.cycleChild(newVC: tripStatusVC, containerView: self.containerView, isLeftSlide: true, isRemovePrevious: true)
            }
            else if dismissOption == .visitPlanner {
                let visitPlannerVC = UIViewController.getViewController(storyboardName: "VisitPlanner", storyboardID: "VisitPlannerVC") as! VisitPlannerVC
                visitPlannerVC.mainVC = self
                self.pushChild(newVC: visitPlannerVC, containerView: self.containerView)
            }
            else if dismissOption == .productCatalog {
                let productCatalogVC = UIViewController.getViewController(storyboardName: "ProductCatalog", storyboardID: "ProductCatalogVC") as! ProductCatalogVC
                productCatalogVC.mainVC = self
                productCatalogVC.orderVC = nil
                productCatalogVC.customerDetail = nil
                self.pushChild(newVC: productCatalogVC, containerView: self.containerView)
            }
            else if dismissOption == .help {
                // help
                if let url = URL(string: "https://support.dsdassist.com/portal/") {
                    let helpVC = SFSafariViewController(url: url)
                    helpVC.setFullScreenPresentation()
                    self.present(helpVC, animated: true, completion: nil)
                }
            }
            else if dismissOption == .signout {
                // sign out
                self.globalInfo.gpsLogger.stopLogger()
                let loginVC = UIViewController.getViewController(storyboardName: "Main", storyboardID: "LoginVC") as! LoginVC
                loginVC.setAsRoot()
            }
            else if dismissOption == .about {
                // about
                let aboutVC = UIViewController.getViewController(storyboardName: "Main", storyboardID: "AboutVC") as! AboutVC
                aboutVC.setDefaultModalPresentationStyle()
                self.present(aboutVC, animated: true, completion: nil)
            }
        }
        self.present(hamburgerMenuVC, animated: false, completion: nil)
    }

    @IBAction func onLogo(_ sender: Any) {
        let chatContainerVC = UIViewController.getViewController(storyboardName: "Chat", storyboardID: "ChatContainerVC") as! ChatContainerVC
        chatContainerVC.setFullScreenPresentation()
        self.present(chatContainerVC, animated: true, completion: nil)
    }

    @objc func updateChatBadge() {

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

    @objc func onChangedChatService() {
         logoButton.isEnabled = Utils.isExistChatService()
    }
}
