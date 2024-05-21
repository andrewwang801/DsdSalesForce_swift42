//
//  SearchProductVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 8/22/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class SearchProductVC: UIViewController {

    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var searchByButton: UIButton!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var productTableView: UITableView!

    enum SearchByType: Int {
        case productName = 0
        case itemType = 1
        case productGroup = 2
        case productLine = 3
        case brand = 4
        case subBrand = 5
    }

    enum DismissOption {
        case cancelled
        case added
    }

    let globalInfo = GlobalInfo.shared
    var customerDetail: CustomerDetail!
    var productDetailArray = [ProductDetail]()
    var searchedArray = [ProductDetail]()

    let searchByTypeNameArray = ["Product Name", "Item Type", "Product Group", "Product Line", "Brand", "Sub Brand"]
    var selectedSearchByType: SearchByType = .productName {
        didSet {
            let index = selectedSearchByType.rawValue
            searchByButton.setTitleForAllState(title: searchByTypeNameArray[index])
            reloadProducts()
        }
    }

    // for tree
    var authHeader: AuthHeader?
    var authDetailArray = [AuthDetail]()
    var authItemDictionary = [String: AuthDetail]()
    var isEnableFilterAuthorizedItem = false

    // added selected result
    var selectedType = 0
    var selectedItemNo = ""

    var dismissHandler: ((SearchProductVC, DismissOption)->())?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
        initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reloadProducts()
    }

    func initData() {
        // load auth header
        let authGrp = customerDetail.authGrp ?? ""
        if isEnableFilterAuthorizedItem == true && authGrp.isEmpty == false {
            authHeader = AuthHeader.getBy(context: globalInfo.managedObjectContext, authGrp: authGrp).first
            if authHeader != nil {
                authDetailArray = AuthDetail.getBy(context: globalInfo.managedObjectContext, authGrp: authHeader!.authGrp ?? "")
                authItemDictionary = [:]
                for authDetil in authDetailArray {
                    authItemDictionary[authDetil.itemNo ?? ""] = authDetil
                }
            }
        }

        let managedObjectContext = globalInfo.managedObjectContext!
        let prodDetailArray = ProductDetail.getAll(context: managedObjectContext)

        for prodDetail in prodDetailArray {
            prodDetail.desc1 = DescType.getBy(context: managedObjectContext, descTypeID: "ITEMTYPE", alphaKey: prodDetail.itemType ?? "")?.desc ?? ""
            prodDetail.desc2 = DescType.getBy(context: managedObjectContext, descTypeID: "PRODGROUP", alphaKey: prodDetail.prodGrp ?? "")?.desc ?? ""
            prodDetail.desc3 = DescType.getBy(context: managedObjectContext, descTypeID: "PRODLINE", alphaKey: prodDetail.prodLine ?? "")?.desc ?? ""
            prodDetail.desc4 = DescType.getBy(context: managedObjectContext, descTypeID: "BRAND", alphaKey: prodDetail.brand ?? "")?.desc ?? ""
            prodDetail.desc5 = DescType.getBy(context: managedObjectContext, descTypeID: "SUBBRAND", alphaKey: prodDetail.subBrand ?? "")?.desc ?? ""
        }

        productDetailArray.removeAll()
        if isEnableFilterAuthorizedItem == true && authHeader != nil {
            for prodDetail in prodDetailArray {
                if isAuthorizedItem(itemNo: prodDetail.itemNo ?? "") == true {
                    productDetailArray.append(prodDetail)
                }
            }
        }
        else {
            productDetailArray.append(contentsOf: prodDetailArray)
        }

        reloadProducts()
    }

    func initUI() {

        searchText.delegate = self
        searchText.addTarget(self, action: #selector(SearchProductVC.onSearchTextDidChanged), for: .editingChanged)
        searchText.returnKeyType = .done

        productTableView.dataSource = self
        productTableView.delegate = self
    }

    func reloadProducts() {

        // reload customers
        //productDetailArray = []

        let searchKey = (searchText.text ?? "").lowercased()
        /*
        if searchKey.isEmpty == true {
            return
        }*/
        searchedArray.removeAll()
        for productDetail in productDetailArray {
            if searchKey.isEmpty == true {
                searchedArray.append(productDetail)
                continue
            }
            if selectedSearchByType == .productName {
                let desc = (productDetail.desc ?? "").lowercased()
                if desc.contains(searchKey) == true {
                    searchedArray.append(productDetail)
                }
            }
            else if selectedSearchByType == .itemType {
                let desc1 = (productDetail.desc1 ?? "").lowercased()
                if desc1.contains(searchKey) == true {
                    searchedArray.append(productDetail)
                }
            }
            else if selectedSearchByType == .productGroup {
                let desc2 = (productDetail.desc2 ?? "").lowercased()
                if desc2.contains(searchKey) == true {
                    searchedArray.append(productDetail)
                }
            }
            else if selectedSearchByType == .productLine {
                let desc3 = (productDetail.desc3 ?? "").lowercased()
                if desc3.contains(searchKey) == true {
                    searchedArray.append(productDetail)
                }
            }
            else if selectedSearchByType == .brand {
                let desc4 = (productDetail.desc4 ?? "").lowercased()
                if desc4.contains(searchKey) == true {
                    searchedArray.append(productDetail)
                }
            }
            else if selectedSearchByType == .subBrand {
                let desc5 = (productDetail.desc5 ?? "").lowercased()
                if desc5.contains(searchKey) == true {
                    searchedArray.append(productDetail)
                }
            }

        }

        searchedArray = searchedArray.sorted(by: { (productDetail1, productDetail2) -> Bool in
            let desc1 = productDetail1.desc ?? ""
            let desc2 = productDetail2.desc ?? ""
            return desc1 < desc2
        })

        refreshProducts()
    }

    func refreshProducts() {
        productTableView.reloadData()
        if searchedArray.count == 0 {
            noDataLabel.isHidden = false
        }
        else {
            noDataLabel.isHidden = true
        }
    }

    func addProduct(index: Int) {

        let product = searchedArray[index]
        let itemNo = product.itemNo ?? ""
        selectedItemNo = itemNo
        selectedType = kSelectProductItemNo
        self.dismiss(animated: true) {
            self.dismissHandler?(self, .added)
        }
    }

    @objc func onSearchTextDidChanged() {
        reloadProducts()
    }

    func isAuthorizedItem(itemNo: String) -> Bool {

        if authHeader == nil {
            return true
        }

        let authType = authHeader!.authType ?? ""
        if authType == "A" {
            let authDetail = authItemDictionary[itemNo]
            if authDetail != nil {
                return true
            }
            else {
                return false
            }
        }
        else if authType == "U" {
            let authDetail = authItemDictionary[itemNo]
            if authDetail != nil {
                return false
            }
            else {
                return true
            }
        }
        else {
            return true
        }
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
            self.dismissHandler?(self, .cancelled)
        }
    }

}

extension SearchProductVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchProductCell", for: indexPath) as! SearchProductCell
        cell.setupCell(parentVC: self, indexPath: indexPath)
        return cell
    }

}

extension SearchProductVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}

extension SearchProductVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchText {
            searchText.resignFirstResponder()
            reloadProducts()
            return false
        }
        return true
    }

}

extension SearchProductVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
