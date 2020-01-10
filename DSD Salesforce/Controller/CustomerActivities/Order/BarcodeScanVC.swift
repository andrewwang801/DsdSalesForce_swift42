//
//  BarcodeScanVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 8/23/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import AVFoundation
import RSBarcodes_Swift

class BarcodeScanVC: RSCodeReaderViewController {

    @IBOutlet weak var mainBack: UIView!
    @IBOutlet weak var cancelButton: AnimatableButton!
    
    var dispatched: Bool = false
    var scanBounds = CGRect.zero

    enum DismissOption {
        case cancelled
        case scanned
    }

    var itemUPC: String = ""
    var dismissHandler: ((BarcodeScanVC, DismissOption) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()

        cancelButton.setTitleForAllState(title: L10n.cancel())
        // Do any additional setup after loading the view.
        initBarcode()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.dispatched = false // reset the flag so user can do another scan
        super.viewWillAppear(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initMainBackHole()
    }

    func initMainBackHole() {

        // make a hole at the main back
        let mainBounds = mainBack.bounds
        let width = floor(mainBounds.width / 2)
        let height = floor(width/480*300)

        let centerX = mainBounds.width / 2
        let centerY = mainBounds.height / 2

        // make a slight round rect
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: mainBounds.size.width, height: mainBounds.size.height), cornerRadius: 0)

        scanBounds = CGRect(x: centerX-width/2, y: centerY-height/2, width: width, height: height)
        let innerPath = UIBezierPath(roundedRect: scanBounds, cornerRadius: 10.0)

        path.append(innerPath)
        path.usesEvenOddFillRule = true

        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
        fillLayer.fillColor = UIColor.black.cgColor
        fillLayer.opacity = 0.6
        mainBack.layer.addSublayer(fillLayer)

    }

    func initBarcode() {

        // MARK: NOTE: If you want to detect specific barcode types, you should update the types
        let types = NSMutableArray(array: self.output.availableMetadataObjectTypes)
        self.output.metadataObjectTypes = NSArray(array: types) as? [AVMetadataObject.ObjectType]

        // MARK: NOTE: If you layout views in storyboard, you should these 3 lines
        for subview in self.view.subviews {
            self.view.bringSubviewToFront(subview)
        }

        self.barcodesHandler = { barcodes in
            if !self.dispatched { // triggers for only once

                var isFound = false
                for barcode in barcodes {

                    let barcodeBounds = barcode.bounds

                    print("Barcode found: type=" + barcode.type.rawValue + " value=" + (barcode.stringValue ?? ""))

                    if self.scanBounds.contains(barcodeBounds) == true {
                        isFound = true
                        self.itemUPC = barcode.stringValue ?? ""
                        break
                    }

                    break
                }

                if isFound == false {
                    self.dispatched = false
                }
                else {
                    self.dispatched = true
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: {
                            self.dismissHandler?(self, .scanned)
                        })
                    }
                }
            }
        }
    }

    @IBAction func onCancel(_ sender: Any) {
        self.dispatched = true
        self.dismiss(animated: true) {
            self.dismissHandler?(self, .cancelled)
        }
    }

}
