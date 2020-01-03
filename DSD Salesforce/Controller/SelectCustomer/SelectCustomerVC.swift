//
//  SelectCustomerVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/5/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import GoogleMaps
import IBAnimatable

class SelectCustomerVC: UIViewController {

    @IBOutlet weak var customerTableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var pricingButton: UIButton!
    @IBOutlet weak var topProductsButton: UIButton!
    @IBOutlet weak var opportunitiesButton: UIButton!
    @IBOutlet weak var nearbyButton: UIButton!
    @IBOutlet weak var noCustomerSelectedLabel: UILabel!
    @IBOutlet weak var showAllButton: UIButton!
    @IBOutlet weak var showAllCheckImageView: UIImageView!
    @IBOutlet weak var optimizationButton: AnimatableButton!
    @IBOutlet weak var addCustomerButton: AnimatableButton!
    @IBOutlet weak var customerMapView: GMSMapView!
    @IBOutlet weak var noteButton: UIButton!

    @IBOutlet weak var containerView: UIView!

    enum TopOption: Int {
        case details = 0
        case pricing = 1
        case topProductions = 2
        case opportunities = 3
        case nearby = 4
    }

    var mainVC: MainVC!
    let globalInfo = GlobalInfo.shared

    var topOptionButtonArray = [UIButton]()
    var selectedTopOption: TopOption = .details

    var customerDetailArray = [CustomerDetail]()
    var presoldOrHeaderArray = [PresoldOrHeader?]()
    var selectedCustomer: CustomerDetail?
    var selectedPresoldOrHeader: PresoldOrHeader?

    var mapCustomerArray = [CustomerDetail]()
    var mapPresoldOrHeaderArray = [PresoldOrHeader?]()

    var isShowAll = false {
        didSet {
            showAllCheckImageView.isHidden = !isShowAll
        }
    }

    var routificResult: RoutificJob?
    var routificError: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        initMap()
        initUI()
        reloadCustomers()
        selectedCustomer = customerDetailArray.first
        selectedPresoldOrHeader = presoldOrHeaderArray.first as? PresoldOrHeader
        onSelectedCustomer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        mainVC.setTitleBarText(title: "SELECT CUSTOMER")
        
