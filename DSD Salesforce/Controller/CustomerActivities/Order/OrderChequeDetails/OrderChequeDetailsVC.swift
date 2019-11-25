//
//  OrderChequeDetailsVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 9/8/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class OrderChequeDetailsVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var collectionRequiredLabel: UILabel!
    @IBOutlet weak var totalCollectedLabel: UILabel!
    @IBOutlet weak var totalRemainingLabel: UILabel!
    @IBOutlet weak var bankBSBText: AnimatableTextField!
    @IBOutlet weak var accountText: AnimatableTextField!
    @IBOutlet weak var chequeNumberText: AnimatableTextField!
    @IBOutlet weak var chequeDateText: AnimatableTextField!
    @IBOutlet weak var chequeAmountText: AnimatableTextField!
    @IBOutlet weak var arNoteText: AnimatableTextField!

    let globalInfo = GlobalInfo.shared
    var customerDetail: CustomerDetail!
    // var orderSummaryVC: OrderSummaryVC!

    var datePicker = UIDatePicker()

    let kDateFormat = "EEE dd/MM/yyyy"

    enum DismissOption {
        case cancelled
        case done
    }
    var dismissHandler: ((OrderChequeDetailsVC, DismissOption)->())?

    var collectionRequired: Double = 0
    var totalCollected: Double = 0
    var originalUARPayment: UARPayment?
    var chequeAmount: Double = 0
    var resultUARPayment: UARPayment?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
    }

    func initUI() {
        customerNameLabel.text = customerDetail.name ?? ""
        collectionRequiredLabel.text = Utils.getMoneyString(moneyValue: self.collectionRequired)
        totalCollectedLabel.text = Utils.getMoneyString(moneyValue: self.totalCollected)

        let remaining = self.collectionRequired-self.totalCollected
        totalRemainingLabel.text = Utils.getMoneyString(moneyValue: remaining)

        chequeDateText.text = Date().toDateString(format: kDateFormat)
        chequeAmountText.text = chequeAmount.twoGroupedExactDecimalString

        bankBSBText.delegate = self
        accountText.delegate = self
        chequeNumberText.delegate = self
        chequeAmountText.delegate = self
        chequeAmountText.addTarget(self, action: #selector(OrderChequeDetailsVC.onChangeChequeAmountText(_:)), for: .editingChanged)

        // date picker
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        chequeDateText.inputView = datePicker
        chequeDateText.delegate = self

        let dateDismissAccessory = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 44))
        let itemCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(OrderChequeDetailsVC.onChequeDateCancel(_:)))
        let itemFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let itemDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(OrderChequeDetailsVC.onChequeDateDone(_:)))
        dateDismissAccessory.items = [itemCancel, itemFlexibleSpace, itemDone]
        chequeDateText.inputAccessoryView = dateDismissAccessory

        updateFromUAR()
    }

    func updateFromUAR() {
        if originalUARPayment != nil {
            bankBSBText.text = originalUARPayment!.bankNo
            accountText.text = originalUARPayment!.account
            chequeNumberText.text = originalUARPayment!.checkNo
            arNoteText.text = originalUARPayment!.arNotes
        }
    }

    @objc func onChequeDateCancel(_ sender: Any) {
        chequeDateText.resignFirstResponder()
    }

    @objc func onChequeDateDone(_ sender: Any) {
        let selectedDate = datePicker.date
        chequeDateText.text = selectedDate.toDateString(format: kDateFormat)
        chequeDateText.resignFirstResponder()
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?(self, .cancelled)
        }
    }

    @IBAction func onDone(_ sender: Any) {
        // fill missed info in uar payment
        resultUARPayment = UARPayment(context: globalInfo.managedObjectContext, forSave: false)

        if originalUARPayment != nil {
            resultUARPayment?.updateBy(theSource: originalUARPayment!)
        }

        resultUARPayment!.bankNo = bankBSBText.text ?? ""
        resultUARPayment!.account = accountText.text ?? ""
        resultUARPayment!.checkNo = chequeNumberText.text ?? ""
        let checkDate = Date.fromDateString(dateString: chequeDateText.text ?? "", format: kDateFormat)
        resultUARPayment!.checkDate = checkDate?.toDateString(format: kTightJustDateFormat) ?? ""
        resultUARPayment!.arNotes = arNoteText.text ?? ""

        let paidAmount = Double(chequeAmountText.text ?? "0") ?? 0
        chequeAmount = paidAmount
        resultUARPayment!.trxnAmount = Utils.getXMLMultipliedString(value: paidAmount)

        self.dismiss(animated: true) {
            self.dismissHandler?(self, .done)
        }
    }

    @objc func onChangeChequeAmountText(_ sender: Any) {
        var inputText = chequeAmountText.text ?? ""
        inputText = inputText.replacingOccurrences(of: ".", with: "")
        let inputNum = (Double(inputText) ?? 0)/100
        let answer = inputNum.exactTwoDecimalString
        chequeAmountText.text = answer
    }

}

extension OrderChequeDetailsVC: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {

        if textField == chequeDateText {
            let date = Date.fromDateString(dateString: textField.text ?? "", format: kDateFormat) ?? Date()
            datePicker.date = date
        }

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == chequeAmountText {
            textField.resignFirstResponder()
            return false
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == bankBSBText || textField == accountText || textField == chequeNumberText || textField == chequeAmountText {
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


