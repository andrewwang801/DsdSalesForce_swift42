//
//  ZebraPrintEngine.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 9/10/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class ZebraPrintEngine: NSObject {

    // for printing
    static var connection: MfiBtPrinterConnection?
    static var selectedPrinter: EAAccessory?
    static var zebraPrinter: ZebraPrinter?
    static var pdfPath: String = ""
    static var hud: MBProgressHUD?
    static var viewController: UIViewController?
    static var completionHandler: ((Bool, String)->())?

    static func tryPrint(vc: UIViewController, pdfPath: String, completionHandler: ((Bool, String)->())?) {

        self.pdfPath = pdfPath
        self.viewController = vc
        self.completionHandler = completionHandler

        selectPrinter()
    }

    static func selectPrinter() {
        let selectPrinterVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "SelectPrinterVC") as! SelectPrinterVC
        selectPrinterVC.setDefaultModalPresentationStyle()
        selectPrinterVC.dismissHandler = { vc, dismissOption in
            if dismissOption == .selected {
                doPrinter(selectedPrinter: vc.selectedPrinter!)
            }
        }
        viewController?.present(selectPrinterVC, animated: true, completion: nil)
    }

    static func openPrinter(selectedPrinter: EAAccessory) -> Bool {
        let serialNumber = selectedPrinter.serialNumber
        self.connection = MfiBtPrinterConnection(serialNumber: serialNumber)

        let isOpened = self.connection!.open()
        if isOpened == false {
            return false
        }
        self.zebraPrinter = ZebraPrinterFactory.getInstance(self.connection!, with: PRINTER_LANGUAGE_CPCL)

        return true
    }

    static func doPrinter(selectedPrinter: EAAccessory) {
        if openPrinter(selectedPrinter: selectedPrinter) == false {
            Utils.showAlert(vc: self.viewController!, title: "", message: "Connection to printer failed.\nWill you try again?", failed: false, customerName: "", leftString: "Cancel", middleString: "", rightString: "Okay", dismissHandler: { (returnCode) in
                if returnCode == MessageDialogVC.ReturnCode.right {
                    self.selectPrinter()
                    return
                }
                else {
                    completionHandler?(false, "Connection to printer failed")
                    return
                }
            })
        }

        if zebraPrinter == nil {
            Utils.showAlert(vc: self.viewController!, title: "", message: "Printer is not ready.\nWill you try again?", failed: false, customerName: "", leftString: "Cancel", middleString: "", rightString: "Okay", dismissHandler: { (returnCode) in
                if returnCode == MessageDialogVC.ReturnCode.right {
                    self.selectPrinter()
                    return
                }
                else {
                    completionHandler?(false, "Printer is not ready.")
                    return
                }
            })
        }

        self.hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow, animated: true)

        /*
        DispatchQueue.global().async {
            self.sendImageToPrinter()
        }*/

        DispatchQueue.global().async {
            self.sendFileToPrinter()
        }
    }

    static func sendFileToPrinter() {

        let fileUtil = self.zebraPrinter!.getFileUtil()
        let result = self.printPDF(fileUtil: fileUtil!)
        self.connection!.close()
        DispatchQueue.main.async {
            self.hud?.hide(true)
            if result == true {
                completionHandler?(result, "")
            }
        }
    }

    static func printPDF(fileUtil: FileUtil) -> Bool {

        let pdfURL = URL(fileURLWithPath: self.pdfPath)
        let pdf = CGPDFDocument(pdfURL as CFURL)
        if pdf == nil {
            DispatchQueue.main.async {
                SVProgressHUD.showError(withStatus: "Could not retrieve PDF document.")
            }
            return false
        }
        else {
            var success = false
            do {
                try fileUtil.sendFileContents(self.pdfPath)
                success = true
            }
            catch let error {
                DispatchQueue.main.async {
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                }
                success = false
            }

            if success == true {
                DispatchQueue.main.async {
                    SVProgressHUD.showSuccess(withStatus: "PDF file sent to printer successfully")
                }
            }

            return true
        }
    }

    static func sendImageToPrinter() {

        let graphicsUtil = self.zebraPrinter!.getGraphicsUtil()
        let result = self.printPDF(graphicsUtil: graphicsUtil!)
        self.connection!.close()
        DispatchQueue.main.async {
            self.hud?.hide(true)
            if result == true {
                completionHandler?(result, "")
            }
        }
    }

    static func printPDF(graphicsUtil: GraphicsUtil) -> Bool {

        let pdfURL = URL(fileURLWithPath: self.pdfPath)
        let pdf = CGPDFDocument(pdfURL as CFURL)
        if pdf == nil {
            DispatchQueue.main.async {
                SVProgressHUD.showError(withStatus: "Could not retrieve PDF document.")
            }
            return false
        }
        else {
            let nPages = pdf?.numberOfPages ?? 0
            var success = false

            for pageNum in 1...nPages {
                let image = self.imageFrom(pdf: pdf!, pageNo: pageNum)
                if image == nil {
                    DispatchQueue.main.async {
                        SVProgressHUD.showError(withStatus: "Could not render PDF document.")
                    }
                    success = false
                    break
                }

                /*
                DispatchQueue.main.async {
                    let imageViewerVC = UIViewController.getViewController(storyboardName: "Secondary", storyboardID: "ImageViewerVC") as! ImageViewerVC
                    imageViewerVC.image = image
                    self.present(imageViewerVC, animated: true, completion: nil)
                }*/

                do {
                    try graphicsUtil.print(image!.cgImage, atX: 0, atY: 0, withWidth: -1, withHeight: -1, andIsInsideFormat: false)
                    success = true
                }
                catch let error {
                    DispatchQueue.main.async {
                        SVProgressHUD.showError(withStatus: error.localizedDescription)
                    }
                    success = false
                    break
                }
            }

            if success == true {
                DispatchQueue.main.async {
                    SVProgressHUD.showSuccess(withStatus: "Image sent to printer successfully")
                }
            }

            return true
        }
    }

    static func imageFrom(pdf: CGPDFDocument, pageNo: Int) -> UIImage? {

        guard let page = pdf.page(at: pageNo) else {return nil}
        let rect = page.getBoxRect(CGPDFBox.artBox)
        var resultingImage: UIImage?

        UIGraphicsBeginImageContext(rect.size)

        let context = UIGraphicsGetCurrentContext()
        let rgb = CGColorSpaceCreateDeviceRGB()
        let fillColors: [CGFloat] = [1,1,1,1]

        let color = CGColor(colorSpace: rgb, components: fillColors)
        context?.setFillColor(color!)
        context?.fill(rect)

        context?.translateBy(x: 0.0, y: rect.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)

        context?.saveGState()

        let pdfTransform = page.getDrawingTransform(CGPDFBox.cropBox, rect: rect, rotate: 0, preserveAspectRatio: true)
        context?.concatenate(pdfTransform)
        context?.drawPDFPage(page)
        context?.restoreGState()
        resultingImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return resultingImage
    }
}
