//
//  CustomerActivitiesVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/5/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class CustomerActivitiesVC: UIViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var surveyCollectionView: UICollectionView!
    @IBOutlet weak var surveyCollectionViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var assetIconImageView: UIImageView!
    @IBOutlet weak var toDoObjectivesView: UIView!
    @IBOutlet weak var toDoObjectivesViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var promotionsView: UIView!
    @IBOutlet weak var promotionsViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var assetsView: UIView!
    @IBOutlet weak var assetsViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var paymentCollectionButton: UIButton!
    @IBOutlet weak var paymentCollectionView: UIView!
    @IBOutlet weak var paymentCollectionViewRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var toDoObjectivesLabel: UILabel!
    @IBOutlet weak var customerNotesLabel: UILabel!
    @IBOutlet weak var updateDetailsLabel: UILabel!
    @IBOutlet weak var paymentCollectionLabel: UILabel!
    @IBOutlet weak var distributionCheckLabel: UILabel!
    @IBOutlet weak var salesOrderLabel: UILabel!
    @IBOutlet weak var assetLabel: UILabel!
    @IBOutlet weak var promotionsLabel: UILabel!
    @IBOutlet weak var returnButton: AnimatableButton!
    @IBOutlet weak var completeVisitButton: AnimatableButton!
    
    let globalInfo = GlobalInfo.shared
    var mainVC: MainVC!
    var customerDetail: CustomerDetail!

    var dismissHandler: ((CustomerActivitiesVC)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
    }

    func initUI() {
        toDoObjectivesLabel.text = L10n.toDoObjectives()
        customerNotesLabel.text = L10n.customerNotes()
        updateDetailsLabel.text = L10n.updateDeatils()
        paymentCollectionLabel.text = L10n.paymentCollection()
        distributionCheckLabel.text = L10n.distributionCheck()
        salesOrderLabel.text = L10n.salesOrder()
        assetLabel.text = L10n.assets()
        promotionsLabel.text = L10n.promotions()
        returnButton.setTitleForAllState(title: L10n.Return())
        completeVisitButton.setTitleForAllState(title: L10n.completeVisit())
        
        surveyCollectionView.delegate = self
        surveyCollectionView.dataSource = self
    }

    func updateUI() {
        let chainNo = customerDetail.chainNo ?? "0"
        let custNo = customerDetail.custNo ?? "0"

        // Check asset completeness
        let isEquipCompleted = EquipCompleteStatus.getBy(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo)?.isCompleted ?? false
        if isEquipCompleted == true {
            assetIconImageView.image = UIImage(named: "Activity_Asset_Check")
        }
        else {
            assetIconImageView.image = UIImage(named: "Activity_Asset_Normal")
        }

        // Survey status
        refreshSurveys()

        // to do objectives view
        toDoObjectivesView.isHidden = true
        toDoObjectivesViewRightConstraint.constant = -toDoObjectivesView.bounds.width

        // refresh assets view
        let equipCheck = (globalInfo.routeControl?.equipCheck ?? "").trimed()
        if equipCheck == "0" && equipCheck == "" {
            assetsView.isHidden = true
            assetsViewRightConstraint.constant = assetsView.bounds.width
        }

        // promotions view
        updatePromotionsView()

        let arHeaderArray = ARHeader.getUnpaidBy(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo)
        var totalAmount: Double = 0
        for arHeader in arHeaderArray {
            let amount = Utils.getXMLDivided(valueString: arHeader.trxnAmount ?? "0")
            totalAmount += amount
        }
        if totalAmount == 0 {
            paymentCollectionView.isHidden = true
            paymentCollectionViewRightConstraint.constant = -paymentCollectionView.bounds.width
        }
        else {
            paymentCollectionView.isHidden = false
            paymentCollectionViewRightConstraint.constant = 0
        }
    }

    func refreshSurveys() {
        surveyCollectionView.reloadData()
        let surveyCount = min(customerDetail.surveySet.count, 4)
        let mainViewWidth = mainView.bounds.width
        let surveyCellWidth = mainViewWidth/4
        surveyCollectionViewWidthConstraint.constant = surveyCellWidth*CGFloat(surveyCount)
    }

    func updatePromotionsView() {

        let promotionStartDate = Date()
        // let promotionStartWeek = promotionStartDate.weekOfYear
        let weekday = promotionStartDate.weekday
        let promotionWeekStartDate = promotionStartDate.getDateAddedBy(days: -1*(weekday-1))

        let planNo = customerDetail!.promoPlan ?? "0"
        let promotionHeaderArray = PromotionHeader.getBy(context: globalInfo.managedObjectContext, planNo: planNo, endAfter: promotionWeekStartDate)
        var promotionPlanArray = [PromotionPlan]()
        promotionPlanArray.removeAll()
        for promotionHeader in promotionHeaderArray {
            let assignNo = promotionHeader.assignNo ?? ""
            let noVoArray = PromotionNoVo.getBy(context: globalInfo.managedObjectContext, assignNo: assignNo)
            let promotionAss = PromotionAss.getBy(context: globalInfo.managedObjectContext, assignNo: assignNo).first
            let promotionOption = PromotionOption.getBy(context: globalInfo.managedObjectContext, assignNo: assignNo).first
            for noVo in noVoArray {
                let promotionPlan = PromotionPlan()
                promotionPlan.promotionHeader = promotionHeader
                promotionPlan.promotionNoVo = noVo
                promotionPlan.promotionAss = promotionAss
                promotionPlan.promotionOption = promotionOption
                let itemNo = noVo.itemNo ?? "0"
                let productDetail = ProductDetail.getBy(context: globalInfo.managedObjectContext, itemNo: itemNo)
                promotionPlan.productDetail = productDetail
                promotionPlanArray.append(promotionPlan)
            }
        }
        if promotionPlanArray.count == 0 {
            promotionsView.isHidden = true
            promotionsViewRightConstraint.constant = -promotionsView.bounds.width
        }
        else {
            promotionsView.isHidden = false
            promotionsViewRightConstraint.constant = 0
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        mainVC.setTitleBarText(title: "CUSTOMER ACTIVITIES")

        /// uncomment when continue work in order screen
        globalInfo.adjustCoreData()
        updateUI()
    }

    @IBAction func onTodoObjectives(_ sender: Any) {
        let todoObjectivesVC = UIViewController.getViewController(storyboardName: "CustomerActivities", storyboardID: "TodoObjectivesVC") as! TodoObjectivesVC
        todoObjectivesVC.mainVC = mainVC
        todoObjectivesVC.customerDetail = customerDetail
        mainVC.pushChild(newVC: todoObjectivesVC, containerView: mainVC.containerView)
    }

    @IBAction func onUpdateDetails(_ sender: Any) {
        let newCustomerVC = UIViewController.getViewController(storyboardName: "NewCustomer", storyboardID: "NewCustomerVC") as! NewCustomerVC
        newCustomerVC.originalCustomerDetail = customerDetail
        newCustomerVC.setDefaultModalPresentationStyle()
        newCustomerVC.dismissHandler = {vc, dismissOption in

        }
        self.present(newCustomerVC, animated: true, completion: nil)
    }

    @IBAction func onPaymentCollection(_ sender: Any) {
        let paymentCollectionVC = UIViewController.getViewController(storyboardName: "CustomerActivities", storyboardID: "PaymentCollectionVC") as! PaymentCollectionVC
        paymentCollectionVC.mainVC = mainVC
        paymentCollectionVC.customerDetail = customerDetail
        mainVC.pushChild(newVC: paymentCollectionVC, containerView: mainVC.containerView)
    }

    @IBAction func onDistributionCheck(_ sender: Any) {
        let distributionCheckVC = UIViewController.getViewController(storyboardName: "CustomerActivities", storyboardID: "DistributionCheckVC") as! DistributionCheckVC
        distributionCheckVC.mainVC = mainVC
        distributionCheckVC.customerDetail = customerDetail
        mainVC.pushChild(newVC: distributionCheckVC, containerView: mainVC.containerView)
    }

    @IBAction func onSalesOrder(_ sender: Any) {

        if globalInfo.routeControl?.orderFunction == "OM" {
            
            let custInfo = CustInfo.getBy(context: globalInfo.managedObjectContext, infoType: "50", custNo: customerDetail.custNo ?? "")?.info ?? ""
            guard let url = URL(string: "https://app.ordermentum.com/retailer/\(custInfo)/supplier/\(globalInfo.routeControl?.omSupplierId ?? "")/marketplace/categories") else {
              return //be safe
            }

            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        else {
            let chainNo = customerDetail.chainNo ?? ""
            let custNo = customerDetail.custNo ?? ""
            let orderHeaderArray = OrderHeader.getBy(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo)
            
            let savedUploadedHeaderArray = orderHeaderArray.filter { (orderHeader) -> Bool in
                return orderHeader.isSaved == true || orderHeader.isInProgress == true
            }
            let managedObjectContext = globalInfo.managedObjectContext!
            let presoldOrder = PresoldOrHeader.getFirstBy(context: managedObjectContext, chainNo: chainNo, custNo: custNo)
            let presoldOrderType = presoldOrder?.type ?? ""
            
            let result = OrderHeader.getBy(context: globalInfo.managedObjectContext, isSavedOrder: true)
            if result.count == 0 && savedUploadedHeaderArray.count == 0 && presoldOrderType.uppercased() != "P" {
                self.openSalesOrder(selectedOrderHeader: nil, isByPresoldHeader: false, isEdit: true)
            }
            else {
                GlobalInfo.saveCache()
                let existingOrdersVC = UIViewController.getViewController(storyboardName: "CustomerActivities", storyboardID: "ExistingOrdersVC") as! ExistingOrdersVC
                existingOrdersVC.setDefaultModalPresentationStyle()
                existingOrdersVC.customerDetail = customerDetail
                existingOrdersVC.dismissHandler = { vc, dismissOption in
                    if dismissOption == .newOrder {
                        self.openSalesOrder(selectedOrderHeader: nil, isByPresoldHeader: false, isEdit: true)
                    }
                    else if dismissOption == .newOrderByPresold {
                        self.openSalesOrder(selectedOrderHeader: nil, isByPresoldHeader: true, isEdit: true)
                    }
                    else if dismissOption == .selectEdition {
                        if (vc.selectedOrderHeader?.custNo != self.customerDetail.custNo) && vc.selectedOrderHeader?.isSavedOrder == true {
                            let orderHeader = OrderHeader(context: managedObjectContext, forSave: false)
                            orderHeader.updateBy(context: managedObjectContext, theSource: vc.selectedOrderHeader!)
                            orderHeader.isSavedOrder = false
                            self.openSalesOrder(selectedOrderHeader: orderHeader, isByPresoldHeader: false, isEdit: true)
                        }
                        else {
                            self.openSalesOrder(selectedOrderHeader: vc.selectedOrderHeader, isByPresoldHeader: false, isEdit: true)
                        }
                    }
                    else if dismissOption == .select {
                        self.openSalesOrder(selectedOrderHeader: vc.selectedOrderHeader, isByPresoldHeader: false, isEdit: false)
                    }
                }
                self.present(existingOrdersVC, animated: true, completion: nil)
            }
        }
    }

    func openSalesOrder(selectedOrderHeader: OrderHeader?,  isByPresoldHeader: Bool, isEdit: Bool) {
        let salesOrderVC = UIViewController.getViewController(storyboardName: "Order", storyboardID: "OrderVC") as! OrderVC
        salesOrderVC.mainVC = mainVC
        salesOrderVC.customerDetail = customerDetail
        salesOrderVC.originalOrderHeader = selectedOrderHeader
        salesOrderVC.isEnableFilterAuthorizedItem = true
        salesOrderVC.isByPresoldHeader = isByPresoldHeader
        salesOrderVC.isEdit = isEdit
        mainVC.pushChild(newVC: salesOrderVC, containerView: mainVC.containerView)
    }

    func onTapSurvey(index: Int) {
        let customerSurveyVC = UIViewController.getViewController(storyboardName: "CustomerActivities", storyboardID: "CustomerSurveyVC") as! CustomerSurveyVC
        customerSurveyVC.mainVC = mainVC
        customerSurveyVC.customerDetail = customerDetail
        customerSurveyVC.originalSurvey = customerDetail.surveySet[index] as! Survey
        mainVC.pushChild(newVC: customerSurveyVC, containerView: mainVC.containerView)
    }

    func doCompleteVisit() {

        let chainNo = customerDetail.chainNo ?? ""
        let custNo = customerDetail.custNo ?? ""
        let orderHeaderArray = OrderHeader.getBy(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo)
        let notUploadedHeaderArray = orderHeaderArray.filter { (orderHeader) -> Bool in
            return orderHeader.isSaved == true && orderHeader.isUploaded == false && orderHeader.isInProgress == false
        }

        for orderHeader in notUploadedHeaderArray {
            orderHeader.scheduleUpload()
        }
        customerDetail.isCompleted = true

        let now = Date()

        // make cust note for this
        let noteType = "99"
        let messageNote = customerDetail.visitNote ?? ""
        let attachment = "0"

        if messageNote != "" {
            let newCustNote = CustNote(context: globalInfo.managedObjectContext, forSave: true)
            newCustNote.chainNo = chainNo
            newCustNote.custNo = custNo
            newCustNote.noteType = noteType
            newCustNote.noteDate = now.toDateString(format: kTightJustDateFormat) ?? ""
            newCustNote.noteTime = now.toDateString(format: "HHmm") ?? ""
            newCustNote.createdby = globalInfo.routeControl?.userName ?? ""
            newCustNote.note = messageNote
            newCustNote.noteId = "\(now.getTimestamp())"
            newCustNote.attachment = attachment
            newCustNote.fileNames = ""
            newCustNote.fileTypes = ""
            GlobalInfo.saveCache()
        }

        // upload visit upload
        var transactionArray = [UTransaction]()

        let visit = Visit.make(chainNo: chainNo, custNo: custNo, docType: "VIS", date: now, customerDetail: customerDetail, reference: "")
        transactionArray.append(visit.makeTransaction())

        let uService = UploadService.make(chainNo: chainNo, custNo: custNo, docType: "SERV", date: now, reason: "0", done: "0")
        transactionArray.append(uService.makeTransaction())

        var filePathArray = [String]()

        if messageNote != "" {
            let uCustNote = UCustNote.make(chainNo: chainNo, custNo: custNo, docType: "NOTE", date: now, noteType: noteType, note: messageNote, attachmentString: attachment)
            transactionArray.append(uCustNote.makeTransaction())

            let uCustNotePath = UCustNote.saveToXML(uCustNoteArray: [uCustNote])
            filePathArray.append(uCustNotePath)
        }

        let gpsLog = GPSLog.make(chainNo: chainNo, custNo: custNo, docType: "GPS", date: now, location: globalInfo.getCurrentLocation())
        transactionArray.append(gpsLog.makeTransaction())

        let visitPath = Visit.saveToXML(visitArray: [visit])
        filePathArray.append(visitPath)
        let uServicePath = UploadService.saveToXML(uServiceArray: [uService])
        filePathArray.append(uServicePath)

        let transactionPath = UTransaction.saveToXML(transactionArray: transactionArray, shouldIncludeLog: true)
        filePathArray.append(transactionPath)
        let gpsLogPath = GPSLog.saveToXML(gpsLogArray: [gpsLog])
        filePathArray.append(gpsLogPath)

        let uploadManager = globalInfo.uploadManager
        uploadManager?.zipAndScheduleUpload(filePathArray: filePathArray, completionHandler: nil)

        mainVC.popChild(containerView: mainVC.containerView) { (completed) in
            self.dismissHandler?(self)
        }
    }

    @IBAction func onAssets(_ sender: Any) {

        let chainNo = customerDetail.chainNo ?? ""
        let custNo = customerDetail.custNo ?? ""
        var isEquipExist = false
        let equipCheck = (globalInfo.routeControl!.equipCheck ?? "").trimed()
        if equipCheck == "0" {
            isEquipExist = false
        }
        else if equipCheck == "1" {
            let equipArray = EquipAss.getBy(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo)
            isEquipExist = equipArray.count > 0
        }
        else if equipCheck == "2" {
            isEquipExist = true
        }

        let isCompleted = EquipCompleteStatus.getBy(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo)?.isCompleted ?? false

        if isEquipExist == true/* && isCompleted == false*/ {
            let assetManagementVC = UIViewController.getViewController(storyboardName: "Asset", storyboardID: "AssetManagementVC") as! AssetManagementVC
            assetManagementVC.mainVC = mainVC
            assetManagementVC.customerDetail = customerDetail
            mainVC.pushChild(newVC: assetManagementVC, containerView: mainVC.containerView)
        }
    }

    @IBAction func onVisitNotes(_ sender: Any) {
        let messageBoardVC = UIViewController.getViewController(storyboardName: "CustomerActivities", storyboardID: "MessageBoardVC") as! MessageBoardVC
        messageBoardVC.mainVC = mainVC
        messageBoardVC.customerDetail = customerDetail
        mainVC.pushChild(newVC: messageBoardVC, containerView: mainVC.containerView)
    }
    
    @IBAction func onPromotions(_ sender: Any) {

        let promotionPlannerVC = UIViewController.getViewController(storyboardName: "Promotion", storyboardID: "PromotionPlannerVC") as! PromotionPlannerVC
        promotionPlannerVC.mainVC = mainVC
        promotionPlannerVC.customerDetail = customerDetail
        mainVC.pushChild(newVC: promotionPlannerVC, containerView: mainVC.containerView)
    }

    @IBAction func onCompleteVisit(_ sender: Any) {

        let postVisitTaskVC = UIViewController.getViewController(storyboardName: "CustomerActivities", storyboardID: "PostVisitTaskVC") as! PostVisitTaskVC
        postVisitTaskVC.setDefaultModalPresentationStyle()
        postVisitTaskVC.customerDetail = self.customerDetail
        postVisitTaskVC.dismissHandler = { vc, dismissOption in
            if dismissOption == .done {
                self.customerDetail.nextVisitDate = vc.nextVisitDate.toDateString(format: kTightJustDateFormat) ?? ""
                self.customerDetail.visitNote = vc.visitNote
                let visitFrequency = vc.deliveryFreq
                let preferredVisitDay = vc.preferredVisitDay
                self.customerDetail.visitFrequency = Int32(visitFrequency)
                self.customerDetail.preferredVisitDay = Int32(preferredVisitDay)
                
                ///SF71
                self.customerDetail.plannedVisitTime = vc.plannedVisitTimeStr
                ///SF71 END

                // save visit end
                let visitEndString = Date().toDateString(format: kTightFullDateFormat)
                self.customerDetail.visitEndDate = visitEndString

                self.doCompleteVisit()
            }
        }
        self.present(postVisitTaskVC, animated: true, completion: nil)
    }

    @IBAction func onReturn(_ sender: Any) {
        // we need to show warning
        let chainNo = self.customerDetail.chainNo ?? ""
        let custNo = self.customerDetail.custNo ?? ""
        let managedObjectContext = self.globalInfo.managedObjectContext!
        let orderHeaderArray = OrderHeader.getBy(context: managedObjectContext, chainNo: chainNo, custNo: custNo)
        let savedNotUploadedHeaderArray = orderHeaderArray.filter { (orderHeader) -> Bool in
            return (orderHeader.isSaved == true && orderHeader.isUploaded == false) || (orderHeader.isInProgress == true && orderHeader.isSavedOrder == false)
        }

        if savedNotUploadedHeaderArray.count > 0 {
            Utils.showAlert(vc: self, title: "", message: L10n.areYourSureYouWishToExitAnyDataYouHaveEnteredForThisCustomerWillBeLost(), failed: false, customerName: "", leftString: L10n.cancel(), middleString: "", rightString: L10n.confirm()) { (returnCode) in
                if returnCode == MessageDialogVC.ReturnCode.right {
                    // remove orders that was not uploaded
                    for orderHeader in savedNotUploadedHeaderArray {
                        OrderHeader.delete(context: managedObjectContext, orderHeader: orderHeader)
                    }
                    self.mainVC.popChild(containerView: self.mainVC.containerView)
                }
            }
        }
        else {
            self.mainVC.popChild(containerView: self.mainVC.containerView)
        }
    }

}

extension CustomerActivitiesVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return customerDetail.surveySet.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomerActivitySurveyCell", for: indexPath) as! CustomerActivitySurveyCell
        cell.setupCell(parentVC: self, indexPath: indexPath)
        return cell
    }
}

extension CustomerActivitiesVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let kCols = 4
        let totalWidth = mainView.bounds.width
        let totalHeight = collectionView.bounds.height
        let width = floor(totalWidth/CGFloat(kCols))
        return CGSize(width: width, height: totalHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

