//
//  OpportunitiesVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/9/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class SelectCustomerOpportunitiesVC: UIViewController {

    @IBOutlet weak var productTableView: UITableView!
    @IBOutlet weak var customerTypeButton: AnimatableButton!
    @IBOutlet weak var postCodeTextField: AnimatableTextField!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var topProductsLabel: UILabel!
    @IBOutlet weak var inPostcodeLabel: UILabel!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var rankingLabel: UILabel!
    
    let globalInfo = GlobalInfo.shared
    var selectCustomerVC: SelectCustomerVC!
    var customerDescTypeArray = [DescType]()
    var customerOpportunityArray = [CustomerOpportunity]()

    var selectedCustomerDescType: DescType? {
        didSet {
            if selectedCustomerDescType == nil {
                customerTypeButton.setTitleForAllState(title: "")
                customerTypeButton.setTitleColor(kStoreTypeEmptyTextColor, for: .normal)
            }
            else {
                let typeString = selectedCustomerDescType?.desc ?? ""
                customerTypeButton.setTitleForAllState(title: typeString)
                customerTypeButton.setTitleColor(kStoreTypeNormalTextColor, for: .normal)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(SelectCustomerOpportunitiesVC.updateUI), name: NSNotification.Name(rawValue: kCustomerSelectedNotificationName), object: nil)

        initData()
        initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isBeingDismissed == true || isMovingFromParent == true {
            NotificationCenter.default.removeObserver(self)
        }
    }

    func initData() {
        // populate customer type
        let descTypeArray = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "CustomerType")
        customerDescTypeArray = descTypeArray.sorted(by: { (descType1, descType2) -> Bool in
            let desc1 = descType1.desc ?? ""
            let desc2 = descType2.desc ?? ""
            return desc1 < desc2
        })
        selectedCustomerDescType = customerDescTypeArray.first
    }

    func initUI() {
        customerTypeButton.setTitleForAllState(title: L10n.supermarkets())
        topProductsLabel.text = L10n.topProductsFromOther()
        inPostcodeLabel.text = L10n.inPostcode()
        itemLabel.text = L10n.item()
        rankingLabel.text = L10n.ranking()
        noDataLabel.text = L10n.thereIsNoData()
        
        postCodeTextField.delegate = self
        postCodeTextField.addTarget(self, action: #selector(SelectCustomerOpportunitiesVC.onPostCodeTextDidChanged), for: .editingChanged)

        productTableView.dataSource = self
        productTableView.delegate = self
    }

    func refreshProducts() {
        productTableView.reloadData()
        if customerOpportunityArray.count > 0 {
            noDataLabel.isHidden = true
        }
        else {
            noDataLabel.isHidden = false
        }
    }

    @objc func updateUI() {
        guard let customerDetail = selectCustomerVC.selectedCustomer else {return}
        // we need to select the customers type as default
        let type = customerDetail.type ?? ""
        for descType in customerDescTypeArray {
            if type == descType.alphaKey {
                selectedCustomerDescType = descType
                break
            }
        }

        // default postcode = 0
        postCodeTextField.text = "0"

        reload()
    }

    func reload() {
        guard let _ = selectCustomerVC.selectedCustomer else {return}

        updateOrderHistory()
    }

    @objc func onPostCodeTextDidChanged() {
        // reload()
    }

    func updateOrderHistory() {

        guard let selectedCustomer = selectCustomerVC.selectedCustomer else {return}

        let postCode = postCodeTextField.text ?? ""
        globalInfo.opportunityPostCode = postCode
        globalInfo.selectedCustomerTypeDescType = self.selectedCustomerDescType

        //let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow, animated: true)
        DispatchQueue.global().async {
            self.globalInfo.loadOpportunities(selectedCustomer: selectedCustomer)
            DispatchQueue.main.async {
                //hud?.hide(true)
                self.customerOpportunityArray = self.globalInfo.customerOpportunityArray
                self.refreshProducts()
            }
        }
    }

    @IBAction func onCustomerTypeButton(_ sender: Any) {

        let menuComboVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "MenuComboPopoverVC") as! MenuComboPopoverVC
        menuComboVC.modalPresentationStyle = .popover

        let senderButton = sender as! UIButton

        let menuNames = customerDescTypeArray.map { (descType) -> String in
            return descType.desc ?? ""
        }
        let menuItemCount = min(menuNames.count, 10)
        let totalHeight = kPopoverMenuCellHeight * CGFloat(menuItemCount)
        menuComboVC.preferredContentSize = CGSize(width: senderButton.bounds.width, height: totalHeight)
        menuComboVC.menuNamesArray = menuNames
        menuComboVC.dismissHandler = {vc, selectedIndex in
            let selectedDescType = self.customerDescTypeArray[selectedIndex]
            self.selectedCustomerDescType = selectedDescType
            self.reload()
        }

        let presentationPopoverVC = menuComboVC.popoverPresentationController
        presentationPopoverVC?.permittedArrowDirections = [.up]
        presentationPopoverVC?.delegate = self
        presentationPopoverVC?.sourceView = senderButton
        presentationPopoverVC?.sourceRect = senderButton.bounds
        presentationPopoverVC?.backgroundColor = kPopoverMenuBackgroundColor
        self.present(menuComboVC, animated: true, completion: nil)
    }

}

extension SelectCustomerOpportunitiesVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customerOpportunityArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OpportunitiesProductCell", for: indexPath) as! OpportunitiesProductCell
        cell.setupCell(parentVC: self, indexPath: indexPath)
        return cell
    }

}

extension SelectCustomerOpportunitiesVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }

}

extension SelectCustomerOpportunitiesVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension SelectCustomerOpportunitiesVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == postCodeTextField {
            textField.resignFirstResponder()
            reload()
            return false
        }
        return true
    }

}

