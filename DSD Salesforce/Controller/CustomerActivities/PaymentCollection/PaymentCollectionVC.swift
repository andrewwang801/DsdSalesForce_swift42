//
//  PaymentCollectionVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/9/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class PaymentCollectionVC: UIViewController {

    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var allCheckImageView: UIImageView!
    @IBOutlet weak var allPriceLabel: UILabel!
    @IBOutlet weak var invoiceTableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var confirmButton: AnimatableButton!

    @IBOutlet weak var totalToCollectAmountLabel: UILabel!
    @IBOutlet weak var cashText: AnimatableTextField!
    @IBOutlet weak var chequeView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cardViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var chequeAmountLabel: UILabel!
    @IBOutlet weak var cardAmountLabel: UILabel!
    @IBOutlet weak var totalCollectedAmountLabel: UILabel!
    @IBOutlet weak var totalRemainingAmountLabel: UILabel!
    @IBOutlet weak var printButton: AnimatableButton!
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var totalCustomerBalance: UILabel!
    @IBOutlet weak var selectInvoicesToPayLabel: UILabel!
    @IBOutlet weak var selectAllLabel: UILabel!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var totalToCollect: UILabel!
    @IBOutlet weak var cashLabel: UILabel!
    @IBOutlet weak var checkLabel: UILabel!
    @IBOutlet weak var cardLabel: UILabel!
    @IBOutlet weak var totalCollect: UILabel!
    @IBOutlet weak var totalRemainingToCollectLabel: UILabel!
    @IBOutlet weak var returnButton: AnimatableButton!
    
    let globalInfo = GlobalInfo.shared
    var mainVC: MainVC!
    var customerDetail: CustomerDetail!
    var arHeaderArray = [ARHeader]()
    var selectedIndexArray = [Int]()

    var chequePaymentArray = [UARPayment]()
    var cardPaymentArray = [UARPayment]()

    var printEngine: PrintEngine!
    var pdfPath = ""
    var pdfFileName = ""

    var isCreatePdfForPrint = false
    var isPrinted = false

    var uar: UAR?

    enum DismissOption {
        case cancelled
        case done
    }

    var dismissHandler: ((PaymentCollectionVC, DismissOption) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initData()
        initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainVC.setTitleBarText(title: "PAYMENT COLLECTION")
        refreshInvoices()
        updatePaymentView()
    }

    func initData() {
        // load all ar for the customer details
        arHeaderArray.removeAll()
        arHeaderArray = ARHeader.getUnpaidBy(context: globalInfo.managedObjectContext, chainNo: customerDetail.chainNo ?? "0", custNo: customerDetail.custNo ?? "0")
    }

    func initUI() {
        totalCustomerBalance.text = L10n.totalCustomerBalance()
        selectInvoicesToPayLabel.text = L10n.selectInvoicesToPay()
        selectAllLabel.text = L10n.selectAll()
        paymentMethodLabel.text = L10n.paymentMethod()
        totalToCollect.text = L10n.totalToCollect()
        cashLabel.text = L10n.cash()
        checkLabel.text = L10n.check()
        cardLabel.text = L10n.card()
        totalCollect.text = L10n.totalCollected()
        totalRemainingToCollectLabel.text = L10n.totalRemainingToCollect()
        returnButton.setTitleForAllState(title: L10n.Return())
        printButton.setTitleForAllState(title: L10n.print())
        confirmButton.setTitleForAllState(title: L10n.CONFIRM())
        
        invoiceTableView.dataSource = self
        invoiceTableView.delegate = self

        cashText.delegate = self
        cashText.addTarget(self, action: #selector(PaymentCollectionVC.onChangeCashText(_:)), for: .editingChanged)
        var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PaymentCollectionVC.onTapChequeView))
        chequeView.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PaymentCollectionVC.onTapCardView))
        cardView.addGestureRecognizer(tapGestureRecognizer)

        // total collection amount
        var totalAmount: Double = 0
        for arHeader in arHeaderArray {
            let amount = Utils.getXMLDivided(valueString: arHeader.trxnAmount ?? "0")
            totalAmount += amount
        }
        let textColor = totalAmount >= 0 ? kBlackTextColor : UIColor.red

        if totalAmount >= 0 {
            totalAmountLabel.text = Utils.getMoneyString(moneyValue: totalAmount)
        }
        else {
            totalAmountLabel.text = "-"+Utils.getMoneyString(moneyValue: fabs(totalAmount))
        }
        totalAmountLabel.textColor = textColor

        cashText.text = "0"

        let cardProc = globalInfo.routeControl?.cardProc ?? ""
        if cardProc == "0" {
            cardView.isHidden = true
            cardViewBottomConstraint.constant = -45.0
        }
        else {
            cardView.isHidden = false
            cardViewBottomConstraint.constant = 0
        }

        let printType = globalInfo.routeControl?.printType ?? ""
        if printType == "1" {
            printButton.isHidden = false
        }
        else {
            printButton.isHidden = true
        }
    }

    func refreshInvoices() {
        invoiceTableView.reloadData()
        if arHeaderArray.count == 0 {
            noDataLabel.isHidden = false
        }
        else {
            noDataLabel.isHidden = true
        }

        if selectedIndexArray.count == arHeaderArray.count {
            allCheckImageView.isHidden = false
        }
        else {
            allCheckImageView.isHidden = true
        }

        let totalSelectedAmount = getTotalSelected()
        if totalSelectedAmount >= 0 {
            allPriceLabel.text = Utils.getMoneyString(moneyValue: totalSelectedAmount)
        }
        else {
            allPriceLabel.text = "-"+Utils.getMoneyString(moneyValue: fabs(totalSelectedAmount))
        }

        updatePaymentView()

        if totalSelectedAmount == 0 {
            confirmButton.isHidden = true
        }
        else {
            confirmButton.isHidden = false
        }

    }

    func updatePaymentView() {

        // total to collect values
        let totalToCollectAmount = getTotalSelected()
        totalToCollectAmountLabel.text = Utils.getMoneyString(moneyValue: totalToCollectAmount)

        // update payment values
        let cashAmount = Double(cashText.text ?? "0") ?? 0
        var chequeAmount: Double = 0
        for payment in chequePaymentArray {
            let amount = Utils.getXMLDivided(valueString: payment.trxnAmount)
            chequeAmount += amount
        }
        var cardAmount: Double = 0
        for payment in cardPaymentArray {
            let amount = Utils.getXMLDivided(valueString: payment.trxnAmount)
            cardAmount += amount
        }
        chequeAmountLabel.text = Utils.getMoneyString(moneyValue: chequeAmount)
        cardAmountLabel.text = Utils.getMoneyString(moneyValue: cardAmount)

        // total collected
        let totalCollectedAmount = cashAmount+chequeAmount+cardAmount
        totalCollectedAmountLabel.text = Utils.getMoneyString(moneyValue: totalCollectedAmount)

        // total remaining to collect
        let totalRemainingAmount = totalToCollectAmount - totalCollectedAmount
        totalRemainingAmountLabel.text = Utils.getMoneyString(moneyValue: totalRemainingAmount)
    }

    func prepareTemplatePayment(paymentType: Int) -> UARPayment {
        let chainNo = customerDetail.chainNo ?? "0"
        let custNo = customerDetail.custNo ?? "0"
        let managedObjectContext = globalInfo.managedObjectContext!
        let trxnDate = Date()
        let uarPayment = UARPayment.make(context: managedObjectContext, chainNo: chainNo, custNo: custNo, trnxDate: trxnDate, trxnAmount: "0", paymentType: paymentType, forSave: false)
        return uarPayment
    }

    func handleARHeaders() {
        let totalCollected = getTotalCollected()
        let totalSelected = getTotalSelected()
        if totalCollected == totalSelected {
            // full pay
            for selectedIndex in selectedIndexArray {
                let arHeader = arHeaderArray[selectedIndex]
                arHeader.nProcessStatus = kARPaidStatus
            }
            GlobalInfo.saveCache()
        }
        else {
            // partial pay
            let newARHeader = ARHeader(context: globalInfo.managedObjectContext, forSave: true)
            newARHeader.chainNo = customerDetail.chainNo ?? "0"
            newARHeader.custNo = customerDetail.custNo ?? "0"
            newARHeader.invDate = Date().toDateString(format: kTightJustDateFormat) ?? ""
            newARHeader.invNo = "0"
            newARHeader.arTrxnType = "CRN"
            newARHeader.trxnAmount = Utils.getXMLMultipliedString(value: totalCollected * -1)
            GlobalInfo.saveCache()
        }
    }

    func handleUAR() {

        let chainNo = customerDetail.chainNo ?? "0"
        let custNo = customerDetail.custNo ?? "0"
        let trxnDate = Date()

        var paymentArray = [UARPayment]()
        // make uar for each uarpayment
        // cash
        let cashAmount = Double(cashText.text ?? "0") ?? 0
        let trxnAmount = Utils.getXMLMultipliedString(value: cashAmount)
        let cashPayment = UARPayment.make(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo, trnxDate: trxnDate, trxnAmount: trxnAmount, paymentType: kCollectionCash, forSave: true)
        paymentArray.append(cashPayment)

        // cheque
        for payment in chequePaymentArray {
            let clonePayment = UARPayment(context: globalInfo.managedObjectContext, forSave: true)
            clonePayment.updateBy(theSource: payment)
            paymentArray.append(clonePayment)
        }

        // card
        for payment in cardPaymentArray {
            let clonePayment = UARPayment(context: globalInfo.managedObjectContext, forSave: true)
            clonePayment.updateBy(theSource: payment)
            paymentArray.append(clonePayment)
        }

        let trip = globalInfo.routeControl?.trip ?? ""
        let uar = UAR.make(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo, docType: "PAY", trnxDate: trxnDate, trip: trip, paymentArray: paymentArray)

        uar.printedFlag = "0"
        uar.reference = ""
        uar.invTrxnNo = "0"

        self.uar = uar

        GlobalInfo.saveCache()
    }

    func uploadData() {

        let uploadManager = globalInfo.uploadManager
        let chainNo = customerDetail.chainNo ?? "0"
        let custNo = customerDetail.custNo ?? "0"
        let trip = globalInfo.routeControl?.trip ?? ""

        var zipFilePathArray = [String]()
        var transactionArray = [UTransaction]()

        // upload pdf file
        let fileTrxnDate = Date()
        let fileTrxnDateString = fileTrxnDate.toDateString(format: kTightJustDateFormat) ?? ""
        let fileTrxnTimeString = fileTrxnDate.toDateString(format: kTightJustTimeFormat) ?? ""
        let docNo = uar!.invTrxnNo ?? ""

        let fileTransaction = FileTransaction.make(chainNo: chainNo, custNo: custNo, docType: "FARC", fileTrxnDate: fileTrxnDate, trip: trip, trnxDate: Date(), fileDocNo: docNo, fileShortDesc: "RECEIPT", fileLongDesc: "PAYMENT RECEIPT", fileCreateDate: fileTrxnDateString, fileCreateTime: fileTrxnTimeString, fileName: pdfFileName)
        transactionArray.append(fileTransaction.makeTransaction())

        uploadManager?.scheduleUpload(localFileName: kPDFDirName+"/"+fileTransaction.fileFileName, remoteFileName: fileTransaction.fileFileName, uploadItemType: .normalCustomerFile)

        transactionArray.append(uar!.makeTransaction())

        let gpsLog = GPSLog.make(chainNo: chainNo, custNo: custNo, docType: "GPS", date: Date(), location: globalInfo.getCurrentLocation())
        transactionArray.append(gpsLog.makeTransaction())

        uar!.printedFlag = isPrinted ? "1" : "0"
        let uarPath = UAR.saveToXML(uarArray: [uar!])
        if uarPath.isEmpty == false {
            zipFilePathArray.append(uarPath)
        }
        let fileTransactionPath = FileTransaction.saveToXML(fileTransactionArray: [fileTransaction])
        if fileTransactionPath.isEmpty == false {
            zipFilePathArray.append(fileTransactionPath)
        }
        let gpsLogPath = GPSLog.saveToXML(gpsLogArray: [gpsLog])
        zipFilePathArray.append(gpsLogPath)
        let transactionPath = UTransaction.saveToXML(transactionArray: transactionArray, shouldIncludeLog: true)
        zipFilePathArray.append(transactionPath)

        uploadManager?.zipAndScheduleUpload(filePathArray: zipFilePathArray)
    }

    func getTotalSelected() -> Double {
        var totalSelectedAmount: Double = 0
        for selectedIndex in selectedIndexArray {
            let arHeader = arHeaderArray[selectedIndex]
            let amount = Utils.getXMLDivided(valueString: arHeader.trxnAmount ?? "0")
            totalSelectedAmount += amount
        }
        return totalSelectedAmount
    }

    func getTotalCollected() -> Double {
        let cashAmount = Double(cashText.text ?? "0") ?? 0
        var chequeAmount: Double = 0
        for payment in chequePaymentArray {
            let amount = Utils.getXMLDivided(valueString: payment.trxnAmount)
            chequeAmount += amount
        }
        var cardAmount: Double = 0
        for payment in cardPaymentArray {
            let amount = Utils.getXMLDivided(valueString: payment.trxnAmount)
            cardAmount += amount
        }
        let collectedAmount = cashAmount+chequeAmount+cardAmount
        return collectedAmount
    }

    func clearUARForPrint() {
        if uar != nil {
            UAR.delete(context: globalInfo.managedObjectContext, uar: uar!)
            uar = nil
        }
    }

    func doMakePdf() {

        printEngine = PrintEngine()

        let pdfFileName = Utils.getPDFFileName()
        let pdfPath = CommData.getFilePathAppended(byCacheDir: kPDFDirName+"/"+pdfFileName) ?? ""

        var docNo = ""
        if pdfFileName.length > 4 {
            docNo = pdfFileName.subString(startIndex: 0, length: pdfFileName.length-4)
        }
        else {
            docNo = pdfFileName
        }
        uar!.docNo = docNo
        uar!.updateInvNoForPayments(invNo: docNo)

        printEngine.prepareCashPrint(customerDetail: customerDetail, uar: self.uar!)
        printEngine.isForOnePage = true

        printEngine.createPDF(webView: webView, isDuplicated: false, path: pdfPath, type: kPaymentCollectionPrint, shouldShowHUD: true) { (success) in
            if success == true {
                self.pdfFileName = pdfFileName
                self.pdfPath = self.printEngine.printPDFPath
                self.onPDFCompleted(success: success, pdfPath: self.pdfPath)
            }
            else {
                self.clearUARForPrint()
            }
        }
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
                self.doFinalize()
            }
            else {
                if pdfPath != "" {
                    ZebraPrintEngine.tryPrint(vc: self, pdfPath: pdfPath, completionHandler: { success, message in
                        if success == true {
                            self.isPrinted = true
                        }
                        self.clearUARForPrint()
                    })
                }
            }
        }
        else {
            NSLog("PDF creation failed")
        }
    }

    func doFinalize() {

        uploadData()

        mainVC.popChild(containerView: mainVC.containerView) { (finished) in
            self.dismissHandler?(self, .done)
        }
    }

    @objc func onChangeCashText(_ sender: Any) {
        var inputText = cashText.text ?? ""
        inputText = inputText.replacingOccurrences(of: ".", with: "")
        let inputNum = (Double(inputText) ?? 0)/100
        let answer = inputNum.exactTwoDecimalString
        cashText.text = answer

        updatePaymentView()
    }

    @objc func onTapChequeView() {
        let totalSelectedAmount = getTotalSelected()
        let collectedAmount = getTotalCollected()
        let orderChequeDetailsVC = UIViewController.getViewController(storyboardName: "Order", storyboardID: "OrderChequeDetailsVC") as! OrderChequeDetailsVC
        orderChequeDetailsVC.customerDetail = self.customerDetail
        orderChequeDetailsVC.collectionRequired = totalSelectedAmount
        orderChequeDetailsVC.totalCollected = collectedAmount
        orderChequeDetailsVC.chequeAmount = totalSelectedAmount-collectedAmount
        orderChequeDetailsVC.originalUARPayment = prepareTemplatePayment(paymentType: kCollectionCheque)
        orderChequeDetailsVC.setDefaultModalPresentationStyle()

        orderChequeDetailsVC.dismissHandler = {vc, dismissOption in
            if dismissOption == .done {
                self.chequePaymentArray.append(vc.resultUARPayment!)
                self.updatePaymentView()
            }
        }
        self.present(orderChequeDetailsVC, animated: true, completion: nil)
    }

    @objc func onTapCardView() {
        var totalSelectedAmount: Double = 0
        for selectedIndex in selectedIndexArray {
            let arHeader = arHeaderArray[selectedIndex]
            let amount = Utils.getXMLDivided(valueString: arHeader.trxnAmount ?? "0")
            totalSelectedAmount += amount
        }
        let cashAmount = Double(cashText.text ?? "0") ?? 0
        var chequeAmount: Double = 0
        for payment in chequePaymentArray {
            let amount = Utils.getXMLDivided(valueString: payment.trxnAmount)
            chequeAmount += amount
        }
        var cardAmount: Double = 0
        for payment in cardPaymentArray {
            let amount = Utils.getXMLDivided(valueString: payment.trxnAmount)
            cardAmount += amount
        }
        let collectedAmount = cashAmount+chequeAmount+cardAmount

        let orderEWayDetailsVC = UIViewController.getViewController(storyboardName: "Order", storyboardID: "OrderEWayDetailsVC") as! OrderEWayDetailsVC
        orderEWayDetailsVC.customerDetail = self.customerDetail
        orderEWayDetailsVC.amount = totalSelectedAmount-collectedAmount
        orderEWayDetailsVC.originalUARPayment = prepareTemplatePayment(paymentType: kCollectionCard)
        orderEWayDetailsVC.setDefaultModalPresentationStyle()
        orderEWayDetailsVC.dismissHandler = {vc, dismissOption in
            if dismissOption == .done {
                self.cardPaymentArray.append(vc.resultUARPayment!)
                self.updatePaymentView()
            }
        }
        self.present(orderEWayDetailsVC, animated: true, completion: nil)
    }

    @IBAction func onTapAllCheck(_ sender: Any) {
        if selectedIndexArray.count == arHeaderArray.count {
            // deselect all
            selectedIndexArray.removeAll()
        }
        else {
            // select all
            selectedIndexArray.removeAll()
            for (index, _) in arHeaderArray.enumerated() {
                selectedIndexArray.append(index)
            }
        }
        refreshInvoices()
    }

    @IBAction func onPrint(_ sender: Any) {

        let totalCollectedAmount = getTotalCollected()
        if totalCollectedAmount == 0 {
            SVProgressHUD.showInfo(withStatus: L10n.totalCollectedAmountShouldNotBeZero())
            return
        }

        if selectedIndexArray.count == 0 {
            SVProgressHUD.showInfo(withStatus: L10n.youShouldSelectAtLeastOneInvoiceToPay())
            return
        }

        handleUAR()

        isCreatePdfForPrint = true
        doMakePdf()
    }

    @IBAction func onDone(_ sender: Any) {

        let totalCollectedAmount = getTotalCollected()
        if totalCollectedAmount == 0 {
            SVProgressHUD.showInfo(withStatus: L10n.totalCollectedAmountShouldNotBeZero())
            return
        }

        if selectedIndexArray.count == 0 {
            SVProgressHUD.showInfo(withStatus: L10n.youShouldSelectAtLeastOneInvoiceToPay())
            return
        }

        let totalSelected = getTotalSelected()
        let totalCollected = getTotalCollected()
        let totalRemaining = totalSelected-totalCollected
        if totalRemaining != 0 {
            Utils.showAlert(vc: self, title: "", message: L10n.youHaveNotCollectedTheFullAmountYouSelectedToCollect(), failed: false, customerName: "", leftString: L10n.return(), middleString: "", rightString: L10n.proceed()) { (returnCode) in
                if returnCode == .right {
                    self.handleARHeaders()
                    self.handleUAR()
                    self.isCreatePdfForPrint = false
                    self.doMakePdf()
                }
            }
        }
        else {
            self.handleARHeaders()
            self.handleUAR()
            self.isCreatePdfForPrint = false
            self.doMakePdf()
        }
    }

    @IBAction func onBack(_ sender: Any) {
        mainVC.popChild(containerView: mainVC.containerView) { (finished) in
            self.dismissHandler?(self, .cancelled)
        }
    }

}

extension PaymentCollectionVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arHeaderArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCollectionCell", for: indexPath) as! PaymentCollectionCell
        cell.setupCell(parentVC: self, indexPath: indexPath)
        return cell
    }

}

extension PaymentCollectionVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

}

extension PaymentCollectionVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == cashText {
            textField.resignFirstResponder()
            return false
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == cashText {
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
