//
//  LoginVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/3/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class LoginVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var leftLogoImageView: UIImageView!

    @IBOutlet weak var usernameText: AnimatableTextField!
    @IBOutlet weak var usernameButtonView: AnimatableView!
    @IBOutlet weak var usernameButton: UIButton!

    @IBOutlet weak var passwordText: AnimatableTextField!

    @IBOutlet weak var territoryText: AnimatableTextField!
    @IBOutlet weak var territoryLabelView: AnimatableView!
    @IBOutlet weak var territoryLabel: UILabel!

    @IBOutlet weak var companyPinText: AnimatableTextField!

    @IBOutlet weak var usernameImageView: UIImageView!
    @IBOutlet weak var passwordImageView: UIImageView!
    @IBOutlet weak var territoryImageView: UIImageView!
    @IBOutlet weak var companyPinImageView: UIImageView!

    @IBOutlet weak var usernameView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var territoryView: UIView!
    @IBOutlet weak var companyPinView: UIView!

    @IBOutlet weak var territoryTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginButton: AnimatableButton!

    let globalInfo = GlobalInfo.shared
    var ftpLoginInfo: FTPLoginInfo?
    var tripUserArray = [TripUser]()
    var isFTPLoggedin: Bool {
        get {
            return globalInfo.ftpHostname != ""
        }
    }

    var selectedTripUser: TripUser? {
        didSet {
            if selectedTripUser == nil {
                usernameButton.setTitleForAllState(title: "USER NAME")
                usernameButton.setTitleColor(kTextNormalBorderColor, for: .normal)

                passwordText.text = ""

                territoryLabel.text = "TERRITORY"
                territoryLabel.textColor = kTextNormalBorderColor
            }
            else {
                let username = selectedTripUser?.userName ?? ""
                usernameButton.setTitleForAllState(title: username)
                usernameButton.setTitleColor(kTextSelectedBorderColor, for: .normal)

                passwordText.text = ""

                let territory = selectedTripUser?.trip ?? ""
                territoryLabel.text = territory
                territoryLabel.textColor = kTextSelectedBorderColor
            }
        }
    }

    var usernameDropDown = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()

        globalInfo.productImageDownloadManager.stop()
    }

    func initUI() {

        initTitleBar()

        usernameText.delegate = self
        passwordText.delegate = self
        territoryText.delegate = self
        companyPinText.delegate = self
        territoryText.returnKeyType = .done

        updateLeftPanel()
        updateRightPanel()
    }

    var isFirstAppear = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        globalInfo.loadUserSetting()
        updateRightPanel()

        if isFirstAppear == false {
            usernameText.text = ""
            passwordText.text = ""
            territoryText.text = ""
            companyPinText.text = ""
        }
        isFirstAppear = true
    }

    func initTitleBar() {
        // title label
        let titleString = titleLabel.text ?? ""
        let attributedString = NSMutableAttributedString(string: titleLabel.text ?? "")
        let titleSpacing: CGFloat = 2.5
        attributedString.addAttributes([NSAttributedString.Key.kern: titleSpacing], range: NSMakeRange(0, titleString.length))
        titleLabel.attributedText = attributedString
    }

    @IBAction func onLogin(_ sender: Any) {

        globalInfo.loadUserSetting()
        globalInfo.loadFTPSetting()

        var username = ""
        var password = ""
        var territory = ""
        var companyPin = ""

        if isFTPLoggedin == false {

            companyPinText.resignFirstResponder()
            territoryText.resignFirstResponder()

            // initial sign on
            companyPin = companyPinText.text ?? ""
            if companyPin.length != 6 {
                Utils.showAlert(vc: self, title: "", message: "Company Pin format is invalid.", failed: false, customerName: "", leftString: "", middleString: "OK", rightString: "", dismissHandler: nil)
                return
            }

            territory = territoryText.text ?? ""
            if territory.isEmpty == true {
                Utils.showAlert(vc: self, title: "", message: "Please input trip number", failed: false, customerName: "", leftString: "", middleString: "Ok", rightString: "", dismissHandler: nil)
                return
            }

            // pin format check
            let _pin = companyPin as NSString
            let strKey1 = _pin.substring(with: NSMakeRange(0, 2))
            let strKey2 = _pin.substring(with: NSMakeRange(2, 2))
            let strKey3 = _pin.substring(with: NSMakeRange(4, 2))
            if globalInfo.urlBaseMap[strKey1] == nil || globalInfo.urlBaseMap[strKey2] == nil || globalInfo.urlBaseMap[strKey3] == nil {
                Utils.showAlert(vc: self, title: "", message: "Company Pin format is invalid.", failed: false, customerName: "", leftString: "", middleString: "OK", rightString: "", dismissHandler: nil)
                return
            }

            let strBaseURL = Utils.getBaseURL(pinNumber: companyPin)
            let urlSuffix = Utils.getURLSuffix(pinNumber: companyPin)

            let userDefaults = UserDefaults.standard

            let username = "admin"
            let password = "password"
            let params = ["username": username, "password": password]
            APIManager.doNormalRequest(baseURL: strBaseURL, methodName: "api/sftp", httpMethod: "POST", params: params, shouldShowHUD: true) { (ftpResponse, message) in
                if ftpResponse == nil {
                    Utils.showAlert(vc: self, title: "", message: "You have used wrong information to login.", failed: false, customerName: "", leftString: "", middleString: "OK", rightString: "", dismissHandler: nil)
                }
                else {
                    // login with delivery
                    let params = ["username": username, "password": password]
                    APIManager.doNormalRequest(baseURL: strBaseURL, methodName: "api/login", httpMethod: "POST", params: params, shouldShowHUD: true) { (loginResponse, message) in
                        if loginResponse == nil {
                            Utils.showAlert(vc: self, title: "", message: "You have used wrong information to login.", failed: false, customerName: "", leftString: "", middleString: "OK", rightString: "", dismissHandler: nil)
                        }
                        else {
                            // save delivery login information
                            let json = JSON(data: loginResponse as! Data)
                            let loginInfo = LoginInfo.from(json: json)
                            if loginInfo != nil {
                                userDefaults.set(loginInfo!.token, forKey: kDeliveryLoginTokenKey)
                                userDefaults.set(companyPin, forKey: kDeliveryLoginPinNumberKey)
                                userDefaults.set(username, forKey: kDeliveryLoginUserNameKey)
                                userDefaults.set(password, forKey: kDeliveryLoginPasswordKey)
                                userDefaults.synchronize()

                                // Normal ftp login process
                                let json = JSON(data: ftpResponse as! Data)
                                let ftpLoginInfo = FTPLoginInfo.from(json: json)
                                if ftpLoginInfo != nil {
                                    var ftpRoot = ""
                                    if companyPin == "040513" {
                                        ftpRoot = "DSDPlus_Demo"
                                    }
                                    else {
                                        ftpRoot = "DSDPlus_"+urlSuffix.uppercased()
                                    }
                                    ftpLoginInfo!.root = ftpRoot

                                    let ftpInfo = FTPInfo()
                                    ftpInfo.hostname = ftpLoginInfo!.ipAddress
                                    ftpInfo.user = ftpLoginInfo!.username
                                    ftpInfo.password = ftpLoginInfo!.password
                                    ftpInfo.root = ftpLoginInfo!.root
                                    ftpInfo.port = "21"/*ftpLoginInfo!.port*/
                                    ftpInfo.territory = territory

                                    self.ftpLoginInfo = ftpLoginInfo

                                    self.globalInfo.loadUserSetting()
                                    self.globalInfo.isUpdated = true
                                    self.globalInfo.saveUserSetting()

                                    self.doFirstLogin(ftpInfo: ftpInfo)
                                }
                                else {
                                    Utils.showAlert(vc: self, title: "", message: "You have used wrong information for Company Pin", failed: false, customerName: "", leftString: "", middleString: "OK", rightString: "", dismissHandler: nil)
                                }
                            }
                            else {
                                Utils.showAlert(vc: self, title: "", message: "You have used wrong information to login.", failed: false, customerName: "", leftString: "", middleString: "OK", rightString: "", dismissHandler: nil)
                            }
                        }
                    }
                }
            }
        }
        else {
            usernameText.resignFirstResponder()
            passwordText.resignFirstResponder()
            territoryText.resignFirstResponder()

            if tripUserArray.count == 0 {
                username = usernameText.text ?? ""
                password = passwordText.text ?? ""
                territory = territoryText.text ?? ""
            }
            else {
                username = selectedTripUser?.userName ?? ""
                password = passwordText.text ?? ""
                territory = selectedTripUser?.trip ?? ""
            }

            if username.isEmpty == true || password.isEmpty == true || territory.isEmpty == true {
                Utils.showAlert(vc: self, title: "", message: "Please fill in the login information field.", failed: false, customerName: "", leftString: "", middleString: "OK", rightString: "", dismissHandler: nil)
                return
            }

            globalInfo.loadUserSetting()
            // decide if new user is not in the trip user list or entered
            var isAvailableCredential = false
            if globalInfo.username == username && globalInfo.password == password {
                isAvailableCredential = true
            }
            else {
                var isFound = false
                for tripUser in tripUserArray {
                    let tripUsername = tripUser.userName ?? ""
                    let tripUserPassword = tripUser.security1 ?? ""
                    if tripUsername == username && tripUserPassword == password {
                        isFound = true
                        break
                    }
                }
                if isFound == true {
                    isAvailableCredential = true
                }
            }

            if isAvailableCredential == false {
                self.showInvalidSignOn()
            }
            else {
                if globalInfo.territory == "" {
                    self.globalInfo.loadFTPSetting()
                    let ftpInfo = FTPInfo()
                    ftpInfo.hostname = self.globalInfo.ftpHostname
                    ftpInfo.user = self.globalInfo.ftpUsername
                    ftpInfo.password = self.globalInfo.ftpPassword
                    ftpInfo.root = self.globalInfo.ftpRoot
                    ftpInfo.territory = territory
                    globalInfo.clearDataForNewTrip()
                    self.doReLogin(ftpInfo: ftpInfo)
                }
                else {
                    if globalInfo.territory == territory {
                        if globalInfo.isUpdated == true {
                            //globalInfo.isUpdated = false
                            //globalInfo.saveUserSetting()
                            self.loginToQBAndOpenMain()
                        }
                        else {
                            Utils.showAlert(vc: self, title: "Refresh Data", message: "Refresh the data on your device?\nThis will reset the visit plan and may cause loss of transactions you have completed today!", failed: false, customerName: "", leftString: "No", middleString: "", rightString: "Yes") { returnCode in
                                if returnCode == MessageDialogVC.ReturnCode.left {
                                    self.loginToQBAndOpenMain()
                                }
                                else {
                                    let routeControl = RouteControl.getAll(context: self.globalInfo.managedObjectContext).first
                                    let realPinCode = routeControl?.security3 ?? ""
                                    if realPinCode.trimed() == "" {
                                        self.globalInfo.loadFTPSetting()
                                        let ftpInfo = FTPInfo()
                                        ftpInfo.hostname = self.globalInfo.ftpHostname
                                        ftpInfo.user = self.globalInfo.ftpUsername
                                        ftpInfo.password = self.globalInfo.ftpPassword
                                        ftpInfo.root = self.globalInfo.ftpRoot
                                        ftpInfo.territory = territory
                                        self.doReLogin(ftpInfo: ftpInfo)
                                    }
                                    else {
                                        Utils.showInput(vc: self, title: "PIN CODE", placeholder: "PIN code for communication", enteredString: "", leftString: "Enter", middleString: "", rightString: "Return", dismissHandler: { (returnCode, inputString) in
                                            if returnCode == InputDialogVC.ReturnCode.left {
                                                if realPinCode == inputString {
                                                    self.globalInfo.loadFTPSetting()
                                                    let ftpInfo = FTPInfo()
                                                    ftpInfo.hostname = self.globalInfo.ftpHostname
                                                    ftpInfo.user = self.globalInfo.ftpUsername
                                                    ftpInfo.password = self.globalInfo.ftpPassword
                                                    ftpInfo.root = self.globalInfo.ftpRoot
                                                    ftpInfo.territory = territory
                                                    self.doReLogin(ftpInfo: ftpInfo)
                                                }
                                                else {
                                                    Utils.showAlert(vc: self, title: "ALERT", message: "Invalid code", failed: false, customerName: "", leftString: "", middleString: "Ok", rightString: "", dismissHandler: nil)
                                                }
                                            }
                                        })
                                    }
                                }
                            }
                        }
                    }
                    else {
                        Utils.showAlert(vc: self, title: "NO DATA", message: "Trip \(territory) is not the current loaded trip on your device.\nContinue to load new trip?", failed: false, customerName: "", leftString: "No", middleString: "", rightString: "Yes") { returnCode in
                            if returnCode == MessageDialogVC.ReturnCode.right {
                                self.globalInfo.loadFTPSetting()
                                let ftpInfo = FTPInfo()
                                ftpInfo.hostname = self.globalInfo.ftpHostname
                                ftpInfo.user = self.globalInfo.ftpUsername
                                ftpInfo.password = self.globalInfo.ftpPassword
                                ftpInfo.root = self.globalInfo.ftpRoot
                                ftpInfo.territory = territory
                                self.globalInfo.clearDataForNewTrip()
                                self.doReLogin(ftpInfo: ftpInfo)
                            }
                        }
                    }
                }
            }
        }
    }

    func doFirstLogin(ftpInfo: FTPInfo) {

        globalInfo.ftpManager.downloadXmls(hostname: ftpInfo.hostname, user: ftpInfo.user, password: ftpInfo.password, root: ftpInfo.root, territory: ftpInfo.territory, shouldShowHUD: true) { (success, message) in

            if success == true {
                //measure time
                var startTime = CFAbsoluteTimeGetCurrent()
                
                self.globalInfo.ftpManager.downloadDirectoryFiles(hostname: ftpInfo.hostname, user: ftpInfo.user, password: ftpInfo.password, root: ftpInfo.root, territory: ftpInfo.territory, remoteDirName: kReportsDirName, remoteFileNames: kReportsFileNameArray, localDirName: kReportsDirName, shouldShowHUD: true, completion: { (success, message) in
                    
                    //measure time
                    var timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
                    print("Time elapsed for first DownloadDirectoryFiles: \(timeElapsed) s.")
                    
                    if success == true {
                        self.updateLeftPanel()
                    }

                    //measure time
                    startTime = CFAbsoluteTimeGetCurrent()
                    
                    self.globalInfo.ftpManager.downloadDirectory(hostname: ftpInfo.hostname, user: ftpInfo.user, password: ftpInfo.password, root: ftpInfo.root, territory: ftpInfo.territory, remoteDirName: kProductCatalogDirName, localDirName: kProductCatalogDirName, shouldShowHUD: true, completion: { (success, message) in

                        //measure time
                        timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
                        print("Time elapsed for second DownloadDirectory: \(timeElapsed) s.")
                        
                        //measure time
                        startTime = CFAbsoluteTimeGetCurrent()
                        
                        self.globalInfo.ftpManager.downloadDirectory(hostname: ftpInfo.hostname, user: ftpInfo.user, password: ftpInfo.password, root: ftpInfo.root, territory: ftpInfo.territory, remoteDirName: kEquipmentCatalogDirName, localDirName: kEquipmentCatalogDirName, shouldShowHUD: true, completion: { (success, message) in

                            //measure time
                            timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
                            print("Time elapsed for Third DownloadDirectory: \(timeElapsed) s.")

                            //measure time
                            startTime = CFAbsoluteTimeGetCurrent()
                            self.globalInfo.loadCoreDataFromXML()
                            
                            //measure time
                            timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
                            print("Time elapsed for second LoadCoreXML: \(timeElapsed) s.")
                            
                            guard let routeControl = RouteControl.getAll(context: self.globalInfo.managedObjectContext).first else {
                                NSLog("doFirstLogin: Invalid RouteControl")
                                return
                            }

                            self.globalInfo.username = routeControl.userName ?? ""
                            self.globalInfo.password = routeControl.security1 ?? ""
                            self.globalInfo.territory = routeControl.trip ?? ""
                            //self.globalInfo.isUpdated = false
                            self.globalInfo.saveUserSetting()

                            self.usernameText.text = ""
                            self.passwordText.text = ""
                            self.territoryText.text = ""

                            self.globalInfo.ftpHostname = self.ftpLoginInfo!.ipAddress
                            self.globalInfo.ftpUsername = self.ftpLoginInfo!.username
                            self.globalInfo.ftpPassword = self.ftpLoginInfo!.password
                            self.globalInfo.ftpPort = self.ftpLoginInfo!.port
                            self.globalInfo.ftpRoot = self.ftpLoginInfo!.root
                            self.globalInfo.ftpChatCompanyCode = self.ftpLoginInfo!.chatCompanyCode
                            self.globalInfo.saveFTPSetting()

                            self.updateRightPanel()
                        })
                    })
                })
            }
            else {
                self.showNotFoundMatchedTripData()
                return
            }
        }
    }

    func doReLogin(ftpInfo: FTPInfo) {

        globalInfo.ftpManager.downloadXmls(hostname: ftpInfo.hostname, user: ftpInfo.user, password: ftpInfo.password, root: ftpInfo.root, territory: ftpInfo.territory, shouldShowHUD: true) { (success, message) in

            if success == true {

                self.globalInfo.ftpManager.downloadDirectoryFiles(hostname: ftpInfo.hostname, user: ftpInfo.user, password: ftpInfo.password, root: ftpInfo.root, territory: ftpInfo.territory, remoteDirName: kReportsDirName, remoteFileNames: kReportsFileNameArray, localDirName: kReportsDirName, shouldShowHUD: true, completion: { (success, message) in
                    if success == true {
                        self.updateLeftPanel()
                    }

                    self.globalInfo.ftpManager.downloadDirectory(hostname: ftpInfo.hostname, user: ftpInfo.user, password: ftpInfo.password, root: ftpInfo.root, territory: ftpInfo.territory, remoteDirName: kProductCatalogDirName, localDirName: kProductCatalogDirName, shouldShowHUD: true, completion: { (success, message) in

                        self.globalInfo.ftpManager.downloadDirectory(hostname: ftpInfo.hostname, user: ftpInfo.user, password: ftpInfo.password, root: ftpInfo.root, territory: ftpInfo.territory, remoteDirName: kEquipmentCatalogDirName, localDirName: kEquipmentCatalogDirName, shouldShowHUD: true, completion: { (success, message) in

                            self.globalInfo.loadCoreDataFromXML()
                            guard let routeControl = RouteControl.getAll(context: self.globalInfo.managedObjectContext).first else {
                                self.showNotFoundMatchedTripData()
                                return
                            }
                            self.globalInfo.username = routeControl.userName ?? ""
                            self.globalInfo.password = routeControl.security1 ?? ""
                            self.globalInfo.territory = routeControl.trip ?? ""
                            //self.globalInfo.isUpdated = false
                            self.globalInfo.saveUserSetting()

                            self.loginToQBAndOpenMain()
                        })
                    })
                })
            }
            else {
                self.showNotFoundMatchedTripData()
                return
            }
        }
    }

    func updateLeftPanel() {
        let companyLogoPath = CommData.getFilePathAppended(byCacheDir: kReportsDirName+"/"+kCompanyLogoFileName) ?? ""
        let image = UIImage.loadImageFromLocal(filePath: companyLogoPath)
        if image == nil {
            leftLogoImageView.image = UIImage(named: "Logo_Large")
        }
        else {
            leftLogoImageView.image = image
        }
    }

    func updateRightPanel() {

        globalInfo.loadFTPSetting()
        if globalInfo.ftpHostname == "" {
            usernameView.isHidden = true
            passwordView.isHidden = true
            territoryView.isHidden = false
            companyPinView.isHidden = false
            territoryLabelView.isHidden = true
            territoryTopConstraint.constant = -46.0
        }
        else {
            tripUserArray = TripUser.getAll(context: globalInfo.managedObjectContext)
            setupUsernameDropDown()

            usernameView.isHidden = false
            passwordView.isHidden = false
            territoryView.isHidden = false
            companyPinView.isHidden = true
            territoryTopConstraint.constant = 35.0

            if tripUserArray.count == 0 {
                usernameText.isHidden = false
                territoryText.isHidden = false
                usernameButtonView.isHidden = true
                territoryLabelView.isHidden = true
            }
            else {
                usernameText.isHidden = true
                territoryText.isHidden = true
                usernameButtonView.isHidden = false
                territoryLabelView.isHidden = false

                // set the previous user name in the list
                globalInfo.loadUserSetting()
                let oldUsername = globalInfo.username
                for tripUser in tripUserArray {
                    let userName = tripUser.userName ?? ""
                    if userName == oldUsername {
                        self.selectedTripUser = tripUser
                    }
                }
            }
        }
    }

    func setupUsernameDropDown() {

        usernameDropDown.cellHeight = usernameButton.bounds.height-10
        usernameDropDown.anchorView = usernameButton
        usernameDropDown.bottomOffset = CGPoint(x: 0, y: usernameButton.bounds.height)
        usernameDropDown.backgroundColor = CommData.color(fromHexString: "#C0C0C0")!
        usernameDropDown.textFont = usernameButton.titleLabel!.font

        let tripUsernameArray = tripUserArray.map({ (tripUser) -> String in
            return tripUser.userName ?? ""
        })
        usernameDropDown.dataSource = tripUsernameArray
        usernameDropDown.cellNib = UINib(nibName: "GeneralCenterDropDownCell", bundle: nil)
        usernameDropDown.customCellConfiguration = {_index, item, cell in
        }
        usernameDropDown.selectionAction = { index, item in
            self.selectedTripUser = self.tripUserArray[index]
        }
    }

    func loginToQBAndOpenMain() {

        globalInfo.isUpdated = false
        globalInfo.saveUserSetting()

        globalInfo.loadCoreData()
        globalInfo.resetForSignIn()

        // QB process
        globalInfo.currentQBUser = QBUUser()
        let companyCode = globalInfo.routeControl?.company ?? ""

        let userDefaults = UserDefaults.standard
        userDefaults.set(companyCode, forKey: kCompanyNameKey)
        userDefaults.synchronize()
        
        globalInfo.currentQBUser?.login = "\(companyCode)_\(globalInfo.username)"
        globalInfo.currentQBUser?.password = "dsdproduct_\(globalInfo.territory)"

        self.openMain()

        //let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow, animated: true)
        ServicesManager.instance().logIn(with: self.globalInfo.currentQBUser!, completion: { (success, message) in
            DispatchQueue.main.async {
                //hud?.hide(true)
                if success == true {
                    SVProgressHUD.showSuccess(withStatus: "Connected to DSD Chatter successfully")
                    //GlobalInfo.getAppDelegate().registerForRemoteNotification()

                    if (ServicesManager.instance().notificationService.pushDialogID != nil) {
                        ServicesManager.instance().notificationService.handlePushNotificationWithDelegate(delegate: self)
                    }
                    else {
                        Utils.registerChatService()
                    }
                }
                else {
                    NSLog("QB Sign in failed. \(message ?? "")")
                }
            }
        })
    }

    func openMain() {

        // remove unsaved order headers
        globalInfo.adjustCoreData()

        globalInfo.productImageDownloadManager.start()

        let mainVC = UIViewController.getViewController(storyboardName: "Main", storyboardID: "MainVC") as! MainVC
        mainVC.setFullScreenPresentation()
        self.present(mainVC, animated: true, completion: nil)
    }

    func showNotFoundMatchedTripData() {
        Utils.showAlert(vc: self, title: "ALERT", message: "Can't find the matched trip data", failed: false, customerName: "", leftString: "", middleString: "Ok", rightString: "", dismissHandler: nil)
    }

    func showInvalidSignOn() {
        Utils.showAlert(vc: self, title: "INVALID SIGN ON", message: "Username or Password is invalid", failed: false, customerName: "", leftString: "", middleString: "Return", rightString: "", dismissHandler: nil)
    }

    @IBAction func onUsernameButton(_ sender: Any) {
        usernameDropDown.show()
    }
}

