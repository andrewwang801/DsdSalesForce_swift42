//
//  VisitPlannerVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 5/11/19.
//  Copyright © 2019 iOS Developer. All rights reserved.
//

import UIKit
import GoogleMaps

class VisitPlannerVC: UIViewController {

    @IBOutlet weak var weekdayCV: UICollectionView!
    @IBOutlet weak var customerTableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var customerMapView: GMSMapView!
    @IBOutlet weak var addAVisitButton: AnimatableButton!
    @IBOutlet weak var mapDay: AnimatableButton!
    @IBOutlet weak var returnButton: AnimatableButton!

    var mainVC: MainVC!
    let globalInfo = GlobalInfo.shared

    var weekdayStart = Date()
    var customerDetailArray = [CustomerDetail]()
    var presoldOrHeaderArray = [PresoldOrHeader?]()

    var mapCustomerArray = [CustomerDetail]()
    var mapPresoldOrHeaderArray = [PresoldOrHeader?]()

    let kWeekdayCount = 7
    var selectedWeekdayIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
        
        self.customerTableView.dragInteractionEnabled = true
        self.customerTableView.dragDelegate = self as UITableViewDragDelegate
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadCustomers()
        refreshCustomers()
        refreshWeekdays()

        mainVC.setTitleBarText(title: L10n.visitPlanner())
    }

    func initUI() {
        addAVisitButton.setTitleForAllState(title: L10n.addAVisit())
        mapDay.setTitleForAllState(title: L10n.mapDay())
        returnButton.setTitleForAllState(title: L10n.Return())
        noDataLabel.text = L10n.thereIsNoData()
        
        customerTableView.dataSource = self
        customerTableView.delegate = self

        weekdayCV.dataSource = self
        weekdayCV.delegate = self

        initMap()
    }

    func initMap() {
        customerMapView.delegate = self
        customerMapView.isMyLocationEnabled = true
        customerMapView.settings.zoomGestures = true
        customerMapView.settings.rotateGestures = true
        customerMapView.settings.compassButton = false
    }

    func reloadCustomers() {
        customerDetailArray.removeAll()
        presoldOrHeaderArray.removeAll()
        
        // get the dayNo
        let selectedDay = weekdayStart.getDateAddedBy(days: selectedWeekdayIndex)
        let dayNo = Utils.getWeekday(date: selectedDay)

        // all customers in the routesch
        // all customers manually added by the user during the day on Monday 15 July(if any)
        var scheduledCustomerArray = CustomerDetail.getScheduled(context: globalInfo.managedObjectContext, dayNo: "\(dayNo)", shouldExcludeCompleted: false)
        scheduledCustomerArray = scheduledCustomerArray.filter({ (customerDetail) -> Bool in
            if customerDetail.isVisitPlanned == true {
                let nowDateString = selectedDay.toDateString(format: kTightJustDateFormat) ?? ""
                if customerDetail.deliveryDate == nowDateString {
                    return true
                }
                else {
                    return false
                }
            }
            return true
        })
        customerDetailArray.append(contentsOf: scheduledCustomerArray)

        // all customers with a presold header record
        let allPresoldorHeaders = PresoldOrHeader.getAll(context: globalInfo.managedObjectContext)
        for presoldorHeader in allPresoldorHeaders {
            let custNo = presoldorHeader.custNo ?? ""
            let chainNo = presoldorHeader.chainNo ?? ""
            if let customerDetail = CustomerDetail.getBy(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo) {
                customerDetailArray.append(customerDetail)
            }
        }

        customerDetailArray = CustomerDetail.sortBySeqNo(customerDetailArray: customerDetailArray)

        for customerDetail in customerDetailArray {
            let chainNo = customerDetail.chainNo ?? ""
            let custNo = customerDetail.custNo ?? ""
            let presoldOrHeader = PresoldOrHeader.getFirstBy(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo)
            // filter customers by search text
            presoldOrHeaderArray.append(presoldOrHeader)
        }

        reloadMap()
    }

    func reloadMap() {
        customerMapView.clear()
        var markers = [GMSMarker]()
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

    func refreshCustomers() {
        customerTableView.reloadData()
        if customerDetailArray.count > 0 {
            noDataLabel.isHidden = true
        }
        else {
            noDataLabel.isHidden = false
        }
    }

    func refreshWeekdays() {
        weekdayCV.reloadData()
    }

    func onNoteCustomerTapped(index: Int) {
        let customerDetail = customerDetailArray[index]
        let messageBoardVC = UIViewController.getViewController(storyboardName: "CustomerActivities", storyboardID: "MessageBoardVC") as! MessageBoardVC
        messageBoardVC.mainVC = mainVC
        messageBoardVC.customerDetail = customerDetail
        mainVC.pushChild(newVC: messageBoardVC, containerView: mainVC.containerView)
    }

    func onLocateCustomerTapped(index: Int) {

        let customerDetail = customerDetailArray[index]

        var lat: Double = 0
        var lon: Double = 0
        lat = Double(customerDetail.driverLatitude ?? "0") ?? 0
        lon = Double(customerDetail.driverLongitude ?? "0") ?? 0

        if lat == 0 || lon == 0 {
            lat = Double(customerDetail.latitude ?? "0") ?? 0
            lon = Double(customerDetail.longitude ?? "0") ?? 0
            if lat == 0 || lon == 0 {
                return
            }
        }

        let locationVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "CustomerLocationVC") as! CustomerLocationVC
        locationVC.latitude = lat
        locationVC.longitude = lon
        locationVC.setDefaultModalPresentationStyle()
        self.present(locationVC, animated: true, completion: nil)
    }

    func onWeekdayTapped(index: Int) {
        selectedWeekdayIndex = index
        refreshWeekdays()
        reloadCustomers()
        refreshCustomers()
    }

    @IBAction func onAddVisit(_ sender: Any) {
        let searchVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "SearchCustomerVC") as! SearchCustomerVC
        searchVC.setDefaultModalPresentationStyle()
        searchVC.addingDate = weekdayStart.getDateAddedBy(days: selectedWeekdayIndex)
        searchVC.isFromVisitPlanner = true
        searchVC.dismissHandler = {
            self.reloadCustomers()
            self.refreshCustomers()
        }
        self.present(searchVC, animated: true, completion: nil)
    }

    @IBAction func onMapDay(_ sender: Any) {
        if customerMapView.isHidden == true {
            reloadMap()
        }
        customerMapView.isHidden = !customerMapView.isHidden
    }

    @IBAction func onReturnButton(_ sender: Any) {
        mainVC.popChild(containerView: mainVC.containerView)
    }
}

