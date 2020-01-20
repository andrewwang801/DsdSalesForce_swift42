//
//  AssetManagementVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/12/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class AssetManagementVC: UIViewController {

    @IBOutlet weak var verifiedView: UIView!
    @IBOutlet weak var foundUpdatedView: UIView!
    @IBOutlet weak var notFoundView: UIView!
    @IBOutlet weak var verifiedLabel: AnimatableLabel!
    @IBOutlet weak var foundUpdatedLabel: AnimatableLabel!
    @IBOutlet weak var notFoundLabel: AnimatableLabel!
    @IBOutlet weak var assetTableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var noDataRightLabel: UILabel!
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var searchCloseButton: UIButton!
    @IBOutlet weak var searchViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerView: UIView!

    @IBOutlet weak var serialNumberLabel: UILabel!
    @IBOutlet weak var alternativeAssetNumberLabel: UILabel!
    @IBOutlet weak var makeLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var locationInStoreLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var repairButton: AnimatableButton!

    @IBOutlet weak var assetImageView: UIImageView!
    @IBOutlet weak var assetTitleLabel: UILabel!

    @IBOutlet weak var foundAndDetailsUpdatedLabel: UILabel!
    @IBOutlet weak var notFound: UILabel!
    @IBOutlet weak var newAssetFoundButton: AnimatableButton!
    @IBOutlet weak var requestNewPlacementButton: AnimatableButton!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var serialNumberTitleLabel: UILabel!
    @IBOutlet weak var alternativeAssetNumberTitleLabel: UILabel!
    @IBOutlet weak var makeTitleLabel: UILabel!
    @IBOutlet weak var modelTitleLabel: UILabel!
    @IBOutlet weak var locationInStoreTitleLabel: UILabel!
    @IBOutlet weak var statusTitleLabel: UILabel!
    @IBOutlet weak var verified: UILabel!
    
    enum AssetOption: Int {
        case none = -1
        case verified = 0
        case foundUpdated = 1
        case notFound = 2
    }

    var selectedAssetOption: AssetOption = .verified {
        didSet {
            onSelectedAssetOption()
        }
    }

    let globalInfo = GlobalInfo.shared
    var mainVC: MainVC!
    var customerDetail: CustomerDetail!
    var equipmentWithAssArray = [EquipmentWithAss]()
    var currentEquipmentWithAssArray = [EquipmentWithAss]()
    var assetViewArray = [UIView]()
    var assetRadioLabelArray = [AnimatableLabel]()
    var isSearchExpanded = false

    var isExistSelectModel = false
    var repairDescCount = 0

    var selectedEquipment: Equipment?
    var selectedEquipAss: EquipAss?
    var selectedEquipmentWithAss: EquipmentWithAss? {
        didSet {
            selectedEquipment = selectedEquipmentWithAss?.equipment
            selectedEquipAss = selectedEquipmentWithAss?.equipAss
            onSelectedEquipmentWithAss()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
        initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        mainVC.setTitleBarText(title: L10n.assetManagement())
        reloadEquipments()
    }

    func initData() {
        // asset view array
        let repairDescArray = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "EQRPRREASN")
        repairDescCount = repairDescArray.count
    }

    func initUI() {
        verified.text = L10n.verified()
        foundAndDetailsUpdatedLabel.text = L10n.foundAndDetailsUpdated()
        notFound.text = L10n.notFound()
        serialNumberTitleLabel.text = L10n.serialNumber()
        alternativeAssetNumberTitleLabel.text = L10n.alternativeAssetNumber()
        makeTitleLabel.text = L10n.make()
        modelTitleLabel.text = L10n.model()
        locationInStoreTitleLabel.text = L10n.locationInStore()
        statusTitleLabel.text = L10n.Status()
        newAssetFoundButton.setTitleForAllState(title: L10n.newAssetFound())
        requestNewPlacementButton.setTitleForAllState(title: L10n.requestNewPlacement())
        doneButton.setTitleForAllState(title: L10n.Done())
        noDataLabel.text = L10n.thereIsNoData()
        
        searchText.delegate = self
        searchText.addTarget(self, action: #selector(AssetManagementVC.onSearchTextDidChanged), for: .editingChanged)
        searchText.returnKeyType = .done

        let screenBounds = UIScreen.main.bounds
        let rightMargin = -1*(screenBounds.width*11.5/16-190)
        searchViewRightConstraint.constant = rightMargin

        assetTableView.delegate = self
        assetTableView.dataSource = self

        assetRadioLabelArray = [verifiedLabel, foundUpdatedLabel, notFoundLabel]
        assetViewArray = [verifiedView, foundUpdatedView, notFoundView]
        for (index, view) in assetViewArray.enumerated() {
            view.tag = 400+index
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AssetManagementVC.onTapAssetView(_:)))
            view.addGestureRecognizer(tapGestureRecognizer)
        }
        selectedAssetOption = .verified

        centerView.tag = 400-1
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AssetManagementVC.onTapAssetView(_:)))
        centerView.addGestureRecognizer(tapGestureRecognizer)
    }

    func reloadEquipments() {

        let chainNo = customerDetail.chainNo ?? ""
        let custNo = customerDetail.custNo ?? ""
        let equipAssArray = EquipAss.getBy(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo)

        equipmentWithAssArray.removeAll()
        for equipAss in equipAssArray {
            let equipmentNo = equipAss.equipmentNo ?? ""
            let equipmentWithAss = EquipmentWithAss()
            equipmentWithAss.equipAss = equipAss
            let equipment = Equipment.getBy(context: globalInfo.managedObjectContext, equipmentNo: equipmentNo).first
            equipmentWithAss.equipment = equipment
            equipmentWithAssArray.append(equipmentWithAss)
        }
        isExistSelectModel = isExistEquipModel()

        let searchKey = searchText.text ?? ""
        currentEquipmentWithAssArray.removeAll()
        for equipmentWithAss in equipmentWithAssArray {
            let altEquipment = equipmentWithAss.equipment?.altEquipment ?? ""
            if searchKey.isEmpty == true || altEquipment.contains(searchKey) {
                let equipmentType = equipmentWithAss.equipment?.equipmentType ?? ""
                let status = equipmentWithAss.equipAss?.status ?? ""
                if equipmentType != "N" && status == "V" {
                    currentEquipmentWithAssArray.append(equipmentWithAss)
                }
            }
        }

        if selectedEquipmentWithAss == nil {
            selectedEquipmentWithAss = currentEquipmentWithAssArray.first
        }

        refreshAssets()
    }

    func isExistEquipModel() -> Bool {
        let equipAssArray = EquipAss.getBy(context: globalInfo.managedObjectContext, chainNo: "0", custNo: "0")
        var isExist = false
        for equipAss in equipAssArray {
            let equipmentNo = equipAss.equipmentNo ?? ""
            let equipmentArray = Equipment.getBy(context: globalInfo.managedObjectContext, equipmentNo: equipmentNo)
            if equipmentArray.count > 0 {
                isExist = true
                break;
            }
        }
        return isExist
    }

    func refreshAssets() {
        assetTableView.reloadData()
        if currentEquipmentWithAssArray.count == 0 {
            noDataLabel.isHidden = false
        }
        else {
            noDataLabel.isHidden = true
        }
    }

    @objc func onSearchTextDidChanged() {
        reloadEquipments()
    }

    func toggleSearchView(shouldExpand: Bool) {
        if shouldExpand == true {
            if isSearchExpanded == true {
                return
            }
            searchCloseButton.isHidden = false
            UIView.animate(withDuration: 1.0, animations: {
                self.searchViewRightConstraint.constant = 0
            }) { (completed) in
                self.isSearchExpanded = true
            }
        }
        else {
            let screenBounds = UIScreen.main.bounds
            let rightMargin = -1*(screenBounds.width*11.5/16-190)
            if isSearchExpanded == false {
                return
            }
            searchCloseButton.isHidden = true
            UIView.animate(withDuration: 1.0, animations: {
                self.searchViewRightConstraint.constant = rightMargin
            }) { (completed) in
                self.isSearchExpanded = false
                self.searchText.resignFirstResponder()
            }
        }
    }

    func onSelectedAssetOption() {
        for (_index, _) in assetViewArray.enumerated() {
            let radioLabel = assetRadioLabelArray[_index]
            if _index == selectedAssetOption.rawValue {
                radioLabel.backgroundColor = kOrderSalesOptionSelectedColor
            }
            else {
                radioLabel.backgroundColor = kOrderSalesOptionNormalColor
            }
        }

        if selectedAssetOption == .foundUpdated {
            serialNumberLabel.text = selectedEquipmentWithAss?.equipment?.serialNo ?? ""
        }
        else {
            serialNumberLabel.text = ""
        }
    }

    @objc func onTapAssetView(_ sender: Any) {
        guard let selectedEquipmentWithAss = self.selectedEquipmentWithAss else {return}
        let tapGestureRecognizer = sender as! UITapGestureRecognizer
        let view = tapGestureRecognizer.view!
        let index = view.tag-400

        if index == 0 {
            selectedEquipmentWithAss.equipAss.verified = "V"
        }
        else if index == 1 {
            selectedEquipmentWithAss.equipAss.verified = "U"
            Utils.showInput(vc: self, title: "Update Fridge Serial No", placeholder: L10n.uniqueAssetID(), enteredString: selectedEquipmentWithAss.equipment?.altEquipment ?? "", leftString: L10n.return(), middleString: "", rightString: L10n.update(), dismissHandler: { (returnCode, inputString) in
                if returnCode == InputDialogVC.ReturnCode.right {
                    selectedEquipmentWithAss.equipment?.altEquipment = inputString
                    GlobalInfo.saveCache()
                }
            })
        }
        else if index == 2 {
            selectedEquipmentWithAss.equipAss.verified = "N"
        }
        else {
            selectedEquipmentWithAss.equipAss.verified = ""
        }

        let equipment = selectedEquipmentWithAss.equipment!
        let equipmentType = equipment.equipmentType ?? ""
        if equipmentType.length > 0 && equipmentType != "V" {
            // Backup current equipment assInfo
            selectedEquipmentWithAss.equipAss.oldEquipmentType = equipmentType
            selectedEquipmentWithAss.equipAss.status = "I"

            let newEquipAss = EquipAss(context: globalInfo.managedObjectContext, forSave: true)
            newEquipAss.updateBy(theSource: selectedEquipmentWithAss.equipAss)

            let newEquipment = Equipment(context: globalInfo.managedObjectContext, forSave: false)
            newEquipment.updateBy(theSource: selectedEquipmentWithAss.equipment!)

            let equipementWithAss = EquipmentWithAss()
            equipementWithAss.equipAss = newEquipAss
            equipementWithAss.equipment = newEquipment

            equipmentWithAssArray.append(equipementWithAss)

            GlobalInfo.saveCache()
        }
        selectedEquipmentWithAss.equipAss.status = "V"
        let verified = selectedEquipmentWithAss.equipAss.verified ?? ""
        selectedEquipmentWithAss.equipment!.equipmentType = verified.length > 0 ? "V" : ""
        GlobalInfo.saveCache()

        selectedAssetOption = AssetOption(rawValue: index)!
    }

    func onSelectedEquipmentWithAss() {

        if selectedEquipmentWithAss == nil {
            centerView.isHidden = true
            noDataRightLabel.isHidden = false
            assetImageView.isHidden = true
            assetTitleLabel.isHidden = true
            repairButton.isHidden = true
            return
        }
        else {
            centerView.isHidden = false
            noDataRightLabel.isHidden = true
            assetImageView.isHidden = false
            assetTitleLabel.isHidden = false
            repairButton.isHidden = false
        }

        // update center view
        let verified = selectedEquipmentWithAss?.equipAss.verified ?? ""
        if verified == "" {
            selectedAssetOption = .none
        }
        else if verified == "V" {
            selectedAssetOption = .verified
        }
        else if verified == "U" {
            selectedAssetOption = .foundUpdated
        }
        else if verified == "N" {
            selectedAssetOption = .notFound
        }
        else {
            selectedAssetOption = .none
        }

        let verifyFlag = selectedEquipmentWithAss?.equipAss.verifyFlag ?? ""
        if verifyFlag.uppercased() == "Y" {

            for assetOptionView in assetViewArray {
                assetOptionView.isUserInteractionEnabled = true
            }
            centerView.isUserInteractionEnabled = true
        }
        else {
            for assetOptionView in assetViewArray {
                assetOptionView.isUserInteractionEnabled = false
            }
            centerView.isUserInteractionEnabled = false
        }

        // update right view
        assetImageView.image = selectedEquipmentWithAss!.equipment?.getEquipmentImage()
        let desc = selectedEquipmentWithAss!.equipment?.desc ?? ""
        let serialNo = selectedEquipmentWithAss!.equipment?.serialNo ?? ""
        assetTitleLabel.text = "\(desc)\n\(serialNo)"

        // update center view
        serialNumberLabel.text = selectedEquipment!.serialNo ?? ""
        alternativeAssetNumberLabel.text = selectedEquipment!.altEquipment ?? ""
        makeLabel.text = selectedEquipment!.make ?? ""

        let model = selectedEquipment!.model ?? ""
        let modelDescType = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "EQMODEL", alphaKey: model)
        modelLabel.text = modelDescType?.desc ?? ""

        let application = selectedEquipment!.application ?? ""
        let applicationDescType = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "EQAPP", numericKey: application)
        locationInStoreLabel.text = applicationDescType?.desc ?? ""

        let statusCode = selectedEquipment!.statusCode ?? ""
        let statusDescType = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "EQSTATUS", numericKey: statusCode)
        statusLabel.text = statusDescType?.desc ?? ""
    }

    func doRepair(equipmentWithAss: EquipmentWithAss) {
        let repairEquipmentVC = UIViewController.getViewController(storyboardName: "Asset", storyboardID: "RepairEquipmentVC") as! RepairEquipmentVC
        repairEquipmentVC.setDefaultModalPresentationStyle()
        repairEquipmentVC.customerDetail = customerDetail
        repairEquipmentVC.equipmentWithAss = equipmentWithAss
        repairEquipmentVC.dismissHandler = {vc, dismissOption in
            if dismissOption == .confirm {

            }
        }
        self.present(repairEquipmentVC, animated: true, completion: nil)
    }

    @IBAction func onRepair(_ sender: Any) {
        guard let equipmentWithAss = self.selectedEquipmentWithAss else {return}
        if repairDescCount == 0 {
            Utils.showAlert(vc: self, title: "", message: L10n.noEquipModel(), failed: false, customerName: "", leftString: "", middleString: "", rightString: L10n.ok(), dismissHandler: nil)
        }
        else {
            doRepair(equipmentWithAss: equipmentWithAss)
        }
    }

    @IBAction func onNewAsset(_ sender: Any) {

        if isExistSelectModel == true {
            let assetAddVC = UIViewController.getViewController(storyboardName: "Asset", storyboardID: "AssetAddVC") as! AssetAddVC
            assetAddVC.mainVC = mainVC
            assetAddVC.customerDetail = customerDetail
            mainVC.pushChild(newVC: assetAddVC, containerView: mainVC.containerView)
        }
        else {
            Utils.showAlert(vc: self, title: "", message: L10n.noEquipModel(), failed: false, customerName: "", leftString: "", middleString: "", rightString: L10n.ok(), dismissHandler: nil)
        }
    }

    @IBAction func onRequestNewPlacement(_ sender: Any) {

        if isExistSelectModel == true {
            let newAssetPlacementVC = UIViewController.getViewController(storyboardName: "Asset", storyboardID: "NewAssetPlacementVC") as! NewAssetPlacementVC
            newAssetPlacementVC.mainVC = mainVC
            newAssetPlacementVC.customerDetail = customerDetail
            mainVC.pushChild(newVC: newAssetPlacementVC, containerView: mainVC.containerView)
        }
        else {
            Utils.showAlert(vc: self, title: "", message: L10n.noEquipModel(), failed: false, customerName: "", leftString: "", middleString: "", rightString: L10n.ok(), dismissHandler: nil)
        }
    }

    @IBAction func onCloseSearch(_ sender: Any) {
        toggleSearchView(shouldExpand: false)
    }

    @IBAction func onDone(_ sender: Any) {

        let chainNo = customerDetail.chainNo ?? ""
        let custNo = customerDetail.custNo ?? ""
        let trip = globalInfo.routeControl?.trip ?? ""

        for equipmentWithAss in currentEquipmentWithAssArray {
            let verifyFlag = equipmentWithAss.equipAss.verifyFlag ?? ""
            let verified = equipmentWithAss.equipAss.verified ?? ""
            if verifyFlag == "Y" && verified.isEmpty == true {
                Utils.showAlert(vc: self, title: "", message: L10n.verifyEquip(), failed: false, customerName: "", leftString: "", middleString: "", rightString: L10n.ok(), dismissHandler: nil)
                return
            }
        }

        let uploadManager = globalInfo.uploadManager

        // need to prepare and upload info
        let now = Date()
        let transaction = UTransaction.make(chainNo: chainNo, custNo: custNo, docType: "Asset", date: now, reference: "", trip: trip)
        let trxnNo = transaction.trxnNo
        let trxnTime = transaction.trxnTime
        let trxnDate = transaction.trxnDate

        var arTrxnNo = "\(Date().getTimestamp())"
        while trxnNo == arTrxnNo {
            arTrxnNo = "\(Date().getTimestamp())"
        }

        /*
        let uar = UAR(context: globalInfo.managedObjectContext, forSave: true)
        uar.trxnNo = arTrxnNo
        uar.chainNo = customerDetail.chainNo ?? ""
        uar.custNo = customerDetail.custNo ?? ""
        uar.trxnDate = trxnDate
        uar.docType = "DEP"
        uar.trxnTime = trxnTime*/

        var isCollectionExist = false
        var fileTransactionArray = [FileTransaction]()
        var cameraTransactionArray = [CameraTransaction]()
        var transactionArray = [UTransaction]()
        transactionArray.append(transaction)

        var assetArray = [UAsset]()
        for equipmentWithAss in equipmentWithAssArray {
            let equipment = equipmentWithAss.equipment
            let equipAss = equipmentWithAss.equipAss!
            let equipmentType = equipment?.equipmentType ?? ""
            if equipmentType.isEmpty == false {
                let trxnDate = Date.fromTimeStamp(timeStamp: Int64(trxnNo) ?? 0)
                let trxnDateString = trxnDate.toDateString(format: kTightJustDateFormat) ?? ""
                let trxnTimeString = trxnDate.toDateString(format: kTightJustTimeFormat) ?? ""
                let uAsset = UAsset()
                uAsset.trxnNo = trxnNo
                uAsset.chainNo = equipAss.chainNo ?? ""
                uAsset.custNo = equipAss.custNo ?? ""

                if equipmentType == "N" || equipmentType == "A" {
                    uAsset.equipmentNo = equipAss.oldEquipmentNo ?? ""
                }
                else {
                    uAsset.equipmentNo = equipment?.equipmentNo ?? ""
                }
                uAsset.serialNo = equipment?.serialNo ?? ""
                let statusCode = equipment?.statusCode ?? ""
                if statusCode == "V" {
                    uAsset.equipmentType = equipment?.equipmentType ?? ""
                }
                else {
                    uAsset.equipmentType = equipAss.oldEquipmentType ?? ""
                }
                uAsset.make = equipment?.make ?? ""
                uAsset.model = equipment?.model ?? ""
                uAsset.application = equipment?.application ?? ""
                uAsset.statusCode = equipment?.statusCode ?? ""
                uAsset.assetType = equipment?.assetType ?? ""
                uAsset.requestDate = trxnDateString
                uAsset.repairReason = equipAss.repairReason ?? ""
                uAsset.repairNotes = equipAss.repairNotes ?? ""
                uAsset.response = equipAss.verified ?? ""
                uAsset.altEquipment = equipment?.altEquipment ?? ""
                uAsset.docType = "AST" + uAsset.equipmentType
                uAsset.voidFlag = "0"
                uAsset.printedFlag = "0"
                uAsset.trxnDate = trxnDateString
                uAsset.trxnTime = trxnTimeString
                uAsset.reference = ""
                uAsset.tCOMStatus = "0"
                uAsset.saleDate = trxnDateString

                let repairImage = equipAss.repairImage ?? ""
                let newReplacementDocPath = equipment?.newPlacementDocPath ?? ""

                let fileTrxnDate = Date()
                let fileTrxnDateString = fileTrxnDate.toDateString(format: kTightJustDateFormat) ?? ""
                let fileTrxnTimeString = fileTrxnDate.toDateString(format: kTightJustTimeFormat) ?? ""

                if equipmentType == "R" && repairImage.isEmpty == false {

                    let cameraTransaction = CameraTransaction.make(chainNo: chainNo, custNo: custNo, docType: "CAM", photoPath: repairImage, reference: "", trip: trip, date: fileTrxnDate)
                    cameraTransactionArray.append(cameraTransaction)
                    let transaction1 = cameraTransaction.makeTransaction()
                    transactionArray.append(transaction1)

                    let fileTransaction = FileTransaction.make(chainNo: chainNo, custNo: custNo, docType: "FARC", fileTrxnDate: fileTrxnDate, trip: trip, trnxDate: Date(), fileDocNo: "", fileShortDesc: "EQUIPREPAIR", fileLongDesc: "EQUIPREPAIR", fileCreateDate: fileTrxnDateString, fileCreateTime: fileTrxnTimeString, fileName: cameraTransaction.reference)
                    fileTransactionArray.append(fileTransaction)

                    uploadManager?.scheduleUpload(localFileName: cameraTransaction.reference, remoteFileName: cameraTransaction.reference, uploadItemType: .normalCustomerFile)
                }

                if equipmentType == "N" && newReplacementDocPath.isEmpty == false {
                    let pdfFileName = String.getFilenameFromPath(filePath: newReplacementDocPath)
                    let docNo = pdfFileName.components(separatedBy: ".").first ?? ""
                    uAsset.docNo = docNo
                    let fileTransaction = FileTransaction.make(chainNo: chainNo, custNo: custNo, docType: "FARC", fileTrxnDate: fileTrxnDate, trip: trip, trnxDate: Date(), fileDocNo: docNo, fileShortDesc: "EQUIPNEWPLACEMENT", fileLongDesc: "EQUIPMENT NEW PLACEMENT", fileCreateDate: fileTrxnDateString, fileCreateTime: fileTrxnTimeString, fileName: pdfFileName)
                    fileTransactionArray.append(fileTransaction)
                    let transaction1 = fileTransaction.makeTransaction()
                    transactionArray.append(transaction1)

                    uploadManager?.scheduleUpload(localFileName: kPDFDirName+"/"+fileTransaction.fileFileName, remoteFileName: fileTransaction.fileFileName, uploadItemType: .normalCustomerFile)
                }

                assetArray.append(uAsset)

                if equipmentType == "N" {
                    isCollectionExist = true
                }
            }
        }

        EquipCompleteStatus.setCompleted(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo, isCompleted: true)

        var zipFilePathArray = [String]()

        // GPS
        let gpsLog = GPSLog.make(chainNo: chainNo, custNo: custNo, docType: "GPS", date: Date(), location: globalInfo.getCurrentLocation())
        let gpsLogTransaction = gpsLog.makeTransaction()
        transactionArray.append(gpsLogTransaction)

        // Camera UTransaction
        let cameraTransactionPath = CameraTransaction.saveToXML(cameraArray: cameraTransactionArray)
        if cameraTransactionPath.isEmpty == false {
            zipFilePathArray.append(cameraTransactionPath)
        }

        // File UTransaction
        let fileTransactionPath = FileTransaction.saveToXML(fileTransactionArray: fileTransactionArray)
        if fileTransactionPath.isEmpty == false {
            zipFilePathArray.append(fileTransactionPath)
        }

        // Asset
        let assetPath = UAsset.saveToXML(assetArray: assetArray)
        if assetPath.isEmpty == false {
            zipFilePathArray.append(assetPath)
        }

        // GPS
        let gpsLogPath = GPSLog.saveToXML(gpsLogArray: [gpsLog])
        zipFilePathArray.append(gpsLogPath)

        // UTransaction
        let transactionPath = UTransaction.saveToXML(transactionArray: transactionArray, shouldIncludeLog: true)
        zipFilePathArray.append(transactionPath)

        uploadManager?.zipAndScheduleUpload(filePathArray: zipFilePathArray, completionHandler: nil)

        mainVC.popChild(containerView: mainVC.containerView)
    }

}

extension AssetManagementVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentEquipmentWithAssArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssetManagementAssetCell", for: indexPath) as! AssetManagementAssetCell
        cell.setupCell(parentVC: self, indexPath: indexPath)
        return cell
    }

}

extension AssetManagementVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }

}

extension AssetManagementVC: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        toggleSearchView(shouldExpand: true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {

    }
}

