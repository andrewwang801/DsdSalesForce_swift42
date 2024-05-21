//
//  SelectCustomerDetailsVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/5/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import SSZipArchive

class SelectCustomerDetailsVC: UIViewController {

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var numberLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var contactTableView: UITableView!
    @IBOutlet weak var locateButton: UIButton!
    @IBOutlet weak var testImageView: UIImageView!

    @IBOutlet weak var lastVisitedLabel: UILabel!
    @IBOutlet weak var lastOrderLabel: UILabel!
    @IBOutlet weak var availableCreditLabel: UILabel!
    @IBOutlet weak var currentMonthSalesLabel: UILabel!

    @IBOutlet weak var lastVisitedTitleLabel: UILabel!
    @IBOutlet weak var lastOrderTitleLabel: UILabel!
    @IBOutlet weak var availableCreditTitleLabel: UILabel!
    @IBOutlet weak var currentMonthSalesTitleLabel: UILabel!

    let globalInfo = GlobalInfo.shared
    var selectCustomerVC: SelectCustomerVC!
    var contactArray = [CustomerContact]()
    var otherInfoTitleArray = [String]()
    var otherInfoValueArray = [String]()

    var infoTypeTitleLabelArray = [UILabel]()
    var infoTypeLabelArray = [UILabel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(SelectCustomerDetailsVC.updateUIProgress), name: NSNotification.Name(rawValue: kCustomerSelectedNotificationName), object: nil)

        initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateUIProgress()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isBeingDismissed == true || isMovingFromParent == true {
            NotificationCenter.default.removeObserver(self)
        }
    }

    func initUI() {
        lastVisitedTitleLabel.text = L10n.lastVisitedOn()
        lastOrderTitleLabel.text = L10n.lastOrderOn()
        availableCreditTitleLabel.text = L10n.availableCredit()
        currentMonthSalesTitleLabel.text = L10n.currentMonthSales()
        
        contactTableView.dataSource = self
        contactTableView.delegate = self

        infoTypeTitleLabelArray = [lastVisitedTitleLabel, lastOrderTitleLabel, availableCreditTitleLabel, currentMonthSalesTitleLabel]
        infoTypeLabelArray = [lastVisitedLabel, lastOrderLabel, availableCreditLabel, currentMonthSalesLabel]
    }

    @objc func updateUIProgress () {
        
        //let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow, animated: true)
            
        DispatchQueue.main.async {
            self.updateUI()
            //hud?.hide(true)
        }
        
    }
    
    @objc func updateUI() {

        guard let selectedCustomerDetails = selectCustomerVC.selectedCustomer else {return}

        updateCustomerContact()

        let selectedPresoldOrHeader = selectCustomerVC.selectedPresoldOrHeader

        let tagNo = selectedCustomerDetails.getCustomerTag()
        if selectedCustomerDetails.altCustNo != "" {
            numberLabel.text = selectedCustomerDetails.altCustNo
        }
        else {
            numberLabel.text = tagNo
        }
        let estimatedWidth = tagNo.width(withConstraintedHeight: numberLabel.bounds.width, attributes: [NSAttributedString.Key.font: numberLabel.font])
        //numberLabelWidthConstraint.constant = estimatedWidth+20

        let custTitle = selectedCustomerDetails.getCustomerTitle()
        titleLabel.text = custTitle

        // address view
        let address = selectedCustomerDetails.getTotalAddress()
        addressLabel.text = address

        // phone
        let phone = selectedCustomerDetails.phone ?? ""
        phoneLabel.text = phone

        // email
        let email = ""
        emailLabel.text = email

        updatePanels()

        updateTopRightButtons()
    }

    func updateCustomerContact() {

        guard let selectedCustomerDetails = selectCustomerVC.selectedCustomer else {return}

        // contact
        contactArray.removeAll()

        let custNo = selectedCustomerDetails.custNo ?? ""
        let chainNo = selectedCustomerDetails.chainNo ?? ""
        contactArray = CustomerContact.getBy(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo)

        // other info
        otherInfoTitleArray.removeAll()
        otherInfoValueArray.removeAll()

        // Terms
        var descType: DescType!
        let customerTerms = selectedCustomerDetails.terms ?? ""
        if customerTerms.trimed() != "" && customerTerms != "0" {
            descType = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "TermsCode", alphaKey: customerTerms)
            if descType != nil {
                otherInfoTitleArray.append("Terms")
                otherInfoValueArray.append(descType!.desc ?? "")
            }
        }

        // Price Group
        let priceGroup = CustInfo.getBy(context: globalInfo.managedObjectContext, infoType: "15", custNo: custNo)?.info ?? ""
        if priceGroup.trimed() != "" {
            otherInfoTitleArray.append("Price Group")
            otherInfoValueArray.append(priceGroup)
        }
        
        // Price Group
