//
//  GlobalInfo.swift
//  iRis
//
//  Created by iOS Developer on 5/20/16.
//  Copyright © 2016 QScope. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Quickblox
import ExternalAccessory

class GlobalInfo: NSObject {

    /// 2020-3-10 RSB
    var isFromInProgressExistingOrder = false
    var isFromMarginCalculator = 0
    var isFromProductCatalog = 0
    
    enum Lang: String {
        case en_gb = "EUK"
        case gn_us = "EUS"
    }
    
    enum DateFmt: String {
        case dmy = "dmy"
        case mdy = "mdy"
    }
    
    static var language: Lang = .en_gb
    static var dateFmt: DateFmt = .dmy
    
    var ftpManager: FTPManager!
    var uploadManager: UploadManager!
    var productImageDownloadManager: ProductImageDownloadManager!

    var selectedCustomer: CustomerDetail?
    var selectedPresoldOrHeader: PresoldOrHeader?
    
    // XML
    var routeControl: RouteControl?
    var target: Target?
    var descTypeArrary = [DescType]()
    var kpiArray = [KPI]()
    var customerDetailArray = [CustomerDetail]()
    var customerContactArray = [CustomerContact]()

    var termsText: String = ""

    var username = ""
    var password = ""
    var territory = ""
    var isUpdated = false

    var ftpHostname = ""
    var ftpUsername = ""
    var ftpPassword = ""
    var ftpRoot = ""
    var ftpPort = ""
    var ftpChatCompanyCode = ""

    // location track to get background process
    var locationTracker: LocationTracker!
    var gpsLogger: GPSLogger!

    var dCurrentTotalValue: Double = 0
    var pageHeightWhenZero: Double = 0

    var orderDetailSetArray = [NSMutableOrderedSet](repeating: NSMutableOrderedSet(), count: 3)
    var orderHeader: OrderHeader!
    // Zebra printer
    var selectedPrinter: EAAccessory?

    var managedObjectContext: NSManagedObjectContext!

    // quick blocks user
    var currentQBUser: QBUUser?

    var urlBaseMap = [String: String]()
    var tripInfoList = [TripInfo]()

    var customerTypeDescTypeArray = [DescType]()
    var selectedCustomerTypeDescType: DescType?
    var opportunityPostCode: String = ""
    var selectedOpportunityCustomer: CustomerDetail?
    var customerOpportunityArray = [CustomerOpportunity]()
    var customerOpportunityDictionary = [String: [CustomerOpportunity]]()
    var customerPricingDictionary = [String: [CustomerPricingItem]]()

    var productItemDictionary = [String: ProductDetail]()
    var productUPCDictionary = [String: ProductDetail]()
    
    static var shared: GlobalInfo {
        if gbInstance == nil {
            gbInstance = GlobalInfo()
            gbInstance!.initAppearance()
            gbInstance!.initData()
            gbInstance!.initLocationTrack()
            return gbInstance!
        }
        return gbInstance!
    }

    static func getAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    //unsaved order flag
    var confirmFromOrderSales = 1
}

var gbInstance:GlobalInfo?

// MARK: -CoreData extension
extension GlobalInfo {

    static func getManagedObjectContext() -> NSManagedObjectContext {
        return getAppDelegate().managedObjectContext
    }

    static func getQueueManagedObjectContext() -> NSManagedObjectContext {
        return getAppDelegate().queueManagedObjectContext
    }
    
    static func saveCache() {
        getAppDelegate().saveContext()
    }

    static func undoCache() {
        
    }

    static func clearAllData() {

    }

}

// MARK: -Appearance setting
extension GlobalInfo {

    func initData() {
        managedObjectContext = GlobalInfo.getManagedObjectContext()
        ftpManager = FTPManager()
        uploadManager = UploadManager()
        uploadManager.initManager()
        gpsLogger = GPSLogger()
        productImageDownloadManager = ProductImageDownloadManager()
    }

