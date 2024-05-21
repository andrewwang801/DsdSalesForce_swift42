// 
//  Constants.swift
//  ThePlanner 
// 
//  Created by iOS Developer on 11/6/16. 
//  Copyright © 2016 iOS Developer. All rights reserved. 
//  

import Foundation
import UIKit

/// UI Constants

let kPopoverMenuCellHeight: CGFloat = 35.0
let kOrderProductCellHeight: CGFloat = 38.0
let kNewCustomerContactCellHeight: CGFloat = 220.0
let kNewCustomerContactTypeHeight: CGFloat = 25.0

let kSurveyAnswerCellHeight: CGFloat = 50.0
let kSurveyVerticalMargin: CGFloat = 30.0
let kSurveyInnerTopMargin: CGFloat = 30.0
let kSurveyInnerBottomMargin: CGFloat = 30.0
let kSurveyInnerHorizontalMargin: CGFloat = 70.0
let kSurveyQuestionHeaderHeight: CGFloat = 53.0
let kSurveyAnswersPerRow: Int = 2

let kUploadHandleDelay: Double = 2.0

let kInvoiceEmptyDataHeight: Double = 600
let kInvoiceItemRowHeight: Double = 40

//let kPrintPixelFactor: CGFloat = 3/2.1875
let kPrintPixelFactor: CGFloat = 1.0

let kXMLDirName = "xmls"
let kAdminUsername = "admin"
let kAdminPassword = "9999"

let kReportsDirName = "Reports"
let kCompanyLogoFileName = "CmpyloginSF.bmp"

let kPrintTemplateInvoiceFmtFileName = "INVOICEFMT.xml"
let kPrintTemplateDeliveryFmtFileName = "DELIVERYFMT.xml"
let kPrintLoadSheetTemplateFileName = "LOADSHEETFMT.xml"
let kPrintTruckInventoryTemplateFileName = "TRUCKINVENTORYFMT.xml"
let kPrintLoadRequestTemplateFileName = "LOADREQUESTFMT.xml"
let kPrintLoadAdjustmentTemplateFileName = "LOADADJUSTMENTFMT.xml"
let kPrintStockTakeCountTemplateFileName = "STOCKTAKEFMT.xml"
let kPrintPickSlipTemplateFileName = "PICKSLIPFMT.xml"
let kPrintTermsTemplateFileName = "TERMSFMT.xml"
let kPrintSalesPlanTemplateFileName = "PRINTSALESFMT.xml"
let kPrintOrderAcknowledgeTemplateFileName = "ORDERACKFMT.xml"
let kPrintVehicleTemplateFileName = "VEHICLEFMT.xml"
let kPrintCashTemplateFileName = "CASHRECEIPTFMT.xml"
let kPrintCollectionConfirmTemplateFileName = "COLLECTIONFMT.xml"

let kPrintTextFontName = "Arial"

let kSignatureFileName = "signature.jpg"

let kReportsFileNameArray = [kCompanyLogoFileName, kPrintTemplateInvoiceFmtFileName, kPrintTemplateDeliveryFmtFileName, kPrintLoadSheetTemplateFileName, kPrintTruckInventoryTemplateFileName, kPrintLoadRequestTemplateFileName, kPrintLoadAdjustmentTemplateFileName, kPrintStockTakeCountTemplateFileName, kPrintPickSlipTemplateFileName, kPrintTermsTemplateFileName, kPrintSalesPlanTemplateFileName, kPrintOrderAcknowledgeTemplateFileName, kPrintVehicleTemplateFileName, kPrintCashTemplateFileName, kPrintCollectionConfirmTemplateFileName]

let kHamburgerDashboardName = L10n.dashboard()
let kHamburgerViewVehicleStockName = L10n.viewVehicleStock()
let kHamburgerAdjustVehicleStockName = L10n.addjustVehicleStock()
let kHamburgerCountVehicleStockName = L10n.countVehicleStock()
let kHamburgerDeliveriesTodayName = L10n.deliveriesToday()
let kHamburgerDeliveryTripStatusName = L10n.deliveryTripStatus()
let kHamburgerVisitPlannerName = L10n.visitPlanner()
let kHamburgerProductCatalog = L10n.productCatalog()
let kHamburgerHelpName = L10n.help()
let kHamburgerAboutName = L10n.about()

