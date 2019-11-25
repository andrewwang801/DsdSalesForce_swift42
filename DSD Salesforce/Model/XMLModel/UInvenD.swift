//
//  UInvenD.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 8/22/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import Foundation

class UInvenD: NSObject {

    var trxnNo = 0
    var itemNo = ""
    var loaded = 0
    var loadAdj = 0
    var stock = 0
    var prevStock = 0
    var sales = 0
    var dumps = 0
    var buybacks = 0
    var transIn = 0
    var transOut = 0
    var spoils = 0
    var unload = 0
    var dumpsUnload = 0
    var endAdj = 0

    var shortDesc = ""
    var desc = ""
    var pickLocationCode = ""
    var uom = ""
    var fullCase = ""
    var weight = 0
    var isShow = false
    var order = 0
    var scwType = 0
    var prodLoconSCWType = 0
    var type = 0
    var isCompleted = false
    var completeStatus = 0

    var detailFile = ""
    var startTime = ""

    var beginQty = 0
    var sequence = 0

    var beginPresold = 0
    var beginPeddle = 0
    var resPresold = 0
    var resPeddle = 0
    var reasonCode = -1

    var adjQty = 0

    var dBeginPresold: Double = 0
    var dBeginPeddle: Double = 0
    var dResPresold: Double = 0
    var dResPeddle: Double = 0
    var dLoaded: Double = 0
    var dLoadAdj: Double = 0
    var dStock: Double = 0
    var dSales: Double = 0
    var dDumps: Double = 0
    var dBuybacks: Double = 0
    var dTransIn: Double = 0
    var dTransOut: Double = 0
    var dSpoils: Double = 0
    var dUnload: Double = 0
    var dDumpsUnload: Double = 0
    var dEndAdj: Double = 0
    var dBeginQty: Double = 0
    var dAdjQty: Double = 0

    func clone() -> UInvenD {
        let uInvenD = UInvenD()
        uInvenD.trxnNo = self.trxnNo
        uInvenD.itemNo = self.itemNo
        uInvenD.loaded = self.loaded
        uInvenD.loadAdj = self.loadAdj
        uInvenD.beginQty = self.beginQty
        uInvenD.stock = self.stock
        uInvenD.sales = self.sales
        uInvenD.dumps = self.dumps
        uInvenD.buybacks = self.buybacks
        uInvenD.transIn = self.transIn
        uInvenD.transOut = self.transOut
        uInvenD.spoils = self.spoils
        uInvenD.unload = self.unload
        uInvenD.dumpsUnload = self.dumpsUnload
        uInvenD.endAdj = self.endAdj
        uInvenD.shortDesc = self.shortDesc
        uInvenD.desc = self.desc
        uInvenD.pickLocationCode = self.pickLocationCode
        uInvenD.uom = self.uom
        uInvenD.fullCase = self.fullCase
        uInvenD.weight = self.weight
        uInvenD.isShow = self.isShow
        uInvenD.order = self.order
        uInvenD.scwType = self.scwType
        uInvenD.type = self.type
        uInvenD.detailFile = self.detailFile
        uInvenD.adjQty = self.adjQty

        uInvenD.beginPeddle = self.beginPeddle
        uInvenD.beginPresold = self.beginPresold
        uInvenD.resPeddle = self.resPeddle
        uInvenD.resPresold = self.resPresold

        uInvenD.dLoaded = self.dLoaded
        uInvenD.dStock = self.dStock
        uInvenD.dSales = self.dSales
        uInvenD.dDumps = self.dDumps
        uInvenD.dLoadAdj = self.dLoadAdj
        uInvenD.dBeginQty = self.dBeginQty
        uInvenD.dAdjQty = self.dAdjQty
        uInvenD.prodLoconSCWType = self.prodLoconSCWType

        uInvenD.dBeginPeddle = self.dBeginPeddle
        uInvenD.dBeginPresold = self.dBeginPresold
        uInvenD.dResPeddle = self.dResPeddle
        uInvenD.dResPresold = self.dResPresold

        uInvenD.dEndAdj = self.dEndAdj
        uInvenD.dDumpsUnload = self.dDumpsUnload
        uInvenD.dUnload = self.dUnload

        uInvenD.dBuybacks = self.dBuybacks
        uInvenD.dTransIn = self.dTransIn
        uInvenD.dTransOut = self.dTransOut
        uInvenD.dSpoils = self.dSpoils

        return uInvenD
    }

    /*
    static var keyArray = ["TrxnNo", "DocNo", "DocType", "VoidFlag", "PrintedFlag", "TrxnDate", "TrxnTime", "Reference", "TCOMStatus", "SaleDate", "ChainNo", "CustNo", "EquipmentNo", "SerialNo", "EquipmentType", "RequestDate", "Reason", "Features", "Response", "Make", "Application", "StatusCode", "AssetType", "RepairReason", "RepairNotes", "AltEquipment"]

    func getDictionary() -> [String: String] {
        var dic = [String: String]()
        dic["TrxnNo"] = trxnNo
        dic["DocNo"] = docNo
        dic["DocType"] = docType
        dic["VoidFlag"] = voidFlag
        dic["PrintedFlag"] = printedFlag
        dic["TrxnDate"] = trxnDate
        dic["TrxnTime"] = trxnTime
        dic["Reference"] = reference
        dic["TCOMStatus"] = tCOMStatus
        dic["SaleDate"] = saleDate
        dic["ChainNo"] = chainNo
        dic["CustNo"] = custNo
        dic["EquipmentNo"] = equipmentNo
        dic["SerialNo"] = serialNo
        dic["EquipmentType"] = equipmentType
        dic["RequestDate"] = requestDate
        dic["Reason"] = reason
        dic["Features"] = features
        dic["Response"] = response
        dic["Make"] = make
        dic["Application"] = application
        dic["StatusCode"] = statusCode
        dic["AssetType"] = assetType
        dic["RepairReason"] = repairReason
        dic["RepairNotes"] = repairNotes
        dic["AltEquipment"] = altEquipment
        return dic
    }

    func makeTransaction() -> UTransaction {
        let trxnNoString = self.trxnNo
        let trxnNo = Int64(trxnNoString) ?? 0
        let date = Date.fromTimeStamp(timeStamp: trxnNo)
        let globalInfo = GlobalInfo.shared
        let trip = globalInfo.routeControl?.trip ?? ""
        return UTransaction.make(chainNo: self.chainNo, custNo: self.custNo, docType: self.docType, date: date, reference: "", trip: trip)
    }

    static func saveToXML(assetArray: [UAsset], filePath: String) {

        var dicArray = [[String: String]]()
        for asset in assetArray {
            let dictionary = asset.getDictionary()
            dicArray.append(dictionary)
        }
        Utils.saveToXML(dicArray: dicArray, keyArray: keyArray, rootName: "Assets", branchName: "Asset", filePath: filePath)
    }

    static func saveToXML(assetArray: [UAsset]) -> String {
        if assetArray.count == 0 {
            return ""
        }
        let nowString = Date().toDateString(format: "yyyyMMddHHmmss") ?? ""
        let fileName = "Assets\(nowString).upl"
        let filePath = CommData.getFilePathAppended(byCacheDir: fileName) ?? ""
        saveToXML(assetArray: assetArray, filePath: filePath)
        return filePath
    }*/
}