    func loadCoreDataFromXML(isReLogin: Bool) {
        let _ = RouteControl.loadFromXML(context: managedObjectContext, forSave: true).first
        let _ = Target.loadFromXML(context: managedObjectContext, forSave: true)
        let _ = DescType.loadFromXML(context: managedObjectContext, forSave: true)
        let _ = KPI.loadFromXML(context: managedObjectContext, forSave: true)
        let _ = CustomerDetail.loadFromXML(context: managedObjectContext, forSave: true)
        let _ = CustomerContact.loadFromXML(context: managedObjectContext, forSave: true)
        let _ = PresoldOrHeader.loadFromXML(context: managedObjectContext, forSave: true)
        let _ = Pricing.loadFromXML(context: managedObjectContext, forSave: true)
        let _ = ProductDetail.loadFromXML(context: managedObjectContext, forSave: true)
        let _ = PriceGroup.loadFromXML(context: managedObjectContext, forSave: true)
        let _ = OrderHistory.loadFromXML(context: managedObjectContext, forSave: true)
        let _ = CompanyContact.loadFromXML(context: managedObjectContext, forSave: true)
        let _ = TripUser.loadFromXML(context: managedObjectContext, forSave: true)
        let _ = CustInfo.loadFromXML(context: managedObjectContext, forSave: true)
        let _ = CustNote.loadFromXML(context: managedObjectContext, forSave: true)
        
        UploadService.deleteAll(context: managedObjectContext)
        Visit.deleteAll(context: managedObjectContext)

        // load survey and attach to customer details
        let surveyArray = Survey.loadFromXML(context: managedObjectContext, forSave: false)
        let surveyQuestionArray = SurveyQuestion.loadFromXML(context: managedObjectContext, forSave: false)
        let surveyAnswerOptionArray = SurveyAnswerOption.loadFromXML(context: managedObjectContext, forSave: false)

        let customerDetailArray = CustomerDetail.getAll(context: managedObjectContext)
        for customerDetail in customerDetailArray {
            customerDetail.fillSurveys(context: managedObjectContext, surveyArray: surveyArray)
            let surveySet = customerDetail.surveySet
            for _survey in surveySet {
                let survey = _survey as! Survey
                survey.fillQuestions(context: managedObjectContext, questionArray: surveyQuestionArray)
                let questionSet = survey.questionSet
                for _question in questionSet {
                    let question = _question as! SurveyQuestion
                    question.fillAnswerOptions(context: managedObjectContext, answerOptions: surveyAnswerOptionArray)
                }
            }
        }
        
        let _ = ShelfStatus.loadFromXML(context: managedObjectContext, forSave: true)
        let _ = PromotionHeader.loadFromXML(context: managedObjectContext, forSave: true)
        let _ = PromotionNoVo.loadFromXML(context: managedObjectContext, forSave: true)
        let _ = PromotionAss.loadFromXML(context: managedObjectContext, forSave: true)
        let _ = PromotionOption.loadFromXML(context: managedObjectContext, forSave: true)
        let _ = EquipAss.loadFromXML(context: managedObjectContext, forSave: true)
        let _ = Equipment.loadFromXML(context: managedObjectContext, forSave: true)
        let _ = DocText.loadFromXML(context: managedObjectContext, forSave: true)
        EquipCompleteStatus.deleteAll(context: managedObjectContext)

        let _ = AuthHeader.loadFromXML(context: managedObjectContext, forSave: true)
        let _ = AuthDetail.loadFromXML(context: managedObjectContext, forSave: true)

        let productStructArray = ProductStruct.loadFromXML(context: managedObjectContext, forSave: true)
        
        //measure time
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for productStruct in productStructArray {
            let reference = productStruct.reference ?? ""
            let productDetail = ProductDetail.getByFromDic(context: managedObjectContext, itemNo: reference)
            productStruct.shortDesc = productDetail?.shortDesc ?? ""
            productStruct.fullDesc = productDetail?.desc ?? ""
        }
        
        //measure time
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("XML loading time: \(timeElapsed).")

        let productLocnArray = ProductLocn.loadFromXML(context: managedObjectContext, forSave: true)
        for productLocn in productLocnArray {
            let itemNo = productLocn.itemNo ?? ""
            if let productDetail = ProductDetail.getByFromDic(context: managedObjectContext, itemNo: itemNo) {
                productDetail.productLocn = productLocn
            }
        }
        //let productLevlPath = CommData.getFilePathAppended(byCacheDir: "\(kXMLDirName)/PRODLEVL.XML") ?? ""
        //let isProductLevelExist = CommData.isExistingFile(atPath: productLevlPath)
        let productLevlArray = ProductLevl.loadFromXML(context: managedObjectContext, forSave: true)
        let routeControl = RouteControl.getAll(context: managedObjectContext).first
        let defLocNo = routeControl?.defLocNo ?? ""
        for productLevl in productLevlArray {
            let itemNo = productLevl.itemNo ?? ""
            let locNo = productLevl.locNo ?? ""
            if locNo != defLocNo {
                continue
            }
            if let productDetail = ProductDetail.getByFromDic(context: managedObjectContext, itemNo: itemNo) {
                productDetail.productLevl = productLevl
            }
        }

        // add promotion
        let _ = PresoldOrDetail.loadFromXML(context: managedObjectContext, forSave: true)
        let _ = TaxCodes.loadFromXML(context: managedObjectContext, forSave: true)
        let _ = TaxRates.loadFromXML(context: managedObjectContext, forSave: true)
        let _ = ARHeader.loadFromXML(context: managedObjectContext, forSave: true)
        
        if isReLogin == false {
            OrderHeader.deleteAll(context: managedObjectContext)
            OrderDetail.deleteAll(context: managedObjectContext)
            UTax.deleteAll(context: managedObjectContext)
            UPromotion.deleteAll(context: managedObjectContext)
            UAR.deleteAll(context: managedObjectContext)
            UARPayment.deleteAll(context: managedObjectContext)

            removeUARPaymentPDF()
        }
        
        initSetting()

        GlobalInfo.saveCache()
    }

