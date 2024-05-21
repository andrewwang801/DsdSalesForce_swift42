//
//  TripStatusVC.swift
//  DSDConnect
//
//  Created by iOS Developer on 3/15/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable
import MBCircularProgressBar

class TripStatusVC: UIViewController {

    @IBOutlet weak var tripComboButton: AnimatableButton!
    @IBOutlet weak var toDeliverProgress: MBCircularProgressBarView!
    @IBOutlet weak var deliverRefusedProgress: MBCircularProgressBarView!
    @IBOutlet weak var deliveredProgress: MBCircularProgressBarView!
    @IBOutlet weak var toDeliverValueLabel: UILabel!
    @IBOutlet weak var deliverRefusedValueLabel: UILabel!
    @IBOutlet weak var deliveredValueLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var loaded_cnt = 0
    var delivered_cnt = 0
    var not_delivered_cnt = 0
    var not_loaded_cnt = 0
    var tripStatusInfoList = [TripStatusInfo]()

    var selectedTripIndex = 0
    var isRefreshing = false
    var currentTripInfo: TripInfo? {
        didSet {
            if currentTripInfo == nil {
                tripComboButton.setTitleForAllState(title: "No Trip Selected")
            }
            else {
                let tripTitle = currentTripInfo!.getTripString()
                tripComboButton.setTitleForAllState(title: tripTitle)
            }
        }
    }

    var currentTripStatusInfo: TripStatusInfo?

    let globalInfo = GlobalInfo.shared
    var mainVC: MainVC!
    let kGraphBandWidth: CGFloat = 20.0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
        refreshTripList()
        refreshData()

        currentTripInfo = nil
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //updateGraphValues()
    }

    func initUI() {
        tableView.delaysContentTouches = false
        tableView.dataSource = self
        tableView.delegate = self
    }

    func refreshTripList() {

        let userDefaults = UserDefaults.standard
        let strPinNumber = userDefaults.string(forKey: kDeliveryLoginPinNumberKey) ?? ""
        //let strPinNumber = kDeliveryPinNumber
        let strToken = userDefaults.string(forKey: kDeliveryLoginTokenKey) ?? ""
        let headers = ["X-Auth-Token": strToken]
        var params = [String: String]()
        let now = Date()
        let day = Utils.getWeekday(date: now)
        params["day"] = "\(day)"
        //params["day"] = "1"

        let baseURL = Utils.getBaseURL(pinNumber: strPinNumber)
        APIManager.doNormalRequest(baseURL: baseURL, methodName: "api/trip", httpMethod: "GET", headers: headers, params: params, shouldShowHUD: true) { (response, message) in
            if response == nil {
                Utils.showAlert(vc: self, title: "", message: "Refresh token is failed.", failed: false, customerName: "", leftString: "", middleString: "OK", rightString: "", dismissHandler: nil)
            }
            else {
                let json = JSON(data: response as! Data)
                let tripArray = TripInfo.arrayFrom(json: json)
                if tripArray == nil {
                    Utils.refreshToken(completion: { (success, message) in
                        self.refreshTripList()
                    })
                }
                else {
                    self.refreshTripList(tripInfoList: tripArray!)
                }
            }
        }
    }

    func refreshTripList(tripInfoList: [TripInfo]) {

        globalInfo.tripInfoList.removeAll()
        globalInfo.tripInfoList.append(contentsOf: tripInfoList)
        if globalInfo.tripInfoList.count == 0 {
            currentTripInfo = nil
        }
        else {
            currentTripInfo = globalInfo.tripInfoList[0]
        }
        self.showTripInfo()
    }

    func showTripInfo() {

        if currentTripInfo == nil {
            return
        }

        let userDefaults = UserDefaults.standard
        var params = [String: String]()
        let now = Date()
        let day = Utils.getWeekday(date: now)
        params["day"] = "\(day)"
        //params["day"] = "1"
        params["tripNo"] = "\(currentTripInfo!.tripNumber)"

        let strPinNumber = userDefaults.string(forKey: kDeliveryLoginPinNumberKey) ?? ""
        //let strPinNumber = kDeliveryPinNumber
        let strToken = userDefaults.string(forKey: kDeliveryLoginTokenKey) ?? ""
        let headers = ["X-Auth-Token": strToken]

        isRefreshing = true

        let baseURL = Utils.getBaseURL(pinNumber: strPinNumber)
        APIManager.doNormalRequest(baseURL: baseURL, methodName: "api/trip-status", httpMethod: "GET", headers: headers, params: params, shouldShowHUD: true) { (response, message) in
            if response == nil {
                self.tripStatusInfoList.removeAll()
                self.loaded_cnt = 0
                self.not_delivered_cnt = 0
                self.delivered_cnt = 0
                self.refreshData()
                self.isRefreshing = false

                Utils.showAlert(vc: self, title: "", message: "Api Failed.", failed: false, customerName: "", leftString: "", middleString: "OK", rightString: "", dismissHandler: nil)
            }
            else {
                self.tripStatusInfoList.removeAll()
                self.loaded_cnt = 0
                self.not_delivered_cnt = 0
                self.delivered_cnt = 0
                self.not_loaded_cnt = 0

                let json = JSON(data: response as! Data)
                let statusInfoArray = TripStatusInfo.arrayFrom(json: json)
                if statusInfoArray != nil {
                    for info in statusInfoArray! {
                        if info.status == "1" {
                            self.tripStatusInfoList.append(info)
                            self.loaded_cnt += 1
                        }
                        else if info.status == "5" {
                            self.tripStatusInfoList.append(info)
                            self.delivered_cnt += 1
                        }
                        else if info.status == "4" {
                            self.tripStatusInfoList.append(info)
                            self.not_delivered_cnt += 1
                        }
                        else {
                            self.tripStatusInfoList.append(info)
                            self.not_loaded_cnt += 1
                        }
                    }
                    self.refreshData()
                    self.isRefreshing = false
                }
                else {
                    Utils.refreshToken(completion: { (success, message) in
                        self.showTripInfo()
                    })
                }
            }
        }
    }

    func refreshData() {

        var totalCount = not_delivered_cnt + delivered_cnt + loaded_cnt + not_loaded_cnt
        if totalCount == 0 {
            totalCount = 1
        }

        toDeliverValueLabel.text = "\(loaded_cnt)"
        UIView.animate(withDuration: 1.0) {
            self.toDeliverProgress.value = CGFloat(self.loaded_cnt)/CGFloat(totalCount)*100.0
        }

        deliverRefusedValueLabel.text = "\(not_delivered_cnt)"
        UIView.animate(withDuration: 1.0) {
            self.deliverRefusedProgress.value = CGFloat(self.not_delivered_cnt)/CGFloat(totalCount)*100.0
        }

        deliveredValueLabel.text = "\(delivered_cnt)"
        UIView.animate(withDuration: 1.0) {
            self.deliveredProgress.value = CGFloat(self.delivered_cnt)/CGFloat(totalCount)*100.0
        }

        tableView.reloadData()
    }

    func showTripStatusInfo() {

        if currentTripInfo == nil {
            Utils.showAlert(vc: self, title: "", message: "PDF not able to be retrieved", failed: false, customerName: "", leftString: "", middleString: "OK", rightString: "", dismissHandler: nil)
        }
        else {
            let dateString = Date.convertDateFormat(dateString: currentTripStatusInfo!.trxnDate, fromFormat: "yyyy-MM-dd", toFormat: kTightJustDateFormat)
            Utils.showPDF(vc: self, strDocNo: currentTripStatusInfo!.docNo, strDate: dateString)
        }
    }

    @IBAction func onTripCombo(_ sender: Any) {

        if globalInfo.tripInfoList.count == 0 {
            return
        }
        let valueArray = globalInfo.tripInfoList.map { (tripInfo) -> String in
            let tripString = tripInfo.getTripString()
            return tripString
        }
        let originIndex = selectedTripIndex
        let selectedTripInfo = globalInfo.tripInfoList[selectedTripIndex]
        //let originText = getTripString(tripInfo: selectedTripInfo)

        let comboVC = UIViewController.getViewController(storyboardName: "Delivery", storyboardID: "ComboPopoverVC") as! ComboPopoverVC
        comboVC.vaItemArray = valueArray
        comboVC.selectedTitle = "Select Trip"
        comboVC.viSelectedIndex = originIndex
        comboVC.dismissHandler = {vc, selectedIndex in
            if selectedIndex != -1 {
                self.currentTripInfo = self.globalInfo.tripInfoList[selectedIndex]
                if originIndex != selectedIndex {
                    self.selectedTripIndex = selectedIndex
                    self.showTripInfo()
                }
            }
        }
        comboVC.setDefaultModalPresentationStyle()
        self.present(comboVC, animated: true, completion: nil)
    }

    @IBAction func onReload(_ sender: Any) {
        if isRefreshing == false {
            showTripInfo()
        }
    }

    @IBAction func onClose(_ sender: Any) {
        mainVC.popChild(containerView: mainVC.containerView)
    }

}