let kHamburgerSignoutName = L10n.signOut()

let kFulfilbyValueArray = ["W", "V", "D"]

let kDistributorDescTypeID = L10n.distributor()

/// Prefixes
let kAmericanExpressPrefixes = ["34", "37"]
let kDinersClubPrefixes = ["300", "301", "302", "303", "304", "305", "309", "36", "38", "39"]

let kMaxStrandardLength = 16
let kMaxAmericanExpressLength = 15
let kMaxDinersClubLength = 14

/// String constants
let kProductCatalogDirName = "ProductCatalog"
let kEquipmentCatalogDirName = "EquipmentCatalog"
let kPDFDirName = "pdf"
let kPDFLocalDirName = "pdf_local"

/// User Defaults Keys
let kPrefCustSeqNo = "CustSeqNo"
let kPrefToday = "PrefToday"
let kNewCustomersToday = "NewCustomersToday"
let kPdfSequenceNoPrefix = "PdfSequenceNo"
let kPrefUInvenTrxnNo = "PrefUInvenTrxnNo"

let kCompanyNameKey = "CampanyName"
let kChatPasswordKey = "ChatPassword"

let kLoginUserNameKey = "LoginUserName"
let kLoginPasswordKey = "LoginPassword"
let kLoginTerritoryKey = "LoginTerritory"
let kLoginUpdatedKey = "LoginUpdated"

let kDeliveryLoginUserNameKey = "DeliveryLoginUserName"
let kDeliveryLoginPasswordKey = "DeliveryLoginPassword"
let kDeliveryLoginTokenKey = "DeliveryLoginToken"
let kDeliveryLoginPinNumberKey = "DeliveryLoginPinNumber"

let kFTPPortKey = "FTPPort"
let kFTPChatCompanyKey = "FTPChatCompany"
let kFTPUsernameKey = "FTPUsername"
let kFTPPasswordKey = "FTPPassword"
let kFTPIPAddressKey = "FTPIPAddress"
let kFTPRootKey = "FTPRoot"

let kCollectionsBalancingPDFNameKey = "CollectionsBalancingPDFName"

let kSalesToday = "SalesToday"
let kReturnsToday = "ReturnsToday"

let kCustomerSummaryCod = "COD"
let kCustomerSummaryAccount = "ACCOUNT"
let kCustomerSummaryPayOnOrder = "PAYONORDER"

let kARPaidStatus: Int32 = 1

let kFromAppTag = 100

/// Product selection
let kSelectProductItemNo = 0
let kSelectProductItemUPC = 1

let kDeliveryPinNumber = "041903"

// Date format strings
/// yyyyMMddHHmmss
let kTightFullDateFormat = "yyyyMMddHHmmss"
/// yyyyMMdd
let kTightJustDateFormat = "yyyyMMdd"
/// HHmmss
let kTightJustTimeFormat = "HHmmss"

let kAttachmentTypePDF = "pdf"
let kAttachmentTypeJPG = "jpg"
let kAttachmentTypePNG = "png"

/// Print
let kSalePrint = 1
let kSaleDocketPrint = 8
let kLoadSheetPrint = 2
let kTruckInventoryPrint = 3
let kLoadRequestPrint = 4
let kLoadAdjustmentPrint = 5
let kLoadStockTakePrint = 6
let kPickSlipPrint = 7
let kTermsPrint = 10
let kSalesPlanPrint = 9
let kSaleAcknowledgePrint = 11
let kSaleVehiclePrint = 12
let kPaymentCollectionPrint = 13
let kCollectionConfirmPrint = 14

