//
//  SurveyS.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 8/2/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class SurveyDetail: NSObject {

    var trxnNo = ""
    var questionID = ""
    var resultVal = ""
    var visible = ""
    var seqNo = ""

    static var keyArray = ["TrxnNo", "QuestionID", "ResultVal", "Visible", "SeqNo"]

    func getDictionary() -> [String: String] {
        var dic = [String: String]()
        dic["TrxnNo"] = trxnNo
        dic["QuestionID"] = questionID
        dic["ResultVal"] = resultVal
        dic["Visible"] = visible
        dic["SeqNo"] = seqNo
        return dic
    }
}

class SurveyS: NSObject {

    var trxnNo = ""
    var chainNo = ""
    var custNo = ""
    var surveyID = ""
    var completed = ""
    var aTrxnNo = ""
    var aDocNo = ""
    var docType = ""
    var voidFlag = ""
    var printedFlag = ""
    var trxnDate = ""
    var trxnTime = ""
    var reference = ""
    var tCOMStatus = ""
    var saleDate = ""
    var surveyDetailArray = [SurveyDetail]()

    static var keyArray = ["TrxnNo", "ChainNo", "CustNo", "SurveyID", "Completed", "aTrxnNo", "aDocNo", "DocType", "VoidFlag", "PrintedFlag", "TrxnDate", "TrxnTime", "Reference", "TCOMStatus", "SaleDate"]

    func getDictionary() -> [String: String] {
        var dic = [String: String]()
        dic["TrxnNo"] = trxnNo
        dic["ChainNo"] = chainNo
        dic["CustNo"] = custNo
        dic["SurveyID"] = surveyID
        dic["Completed"] = completed
        dic["aTrxnNo"] = aTrxnNo
        dic["aDocNo"] = aDocNo
        dic["DocType"] = docType
        dic["VoidFlag"] = voidFlag
        dic["PrintedFlag"] = printedFlag
        dic["TrxnDate"] = trxnDate
        dic["TrxnTime"] = trxnTime
        dic["Reference"] = reference
        dic["TCOMStatus"] = tCOMStatus
        dic["SaleDate"] = saleDate
        return dic
    }

    static func saveToXML(surveyArray: [SurveyS], filePath: String) {

        let rootName = "Surveys"
        let branchName = "Survey"
        let rootElement = GDataXMLNode.element(withName: rootName)
        for survey in surveyArray {
            let branchElement = GDataXMLNode.element(withName: branchName)
            let dic = survey.getDictionary()
            for key in keyArray {
                let value = dic[key]
                let leafElement = GDataXMLNode.element(withName: key, stringValue: value)
                branchElement!.addChild(leafElement!)
            }
            let detailBranchName = "Detail"
            for surveyDetail in survey.surveyDetailArray {
                let detailBranchElement = GDataXMLNode.element(withName: detailBranchName)
                let detailDic = surveyDetail.getDictionary()
                for key in SurveyDetail.keyArray {
                    let value = detailDic[key]
                    let leafElement = GDataXMLNode.element(withName: key, stringValue: value)
                    detailBranchElement!.addChild(leafElement!)
                }
                branchElement!.addChild(detailBranchElement!)
            }
            rootElement!.addChild(branchElement!)
        }
        let document = GDataXMLDocument(rootElement: rootElement)
        guard let xmlData = document!.xmlData() else {return}

        CommData.deleteFileIfExist(filePath)
        let fileURL = URL(fileURLWithPath: filePath)
        try? xmlData.write(to: fileURL, options: [NSData.WritingOptions.atomic])
    }

}