//        let priceGroup = selectedCustomerDetails.priceGrp ?? ""
//        if priceGroup.trimed() != "" && priceGroup != "0" {
//            descType = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "PriceGroup", numericKey: priceGroup)
//            if descType != nil {
//                otherInfoTitleArray.append("Price Group")
//                otherInfoValueArray.append(descType!.desc ?? "")
//            }
//        }

        // Visit
        let deliveryFrequency = selectedCustomerDetails.delivFreq ?? ""
        if deliveryFrequency.trimed() != "" && deliveryFrequency != "0" {
            descType = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "DeliveryFrequency", numericKey: deliveryFrequency)
            if descType != nil {
                otherInfoTitleArray.append("Visit")
                otherInfoValueArray.append(descType!.desc ?? "")
            }
        }

        // Store No
        let storeNo = selectedCustomerDetails.storeNo ?? ""
        if storeNo.isEmpty == false {
            otherInfoTitleArray.append("Store No")
            otherInfoValueArray.append(storeNo)
        }

        contactTableView.reloadData()
    }

    func updatePanels() {

        let routeCtlProfile = globalInfo.routeControl?.profile ?? ""
        let infoTypeArray = routeCtlProfile.components(separatedBy: ",")
        if routeCtlProfile == "" || infoTypeArray.count == 0 {
            for i in 0..<4 {
                infoTypeTitleLabelArray[i].text = ""
                infoTypeLabelArray[i].text = ""
            }
        }
        else {
            let custNo = selectCustomerVC.selectedCustomer?.custNo ?? ""
            for (i, infoType) in infoTypeArray.enumerated() {
                let infoTypeTitleDescType = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "CUSTINFO", numericKey: infoType)
                let infoTypeTitle = infoTypeTitleDescType?.desc ?? ""
                let custInfo = CustInfo.getBy(context: globalInfo.managedObjectContext, infoType: infoType, custNo: custNo)
                let infoTypeValue = custInfo?.info ?? ""
                
                var textColor = UIColor.black
                switch infoTypeTitleDescType?.value1 {
                case "Red":
                    textColor = UIColor.red
                    break
                case "Black":
                    textColor = UIColor.black
                    break
                case "Green":
                    textColor = UIColor.green
                    break
                default:
                    textColor = UIColor.black
                    break
                }
                infoTypeTitleLabelArray[i].text = infoTypeTitle
                infoTypeLabelArray[i].text = infoTypeValue
                infoTypeLabelArray[i].textColor = textColor
            }
        }

    }

    func updateTopRightButtons() {

        guard let selectedCustomer = selectCustomerVC.selectedCustomer else {return}
        let custNo = selectedCustomer.custNo ?? "0"

        let driverLat = Double(selectedCustomer.driverLatitude ?? "0") ?? 0
        let driverLon = Double(selectedCustomer.driverLongitude ?? "0") ?? 0

        locateButton.isEnabled = true
        if driverLat == 0 || driverLon == 0 {
            let lat = Double(selectedCustomer.latitude ?? "0") ?? 0
            let lon = Double(selectedCustomer.longitude ?? "0") ?? 0
            if lat == 0 || lon == 0 {
                locateButton.isEnabled = false
            }
        }

    }

    @IBAction func onEditCustomer(_ sender: Any) {
        guard let selectedCustomer = selectCustomerVC.selectedCustomer else {return}
        let newCustomerVC = UIViewController.getViewController(storyboardName: "NewCustomer", storyboardID: "NewCustomerVC") as! NewCustomerVC
        newCustomerVC.originalCustomerDetail = selectedCustomer
        newCustomerVC.setDefaultModalPresentationStyle()
        newCustomerVC.dismissHandler = {vc, dismissOption in
            self.selectCustomerVC.reloadCustomers()
            self.updateUIProgress()
        }
        self.present(newCustomerVC, animated: true, completion: nil)
    }

    @IBAction func onCapture(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self

        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            imagePicker.setDefaultModalPresentationStyle()
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            SVProgressHUD.showInfo(withStatus: L10n.youDonTHaveCamera())
        }
    }

    @IBAction func onLocateCustomer(_ sender: Any) {
        guard let selectedCustomer = selectCustomerVC.selectedCustomer else {return}

        var lat: Double = 0
        var lon: Double = 0
        lat = Double(selectedCustomer.driverLatitude ?? "0") ?? 0
        lon = Double(selectedCustomer.driverLongitude ?? "0") ?? 0

        if lat == 0 || lon == 0 {
            lat = Double(selectedCustomer.latitude ?? "0") ?? 0
            lon = Double(selectedCustomer.longitude ?? "0") ?? 0
            if lat == 0 || lon == 0 {
                return
            }
        }

        let locationVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "CustomerLocationVC") as! CustomerLocationVC
        locationVC.latitude = lat
        locationVC.longitude = lon
        locationVC.setDefaultModalPresentationStyle()
        self.present(locationVC, animated: true, completion: nil)
    }
}