extension VisitPlannerVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customerDetailArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VisitPlannerCustomerCell", for: indexPath) as! VisitPlannerCustomerCell
        cell.setupCell(parentVC: self, indexPath: indexPath)
        return cell
    }
}

extension VisitPlannerVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}

extension VisitPlannerVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return kWeekdayCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VisitPlannerWeekdayCell", for: indexPath) as! VisitPlannerWeekdayCell
        cell.setupCell(parentVC: self, indexPath: indexPath)
        return cell
    }
}

extension VisitPlannerVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = collectionView.bounds.width
        let totalHeight = collectionView.bounds.height
        let availableWidth = totalWidth-CGFloat(kWeekdayCount-1)*1
        let normalWidth = ceil((availableWidth/CGFloat(kWeekdayCount)))
        let lastWidth = availableWidth-normalWidth*CGFloat(kWeekdayCount-1)
        if indexPath.row != kWeekdayCount-1 {
            return CGSize(width: normalWidth, height: totalHeight)
        }
        else {
            return CGSize(width: lastWidth, height: totalHeight)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

extension VisitPlannerVC: GMSMapViewDelegate {

}

// MARK: - UITableViewDragDropDelegate Methods
extension VisitPlannerVC : UITableViewDragDelegate
{
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem]
    {
        let item = String(indexPath.row)
        let itemProvider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem]
    {
        let item = String(indexPath.row)
        let itemProvider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters?
    {
        if tableView == tableView
        {
            let previewParameters = UIDragPreviewParameters()
            previewParameters.visiblePath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 250, height: 61))
            return previewParameters
        }
        return nil
    }
}
