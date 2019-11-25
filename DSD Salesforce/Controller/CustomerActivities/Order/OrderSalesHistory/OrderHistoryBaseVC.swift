//
//  OrderHistoryBaseVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 8/31/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class OrderHistoryBaseVC: UIViewController {

    var customerDetail: CustomerDetail!

    var saItemArray = [String]()
    var bbItemArray = [String]()
    var saDateArray = [String]()
    var bbDateArray = [String]()

    var dataDictionary = [String: OrderHistoryItem]()
    var productDetailDictionary = [String: ProductDetail]()
    var dateDataDictionary = [String: [OrderHistoryItem]]()
    var orderHistoryItemArray = [OrderHistoryItem]()

    var isDeliver = true    // deliver or return
    var isShowCase = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