        reloadCustomers()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailsVC = segue.destination as? SelectCustomerDetailsVC {
            detailsVC.selectCustomerVC = self
        }
    }

    func initUI() {

        // top option buttons
        detailsButton.setTitleForAllState(title: "SA_STR_DETAILS".localized)
        topOptionButtonArray = [detailsButton, pricingButton, topProductsButton, opportunitiesButton, nearbyButton]
        for (index, button) in topOptionButtonArray.enumerated() {
            button.tag = 300+index
            button.addTarget(self, action: #selector(SelectCustomerVC.onTapTopOptionButton(_:)), for: .touchUpInside)
        }

        customerTableView.delegate = self
        customerTableView.dataSource = self
        customerTableView.reorder.delegate = self
        customerTableView.reorder.cellScale = 0.9
        customerTableView.delaysContentTouches = false

        //show or hide addCustomerButton
        if self.globalInfo.routeControl?.custaddNew == nil || self.globalInfo.routeControl?.custaddNew == "0" {
            addCustomerButton.isHidden = true
        }
        else {
            addCustomerButton.isHidden = false
        }
    }
    
    func initMap() {
        customerMapView.delegate = self
        customerMapView.isMyLocationEnabled = true
        customerMapView.settings.zoomGestures = true
        customerMapView.settings.rotateGestures = true
        customerMapView.settings.compassButton = false
    }

    func reloadMap() {
        customerMapView.clear()
        var markers = [GMSMarker]()
        //for customer in customer

        /*
        mapCustomerArray = CustomerDetail.getScheduled(context: globalInfo.managedObjectContext, shouldExcludeCompleted: false)*/
        mapCustomerArray = customerDetailArray

        mapPresoldOrHeaderArray.removeAll()
        for customerDetail in mapCustomerArray {
            let chainNo = customerDetail.chainNo ?? ""
            let custNo = customerDetail.custNo ?? ""
            let presoldOrHeader = PresoldOrHeader.getFirstBy(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo)
            // filter customers by search text
            mapPresoldOrHeaderArray.append(presoldOrHeader)
        }

        for (index, customer) in mapCustomerArray.enumerated() {
            let presoldOrHeader = mapPresoldOrHeaderArray[index]

            let latitude = Double(customer.latitude ?? "") ?? 0
            let longitude = Double(customer.longitude ?? "") ?? 0

            if latitude == 0 && longitude == 0 {
                continue
            }

            let newMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))

            var markerImageName = ""
            // should set colors of markers
            let creditHold = Double(customer.creditHold ?? "") ?? 0
            if customer.isCompleted == true {
                markerImageName = "Customer_Marker_Green"
            }
            else {
                if creditHold > 0 {
                    markerImageName = "Customer_Marker_Red"
                }
                else {
                    let type = (presoldOrHeader?.type ?? "").uppercased()
                    if type == "P" {
                        markerImageName = "Customer_Marker_Blue"
                    }
                    else if type == "N" || type == "W" {
                        markerImageName = "Customer_Marker_Orange"
                    }
                    else {
                        markerImageName = "Customer_Marker_Black"
                    }
                }

                let orderType = customer.orderType ?? ""
                if orderType == "P" {
                    markerImageName = "Customer_Marker_Orange"
                }
            }

            newMarker.icon = UIImage(named: markerImageName)

            newMarker.groundAnchor = CGPoint(x: 0.5, y: 1)
            newMarker.snippet = customer.name ?? ""
            newMarker.userData = customer
            newMarker.map = customerMapView
            markers.append(newMarker)
        }

        // add me
        if let myLocation = customerMapView.myLocation {
            let myMarker = GMSMarker(position: myLocation.coordinate)
            myMarker.icon =  UIImage(named: "Nearby_Sales_Position_Marker")
            myMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            myMarker.userData = nil
            myMarker.map = customerMapView
            markers.append(myMarker)
        }

        let path = GMSMutablePath()
        for marker in markers {
            path.add(marker.position)
        }
        let bounds = GMSCoordinateBounds(path: path)

        let cameraUpdate = GMSCameraUpdate.fit(bounds, withPadding: 64)
        customerMapView.animate(with: cameraUpdate)
    }

    func reloadCustomers() {
        customerDetailArray.removeAll()
        presoldOrHeaderArray.removeAll()

        let dayNo = Utils.getWeekday(date: Date())
        customerDetailArray = CustomerDetail.getScheduled(context: globalInfo.managedObjectContext, dayNo: "\(dayNo)", shouldExcludeCompleted: self.isShowAll == false)

        customerDetailArray = customerDetailArray.filter({ (customerDetail) -> Bool in
            if customerDetail.isVisitPlanned == true {
                let nowDateString = Date().toDateString(format: kTightJustDateFormat) ?? ""
                if customerDetail.deliveryDate == nowDateString {
                    return true
                }
                else {
                    return false
                }
            }
            return true
        })

        customerDetailArray = CustomerDetail.sortBySeqNo(customerDetailArray: customerDetailArray)

        for customerDetail in customerDetailArray {
            let chainNo = customerDetail.chainNo ?? ""
            let custNo = customerDetail.custNo ?? ""
            let presoldOrHeader = PresoldOrHeader.getFirstBy(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo)
            // filter customers by search text
            presoldOrHeaderArray.append(presoldOrHeader)
        }

        // check if the selected customer is in the array
        if selectedCustomer != nil {
            if customerDetailArray.index(of: selectedCustomer!) == nil {
                selectedCustomer = nil
            }
        }

        if selectedCustomer == nil {
            selectedCustomer = customerDetailArray.first
            selectedPresoldOrHeader = presoldOrHeaderArray.first as? PresoldOrHeader
        }
        refreshCustomerTable()
        reloadMap()
    }

    func refreshCustomerTable() {
        customerTableView.reloadData()

        if customerDetailArray.count == 0 {
            noDataLabel.isHidden = false
            optimizationButton.isHidden = true
        }
        else {
            noDataLabel.isHidden = true
            if self.globalInfo.routeControl?.routificAPI == nil || self.globalInfo.routeControl?.routificAPI == "" {
                optimizationButton.isHidden = true
            }
            else {
                optimizationButton.isHidden = false
            }
        }
    }

    func doRoutific() {

        let currentLocation = self.globalInfo.getCurrentLocation()
        if currentLocation.latitude == 0 && currentLocation.longitude == 0 {
            SVProgressHUD.showInfo(withStatus: "Can not capture device location")
            return
        }
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow, animated: true)
        DispatchQueue.global().async {
            var headers = [String: String]()
            headers["Authorization"] = "bearer " + (self.globalInfo.routeControl?.routificAPI ?? "")

            var request = [String: Any]()
            var fleet = [String: Any]()
            var vehicle = [String: Any]()
            var start_location = [String: Any]()
            start_location["id"] = self.globalInfo.routeControl?.trip ?? ""
            start_location["lat"] = currentLocation.latitude
            start_location["lng"] = currentLocation.longitude
            //start_location["lat"] = -27.460426
            //start_location["lng"] = 153.021106

            vehicle["start_location"] = start_location

            let now = Date()
            var dt = now.getDateAddedBy(minutes: 2)
            //dt = dt.getDateAddedBy(hours: 4)

            vehicle["shift_start"] = dt.toDateString(format: "kk:mm") ?? ""

            let routeNumber = self.globalInfo.routeControl?.routeNumber ?? ""
            let routeNumberValue = Int(routeNumber) ?? 0
            let descType = DescType.getBy(context: self.globalInfo.managedObjectContext, descTypeID: "RouteNumber", numericKey: "\(routeNumberValue)")
            var latitude: Double = 0
            var longitude: Double = 0
            if descType != nil {
                latitude = Double(descType?.value3 ?? "") ?? 0
                longitude = Double(descType?.value4 ?? "") ?? 0
            }
            else {
                latitude = self.globalInfo.routeControl?.loconNoGPSLatitude ?? 0
                longitude = self.globalInfo.routeControl?.loconNoGPSLongitude ?? 0
            }
            if latitude != 0 && longitude != 0 {
                var end_location = [String: Any]()
                end_location["id"] = "depot"
                end_location["lat"] = latitude
                end_location["lng"] = longitude
                vehicle["end_location"] = end_location
            }

            fleet["vehicle_1"] = vehicle
            request["fleet"] = fleet

            var options = [String: Any]()
            options["traffic"] = "predicted"
            request["options"] = options

            dt = Date()
            let today = dt.toDateString(format: "yyyy-MM-dd") ?? ""
            request["date"] = today

            var visits = [String: Any]()
            var orderNo = 0
            for customer in self.customerDetailArray {
                let latitude = Double(customer.latitude ?? "") ?? 0
                let longitude = Double(customer.longitude ?? "") ?? 0
                if latitude == 0 && longitude == 0 {
                    continue
                }
                orderNo += 1
                var order = [String: Any]()
                var location = [String: Any]()

                let chainNo = customer.chainNo ?? "0"
                let custNo = customer.custNo ?? "0"
                location["name"] = chainNo + "/" + custNo

                let driverLatitude = Double(customer.driverLatitude ?? "") ?? 0
                let driverLongitude = Double(customer.driverLongitude ?? "") ?? 0
                let _latitude = Double(customer.latitude ?? "") ?? 0
                let _longitude = Double(customer.longitude ?? "") ?? 0

                if driverLatitude == 0 || driverLongitude == 0 {
                    location["lat"] = _latitude
                    location["lng"] = _longitude
                }
                else {
                    location["lat"] = driverLatitude
                    location["lng"] = driverLongitude
                }
                order["location"] = location

                var time_windows = [[String: Any]]()
                let startTime1 = customer.startTime1 ?? ""
                let endTime1 = customer.endTime1 ?? ""
                if startTime1 != "0000" && endTime1 != "0000" {
                    var time = [String: Any]()
                    if startTime1.contains(":") == false {
                        time["start"] = startTime1.subString(startIndex: 0, length: 2) + ":" + startTime1.subString(startIndex: 2, length: 2)
                    }
                    else {
                        time["start"] = startTime1
                    }
                    if endTime1.contains(":") == false {
                        time["end"] = endTime1.subString(startIndex: 0, length: 2) + ":" + endTime1.subString(startIndex: 2, length: 2)
                    }
                    else {
                        time["end"] = startTime1
                    }
                    time_windows.append(time)
                }
                let startTime2 = customer.startTime2 ?? ""
                let endTime2 = customer.endTime2 ?? ""
                if startTime2 != "0000" && endTime2 != "0000" {
                    var time = [String: Any]()
                    time["start"] = startTime2.subString(startIndex: 0, length: 2) + ":" + startTime2.subString(startIndex: 2, length: 2)
                    time["end"] = endTime2.subString(startIndex: 0, length: 2) + ":" + endTime2.subString(startIndex: 2, length: 2)
                    time_windows.append(time)
                }
                if time_windows.count != 0 {
                    order["time_windows"] = time_windows
                }
                order["duration"] = Int(self.globalInfo.routeControl?.visitDuration ?? "") ?? 0
                visits["order_\(orderNo)"] = order
            }
            request["visits"] = visits

            // res = null
            headers["token"] = "bearer " + (self.globalInfo.routeControl?.routificAPI ?? "")

            self.routificResult = nil
            self.routificError = ""
            var isAPIFinished = false

            APIManager.doNormalJSONRequest(baseURL: "https://api.routific.com/", methodName: "v1/vrp-long", httpMethod: "POST", headers: headers, params: request, shouldShowHUD: false, completion: { (response, message) in
                if response != nil {
                    let responseJSON = JSON(data: response as! Data)
                    let result = RoutificJob(json: responseJSON)
                    self.routificResult = result
                }
                self.routificError = message
                isAPIFinished = true
            })

            while (isAPIFinished == false) {
                Thread.sleep(forTimeInterval: 0.5)
            }

            if self.routificResult == nil {
                DispatchQueue.main.async {
                    hud?.hide(true)
                    SVProgressHUD.showInfo(withStatus: "Failed to call Routific api")
                }
                return
            }

            if self.routificResult!.error != "" {
                DispatchQueue.main.async {
                    hud?.hide(true)
                    let error = self.routificResult!.error
                    SVProgressHUD.showInfo(withStatus: error)
                }
                return
            }

            var isResult = false
            var etaTime = ""
            var etaDate = ""

            while isResult == false {

                isAPIFinished = false

                let job_id = self.routificResult!.job_id
                APIManager.doNormalRequest(baseURL: "https://api.routific.com/", methodName: "jobs/\(job_id)", httpMethod: "GET", params: [:], shouldShowHUD: false, completion: { (response, message) in
                    if response != nil {
                        let responseJSON = JSON(data: response as! Data)
                        let routificResponse = RoutificResponse(json: responseJSON)
                        if routificResponse.status != "finished" {
                            isResult = false
                        }
                        else {
                            isResult = true
                            let createdAt = routificResponse.createdAt
                            let date = Date.fromDateString(dateString: createdAt, format: "yyyy-MM-dd'T'kk:mm:ss.SSS'Z'") ?? Date()
                            etaDate = date.toDateString(format: "yyyyMMdd") ?? ""
                            etaTime = date.toDateString(format: "kkmmss") ?? ""

                            DispatchQueue.main.async {
                                hud?.hide(true)

                                if routificResponse.output == nil {
                                    SVProgressHUD.showInfo(withStatus: "Failed to call Routific api")
                                }
                                else {
                                    if routificResponse.output!.status == "success" {
                                        if routificResponse.output!.solution != nil {
                                            if routificResponse.output!.solution!.vehicle_1.count > 0 {
                                                self.optimizeSequence(locationList: routificResponse.output!.solution!.vehicle_1)
                                            }
                                            else {
                                                SVProgressHUD.showInfo(withStatus: "Failed to call Routific api")
                                            }
                                        }
                                        else {
                                            SVProgressHUD.showInfo(withStatus: "Failed to call Routific api")
                                        }
                                    }
                                    else {
                                        SVProgressHUD.showInfo(withStatus: "Failed to call Routific api")
                                    }
                                }
                            }
                        }
                    }
                    else {
                        isResult = true
                        DispatchQueue.main.async {
                            hud?.hide(true)
                            SVProgressHUD.showInfo(withStatus: "Failed to call Routific api")
                        }
                    }
                    isAPIFinished = true
                })

                while isAPIFinished == false {
                    Thread.sleep(forTimeInterval: 0.5)
                }
            }
        }
    }

    func optimizeSequence(locationList: [RoutificLocation]) {

        var routificLocationDictionary = [String: RoutificLocation]()
        for location in locationList {
            routificLocationDictionary[location.location_name] = location
        }
        for customer in customerDetailArray {
            let chainNo = customer.chainNo ?? ""
            let custNo = customer.custNo ?? ""
            let key = chainNo+"/"+custNo
            let location = routificLocationDictionary[key]
            if location != nil {
                customer.arrivalTime = location!.arrival_time
            }
        }

        customerDetailArray = customerDetailArray.sorted(by: { (customer1, customer2) -> Bool in
            let arrivalTime1 = customer1.arrivalTime ?? ""
            let arrivalTime2 = customer2.arrivalTime ?? ""
            return arrivalTime1 < arrivalTime2
        })

        for (index, customer) in customerDetailArray.enumerated() {
            customer.seqNo = "\(index)"
        }

        self.reloadCustomers()
        self.onSelectedCustomer()

        GlobalInfo.saveCache()
    }

    func onSelectedCustomer() {

        refreshCustomerTable()

        if selectedCustomer == nil {
            self.containerView.isHidden = true
            noCustomerSelectedLabel.isHidden = false
        }
        else {
            self.containerView.isHidden = false
            noCustomerSelectedLabel.isHidden = true
        }

        if selectedCustomer != globalInfo.selectedOpportunityCustomer {
            globalInfo.resetOpportunities()
        }

        // check customer notes
        if selectedCustomer == nil {
            noteButton.setImageForAllState(image: UIImage(named: "Select_Customer_Note_Gray"))
        }
        else {
            let custNo = selectedCustomer!.custNo ?? "0"
            let chainNo = selectedCustomer!.chainNo ?? "0"
            let custNotes = CustNote.getBy(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo)
            if custNotes.count > 0 {
                noteButton.setImageForAllState(image: UIImage(named: "Select_Customer_Note_Orange"))
            }
            else {
                noteButton.setImageForAllState(image: UIImage(named: "Select_Customer_Note_Gray"))
            }
        }

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kCustomerSelectedNotificationName), object: nil)
    }

    @objc func onTapTopOptionButton(_ sender: Any) {
        let button = sender as! UIButton
        let index = button.tag-300
        for (_index, button) in topOptionButtonArray.enumerated() {
            if _index == index {
                button.isSelected = true
            }
            else {
                button.isSelected = false
            }
        }
        selectedTopOption = TopOption(rawValue: index)!
        onSelectedTopOption(index: index)
    }

    func onSelectedTopOption(index: Int) {
        // show/hide sub view controllers
        let option = TopOption(rawValue: index)!
        if option == .details {
            let detailsVC = UIViewController.getViewController(storyboardName: "SelectCustomer", storyboardID: "SelectCustomerDetailsVC") as! SelectCustomerDetailsVC
            detailsVC.selectCustomerVC = self
            changeChild(newVC: detailsVC, containerView: containerView, isRemovePrevious: true)
        }
        else if option == .topProductions {
            let topProductsVC = UIViewController.getViewController(storyboardName: "SelectCustomer", storyboardID: "SelectCustomerTopProductsVC") as! SelectCustomerTopProductsVC
            topProductsVC.selectCustomerVC = self
            changeChild(newVC: topProductsVC, containerView: containerView, isRemovePrevious: true)
        }
        else if option == .opportunities {
            let opportunitiesVC = UIViewController.getViewController(storyboardName: "SelectCustomer", storyboardID: "SelectCustomerOpportunitiesVC") as! SelectCustomerOpportunitiesVC
            opportunitiesVC.selectCustomerVC = self
            changeChild(newVC: opportunitiesVC, containerView: containerView, isRemovePrevious: true)
        }
        else if option == .pricing {
            let pricingVC = UIViewController.getViewController(storyboardName: "SelectCustomer", storyboardID: "SelectCustomerPricingVC") as! SelectCustomerPricingVC
            pricingVC.selectCustomerVC = self
            changeChild(newVC: pricingVC, containerView: containerView, isRemovePrevious: true)
        }
        else if option == .nearby {
            let nearbyVC = UIViewController.getViewController(storyboardName: "SelectCustomer", storyboardID: "SelectCustomerNearbyVC") as! SelectCustomerNearbyVC
            nearbyVC.selectCustomerVC = self
            changeChild(newVC: nearbyVC, containerView: containerView, isRemovePrevious: true)
        }
    }

    func onSelectedNoVisitReasonCode(reasonCode: DescType) {

        guard let customerDetails = selectedCustomer else {return}
        let result = reasonCode.numericKey ?? ""

        let chainNo = customerDetails.chainNo ?? ""
        let custNo = customerDetails.custNo ?? ""
        let now = Date()

        // make cust note for this
        let noteType = "99"
        let messageNote = customerDetails.visitNote ?? ""
        let attachment = "0"

        if messageNote != "" {
            let newCustNote = CustNote(context: globalInfo.managedObjectContext, forSave: true)
            newCustNote.chainNo = chainNo
            newCustNote.custNo = custNo
            newCustNote.noteType = noteType
            newCustNote.noteDate = now.toDateString(format: kTightJustDateFormat) ?? ""
            newCustNote.noteTime = now.toDateString(format: "HHmm") ?? ""
            newCustNote.createdby = globalInfo.routeControl?.userName ?? ""
            newCustNote.note = messageNote
            newCustNote.noteId = "\(now.getTimestamp())"
            newCustNote.attachment = attachment
            newCustNote.fileNames = ""
            newCustNote.fileTypes = ""
            GlobalInfo.saveCache()
        }

        var transactionArray = [UTransaction]()

        let visit = Visit.make(chainNo: chainNo, custNo: custNo, docType: "VIS", date: now, customerDetail: customerDetails, reference: result)
        transactionArray.append(visit.makeTransaction())

        let uService = UploadService.make(chainNo: chainNo, custNo: custNo, docType: "SERV", date: now, reason: result, done: "0")
        transactionArray.append(uService.makeTransaction())

        let gpsLog = GPSLog.make(chainNo: chainNo, custNo: custNo, docType: "GPS", date: now, location: globalInfo.getCurrentLocation())
        transactionArray.append(gpsLog.makeTransaction())

        var filePathArray = [String]()

        let visitPath = Visit.saveToXML(visitArray: [visit])
        filePathArray.append(visitPath)

        if messageNote != "" {
            let uCustNote = UCustNote.make(chainNo: chainNo, custNo: custNo, docType: "NOTE", date: now, noteType: noteType, note: messageNote, attachmentString: attachment)
            transactionArray.append(uCustNote.makeTransaction())

            let uCustNotePath = UCustNote.saveToXML(uCustNoteArray: [uCustNote])
            filePathArray.append(uCustNotePath)
        }

        // Order Status Info
        let orderStatus = OrderStatusS.make(customerDetails: customerDetails, date: Date(), docType: "OSTA", reference: reasonCode.desc ?? "", status: "4")

        // uservice file
        let uServicePath = UploadService.saveToXML(uServiceArray: [uService])
        filePathArray.append(uServicePath)

        // order status file
        let orderStatusPath = OrderStatusS.saveToXML(orderStatusArray: [orderStatus])
        filePathArray.append(orderStatusPath)

        // transaction file
        let transactionPath = UTransaction.saveToXML(transactionArray: transactionArray, shouldIncludeLog: true)
        filePathArray.append(transactionPath)

        let gpsLogPath = GPSLog.saveToXML(gpsLogArray: [gpsLog])
        filePathArray.append(gpsLogPath)

        globalInfo.uploadManager.zipAndScheduleUpload(filePathArray: filePathArray)

        customerDetails.isCompleted = true
        self.selectedCustomer = nil

        GlobalInfo.saveCache()
        self.reloadCustomers()
        self.onSelectedCustomer()
    }

    func onSelectedCustomerVisitReasonCode(reasonCode: DescType) {
        guard let customerDetails = selectedCustomer else {return}
        customerDetails.visitReason = reasonCode.alphaKey ?? ""
        GlobalInfo.saveCache()
    }

    @IBAction func onRoutific(_ sender: Any) {
        doRoutific()
    }

    @IBAction func onTapShowAll(_ sender: Any) {
        isShowAll = !isShowAll
        reloadCustomers()
        onSelectedCustomer()
    }

    @IBAction func onVisitCustomer(_ sender: Any) {
        let reasonCodeDescTypeArray = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "CALLRSN")
        if reasonCodeDescTypeArray.count == 0 {
            openCustomerActivities()
        }
        else {
            guard let selectedCustomerDetail = self.selectedCustomer else {return}
            let selectReasonCodeVC = UIViewController.getViewController(storyboardName: "SelectCustomer", storyboardID: "SelectReasonCodeVC") as! SelectReasonCodeVC
            selectReasonCodeVC.setDefaultModalPresentationStyle()
            selectReasonCodeVC.customerDetails = selectedCustomerDetail
            selectReasonCodeVC.reasonType = .visitReason
            selectReasonCodeVC.dismissHandler = { vc, dismissOption in
                if dismissOption == SelectReasonCodeVC.DismissOption.okay {
                    self.onSelectedCustomerVisitReasonCode(reasonCode: vc.selectedReasonDescType!)
                    self.openCustomerActivities()
                }
            }
            self.present(selectReasonCodeVC, animated: true, completion: nil)
        }
    }

    func openCustomerActivities() {
        guard let selectedCustomer = self.selectedCustomer else {return}

        print(selectedCustomer.surveys!)
        print(selectedCustomer.surveySet)
        
        // load opportunities
        if globalInfo.customerOpportunityArray.count == 0 {
            globalInfo.loadDefaultOpportunities(selectedCustomer: selectedCustomer)
        }

        // save visit start date if it is first visit
        if String.isNullOrEmpty(value: selectedCustomer.visitStartDate) == true {
            let nowString = Date().toDateString(format: kTightFullDateFormat)
            selectedCustomer.visitStartDate = nowString
            GlobalInfo.saveCache()
        }

        let customerActivitesVC = UIViewController.getViewController(storyboardName: "CustomerActivities", storyboardID: "CustomerActivitiesVC") as! CustomerActivitiesVC
        customerActivitesVC.mainVC = mainVC
        customerActivitesVC.customerDetail = selectedCustomer
        customerActivitesVC.dismissHandler = { vc in
            self.reloadCustomers()
            self.onSelectedCustomer()
        }
        mainVC.pushChild(newVC: customerActivitesVC, containerView: mainVC.containerView)
    }

    func doEndTripProcess() {
        // show Trip Settlement
        let tripSettlementVC = UIViewController.getViewController(storyboardName: "SelectCustomer", storyboardID: "TripSettlementVC") as! TripSettlementVC
        tripSettlementVC.dismissHandler = {
            // delete territory code
            self.globalInfo.loadUserSetting()
            self.globalInfo.territory = ""
            self.globalInfo.saveUserSetting()
            // signout
            self.globalInfo.gpsLogger.stopLogger()
            let loginVC = UIViewController.getViewController(storyboardName: "Main", storyboardID: "LoginVC") as! LoginVC
            loginVC.setAsRoot()
        }
        tripSettlementVC.setDefaultModalPresentationStyle()
        self.present(tripSettlementVC, animated: true, completion: nil)
    }

    @IBAction func onEndTrip(_ sender: Any) {
        Utils.showAlert(vc: self, title: "END TRIP", message: "You are about to commence the End Trip processing. Once started you will not be able to return to make further sales for this trip", failed: false, customerName: "", leftString: "Return", middleString: "", rightString: "End Trip") { (returnCode) in
            if returnCode == MessageDialogVC.ReturnCode.right {
                self.doEndTripProcess()
            }
        }
    }

    @IBAction func onNoVisitRequired(_ sender: Any) {

        guard let selectedCustomerDetail = self.selectedCustomer else {return}

        let selectReasonCodeVC = UIViewController.getViewController(storyboardName: "SelectCustomer", storyboardID: "SelectReasonCodeVC") as! SelectReasonCodeVC
        selectReasonCodeVC.setDefaultModalPresentationStyle()
        selectReasonCodeVC.customerDetails = selectedCustomerDetail
        selectReasonCodeVC.reasonType = .noVisitReason
        selectReasonCodeVC.dismissHandler = { vc, dismissOption in
            if dismissOption == SelectReasonCodeVC.DismissOption.okay {

                let selectedReasonCode = vc.selectedReasonDescType!

                let postVisitTaskVC = UIViewController.getViewController(storyboardName: "CustomerActivities", storyboardID: "PostVisitTaskVC") as! PostVisitTaskVC
                postVisitTaskVC.setDefaultModalPresentationStyle()
                postVisitTaskVC.customerDetail = selectedCustomerDetail
                postVisitTaskVC.dismissHandler = { vc, dismissOption in
                    if dismissOption == .done {

                        let nextVisitDateString = vc.nextVisitDate.toDateString(format: kTightJustDateFormat) ?? ""
                        let visitNote = vc.visitNote

                        selectedCustomerDetail.nextVisitDate = nextVisitDateString
                        selectedCustomerDetail.visitNote = visitNote

                        self.onSelectedNoVisitReasonCode(reasonCode: selectedReasonCode)
                    }
                }
                self.present(postVisitTaskVC, animated: true, completion: nil)
            }
        }
        self.present(selectReasonCodeVC, animated: true, completion: nil)
    }

    @IBAction func onMessage(_ sender: Any) {
        if selectedCustomer == nil {
            return
        }
        let messageBoardVC = UIViewController.getViewController(storyboardName: "CustomerActivities", storyboardID: "MessageBoardVC") as! MessageBoardVC
        messageBoardVC.mainVC = mainVC
        messageBoardVC.customerDetail = selectedCustomer
        mainVC.pushChild(newVC: messageBoardVC, containerView: mainVC.containerView)
    }

    @IBAction func onSearch(_ sender: Any) {
        let searchVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "SearchCustomerVC") as! SearchCustomerVC
        searchVC.setDefaultModalPresentationStyle()
        searchVC.addingDate = Date()
        searchVC.isFromVisitPlanner = false
        searchVC.dismissHandler = {
            self.reloadCustomers()
        }
        self.present(searchVC, animated: true, completion: nil)
    }

    @IBAction func onAddCustomer(_ sender: Any) {
        let newCustomerVC = UIViewController.getViewController(storyboardName: "NewCustomer", storyboardID: "NewCustomerVC") as! NewCustomerVC
        newCustomerVC.setDefaultModalPresentationStyle()
        newCustomerVC.dismissHandler = {vc, dismissOption in
            if dismissOption == NewCustomerVC.DismissOption.add {
                self.reloadCustomers()
            }
        }
        self.present(newCustomerVC, animated: true, completion: nil)
    }

    @IBAction func onCustomerMap(_ sender: Any) {
        if customerMapView.isHidden == true {
            reloadMap()
        }
        customerMapView.isHidden = !customerMapView.isHidden
    }

}