extension TripStatusVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripStatusInfoList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripStatusCell") as! TripStatusCell
        let index = indexPath.row
        let statusInfo = tripStatusInfoList[index]
        cell.captionLabel.text = statusInfo.customerName
        if statusInfo.status == "1" {
            cell.statusLabel.text = "To Deliver"
        }
        else if statusInfo.status == "4" {
            cell.statusLabel.text = "Delivery Refused"
        }
        else if statusInfo.status == "5" {
            cell.statusLabel.text = "Delivered"
        }
        else {
            cell.statusLabel.text = "Not Loaded"
        }

        if statusInfo.status != "1" && statusInfo.status != "2" && statusInfo.status != "3" {
            cell.timeLabel.text = statusInfo.time
        }
        else {
            cell.timeLabel.text = ""
        }

        if statusInfo.status == "1" {
            cell.statusLabel.textColor = UIColor.black
        }
        else if statusInfo.status == "4" {
            cell.statusLabel.textColor = UIColor.red
        }
        else if statusInfo.status == "5" {
            cell.statusLabel.textColor = UIColor.black
        }
        else {
            cell.statusLabel.textColor = UIColor.black
        }
        return cell
    }
}

extension TripStatusVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let index = indexPath.row
        let statusInfo = self.tripStatusInfoList[index]
        if statusInfo.status == "1" || statusInfo.status == "2" || statusInfo.status == "3" {
            return
        }

        // open status info dialog
        let infoVC = UIViewController.getViewController(storyboardName: "Delivery", storyboardID: "TripStatusInfoDialogVC") as! TripStatusInfoDialogVC
        infoVC.tripStatusInfo = statusInfo
        infoVC.setDefaultModalPresentationStyle()
        infoVC.dismissHandler = { returnCode in
            if returnCode == .left {
                self.currentTripStatusInfo = infoVC.tripStatusInfo
                self.showTripStatusInfo()
            }
        }
        self.present(infoVC, animated: true, completion: nil)
    }
}