    func removeUARPaymentPDF() {
        let pdfName = Utils.getStringSetting(key: kCollectionsBalancingPDFNameKey)
        if pdfName == "" {
            return
        }
        let pdfPath = CommData.getFilePathAppended(byCacheDir: kPDFDirName+"/"+pdfName)
        if CommData.isExistingFile(atPath: pdfPath) {
            CommData.deleteFileIfExist(pdfPath)
        }
        Utils.setStringSetting(key: kCollectionsBalancingPDFNameKey, value: "")
    }

    func clearDataForNewTrip() {
        CustomerDetail.deleteAll(context: managedObjectContext)
    }

    func adjustCoreData() {

//        if isFromInProgressExistingOrder {
//            setInProgressFlag()
//        }
        
        setInProgressFlag()
        removeUnsavedOrderDetailsFromInProgressOrderHeader()
        GlobalInfo.saveCache()
    }

    func removeUnsavedOrderDetailsFromCompletedOrderHeader() {

        let allOrderDetails = OrderDetail.getAll(context: managedObjectContext)
        let unsavedOrderDetails = allOrderDetails.filter { (orderDetail) -> Bool in
            return (orderDetail).isSaved == false
        }

        for orderDetail in unsavedOrderDetails {
            OrderDetail.delete(context: managedObjectContext, orderDetail: orderDetail)
        }
        
    }
    
    func removeUnsavedOrderDetailsFromInProgressOrderHeader() {

        let allOrderDetails = OrderDetail.getAll(context: managedObjectContext)
        let unsavedOrderDetails = allOrderDetails.filter { (orderDetail) -> Bool in
            return (orderDetail).isInProgress == true && (orderDetail).isSaved == false
        }

        for orderDetail in unsavedOrderDetails {
            OrderDetail.delete(context: managedObjectContext, orderDetail: orderDetail)
        }
        
    }
    
