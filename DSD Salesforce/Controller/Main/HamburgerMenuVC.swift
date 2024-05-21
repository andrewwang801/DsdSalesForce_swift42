//
//  HamburgerMenuVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/4/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class HamburgerMenuVC: UIViewController {

    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var menuTableViewHeightConstraint: NSLayoutConstraint!

    enum DismissOption {
        case dashboard
        case viewVehicleStock
        case adjustVehicleStock
        case countVehicleStock
        case deliveriesToday
        case deliveryTripStatus
        case marginCalculator
        case visitPlanner
        case productCatalog
        case help
        case about
        case signout
        case cancel
    }

    var menuTitleArray = [String]()

    let globalInfo = GlobalInfo.shared
    var dismissHandler: ((DismissOption)->())?
    var shouldDashboardEnabled = true

    let kMenuCellHeight: CGFloat = 35.0
    let kProductCatalogCellHeight: CGFloat = 35.0

    override func viewDidLoad() {
        super.viewDidLoad()

        initData()
        initUI()
    }

    func initData() {
        menuTitleArray = [kHamburgerDashboardName, kHamburgerVisitPlannerName, kHamburgerProductCatalog, kHamburgerMarginCalculator, "", 
                          kHamburgerViewVehicleStockName, kHamburgerAdjustVehicleStockName, kHamburgerCountVehicleStockName, kHamburgerDeliveryTripStatusName, kHamburgerDeliveriesTodayName]
        let vehicleInventory = globalInfo.routeControl?.vehicleInventory ?? "0"
        let vehicleInventoryCount = Int(vehicleInventory) ?? 0
        if vehicleInventoryCount == 0 {
            // remove show, adjust, count vehicle stock
            for (index, menuTitle) in menuTitleArray.enumerated() {
                if menuTitle == kHamburgerViewVehicleStockName {
                    menuTitleArray.remove(at: index)
                    break
                }
            }
            for (index, menuTitle) in menuTitleArray.enumerated() {
                if menuTitle == kHamburgerAdjustVehicleStockName {
                    menuTitleArray.remove(at: index)
                    break
                }
            }
            for (index, menuTitle) in menuTitleArray.enumerated() {
                if menuTitle == kHamburgerCountVehicleStockName {
                    menuTitleArray.remove(at: index)
                    break
                }
            }
        }

        let kpiArray = KPI.getAll(context: globalInfo.managedObjectContext)
        if kpiArray.count == 0 {
            shouldDashboardEnabled = false
        }
        else {
            shouldDashboardEnabled = true
        }
    }

    func initUI() {

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(HamburgerMenuVC.onTapMainView))
        self.view.addGestureRecognizer(tapRecognizer)

        menuTableView.backgroundColor = .clear
        menuTableView.backgroundView?.backgroundColor = .clear
        menuTableView.delegate = self
        menuTableView.dataSource = self

        menuTableViewHeightConstraint.constant = CGFloat(menuTitleArray.count-1)*kMenuCellHeight+kProductCatalogCellHeight
    }

    @objc func onTapMainView() {
        dismiss(animated: false) {
            self.dismissHandler?(.cancel)
        }
    }

    @objc func onTapMenu(_ sender: Any) {
        let button = sender as! UIButton
        let index = button.tag - 1000
        let menuTitle = menuTitleArray[index]

        if menuTitle == kHamburgerDashboardName {
            dismiss(animated: false) {
                self.dismissHandler?(.dashboard)
            }
        }
        else if menuTitle == kHamburgerViewVehicleStockName {
            dismiss(animated: false) {
                self.dismissHandler?(.viewVehicleStock)
            }
        }
        else if menuTitle == kHamburgerAdjustVehicleStockName {
            dismiss(animated: false) {
                self.dismissHandler?(.adjustVehicleStock)
            }
        }
        else if menuTitle == kHamburgerCountVehicleStockName {
            dismiss(animated: false) {
                self.dismissHandler?(.countVehicleStock)
            }
        }
        else if menuTitle == kHamburgerDeliveriesTodayName {
            dismiss(animated: false) {
                self.dismissHandler?(.deliveriesToday)
            }
        }
        else if menuTitle == kHamburgerMarginCalculator {
            dismiss(animated: false) {
                self.dismissHandler?(.marginCalculator)
            }
        }
        else if menuTitle == kHamburgerDeliveryTripStatusName {
            dismiss(animated: false) {
                self.dismissHandler?(.deliveryTripStatus)
            }
        }
        else if menuTitle == kHamburgerVisitPlannerName {
            dismiss(animated: false) {
                self.dismissHandler?(.visitPlanner)
            }
        }
        else if menuTitle == kHamburgerProductCatalog {
            dismiss(animated: false) {
                self.dismissHandler?(.productCatalog)
            }
        }
    }

    @IBAction func onHelp(_ sender: Any) {
        dismiss(animated: false) {
            self.dismissHandler?(.help)
        }
    }

    @IBAction func onAbout(_ sender: Any) {
        dismiss(animated: false) {
            self.dismissHandler?(.about)
        }
    }

    @IBAction func onSignout(_ sender: Any) {
        dismiss(animated: false) {
            self.dismissHandler?(.signout)
        }
    }

    @IBAction func onClose(_ sender: Any) {
        dismiss(animated: false) {
            self.dismissHandler?(.cancel)
        }
    }

}

extension HamburgerMenuVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuTitleArray.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let index = indexPath.row
        let menuTitle = menuTitleArray[index]

        if menuTitle == kHamburgerProductCatalog {
            return kProductCatalogCellHeight
        }
        else {
            return kMenuCellHeight
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let index = indexPath.row
        let menuTitle = menuTitleArray[index]

        if menuTitle == kHamburgerProductCatalog {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HamburgerProductCatalogCell", for: indexPath) as! HamburgerProductCatalogCell
            cell.backgroundView?.backgroundColor = .clear
            cell.backgroundColor = .clear
            cell.menuButton.setTitleForAllState(title: menuTitle)
            cell.menuButton.tag = index+1000
            cell.menuButton.addTarget(self, action: #selector(HamburgerMenuVC.onTapMenu(_:)), for: .touchUpInside)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HamburgerMenuCell", for: indexPath) as! HamburgerMenuCell
            cell.backgroundView?.backgroundColor = .clear
            cell.backgroundColor = .clear
            cell.menuButton.setTitleForAllState(title: menuTitle)
            cell.menuButton.tag = index+1000
            cell.menuButton.addTarget(self, action: #selector(HamburgerMenuVC.onTapMenu(_:)), for: .touchUpInside)

            if menuTitle == kHamburgerDashboardName {
                cell.menuButton.isEnabled = shouldDashboardEnabled
            }
            else {
                cell.menuButton.isEnabled = true
            }
            return cell
        }
    }

}