/// Promo Type Values
let kPromoTypeCentsOff = 1
let kPromoTypePercentageOff = 2
let kPromoTypeReplacePrice = 3
let kPromoTypeBuyFree = 4
let kPromoTypeBuyFreeMulti = 8

/// UTransaction Type for sales
let kTrxnPickup = 1
let kTrxnBuyBack = 2
let kTrxnDeliver = 4
let kTrxnContainerDump = 6
let kTrxnContainerSale = 7
let kTrxnFree = 12
let kTrxnSample = 11

/// SCW Type - Inventory
let kInventoryFresh = 0
let kInventoryReturns = 1
let kInventoryContainers = 2
let kInventoryTruck = 1

// Order collection type
let kCollectionCheque = 0
let kCollectionCash = 1
let kCollectionEODCheque = 2
let kCollectionEODCash = 3
let kCollectionCard = 7

let kWeightItem = 4 // ProductLocn.scwType == 4

let kNearbyAPIURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
let kNearbyAPIKey = "AIzaSyCP0KNFVCBMgo6Czgnloq2NRGSE6uif_DE"

let kPromotionBarColorArray = [kPromotionBar1Color, kPromotionBar2Color, kPromotionBar3Color, kPromotionBar4Color]
let kPromotionWeekCount = 8

let kMessageAttachmentChoosePhotoCount = 10

let kXMLNumberDivider = 100000
let kOrderHistoryDivider: Double = 100

let kGoogleSearchTypeArray = ["accounting", "airport", "amusement_park", "aquarium", "art_gallery", "atm", "bakery", "bank", "bar", "beauty_salon", "bicycle_store", "book_store", "bowling_alley", "bus_station", "cafe", "campground", "car_dealer", "car_rental", "car_repair", "car_wash", "casino", "cemetery", "church", "city_hall", "clothing_store", "convenience_store", "courthouse", "dentist", "department_store", "doctor", "electrician", "electronics_store", "embassy", "fire_station", "florist", "funeral_home", "furniture_store", "gas_station", "gym", "hair_care", "hardware_store", "hindu_temple", "home_goods_store", "hospital", "insurance_agency", "jewelry_store", "laundry", "lawyer", "library", "liquor_store", "local_government_office", "locksmith", "lodging", "meal_delivery", "meal_takeaway", "mosque", "movie_rental", "movie_theater", "moving_company", "museum", "night_club", "painter", "park", "parking", "pet_store", "pharmacy", "physiotherapist", "plumber", "police", "post_office", "real_estate_agency", "restaurant", "roofing_contractor", "rv_park", "school", "shoe_store", "shopping_mall", "spa", "stadium", "storage", "store", "subway_station", "supermarket", "synagogue", "taxi_stand", "train_station", "transit_station", "travel_agency", "veterinary_care", "zoo"]

/// Colors
let kNavBackColor = CommData.color(fromHexString: "#3B3245")
let kNavTextColor = CommData.color(fromHexString: "#d0d0d0")

let kColorPrimary = CommData.color(fromHexString: "#000000")
let kColorPrimaryDark = CommData.color(fromHexString: "#000000")

let kColorPrimaryBack = CommData.color(fromHexString: "#ECF0F1")
let kColorActivityIndicator = CommData.color(fromHexString: "#FFFFFF")

let kTextNormalBorderColor = UIColor(red: 83.0/255, green: 78.0/255, blue: 78.0/255, alpha: 1.0)
let kTextSelectedBorderColor = UIColor.white

let kGraphBackColor = CommData.color(fromHexString: "#CBCBCB")!

let kPopoverMenuBackgroundColor = CommData.color(fromHexString: "#ffffff")!

let kChartBackColor = UIColor.white
let kChartGridColor = UIColor(red: 241.0/255, green: 241.0/255, blue: 241.0/255, alpha: 1.0)
let kChartAxisColor = UIColor(red: 47.0/255, green: 41.0/255, blue: 41.0/255, alpha: 1.0)
let kChartAxisTextColor = UIColor(red: 47.0/255, green: 41.0/255, blue: 41.0/255, alpha: 1.0)
let kChartOptionNormalColor = UIColor(red: 155.0/255, green: 151.0/255, blue: 151.0/255, alpha: 1.0)
let kChartOptionSelectedColor = UIColor(red: 60.0/255, green: 182.0/255, blue: 76.0/255, alpha: 1.0)

