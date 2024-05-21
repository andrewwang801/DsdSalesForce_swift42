//
//  OrderSummaryVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/11/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable
import WebKit

class OrderSummaryVC: UIViewController {

    @IBOutlet weak var headerView: UIView!

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cashView: UIView!
    @IBOutlet weak var chequeView: UIView!
    @IBOutlet weak var cardRadioLabel: AnimatableLabel!
    @IBOutlet weak var cashRadioLabel: AnimatableLabel!
    @IBOutlet weak var chequeRadioLabel: AnimatableLabel!
    @IBOutlet weak var cardViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var salesCountLabel: UILabel!
    @IBOutlet weak var returnsCountLabel: UILabel!
    @IBOutlet weak var samplesCountLabel: UILabel!
    @IBOutlet weak var totalCountLabel: UILabel!
    @IBOutlet weak var previousInvoicesLabel: UILabel!
    @IBOutlet weak var thisOrderLabel: UILabel!
    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var printButton: AnimatableButton!
    @IBOutlet weak var confirmButton: AnimatableButton!

    @IBOutlet weak var collectionTitleLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var collectionButton: UIButton!
    @IBOutlet weak var collectionText: AnimatableTextField!
    @IBOutlet weak var collectionDescLabel: UILabel!
    @IBOutlet weak var referenceNumberTitleLabel: UILabel!
    @IBOutlet weak var referenceNumberText: AnimatableTextField!
    @IBOutlet weak var nameTitleLabel: UILabel!
    @IBOutlet weak var nameText: AnimatableTextField!
    @IBOutlet weak var deliveryDateText: AnimatableTextField!
    @IBOutlet weak var deliveryDateButton: AnimatableButton!

    @IBOutlet weak var fulfilbyView: UIView!
    @IBOutlet weak var fulfilbyStackView: UIStackView!
    @IBOutlet weak var fulfilSubView1: UIView!
    @IBOutlet weak var fulfilSubView1RadioLabel: AnimatableLabel!
    @IBOutlet weak var fulfilSubView1TitleLabel: UILabel!
    @IBOutlet weak var fulfilSubView2: UIView!
    @IBOutlet weak var fulfilSubView2RadioLabel: AnimatableLabel!
    @IBOutlet weak var fulfilSubView2TitleLabel: UILabel!
    @IBOutlet weak var fulfilSubView3: UIView!
    @IBOutlet weak var fulfilSubView3RadioLabel: AnimatableLabel!
    @IBOutlet weak var fulfilSubView3TitleLabel: UILabel!
    @IBOutlet weak var distributorButton: AnimatableButton!

    @IBOutlet weak var notesTitleLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var salesLabel: UILabel!
    @IBOutlet weak var returnsLabel: UILabel!
    @IBOutlet weak var freeLabel: UILabel!
    @IBOutlet weak var totalTitleLabel: UILabel!
    @IBOutlet weak var priorBalance: UILabel!
    @IBOutlet weak var thisOrder: UILabel!
    @IBOutlet weak var terms: UILabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var cardLabel: UILabel!
    @IBOutlet weak var cashLabel: UILabel!
    @IBOutlet weak var checkLabel: UILabel!
    @IBOutlet weak var poReferenceNumberLabel: UILabel!
    @IBOutlet weak var signatureLabel: UILabel!
    @IBOutlet weak var deliveryDateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var returnToOrderLabel: AnimatableButton!
    @IBOutlet weak var printLabel: AnimatableButton!
    @IBOutlet weak var confirmLabel: AnimatableButton!
    
    enum PaybyOption: Int {
        case none = -1
        case card = 0
        case cash = 1
        case cheque = 2
    }

    var selectedPaybyOption: PaybyOption = .card {
        didSet {
            for (_index, _) in paybyViewArray.enumerated() {
                let radioLabel = paybyRadioLabelArray[_index]
                if _index == selectedPaybyOption.rawValue {
                    radioLabel.backgroundColor = kOrderSalesOptionSelectedColor
                }
                else {
                    radioLabel.backgroundColor = kOrderSalesOptionNormalColor
                }
            }

            onChangedOption()
        }
    }

    enum FulfilbyOption: Int {
        case warehouse = 0
        case vehicle = 1
        case distributor = 2
    }

