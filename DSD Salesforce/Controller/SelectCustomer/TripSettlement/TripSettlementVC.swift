//
//  TripSettlementVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 12/25/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

struct TripSettlementMenu {
    var menuName = ""
    var isMenuCompleted = false
    var isEnabled = false
}

class TripSettlementVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tripNoLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var completeButton: AnimatableButton!
    @IBOutlet weak var backButton: AnimatableButton!
    
    let globalInfo = GlobalInfo.shared

//    let kNoVisitReasonsMenu = "No Visit Reasons"
//    let kEndingInventoryMenu = "Ending Inventory"
//    let kBalanceCollectionsMenu = "Balance Collections"
//    let kSalesPerformanceMenu = "Sales Performance"
//    let kPostTripInspectionMenu = "Post Trip Inspection"
    
    let kNoVisitReasonsMenu = L10n.noVisitReasons()
    let kEndingInventoryMenu = L10n.endingInventory()
    let kBalanceCollectionsMenu = L10n.balanceCollections()
    let kSalesPerformanceMenu = L10n.salesPerormance()
    let kPostTripInspectionMenu = L10n.postTripInspection()
    
    var menuArray = [TripSettlementMenu]()
    var incompleteInfoArray = [IncompleteInfo]()
    var pdfTrxnNo: Int64 = 0
    var strPdfFileName = ""
    var dismissHandler: (()->())?

    var collectionConfirmPDFName = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
        initUI()
        reloadMenus()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadMenus()
    }

    func initUI() {
        backButton.setTitleForAllState(title: L10n.back())
        completeButton.setTitleForAllState(title: L10n.completed())
        
        let userName = globalInfo.routeControl?.userName ?? ""
        usernameLabel.text = "\(L10n.hi()) \(userName)"

        let tripNumber = globalInfo.routeControl?.trip ?? ""
        tripNoLabel.text = "\(L10n.trip()) # \(tripNumber)"

        tableView.delegate = self
        tableView.dataSource = self
    }

    func initData() {
        let menuNameArray = [kNoVisitReasonsMenu, kEndingInventoryMenu, kBalanceCollectionsMenu, kSalesPerformanceMenu, kPostTripInspectionMenu]
        menuArray.removeAll()

        let dayNo = "\(Utils.getWeekday(date: Date()))"
        var customerArray = CustomerDetail.getScheduled(context: globalInfo.managedObjectContext, dayNo: dayNo, shouldExcludeCompleted: false)
        customerArray = customerArray.filter({ (customerDetail) -> Bool in
            if customerDetail.isVisitPlanned == true {
                let nowDateString = Date().toDateString(format: kTightJustDateFormat) ?? ""
                if customerDetail.deliveryDate == nowDateString {
                    return true
                }
                else {
                    return false
                }
            }
            return true
        })
        customerArray = customerArray.sorted(by: { (customerDetail1, customerDetail2) -> Bool in
            let seqNo1 = Int(customerDetail1.seqNo ?? "") ?? 0
            let seqNo2 = Int(customerDetail2.seqNo ?? "") ?? 0
            let periodNo1 = Int(customerDetail1.periodNo ?? "") ?? 0
            let periodNo2 = Int(customerDetail2.periodNo ?? "") ?? 0
            let deliveryDate1 = customerDetail1.deliveryDate ?? ""
            let deliveryDate2 = customerDetail2.deliveryDate ?? ""

            if deliveryDate1 != deliveryDate2 {
                return deliveryDate1 < deliveryDate2
            }
            else {
                if periodNo1 != periodNo2 {
                    return periodNo1 < periodNo2
                }
                else {
                    return seqNo1 < seqNo2
                }
            }
        })
        for customerDetail in customerArray {
            if customerDetail.isCompleted == true {
                continue
            }
            let incompleteInfo = IncompleteInfo()
            incompleteInfo.customerDetail = customerDetail
            incompleteInfo.nReasonIdx = -1
            incompleteInfo.nCases = 0
            incompleteInfo.nUnits = 0

            let chainNo = customerDetail.chainNo ?? "0"
            let custNo = customerDetail.custNo ?? "0"
            let periodNo = customerDetail.periodNo ?? ""
            let presoldOrHeaderArray = PresoldOrHeader.getBy(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo, periodNo: periodNo)
            for presoldOrHeader in presoldOrHeaderArray {
                let detailFile = presoldOrHeader.detailFile ?? ""
                let presoldOrDetailArray = PresoldOrDetail.getBy(context: globalInfo.managedObjectContext, detailFile: detailFile)
                for presoldOrDetail in presoldOrDetailArray {
                    let itemNo = presoldOrDetail.itemNo ?? ""
                    let prodLocnArray = ProductLocn.getBy(context: globalInfo.managedObjectContext, itemNo: itemNo)
                    let firstProdLocn = prodLocnArray.first
                    let fullCase = firstProdLocn?.fullCase
                    if firstProdLocn != nil && fullCase != nil && fullCase?.uppercased() == "Y" {
                        incompleteInfo.nCases += presoldOrDetail.nOrderQty
                    }
                    else {
                        incompleteInfo.nUnits += presoldOrDetail.nOrderQty
                    }
                }
            }
            incompleteInfoArray.append(incompleteInfo)
        }

        for menuName in menuNameArray {
            var isMenuEnabled = false
            var isMenuCompleted = false
            if menuName == kNoVisitReasonsMenu {
                if incompleteInfoArray.count == 0 {
                    isMenuEnabled = false
                    isMenuCompleted = true
                }
                else {
                    isMenuEnabled = true
                    isMenuCompleted = false
                }
            }
            else if menuName == kBalanceCollectionsMenu {
                let uarPaymentArray = UARPayment.getAll(context: globalInfo.managedObjectContext)
                if uarPaymentArray.count == 0 {
                    isMenuEnabled = false
                    isMenuCompleted = true
                }
                else {
                    // we should check if the pdf exist
                    isMenuEnabled = true
                    let pdfName = Utils.getStringSetting(key: kCollectionsBalancingPDFNameKey)
                    if pdfName == "" {
                        isMenuCompleted = false
                    }
                    else {
                        let pdfPath = CommData.getFilePathAppended(byCacheDir: kPDFDirName+"/"+pdfName)
                        if CommData.isExistingFile(atPath: pdfPath) {
                            isMenuCompleted = true
                        }
                        else {
                            isMenuCompleted = false
                        }
                    }
                }
            }
            else {
                isMenuEnabled = false
                isMenuCompleted = true
            }
            let tripSettleMenu = TripSettlementMenu(menuName: menuName, isMenuCompleted: isMenuCompleted, isEnabled: isMenuEnabled)
            menuArray.append(tripSettleMenu)
        }
    }

    func reloadMenus() {
        var isCompleted = true
        for (index, menu) in menuArray.enumerated() {
            let menuName = menu.menuName
            if menuName == kBalanceCollectionsMenu {
                let uarPaymentArray = UARPayment.getAll(context: globalInfo.managedObjectContext)
                if uarPaymentArray.count == 0 {
                    menuArray[index].isEnabled = false
                    menuArray[index].isMenuCompleted = true
                }
                else {
                    // we should check if the pdf exist
                    menuArray[index].isEnabled = true
                    let pdfName = Utils.getStringSetting(key: kCollectionsBalancingPDFNameKey)
                    if pdfName == "" {
                        menuArray[index].isMenuCompleted = false
                    }
                    else {
                        let pdfPath = CommData.getFilePathAppended(byCacheDir: kPDFDirName+"/"+pdfName)
                        if CommData.isExistingFile(atPath: pdfPath) {
                            menuArray[index].isMenuCompleted = true
                        }
                        else {
                            menuArray[index].isMenuCompleted = false
                        }
                    }
                }
            }
            if menuArray[index].isMenuCompleted == false {
                isCompleted = false
            }
        }
        completeButton.isEnabled = isCompleted
        tableView.reloadData()
    }

    @IBAction func onCompleted(_ sender: Any) {

        // we should make the upload service
        var visitArray = Visit.getAll(context: globalInfo.managedObjectContext)
        visitArray = visitArray.sorted(by: { (visit1, visit2) -> Bool in
            let trxnNo1 = Int(visit1.trxnNo ?? "0") ?? 0
            let trxnNo2 = Int(visit2.trxnNo ?? "0") ?? 0
            return trxnNo1 < trxnNo2
        })

        var uploadServiceArray = UploadService.getAll(context: globalInfo.managedObjectContext)
        uploadServiceArray = uploadServiceArray.sorted(by: { (uploadService1, uploadService2) -> Bool in
            let trxnNo1 = Int(uploadService1.trxnNo ?? "0") ?? 0
            let trxnNo2 = Int(uploadService2.trxnNo ?? "0") ?? 0
            return trxnNo1 < trxnNo2
        })

        let uploadManager = globalInfo.uploadManager
        var zipFileArray = [String]()
        let visitFilePath = Visit.saveToXML(visitArray: visitArray)
        if visitFilePath != "" {
            zipFileArray.append(visitFilePath)
        }
        let uploadServiceFilePath = UploadService.saveToXML(uServiceArray: uploadServiceArray)
        if uploadServiceFilePath != "" {
            zipFileArray.append(uploadServiceFilePath)
        }

        // upload pdf if there is the pdf
        var fileTrxnDate = Date()
        var fileTrxnDateString = fileTrxnDate.toDateString(format: kTightJustDateFormat) ?? ""
        var fileTrxnTimeString = fileTrxnDate.toDateString(format: kTightJustTimeFormat) ?? ""
        let trip = globalInfo.routeControl?.trip ?? ""

        var fileTransactionArray = [FileTransaction]()
        var transactionArray = [UTransaction]()
        if strPdfFileName != "" {
            let fileTransaction = FileTransaction.make(chainNo: "0", custNo: "0", docType: "FARC", fileTrxnDate: fileTrxnDate, trip: trip, trnxDate: Date(), fileDocNo: strPdfFileName, fileShortDesc: "UNDELIVERED CUSTOMERS REPORT", fileLongDesc: "UNDELIVERED CUSTOMERS REPORT", fileCreateDate: fileTrxnDateString, fileCreateTime: fileTrxnTimeString, fileName: strPdfFileName)
            fileTransactionArray.append(fileTransaction)
            transactionArray.append(fileTransaction.makeTransaction())

            uploadManager?.scheduleUpload(localFileName: kPDFDirName+"/"+strPdfFileName, remoteFileName: fileTransaction.fileFileName, uploadItemType: .normalCustomerFile)
        }

        fileTrxnDate = Date()
        fileTrxnDateString = fileTrxnDate.toDateString(format: kTightJustDateFormat) ?? ""
        fileTrxnTimeString = fileTrxnDate.toDateString(format: kTightJustTimeFormat) ?? ""
        if collectionConfirmPDFName != "" {
            let fileTransaction = FileTransaction.make(chainNo: "0", custNo: "0", docType: "FARC", fileTrxnDate: fileTrxnDate, trip: trip, trnxDate: Date(), fileDocNo: strPdfFileName, fileShortDesc: "COLLECTION", fileLongDesc: "Collection Confirmation Report", fileCreateDate: fileTrxnDateString, fileCreateTime: fileTrxnTimeString, fileName: strPdfFileName)
            fileTransactionArray.append(fileTransaction)
            transactionArray.append(fileTransaction.makeTransaction())

            uploadManager?.scheduleUpload(localFileName: kPDFDirName+"/"+strPdfFileName, remoteFileName: fileTransaction.fileFileName, uploadItemType: .normalCustomerFile)
        }

        let fileTransactionPath = FileTransaction.saveToXML(fileTransactionArray: fileTransactionArray)
        if fileTransactionPath != "" {
            zipFileArray.append(fileTransactionPath)
        }

        // transaction
        let transactionPath = UTransaction.saveToXML(transactionArray: transactionArray, shouldIncludeLog: true)
        if transactionPath != "" {
            zipFileArray.append(transactionPath)
        }
        if zipFileArray.count > 0 {
            uploadManager?.zipAndScheduleUpload(filePathArray: zipFileArray)
        }

        self.dismiss(animated: true) {
            self.dismissHandler?()
        }
    }

}

