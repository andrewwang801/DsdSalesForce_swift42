//
//  TermsOfPlacementVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 8/1/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable
import SSZipArchive
import BNHtmlPdfKit

class TermsOfPlacementVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var termsTextView: YYTextView!
    @IBOutlet weak var agreedNameText: AnimatableTextField!
    @IBOutlet weak var signatureButton: AnimatableButton!
    @IBOutlet weak var webView: UIWebView!

    let globalInfo = GlobalInfo.shared
    var customerDetail: CustomerDetail!
    var equipment: Equipment?
    var signatureImageName = ""

    var printEngine: PrintEngine!

    var pdfPath = ""
    var htmlContent = ""

    enum DismissOption {
        case back
        case confirm
    }

    var dismissHandler: ((TermsOfPlacementVC, DismissOption) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
        loadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        updateAgreedBy()
    }

    func initUI() {
        termsTextView.isEditable = false
        customerNameLabel.text = customerDetail.name ?? ""
    }

    func loadData() {

        if globalInfo.termsText.isEmpty == true {
            globalInfo.termsText = Terms.loadFromXML() ?? ""
        }

        let text = NSMutableAttributedString(string:  globalInfo.termsText)
        text.yy_font = UIFont(name: "Roboto-Regular", size: 18.0)
        text.yy_color = kBlackTextColor
        text.yy_lineSpacing = 5.0
        text.yy_paragraphSpacing = 20.0

        termsTextView.attributedText = text
        termsTextView.delegate = self
    }

    func updateAgreedBy() {
        let contentLeftHeight = termsTextView.contentSize.height - termsTextView.contentOffset.y
        if contentLeftHeight - termsTextView.bounds.height < 5 {
            agreedNameText.isEnabled = true
            signatureButton.isEnabled = true
            agreedNameText.becomeFirstResponder()
        }
        else {
            agreedNameText.isEnabled = false
            signatureButton.isEnabled = false
        }
    }

    func doMakePdf() {

        let agreedByName = self.agreedNameText.text ?? ""

        printEngine = PrintEngine()

        let pdfName = Utils.getPDFFileName()
        let pdfPath = CommData.getFilePathAppended(byDocumentDir: kPDFDirName+"/"+pdfName) ?? ""

        let signaturePath = CommData.getFilePathAppended(byDocumentDir: signatureImageName) ?? ""
        printEngine.prepareTermsPrint(filePath: signaturePath, name: agreedByName, customerDetail: self.customerDetail, equipment: self.equipment!)
        printEngine.isForOnePage = false
        printEngine.createPDF(webView: webView, isDuplicated: false, path: pdfPath, type: kTermsPrint, shouldShowHUD: true) { (success) in
            self.pdfPath = self.printEngine.printPDFPath
            if success == true {
                NSLog("PDF creation success")
                /*
                let pdfViewerVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "PDFViewerVC") as! PDFViewerVC
                pdfViewerVC.pdfPath = pdfPath
                self.present(pdfViewerVC, animated: true, completion: nil)*/
                self.equipment?.newPlacementDocPath = pdfPath
                self.processConfirm()
            }
            else {
                NSLog("PDF creation failed")
            }
        }
    }

    func makeEquipNumber() -> String {
        var equipNumber = "9"
        let routeNumber = globalInfo.routeControl?.routeNumber ?? ""
        if routeNumber == "" {
            equipNumber += "000"
        }
        else if routeNumber.length == 1 {
            equipNumber += "00" + routeNumber
        }
        else if routeNumber.length == 2 {
            equipNumber += "0" + routeNumber
        }
        else {
            let lastEquipNumber = routeNumber.subString(startIndex: routeNumber.length-3, length: 3)
            equipNumber += lastEquipNumber
        }

        let now = Date()
        let y = now.toDateString(format: "yyyy") ?? ""
        let dayOfYear = now.dayOfYear
        let jjj = "\(dayOfYear)"

        let tripNumber = globalInfo.routeControl?.trip ?? ""
        let pdfSequenceNoKey = kPdfSequenceNoPrefix+tripNumber
        let pdfSequenceNo = Utils.getIntSetting(key: pdfSequenceNoKey)+1
        Utils.setIntSetting(key: pdfSequenceNoKey, value: pdfSequenceNo)

        let sss = "\(pdfSequenceNo)"
        equipNumber += y.subString(startIndex: 3, length: 1)
        if jjj.length == 0 {
            equipNumber += "000"
        }
        else if jjj.length == 1 {
            equipNumber += "00"+jjj
        }
        else if jjj.length == 2 {
            equipNumber += "0"+jjj
        }
        else {
            equipNumber += jjj.subString(startIndex: jjj.length-3, length: 3)
        }

        if sss.length == 0 {
            equipNumber += "00"
        }
        else if sss.length == 1 {
            equipNumber += "0"+sss
        }
        else {
            equipNumber += sss.subString(startIndex: sss.length-2, length: 2)
        }

        return equipNumber
    }

    func processConfirm() {

        let oldEquipNo = equipment?.equipmentNo ?? ""
        let equipNo = makeEquipNumber()

        let newEquipment = Equipment(context: globalInfo.managedObjectContext, forSave: true)
        newEquipment.updateBy(theSource: equipment!)
        newEquipment.equipmentNo = equipNo
        newEquipment.equipmentType = "N"

        let equipAss = EquipAss(context: globalInfo.managedObjectContext, forSave: true)
        equipAss.chainNo = customerDetail.chainNo
        equipAss.custNo = customerDetail.custNo
        equipAss.equipmentNo = equipNo
        equipAss.oldEquipmentNo = oldEquipNo
        GlobalInfo.saveCache()

        self.dismiss(animated: true) {
            self.dismissHandler?(self, .confirm)
        }
    }

    @IBAction func onSignature(_ sender: Any) {
        let signatureVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "SignatureVC") as! SignatureVC
        signatureVC.setDefaultModalPresentationStyle()
        signatureVC.dismissHandler = {signatureImage in
            let imagePath = CommData.getFilePathAppended(byDocumentDir: kSignatureFileName) ?? ""
            UIImage.saveImageToLocal(image: signatureImage, filePath: imagePath)
            self.signatureImageName = kSignatureFileName
        }
        self.present(signatureVC, animated: true, completion: nil)
    }

    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?(self, .back)
        }
    }

    @IBAction func onConfirm(_ sender: Any) {

        // validation
        if agreedNameText.isEnabled == false {
            Utils.showAlert(vc: self, title: "", message: L10n.pleaseReadOurTermsAndConditionsAndInputNameAndSign(), failed: false, customerName: "", leftString: "", middleString: "", rightString: L10n.ok(), dismissHandler: nil)
            return
        }
        let agreedName = agreedNameText.text ?? ""
        if agreedName.isEmpty == true {
            Utils.showAlert(vc: self, title: "", message: L10n.pleaseInputAgreedToName(), failed: false, customerName: "", leftString: "", middleString: "", rightString: L10n.ok(), dismissHandler: nil)
            return
        }
        if signatureImageName.isEmpty == true {
            Utils.showAlert(vc: self, title: "", message: L10n.pleaseSignYourSignature(), failed: false, customerName: "", leftString: "", middleString: "", rightString: L10n.ok(), dismissHandler: nil)
            return
        }
        
        doMakePdf()
    }

}

extension TermsOfPlacementVC: YYTextViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateAgreedBy()
    }
}
