//
//  Utils.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/19/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import Foundation

class Utils {

    static var dialogsManager: DialogsManager?
    static var productLoconSCWTypeDictionary = [String: Int]()
    static var caseDictionary = [String: Int]()

    static func showAlert(vc: UIViewController, title: String, message: String, failed: Bool, customerName: String, leftString: String, middleString: String, rightString: String, dismissHandler: ((MessageDialogVC.ReturnCode) -> ())?) {
        let alertVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "MessageDialogVC") as! MessageDialogVC
        alertVC.setDefaultModalPresentationStyle()
        alertVC.strTitle = title
        alertVC.strMessage = message
        alertVC.isFailed = failed
        alertVC.strCustomerName = customerName
        alertVC.strLeft = leftString
        alertVC.strMiddle = middleString
        alertVC.strRight = rightString
        alertVC.dismissHandler = dismissHandler
        vc.present(alertVC, animated: true, completion: nil)
    }

    static func showInput(vc: UIViewController, title: String, placeholder: String, enteredString: String, leftString: String, middleString: String, rightString: String, dismissHandler: ((InputDialogVC.ReturnCode, String) -> ())?) {
        let alertVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "InputDialogVC") as! InputDialogVC
        alertVC.setDefaultModalPresentationStyle()
        alertVC.strTitle = title
        alertVC.strPlaceholder = placeholder
        alertVC.strEnteredString = enteredString
        alertVC.strLeft = leftString
        alertVC.strMiddle = middleString
        alertVC.strRight = rightString
        alertVC.dismissHandler = dismissHandler
        vc.present(alertVC, animated: true, completion: nil)
    }

    // Chat service
    static var chatServiceRegistered = false
    static func registerChatService() {
        chatServiceRegistered = true
        dialogsManager = DialogsManager()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kChatServiceChangedNotificationName), object: nil)
    }

    static func isExistChatService() -> Bool {
        return dialogsManager != nil
    }

    static func unregisterQbChatListeners() {
        chatServiceRegistered = false
        dialogsManager = nil
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kChatServiceChangedNotificationName), object: nil)
    }

    static func loadFromXML(xmlName: String, xPath: String) -> [[String: String]] {
        let filePath = CommData.getFilePathAppended(byCacheDir: "\(kXMLDirName)/\(xmlName).XML") ?? ""
        let url = URL(fileURLWithPath: filePath)
        guard let xmlData = try? Data(contentsOf: url) else {return []}
        //var xmlString = String(data: xmlData, encoding: .ascii) ?? ""
        var xmlString = String(data: xmlData, encoding: .utf8) ?? ""
        xmlString = xmlString.unescapeSpecialCharacters()

        // let xmlString = xmlData
        var dicArray = [[String: String]]()
        do {
            let doc = try GDataXMLDocument(xmlString: xmlString, options: 0)
            // let doc = try GDataXMLDocument(data: xmlData, options: 0)
            let elementArray = try doc.nodes(forXPath: xPath)
            for _element in elementArray {
                let element = _element as! GDataXMLElement
                let attributes = element.attributes()
                var dic = [String: String]()
                for _attribute in attributes! {
                    let attribute = _attribute as! GDataXMLNode
                    dic[attribute.name()] = attribute.stringValue()
                }
                dicArray.append(dic)
            }
            
            return dicArray
        }
        catch let error as NSError {
            
            NSLog("Load \(xmlName) XML failed: \(error.localizedDescription)")
            return []
        }
    }

    static func saveToXML(dicArray: [[String: String]], keyArray: [String], rootName: String, branchName: String, filePath: String) {

        let rootElement = GDataXMLNode.element(withName: rootName)
        for dic in dicArray {
            let branchElement = GDataXMLNode.element(withName: branchName)
            for key in keyArray {
                let value = dic[key]
                let leafElement = GDataXMLNode.element(withName: key, stringValue: value)
                branchElement!.addChild(leafElement!)
            }
            rootElement!.addChild(branchElement!)
        }
        let document = GDataXMLDocument(rootElement: rootElement)
        guard let xmlData = document!.xmlData() else {return}

        CommData.deleteFileIfExist(filePath)
        let fileURL = URL(fileURLWithPath: filePath)
        try? xmlData.write(to: fileURL, options: [NSData.WritingOptions.atomic])
    }

    static func getStringSetting(key: String) -> String {
        let userDefaults = UserDefaults.standard
        let settingValue = userDefaults.string(forKey: key) ?? ""
        return settingValue
    }

    static func getIntSetting(key: String) -> Int {
        let userDefaults = UserDefaults.standard
        let settingValue = userDefaults.integer(forKey: key)
        return settingValue
    }

    static func getDoubleSetting(key: String) -> Double {
        let userDefaults = UserDefaults.standard
        let settingValue = userDefaults.double(forKey: key)
        return settingValue
    }

    static func setStringSetting(key: String, value: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }

    static func setIntSetting(key: String, value: Int) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }

    static func setDoubleSetting(key: String, value: Double) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }

    static func getPDFFileName() -> String {
        let fileName = getOrderNo()+".pdf"
        return fileName
    }

    static func getOrderNo() -> String {

        let globalInfo = GlobalInfo.shared
        var orderNo = ""
        let tripNumber = globalInfo.routeControl?.trip ?? ""
        let pattern = globalInfo.routeControl?.invoiceNumFormat ?? ""
        let pdfSequenceNoKey = kPdfSequenceNoPrefix+tripNumber
        let pdfSequenceNo = Utils.getIntSetting(key: pdfSequenceNoKey)+1

        // kk value
        let rrr = globalInfo.routeControl?.routeNumber ?? ""
        let kkDescType = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "ROUTE", numericKey: rrr)
        let kk = kkDescType?.value1 ?? ""

        Utils.setIntSetting(key: pdfSequenceNoKey, value: pdfSequenceNo)

        let now = Date()
        let y = now.toDateString(format: "yyyy") ?? ""
        let dayOfYear = now.dayOfYear
        let jjj = "\(dayOfYear)"
        let sss = "\(pdfSequenceNo)"

        orderNo = ""

        var rIndex = 0
        var yIndex = 0
        var jIndex = 0
        var sIndex = 0
        var kIndex = 0

        var index = 0

        for i in (0..<pattern.length).reversed() {
            let c = pattern.subString(startIndex: i, length: 1)
            if c == "R" {
                index = rrr.length-rIndex-1
                if index >= 0 {
                    orderNo = rrr.subString(startIndex: index, length: 1)+orderNo
                }
                else {
                    orderNo = "0"+orderNo
                }
                rIndex += 1
            }
            else if c == "Y" {
                index = y.length-yIndex-1
                if index >= 0 {
                    orderNo = y.subString(startIndex: index, length: 1)+orderNo
                }
                else {
                    orderNo = "0"+orderNo
                }
                yIndex += 1
            }
            else if c == "J" {
                index = jjj.length-jIndex-1
                if index >= 0 {
                    orderNo = jjj.subString(startIndex: index, length: 1)+orderNo
                }
                else {
                    orderNo = "0"+orderNo
                }
                jIndex += 1
            }
            else if c == "S" {
                index = sss.length-sIndex-1
                if index >= 0 {
                    orderNo = sss.subString(startIndex: index, length: 1)+orderNo
                }
                else {
                    orderNo = "0"+orderNo
                }
                sIndex += 1
            }
            else if c == "K" {
                index = kk.length-kIndex-1
                if index >= 0 {
                    orderNo = kk.subString(startIndex: index, length: 1)+orderNo
                }
                else {
                    orderNo = "0"+orderNo
                }
                kIndex += 1
            }
        }

        return orderNo

    }

    static func getOrderNo(value: String, format: String) -> String {
        let nFormatLen = format.length
        let valueString = value.subString(startIndex: value.length-nFormatLen, length: nFormatLen)
        return valueString
    }

    static func getProductLoconSCWType(itemNo: String) -> Int {
        var type = productLoconSCWTypeDictionary[itemNo]
        let globalInfo = GlobalInfo.shared
        if type == nil {
            type = ProductLocn.getProdLocnSCWType(context: globalInfo.managedObjectContext, itemNo: itemNo)
            productLoconSCWTypeDictionary[itemNo] = type
        }
        return type ?? 0
    }

    static func getXMLDivided(valueString: String) -> Double {
        let value = Double(valueString) ?? 0
        return value/Double(kXMLNumberDivider)
    }

    static func getXMLMultiplied(value: Double) -> Double {
        return value*Double(kXMLNumberDivider)
    }

    static func getXMLMultipliedString(value: Double) -> String {
        return getXMLMultiplied(value:value).integerString
    }

    static func printDebug(message: String) {
        SVProgressHUD.showInfo(withStatus: message)
    }

    static func getMoneyString(moneyValue: Double) -> String {

        let numberFormat = NumberFormatter()
        numberFormat.maximumFractionDigits = 2
        numberFormat.minimumFractionDigits = 2
        numberFormat.minimumIntegerDigits = 1
        numberFormat.usesGroupingSeparator = true
        numberFormat.groupingSeparator = ","
        numberFormat.groupingSize = 3
        let result = numberFormat.string(from: NSNumber(value: moneyValue)) ?? "0.00"

        let globalInfo = GlobalInfo.shared
        let currencySymbol = globalInfo.routeControl?.currencySymbol ?? ""
        return "\(currencySymbol)\(result)"
    }

    static func getCaseValue(itemNo: String) -> Int {
        let globalInfo = GlobalInfo.shared
        if caseDictionary.count == 0 {
            caseDictionary = ProductLocn.getCaseDictionary(context: globalInfo.managedObjectContext)
        }
        var _case = 1
        if let resultCase = caseDictionary[itemNo] {
            _case = resultCase
        }
        if _case < 1 {
            _case = 1
        }
        return _case
    }

    static func buildBaseURLMap() {
        let globalInfo = GlobalInfo.shared
        globalInfo.urlBaseMap = [:]

        var keyInt = 1
        for ch in 97..<97+26 {
            let key = keyInt.toLeftPaddedString(digitCount: 2) ?? ""
            let s = String(UnicodeScalar(UInt8(ch)))
            globalInfo.urlBaseMap[key] = s
            keyInt += 1
        }
    }

    static func getBaseURL(pinNumber: String) -> String {
        let urlSuffix = getURLSuffix(pinNumber: pinNumber)
        let resultPath = "https://dsdconnect\(urlSuffix).dsdassist.com/"
        return resultPath
    }

    static func getURLSuffix(pinNumber: String) -> String {

        let _pinNumber = pinNumber as NSString
        let key1 = _pinNumber.substring(with: NSMakeRange(0, 2))
        let key2 = _pinNumber.substring(with: NSMakeRange(2, 2))
        let key3 = _pinNumber.substring(with: NSMakeRange(4, 2))

        let globalInfo = GlobalInfo.shared
        let value1 = globalInfo.urlBaseMap[key1] ?? ""
        let value2 = globalInfo.urlBaseMap[key2] ?? ""
        let value3 = globalInfo.urlBaseMap[key3] ?? ""

        return "\(value1)\(value2)\(value3)"
    }

    static func getWeekday(date: Date) -> Int {
        let weekday = date.weekday
        if weekday == 1 {
            return 7
        }
        else {
            return weekday-1
        }
    }

    static func refreshToken(completion: @escaping (Bool, String) -> Void) {
        let userDefaults = UserDefaults.standard
        let pinNumber = userDefaults.string(forKey: kDeliveryLoginPinNumberKey) ?? ""
        //let pinNumber = kDeliveryPinNumber
        let userName = userDefaults.string(forKey: kDeliveryLoginUserNameKey) ?? ""
        let userPassword = userDefaults.string(forKey: kDeliveryLoginPasswordKey) ?? ""
        if userName.isEmpty == false {
            var params = [String: String]()
            params["username"] = userName
            params["password"] = userPassword

            let baseURL = Utils.getBaseURL(pinNumber: pinNumber)
            APIManager.doNormalRequest(baseURL: baseURL, methodName: "api/login", httpMethod: "POST", params: params, shouldShowHUD: true, completion: { (response, message) in
                if response == nil {
                    completion(false, message)
                }
                else {
                    let json = JSON(data: response as! Data)
                    let loginInfo = LoginInfo.from(json: json)
                    let loginToken = userDefaults.string(forKey: kDeliveryLoginTokenKey) ?? ""
                    if loginToken.isEmpty == false {
                        if loginInfo != nil {
                            let token = loginInfo!.token
                            userDefaults.set(token, forKey: kDeliveryLoginTokenKey)
                            userDefaults.synchronize()
                        }
                    }
                    completion(true, "")
                }
            })
        }
    }

    static func refreshTokenForGeneral(completion: @escaping (Bool, String) -> Void) {
        let userDefaults = UserDefaults.standard
        let pinNumber = userDefaults.string(forKey: kDeliveryLoginPinNumberKey) ?? ""
        //let pinNumber = kDeliveryPinNumber
        let userName = userDefaults.string(forKey: kDeliveryLoginUserNameKey) ?? ""
        let userPassword = userDefaults.string(forKey: kDeliveryLoginPasswordKey) ?? ""
        if userName.isEmpty == false {
            var params = [String: String]()
            params["username"] = userName
            params["password"] = userPassword

            let baseURL = Utils.getBaseURL(pinNumber: pinNumber)
            APIManager.doNormalRequest(baseURL: baseURL, methodName: "api/login", httpMethod: "POST", params: params, shouldShowHUD: true, completion: { (response, message) in
                if response == nil {
                    completion(false, message)
                }
                else {
                    let json = JSON(data: response as! Data)
                    let loginInfo = LoginInfo.from(json: json)
                    let loginToken = userDefaults.string(forKey: kDeliveryLoginTokenKey) ?? ""
                    if loginToken.isEmpty == false {
                        if loginInfo != nil {
                            let token = loginInfo!.token
                            userDefaults.set(token, forKey: kDeliveryLoginTokenKey)
                            userDefaults.synchronize()
                        }
                    }
                    completion(true, "")
                }
            })
        }
    }

    static func showPDF(vc: UIViewController, strDocNo: String, strDate: String) {
        let localFileName = strDocNo + "_" + strDate + ".pdf"
        let localPath = CommData.getFilePathAppended(byCacheDir: localFileName) ?? ""
        if CommData.isExistingFile(atPath: localPath) == true {
            launchPDF(vc: vc, strPath: localPath)
            return
        }

        let userDefaults = UserDefaults.standard
        let strPinNumber = userDefaults.string(forKey: kDeliveryLoginPinNumberKey) ?? ""
        // let strPinNumber = kDeliveryPinNumber
        let baseURL = Utils.getBaseURL(pinNumber: strPinNumber)
        let strURL = baseURL + "api/document-archive?docno=" + strDocNo + "&date=" + strDate

        // download files
        APIManager.downloadMedia(sourceURL: strURL, downloadPath: localPath) { (success, message) in
            if success == true {
                Utils.launchPDF(vc: vc, strPath: localPath)
            }
            else {
                NSLog("Media download failed: \(message)")
                Utils.showAlert(vc: vc, title: "", message: L10n.pdfNotAbleToBeRetrieved(), failed: false, customerName: "", leftString: "", middleString: L10n.ok(), rightString: "", dismissHandler: nil)
                CommData.deleteFileIfExist(localPath)
            }
        }

    }

    static func launchPDF(vc: UIViewController, strPath: String) {
        let url = URL(fileURLWithPath: strPath)
        //guard let data = try? Data(contentsOf: url) else {return}
        let pdfViewerVC = UIViewController.getViewController(storyboardName: "Delivery", storyboardID: "DeliveryPDFViewerVC") as! DeliveryPDFViewerVC
        pdfViewerVC.pdfURL = url
        //pdfViewerVC.data = data
        pdfViewerVC.setDefaultModalPresentationStyle()
        vc.present(pdfViewerVC, animated: true, completion: nil)
    }

    static func getFormattedTime(original: String) -> String {
        let value = Int(original) ?? 0
        let result = value.toLeftPaddedString(digitCount: 4) ?? ""
        return result
    }

    static func getProductImage(itemNo: String) -> UIImage? {
        var productImage: UIImage?
        // check jpg
        let catalogPath = CommData.getFilePathAppended(byCacheDir: kProductCatalogDirName) ?? ""
        var itemImagePath = catalogPath+"/"+itemNo+".jpg"
        productImage = UIImage.loadImageFromLocal(filePath: itemImagePath)

        if productImage == nil {
            // check png
            itemImagePath = catalogPath+"/"+itemNo+".png"
            productImage = UIImage.loadImageFromLocal(filePath: itemImagePath)

            if productImage == nil {
                // check bmp
                itemImagePath = catalogPath+"/"+itemNo+".bmp"
                productImage = UIImage.loadImageFromLocal(filePath: itemImagePath)
            }
        }
        return productImage
    }

    static func getProductImageFileName(itemNo: String) -> String {
        let catalogPath = CommData.getFilePathAppended(byCacheDir: kProductCatalogDirName) ?? ""
        var itemImagePath = catalogPath+"/"+itemNo+".jpg"
        if CommData.isExistingFile(atPath: itemImagePath) == true {
            return itemNo+".jpg"
        }
        itemImagePath = catalogPath+"/"+itemNo+".png"
        if CommData.isExistingFile(atPath: itemImagePath) == true {
            return itemNo+".png"
        }
        itemImagePath = catalogPath+"/"+itemNo+".bmp"
        if CommData.isExistingFile(atPath: itemImagePath) == true {
            return itemNo+".bmp"
        }
        return ""
    }

    static func showProductDetailVC(vc: UIViewController, productDetail: ProductDetail, customerDetail: CustomerDetail, isForInputQty: Bool, inputQty: Int, dismissHandler: ((ProductDetailVC, ProductDetailVC.DismissOption)->())?) {
        let productDetailVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "ProductDetailVC") as! ProductDetailVC
        productDetailVC.productDetail = productDetail
        productDetailVC.customerDetail = customerDetail
        productDetailVC.isForInputQty = isForInputQty
        productDetailVC.dismissHandler = dismissHandler
        productDetailVC.inputedQty = inputQty
        productDetailVC.setDefaultModalPresentationStyle()
        vc.present(productDetailVC, animated: true, completion: nil)
    }

    static func getCardLength(cardNo1: String) -> Int {
        if hasAnyPrefix(number: cardNo1, prefixes: kAmericanExpressPrefixes) {
            return 15
        }
        if hasAnyPrefix(number: cardNo1, prefixes: kDinersClubPrefixes) {
            return 14
        }
        return 16
    }

    static func hasAnyPrefix(number: String, prefixes: [String]) -> Bool {
        for prefix in prefixes {
            if number.starts(with: prefix) == true {
                return true
            }
        }
        return false
    }

    static func getLocalFileModifiedDate(filePath: String) -> Date? {
        let defaultManager = FileManager.default
        guard let attributes = try? defaultManager.attributesOfItem(atPath: filePath) else {return nil}
        let modifiedDate = attributes[FileAttributeKey.modificationDate] as? NSDate
        return modifiedDate?.date
    }

    static func getRemoteFileSize(url: URL) -> UInt64 {
        var contentLength = NSURLSessionTransferSizeUnknown
        let request = NSMutableURLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 5.0
        let group = DispatchGroup()
        group.enter()

        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            contentLength = response?.expectedContentLength ?? NSURLSessionTransferSizeUnknown
            group.leave()
        }.resume()
        let _ = group.wait(timeout: .now()+5.0)

        if contentLength < 0 {
            return 0
        }
        else {
            return UInt64(contentLength)
        }
    }
}