extension TripSettlementVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripSettlementCell", for: indexPath) as! TripSettlementCell
        let index = indexPath.row
        let menu = menuArray[index]
        let menuName = menu.menuName
        cell.titleLabel.text = menuName
        if menu.isMenuCompleted == true {
            cell.checkImageView.isHidden = false
        }
        else {
            cell.checkImageView.isHidden = true
        }
        if menu.isEnabled == true {
            cell.titleLabel.textColor = kBlackTextColor
        }
        else {
            cell.titleLabel.textColor = UIColor.lightGray
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let menu = menuArray[index]
        tableView.deselectRow(at: indexPath, animated: true)
        if menu.isEnabled == false {
            return
        }
        else if menu.isMenuCompleted == true {
            return
        }
        let menuName = menu.menuName
        if menuName == kNoVisitReasonsMenu {
            let incompleteDeliveriesVC = UIViewController.getViewController(storyboardName: "SelectCustomer", storyboardID: "IncompleteDeliveriesVC") as! IncompleteDeliveriesVC
            incompleteDeliveriesVC.setDefaultModalPresentationStyle()
            incompleteDeliveriesVC.dismissHander = {vc, dismissOption in
                if dismissOption == .completed {
                    self.menuArray[index].isMenuCompleted = true
                    self.incompleteInfoArray = vc.incompleteInfoArray
                    self.pdfTrxnNo = vc.pdfTrxnNo
                    self.strPdfFileName = vc.strPdfFileName
                    self.reloadMenus()
                }
            }
            self.present(incompleteDeliveriesVC, animated: true, completion: nil)
        }
        else if menuName == kBalanceCollectionsMenu {
            let collectionsBalancingVC = UIViewController.getViewController(storyboardName: "SelectCustomer", storyboardID: "CollectionsBalancingVC") as! CollectionsBalancingVC
            collectionsBalancingVC.setDefaultModalPresentationStyle()
            collectionsBalancingVC.dismissHandler = {vc in
                self.collectionConfirmPDFName = vc.pdfFileName
                self.reloadMenus()
            }
            self.present(collectionsBalancingVC, animated: true, completion: nil)
        }
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let index = indexPath.row
        let menu = menuArray[index]
        if menu.isEnabled == false {
            return false
        }
        else {
            return !menu.isMenuCompleted
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

}



