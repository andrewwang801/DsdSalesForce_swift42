//
//  CalendarVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 10/8/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class CalendarVC: UIViewController {

    @IBOutlet weak var calendarView: JTHorizontalCalendarView!
    @IBOutlet weak var monthTitleLabel: UILabel!

    var calendarManager: JTCalendarManager!
    var selectedDate: Date?

    enum DismissOption {
        case cancelled
        case done
    }

    var dismissHandler: ((Date?, DismissOption)->())?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
    }

    func initUI() {
        // calendar
        if selectedDate == nil {
            selectedDate = Date()
        }

        calendarManager = JTCalendarManager()
        calendarManager.delegate = self
        calendarManager.contentView = calendarView
        calendarManager.setDate(selectedDate)
        calendarManager.reload()
    }

    func reloadCalendarHeaderView() {
        let calendarDate = calendarView.date
        let titleText = calendarDate?.toDateString(format: "MMMM yyyy") ?? ""
        monthTitleLabel.text = titleText
    }

    @IBAction func onPrevMonth(_ sender: Any) {
        calendarView.loadPreviousPageWithAnimation()
    }

    @IBAction func onNextMonth(_ sender: Any) {
        calendarView.loadNextPageWithAnimation()
    }

    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?(nil, .cancelled)
        }
    }

    @IBAction func onDone(_ sender: Any) {
        // check if the selected date is future date
        let tomorrow = Date().getDateAddedBy(days: 1).getJustDay()
        if self.selectedDate!.timeIntervalSince(tomorrow) < 0 {
            SVProgressHUD.showInfo(withStatus: "You can not select the day less than tomorrow.")
            return
        }

        self.dismiss(animated: true) {
            self.dismissHandler?(self.selectedDate!, .done)
        }
    }

}

// MARK: -JTCalendarManagerDelegate
extension CalendarVC: JTCalendarDelegate {

    func calendar(_ calendar: JTCalendarManager!, prepareDayView dayView: UIView!) {

        DispatchQueue.main.async {
            dayView.isHidden = false
            let _dayView = dayView as! JTCalendarDayView

            // Test if the dayView is from another month than the page
            // Use only in month mode for indicate the day of the previous or next month
            if _dayView.isFromAnotherMonth == true {
                _dayView.circleView.isHidden = true
                _dayView.dotView.backgroundColor = kCalendarDotColor
            }
            else if self.selectedDate != nil && calendar.dateHelper.date(self.selectedDate, isTheSameDayThan: _dayView.date) == true {
                _dayView.circleView.isHidden = false
                _dayView.circleView.backgroundColor = kCalendarSelectedDayBackColor
                _dayView.dotView.backgroundColor = kCalendarDotColor
            }
            else {
                _dayView.circleView.isHidden = true
                _dayView.dotView.backgroundColor = kCalendarDotColor
            }

            if _dayView.isFromAnotherMonth == true {
                _dayView.textLabel.textColor = kCalendarOtherMonthDayTextColor
            }
            else if self.calendarManager.dateHelper.date(_dayView.date, isTheSameDayThan: Date()) {
                _dayView.textLabel.textColor = kRedTextColor
            }
            else {
                _dayView.textLabel.textColor = kCalendarTheMonthDayTextColor
            }


            if _dayView.isFromAnotherMonth == false {
                self.reloadCalendarHeaderView()
            }

            _dayView.dotView.isHidden = true
        }
    }

    func calendar(_ calendar: JTCalendarManager!, didTouchDayView dayView: UIView!) {

        let _dayView = dayView as! JTCalendarDayView
        selectedDate = _dayView.date

        // animation for the circle view
        _dayView.circleView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.transition(with: _dayView, duration: 0.3, options: [], animations: {
            _dayView.circleView.transform = CGAffineTransform.identity
            self.calendarManager.reload()
        }, completion: nil)

        reloadCalendarHeaderView()

        // load the previous or next page if touch a day from another month
        if calendarManager.dateHelper.date(calendarView.date, isTheSameMonthThan: _dayView.date) == false {
            if calendarView.date.compare(_dayView.date) == .orderedAscending {
                calendarView.loadNextPageWithAnimation()
            }
            else {
                calendarView.loadPreviousPageWithAnimation()
            }
        }
    }

}
