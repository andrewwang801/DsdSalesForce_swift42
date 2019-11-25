//
//  NearbyPlace.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/6/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import Foundation

class NearbyPlace: NSObject {
    
    var name = ""
    var customerDetail: CustomerDetail?
    var latitude: Double = 0
    var longitude: Double = 0
    var lastVisitedDate = ""
    var lastOrderedDate = ""
    var averageOrderAmount = ""

    init(name: String, customerDetail: CustomerDetail?, latitude: Double, longitude: Double, lastVisitedDate: String, lastOrderedDate: String, averageOrderAmount: String) {
        self.name = name
        self.customerDetail = customerDetail
        self.latitude = latitude
        self.longitude = longitude
        self.lastVisitedDate = lastVisitedDate
        self.lastOrderedDate = lastOrderedDate
        self.averageOrderAmount = averageOrderAmount
    }
}