extension LoginVC: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        let animatableTextField = textField as! AnimatableTextField
        animatableTextField.borderWidth = 1.0
        animatableTextField.borderColor = kTextSelectedBorderColor

        if isFTPLoggedin == false {
            if textField == companyPinText {
                companyPinImageView.image = #imageLiteral(resourceName: "Login_Username_Highlight")
            }
            else if textField == territoryText {
                territoryImageView.image = #imageLiteral(resourceName: "Login_Territory_Highlight")
            }
        }
        else {
            if textField == usernameText {
                usernameImageView.image = #imageLiteral(resourceName: "Login_Username_Highlight")
            }
            else if textField == passwordText {
                passwordImageView.image = #imageLiteral(resourceName: "Login_Password_Highlight")
            }
            else if textField == territoryText {
                territoryImageView.image = #imageLiteral(resourceName: "Login_Territory_Highlight")
            }
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        let animatableTextField = textField as! AnimatableTextField
        animatableTextField.borderWidth = 1.0
        animatableTextField.borderColor = kTextNormalBorderColor

        if isFTPLoggedin == false {
            if textField == companyPinText {
                companyPinImageView.image = #imageLiteral(resourceName: "Login_Username")
            }
            else if textField == territoryText {
                territoryImageView.image = #imageLiteral(resourceName: "Login_Territory")
            }
        }
        else {
            if textField == usernameText {
                usernameImageView.image = #imageLiteral(resourceName: "Login_Username")
            }
            else if textField == passwordText {
                passwordImageView.image = #imageLiteral(resourceName: "Login_Password")
            }
            else if textField == territoryText {
                territoryImageView.image = #imageLiteral(resourceName: "Login_Territory")
            }
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if isFTPLoggedin == false {
            if textField == territoryText {
                textField.resignFirstResponder()
                onLogin(loginButton)
                return false
            }
        }
        else {
            if textField == territoryText {
                textField.resignFirstResponder()
                onLogin(loginButton)
                return false
            }
        }
        return true
    }

}

extension LoginVC: NotificationServiceDelegate {

    func notificationServiceDidStartLoadingDialogFromServer() {
        SVProgressHUD.show(withStatus: "SA_STR_LOADING_DIALOG".localized, maskType: SVProgressHUDMaskType.clear)
    }

    func notificationServiceDidFinishLoadingDialogFromServer() {
        SVProgressHUD.dismiss()
    }

    func notificationServiceDidSucceedFetchingDialog(chatDialog: QBChatDialog!) {

        /*
         let dialogsController = self.storyboard?.instantiateViewController(withIdentifier: "DialogsViewController") as! DialogsViewController
         let chatController = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
         chatController.dialog = chatDialog

         self.navigationController?.viewControllers = [dialogsController, chatController]*/
    }

    func notificationServiceDidFailFetchingDialog() {
        //self.performSegue(withIdentifier: "SA_STR_SEGUE_GO_TO_DIALOGS".localized, sender: nil)
    }
}
