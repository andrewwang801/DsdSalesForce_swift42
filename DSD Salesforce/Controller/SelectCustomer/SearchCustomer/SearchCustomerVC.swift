//
//  SearchCustomerVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/31/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class SearchCustomerVC: UIViewController {

    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var salesDistrictTypeButton: UIButton!
    @IBOutlet weak var searchByButton: UIButton!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var customerTableView: UITableView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var salesDistrictLabel: UIButton!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var returnButton: AnimatableButton!
    @IBOutlet weak var addAllButton: AnimatableButton!
    
    enum SearchByType: Int {
        case customerName = 0
        case customerPostcode = 1
        case customerSuburb = 2
        case salesDistrict = 3
    }

    var isFromVisitPlanner = false
    var addingDate = Date()

    let globalInfo = GlobalInfo.shared
    var customerDetailArray = [CustomerDetail]()

    var salesDistrictDescTypeArray = [DescType]()
    let searchByTypeNameArray = ["Customer Name", L10n.customerPostcode(), "Customer Suburb", "Sales District"]

    var selectedSearchByType: SearchByType = .customerName {
        didSet {
            if selectedSearchByType == .salesDistrict {
                searchText.isHidden = true
                salesDistrictTypeButton.isHidden = false
            }
            else {
                searchText.isHidden = false
                salesDistrictTypeButton.isHidden = true
            }
            let index = selectedSearchByType.rawValue
            searchByButton.setTitleForAllState(title: searchByTypeNameArray[index])
        }
    }

    var selectedSalesDistrictDescType: DescType? {
        didSet {
            if selectedSalesDistrictDescType == nil {
                salesDistrictTypeButton.setTitleForAllState(title: "")
            }
            else {
                let desc = selectedSalesDistrictDescType!.desc ?? ""
                salesDistrictTypeButton.setTitleForAllState(title: desc)
            }
        }
    }

    var dismissHandler: (()->())?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
        initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reloadCustomers()
    }

    func initData() {
        let descTypeArray = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "SalesDistrict")
        let defLocNo = globalInfo.routeControl?.defLocNo ?? ""
        salesDistrictDescTypeArray = descTypeArray.filter({ (descType) -> Bool in
            let value1 = descType.value1 ?? ""
            if value1 == "" {
                return true
            }
            else {
                if value1 == defLocNo {
                    return true
                }
                else {
                    return false
                }
            }
        })
        //salesDistrictDescTypeArray.insert(nil, at: 0)

        selectedSearchByType = .customerName
        selectedSalesDistrictDescType = salesDistrictDescTypeArray.first

        reloadCustomers()
    }

    func initUI() {

        titleLabel.text = L10n.addCustomersToTrip()
        searchLabel.text = L10n.search()
        noDataLabel.text = L10n.thereIsNoData()
        returnButton.setTitleForAllState(title: L10n.Return1())
        addAllButton.setTitleForAllState(title: L10n.addAll())
        searchField.placeholder = L10n.pleaseEnterSearchKey()
        salesDistrictLabel.setTitleForAllState(title: L10n.salesDistrict())
        
        searchText.delegate = self
        searchText.addTarget(self, action: #selector(SearchCustomerVC.onSearchTextDidChanged), for: .editingChanged)
        searchText.returnKeyType = .done

        customerTableView.dataSource = self
        customerTableView.delegate = self
    }

    func reloadCustomers() {

        // reload customers
        customerDetailArray = []

        let searchKey = searchText.text ?? ""
        if selectedSearchByType != .salesDistrict {
            if searchKey.isEmpty == true {
                return
            }
        }

        // load customers
        if selectedSearchByType == .customerName {
            customerDetailArray = CustomerDetail.getBy(context: globalInfo.managedObjectContext, substringOfName: searchKey)
        }
        else if selectedSearchByType == .customerPostcode {
            customerDetailArray = CustomerDetail.getBy(context: globalInfo.managedObjectContext, substringOfZip: searchKey)
        }
        else if selectedSearchByType == .customerSuburb {
            customerDetailArray = CustomerDetail.getBy(context: globalInfo.managedObjectContext, substringOfCity: searchKey)
        }
        else if selectedSearchByType == .salesDistrict {
            let numericKey = selectedSalesDistrictDescType?.numericKey ?? ""
            customerDetailArray = CustomerDetail.getBy(context: globalInfo.managedObjectContext, salesDistrict: numericKey)
        }

        let dayNo = "\(Utils.getWeekday(date: addingDate))"
        let routeScheduleCustomers = CustomerDetail.getScheduled(context: globalInfo.managedObjectContext, dayNo: dayNo)

        customerDetailArray = customerDetailArray.filter({ (customerDetail) -> Bool in

            if customerDetail.isVisitPlanned == true {
                return false
            }
            if customerDetail.isRouteScheduled == true {
                return false
            }
            /*
            if customerDetail.isRouteScheduled == true && customerDetail.dayNo == dayNo {
                return false
            }*/
            var isAlreadyAdded = false
            for routeScheduleCustomer in routeScheduleCustomers {
                if routeScheduleCustomer.custNo == customerDetail.custNo && routeScheduleCustomer.chainNo == customerDetail.chainNo {
                    isAlreadyAdded = true
                    break
                }
            }
            if isAlreadyAdded == true {
                return false
            }
            return true
        })

        customerDetailArray = customerDetailArray.sorted(by: { (detail1, detail2) -> Bool in
            let title1 = detail1.getCustomerTitle().lowercased()
            let title2 = detail2.getCustomerTitle().lowercased()
            return title1 < title2
        })

        refreshCustomers()
    }

    func refreshCustomers() {
        customerTableView.reloadData()
        if customerDetailArray.count == 0 {
            noDataLabel.isHidden = false
        }
        else {
            noDataLabel.isHidden = true
        }
    }

    func addCustomer(index: Int) {

        // resort previous customers
        let dayNo = "\(Utils.getWeekday(date: addingDate))"
        let routeScheduleCustomers = CustomerDetail.getScheduled(context: globalInfo.managedObjectContext, dayNo: dayNo)
        for customer in routeScheduleCustomers {
            if customer.isFromSameNextVisit == true {
                continue
            }
            let originalSeqNo = Int(customer.seqNo ?? "") ?? 0
            customer.seqNo = "\(originalSeqNo+1)"
        }

        let customerDetail = customerDetailArray[index]

        let newCustomerDetail = CustomerDetail(context: globalInfo.managedObjectContext, forSave: true)
        newCustomerDetail.updateBy(theSource: customerDetail)

        newCustomerDetail.seqNo = "0"
        newCustomerDetail.isRouteScheduled = true
        newCustomerDetail.dayNo = dayNo
        newCustomerDetail.deliveryDate = addingDate.toDateString(format: kTightJustDateFormat)

        newCustomerDetail.isVisitPlanned = true

        GlobalInfo.saveCache()
        reloadCustomers()
    }

    func addAllCustomers() {

        let dayNo = "\(Utils.getWeekday(date: addingDate))"
        let routeScheduleCustomers = CustomerDetail.getScheduled(context: globalInfo.managedObjectContext, dayNo: dayNo)

        let addedCustomerCount = routeScheduleCustomers.count
        for customer in customerDetailArray {
            if customer.isFromSameNextVisit == true {
                continue
            }
            let seqNo = Int(customer.seqNo ?? "") ?? 0
            let newSeqNo = seqNo+addedCustomerCount
            customer.seqNo = "\(newSeqNo)"
        }

        for (index, customer) in customerDetailArray.enumerated() {
            let newCustomer = CustomerDetail(context: globalInfo.managedObjectContext, forSave: true)
            newCustomer.updateBy(theSource: customer)

            newCustomer.seqNo = "\(index)"
            newCustomer.isRouteScheduled = true
            newCustomer.dayNo = dayNo
            newCustomer.deliveryDate = addingDate.toDateString(format: kTightJustDateFormat)

            newCustomer.isVisitPlanned = true
        }

        GlobalInfo.saveCache()

        self.dismiss(animated: true) {
            self.dismissHandler?()
        }
    }

    @objc func onSearchTextDidChanged() {
        reloadCustomers()
    }

    @IBAction func onSalesDistrict(_ sender: Any) {

        let menuComboVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "MenuComboPopoverVC") as! MenuComboPopoverVC
        menuComboVC.modalPresentationStyle = .popover

        let senderButton = sender as! UIButton

        let menuNames = salesDistrictDescTypeArray.map { (descType) -> String in
            return descType.desc ?? ""
        }
        let menuItemCount = min(menuNames.count, 10)
        let totalHeight = 40.0 * CGFloat(menuItemCount)
        menuComboVC.preferredContentSize = CGSize(width: senderButton.bounds.width, height: totalHeight)
        menuComboVC.cellHeight = 40.0
        menuComboVC.menuNamesArray = menuNames
        menuComboVC.dismissHandler = {vc, selectedIndex in
            self.selectedSalesDistrictDescType = self.salesDistrictDescTypeArray[selectedIndex]
            self.reloadCustomers()
        }

        let presentationPopoverVC = menuComboVC.popoverPresentationController
        presentationPopoverVC?.permittedArrowDirections = [.up]
        presentationPopoverVC?.delegate = self
        presentationPopoverVC?.sourceView = senderButton
        presentationPopoverVC?.sourceRect = senderButton.bounds
        presentationPopoverVC?.backgroundColor = kPopoverMenuBackgroundColor
        self.present(menuComboVC, animated: true, completion: nil)
    }

    @IBAction func onSearchBy(_ sender: Any) {

        let menuComboVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "MenuComboPopoverVC") as! MenuComboPopoverVC
        menuComboVC.modalPresentationStyle = .popover

        let senderButton = sender as! UIButton

        let menuNames = searchByTypeNameArray
        let menuItemCount = min(menuNames.count, 10)
        let totalHeight = 40.0 * CGFloat(menuItemCount)
        menuComboVC.preferredContentSize = CGSize(width: senderButton.bounds.width, height: totalHeight)
        menuComboVC.cellHeight = 40.0
        menuComboVC.menuNamesArray = menuNames
        menuComboVC.dismissHandler = {vc, selectedIndex in
            self.selectedSearchByType = SearchByType(rawValue: selectedIndex)!
            self.reloadCustomers()
        }

        let presentationPopoverVC = menuComboVC.popoverPresentationController
        presentationPopoverVC?.permittedArrowDirections = [.up]
        presentationPopoverVC?.delegate = self
        presentationPopoverVC?.sourceView = senderButton
        presentationPopoverVC?.sourceRect = senderButton.bounds
        presentationPopoverVC?.backgroundColor = kPopoverMenuBackgroundColor
        self.present(menuComboVC, animated: true, completion: nil)
    }

    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?()
        }
    }

    @IBAction func onAddAll(_ sender: Any) {

        let addingCustomerCount = customerDetailArray.count
        if addingCustomerCount == 0 {
            return
        }
        Utils.showAlert(vc: self, title: "", message: "\(L10n.aboutToAdd()) \(addingCustomerCount) \(L10n.customersToYourTrip())", failed: false, customerName: "", leftString: L10n.return(), middleString: "", rightString: L10n.proceed()) { (returnCode) in
            if returnCode == .right {
                self.addAllCustomers()
            }
        }
    }
}

extension SearchCustomerVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customerDetailArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCustomerCell", for: indexPath) as! SearchCustomerCell
        cell.setupCell(parentVC: self, indexPath: indexPath)
        return cell
    }

}

extension SearchCustomerVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }

}

extension SearchCustomerVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchText {
            searchText.resignFirstResponder()
            reloadCustomers()
            return false
        }
        return true
    }

}

extension SearchCustomerVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