    var selectedFulfilbyOption: FulfilbyOption = .warehouse {
        didSet {
            for (_, fulfilbyDescType) in fulfilbyDescTypeArray.enumerated() {
                let numericKeyValue = Int(fulfilbyDescType.numericKey ?? "") ?? 1
                let numericKeyIndex = numericKeyValue-1
                let radioLabel = fulfilbyRadioLabelArray[numericKeyIndex]

                if (numericKeyIndex == selectedFulfilbyOption.rawValue) {
                    radioLabel.backgroundColor = kOrderSalesOptionSelectedColor
                }
                else {
                    radioLabel.backgroundColor = kOrderSalesOptionNormalColor
                }
            }

            if selectedFulfilbyOption == .vehicle {
                selectedDeliveryDate = Date()
            }
            else {
                selectedDeliveryDate = deliveryDateArray.first
            }
            onChangedOption()
            updateARCollection()
        }
    }

    var deliveryDateArray = [Date]()
    var selectedDeliveryDate: Date? {
        didSet {
            let dateString = selectedDeliveryDate?.toDateString(format: kDeliveryDateFormat) ?? ""
            deliveryDateText.text = dateString
            deliveryDateButton.setTitleForAllState(title: dateString)
        }
    }

    let globalInfo = GlobalInfo.shared
    var mainVC: MainVC!
    var orderVC: OrderVC!
    var customerDetail: CustomerDetail!
    var paybyViewArray = [UIView]()
    var paybyRadioLabelArray = [AnimatableLabel]()
    var fulfilbyViewArray = [UIView]()
    var fulfilbyRadioLabelArray = [AnimatableLabel]()
    var fulfilbyTitleLabelArray = [UILabel]()
    var topButtonArray = [UIButton]()
    var originalARHeaderArray = [ARHeader]()
    var previousInvoices: Double = 0
    var thisOrderAmount: Double = 0
    var realPayAmount: Double = 0

    var distributorDescTypeArray = [DescType]()
    var selectedDistributorDescType: DescType? {
        didSet {
            if selectedDistributorDescType == nil {
                distributorButton.setTitleForAllState(title: L10n.selectDistributor())
                distributorButton.setTitleColor(kStoreTypeEmptyTextColor, for: .normal)
            }
            else {
                let distributorDesc = selectedDistributorDescType?.desc ?? ""
                distributorButton.setTitleForAllState(title: distributorDesc)
                distributorButton.setTitleColor(kStoreTypeNormalTextColor, for: .normal)
            }
        }
    }

    var fulfilbyDescTypeArray = [DescType]()

    var quantityArray = [Int]()
    var pickupQuantity = 0
    var buybackQuantity = 0
    var samplesQuantity = 0
    var freeQuantity = 0
    var caseArray = [Int]()
    var qtyArray = [Int]()
    var priceArray = [Double]()
    var subTotalArray = [Double]()
    var taxArray = [Double]()
    var diffPriceTotal: Double = 0

    var deliveryDateDropDown = DropDown()
    var distributorDropDown = DropDown()

    var isShowCase = true
    var signatureImageName = ""
    var photoPath: String = ""
    var payMethod = 0

    var printEngine: PrintEngine!
    var pdfFileName = ""
    var pdfPath = ""
    var isCreatePdfForPrint = true

    var shortDescForFile = ""
    var longDescForFile = ""

    var isPrinted = false

    var arHeaderArray = [ARHeader]()
    var selectedARHeaderIndexArray = [Int]()
    var selectedARHeaderAmount: Double = 0

    var uar: UAR?
    var uOrder: UOrder?

    var cardType = ""
    var transactionID = ""

    var connection: MfiBtPrinterConnection?
    var zebraPrinter: ZebraPrinter?

    var deliveryDatePicker = UIDatePicker()
    let kDeliveryDateFormat = "EEEE d MMMM"

    enum DismissOption {
        case confirmed
        case cancelled
    }

    var dismissHandler: ((OrderSummaryVC, DismissOption)->())?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
        loadARHeaderArray()
        initUI()
        updatePaidTextFromInvoiceArray()

        if orderVC.originalOrderHeader != nil {
            updateByOrderHeader()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        mainVC.setTitleBarText(title: L10n.orderSummary())
    }

