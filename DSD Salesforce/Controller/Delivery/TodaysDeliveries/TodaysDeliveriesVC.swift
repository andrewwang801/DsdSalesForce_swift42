//
//  TodaysDeliveriesVC.swift
//  DSDConnect
//
//  Created by iOS Developer on 3/15/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import GoogleMaps
import IBAnimatable

class TodaysDeliveriesVC: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var tripComboButton: AnimatableButton!

    let globalInfo = GlobalInfo.shared
    var mainVC: MainVC!

    var isRefreshing = false
    var tripMapInfoList = [TripMapInfo]()
    var selectedTripIndex = 0
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
    var currentTripMapInfo: TripMapInfo?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initMap()
        refreshTripList()
    }

    func initMap() {
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.zoomGestures = true
        mapView.settings.rotateGestures = true
        mapView.settings.compassButton = false
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
        //let selectedTripInfo = globalInfo.tripInfoList[selectedTripIndex]
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
        //params["day"] = "2"

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

        mapView.clear()

        if currentTripInfo == nil {
            return
        }

        let userDefaults = UserDefaults.standard
        var params = [String: String]()
        let now = Date()
        let day = Utils.getWeekday(date: now)
        params["day"] = "\(day)"
        //params["day"] = "2"
        params["routenumber"] = "\(currentTripInfo!.routeNumber)"
        params["query"] = "5"
        params["tripnumber"] = "\(currentTripInfo!.tripNumber)"
        params["deliverydate"] = now.toDateString(format: "yyyy-MM-dd") ?? ""

        let strPinNumber = userDefaults.string(forKey: kDeliveryLoginPinNumberKey) ?? ""
        //let strPinNumber = kDeliveryPinNumber
        let strToken = userDefaults.string(forKey: kDeliveryLoginTokenKey) ?? ""
        let headers = ["X-Auth-Token": strToken]

        isRefreshing = true

        let baseURL = Utils.getBaseURL(pinNumber: strPinNumber)
        APIManager.doNormalRequest(baseURL: baseURL, methodName: "api/trip-map", httpMethod: "GET", headers: headers, params: params, shouldShowHUD: true) { (response, message) in
            if response == nil {

                self.isRefreshing = false

                Utils.showAlert(vc: self, title: "", message: "Api Failed.", failed: false, customerName: "", leftString: "", middleString: "OK", rightString: "", dismissHandler: nil)
            }
            else {
                self.tripMapInfoList.removeAll()

                let json = JSON(data: response as! Data)
                var mapInfoArray = TripMapInfo.arrayFrom(json: json)
                if mapInfoArray != nil {
                    DispatchQueue.global().async {
                        self.doProcessRoad(infoList: &mapInfoArray!)
                    }
                }
                else {
                    Utils.refreshToken(completion: { (success, message) in
                        self.showTripInfo()
                    })
                }
            }
        }
    }

    func doProcessRoad(infoList: inout [TripMapInfo]) {
        var onRouteItem: TripMapInfo?
        var onRouteInfos = [TripMapInfo]()
        var lastInfo: TripMapInfo? = TripMapInfo()
        for item in infoList {
            if item.customerName.trimed().lowercased() == "on route" {
                lastInfo = nil
                if onRouteItem == nil {
                    onRouteItem = item
                    onRouteInfos.append(onRouteItem!)
                }
                else {
                    if onRouteItem!.latitude == item.latitude && onRouteItem!.longitude == item.longitude {
                        //if onRouteItem!.time < item.time {
                        if let index = onRouteInfos.index(of: onRouteItem!) {
                            onRouteInfos.remove(at: index)
                            onRouteItem = item
                            onRouteInfos.append(onRouteItem!)
                        }
                        //}
                    }
                    else {
                        onRouteItem = item
                        onRouteInfos.append(item)
                    }
                }
            }
            else {
                if lastInfo != nil && lastInfo!.time == item.time && lastInfo!.customerName == item.customerName {
                    continue
                }
                lastInfo = item
                onRouteInfos.append(item)
                onRouteInfos = doProcessGoogleRoad(infoList: onRouteInfos, isLastDeliveryItem: true)
                tripMapInfoList.append(contentsOf: onRouteInfos)

                onRouteInfos.removeAll()
                onRouteItem = nil
            }
        }

        if onRouteInfos.count > 0 {
            onRouteInfos = doProcessGoogleRoad(infoList: onRouteInfos, isLastDeliveryItem: false)
            tripMapInfoList.append(contentsOf: onRouteInfos)
        }

        tripMapInfoList.append(contentsOf: infoList)

        doProcessDeliveryItem(infoList: &infoList)

        DispatchQueue.main.async {
            self.refreshMap()
            self.isRefreshing = false
        }
    }

    func doProcessGoogleRoad(infoList: [TripMapInfo], isLastDeliveryItem: Bool) -> [TripMapInfo] {

        var locationCoord = CLLocationCoordinate2D()
        var dataInfoList = [TripMapInfo]()
        var isCalling = false
        for i in 0..<(infoList.count/100+1) {
            var param = ""
            let jMax = min(infoList.count, (i+1)*100)
            for j in i*100..<jMax {
                if param != "" {
                    param = param+"|"
                }
                param = param + "\(infoList[j].latitude), \(infoList[j].longitude)"
            }
            if param != "" {
                var params = [String: String]()
                params["path"] = param
                params["interpolate"] = "true"
                params["key"] = "AIzaSyCJ6WmPQoXlrpLh1AYa0o6U-mk48LjSkHk"

                isCalling = true
                let finalI = i
                APIManager.doNormalRequest(baseURL: "https://roads.googleapis.com/v1/", methodName: "snapToRoads", httpMethod: "GET", headers: params, params: params, shouldShowHUD: true) { (response, message) in
                    if response != nil {
                        let responseJSON = JSON(data: response as! Data)
                        if let pointJSONArray = responseJSON["snappedPoints"].array {
                            let pointArray = GooglePoint.getArrayBy(pointJSONArray: pointJSONArray)
                            if pointArray.count > 0 {
                                var lastIndex = 0
                                for (k, point) in pointArray.enumerated() {
                                    if k == pointArray.count-1 {
                                        locationCoord.latitude = point.location.latitude
                                        locationCoord.longitude = point.location.longitude
                                    }
                                    if point.originalIndex == -1 {
                                        continue
                                    }
                                    for kk in lastIndex..<max(point.originalIndex-1,lastIndex)  {
                                        dataInfoList.append(infoList[finalI*100+kk])
                                    }
                                    infoList[finalI*100+point.originalIndex].longitude = point.location.longitude
                                    infoList[finalI*100+point.originalIndex].latitude = point.location.latitude
                                    dataInfoList.append(infoList[finalI*100+point.originalIndex])
                                    lastIndex = point.originalIndex
                                }
                            }
                        }
                    }
                    isCalling = false
                }
                while isCalling == true {
                    Thread.sleep(forTimeInterval: 0.5)
                }
            }
        }
        if isLastDeliveryItem == true && dataInfoList.count > 0 && dataInfoList.last!.customerName.trimed().lowercased() == "on route" {
            let info = infoList.last!
            info.latitude = locationCoord.latitude
            info.longitude = locationCoord.longitude
            dataInfoList.append(info)
        }

        return dataInfoList
    }

    func doProcessDeliveryItem( infoList: inout [TripMapInfo]) {
        for (i, info) in infoList.enumerated() {
            if info.customerName.lowercased() != "on route" && i != 0 && i != infoList.count-1 {
                doCheckPoint(start: infoList[i-1], delivery: &infoList[i], end: infoList[i+1])
            }
        }
    }

    func doCheckPoint(start: TripMapInfo, delivery: inout TripMapInfo, end: TripMapInfo) {
        let path = GPSPath()
        var params = [String: String]()
        params["origin"] = "\(start.latitude),\(start.longitude)"
        params["destination"] = "\(end.latitude),\(end.longitude)"
        params["key"] = "AIzaSyCJ6WmPQoXlrpLh1AYa0o6U-mk48LjSkHk"
        var isCalling = true
        APIManager.doNormalRequest(baseURL: "https://maps.googleapis.com", methodName: "/maps/api/directions/json", httpMethod: "GET", headers: [:], params: params, shouldShowHUD: true) { (response, message) in
            if response != nil {
                let responseJSON = JSON(data: response as! Data)
                let pathResponse = GooglePath(json: responseJSON)
                if pathResponse.routes.count > 0 && pathResponse.routes[0].legs.count > 0 {
                    let leg = pathResponse.routes[0].legs[0]
                    path.distance = leg.distance.value
                    path.duration = leg.duration.value
                    path.start_location = GPSPath.GPSPosition()
                    path.start_location.lat = leg.start_location.lat
                    path.start_location.lng = leg.start_location.lng
                    path.end_location = GPSPath.GPSPosition()
                    path.end_location.lat = leg.end_location.lat
                    path.end_location.lng = leg.end_location.lng

                    for (_, step) in leg.steps.enumerated() {
                        let subPath = GPSPath()
                        subPath.distance = step.distance.value
                        subPath.duration = step.duration.value
                        subPath.start_location = GPSPath.GPSPosition()
                        subPath.start_location.lat = step.start_location.lat
                        subPath.start_location.lng = step.start_location.lng
                        subPath.end_location = GPSPath.GPSPosition()
                        subPath.end_location.lat = step.end_location.lat
                        subPath.end_location.lng = step.end_location.lng
                        path.pathList.append(subPath)
                    }
                }
            }
            isCalling = false
        }

        while isCalling == true {
            Thread.sleep(forTimeInterval: 0.5)
        }

        let startLocation = GPSLocation()
        startLocation.time = Date.fromDateString(dateString: start.time, format: "kk:mm:ss")?.getTimestamp() ?? 0
        startLocation.latitude = start.latitude
        startLocation.longitude = start.longitude

        let endLocation = GPSLocation()
        endLocation.time = Date.fromDateString(dateString: end.time, format: "kk:mm:ss")?.getTimestamp() ?? 0
        endLocation.latitude = end.latitude
        endLocation.longitude = end.longitude

        var curGPSLocation = GPSLocation()
        let deliveryTime = Date.fromDateString(dateString: delivery.time, format: "kk:mm:ss")?.getTimestamp() ?? 0
        if path.distance == 0 {
            curGPSLocation = TodaysDeliveriesVC.getCalcGPSLocation(sLoc: startLocation, eLoc: endLocation, time: deliveryTime)
        }
        else {
            curGPSLocation = TodaysDeliveriesVC.getCalcGPSLocationOnPath(sLoc: startLocation, eLoc: endLocation, path: path, time: deliveryTime)
        }

        delivery.longitude = curGPSLocation.longitude
        delivery.latitude = curGPSLocation.latitude
    }

    static func getCalcGPSLocation(sLoc: GPSLocation, eLoc: GPSLocation, time: Int64) -> GPSLocation {
        let location = GPSLocation()
        location.time = time
        location.latitude = sLoc.latitude+(eLoc.latitude-sLoc.latitude)/Double(eLoc.time-sLoc.time)*Double(time-sLoc.time)
        location.longitude = sLoc.longitude+(eLoc.longitude-sLoc.longitude)/Double(eLoc.time-sLoc.time)*Double(time-sLoc.time)
        return location
    }

    static func getCalcGPSLocationOnPath(sLoc: GPSLocation, eLoc: GPSLocation, path: GPSPath, time: Int64) -> GPSLocation {
        let duration = eLoc.time-sLoc.time
        let speed = Double(path.distance)/Double(duration)
        let distance = Int64(Double(time-sLoc.time)*speed)
        var sDistance: Int64 = 0
        var eDistance: Int64 = 0
        var selPath: GPSPath?
        for (_, _path) in path.pathList.enumerated() {
            eDistance = sDistance+_path.distance
            if distance >= sDistance && distance <= eDistance {
                selPath = _path
                break
            }
            sDistance = eDistance
        }

        if selPath == nil {
            return getCalcGPSLocation(sLoc: sLoc, eLoc: eLoc, time: time)
        }

        let startTime = sLoc.time

        let _sLoc = GPSLocation()
        _sLoc.time = startTime+Int64(Double(sDistance)/speed)
        _sLoc.longitude = selPath!.start_location.lng
        _sLoc.latitude = selPath!.start_location.lat

        let _eLoc = GPSLocation()
        _eLoc.time = startTime+Int64(Double(eDistance)/speed)
        _eLoc.longitude = selPath!.end_location.lng
        _eLoc.latitude = selPath!.end_location.lat

        return getCalcGPSLocation(sLoc: _sLoc, eLoc: _eLoc, time: time)
    }

    func refreshMap() {

        mapView.clear()

        if tripMapInfoList.count > 0 {
            mapView.isMyLocationEnabled = true
            var markers = [GMSMarker]()
            var snippet = ""
            for (pinIndex, pinInfo) in tripMapInfoList.enumerated() {
                let customerLocation = CLLocationCoordinate2D(latitude: pinInfo.latitude, longitude: pinInfo.longitude)
                let newMarker = GMSMarker(position: customerLocation)

                if pinInfo.customerName.trimed().lowercased() == "on route" {
                    snippet = Date.convertDateFormat(dateString: pinInfo.time, fromFormat: "HH:mm:ss", toFormat: "hh:mm:ss a")
                    newMarker.snippet = "Location at : " + snippet
                }
                else {
                    if pinInfo.customerName.isEmpty == false {
                        snippet = pinInfo.customerName.trimed()
                    }
                    if pinInfo.docNo.isEmpty == false {
                        if snippet.length > 0 {
                            snippet += "\nDocket : " + pinInfo.docNo.trimed()
                        }
                        else {
                            snippet = "Docket : " + pinInfo.docNo.trimed()
                        }
                    }
                    if snippet.length > 0 {
                        snippet += "\nValue : \(Double(pinInfo.totalInvoiceAmount).moneyString)"
                    }
                    else {
                        snippet = "Value : \(Double(pinInfo.totalInvoiceAmount).moneyString)"
                    }
                    let delieveredDate = Date.convertDateFormat(dateString: pinInfo.time, fromFormat: "HH:mm:ss", toFormat: "hh:mm:ss a")
                    snippet += "\nDelivered at : \(delieveredDate)"
                    if pinInfo.receivedBy.isEmpty == false {
                        snippet += "\nReceived By : " + pinInfo.receivedBy.trimed()
                    }
                    newMarker.snippet = snippet
                }

                if pinIndex == 0 {
                    newMarker.icon = UIImage(named: "icon_GreenCirclePin")
                    newMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
                }
                else {
                    if pinInfo.customerName.trimed().lowercased() == "on route" {
                        if pinIndex == tripMapInfoList.count-1 {
                            newMarker.icon = UIImage(named: "icon_RedCirclePin")
                            newMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
                        }
                        else {
                            newMarker.icon = UIImage(named: "icon_SmallBlackCirclePin")
                            newMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
                            /*
                            newMarker.isFlat = true

                            let nextPinInfo = tripMapInfoList[pinIndex+1]
                            let nextLat = nextPinInfo.latitude
                            let nextLon = nextPinInfo.longitude
                            let currentLat = pinInfo.latitude
                            let currentLon = pinInfo.longitude

                            let bearing = Utils.bearingInDegree(a1: currentLat, a2: currentLon, b1: nextLat, b2: nextLon)
                            newMarker.rotation = bearing-90*/
                        }
                    }
                    else {
                        newMarker.icon = UIImage(named: "icon_Pin")
                        newMarker.groundAnchor = CGPoint(x: 0.5, y: 1)
                    }
                }
                newMarker.userData = pinInfo
                newMarker.map = mapView
                markers.append(newMarker)
            }

            let path = GMSMutablePath()
            for marker in markers {
                //NSLog("Marker position:\(marker.position)")
                path.add(marker.position)
            }
            let bounds = GMSCoordinateBounds(path: path)

            let cameraUpdate = GMSCameraUpdate.fit(bounds, withPadding: 64)
            mapView.animate(with: cameraUpdate)
        }
    }

    func showTripMapInfo() {

        if currentTripMapInfo == nil {
            Utils.showAlert(vc: self, title: "", message: "PDF not able to be retrieved", failed: false, customerName: "", leftString: "", middleString: "OK", rightString: "", dismissHandler: nil)
        }
        else {
            let dateString = Date.convertDateFormat(dateString: currentTripMapInfo!.deliveryDate, fromFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS", toFormat: kTightJustDateFormat)
            Utils.showPDF(vc: self, strDocNo: currentTripMapInfo!.docNo, strDate: dateString)
        }
    }

    @IBAction func onReload(_ sender: Any) {
        if isRefreshing == false {
            showTripInfo()
        }
    }

    @IBAction func onMyLocation(_ sender: Any) {
        guard let location = mapView.myLocation else {return}
        mapView.animate(toLocation: location.coordinate)
    }

    @IBAction func onClose(_ sender: Any) {
        mainVC.popChild(containerView: mainVC.containerView)
    }

}

