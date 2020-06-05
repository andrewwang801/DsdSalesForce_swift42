//
//  CustomerSurveyVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/12/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable
import SSZipArchive

class CustomerSurveyVC: UIViewController {

    @IBOutlet weak var backButton: AnimatableButton!
    @IBOutlet weak var surveyTableView: UITableView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var completedPercentLabel: UILabel!
    @IBOutlet weak var percentSliderContainerView: AnimatableView!
    @IBOutlet weak var percentSliderLabel: AnimatableLabel!
    @IBOutlet weak var percentTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var doneButton: UIButton!

    let globalInfo = GlobalInfo.shared
    var mainVC: MainVC!
    var customerDetail: CustomerDetail!
    var originalSurvey: Survey!
    var survey: Survey!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
        initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let surveyTitle = survey.surveyTitle ?? ""
        mainVC.setTitleBarText(title: surveyTitle.uppercased())
        headerTitleLabel.text = surveyTitle.uppercased()
        updateUI()
    }

    func initData() {
        //survey = originalSurvey
        survey = Survey(context: globalInfo.managedObjectContext, forSave: false)
        survey.cloneBy(context: globalInfo.managedObjectContext, theSource: originalSurvey)
    }

    func initUI() {
        surveyTableView.dataSource = self
        surveyTableView.delegate = self

    }

    func updateUI() {
        reloadSurveys()
        updatePercent()
    }

    func reloadSurveys() {
        surveyTableView.reloadData()
    }

    func setCompletedRatio(ratio: Double) {
        let completedRatio = min(max(ratio, 0), 1)
        let containerBounds = percentSliderContainerView.bounds
        let targetTopMargin = containerBounds.height*CGFloat(1-completedRatio)
        let percent = ratio*100
        completedPercentLabel.text = percent.integerString+"%"
        UIView.animate(withDuration: 1.0) {
            self.percentTopMarginConstraint.constant = targetTopMargin
        }
    }

    func updatePercent() {
        let completedRatio = survey.completedPercent/100
        setCompletedRatio(ratio: completedRatio)
        doneButton.isEnabled = survey.isCompleted
    }

    @IBAction func onBack(_ sender: Any) {
        goBackToCustomerActivity()
    }

    @IBAction func onDone(_ sender: Any) {

        originalSurvey.cloneBy(context: globalInfo.managedObjectContext, theSource: survey)
        customerDetail.isAssetsChecked = true
        GlobalInfo.saveCache()

        // generate XMLs and upload it
        let now = Date()
        let nowString = now.toDateString(format: kTightFullDateFormat) ?? ""
        let suveryTransaction = UTransaction.make(chainNo: customerDetail.chainNo ?? "", custNo: customerDetail.custNo ?? "", docType: "SURV", date: now, reference: "", trip: globalInfo.routeControl!.trip ?? "")

        let trxnNo = suveryTransaction.trxnNo
        let trxnTime = suveryTransaction.trxnTime
        let trxnDate = suveryTransaction.trxnDate

        // SurveyS XML
        let surveyS = SurveyS()
        surveyS.trxnNo = trxnNo
        surveyS.chainNo = customerDetail.chainNo ?? ""
        surveyS.custNo = customerDetail.custNo ?? ""
        surveyS.surveyID = originalSurvey.surveyID ?? ""
        surveyS.completed = originalSurvey.isCompleted == true ? "1" : "0"
        surveyS.aTrxnNo = "0"
        surveyS.aDocNo = "0"
        surveyS.docType = "SURV"
        surveyS.voidFlag = "0"
        surveyS.printedFlag = "0"
        surveyS.trxnDate = trxnDate
        surveyS.trxnTime = trxnTime
        surveyS.reference = ""
        surveyS.tCOMStatus = "0"
        surveyS.saleDate = trxnDate

        for _question in originalSurvey.questionSet {
            let question = _question as! SurveyQuestion
            let surveyDetail = SurveyDetail()
            surveyDetail.trxnNo = trxnNo
            surveyDetail.questionID = question.questionID ?? ""
            surveyDetail.resultVal = question.answer ?? ""
            surveyDetail.visible = "0"
            surveyDetail.seqNo = "0"
            surveyS.surveyDetailArray.append(surveyDetail)
        }

        let gpsLog = GPSLog.make(chainNo: customerDetail.chainNo ?? "", custNo: customerDetail.custNo ?? "", docType: "GPS", date: now, location: globalInfo.getCurrentLocation())
        let gpsLogTransaction = gpsLog.makeTransaction()

        // Survey XML file
        let surveySPath = CommData.getFilePathAppended(byDocumentDir: "Surveys\(nowString).upl") ?? ""
        SurveyS.saveToXML(surveyArray: [surveyS], filePath: surveySPath)

        // Log
        let gpsLogPath = GPSLog.saveToXML(gpsLogArray: [gpsLog])

        // transaction file
        let transactionPath = UTransaction.saveToXML(transactionArray: [suveryTransaction, gpsLogTransaction], shouldIncludeLog: true)

        globalInfo.uploadManager.zipAndScheduleUpload(filePathArray: [surveySPath, gpsLogPath, transactionPath], completionHandler: nil)

        goBackToCustomerActivity()
    }

    func goBackToCustomerActivity() {
        mainVC.popChild(containerView: mainVC.containerView)
    }
}

extension CustomerSurveyVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return survey.questionSet.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let question = survey.questionSet[index] as! SurveyQuestion
        let questionType = question.questionType ?? ""
        if questionType == "Y" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SurveyYesNoQuestionCell", for: indexPath) as! SurveyYesNoQuestionCell
            cell.setupCell(parentVC: self, indexPath: indexPath)
            return cell
        }
        else if questionType == "L" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SurveyOptionQuestionCell", for: indexPath) as! SurveyOptionQuestionCell
            cell.setupCell(parentVC: self, indexPath: indexPath)
            return cell
        }
        else if questionType == "D" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SurveyFreeInputQuestionCell", for: indexPath) as! SurveyFreeInputQuestionCell
            cell.setupCell(parentVC: self, indexPath: indexPath)
            return cell
        }
        else if questionType == "C" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SurveyCurrencyQuestionCell", for: indexPath) as! SurveyCurrencyQuestionCell
            cell.setupCell(parentVC: self, indexPath: indexPath)
            return cell
        }
        else if questionType == "P" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SurveyPercentQuestionCell", for: indexPath) as! SurveyPercentQuestionCell
            cell.setupCell(parentVC: self, indexPath: indexPath)
            return cell
        }
        else {
            let cell = UITableViewCell(frame: CGRect.zero)
            return cell
        }
    }

}

extension CustomerSurveyVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let index = indexPath.row
        let question = survey.questionSet[index] as! SurveyQuestion
        let questionType = question.questionType ?? ""

        var bottomMargin: CGFloat = kSurveyVerticalMargin
        if index == survey.questionSet.count-1 {
            bottomMargin = 0
        }

        if questionType == "L" {
            let answerCount = question.answerOptionSet.count
            let kCols = kSurveyAnswersPerRow
            let rowCount = ceil(CGFloat(answerCount)/CGFloat(kCols))
            return kSurveyQuestionHeaderHeight+kSurveyInnerTopMargin+kSurveyInnerBottomMargin+rowCount*kSurveyAnswerCellHeight+bottomMargin
        }
        else {
            return kSurveyQuestionHeaderHeight+kSurveyInnerTopMargin+kSurveyInnerBottomMargin+kSurveyAnswerCellHeight+bottomMargin
        }
    }

}