    @objc func onChangeCollectionText(_ sender: Any) {
        var inputText = collectionText.text ?? ""
        inputText = inputText.replacingOccurrences(of: ".", with: "")
        let inputNum = (Double(inputText) ?? 0)/100
        let answer = inputNum.exactTwoDecimalString
        collectionText.text = answer
    }

    @objc func onTapPaybyView(_ sender: Any) {
        let tapGestureRecognizer = sender as! UITapGestureRecognizer
        let view = tapGestureRecognizer.view!
        let index = view.tag-400

        if selectedPaybyOption.rawValue == index {
            selectedPaybyOption = .none
        }
        else {
            selectedPaybyOption = PaybyOption(rawValue: index)!
        }
    }

    @objc func onTapFulfilbyView(_ sender: Any) {
        let tapGestureRecognizer = sender as! UITapGestureRecognizer
        let view = tapGestureRecognizer.view!
        let index = view.tag-500

        selectedFulfilbyOption = FulfilbyOption(rawValue: index)!
    }

    func onPDFCompleted(success: Bool, pdfPath: String) {

        if success == true {
            self.pdfPath = pdfPath
            NSLog("PDF creation success")

            /*
            let pdfViewerVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "PDFViewerVC") as! PDFViewerVC
            pdfViewerVC.pdfPath = pdfPath
            self.present(pdfViewerVC, animated: true, completion: nil)*/

            if isCreatePdfForPrint == false {
                self.doFinalizeOrder()
            }
            else {
                if pdfPath != "" {
                    ZebraPrintEngine.tryPrint(vc: self, pdfPath: pdfPath, completionHandler: { success, message in
                        if success == true {
                            self.isPrinted = true
                        }
                    })
                }
            }
        }
        else {
            NSLog("PDF creation failed")
        }
    }

    @IBAction func onDeliveryDate(_ sender: Any) {
        deliveryDateDropDown.show()
    }

    @IBAction func onDistributor(_ sender: Any) {
        distributorDropDown.show()
    }

    @IBAction func onTapReferenceNumber(_ sender: Any) {
        referenceNumberText.becomeFirstResponder()
    }

