//
//  SelectCustomerNearbyVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/6/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import GoogleMaps
import IBAnimatable

class SelectCustomerNearbyVC: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var storeTypeView: AnimatableView!
    @IBOutlet weak var storeTypeButton: UIButton!

    let globalInfo = GlobalInfo.shared
    var selectCustomerVC: SelectCustomerVC!
    let placeTypeArray = kGoogleSearchTypeArray

    var nearbyPlaceArray = [NearbyPlace]()
    var selectedStoreType: String? {
        didSet {
            if selectedStoreType == nil {
                storeTypeButton.setTitleForAllState(title: "SELECT STORE TYPE")
                storeTypeButton.setTitleColor(kStoreTypeEmptyTextColor, for: .normal)
            }
            else {
                let typeString = selectedStoreType!.replacingOccurrences(of: "_", with: " ")
                storeTypeButton.setTitleForAllState(title: typeString)
                storeTypeButton.setTitleColor(kStoreTypeNormalTextColor, for: .normal)
            }
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(SelectCustomerNearbyVC.updateUI), name: NSNotification.Name(rawValue: kCustomerSelectedNotificationName), object: nil)

        initData()
        initMap()

        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            self.updateUI()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isBeingDismissed == true || isMovingFromParent == true {
            NotificationCenter.default.removeObserver(self)
        }
    }

    func initData() {

        // populate customer type
        selectedStoreType = nil
    }

    func initMap() {
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.zoomGestures = true
        mapView.settings.rotateGestures = true
        mapView.settings.compassButton = false
    }

    @objc func updateUI() {
        guard let myLocation = mapView.myLocation else {return}
        let locationString = "\(myLocation.coordinate.latitude),\(myLocation.coordinate.longitude)"
        //let locationString = "-33.8670522,151.1957362"
        let type = (selectedStoreType ?? "").lowercased()
        let params: [String: Any] = ["location":locationString, "radius":"1000", "type":type, "key": kNearbyAPIKey]

        APIManager.doNormalRequest(baseURL: kNearbyAPIURL, methodName: "", httpMethod: "GET", params: params, shouldShowHUD: true) { (response, message) in

            guard let responseData = response as? Data else {
                SVProgressHUD.showError(withStatus: "Google api failed. \(message)")
                return
            }

            let responseJSON = JSON(data: responseData)
            guard let resultJSONArray = responseJSON["results"].array else {
                SVProgressHUD.showError(withStatus: "Google api response error.")
                return
            }

            let context = self.globalInfo.managedObjectContext!
            self.nearbyPlaceArray.removeAll()
            for resultJSON in resultJSONArray {
                let geometry = resultJSON["geometry"]
                let location = geometry["location"]
                let lat = location["lat"].doubleValue
                let lon = location["lng"].doubleValue
                let name = resultJSON["name"].stringValue
                let placeId = resultJSON["place_id"].stringValue

                // decide if it is in customer details
                var isCustomer = false
                var theCustomer: CustomerDetail?
                if placeId.trimed() == "" {
                    isCustomer = false
                }
                else {
                    theCustomer = CustomerDetail.getBy(context: context, googlePlaceID: placeId).first
                    if theCustomer != nil {
                        isCustomer = true
                    }
                }

                if isCustomer == true {
                    let chainNo = theCustomer?.chainNo ?? "0"
                    let custNo = theCustomer?.custNo ?? "0"
                    let orderHistoryArray = OrderHistory.getBy(context: context, chainNo: chainNo, custNo: custNo)
                    let orderedHistoryArray = orderHistoryArray.sorted(by: { (orderHistory1, orderHistory2) -> Bool in
                        let date1 = orderHistory1.getDate()
                        let date2 = orderHistory2.getDate()
                        return date1 > date2
                    })
                    var lastOrdered = ""
                    if let recentOrderHistory = orderedHistoryArray.first {
                        let recentDateString = recentOrderHistory.getDate()
                        let recentDate = Date.fromDateString(dateString: recentDateString, format: kTightJustDateFormat) ?? Date()
                        lastOrdered = recentDate.toDateString(format: "dd/MM/yyyy") ?? ""
                    }
                    let nearbyPlace = NearbyPlace(name: name, customerDetail: theCustomer, latitude: lat, longitude: lon, lastVisitedDate: "29/02/2018", lastOrderedDate: lastOrdered, averageOrderAmount: "")
                    self.nearbyPlaceArray.append(nearbyPlace)
                }
                else {
                    let nearbyPlace = NearbyPlace(name: name, customerDetail: nil, latitude: lat, longitude: lon, lastVisitedDate: "", lastOrderedDate: "", averageOrderAmount: "")
                    self.nearbyPlaceArray.append(nearbyPlace)
                }
            }

            self.reloadMap()
        }

    }

    func reloadMap() {

        mapView.clear()
        var markers = [GMSMarker]()
        for nearbyPlace in nearbyPlaceArray {
            let placeLocation = CLLocationCoordinate2D(latitude: nearbyPlace.latitude, longitude: nearbyPlace.longitude)
            let newMarker = GMSMarker(position: placeLocation)
            newMarker.groundAnchor = CGPoint(x: 0.5, y: 1)
            if nearbyPlace.customerDetail != nil {
                newMarker.icon = UIImage(named: "Select_Customer_Marker_Green")
            }
            else {
                newMarker.icon = UIImage(named: "Select_Customer_Marker_Blue")
            }
            newMarker.userData = nearbyPlace
            newMarker.map = mapView
            markers.append(newMarker)
        }

        // add me
        if let myLocation = mapView.myLocation {
            let salesMarker = GMSMarker(position: myLocation.coordinate)
            salesMarker.icon =  UIImage(named: "Nearby_Sales_Position_Marker")
            salesMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            salesMarker.userData = nil
            salesMarker.map = mapView
            markers.append(salesMarker)
        }

        let path = GMSMutablePath()
        for marker in markers {
            path.add(marker.position)
        }
        let bounds = GMSCoordinateBounds(path: path)

        let cameraUpdate = GMSCameraUpdate.fit(bounds, withPadding: 64)
        mapView.animate(with: cameraUpdate)
    }

    @IBAction func onSelectStoreType(_ sender: Any) {

        let menuComboVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "MenuComboPopoverVC") as! MenuComboPopoverVC
        menuComboVC.modalPresentationStyle = .popover

        let senderButton = sender as! UIButton

        let menuNames = placeTypeArray.map { (googlePlaceType) -> String in
            return googlePlaceType.replacingOccurrences(of: "_", with: " ")
        }
        let menuItemCount = min(menuNames.count, 10)
        let totalHeight = kPopoverMenuCellHeight * CGFloat(menuItemCount)
        menuComboVC.preferredContentSize = CGSize(width: senderButton.bounds.width, height: totalHeight)
        menuComboVC.menuNamesArray = menuNames
        menuComboVC.dismissHandler = {vc, selectedIndex in
            self.selectedStoreType = self.placeTypeArray[selectedIndex]
        }

        let presentationPopoverVC = menuComboVC.popoverPresentationController
        presentationPopoverVC?.permittedArrowDirections = [.up]
        presentationPopoverVC?.delegate = self
        presentationPopoverVC?.sourceView = senderButton
        presentationPopoverVC?.sourceRect = senderButton.bounds
        presentationPopoverVC?.backgroundColor = kPopoverMenuBackgroundColor
        self.present(menuComboVC, animated: true, completion: nil)
    }
}

extension SelectCustomerNearbyVC: GMSMapViewDelegate {

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

    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        /*
        currentTripMapInfo = marker.userData as? TripMapInfo
        if currentTripMapInfo?.customerName.trimed().lowercased() == "on route" {
            return
        }
        showTripMapInfo()*/
    }
}

extension SelectCustomerNearbyVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
