//
//  BluetoothPrintersVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 9/10/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import ExternalAccessory

class SelectPrinterVC: UIViewController {

    @IBOutlet weak var printerTableView: UITableView!
    @IBOutlet weak var noPrinterLabel: UILabel!

    var selectedPrinter: EAAccessory?
    var bluetoothPrinters = [EAAccessory]()

    enum DismissOption {
        case cancelled
        case selected
    }

    var dismissHandler: ((SelectPrinterVC, DismissOption)->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadPrinters()
    }

    func initData() {
        let manager = EAAccessoryManager.shared()
        bluetoothPrinters = manager.connectedAccessories
    }

    func initUI() {
        printerTableView.delegate = self
        printerTableView.dataSource = self
    }

    func reloadPrinters() {
        let manager = EAAccessoryManager.shared()
        bluetoothPrinters = manager.connectedAccessories
        refreshPrinters()
    }

    func refreshPrinters() {
        printerTableView.reloadData()
        if bluetoothPrinters.count > 0 {
            noPrinterLabel.isHidden = true
        }
        else {
            noPrinterLabel.isHidden = false
        }
    }

    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?(self, .cancelled)
        }
    }

}

extension SelectPrinterVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bluetoothPrinters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let accessory = bluetoothPrinters[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectPrintersCell") as! SelectPrintersCell
        let name = accessory.name
        let serialNumber = accessory.serialNumber
        cell.contentLabel.text = "\(name)\n\(serialNumber)"

        cell.topSeparatorLabel.isHidden = true
        if index == bluetoothPrinters.count-1 {
            cell.bottomSeparatorLabel.isHidden = true
        }
        else {
            cell.bottomSeparatorLabel.isHidden = false
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let accessory = bluetoothPrinters[indexPath.row]
        selectedPrinter = accessory
        self.dismiss(animated: true) {
            self.dismissHandler?(self, .selected)
        }
    }

}
