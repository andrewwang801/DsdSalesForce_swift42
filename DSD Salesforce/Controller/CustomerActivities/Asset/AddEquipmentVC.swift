//
//  AddEquipmentVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 8/13/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class AddEquipmentVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var equipmentNameLabel: UILabel!
    @IBOutlet weak var equipmentImageView: AnimatableImageView!
    @IBOutlet weak var serialNumberText: AnimatableTextField!
    @IBOutlet weak var altAssetNumberText: AnimatableTextField!
    @IBOutlet weak var makeText: AnimatableTextField!
    @IBOutlet weak var modelText: AnimatableTextField!
    @IBOutlet weak var locationInStoreButton: AnimatableButton!
    @IBOutlet weak var statusButton: AnimatableButton!
    @IBOutlet weak var assetTypeButton: AnimatableButton!

    let globalInfo = GlobalInfo.shared
    var customerDetail: CustomerDetail!
    var equipment: Equipment?
    var applicationDescTypeArray = [DescType]()
    var statusCodeDescTypeArray = [DescType]()
    var assetTypeDescTypeArray = [DescType]()
    var equipModelDescTypeArray = [DescType]()

    var selectedModelDescType: DescType? {
        didSet {
            modelText.text = selectedModelDescType?.desc ?? ""
        }
    }
    var selectedLocationInStoreDescType: DescType? {
        didSet {
            locationInStoreButton.setTitleForAllState(title: selectedLocationInStoreDescType?.desc ?? "")
        }
    }
    var selectedStatusDescType: DescType? {
        didSet {
            statusButton.setTitleForAllState(title: selectedStatusDescType?.desc ?? "")
        }
    }
    var selectedAssetTypeDescType: DescType? {
        didSet {
            assetTypeButton.setTitleForAllState(title: selectedAssetTypeDescType?.desc ?? "")
        }
    }

    enum DismissOption {
        case back
        case confirm
    }

    var dismissHandler: ((AddEquipmentVC, DismissOption) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadData()
        initUI()
    }

    func initUI() {
        customerNameLabel.text = customerDetail.name ?? ""
        altAssetNumberText.text = equipment?.altEquipment ?? ""
        let image = equipment?.getEquipmentImage()
        if image != nil {
            equipmentImageView.image = image
        }
        else {
            equipmentImageView.image = UIImage(named: "No_Image")
        }
        serialNumberText.text = equipment?.serialNo ?? ""
        makeText.text = equipment?.make ?? ""
        makeText.isEnabled = false
        modelText.isEnabled = false

        // Location in store
        var isFound = false
        for descType in applicationDescTypeArray {
            let numericKey = descType.numericKey ?? ""
            let application = equipment?.application ?? ""
            if numericKey == application {
                selectedLocationInStoreDescType = descType
                isFound = true
                break
            }
        }
        if isFound == false {
            selectedLocationInStoreDescType = nil
        }

        // Model
        isFound = false
        for descType in equipModelDescTypeArray {
            let alphaKey = descType.alphaKey ?? ""
            let model = equipment?.model ?? ""
            if alphaKey == model {
                selectedModelDescType = descType
                isFound = true
                break
            }
        }
        if isFound == false {
            selectedModelDescType = nil
        }

        // Status code
        isFound = false
        for descType in statusCodeDescTypeArray {
            let numericKey = descType.numericKey ?? ""
            let statusCode = equipment?.statusCode ?? ""
            if numericKey == statusCode {
                selectedStatusDescType = descType
                isFound = true
                break
            }
        }
        if isFound == false {
            selectedStatusDescType = nil
        }

        // Asset type
        isFound = false
        for descType in assetTypeDescTypeArray {
            let numericKey = descType.numericKey ?? ""
            let assetType = equipment?.assetType ?? ""
            if numericKey == assetType {
                selectedAssetTypeDescType = descType
                isFound = true
                break
            }
        }
        if isFound == false {
            selectedAssetTypeDescType = nil
        }
    }

    func loadData() {
        applicationDescTypeArray = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "EQAPP")
        statusCodeDescTypeArray = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "EQSTATUS")
        assetTypeDescTypeArray = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "EQASSTTYPE")
        equipModelDescTypeArray = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "EQMODEL")

    }

    @IBAction func onLocationInStore(_ sender: Any) {
        let menuComboVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "MenuComboPopoverVC") as! MenuComboPopoverVC
        menuComboVC.modalPresentationStyle = .popover

        let senderButton = sender as! UIButton

        let menuNames = applicationDescTypeArray.map { (descType) -> String in
            return descType.desc ?? ""
        }
        let menuItemCount = min(menuNames.count, 10)
        let totalHeight = kPopoverMenuCellHeight * CGFloat(menuItemCount)
        menuComboVC.preferredContentSize = CGSize(width: senderButton.bounds.width, height: totalHeight)
        menuComboVC.menuNamesArray = menuNames
        menuComboVC.dismissHandler = {vc, selectedIndex in
            self.selectedLocationInStoreDescType = self.applicationDescTypeArray[selectedIndex]
        }

        let presentationPopoverVC = menuComboVC.popoverPresentationController
        presentationPopoverVC?.permittedArrowDirections = [.up, .down]
        presentationPopoverVC?.delegate = self
        presentationPopoverVC?.sourceView = senderButton
        presentationPopoverVC?.sourceRect = senderButton.bounds
        presentationPopoverVC?.backgroundColor = kPopoverMenuBackgroundColor
        self.present(menuComboVC, animated: true, completion: nil)
    }

    @IBAction func onStatus(_ sender: Any) {
        let menuComboVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "MenuComboPopoverVC") as! MenuComboPopoverVC
        menuComboVC.modalPresentationStyle = .popover

        let senderButton = sender as! UIButton

        let menuNames = statusCodeDescTypeArray.map { (descType) -> String in
            return descType.desc ?? ""
        }
        let menuItemCount = min(menuNames.count, 10)
        let totalHeight = kPopoverMenuCellHeight * CGFloat(menuItemCount)
        menuComboVC.preferredContentSize = CGSize(width: senderButton.bounds.width, height: totalHeight)
        menuComboVC.menuNamesArray = menuNames
        menuComboVC.dismissHandler = {vc, selectedIndex in
            self.selectedStatusDescType = self.statusCodeDescTypeArray[selectedIndex]
        }

        let presentationPopoverVC = menuComboVC.popoverPresentationController
        presentationPopoverVC?.permittedArrowDirections = [.up, .down]
        presentationPopoverVC?.delegate = self
        presentationPopoverVC?.sourceView = senderButton
        presentationPopoverVC?.sourceRect = senderButton.bounds
        presentationPopoverVC?.backgroundColor = kPopoverMenuBackgroundColor
        self.present(menuComboVC, animated: true, completion: nil)
    }

    @IBAction func onAssetType(_ sender: Any) {
        let menuComboVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "MenuComboPopoverVC") as! MenuComboPopoverVC
        menuComboVC.modalPresentationStyle = .popover

        let senderButton = sender as! UIButton

        let menuNames = assetTypeDescTypeArray.map { (descType) -> String in
            return descType.desc ?? ""
        }
        let menuItemCount = min(menuNames.count, 10)
        let totalHeight = kPopoverMenuCellHeight * CGFloat(menuItemCount)
        menuComboVC.preferredContentSize = CGSize(width: senderButton.bounds.width, height: totalHeight)
        menuComboVC.menuNamesArray = menuNames
        menuComboVC.dismissHandler = {vc, selectedIndex in
            self.selectedAssetTypeDescType = self.assetTypeDescTypeArray[selectedIndex]
        }

        let presentationPopoverVC = menuComboVC.popoverPresentationController
        presentationPopoverVC?.permittedArrowDirections = [.up, .down]
        presentationPopoverVC?.delegate = self
        presentationPopoverVC?.sourceView = senderButton
        presentationPopoverVC?.sourceRect = senderButton.bounds
        presentationPopoverVC?.backgroundColor = kPopoverMenuBackgroundColor
        self.present(menuComboVC, animated: true, completion: nil)
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

    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?(self, .back)
        }
    }

    @IBAction func onConfirm(_ sender: Any) {

        // generate equip number
        let equipNo = makeEquipNumber()
        let oldEquipNo = equipment?.equipmentNo ?? ""

        let newEquipment = Equipment(context: globalInfo.managedObjectContext, forSave: true)
        newEquipment.updateBy(theSource: equipment!)
        newEquipment.equipmentNo = equipNo
        newEquipment.altEquipment = altAssetNumberText.text ?? ""
        newEquipment.serialNo = serialNumberText.text ?? ""
        newEquipment.make = makeText.text ?? ""
        newEquipment.model = selectedModelDescType?.alphaKey ?? ""
        newEquipment.application = selectedLocationInStoreDescType?.numericKey ?? ""
        newEquipment.statusCode = selectedStatusDescType?.numericKey ?? ""
        newEquipment.assetType = selectedAssetTypeDescType?.numericKey ?? ""
        newEquipment.equipmentType = "A"

        let equipAss = EquipAss(context: globalInfo.managedObjectContext, forSave: true)
        equipAss.chainNo = customerDetail.chainNo
        equipAss.custNo = customerDetail.custNo
        equipAss.equipmentNo = equipNo
        equipAss.oldEquipmentNo = oldEquipNo

        customerDetail.isAssetRequested = true

        GlobalInfo.saveCache()

        let newImagePath = newEquipment.getEquipmentImagePath()
        let oldImagePath = equipment?.getEquipmentImagePath() ?? ""

        let fileManager = FileManager.default
        try? fileManager.copyItem(atPath: oldImagePath, toPath: newImagePath)

        self.dismiss(animated: true) {
            self.dismissHandler?(self, .confirm)
        }
    }
}

extension AddEquipmentVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
