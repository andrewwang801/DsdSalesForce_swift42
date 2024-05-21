//
//  RepairEquipmentVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 8/16/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class RepairEquipmentVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var faultButton: AnimatableButton!
    @IBOutlet weak var noteTextView: UITextView!

    let globalInfo = GlobalInfo.shared
    var customerDetail: CustomerDetail!
    var equipmentWithAss: EquipmentWithAss!
    var photoPath: String = ""

    var selectedRepairReasonDescType: DescType? {
        didSet {
            faultButton.setTitleForAllState(title: selectedRepairReasonDescType?.desc ?? "")
        }
    }

    var repairReasonDescTypeArray = [DescType]()
    var contactDocTextArray = [DocText]()

    enum DismissOption {
        case back
        case confirm
    }
    var dismissHandler: ((RepairEquipmentVC, DismissOption) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
        initUI()
        // Do any additional setup after loading the view.
    }

    func initUI() {

        noteTextView.text = equipmentWithAss.equipAss.repairNotes ?? ""
        customerNameLabel.text = customerDetail.name ?? ""

        // Location in store
        var isFound = false
        for descType in repairReasonDescTypeArray {
            let alphaKey = descType.alphaKey ?? ""
            let repairReason = equipmentWithAss.equipAss.repairReason ?? ""
            if alphaKey == repairReason {
                selectedRepairReasonDescType = descType
                isFound = true
                break
            }
        }
        if isFound == false {
            selectedRepairReasonDescType = nil
        }

        photoPath = equipmentWithAss.equipAss.repairImage ?? ""
    }

    func loadData() {
        repairReasonDescTypeArray = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "EQRPRREASN")
        contactDocTextArray = DocText.getBy(context: globalInfo.managedObjectContext, textType: "91")
    }

    /*
    func takePhoto() {

        let alert = UIAlertController(title: "Where's the image from?", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Use Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Use Photos", style: .default, handler: { _ in
            self.openGallary()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { _ in
        }))
        self.present(alert, animated: true, completion: nil)
    }*/

    @IBAction func onFault(_ sender: Any) {

        let menuComboVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "MenuComboPopoverVC") as! MenuComboPopoverVC
        menuComboVC.modalPresentationStyle = .popover

        let senderButton = sender as! UIButton

        let menuNames = repairReasonDescTypeArray.map { (descType) -> String in
            return descType.desc ?? ""
        }
        let menuItemCount = min(menuNames.count, 10)
        let totalHeight = kPopoverMenuCellHeight * CGFloat(menuItemCount)
        menuComboVC.preferredContentSize = CGSize(width: senderButton.bounds.width, height: totalHeight)
        menuComboVC.menuNamesArray = menuNames
        menuComboVC.dismissHandler = {vc, selectedIndex in
            self.selectedRepairReasonDescType = self.repairReasonDescTypeArray[selectedIndex]
        }

        let presentationPopoverVC = menuComboVC.popoverPresentationController
        presentationPopoverVC?.permittedArrowDirections = [.up, .down]
        presentationPopoverVC?.delegate = self
        presentationPopoverVC?.sourceView = senderButton
        presentationPopoverVC?.sourceRect = senderButton.bounds
        presentationPopoverVC?.backgroundColor = kPopoverMenuBackgroundColor
        self.present(menuComboVC, animated: true, completion: nil)
    }

    @IBAction func onContact(_ sender: Any) {
        var message = ""
        for docText in contactDocTextArray {
            message += (docText.docText ?? "") + "\n"
        }
        Utils.showAlert(vc: self, title: "REPAIR CONTACT DETAILS", message: message, failed: false, customerName: "", leftString: "Return", middleString: "", rightString: "", dismissHandler: nil)
    }

    @IBAction func onPhoto(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self

        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            imagePicker.setDefaultModalPresentationStyle()
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            SVProgressHUD.showInfo(withStatus: "You don't have camera")
        }
    }

    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?(self, .back)
        }
    }

    @IBAction func onConfirm(_ sender: Any) {
        let equipmentType = equipmentWithAss.equipment?.equipmentType ?? ""
        if equipmentType.length > 0 {
            equipmentWithAss.equipAss.oldEquipmentType = equipmentWithAss.equipment?.equipmentType
            equipmentWithAss.equipAss.status = "I"
            let newEquipAss = EquipAss(context: globalInfo.managedObjectContext, forSave: true)
            newEquipAss.updateBy(theSource: equipmentWithAss.equipAss)
        }
        equipmentWithAss.equipAss.status = "V"
        equipmentWithAss.equipment?.equipmentType = "R"
        equipmentWithAss.equipAss.repairReason = selectedRepairReasonDescType?.alphaKey ?? ""
        equipmentWithAss.equipAss.repairImage = photoPath
        equipmentWithAss.equipAss.repairNotes = noteTextView.text
        GlobalInfo.saveCache()

        self.dismiss(animated: true) {
            self.dismissHandler?(self, .confirm)
        }
    }

}

extension RepairEquipmentVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        let convertedImage = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: image.imageOrientation)
        picker.dismiss(animated: true) {
            self.processSaveImage(image: convertedImage)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
        }
    }

    func processSaveImage(image: UIImage) {
        let now = Date()
        let photoName = "\(now.getTimestamp()).jpg"
        let photoPath = CommData.getFilePathAppended(byCacheDir: photoName) ?? ""
        UIImage.saveImageToLocal(image: image, filePath: photoPath)
        self.photoPath = photoPath
    }

}

extension RepairEquipmentVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
