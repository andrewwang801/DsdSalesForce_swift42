//
//  OrderStripeDetailsVC.swift
//  DSD Salesforce
//
//  Created by Head of Hex Clan on 2020/5/16.
//  Copyright © 2020 iOS Developer. All rights reserved.
//

import UIKit
import JavaScriptCore
import WebKit
import IBAnimatable

class OrderStripeDetailsVC: UIViewController {
    
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
    
    var isPaymentCollection = false
    var card: [String: Any] = [:]
    var hud: MBProgressHUD?
    var transactionID: String = ""
    var baseURL = ""
    var headers: [String: String] = [:]

    enum DismissOption {
        case cancelled
        case done
    }
    var dismissHandler: ((OrderStripeDetailsVC, DismissOption)->())?

    var apiKey = ""
    var pubKey = ""

    var amount: Double = 0

    var originalUARPayment: UARPayment?
    var resultUARPayment: UARPayment?

    override func viewDidLoad() {
        super.viewDidLoad()

        initData()
        initUI()
    }

    
    func initData() {

        apiKey = globalInfo.routeControl?.stripeSecKey ?? ""
        pubKey = globalInfo.routeControl?.stripePubKey ?? ""
//        apiKey = "sk_test_DP3udsRoL7eUS1SAKxWiMuGf00ykXU5JjG"
//        pubKey = "pk_test_kd9HWNDTQUWGyZOyNCZxnEGc00aJqDeuHG"
        baseURL = self.getStripeAPIURL()
        headers = self.getStripeHeader()
        let cardProc = globalInfo.routeControl?.cardProc ?? "0"
        if cardProc == "1" {
        }
        else {
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
    
    //create charge
    func doCreateCharge() {
        var params: [String: String] = [:]
//        params["source"] = self.token
        params["amount"] = String(format:"%.0f", amount * 100)
        params["currency"] = globalInfo.routeControl?.currency ?? "aud"
        if isPaymentCollection {
            params["description"] = "Payment Collection"
        }
        else if globalInfo.orderHeader != nil {
            params["description"] = "OrdNo: " + globalInfo.orderHeader.orderNo
        }
        params["customer"] = self.customerId
        APIManager.doNormalRequest(baseURL: baseURL, methodName: "/charges", httpMethod: "POST", headers: headers, params: params, shouldShowHUD: false, completion: { (response, message) in
            if response == nil {
                self.hud?.hide(true)
                if message != "" {
                    SVProgressHUD.showInfo(withStatus: message)
                }
                else {
                    SVProgressHUD.showInfo(withStatus: "Network Connection Error. Please confirm your network connection and try again")
                }
            }
            else {
                let responseJSON = JSON(data: response as! Data)
                if responseJSON["error"] != nil {
                    self.hud?.hide(true)
                    Utils.printDebug(message: responseJSON["error"]["message"].stringValue)
                    return
                }
                self.hud?.hide(true)
//                self.doCreateCustomer()
                self.doFinalProcess()
            }
        })
    }
    
    // create customer
    var customerId = ""
    func doCreateCustomer() {
        
        var params: [String: Any] = [:]
        params["card"] = self.card
        
        APIManager.doNormalRequest(baseURL: baseURL, methodName: "/tokens" , httpMethod: "POST", headers: headers, params: params, shouldShowHUD: false, completion: { (response, message) in
            if response == nil {
                self.hud?.hide(true)
                if message != "" {
                    SVProgressHUD.showInfo(withStatus: message)
                }
                else {
                    SVProgressHUD.showInfo(withStatus: "Network Connection Error. Please confirm your network connection and try again")
                }
            }
            else {
                let responseJSON = JSON(data: response as! Data)
                if responseJSON["error"] != nil {
                    self.hud?.hide(true)
                    Utils.printDebug(message: responseJSON["error"]["message"].stringValue)
                    return
                }
                
                self.token = responseJSON["id"].stringValue
                
                params = [:]
                params["source"] = self.token
                params["description"] = self.customerDetail.name
                params["name"] = self.customerDetail.name
                APIManager.doNormalRequest(baseURL: self.baseURL, methodName: "/customers", httpMethod: "POST", headers: self.headers, params: params, shouldShowHUD: false, completion: { (response, message) in
                    if response == nil {
                        self.hud?.hide(true)
                        if message != "" {
                            SVProgressHUD.showInfo(withStatus: message)
                        }
                        else {
                            SVProgressHUD.showInfo(withStatus: "Network Connection Error. Please confirm your network connection and try again")
                        }
                    }
                    else {
                        let responseJSON = JSON(data: response as! Data)
                        if responseJSON["error"] != nil {
                            self.hud?.hide(true)
                            Utils.printDebug(message: responseJSON["error"]["message"].stringValue)
                            return
                        }
                        self.customerId = responseJSON["id"].stringValue
//                        self.doFinalProcess()
                        self.doCreateCharge()
                    }
                })
            }
        })
        
    }
  
    // create token
    var token = ""
    func doCreateToken() {
        
        var params: [String: Any] = [:]
        params["card"] = self.card
        
        APIManager.doNormalRequest(baseURL: baseURL, methodName: "/tokens" , httpMethod: "POST", headers: headers, params: params, shouldShowHUD: false, completion: { (response, message) in
            if response == nil {
                self.hud?.hide(true)
                if message != "" {
                    SVProgressHUD.showInfo(withStatus: message)
                }
                else {
                    SVProgressHUD.showInfo(withStatus: "Network Connection Error. Please confirm your network connection and try again")
                }
            }
            else {
                let responseJSON = JSON(data: response as! Data)
                if responseJSON["error"] != nil {
                    self.hud?.hide(true)
                    Utils.printDebug(message: responseJSON["error"]["message"].stringValue)
                    return
                }

                self.token = responseJSON["id"].stringValue
//                self.doCreateCharge()
                self.doCreateCustomer()
            }
        })
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

    func getStripeAPIURL() -> String {
        let baseURL = "https://api.stripe.com/v1"
        return baseURL
    }

    func getStripeHeader() -> [String: String] {
        let credential = APIManager.getBasicCredential(userName: apiKey, password: "")
        let header = ["Authorization": credential]
        return header
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

        card["number"] = cardNo
        card["exp_month"] = expireMonth
        card["exp_year"] = expireYear
        card["cvc"] = cvn

        hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow, animated: true)
        // let result = "Unknown Error"
//        doCreateToken()
        doCreateCustomer()
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


extension OrderStripeDetailsVC: UITextFieldDelegate {

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


