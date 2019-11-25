//
//  AssetAddVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/16/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class AssetAddVC: AssetAddBaseVC {

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var searchCloseButton: UIButton!
    @IBOutlet weak var searchViewRightMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var assetTableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var noDataRightLabel: UILabel!
    @IBOutlet weak var centerView: UIView!

    @IBOutlet weak var serialNoText: AnimatableTextField!
    @IBOutlet weak var alternativeAssetNoText: AnimatableTextField!
    @IBOutlet weak var makeLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var locationInStoreButton: AnimatableButton!
    @IBOutlet weak var statusButton: AnimatableButton!
    @IBOutlet weak var assetTypeButton: AnimatableButton!

    let globalInfo = GlobalInfo.shared
    var mainVC: MainVC!
    var customerDetail: CustomerDetail!
    var isSearchExpanded = false

    var locationInStoreDropDown = DropDown()
    var statusDropDown = DropDown()
    var assetTypeDropDown = DropDown()

    var locationInStoreDescTypeArray = [DescType]()
    var statusDescTypeArray = [DescType]()
    var assetTypeDescTypeArray = [DescType]()

    var selectedLocationInStoreDescType: DescType? {
        didSet {
            let applicationText = selectedLocationInStoreDescType?.desc ?? ""
            locationInStoreButton.setTitleForAllState(title: applicationText)
        }
    }

    var selectedStatusDescType: DescType? {
        didSet {
            let statusText = selectedStatusDescType?.desc ?? ""
            statusButton.setTitleForAllState(title: statusText)
        }
    }

    var selectedAssetTypeDescType: DescType? {
        didSet {
            let assetTypeText = selectedAssetTypeDescType?.desc ?? ""
            assetTypeButton.setTitleForAllState(title: assetTypeText)
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

        mainVC.setTitleBarText(title: "ADD ASSET")
        reload()
    }

    func initData() {
        locationInStoreDescTypeArray = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "EQAPP")
        statusDescTypeArray = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "EQSTATUS")
        assetTypeDescTypeArray = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "EQASSTTYPE")
    }

    func initUI() {
        // search view
        searchText.delegate = self
        searchText.addTarget(self, action: #selector(AssetAddVC.onSearchTextDidChanged), for: .editingChanged)
        searchText.returnKeyType = .done

        let screenBounds = UIScreen.main.bounds
        let rightMargin = -1 * screenBounds.width * 11 / 16
        searchViewRightMarginConstraint.constant = rightMargin

        assetTableView.delegate = self
        assetTableView.dataSource = self
        assetTableView.delaysContentTouches = false
        assetTableView.estimatedRowHeight = 0;

        serialNoText.addTarget(self, action: #selector(AssetAddVC.onSerialNoTextChanged(_:)), for: .editingChanged)
        alternativeAssetNoText.addTarget(self, action: #selector(AssetAddVC.onAlternativeAssetNoTextChanged(_:)), for: .editingChanged)

        setupDropDown()
    }

    func setupDropDown() {
        /// Location in store
        locationInStoreDropDown.cellHeight = locationInStoreButton.bounds.height
        locationInStoreDropDown.anchorView = locationInStoreButton
        locationInStoreDropDown.bottomOffset = CGPoint(x: 0, y: locationInStoreButton.bounds.height)
        locationInStoreDropDown.backgroundColor = UIColor.white
        locationInStoreDropDown.textFont = locationInStoreButton.titleLabel!.font

        let locationInStoreStringArray = locationInStoreDescTypeArray.map({ (descType) -> String in
            return descType.desc ?? ""
        })
        locationInStoreDropDown.dataSource = locationInStoreStringArray
        locationInStoreDropDown.cellNib = UINib(nibName: "GeneralDropDownCell", bundle: nil)
        locationInStoreDropDown.customCellConfiguration = {_index, item, cell in
        }
        locationInStoreDropDown.selectionAction = { index, item in
            self.selectedLocationInStoreDescType = self.locationInStoreDescTypeArray[index]
            if self.selectedEquipment != nil {
                self.selectedEquipment!.application = self.selectedLocationInStoreDescType?.numericKey
            }
        }

        /// Status
        statusDropDown.cellHeight = statusButton.bounds.height
        statusDropDown.anchorView = statusButton
        statusDropDown.bottomOffset = CGPoint(x: 0, y: statusButton.bounds.height)
        statusDropDown.backgroundColor = UIColor.white
        statusDropDown.textFont = statusButton.titleLabel!.font

        let statusStringArray = statusDescTypeArray.map({ (descType) -> String in
            return descType.desc ?? ""
        })
        statusDropDown.dataSource = statusStringArray
        statusDropDown.cellNib = UINib(nibName: "GeneralDropDownCell", bundle: nil)
        statusDropDown.customCellConfiguration = {_index, item, cell in
        }
        statusDropDown.selectionAction = { index, item in
            self.selectedStatusDescType = self.statusDescTypeArray[index]
            if self.selectedEquipment != nil {
                self.selectedEquipment!.statusCode = self.selectedStatusDescType?.numericKey
            }
        }

        /// Asset Type
        assetTypeDropDown.cellHeight = assetTypeButton.bounds.height
        assetTypeDropDown.anchorView = assetTypeButton
        assetTypeDropDown.bottomOffset = CGPoint(x: 0, y: statusButton.bounds.height)
        assetTypeDropDown.backgroundColor = UIColor.white
        assetTypeDropDown.textFont = assetTypeButton.titleLabel!.font

        let assetTypeStringArray = assetTypeDescTypeArray.map({ (descType) -> String in
            return descType.desc ?? ""
        })
        assetTypeDropDown.dataSource = assetTypeStringArray
        assetTypeDropDown.cellNib = UINib(nibName: "GeneralDropDownCell", bundle: nil)
        assetTypeDropDown.customCellConfiguration = {_index, item, cell in
        }
        assetTypeDropDown.selectionAction = { index, item in
            self.selectedAssetTypeDescType = self.assetTypeDescTypeArray[index]
            if self.selectedEquipment != nil {
                self.selectedEquipment!.assetType = self.selectedAssetTypeDescType?.numericKey
            }
        }
    }

    @objc func onSerialNoTextChanged(_ sender: Any) {
        if selectedEquipment == nil {
            return
        }
        let newSerialNo = serialNoText.text ?? ""
        selectedEquipment!.serialNo = newSerialNo
    }

    @objc func onAlternativeAssetNoTextChanged(_ sender: Any) {
        if selectedEquipment == nil {
            return
        }
        let altEquipment = alternativeAssetNoText.text ?? ""
        selectedEquipment!.altEquipment = altEquipment
    }

    func reload() {
        
        equipmentArray.removeAll()
        // load mode
        let equipAssArray = EquipAss.getBy(context: globalInfo.managedObjectContext, chainNo: "0", custNo: "0")
        for equipAss in equipAssArray {
            let equipmentNo = equipAss.equipmentNo ?? ""
            let equipArray = Equipment.getBy(context: globalInfo.managedObjectContext, equipmentNo: equipmentNo)
            if equipArray.count > 0 {
                let firstEquipment = equipArray.first!
                let clonedEquipment = Equipment(context: globalInfo.managedObjectContext, forSave: false)
                clonedEquipment.updateBy(theSource: firstEquipment)
                equipmentArray.append(firstEquipment)
            }
        }
        if selectedEquipment == nil {
            selectedEquipment = equipmentArray.first
        }
        refreshAssets()
    }

    override func refreshAssets() {
        super.refreshAssets()
        assetTableView.reloadData()
        if equipmentArray.count == 0 {
            noDataLabel.isHidden = false
        }
        else {
            noDataLabel.isHidden = true
        }
    }

    override func onSelectedEquipment() {
        super.onSelectedEquipment()
        if selectedEquipment == nil {
            centerView.isHidden = true
            noDataRightLabel.isHidden = false
            return
        }
        else {
            centerView.isHidden = false
            noDataRightLabel.isHidden = true
        }

        // update center view
        serialNoText.text = selectedEquipment!.serialNo ?? ""
        alternativeAssetNoText.text = selectedEquipment!.altEquipment ?? ""
        makeLabel.text = selectedEquipment!.make ?? ""

        let model = selectedEquipment!.model ?? ""
        let modelDescType = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "EQMODEL", alphaKey: model)
        modelLabel.text = modelDescType?.desc ?? ""

        let application = selectedEquipment!.application ?? ""
        let applicationDescType = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "EQAPP", numericKey: application)
        selectedLocationInStoreDescType = applicationDescType

        let statusCode = selectedEquipment!.statusCode ?? ""
        let statusDescType = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "EQSTATUS", numericKey: statusCode)
        selectedStatusDescType = statusDescType

        let assetType = selectedEquipment!.assetType ?? ""
        let assetTypeDescType = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "EQASSTTYPE", numericKey: assetType)
        selectedAssetTypeDescType = assetTypeDescType
    }

    func toggleSearchView(shouldExpand: Bool) {
        if shouldExpand == true {
            if isSearchExpanded == true {
                return
            }
            searchCloseButton.isHidden = false
            UIView.animate(withDuration: 1.0, animations: {
                self.searchViewRightMarginConstraint.constant = 0
            }) { (completed) in
                self.isSearchExpanded = true
            }
        }
        else {
            let screenBounds = UIScreen.main.bounds
            let rightMargin = -1 * screenBounds.width * 11 / 16
            if isSearchExpanded == false {
                return
            }
            searchCloseButton.isHidden = true
            UIView.animate(withDuration: 1.0, animations: {
                self.searchViewRightMarginConstraint.constant = rightMargin
            }) { (completed) in
                self.isSearchExpanded = false
                self.searchText.resignFirstResponder()
            }
        }
    }

    @objc func onSearchTextDidChanged() {
        reload()
    }

    func makeEquipNumber() -> String {
        var equipNumber = "9"
        let routeNumber = globalInfo.routeControl?.routeNumber ?? ""
        if routeNumber == "" {
            equipNumber += "000"
        }
        else if routeNumber.length == 1 {
            equipNumber += "00" + routeNumber
        }
        else if routeNumber.length == 2 {
            equipNumber += "0" + routeNumber
        }
        else {
            let lastEquipNumber = routeNumber.subString(startIndex: routeNumber.length-3, length: 3)
            equipNumber += lastEquipNumber
        }

        let now = Date()
        let y = now.toDateString(format: "yyyy") ?? ""
        let dayOfYear = now.dayOfYear
        let jjj = "\(dayOfYear)"

        let tripNumber = globalInfo.routeControl?.trip ?? ""
        let pdfSequenceNoKey = kPdfSequenceNoPrefix+tripNumber
        let pdfSequenceNo = Utils.getIntSetting(key: pdfSequenceNoKey)+1
        Utils.setIntSetting(key: pdfSequenceNoKey, value: pdfSequenceNo)

        let sss = "\(pdfSequenceNo)"
        equipNumber += y.subString(startIndex: 3, length: 1)
        if jjj.length == 0 {
            equipNumber += "000"
        }
        else if jjj.length == 1 {
            equipNumber += "00"+jjj
        }
        else if jjj.length == 2 {
            equipNumber += "0"+jjj
        }
        else {
            equipNumber += jjj.subString(startIndex: jjj.length-3, length: 3)
        }

        if sss.length == 0 {
            equipNumber += "00"
        }
        else if sss.length == 1 {
            equipNumber += "0"+sss
        }
        else {
            equipNumber += sss.subString(startIndex: sss.length-2, length: 2)
        }

        return equipNumber
    }

    func doConfirm() {

        if selectedEquipment == nil {
            return
        }

        let equipNo = makeEquipNumber()
        let oldEquipNo = selectedEquipment?.equipmentNo ?? ""

        let newEquipment = Equipment(context: globalInfo.managedObjectContext, forSave: true)
        newEquipment.updateBy(theSource: selectedEquipment!)
        newEquipment.equipmentNo = equipNo
        newEquipment.equipmentType = "A"

        let equipAss = EquipAss(context: globalInfo.managedObjectContext, forSave: true)
        equipAss.chainNo = customerDetail.chainNo
        equipAss.custNo = customerDetail.custNo
        equipAss.equipmentNo = equipNo
        equipAss.oldEquipmentNo = oldEquipNo

        customerDetail.isAssetRequested = true

        GlobalInfo.saveCache()
        /*
        let newImagePath = newEquipment.getEquipmentImagePath()
        let oldImagePath = equipment?.getEquipmentImagePath() ?? ""

        let fileManager = FileManager.default
        try? fileManager.copyItem(atPath: oldImagePath, toPath: newImagePath)*/
        self.mainVC.popChild(containerView: self.mainVC.containerView)
    }

    @IBAction func onCloseSearch(_ sender: Any) {
        toggleSearchView(shouldExpand: false)
    }

    @IBAction func onLocationInStore(_ sender: Any) {
        locationInStoreDropDown.show()
    }

    @IBAction func onStatus(_ sender: Any) {
        statusDropDown.show()
    }

    @IBAction func onAssetType(_ sender: Any) {
        assetTypeDropDown.show()
    }

    @IBAction func onDone(_ sender: Any) {
        if selectedEquipment == nil {
            Utils.showAlert(vc: self, title: "", message: "Please select Equipment Model", failed: false, customerName: "", leftString: "", middleString: "", rightString: "Ok", dismissHandler: nil)
        }
        else {
            doConfirm()
        }
    }

    @IBAction func onBack(_ sender: Any) {
        mainVC.popChild(containerView: mainVC.containerView)
    }

}

extension AssetAddVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return equipmentArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssetAddAssetCell", for: indexPath) as! AssetAddAssetCell
        cell.setupCell(parentVC: self, indexPath: indexPath)
        return cell
    }

}

extension AssetAddVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }

}

extension AssetAddVC: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        toggleSearchView(shouldExpand: true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {

    }

}
