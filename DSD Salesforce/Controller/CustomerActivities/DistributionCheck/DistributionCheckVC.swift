//
//  DistributionCheckVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/7/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class DistributionCheckVC: UIViewController {

    @IBOutlet weak var checkTableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var categorySortButton: AnimatableButton!
    @IBOutlet weak var aisleSortButton: AnimatableButton!
    @IBOutlet weak var onShelfSortButton: AnimatableButton!
    @IBOutlet weak var perfectStoreRatingsLabel: UILabel!
    @IBOutlet weak var totalItemsInListLabel: UILabel!
    @IBOutlet weak var totalItemsAvailableLabel: UILabel!
    
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var aisleLabel: UILabel!
    @IBOutlet weak var onShelfButton: AnimatableButton!
    @IBOutlet weak var shelfLabel: UILabel!
    @IBOutlet weak var expiryLabel: UILabel!
    @IBOutlet weak var perfectStoreRatingsTitleLabel: UILabel!
    @IBOutlet weak var totalItemsInListTitleLabel: UILabel!
    @IBOutlet weak var totalItemsAvailableTitleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    enum SortType: Int {
        case category
        case aisle
        case onShelf
    }

    enum SortOrder: Int {
        case ascending
        case descending
    }

    let globalInfo = GlobalInfo.shared
    var mainVC: MainVC!
    var customerDetail: CustomerDetail!
    var originalShelfStatusArray = [ShelfStatus]()
    var sortTypeButtonArray = [AnimatableButton]()

    var itemDictionary = [String: DistributionCheck]()

    let sortAscendingImage = UIImage(named: "Sort_Ascending_Arrow")
    let sortDescendingImage = UIImage(named: "Sort_Descending_Arrow")

    var selectedSortType: SortType = .category {
        didSet {
            updateSortButtonUI()
        }
    }
    var selectedSortOrder: SortOrder = .ascending {
        didSet {
            updateSortButtonUI()
        }
    }

    var distributionCheckArray = [DistributionCheck]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sortTypeButtonArray = [categorySortButton, aisleSortButton, onShelfSortButton]

        initData()
        initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainVC.setTitleBarText(title: "DISTRIBUTION CHECK")
        refreshCheck()
        updateRightUI()
    }

    func initData() {

        let chainNo = customerDetail.chainNo ?? ""
        let custNo = customerDetail.custNo ?? ""
        originalShelfStatusArray = ShelfStatus.getBy(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo)

        itemDictionary.removeAll()

        distributionCheckArray.removeAll()
        for originalShelfStatus in originalShelfStatusArray {
            let shelfStatus = ShelfStatus(context: globalInfo.managedObjectContext, forSave: false)
            shelfStatus.updateBy(theSource: originalShelfStatus)
            if shelfStatus.isOnShelf == false {
                shelfStatus.stockCount = "0"
            }

            let itemNo = shelfStatus.itemNo ?? "0"
            guard let productDetail = ProductDetail.getBy(context: globalInfo.managedObjectContext, itemNo: itemNo) else {continue}

            // get the category
            let prodGroup = productDetail.prodGrp ?? ""
            let descType = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "PRODGROUP", alphaKey: prodGroup)

            let distributionCheck = DistributionCheck()
            distributionCheck.category = descType?.desc ?? ""
            distributionCheck.originalShelfStatus = originalShelfStatus
            distributionCheck.shelfStatus = shelfStatus
            distributionCheck.productDetail = productDetail
            distributionCheckArray.append(distributionCheck)

            itemDictionary[itemNo] = distributionCheck
        }

        // add order history product detail
        let orderHistoryArray = OrderHistory.getBy(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo)
        for orderHistory in orderHistoryArray {

            let itemNo = orderHistory.itemNo ?? "0"
            if itemDictionary[itemNo] != nil {
                continue
            }

            let shelfStatus = ShelfStatus(context: globalInfo.managedObjectContext, forSave: false)
            shelfStatus.aisle = ""
            shelfStatus.oos = ""
            shelfStatus.stockCount = "0"
            shelfStatus.expiry = ""
            shelfStatus.itemNo = itemNo

            guard let productDetail = ProductDetail.getBy(context: globalInfo.managedObjectContext, itemNo: itemNo) else {return}

            // get the category
            let prodGroup = productDetail.prodGrp ?? ""
            let descType = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "PRODGROUP", alphaKey: prodGroup)

            let distributionCheck = DistributionCheck()
            distributionCheck.category = descType?.desc ?? ""
            distributionCheck.originalShelfStatus = nil
            distributionCheck.shelfStatus = shelfStatus
            distributionCheck.productDetail = productDetail
            distributionCheckArray.append(distributionCheck)
        }

        selectedSortType = .category
        selectedSortOrder = .ascending
        sortChecks()
    }

    func initUI() {
        //categoryButton.setTitleForAllState(title: L10n.category())
        itemLabel.text = L10n.item()
        aisleLabel.text = L10n.aisle()
        //onShelfButton.setTitleForAllState(title: L10n.onShelf())
        shelfLabel.text = L10n.shelf()
        expiryLabel.text = L10n.expriry()
        perfectStoreRatingsTitleLabel.text = L10n.perfectStoreRatings()
        totalItemsInListTitleLabel.text = L10n.totalItemsInList()
        totalItemsAvailableTitleLabel.text = L10n.totalItemsAvailable()
        backButton.setTitleForAllState(title: L10n.back())
        doneButton.setTitleForAllState(title: L10n.done())
        noDataLabel.text = L10n.thereIsNoData()
        
        checkTableView.dataSource = self
        checkTableView.delegate = self
        updateRightUI()
    }

    func sortChecks() {

        if selectedSortType == .category {
            distributionCheckArray = distributionCheckArray.sorted(by: { (check1, check2) -> Bool in
                let category1 = check1.category
                let category2 = check2.category
                if selectedSortOrder == .ascending {
                    return category1 < category2
                }
                else {
                    return category1 > category2
                }
            })
        }
        else if selectedSortType == .aisle {
            distributionCheckArray = distributionCheckArray.sorted(by: { (check1, check2) -> Bool in
                let aisle1 = check1.shelfStatus!.aisle ?? ""
                let aisle2 = check2.shelfStatus!.aisle ?? ""
                if selectedSortOrder == .ascending {
                    return aisle1 < aisle2
                }
                else {
                    return aisle1 > aisle2
                }
            })
        }
        else if selectedSortType == .onShelf {
            distributionCheckArray = distributionCheckArray.sorted(by: { (check1, check2) -> Bool in
                let onShelf1 = check1.shelfStatus!.isOnShelf
                let onShelf2 = check2.shelfStatus!.isOnShelf
                if selectedSortOrder == .ascending {
                    return onShelf1.intValue < onShelf2.intValue
                }
                else {
                    return onShelf1.intValue > onShelf2.intValue
                }
            })
        }
    }

    func updateSortButtonUI() {
        for (index, sortTypeButton) in sortTypeButtonArray.enumerated() {
            if index == selectedSortType.rawValue {
                if selectedSortOrder == .ascending {
                    sortTypeButton.setImageForAllState(image: sortAscendingImage)
                }
                else {
                    sortTypeButton.setImageForAllState(image: sortDescendingImage)
                }
            }
            else {
                sortTypeButton.setImageForAllState(image: nil)
            }
        }
    }

    func updateRightUI() {
        let totalItemsInList = distributionCheckArray.count
        let filteredCheckArray = distributionCheckArray.filter { (check) -> Bool in
            let isOnShelf = check.shelfStatus?.isOnShelf ?? false
            return isOnShelf
        }
        let totalItemsAvailable = filteredCheckArray.count
        var storeRatings: Double = 0
        if totalItemsInList != 0 {
            storeRatings = Double(totalItemsAvailable)/Double(totalItemsInList)*100
        }
        totalItemsInListLabel.text = "\(totalItemsInList)"
        totalItemsAvailableLabel.text = "\(totalItemsAvailable)"
        perfectStoreRatingsLabel.text = "\(storeRatings.integerString)%"
    }

    func refreshCheck() {
        checkTableView.reloadData()
        if distributionCheckArray.count == 0 {
            noDataLabel.isHidden = false
        }
        else {
            noDataLabel.isHidden = true
        }
    }

    @IBAction func onCategorySort(_ sender: Any) {
        if selectedSortType == .category {
            if selectedSortOrder == .ascending {
                selectedSortOrder = .descending
            }
            else {
                selectedSortOrder = .ascending
            }
        }
        else {
            selectedSortType = .category
            selectedSortOrder = .ascending
        }
        sortChecks()
        refreshCheck()
    }

    @IBAction func onAisleSort(_ sender: Any) {
        if selectedSortType == .aisle {
            if selectedSortOrder == .ascending {
                selectedSortOrder = .descending
            }
            else {
                selectedSortOrder = .ascending
            }
        }
        else {
            selectedSortType = .aisle
            selectedSortOrder = .ascending
        }
        sortChecks()
        refreshCheck()
    }

    @IBAction func onOnShelfSort(_ sender: Any) {
        if selectedSortType == .onShelf {
            if selectedSortOrder == .ascending {
                selectedSortOrder = .descending
            }
            else {
                selectedSortOrder = .ascending
            }
        }
        else {
            selectedSortType = .onShelf
            selectedSortOrder = .ascending
        }
        sortChecks()
        refreshCheck()
    }

    @IBAction func onDone(_ sender: Any) {

        // save shelf status
        for check in distributionCheckArray {
            check.originalShelfStatus?.updateBy(theSource: check.shelfStatus!)
        }

        // save range checked
        customerDetail.isRangeChecked = true
        GlobalInfo.saveCache()

        // prepare upload
        let now = Date()
        let nowString = now.toDateString(format: kTightFullDateFormat) ?? ""
        let shelfStatusTransaction = UTransaction.make(chainNo: customerDetail.chainNo ?? "", custNo: customerDetail.custNo ?? "", docType: "SURV", date: now, reference: "", trip: globalInfo.routeControl!.trip ?? "")

        // GPS Log
        let gpsLog = GPSLog.make(chainNo: customerDetail.chainNo ?? "", custNo: customerDetail.custNo ?? "", docType: "GPS", date: now, location: globalInfo.getCurrentLocation())
        let gpsLogTransaction = gpsLog.makeTransaction()

        let gpsLogPath = GPSLog.saveToXML(gpsLogArray: [gpsLog])

        // ShelfAudits
        let shelfStatusArray = distributionCheckArray.map { (check) -> ShelfStatus in
            return check.shelfStatus!
        }
        let shelfAudit = ShelfAudit.make(chainNo: customerDetail.chainNo ?? "", custNo: customerDetail.custNo ?? "", docType: "SHF", date: now, reference: "", shelfStatusArray: shelfStatusArray)

        let shelfAuditPath = CommData.getFilePathAppended(byCacheDir: "ShelfAudits\(nowString).upl") ?? ""
        ShelfAudit.saveToXML(auditArray: [shelfAudit], filePath: shelfAuditPath)

        let transactionPath = UTransaction.saveToXML(transactionArray: [shelfStatusTransaction, gpsLogTransaction], shouldIncludeLog: true)

        globalInfo.uploadManager.zipAndScheduleUpload(filePathArray: [shelfAuditPath, gpsLogPath, transactionPath], completionHandler: nil)

        mainVC.popChild(containerView: mainVC.containerView)
    }

    @IBAction func onBack(_ sender: Any) {
        mainVC.popChild(containerView: mainVC.containerView)
    }

}

extension DistributionCheckVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return distributionCheckArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DistributionCheckCell", for: indexPath) as! DistributionCheckCell
        cell.setupCell(parentVC: self, indexPath: indexPath)
        return cell
    }

}

extension DistributionCheckVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let distributionCheck = distributionCheckArray[index]
        let productDetail = distributionCheck.productDetail
        if productDetail == nil {
            return
        }
        Utils.showProductDetailVC(vc: self, productDetail: productDetail!, customerDetail: customerDetail, isForInputQty: false, inputQty: 0, dismissHandler: nil)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }

}
