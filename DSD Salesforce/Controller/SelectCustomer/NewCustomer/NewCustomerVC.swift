//
//  NewCustomerVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 8/1/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable
import SSZipArchive

class NewCustomerVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var deliveryDetailsLabel: UILabel!
    @IBOutlet weak var tripNoLabel: UILabel!
    @IBOutlet weak var prospectRadioLabel: AnimatableLabel!
    @IBOutlet weak var customerRadioLabel: AnimatableLabel!
    @IBOutlet weak var prospectView: UIView!
    @IBOutlet weak var customerView: UIView!
    @IBOutlet weak var companyNameText: AnimatableTextField!
    @IBOutlet weak var companyTaxIDText: AnimatableTextField!
    @IBOutlet weak var addressLine1Text: AnimatableTextField!
    @IBOutlet weak var addressLine2Text: AnimatableTextField!
    @IBOutlet weak var cityText: AnimatableTextField!
    @IBOutlet weak var stateText: AnimatableTextField!
    @IBOutlet weak var postcodeText: AnimatableTextField!
    @IBOutlet weak var phoneText: AnimatableTextField!
    @IBOutlet weak var deliveryFromText: AnimatableTextField!
    @IBOutlet weak var deliveryToText: AnimatableTextField!
    @IBOutlet weak var contactDetailsLabel: UILabel!
    @IBOutlet weak var contactTableView: UITableView!
    @IBOutlet weak var contactTableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var prospectLabel: UILabel!
    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var companyTaxIdLabel: UILabel!
    @IBOutlet weak var addressLine1Label: UILabel!
    @IBOutlet weak var addressLine2Label: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var postcodeLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var backButton: AnimatableButton!
    @IBOutlet weak var addButton: AnimatableButton!
    @IBOutlet weak var tripLabel: UILabel!
    @IBOutlet weak var deliveryFromLabel: UILabel!
    @IBOutlet weak var deliveryToLabel: UILabel!
    
    let globalInfo = GlobalInfo.shared

    var originalCustomerDetail: CustomerDetail?
    var customerDetail: CustomerDetail?
    var customerContactArray = [CustomerContact]()

    var deliveryFromDatePicker: UIDatePicker!
    var deliveryToDatePicker: UIDatePicker!

    var orderTypeRadioArray = [AnimatableLabel]()
    var orderTypeViewArray = [UIView]()

    enum OrderType: Int {
        case prospect = 0
        case customer = 1
    }

    var selectedOrderType: OrderType = .prospect {
        didSet {
            for i in 0..<2 {
                if selectedOrderType.rawValue == i {
                    orderTypeRadioArray[i].backgroundColor = kOrderSalesOptionSelectedColor
                }
                else {
                    orderTypeRadioArray[i].backgroundColor = kOrderSalesOptionNormalColor
                }
            }
        }
    }

    var kOrderTypeArray = ["P", "N"]

    enum DismissOption {
        case back
        case add
    }

    var dismissHandler: ((NewCustomerVC, DismissOption) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
        loadData()
    }

    func initUI() {
        titleLabel.text = L10n.newCustomerOrProspect()
        tripLabel.text = L10n.trip()
        prospectLabel.text = L10n.prospect()
        customerLabel.text = L10n.customer()
        companyNameLabel.text = L10n.companyName()
        companyTaxIdLabel.text = L10n.companyTaxID()
        addressLine1Label.text = L10n.addressLine1()
        addressLine2Label.text = L10n.addressLine2()
        cityLabel.text = L10n.city()
        stateLabel.text = L10n.state()
        postcodeLabel.text = L10n.zipCode()
        phoneLabel.text = L10n.phone()
        backButton.setTitleForAllState(title: L10n.Back())
        addButton.setTitleForAllState(title: L10n.add())
        deliveryFromLabel.text = L10n.deliveryFrom()
        deliveryToLabel.text = L10n.deliveryTo()
        
        orderTypeViewArray = [prospectView, customerView]
        orderTypeRadioArray = [prospectRadioLabel, customerRadioLabel]

        for i in 0..<2 {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NewCustomerVC.onTapOrderType(_:)))
            orderTypeViewArray[i].tag = 300+i
            orderTypeViewArray[i].addGestureRecognizer(tapGestureRecognizer)
        }

        contactTableView.delegate = self
        contactTableView.dataSource = self

        deliveryFromDatePicker = UIDatePicker()
        deliveryFromDatePicker.datePickerMode = .time
        deliveryFromText.inputView = deliveryFromDatePicker
        deliveryFromText.delegate = self

        let deliveryFromDismissAccessory = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 44))
        var itemCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(NewCustomerVC.onDeliveryFromCancel(_:)))
        var itemFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        var itemDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(NewCustomerVC.onDeliveryFromDone(_:)))
        deliveryFromDismissAccessory.items = [itemCancel, itemFlexibleSpace, itemDone]
        deliveryFromText.inputAccessoryView = deliveryFromDismissAccessory

        deliveryToDatePicker = UIDatePicker()
        deliveryToDatePicker.datePickerMode = .time
        deliveryToText.inputView = deliveryToDatePicker
        deliveryToText.delegate = self

        let deliveryToDismissAccessory = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 44))
        itemCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(NewCustomerVC.onDeliveryToCancel(_:)))
        itemFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        itemDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(NewCustomerVC.onDeliveryToDone(_:)))
        deliveryToDismissAccessory.items = [itemCancel, itemFlexibleSpace, itemDone]
        deliveryToText.inputAccessoryView = deliveryToDismissAccessory
    }

    func loadData() {

        if let originalCustomerDetail = self.originalCustomerDetail {

            customerDetail = CustomerDetail(context: globalInfo.managedObjectContext, forSave: false)
            customerDetail?.updateBy(theSource: originalCustomerDetail)

            let orderType = customerDetail!.orderType ?? ""
            if let orderTypeIndex = kOrderTypeArray.index(of: orderType) {
                selectedOrderType = OrderType(rawValue: orderTypeIndex)!
            }
            else {
                selectedOrderType = .prospect
            }

            deliveryDetailsLabel.text = customerDetail!.name ?? ""
            companyNameText.text = customerDetail!.name ?? ""
            companyTaxIDText.text = customerDetail!.companyTaxID ?? ""
            addressLine1Text.text = customerDetail!.address1 ?? ""
            addressLine2Text.text = customerDetail!.address2 ?? ""
            cityText.text = customerDetail!.city ?? ""
            stateText.text = customerDetail!.shipToState ?? ""
            postcodeText.text = customerDetail!.shipToZip ?? ""
            phoneText.text = customerDetail!.phone ?? ""

            var startTime = "0:0 AM"
            if let date = Date.fromDateString(dateString: customerDetail!.startTime1 ?? "", format: "kkmm") {
                startTime = date.toDateString(format: "h:mm a") ?? ""
            }
            deliveryFromText.text = startTime

            var endTime = "0:0 AM"
            if let date = Date.fromDateString(dateString: customerDetail!.endTime1 ?? "", format: "kkmm") {
                endTime = date.toDateString(format: "h:mm a") ?? ""
            }
            deliveryToText.text = endTime

            customerContactArray.removeAll()

            let chainNo = customerDetail!.chainNo ?? "0"
            let custNo = customerDetail!.custNo ?? "0"
            let contactArray = CustomerContact.getBy(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo)
            for contact in contactArray {
                let newContact = CustomerContact(context: globalInfo.managedObjectContext, forSave: false)
                newContact.updateBy(theSource: contact)
                customerContactArray.append(newContact)
            }

            titleLabel.text = L10n.editCustomerOrProspect()
            contactDetailsLabel.text = L10n.contactDetails()
            addButton.setTitleForAllState(title: L10n.Done())
        }
        else {
            let now = Date()
            let tempCustPrefix = Int(globalInfo.routeControl?.tempCustPrefix ?? "") ?? 0
            let ppp = tempCustPrefix.toLeftPaddedString(digitCount: 3) ?? ""
            let y = (now.toDateString(format: "yyyy") ?? "").subString(startIndex: 0, length: 3)
            let dayOfYear = now.dayOfYear
            let jjj = dayOfYear.toLeftPaddedString(digitCount: 3) ?? ""
            let todayString = now.toDateString(format: "yyyy-MM-dd") ?? ""

            if Utils.getStringSetting(key: kPrefToday) != todayString {
                Utils.setStringSetting(key: kPrefToday, value: todayString)
                Utils.setIntSetting(key: kPrefCustSeqNo, value: 0)
            }

            let custSeqNo = Utils.getIntSetting(key: kPrefCustSeqNo) + 1
            Utils.setIntSetting(key: kPrefCustSeqNo, value: custSeqNo)
            let ss = custSeqNo.toLeftPaddedString(digitCount: 2) ?? ""
            let custNo = ppp+y+jjj+ss
            let defCustNumber = globalInfo.routeControl?.templateCustomer ?? "0"
            let defChainNumber = globalInfo.routeControl?.templateChain ?? "0"

            let tempCustomerDetail = CustomerDetail.getBy(context: globalInfo.managedObjectContext, chainNo: defChainNumber, custNo: defCustNumber)

            let dayNo = "\(Utils.getWeekday(date: Date()))"

            let scheduledCustomers = CustomerDetail.getScheduled(context: globalInfo.managedObjectContext, dayNo: dayNo)
            let customerCount = scheduledCustomers.count

            customerDetail = CustomerDetail(context: globalInfo.managedObjectContext, forSave: false)
            customerDetail!.orderType = "P"
            if tempCustomerDetail != nil {
                customerDetail?.updateBy(theSource: tempCustomerDetail!)
            }

            customerDetail?.chainNo = globalInfo.routeControl?.tempCustChain ?? "0"
            customerDetail?.custNo = custNo
            customerDetail?.seqNo = "0"
            customerDetail?.orgSeqNo = "\(customerCount)"
            customerDetail?.startTime1 = "0000"
            customerDetail?.endTime1 = "0000"
            customerDetail?.isRouteScheduled = true
            customerDetail?.dayNo = dayNo

            // we will do it finally
            let customerContact = CustomerContact(context: globalInfo.managedObjectContext, forSave: false)
            customerContact.chainNo = customerDetail?.chainNo ?? "0"
            customerContact.custNo = customerDetail?.custNo ?? "0"
            customerContact.contactType = globalInfo.routeControl?.primeContact ?? "0"
            customerContactArray.removeAll()
            customerContactArray.append(customerContact)

            companyNameText.text = customerDetail!.name ?? ""
            companyTaxIDText.text = customerDetail!.companyTaxID ?? ""
            addressLine1Text.text = customerDetail!.address1 ?? ""
            addressLine2Text.text = customerDetail!.address2 ?? ""
            cityText.text = customerDetail!.city ?? ""
            stateText.text = customerDetail!.shipToState ?? ""
            postcodeText.text = customerDetail!.shipToZip ?? ""
            phoneText.text = customerDetail!.phone ?? ""

            selectedOrderType = .prospect

            var startTime = "0:0 AM"
            if let date = Date.fromDateString(dateString: customerDetail!.startTime1 ?? "", format: "kkmm") {
                startTime = date.toDateString(format: "h:mm a") ?? ""
            }
            deliveryFromText.text = startTime

            var endTime = "0:0 AM"
            if let date = Date.fromDateString(dateString: customerDetail!.endTime1 ?? "", format: "kkmm") {
                endTime = date.toDateString(format: "h:mm a") ?? ""
            }
            deliveryToText.text = endTime

            deliveryDetailsLabel.text = L10n.salesDetails()
            titleLabel.text = L10n.newCustomerOrProspect()
            contactDetailsLabel.text = L10n.primaryContact()
            addButton.setTitleForAllState(title: L10n.add())
        }

        if originalCustomerDetail == nil {
            contactTableHeightConstraint.constant = CGFloat(customerContactArray.count)*kNewCustomerContactCellHeight
        }
        else {
            contactTableHeightConstraint.constant = CGFloat(customerContactArray.count)*(kNewCustomerContactCellHeight+kNewCustomerContactTypeHeight)
        }

        let tripNumber = globalInfo.routeControl?.trip ?? ""
        tripNoLabel.text = "\(L10n.trip()) # \(tripNumber)"
        contactTableView.reloadData()
    }

    @objc func onDeliveryFromCancel(_ sender: Any) {
        deliveryFromText.resignFirstResponder()
    }

    @objc func onDeliveryFromDone(_ sender: Any) {
        let selectedDate = deliveryFromDatePicker.date
        deliveryFromText.text = selectedDate.toDateString(format: "h:mm a")
        deliveryFromText.resignFirstResponder()
    }

    @objc func onDeliveryToCancel(_ sender: Any) {
        deliveryToText.resignFirstResponder()
    }

    @objc func onDeliveryToDone(_ sender: Any) {
        let selectedDate = deliveryToDatePicker.date
        deliveryToText.text = selectedDate.toDateString(format: "h:mm a")
        deliveryToText.resignFirstResponder()
    }

    @objc func onTapOrderType(_ sender: Any) {
        let gestureRecognizer = sender as! UITapGestureRecognizer
        let view = gestureRecognizer.view!
        let index = view.tag-300
        selectedOrderType = OrderType(rawValue: index)!
    }

    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?(self, .back)
        }
    }

    @IBAction func onAdd(_ sender: Any) {

        let kPromptMandatoryMessage = "Please input all mandatory fields"
        customerDetail!.name = companyNameText.text ?? ""
        if customerDetail!.name?.isEmpty == true {
            SVProgressHUD.showInfo(withStatus: kPromptMandatoryMessage)
            companyNameText.becomeFirstResponder()
            return
        }
        customerDetail!.companyTaxID = companyTaxIDText.text ?? ""
        customerDetail!.address1 = addressLine1Text.text ?? ""
        if customerDetail!.address1!.isEmpty == true {
            SVProgressHUD.showInfo(withStatus: kPromptMandatoryMessage)
            addressLine1Text.becomeFirstResponder()
            return
        }
        customerDetail!.address2 = addressLine2Text.text ?? ""

        customerDetail!.city = cityText.text ?? ""
        if customerDetail!.city!.isEmpty == true {
            SVProgressHUD.showInfo(withStatus: kPromptMandatoryMessage)
            cityText.becomeFirstResponder()
            return
        }

        customerDetail!.shipToState = stateText.text ?? ""
        if customerDetail!.shipToState!.isEmpty == true {
            SVProgressHUD.showInfo(withStatus: kPromptMandatoryMessage)
            stateText.becomeFirstResponder()
            return
        }

        customerDetail!.shipToZip = postcodeText.text ?? ""
        if customerDetail!.shipToZip!.isEmpty == true {
            SVProgressHUD.showInfo(withStatus: kPromptMandatoryMessage)
            postcodeText.becomeFirstResponder()
            return
        }

        for (index, customerContact) in customerContactArray.enumerated() {
            let contactName = customerContact.contactName ?? ""
            let contactEmail = customerContact.contactEmailAddress ?? ""
            let contactPhone = customerContact.contactPhoneNumber ?? ""
            if contactName.isEmpty || contactEmail.isEmpty || contactPhone.isEmpty {
                SVProgressHUD.showInfo(withStatus: kPromptMandatoryMessage)
                contactTableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: true)
                return
            }
        }

        customerDetail!.orderType = kOrderTypeArray[selectedOrderType.rawValue]
        customerDetail!.phone = phoneText.text ?? ""
        self.view.endEditing(true)

        let deliveryFrom = deliveryFromText.text ?? ""
        var date = Date.fromDateString(dateString: deliveryFrom, format: "h:mm a") ?? Date()
        customerDetail!.startTime1 = date.toDateString(format: "kkmm") ?? ""

        let deliveryTo = deliveryToText.text ?? ""
        date = Date.fromDateString(dateString: deliveryTo, format: "h:mm a") ?? Date()
        customerDetail!.endTime1 = date.toDateString(format: "kkmm") ?? ""

        // transaction files
        processUploadFiles()

        // save customer and routeschedule
        if originalCustomerDetail == nil {

            // resort previous customers
            let dayNo = "\(Utils.getWeekday(date: Date()))"
            let routeScheduleCustomers = CustomerDetail.getScheduled(context: globalInfo.managedObjectContext, dayNo: dayNo)
            for customer in routeScheduleCustomers {
                customer.orderNo += 1
            }

            originalCustomerDetail = CustomerDetail(context: globalInfo.managedObjectContext, forSave: true)
            originalCustomerDetail?.updateBy(theSource: customerDetail!)

            // save customer updated
            originalCustomerDetail?.isCustomerUpdated = true

            for contact in customerContactArray {
                let savedContact = CustomerContact(context: globalInfo.managedObjectContext, forSave: true)
                savedContact.updateBy(theSource: contact)
            }

            let newCustomers = Utils.getIntSetting(key: kNewCustomersToday)
            Utils.setIntSetting(key: kNewCustomersToday, value: newCustomers+1)

            GlobalInfo.saveCache()
        }
        else {
            originalCustomerDetail?.updateBy(theSource: customerDetail!)

            // save customer updated
            originalCustomerDetail?.isCustomerUpdated = true

            // remove original contact
            let originalContactArray = CustomerContact.getBy(context: globalInfo.managedObjectContext, chainNo: customerDetail!.chainNo ?? "", custNo: customerDetail!.custNo ?? "")
            for contact in originalContactArray {
                CustomerContact.delete(context: globalInfo.managedObjectContext, customerContact: contact)
            }

            // add customer contact array
            for contact in customerContactArray {
                let savedContact = CustomerContact(context: globalInfo.managedObjectContext, forSave: true)
                savedContact.updateBy(theSource: contact)
            }

            GlobalInfo.saveCache()
        }

        self.dismiss(animated: true) {
            self.dismissHandler?(self, .add)
        }
    }

    func processUploadFiles() {

        let now = Date()
        let nowString = now.toDateString(format: kTightFullDateFormat) ?? ""
        let trxnDate = now.toDateString(format: kTightJustDateFormat) ?? ""
        let trxnTime = now.toDateString(format: kTightJustTimeFormat) ?? ""
        let trxnNo = "\(now.getTimestamp())"

        let customerFM = CustomerFM()
        let chainNo = customerDetail!.chainNo ?? "0"
        let custNo = customerDetail!.custNo ?? "0"
        customerFM.chainNo = chainNo
        customerFM.custNo = custNo
        customerFM.editType = originalCustomerDetail == nil ? "ADD" : "EDT"
        customerFM.voidFlag = "0"
        customerFM.printedFlag = "0"
        customerFM.tCOMStatus = "0"
        customerFM.name = customerDetail!.name ?? ""
        customerFM.taxID = customerDetail!.companyTaxID ?? ""
        customerFM.address1 = customerDetail!.address1 ?? ""
        customerFM.address2 = customerDetail!.address2 ?? ""
        customerFM.city = customerDetail!.city ?? ""
        customerFM.shipToState = customerDetail!.shipToState ?? ""
        customerFM.shipToZip = customerDetail!.shipToZip ?? ""
        customerFM.phone = customerDetail!.phone ?? ""
        customerFM.orderType = customerDetail!.orderType ?? ""

        for contact in customerContactArray {
            let contactFM = CustomerContactFM()
            contactFM.contactType = contact.contactType ?? ""
            contactFM.contactName = contact.contactName ?? ""
            contactFM.contactEmailAddress = contact.contactEmailAddress ?? ""
            contactFM.contactPhoneNumber = contact.contactPhoneNumber ?? ""
            customerFM.contactFMArray.append(contactFM)
        }

        customerFM.docType = "CSFM"
        customerFM.trxnNo = trxnNo
        customerFM.trxnDate = trxnDate
        customerFM.trxnTime = trxnTime
        customerFM.startDate = trxnDate
        customerFM.startTime = trxnTime
        customerFM.endDate = trxnDate
        customerFM.endTime = trxnTime

        customerFM.deliveryWindowFrom = customerDetail!.startTime1 ?? ""
        customerFM.deliveryWindowTo = customerDetail!.endTime1 ?? ""

        let customerFMPath = CommData.getFilePathAppended(byDocumentDir: "CustomerFM\(nowString).upl") ?? ""
        CustomerFM.saveToXML(customerFMArray: [customerFM], filePath: customerFMPath)

        // make a transaction structure
        let customerFMTransaction = UTransaction.make(chainNo: chainNo, custNo: custNo, docType: "CSFM", date: now, reference: "", trip: globalInfo.routeControl?.trip ?? "")

        // GPS Log
        let gpsLog = GPSLog.make(chainNo: customerDetail!.chainNo ?? "", custNo: customerDetail!.custNo ?? "", docType: "GPS", date: now, location: globalInfo.getCurrentLocation())
        let gpsLogTransaction = gpsLog.makeTransaction()
        let gpsLogPath = GPSLog.saveToXML(gpsLogArray: [gpsLog])

        let transactionPath = UTransaction.saveToXML(transactionArray: [customerFMTransaction, gpsLogTransaction], shouldIncludeLog: true)

        globalInfo.uploadManager.zipAndScheduleUpload(filePathArray: [customerFMPath, gpsLogPath, transactionPath], completionHandler: nil)
    }

}

extension NewCustomerVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customerContactArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewCustomerContactCell", for: indexPath) as! NewCustomerContactCell
        cell.setupCell(parentVC: self, indexPath: indexPath)
        return cell
    }

}

extension NewCustomerVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if originalCustomerDetail == nil {
            return kNewCustomerContactCellHeight
        }
        else {
            return kNewCustomerContactCellHeight+kNewCustomerContactTypeHeight
        }
    }

}

extension NewCustomerVC: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {

        if textField == deliveryFromText {
            let date = Date.fromDateString(dateString: textField.text ?? "", format: "h:mm a") ?? Date()
            deliveryFromDatePicker.date = date
        }
        else if textField == deliveryToText {
            let date = Date.fromDateString(dateString: textField.text ?? "", format: "h:mm a") ?? Date()
            deliveryToDatePicker.date = date
        }

    }
}
