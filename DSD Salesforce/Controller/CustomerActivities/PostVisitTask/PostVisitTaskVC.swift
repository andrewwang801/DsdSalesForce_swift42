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

    let globalInfo = GlobalInfo.shared
    var customerDetail: CustomerDetail!
    var nextVisitDate = Date()
    var visitNote = ""
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
        let now = Date()
        let deliveryFreqString = customerDetail.delivFreq ?? "0"
        let deliveryFreq = Int(deliveryFreqString) ?? 0
        nextVisitDate = now.getDateAddedBy(days: deliveryFreq*7)
    }

    func initUI() {

        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        nextVisitDateButton.setTitleForAllState(title: nextVisitDate.toDateString(format: kDateFormat) ?? "")
        visitNoteTextView.text = ""
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

    @IBAction func onOkay(_ sender: Any) {

        let visitNotes = globalInfo.routeControl?.visitNotes ?? "0"
        if visitNotes == "2" {
            // mandatory
            if visitNoteTextView.text.trimed() == "" {
                SVProgressHUD.showInfo(withStatus: "You should enter Visit Notes.")
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