    func setInProgressFlag() {
        
        let allOrderDetails = OrderDetail.getAll(context: managedObjectContext)
        let unsavedOrderDetails = allOrderDetails.filter { (orderDetail) -> Bool in
            return (orderDetail).isInProgress == true
        }

        for orderDetail in unsavedOrderDetails {
            orderDetail.isInProgress = false
        }
    }
    
    func initSetting() {
        Utils.setIntSetting(key: kPrefUInvenTrxnNo, value: 0)
    }

    func loadCoreData() {

        routeControl = RouteControl.getAll(context: managedObjectContext).first
        GlobalInfo.language = Lang(rawValue: routeControl?.language ?? "EUK") ?? .en_gb
        GlobalInfo.dateFmt = DateFmt(rawValue: routeControl?.dateFmt ?? "dmy") ?? .dmy
        target = Target.getAll(context: managedObjectContext).first
        
        descTypeArrary = DescType.getAll(context: managedObjectContext)
        kpiArray = KPI.getAll(context: managedObjectContext)
        customerDetailArray = CustomerDetail.getAll(context: managedObjectContext)
        customerContactArray = CustomerContact.getAll(context: managedObjectContext)
        termsText = Terms.loadFromXML() ?? ""
    }

    func initLocationTrack() {
        locationTracker = LocationTracker()
        locationTracker.restartLocationUpdates()
    }
    
    func initAppearance() {
        
        SVProgressHUD.setBackgroundColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.8))
        SVProgressHUD.setForegroundColor(UIColor.white)
        // SVProgressHUD.setInfoImage(UIImage())
        SVProgressHUD.setFont(UIFont(name: "Avenir-Book", size: 14.0)!)

        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = kNavBackColor
        UINavigationBar.appearance().titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.foregroundColor.rawValue:kNavTextColor!, NSAttributedString.Key.font.rawValue:UIFont.boldSystemFont(ofSize: 20.0)])
        UINavigationBar.appearance().tintColor = kNavTextColor

        // Remove tab bar upper border
        UITabBar.appearance().layer.borderWidth = 0.0
        UITabBar.appearance().clipsToBounds = true

        // set status bar color
        // UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)
        UIApplication.shared.isStatusBarHidden = true
    }
}

// MARK: -Root view selection
extension GlobalInfo {

    func loadUserSetting() {
        let userDefaults = UserDefaults.standard
        username = userDefaults.string(forKey: kLoginUserNameKey) ?? ""
        password = userDefaults.string(forKey: kLoginPasswordKey) ?? ""
        territory = userDefaults.string(forKey: kLoginTerritoryKey) ?? ""
        isUpdated = userDefaults.bool(forKey: kLoginUpdatedKey)
    }

    func loadFTPSetting() {
        let userDefaults = UserDefaults.standard
        ftpHostname = userDefaults.string(forKey: kFTPIPAddressKey) ?? ""
        ftpUsername = userDefaults.string(forKey: kFTPUsernameKey) ?? ""
        ftpPassword = userDefaults.string(forKey: kFTPPasswordKey) ?? ""
        ftpChatCompanyCode = userDefaults.string(forKey: kFTPChatCompanyKey) ?? ""
        ftpPort = userDefaults.string(forKey: kFTPPortKey) ?? ""
        ftpRoot = userDefaults.string(forKey: kFTPRootKey) ?? ""
    }

