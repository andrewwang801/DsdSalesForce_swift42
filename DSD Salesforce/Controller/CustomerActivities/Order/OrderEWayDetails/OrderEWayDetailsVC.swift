//
//  OrderEWayDetailsVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 9/8/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable
import eWAYPaymentsSDK

class OrderEWayDetailsVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameText: AnimatableTextField!
    @IBOutlet weak var number0Text: AnimatableTextField!
    @IBOutlet weak var number1Text: AnimatableTextField!
    @IBOutlet weak var number2Text: AnimatableTextField!
    @IBOutlet weak var number3Text: AnimatableTextField!
    @IBOutlet weak var cvvText: AnimatableTextField!
    @IBOutlet weak var expiryMonthText: AnimatableTextField!
    @IBOutlet weak var expiryYearText: AnimatableTextField!
    @IBOutlet weak var amountText: AnimatableTextField!

    @IBOutlet weak var nameOnCardLabel: UILabel!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var cvvLabel: UILabel!
    @IBOutlet weak var expiryDateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var returnButton: AnimatableButton!
    @IBOutlet weak var payButton: AnimatableButton!
    
    var numberTextArray = [AnimatableTextField]()

    let globalInfo = GlobalInfo.shared
    var customerDetail: CustomerDetail!
    var sharedRapidAPI = RapidAPI.sharedManager() as! RapidAPI

    enum DismissOption {
        case cancelled
        case done
    }
    var dismissHandler: ((OrderEWayDetailsVC, DismissOption)->())?

    var apiKey = "F9802CaTan7PEJXzII++VGKeriPWTCxG1DnEnv8rgbDtx+CMZfl1A2itKry4xSi+vhlVR4"
    var password = "zE1tlOcZ"

    var amount: Double = 0
    var transactionID: String = ""

    var originalUARPayment: UARPayment?
    var resultUARPayment: UARPayment?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
        initUI()
    }

    func initData() {

        let cardProc = globalInfo.routeControl?.cardProc ?? "0"
        if cardProc == "1" {
            sharedRapidAPI.publicAPIKey = globalInfo.routeControl?.ewayAPI ?? ""
            sharedRapidAPI.rapidEndpoint = globalInfo.routeControl?.ewaySystem ?? ""
            apiKey = globalInfo.routeControl?.rapidAPIKey ?? ""
            password = globalInfo.routeControl?.rapidAPIPwd ?? ""
        }
        else {
            sharedRapidAPI.publicAPIKey = "epk-1C040E3E-E7E3-4A91-BF85-93D96D27AD5C"
            sharedRapidAPI.rapidEndpoint = "https://api.sandbox.ewaypayments.com/"
            apiKey = "F9802CaTan7PEJXzII++VGKeriPWTCxG1DnEnv8rgbDtx+CMZfl1A2itKry4xSi+vhlVR4"
            password = "zE1tlOcZ"
        }
    }

    func initUI() {
        nameOnCardLabel.text = L10n.nameOnCard()
        cardNumberLabel.text = L10n.cardNumber()
        cvvLabel.text = L10n.cvv()
        expiryDateLabel.text = L10n.expiryDate()
        amountLabel.text = L10n.amount()
        returnButton.setTitleForAllState(title: L10n.return())
        payButton.setTitleForAllState(title: L10n.pay())
        
        let expiryDate = Date().getDateAddedBy(months: 1)
        expiryYearText.text = expiryDate.toDateString(format: "yy") ?? ""
        expiryMonthText.text = expiryDate.toDateString(format: "MM") ?? ""

        let payType = customerDetail.payType ?? ""
        let paymentAdjust = globalInfo.routeControl?.paymentAdjust ?? ""
        /*
        if (payType.trimed() == "1" || payType.trimed() == "2") && paymentAdjust.trimed() == "1" {
            amountText.isEnabled = false
        }
        else {
            amountText.isEnabled = true
        }*/
        amountText.isEnabled = true
        amountText.delegate = self
        amountText.addTarget(self, action: #selector(onAmountTextChanged), for: .editingChanged)
        amountText.text = amount.exactTwoDecimalString
        amountText.returnKeyType = .next

        numberTextArray = [number0Text, number1Text, number2Text, number3Text]
        for (index, numberText) in numberTextArray.enumerated() {
            numberText.tag = 100+index
            numberText.delegate = self
            numberText.addTarget(self, action: #selector(onNumberTextChanged(_:)), for: .editingChanged)
            numberText.returnKeyType = .next
        }

        cvvText.delegate = self
        expiryYearText.delegate = self
        expiryMonthText.delegate = self
    }

    func doPayment() {
        let cardName = nameText.text ?? ""
        if cardName == "" {
            SVProgressHUD.showInfo(withStatus: "Please enter name on card")
            return
        }
        let cardNo1 = number0Text.text ?? ""
        let cardType = Utils.getCardLength(cardNo1: cardNo1)
        if cardNo1.length != 4 {
            SVProgressHUD.showInfo(withStatus: "Please enter a valid card number")
            return
        }
        let cardNo2 = number1Text.text ?? ""
        if cardNo2.length != 4 {
            SVProgressHUD.showInfo(withStatus: "Please enter a valid card number")
            return
        }
        let cardNo3 = number2Text.text ?? ""
        if cardNo3.length != 4 {
            SVProgressHUD.showInfo(withStatus: "Please enter a valid card number")
            return
        }
        let cardNo4 = number3Text.text ?? ""
        if (cardNo4.length != 4 && cardType == kMaxStrandardLength) || (cardNo4.length != 3 && cardType == kMaxAmericanExpressLength) || (cardNo4.length != 2 && cardType == kMaxDinersClubLength) {
            SVProgressHUD.showInfo(withStatus: "Please enter a valid card number")
            return
        }
        let expireMonth = Int(expiryMonthText.text ?? "") ?? 0
        if expireMonth == 0 {
            SVProgressHUD.showInfo(withStatus: "Please enter correct expiry month")
            return
        }
        let expireYear = Int(expiryYearText.text ?? "") ?? 0
        if expireYear+2000 < Date().year {
            SVProgressHUD.showInfo(withStatus: "Please enter correct expiry year")
            return
        }
        let cvn = cvvText.text ?? ""
        if cvn == "" {
            SVProgressHUD.showInfo(withStatus: "Please enter CVV")
            return
        }
        if cvn.length != 3 {
            SVProgressHUD.showInfo(withStatus: "Please enter correct CVV")
            return
        }
        amount = Double(amountText.text ?? "") ?? 0
        if amount <= 0 {
            SVProgressHUD.showInfo(withStatus: "Please input amount")
            return
        }
        let cardNo = cardNo1+cardNo2+cardNo3+cardNo4

        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow, animated: true)
        // let result = "Unknown Error"

        let transaction = Transaction()
        let payment = Payment()
        let cardDetails = CardDetails()
        let customer = Customer()

        let totalAmount = Int32(amount*100)
        payment.payment = totalAmount
        payment.currencyCode = "AUD"

        cardDetails.name = cardName
        cardDetails.number = cardNo
        cardDetails.cvn = cvn
        cardDetails.expiryMonth = expireMonth.toLeftPaddedString(digitCount: 2) ?? ""
        cardDetails.expiryYear = (expireYear+2000).toLeftPaddedString(digitCount: 4) ?? ""
        customer.cardDetails = cardDetails

        transaction.transactionType = Purchase
        transaction.payment = payment
        transaction.customer = customer

        NSLog("Expiry Month : "+transaction.customer.cardDetails.expiryMonth+"\n"+"Expiry Year : "+transaction.customer.cardDetails.expiryYear)

        RapidAPI.submitPayment(transaction) { (submitPayResponse) in

            if submitPayResponse == nil {
                SVProgressHUD.showInfo(withStatus: "Network Connection Error. Please confirm your network connection and try again")
            }
            else {
                let status = submitPayResponse!.status
                if status == Success || status == Accepted {
                    let accessCode = submitPayResponse!.submissionID ?? ""
                    let baseURL = self.getEWayAPIURL()
                    let headers = self.getEWayHeader()
                    APIManager.doNormalRequest(baseURL: baseURL, methodName: "Transaction/\(accessCode)", httpMethod: "GET", headers: headers, params: [:], shouldShowHUD: false, completion: { (response, message) in
                        if response == nil {
                            hud?.hide(true)
                            if message != "" {
                                SVProgressHUD.showInfo(withStatus: message)
                            }
                            else {
                                SVProgressHUD.showInfo(withStatus: "Network Connection Error. Please confirm your network connection and try again")
                            }
                        }
                        else {
                            let responseJSON = JSON(data: response as! Data)
                            let transactionResponse = EWayTransactionResponse(json: responseJSON)
                            let responseCode = transactionResponse.transactions[0].responseCode
                            if responseCode == "00" || responseCode == "08" || responseCode == "10" || responseCode == "11" || responseCode == "16" {
                                hud?.hide(true)
                                Utils.printDebug(message: "Payment Successful")
                                self.transactionID = transactionResponse.transactions[0].transactionID
                                self.doFinalProcess()
                            }
                            else {
                                let fullResponseCode = transactionResponse.transactions[0].responseMessage
                                let language = NSLocale.current.languageCode?.uppercased()
                                RapidAPI.userMessage(fullResponseCode, language: language, completed: { (userMessageResponse) in
                                    DispatchQueue.main.async {
                                        hud?.hide(true)
                                        if userMessageResponse == nil {
                                            SVProgressHUD.showInfo(withStatus: "Network Connection Error. Please confirm your network connection and try again")
                                        }
                                        else {
                                            Utils.printDebug(message: self.composeErrorMessage(userMessageResponse!))
                                        }
                                    }
                                })
                            }
                        }
                    })
                }
                else if status == Error {
                    let language = NSLocale.current.languageCode?.uppercased()
                    RapidAPI.userMessage(submitPayResponse!.errors, language: language, completed: { (userMessageResponse) in
                        DispatchQueue.main.async {
                            hud?.hide(true)
                            if userMessageResponse == nil {
                                SVProgressHUD.showInfo(withStatus: "Network Connection Error. Please confirm your network connection and try again")
                            }
                            else {
                                Utils.printDebug(message: self.composeErrorMessage(userMessageResponse!))
                            }
                        }
                    })
                }
            }
        }

    }

    func composeErrorMessage(_ userMessageResponse: UserMessageResponse) -> String {
        guard let messages = userMessageResponse.messages as? [[String:Any]] else {return ""}
        var displayMessageArray = [String]()
        for message in messages {
            let _ = message["ErrorCode"] as? String ?? ""
            let displayMessage = message["DisplayMessage"] as? String ?? ""
            displayMessageArray.append(displayMessage)
        }
        return displayMessageArray.joined(separator: "\n")
    }

    func doFinalProcess() {

        resultUARPayment = UARPayment(context: globalInfo.managedObjectContext, forSave: false)
        if originalUARPayment != nil {
            resultUARPayment?.updateBy(theSource: originalUARPayment!)
        }
        let paidAmount = Double(amountText.text ?? "") ?? 0
        resultUARPayment!.trxnAmount = Utils.getXMLMultipliedString(value: paidAmount)
        self.amount = paidAmount

        GlobalInfo.saveCache()
        self.dismiss(animated: true) {
            self.dismissHandler?(self, .done)
        }
    }

    func getEWayAPIURL() -> String {
        let baseURL = sharedRapidAPI.rapidEndpoint ?? ""
        return baseURL
    }

    func getEWayHeader() -> [String: String] {
        let credential = APIManager.getBasicCredential(userName: apiKey, password: password)
        let header = ["Authorization": credential, "User-Agent": ";eWAY SDK iOS 1.1.0"]
        return header
    }

    @objc func onNumberTextChanged(_ sender: Any) {
        let textField = sender as! AnimatableTextField
        let index = textField.tag - 100
        let length = textField.text?.length ?? 0
        if index == 0 {
            if length >= 4 {
                numberTextArray[index+1].becomeFirstResponder()
                //numberTextArray[index+1].selectAll(nil)
            }
        }
        else if index < 3 {
            if length >= 4 {
                numberTextArray[index+1].becomeFirstResponder()
                //numberTextArray[index+1].selectAll(nil)
            }
            else if length <= 0 {
                numberTextArray[index-1].becomeFirstResponder()
                //numberTextArray[index-1].selectAll(nil)
            }
        }
        else {
            if length <= 0 {
                numberTextArray[index-1].becomeFirstResponder()
                //numberTextArray[index-1].selectAll(nil)
            }
        }
    }

    @objc func onAmountTextChanged() {
        var inputText = amountText.text ?? ""
        inputText = inputText.replacingOccurrences(of: ".", with: "")
        let inputNum = (Double(inputText) ?? 0)/100
        let amount = inputNum.exactTwoDecimalString
        amountText.text = amount
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?(self, .cancelled)
        }
    }

    @IBAction func onDone(_ sender: Any) {

        doPayment()
    }

}

extension OrderEWayDetailsVC: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        var isNumberText = false
        for numberText in numberTextArray {
            if numberText == textField {
                isNumberText = true
                break
            }
        }
        let currentText = textField.text ?? ""
        if textField == amountText || isNumberText == true || textField == cvvText || textField == expiryYearText || textField == expiryMonthText {
            switch string {
            case "0","1","2","3","4","5","6","7","8","9":
                if isNumberText == true {
                    if currentText.length >= 4 {
                        let index = textField.tag-100
                        if index < 3 {
                            numberTextArray[index+1].becomeFirstResponder()
                        }
                        return false
                    }
                }
                else if textField == cvvText {
                    if currentText.length >= 3 {
                        return false
                    }
                }
                else if textField == expiryYearText || textField == expiryMonthText {
                    if currentText.length >= 2 {
                        return false
                    }
                }
                return true
            case "":
                /*
                if isNumberText == true && currentText == "" {
                    let index = textField.tag-100
                    if index >= 1 {
                        numberTextArray[index-1].becomeFirstResponder()
                        return true
                    }
                    return true
                }*/
                return true
            default:
                return false
            }
        }
        return true
    }
}