extension SelectCustomerDetailsVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactArray.count+otherInfoTitleArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        if index < contactArray.count {
            let contact = contactArray[index]
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerContactCell", for: indexPath) as! CustomerContactCell

            let contactTypeDesc = contact.contactTypeDesc ?? ""
            if contactTypeDesc.isEmpty == false {
                cell.typeLabel.text = contactTypeDesc + ":"
            }
            else {
                cell.typeLabel.text = ""
            }
            cell.nameLabel.text = contact.contactName ?? ""

            let phoneNumber = contact.contactPhoneNumber ?? ""
            if phoneNumber.isEmpty == true {
                cell.phoneView.isHidden = true
                cell.phoneWidthConstraint.constant = 0
            }
            else {
                cell.phoneView.isHidden = false
                cell.phoneWidthConstraint.constant = 200
            }
            cell.phoneLabel.text = contact.contactPhoneNumber ?? ""

            let email = contact.contactEmailAddress ?? ""
            if email.isEmpty == true {
                cell.emailView.isHidden = true
                cell.emailWidthConstraint.constant = 0
            }
            else {
                cell.emailView.isHidden = false
                cell.emailWidthConstraint.constant = 200
            }
            cell.emailLabel.text = contact.contactEmailAddress ?? ""

            return cell
        }
        else {
            let realIndex = index - contactArray.count
            let otherInfoTitle = otherInfoTitleArray[realIndex]
            let otherInfoValue = otherInfoValueArray[realIndex]
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerOtherInfoCell", for: indexPath) as! CustomerOtherInfoCell
            cell.titleLabel.text = otherInfoTitle
            cell.valueLabel.text = otherInfoValue
            return cell
        }
    }

}

extension SelectCustomerDetailsVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

}

extension SelectCustomerDetailsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
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

        guard let selectedCustomer = selectCustomerVC.selectedCustomer else {return}

        let custNo = selectedCustomer.custNo ?? "0"
        let chainNo = selectedCustomer.chainNo ?? "0"

        let now = Date()
        let nowString = now.toDateString(format: kTightFullDateFormat) ?? ""

        // save a image in the local area
        let reference = selectedCustomer.getImageName()
        let localImageName = "\(nowString).jpg"
        let imagePath = CommData.getFilePathAppended(byCacheDir: localImageName)
        UIImage.saveImageToLocal(image: image, filePath: imagePath!)

        // make a camera transaction structure
        let cameraTransaction = CameraTransaction.make(chainNo: chainNo, custNo: custNo, docType: "MAIT", reference: reference, date: now)
        let cameraTransactionPath = CameraTransaction.saveToXML(cameraArray: [cameraTransaction])

        // make a transaction structure
        let camera_transaction = UTransaction.make(chainNo: chainNo, custNo: custNo, docType: "MAIT", date: now, reference: reference, trip: globalInfo.routeControl?.trip ?? "")

        let gpsLog = GPSLog.make(chainNo: chainNo, custNo: custNo, docType: "GPS", date: now, location: globalInfo.getCurrentLocation())
        let gpsLogTransaction = gpsLog.makeTransaction()

        let gpsLogPath = GPSLog.saveToXML(gpsLogArray: [gpsLog])

        let transactionPath = UTransaction.saveToXML(transactionArray: [camera_transaction, gpsLogTransaction], shouldIncludeLog: true)

        let uploadManager = self.globalInfo.uploadManager
        uploadManager?.zipAndScheduleUpload(filePathArray: [cameraTransactionPath, gpsLogPath, transactionPath], completionHandler: nil)

        uploadManager?.scheduleUpload(localFileName: localImageName, remoteFileName: reference, uploadItemType: .customerCatalog)

        uploadManager?.startIfNeeded(completionHandler: nil)
    }

}