    func saveUserSetting() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(username, forKey: kLoginUserNameKey)
        userDefaults.set(password, forKey: kLoginPasswordKey)
        userDefaults.set(territory, forKey: kLoginTerritoryKey)
        userDefaults.set(isUpdated, forKey: kLoginUpdatedKey)
        userDefaults.synchronize()
    }

    func saveFTPSetting() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(ftpHostname, forKey: kFTPIPAddressKey)
        userDefaults.set(ftpUsername, forKey: kFTPUsernameKey)
        userDefaults.set(ftpPassword, forKey: kFTPPasswordKey)
        userDefaults.set(ftpChatCompanyCode, forKey: kFTPChatCompanyKey)
        userDefaults.set(ftpPort, forKey: kFTPPortKey)
        userDefaults.set(ftpRoot, forKey: kFTPRootKey)
        userDefaults.synchronize()
    }
}

extension GlobalInfo {

    func resetForSignIn() {

        resetOpportunities()
        customerOpportunityDictionary = [:]
        customerPricingDictionary = [:]
        productItemDictionary = [:]
        productUPCDictionary = [:]
    }

    func getCurrentLocation() -> CLLocationCoordinate2D {
        let defaultLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        guard let locationTracker = self.locationTracker else {return defaultLocation}
        let currentLocation = locationTracker.myLocation
        return currentLocation
    }

    func resetOpportunities() {
        selectedOpportunityCustomer = nil
        selectedCustomerTypeDescType = nil
        customerTypeDescTypeArray = []
        opportunityPostCode = ""
        customerOpportunityArray = []
    }

    func loadDefaultOpportunities(selectedCustomer: CustomerDetail) {
        // set default customer type and post code
        loadDefaultTypeAndPostCode(selectedCustomer: selectedCustomer)
        loadOpportunities(selectedCustomer: selectedCustomer)
    }

    func loadDefaultTypeAndPostCode(selectedCustomer: CustomerDetail) {

        let descTypeArray = DescType.getBy(context: managedObjectContext, descTypeID: "CustomerType")
        customerTypeDescTypeArray = descTypeArray.sorted(by: { (descType1, descType2) -> Bool in
            let desc1 = descType1.desc ?? ""
            let desc2 = descType2.desc ?? ""
            return desc1 < desc2
        })

        let type = selectedCustomer.type ?? ""
        for descType in customerTypeDescTypeArray {
            if type == descType.alphaKey {
                selectedCustomerTypeDescType = descType
                break
            }
        }
        if selectedCustomerTypeDescType == nil {
            selectedCustomerTypeDescType = customerTypeDescTypeArray.first
        }
        opportunityPostCode = "0"
    }