    @IBAction func onTapSignature(_ sender: Any) {
        let signatureVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "SignatureVC") as! SignatureVC
        signatureVC.setDefaultModalPresentationStyle()
        signatureVC.dismissHandler = {signatureImage in
            let imagePath = CommData.getFilePathAppended(byCacheDir: kSignatureFileName) ?? ""
            UIImage.saveImageToLocal(image: signatureImage, filePath: imagePath)
            self.signatureImageName = kSignatureFileName
        }
        self.present(signatureVC, animated: true, completion: nil)
    }

    @IBAction func onTapName(_ sender: Any) {
        nameText.becomeFirstResponder()
    }

    @IBAction func onTapNotes(_ sender: Any) {
        notesTextView.becomeFirstResponder()
    }

    @IBAction func onDetailCollection(_ sender: Any) {
        let collectionVC = UIViewController.getViewController(storyboardName: "Order", storyboardID: "OrderDetailCollectionVC") as! OrderDetailCollectionVC

        collectionVC.customerDetail = customerDetail
        collectionVC.arHeaderArray = arHeaderArray
        collectionVC.selectedIndexArray = selectedARHeaderIndexArray
        collectionVC.isReadOnly = !collectionText.isEnabled
        collectionVC.setDefaultModalPresentationStyle()
        collectionVC.dismissHandler = {vc, dismissOption in
            if dismissOption == .done {
                self.selectedARHeaderIndexArray = vc.selectedIndexArray
                self.updatePaidTextFromInvoiceArray()
            }
        }
        self.present(collectionVC, animated: true, completion: nil)
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
            SVProgressHUD.showInfo(withStatus: L10n.youDonTHaveCamera())
        }
    }

    @IBAction func onReturnToOrder(_ sender: Any) {
        mainVC.popChild(containerView: mainVC.containerView) { (finished) in
            self.dismissHandler?(self, .cancelled)
        }
    }

    @IBAction func onPrint(_ sender: Any) {

        if doValidate() == false {
            return
        }

        processConfirm()
        isCreatePdfForPrint = true

        doCreatePdfTask()
        
        scheduleUOrderUploadWithPostpone()
    }

    @IBAction func onConfirm(_ sender: Any) {

        if doValidate() == false {
            return
        }

        updateUAR()

        var totalSelectedAmount: Double = 0
        for selectedIndex in selectedARHeaderIndexArray {
            let arHeader = arHeaderArray[selectedIndex]
            let amount = Utils.getXMLDivided(valueString: arHeader.trxnAmount ?? "0")
            totalSelectedAmount += amount
        }
        if selectedPaybyOption == .cheque {
            let orderChequeDetailsVC = UIViewController.getViewController(storyboardName: "Order", storyboardID: "OrderChequeDetailsVC") as! OrderChequeDetailsVC
            orderChequeDetailsVC.customerDetail = self.customerDetail
            orderChequeDetailsVC.collectionRequired = totalSelectedAmount
            orderChequeDetailsVC.totalCollected = totalSelectedAmount
            orderChequeDetailsVC.chequeAmount = self.selectedARHeaderAmount
            orderChequeDetailsVC.originalUARPayment = uar!.uarPaymentSet[0] as! UARPayment
            orderChequeDetailsVC.setDefaultModalPresentationStyle()

            orderChequeDetailsVC.dismissHandler = {vc, dismissOption in
                if dismissOption == .done {
                    self.realPayAmount = vc.chequeAmount
                    let payment = self.uar!.uarPaymentSet[0] as! UARPayment
                    payment.updateBy(theSource: vc.resultUARPayment!)
                    self.processConfirm()
                    self.isCreatePdfForPrint = false
                    self.doCreatePdfTask()
                }
            }
            self.present(orderChequeDetailsVC, animated: true, completion: nil)
        }
        else if selectedPaybyOption == .card {
            let orderEWayDetailsVC = UIViewController.getViewController(storyboardName: "Order", storyboardID: "OrderEWayDetailsVC") as! OrderEWayDetailsVC
            orderEWayDetailsVC.customerDetail = self.customerDetail
            orderEWayDetailsVC.amount = self.selectedARHeaderAmount
            orderEWayDetailsVC.originalUARPayment = uar!.uarPaymentSet[0] as! UARPayment
            orderEWayDetailsVC.setDefaultModalPresentationStyle()
            orderEWayDetailsVC.dismissHandler = {vc, dismissOption in
                if dismissOption == .done {
                    self.realPayAmount = vc.amount
                    let payment = self.uar!.uarPaymentSet[0] as! UARPayment
                    payment.updateBy(theSource: vc.resultUARPayment!)
                    self.processConfirm()
                    self.isCreatePdfForPrint = false
                    self.doCreatePdfTask()
                }
            }
            self.present(orderEWayDetailsVC, animated: true, completion: nil)
        }
        else {
            self.processConfirm()
            self.isCreatePdfForPrint = false
            self.doCreatePdfTask()
        }
    }

    @objc func onHeaderTapped() {
        let orderReviewVC = UIViewController.getViewController(storyboardName: "Order", storyboardID: "OrderReviewVC") as! OrderReviewVC
        orderReviewVC.customerDetail = self.customerDetail
        orderReviewVC.orderVC = self.orderVC
        orderReviewVC.setDefaultModalPresentationStyle()
        orderReviewVC.dismissHandler = {vc, dismissOption in
            if dismissOption == .done {
                self.summarizeOrderHeader()
                self.updatePriceLabels()
            }
        }
        self.present(orderReviewVC, animated: true, completion: nil)
    }

    @objc func onDeliveryDateCancel(_ sender: Any) {
        deliveryDateText.resignFirstResponder()
    }

    @objc func onDeliveryDateDone(_ sender: Any) {
        let selectedDate = deliveryDatePicker.date
        selectedDeliveryDate = selectedDate
        deliveryDateText.resignFirstResponder()
    }
}

extension OrderSummaryVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension OrderSummaryVC: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {

        if textField == deliveryDateText {
            deliveryDatePicker.date = selectedDeliveryDate ?? Date()
        }

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == collectionText {
            textField.resignFirstResponder()
            return false
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == collectionText {
            switch string {
            case "0","1","2","3","4","5","6","7","8","9":
                return true
            case "":
                return true
            default:
                return false
            }
        }
        return true
    }

}

extension OrderSummaryVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
        let now = Date()
        let photoName = "\(now.getTimestamp()).jpg"
        let photoPath = CommData.getFilePathAppended(byCacheDir: photoName) ?? ""
        UIImage.saveImageToLocal(image: image, filePath: photoPath)
        self.photoPath = photoPath
    }

}
