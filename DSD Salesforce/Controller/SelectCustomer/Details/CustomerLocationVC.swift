//
//  CustomerLocationVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/29/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import GoogleMaps

class CustomerLocationVC: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!

    var latitude: Double = 0
    var longitude: Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        initMap()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reloadMap()
    }

    func initMap() {
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.zoomGestures = true
        mapView.settings.rotateGestures = true
        mapView.settings.compassButton = false
    }

    func reloadMap() {
        mapView.clear()
        let placeLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let marker = GMSMarker(position: placeLocation)
        marker.groundAnchor = CGPoint(x: 0.5, y: 1)
        marker.icon = UIImage(named: "Select_Customer_Location_Marker")
        marker.map = mapView

        /*
        let path = GMSMutablePath()
        path.add(marker.position)
        let bounds = GMSCoordinateBounds(path: path)*/
        let cameraUpdate = GMSCameraUpdate.setTarget(placeLocation, zoom: 14.0)
        mapView.animate(with: cameraUpdate)
    }

    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension CustomerLocationVC: GMSMapViewDelegate {

    /*
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {

        let userInfo = marker.userData as! NearbyPlace
        let infoView = PlaceMarkerInfoView(frame: CGRect(x: 0, y: 0, width: 280, height: 152))
        infoView.titleLabel.text = userInfo.name
        infoView.lastVisitedLabel.text = userInfo.lastVisitedDate
        infoView.lastOrderedLabel.text = userInfo.lastOrderedDate
        infoView.averageOrderLabel.text = userInfo.averageOrderAmount
        return infoView
    }

    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        /*
         currentTripMapInfo = marker.userData as? TripMapInfo
         if currentTripMapInfo?.customerName.trimed().lowercased() == "on route" {
         return
         }
         showTripMapInfo()*/
    }*/
}