    func loadOpportunities(selectedCustomer: CustomerDetail) {

        selectedOpportunityCustomer = selectedCustomer
        let postCode = self.opportunityPostCode
        let typeAlphaKey = selectedCustomerTypeDescType?.alphaKey ?? ""

        let chainNo = selectedOpportunityCustomer?.chainNo ?? "0"
        let custNo = selectedOpportunityCustomer?.custNo ?? "0"
        let dicKey = "\(custNo)_\(chainNo)_\(typeAlphaKey)_\(postCode)"

        if let storedArray = customerOpportunityDictionary[dicKey] {
            customerOpportunityArray = storedArray
            return
        }

        var customers = [CustomerDetail]()
        if postCode == "0" || postCode == "" {
            customers = CustomerDetail.getBy(context: managedObjectContext, type: typeAlphaKey)
        }
        else {
            customers = CustomerDetail.getBy(context: managedObjectContext, type: typeAlphaKey, zip: postCode)
        }
        customers = customers.filter({ (customerDetail) -> Bool in
            if customerDetail.isRouteScheduled == true {
                return false
            }
            return true
        })
        var allOrderHistoryArray = [OrderHistory]()
        let thisCustNo = selectedCustomer.custNo ?? ""
        let thisChainNo = selectedCustomer.chainNo ?? ""
        for customer in customers {
            let custNo = customer.custNo ?? ""
            let chainNo = customer.chainNo ?? ""

            if chainNo == thisChainNo && custNo == thisCustNo {
                continue
            }

            let orderHistoryArray = OrderHistory.getBy(context: managedObjectContext, chainNo: chainNo, custNo: custNo)
            for orderHistory in orderHistoryArray {
                let itemNo = orderHistory.itemNo ?? ""
                guard let _ = ProductDetail.getBy(context: managedObjectContext, itemNo: itemNo) else {continue}
                allOrderHistoryArray.append(orderHistory)
            }
        }

        let historyCount = allOrderHistoryArray.count
        let removeCount = max(0, historyCount-5)
        allOrderHistoryArray.removeLast(removeCount)
        let customerCount = customers.count

        customerOpportunityArray.removeAll()
        for orderHistory in allOrderHistoryArray {
            let customerOpportunity = CustomerOpportunity()
            customerOpportunity.orderHistory = orderHistory
            let itemNo = orderHistory.itemNo ?? "0"
            let productDetail = ProductDetail.getBy(context: managedObjectContext, itemNo: itemNo)
            customerOpportunity.productDetail = productDetail

            // calculate the ranging percent
            var rangingCount = 0
            for customer in customers {
                let chainNo = customer.chainNo ?? ""
                let custNo = customer.custNo ?? ""
                let firstOrderHistory = OrderHistory.getFirstBy(context: managedObjectContext, chainNo: chainNo, custNo: custNo, itemNo: itemNo)
                if firstOrderHistory != nil {
                    rangingCount += 1
                }
            }
            var rangingPercent: Double = 0
            if customerCount > 0 {
                rangingPercent = Double(rangingCount)/Double(customerCount)*100
            }
            customerOpportunity.rangingPercent = rangingPercent

            customerOpportunityArray.append(customerOpportunity)
        }
        customerOpportunityArray = customerOpportunityArray.sorted(by: { (opportunity1, opportunity2) -> Bool in
            return opportunity1.rangingPercent > opportunity2.rangingPercent
        })

        customerOpportunityDictionary[dicKey] = customerOpportunityArray
    }

    func loadCustomerPricingItems(customerDetail: CustomerDetail) -> [CustomerPricingItem] {
        let custNo = customerDetail.custNo ?? "0"
        let chainNo = customerDetail.chainNo ?? "0"
        let dicKey = "\(chainNo)_\(custNo)"
        if let oldItems = customerPricingDictionary[dicKey] {
            return oldItems
        }

        var pricingItemArray: [CustomerPricingItem] = []

        let custLocation = customerDetail.location ?? ""

        let prodLocnArray = ProductLocn.getAll(context: managedObjectContext)
        for prodLocn in prodLocnArray {
            if prodLocn.locnNo != custLocation {
                continue
            }
            let itemNo = prodLocn.itemNo ?? ""
            
            //use Dic as Loading Speed Issue
            //guard let _productDetail = ProductDetail.getBy(context: managedObjectContext, itemNo: itemNo) else {continue}
            //let _pricing = Pricing.getByForToday(context: managedObjectContext, chainNo: chainNo, custNo: custNo, itemNo: itemNo)
            
            guard let productDetail = ProductDetail.getByFromDic(context: managedObjectContext, itemNo: itemNo) else {continue}
            let pricing = Pricing.getByForTodayFromDic(context: managedObjectContext, chainNo: chainNo, custNo: custNo, itemNo: itemNo)
            let pricingItem = CustomerPricingItem()
            pricingItem.productDetail = productDetail
            pricingItem.pricing = pricing
            pricingItemArray.append(pricingItem)
        }

        pricingItemArray = pricingItemArray.sorted { (item1, item2) -> Bool in
            let itemNo1 = item1.productDetail!.itemNo ?? ""
            let itemNo2 = item2.productDetail!.itemNo ?? ""
            //let entryID1 = productSeqDictionary[itemNo1] ?? 99999
            //let entryID2 = productSeqDictionary[itemNo2] ?? 99999
            return itemNo1 < itemNo2
        }

        customerPricingDictionary[dicKey] = pricingItemArray
        return pricingItemArray
    }

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