let kRedTextColor = CommData.color(fromHexString: "#ff0000")!
let kBlueTextColor = CommData.color(fromHexString: "#006098")!
let kOrangeTextColor = CommData.color(fromHexString: "#F7941D")!
let kGreenTextColor = CommData.color(fromHexString: "#39B54A")!
let kBlackTextColor = UIColor(red: 47.0/255, green: 41.0/255, blue: 41.0/255, alpha: 1.0)

let kGreenButtonColor = CommData.color(fromHexString: "#39B54A")!
let kOrangeButtonColor = CommData.color(fromHexString: "#F7941D")!

let kCustomerCellSelectedColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)
let kCustomerCellNormalColor = UIColor(red: 250.0/255, green: 250.0/255, blue: 250.0/255, alpha: 1.0)
let kCustomerCellHighlightedColor = UIColor(red: 220.0/255, green: 220.0/255, blue: 220.0/255, alpha: 1.0)
let kCustomerCellSelectedTextColor = UIColor(red: 47.0/255, green: 41.0/255, blue: 41.0/255, alpha: 1.0)
let kCustomerCellNormalTextColor = UIColor(red: 139.0/255, green: 133.0/255, blue: 133.0/255, alpha: 1.0)

let kCustomerCellDisabledTextColor = UIColor(red: 193.0/255, green: 193.0/255, blue: 193.0/255, alpha: 1.0)
let kProductCellSelectedColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)
let kProductCellNormalColor = UIColor(red: 250.0/255, green: 250.0/255, blue: 250.0/255, alpha: 1.0)
let kStoreTypeEmptyTextColor = UIColor(red: 150.0/255, green: 145.0/255, blue: 145.0/255, alpha: 1.0)
let kStoreTypeNormalTextColor = UIColor(red: 47.0/255, green: 41.0/255, blue: 41.0/255, alpha: 1.0)

let kReasonOptionNormalColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)
let kReasonOptionSelectedColor = UIColor(red: 128.0/255, green: 121.0/255, blue: 121.0/255, alpha: 1.0)

let kOrderItemNormalColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)
let kOrderItemSelectedColor = UIColor(red: 57.0/255, green: 181.0/255, blue: 74.0/255, alpha: 1.0)
let kOrderItemNormalTextColor = UIColor(red: 139.0/255, green: 133.0/255, blue: 133.0/255, alpha: 1.0)
let kOrderItemSelectedTextColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)
let kOrderCategoryNormalColor = UIColor(red: 229.0/255, green: 229.0/255, blue: 229.0/255, alpha: 1.0)
let kOrderCategorySelectedColor = UIColor(red: 151.0/255, green: 148.0/255, blue: 148.0/255, alpha: 1.0)
let kOrderCategoryNormalTextColor = UIColor(red: 139.0/255, green: 133.0/255, blue: 133.0/255, alpha: 1.0)
let kOrderCategorySelectedTextColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)

let kOrderSalesOptionNormalColor = UIColor(red: 239.0/255, green: 239.0/255, blue: 239.0/255, alpha: 1.0)
let kOrderSalesOptionSelectedColor = UIColor(red: 127.0/255, green: 121.0/255, blue: 121.0/255, alpha: 1.0)

let kAssetCellNormalColor = UIColor(red: 250.0/255, green: 250.0/255, blue: 250.0/255, alpha: 1.0)
let kAssetCellSelectedColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)

let kMessageCellNormalColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)
let kMessageCellSelectedColor = UIColor(red: 250.0/255, green: 250.0/255, blue: 250.0/255, alpha: 1.0)

