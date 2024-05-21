//
//  AssetAddBaseVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 2/4/19.
//  Copyright © 2019 iOS Developer. All rights reserved.
//

import UIKit

class AssetAddBaseVC: UIViewController {

    var equipmentArray = [Equipment]()
    var selectedEquipment: Equipment? {
        didSet {
            onSelectedEquipment()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func onSelectedEquipment() {

    }

    func refreshAssets() {
        
    }

}