extension SelectCustomerVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customerDetailArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerCell", for: indexPath) as! CustomerCell
        cell.setupCell(parentVC: self, indexPath: indexPath)
        return cell
    }

}

extension SelectCustomerVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }

}

extension SelectCustomerVC: TableViewReorderDelegate {

    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Update data model
        let sourceRow = sourceIndexPath.row
        let destRow = destinationIndexPath.row

        let sourceCustomerDetail = customerDetailArray[sourceRow]
        let destCustomerDetail = customerDetailArray[destRow]
        customerDetailArray.remove(at: sourceRow)
        customerDetailArray.insert(sourceCustomerDetail, at: destRow)

        let presoldOrHeader = presoldOrHeaderArray[sourceRow]
        presoldOrHeaderArray.remove(at: sourceRow)
        presoldOrHeaderArray.insert(presoldOrHeader, at: destRow)

        let tempSeqNo = sourceCustomerDetail.seqNo ?? ""
        sourceCustomerDetail.seqNo = destCustomerDetail.seqNo
        destCustomerDetail.seqNo = tempSeqNo

        GlobalInfo.saveCache()
    }

    func tableView(_ tableView: UITableView, canReorderRowAt indexPath: IndexPath) -> Bool {
        let index = indexPath.row
        let customerDetail = customerDetailArray[index]
        if customerDetail.isFromSameNextVisit == true {
            return false
        }
        return true
    }

    func tableViewDidFinishReordering(_ tableView: UITableView, from initialSourceIndexPath: IndexPath, to finalDestinationIndexPath: IndexPath) {
        tableView.reloadData()
    }
}

extension SelectCustomerVC: GMSMapViewDelegate {

    /*
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {

        guard let userInfo = marker.userData as? NearbyPlace else {return nil}
        if userInfo.customerDetail != nil {
            let infoView = CustomerPlaceMarkerInfoView(frame: CGRect(x: 0, y: 0, width: 280, height: 119))
            infoView.titleLabel.text = userInfo.name
            infoView.customerNameLabel.text = userInfo.customerDetail?.name ?? ""
            infoView.lastOrderedLabel.text = userInfo.lastOrderedDate
            return infoView
        }
        else {
            let infoView = NormalPlaceMarkerInfoView(frame: CGRect(x: 0, y: 0, width: 280, height: 50))
            infoView.titleLabel.text = userInfo.name
            return infoView
        }
    }
    */

}