let kPromotionBar1Color = UIColor(red: 248.0/255, green: 237.0/255, blue: 231.0/255, alpha: 1.0)
let kPromotionBar2Color = UIColor(red: 237.0/255, green: 231.0/255, blue: 248.0/255, alpha: 1.0)
let kPromotionBar3Color = UIColor(red: 231.0/255, green: 248.0/255, blue: 234.0/255, alpha: 1.0)
let kPromotionBar4Color = UIColor(red: 231.0/255, green: 245.0/255, blue: 248.0/255, alpha: 1.0)
let kPromotionBarSelectedColor = UIColor(red: 95.0/255, green: 57.0/255, blue: 181.0/255, alpha: 1.0)

let kDashboardHighPercentColor = UIColor(red: 57.0/255, green: 181.0/255, blue: 74.0/255, alpha: 1.0)
let kDashboardLowPercentColor = UIColor(red: 255.0/255, green: 17.0/255, blue: 62.0/255, alpha: 1.0)

let kMenuBackgroundColor = CommData.color(fromHexString: "#3B3245")!
let kMenuCellHeight: CGFloat = 55.0
let kOrangeColor = CommData.color(fromHexString: "#FD9313")!
let kChatSendButtonNormalColor = CommData.color(fromHexString: "#212121")!
let kChatSendButtonHighlightColor = CommData.color(fromHexString: "#808080")!

let kTripStatusCellSelectedColor = CommData.color(fromHexString: "#80FD9313")!
let kTripStatusCellNormalColor = UIColor.white

let kCalendarCurrentDayBackColor = CommData.color(fromHexString: "#2c9445")!
let kCalendarOtherMonthDayTextColor = CommData.color(fromHexString: "#c0c0c0")!
let kCalendarTheMonthDayTextColor = CommData.color(fromHexString: "#303030")!
let kCalendarSelectedDayBackColor = CommData.color(fromHexString: "#39B54A")!
let kCalendarDotColor = CommData.color(fromHexString: "#00ff00")!

let kProductCatalogFilterNormalTextColor = UIColor(red: 140.0/255, green: 140.0/255, blue: 140.0/255, alpha: 1.0)

let kOrderProductSelectedNotificationName = "OrderProductSelectedNotification"
let kOrderProductAddNotificationName = "OrderProductAddNotification"
let kOrderProductUpdateNotificationName = "OrderProductUpdateNotification"

let kTestMode = false

/*  ServicesManager
 ...
 func downloadLatestUsers(successBlock:(([QBUUser]?) -> Void)?, errorBlock:((NSError) -> Void)?) {

 let enviroment = Constants.QB_USERS_ENVIROMENT

 self.usersService.searchUsersWithTags([enviroment])
 */

/// For QuickBlox

class Constants {

    class var QB_USERS_ENVIROMENT: String {

        #if DEBUG
        return "dev"
        #elseif QA
        return "qbqa"
        #else
        assert(false, "Not supported build configuration")
        return ""
        #endif

    }
}

// QB Setting
let kQBApplicationID:UInt = 58588
let kQBAuthKey = "3uUeN8jNvHV5Ovu"
let kQBAuthSecret = "GX-7RGxHPD4Z3wz"
let kQBAccountKey = "dGRuYM3KxyjaxkAELqJv"
let kAPIEndPoint = "https://api.quickblox.com"
let kChatEndPoint = "chat.quickblox.com"

let kQBMDialogIDKey = "dialog_id"

let kChatPresenceTimeInterval:TimeInterval = 45
let kDialogsPageLimit:UInt = 100
let kMessageContainerWidthPadding:CGFloat = 40.0

let kUpdateBadgeNotificationName = "UpdateBadgeNotification"
let kCustomerSelectedNotificationName = "CustomerSelectedNotification"
let kChatServiceChangedNotificationName = "ChatServiceNotification"

let kProductImageSampleURL = "https://firebasestorage.googleapis.com/v0/b/plant-check.appspot.com/o/01BDC817-4B56-41DD-A4D2-2D92BC8A63A7.jpg?alt=media&token=a48aec8c-c05e-4319-929c-c606297b635b"