extension TodaysDeliveriesVC: GMSMapViewDelegate {

    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let snippet = marker.snippet ?? ""
        let nsText = snippet as NSString
        let font = UIFont.systemFont(ofSize: 14.0)
        let textSize = nsText.size(withAttributes: [NSAttributedString.Key.font: font])
        let snippetView = UIView(frame: CGRect(x:0, y:0, width:textSize.width+35, height:textSize.height+45))
        snippetView.backgroundColor = UIColor.clear
        let snippetBounds = snippetView.bounds

        let innerViewFrame = snippetBounds.insetBy(dx: 5.0, dy: 10.0)
        let innerView = UIView(frame: innerViewFrame)
        innerView.backgroundColor = UIColor.white
        innerView.setCornerRadius(cornerRadius: 4.0, borderWidth: 0, borderColor: UIColor.clear)
        innerView.setShadow(offset: CGSize(width: 0, height: 2.0), radius: 2.0, opacity: 0.2, color: UIColor.black)
        snippetView.addSubview(innerView)

        let textFrame = innerView.bounds.insetBy(dx: 5.0, dy: 5.0)
        let snippetLabel = UILabel(frame: textFrame)
        snippetLabel.font = font
        snippetLabel.textAlignment = .center
        snippetLabel.text = snippet
        snippetLabel.numberOfLines = 0
        innerView.addSubview(snippetLabel)

        return snippetView
    }

    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        currentTripMapInfo = marker.userData as? TripMapInfo
        if currentTripMapInfo?.customerName.trimed().lowercased() == "on route" {
            return
        }
        showTripMapInfo()
    }
}
