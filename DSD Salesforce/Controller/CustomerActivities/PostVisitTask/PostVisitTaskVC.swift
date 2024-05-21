//
//  PostVisitTaskVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 9/18/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class PostVisitTaskVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nextVisitDateButton: UIButton!
    @IBOutlet weak var visitNoteTextView: UITextView!
    @IBOutlet weak var nextVisitDateLabel: UILabel!
    @IBOutlet weak var visitNotesLabel: UILabel!
    @IBOutlet weak var okButton: AnimatableButton!
    @IBOutlet var visitDayButton: AnimatableButton!
    @IBOutlet var visitFreq: UITextField!
    
    let globalInfo = GlobalInfo.shared
    var customerDetail: CustomerDetail!
    var nextVisitDate = Date()
    var now = Date()
    var visitNote = ""
    var deliveryFreq = 0
    var preferredVisitDay = 0
    var weekDayStart = Date()
    var isNextVisitDateChanged = false

    var datePicker = UIDatePicker()

    let kDateFormat = "EEEE dd/MM/yyyy"

    enum DismissOption {
        case cancelled
        case done
    }
    var dismissHandler: ((PostVisitTaskVC, DismissOption)->())?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
        initUI()
    }

    func initData() {
        // get the next visit date
        if let custInfo = CustInfo.getBy(context: globalInfo.managedObjectContext, infoType: "16", custNo: customerDetail.custNo!) {
            now = Date.fromDateString(dateString: custInfo.info!) ?? Date()
        }
        else {
            now = Date()
        }
        let deliveryFreqString = customerDetail.delivFreq ?? "0"
        deliveryFreq = Int(deliveryFreqString) ?? 0
        nextVisitDate = now.getDateAddedBy(days: deliveryFreq*7)
        
        for index in 0...6 {
            let date = weekDayStart.getDateAddedBy(days: index)
            formattedVisitDayArray.append(date.toDateString(format: "EEEE") ?? "")
            visitDayArray.append(date)
        }
    }

    func initUI() {
        nextVisitDateLabel.text = L10n.nextVisitDate()
        visitNotesLabel.text = L10n.visitNotes()
        okButton.setTitleForAllState(title: L10n.ok())
        
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        
        let visitDay = now.toDateString(format: "EEEE") ?? ""
        nextVisitDateButton.setTitleForAllState(title: nextVisitDate.toDateString(format: kDateFormat) ?? "")
        visitNoteTextView.text = ""
        visitDayButton.setTitleForAllState(title: visitDay)
        preferredVisitDay = getPreferredDayFromFormattedStr(weekday: visitDay)
        visitFreq.text = customerDetail.delivFreq ?? "0"
        visitFreq.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        setupVisitDayDropDown()
    }
    
    func updateUI() {
        
        nextVisitDateButton.setTitleForAllState(title: nextVisitDate.toDateString(format: kDateFormat) ?? "")
    }
    
    func getPreferredDayFromFormattedStr(weekday: String) -> Int {
        switch weekday {
        case "Monday":
            return 1
        case "Tuesday":
            return 2
        case "Wednesday":
            return 3
        case "Thursday":
            return 4
        case "Friday":
            return 5
        case "Saturday":
            return 6
        case "Sunday":
            return 7
        default:
            return 0
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        // get the next visit date
        let deliveryFreqString = visitFreq.text ?? "0"
        deliveryFreq = Int(deliveryFreqString) ?? 0
        nextVisitDate = now.getDateAddedBy(days: deliveryFreq*7)
        updateUI()
    }
    
    var visitDayDropDown = DropDown()
    var selectedVisitDay = ""
    var visitDayArray: [Date] = []
    var formattedVisitDayArray: [String] = []
    
    func setupVisitDayDropDown() {
        visitDayDropDown.cellHeight = visitDayButton.bounds.height
        visitDayDropDown.anchorView = visitDayButton
        visitDayDropDown.bottomOffset = CGPoint(x: 0, y: visitDayButton.bounds.height)
        visitDayDropDown.backgroundColor = UIColor.white
        visitDayDropDown.textFont = visitDayButton.titleLabel!.font

        visitDayDropDown.dataSource = formattedVisitDayArray
        visitDayDropDown.cellNib = UINib(nibName: "GeneralDropDownCell", bundle: nil)
        visitDayDropDown.customCellConfiguration = {_index, item, cell in
        }
        visitDayDropDown.selectionAction = { index, item in
            self.now = self.visitDayArray[index]
            self.nextVisitDate = self.now.getDateAddedBy(days: self.deliveryFreq*7)
            let visitDay = self.now.toDateString(format: "EEEE") ?? ""
            self.visitDayButton.setTitleForAllState(title: visitDay)
            self.preferredVisitDay = self.getPreferredDayFromFormattedStr(weekday: visitDay)
            self.updateUI()
        }
    }
    
    @IBAction func onNextVisitDate(_ sender: Any) {
        let selectedDateString = nextVisitDateButton.titleLabel?.text ?? ""
        let selectedDate = Date.fromDateString(dateString: selectedDateString, format: kDateFormat)
        let calendarVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "CalendarVC") as! CalendarVC
        calendarVC.setDefaultModalPresentationStyle()
        calendarVC.dismissHandler = {date, dismissOption in
            if dismissOption == .done {
                self.isNextVisitDateChanged = true
                self.nextVisitDateButton.setTitleForAllState(title: date!.toDateString(format: self.kDateFormat) ?? "")
            }
        }
        calendarVC.selectedDate = selectedDate
        self.present(calendarVC, animated: true, completion: nil)
    }

    @IBAction func onVisitDay(_ sender: Any) {
        visitDayDropDown.show()
    }
    
    @IBAction func onOkay(_ sender: Any) {

        let visitNotes = globalInfo.routeControl?.visitNotes ?? "0"
        if visitNotes == "2" {
            // mandatory
            if visitNoteTextView.text.trimed() == "" {
                SVProgressHUD.showInfo(withStatus: L10n.youShouldEnterVisitNotes())
                return
            }
        }

        let selectedDateString = nextVisitDateButton.titleLabel?.text ?? ""
        let date = Date.fromDateString(dateString: selectedDateString, format: kDateFormat) ?? Date()

        
        if isNextVisitDateChanged == true {
            // confirm
            let weekLaterDate = Date().getDateAddedBy(days: 8).getJustDay()
            if date.timeIntervalSince(weekLaterDate) > 0 {
                // excute Add visit function
                doVisitPlanCustomer(nextVisitDate: date)
                /*
                Utils.showAlert(vc: self, title: "", message: "WARNING – You have scheduled a non recurring visit more than 7 days in the future.  This is in addition to any scheduled visits that will remain in place.  This visit will not be automatically scheduled for you on the day you have requested", failed: false, customerName: "", leftString: "", middleString: "OK", rightString: "") { (returnCode) in
                        self.doneProcess(nextVisitDate: date, visitNote: self.visitNoteTextView.text)
                    }
                return*/
            }
            else {
                // excute Add visit function
                doVisitPlanCustomer(nextVisitDate: date)
            }
        }
        doneProcess(nextVisitDate: date, visitNote: visitNoteTextView.text)
    }

    func doVisitPlanCustomer(nextVisitDate: Date) {

        let dayNo = "\(Utils.getWeekday(date: nextVisitDate))"
        let routeScheduleCustomers = CustomerDetail.getScheduled(context: globalInfo.managedObjectContext, dayNo: dayNo)
        for customer in routeScheduleCustomers {
            if customer.isFromSameNextVisit == true {
                continue
            }
            let originalSeqNo = Int(customer.seqNo ?? "") ?? 0
            customer.seqNo = "\(originalSeqNo+1)"
        }

        let newCustomerDetail = CustomerDetail(context: globalInfo.managedObjectContext, forSave: true)
        newCustomerDetail.updateBy(theSource: customerDetail)

        newCustomerDetail.seqNo = "0"
        newCustomerDetail.isRouteScheduled = true
        newCustomerDetail.dayNo = dayNo
        newCustomerDetail.deliveryDate = nextVisitDate.toDateString(format: kTightJustDateFormat)
        newCustomerDetail.isVisitPlanned = true
        newCustomerDetail.visitFrequency = Int32(deliveryFreq)
        newCustomerDetail.preferredVisitDay = Int32(preferredVisitDay)

        GlobalInfo.saveCache()
    }

    func doneProcess(nextVisitDate: Date, visitNote: String) {
        self.visitNote = visitNote
        self.nextVisitDate = nextVisitDate
        self.dismiss(animated: true) {
            self.dismissHandler?(self, .done)
        }
    }

    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?(self, .cancelled)
        }
    }

}
