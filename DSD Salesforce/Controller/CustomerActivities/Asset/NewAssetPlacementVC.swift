//
//  NewAssetPlacementVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/16/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class NewAssetPlacementVC: AssetAddBaseVC {

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var searchCloseButton: UIButton!
    @IBOutlet weak var searchViewRightMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var assetTableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var noDataRightLabel: UILabel!
    @IBOutlet weak var centerView: UIView!

    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var termsTextView: YYTextView!
    @IBOutlet weak var agreedNameText: AnimatableTextField!
    @IBOutlet weak var signatureButton: AnimatableButton!
    @IBOutlet weak var webView: UIWebView!

    let globalInfo = GlobalInfo.shared
    var mainVC: MainVC!
    var customerDetail: CustomerDetail!
    var isSearchExpanded = false

    var signatureImageName = ""
    var printEngine: PrintEngine!
    var pdfPath = ""
    var htmlContent = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        mainVC.setTitleBarText(title: "NEW ASSET PLACEMENT REQUEST")
        reload()
    }

    func initUI() {

        termsTextView.isEditable = false
        customerNameLabel.text = customerDetail.name ?? ""

        // search view
        searchText.delegate = self
        searchText.addTarget(self, action: #selector(AssetAddVC.onSearchTextDidChanged), for: .editingChanged)
        searchText.returnKeyType = .done

        let screenBounds = UIScreen.main.bounds
        let rightMargin = -1 * screenBounds.width * 11 / 16
        searchViewRightMarginConstraint.constant = rightMargin

        assetTableView.delegate = self
        assetTableView.dataSource = self
        assetTableView.delaysContentTouches = false
        assetTableView.estimatedRowHeight = 0;

        self.loadTermsOfPlacementData()
    }

    func reload() {

        equipmentArray.removeAll()
        // load mode
        let equipAssArray = EquipAss.getBy(context: globalInfo.managedObjectContext, chainNo: "0", custNo: "0")
        for equipAss in equipAssArray {
            let equipmentNo = equipAss.equipmentNo ?? ""
            let equipArray = Equipment.getBy(context: globalInfo.managedObjectContext, equipmentNo: equipmentNo)
            if equipArray.count > 0 {
                let firstEquipment = equipArray.first!
                let clonedEquipment = Equipment(context: globalInfo.managedObjectContext, forSave: false)
                clonedEquipment.updateBy(theSource: firstEquipment)
                equipmentArray.append(firstEquipment)
            }
        }
        if selectedEquipment == nil {
            selectedEquipment = equipmentArray.first
        }
        refreshAssets()
    }

    override func refreshAssets() {
        super.refreshAssets()
        assetTableView.reloadData()
        if equipmentArray.count == 0 {
            noDataLabel.isHidden = false
        }
        else {
            noDataLabel.isHidden = true
        }
    }

    override func onSelectedEquipment() {
        super.onSelectedEquipment()
        if selectedEquipment == nil {
            centerView.isHidden = true
            noDataRightLabel.isHidden = false
            return
        }
        else {
            centerView.isHidden = false
            noDataRightLabel.isHidden = true
            self.updateAgreedBy()
        }
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

    func loadTermsOfPlacementData() {

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

    func toggleSearchView(shouldExpand: Bool) {
        if shouldExpand == true {
            if isSearchExpanded == true {
                return
            }
            searchCloseButton.isHidden = false
            UIView.animate(withDuration: 1.0, animations: {
                self.searchViewRightMarginConstraint.constant = 0
            }) { (completed) in
                self.isSearchExpanded = true
            }
        }
        else {
            let screenBounds = UIScreen.main.bounds
            let rightMargin = -1 * screenBounds.width * 11 / 16
            if isSearchExpanded == false {
                return
            }
            searchCloseButton.isHidden = true
            UIView.animate(withDuration: 1.0, animations: {
                self.searchViewRightMarginConstraint.constant = rightMargin
            }) { (completed) in
                self.isSearchExpanded = false
                self.searchText.resignFirstResponder()
            }
        }
    }

    func onSearchTextDidChanged() {
        reload()
    }

    func doMakePdf() {

        let agreedByName = self.agreedNameText.text ?? ""

        printEngine = PrintEngine()

        let pdfName = Utils.getPDFFileName()
        let pdfPath = CommData.getFilePathAppended(byCacheDir: kPDFDirName+"/"+pdfName) ?? ""

        let signaturePath = CommData.getFilePathAppended(byCacheDir: signatureImageName) ?? ""
        printEngine.prepareTermsPrint(filePath: signaturePath, name: agreedByName, customerDetail: self.customerDetail, equipment: self.selectedEquipment!)
        printEngine.isForOnePage = false
        printEngine.createPDF(webView: webView, isDuplicated: false, path: pdfPath, type: kTermsPrint, shouldShowHUD: true) { (success) in
            self.pdfPath = self.printEngine.printPDFPath
            if success == true {
                NSLog("PDF creation success")
                /*
                 let pdfViewerVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "PDFViewerVC") as! PDFViewerVC
                 pdfViewerVC.pdfPath = pdfPath
                 self.present(pdfViewerVC, animated: true, completion: nil)*/
                self.selectedEquipment?.newPlacementDocPath = pdfPath
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

        let oldEquipNo = selectedEquipment?.equipmentNo ?? ""
        let equipNo = makeEquipNumber()

        let newEquipment = Equipment(context: globalInfo.managedObjectContext, forSave: true)
        newEquipment.updateBy(theSource: selectedEquipment!)
        newEquipment.equipmentNo = equipNo
        newEquipment.equipmentType = "N"

        let equipAss = EquipAss(context: globalInfo.managedObjectContext, forSave: true)
        equipAss.chainNo = customerDetail.chainNo
        equipAss.custNo = customerDetail.custNo
        equipAss.equipmentNo = equipNo
        equipAss.oldEquipmentNo = oldEquipNo
        GlobalInfo.saveCache()

        self.mainVC.popChild(containerView: self.mainVC.containerView)
    }

    @IBAction func onCloseSearch(_ sender: Any) {
        toggleSearchView(shouldExpand: false)
    }

    @IBAction func onSignature(_ sender: Any) {
        let signatureVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "SignatureVC") as! SignatureVC
        signatureVC.setDefaultModalPresentationStyle()
        signatureVC.dismissHandler = {signatureImage in
            let imagePath = CommData.getFilePathAppended(byCacheDir: kSignatureFileName) ?? ""
            UIImage.saveImageToLocal(image: signatureImage, filePath: imagePath)
            self.signatureImageName = kSignatureFileName
        }
        self.present(signatureVC, animated: true, completion: nil)
    }

    @IBAction func onDone(_ sender: Any) {
        if selectedEquipment == nil {
            Utils.showAlert(vc: self, title: "", message: "Please select Equipment Model", failed: false, customerName: "", leftString: "", middleString: "", rightString: "Ok", dismissHandler: nil)
        }
        else {
            // validation
            if agreedNameText.isEnabled == false {
                Utils.showAlert(vc: self, title: "", message: "Please read our terms and conditions and input name and sign", failed: false, customerName: "", leftString: "", middleString: "", rightString: "Ok", dismissHandler: nil)
                return
            }
            let agreedName = agreedNameText.text ?? ""
            if agreedName.isEmpty == true {
                Utils.showAlert(vc: self, title: "", message: "Please Input Agreed to Name", failed: false, customerName: "", leftString: "", middleString: "", rightString: "Ok", dismissHandler: nil)
                return
            }
            if signatureImageName.isEmpty == true {
                Utils.showAlert(vc: self, title: "", message: "Please Sign your signature", failed: false, customerName: "", leftString: "", middleString: "", rightString: "Ok", dismissHandler: nil)
                return
            }

            doMakePdf()
        }
    }

    @IBAction func onBack(_ sender: Any) {
        mainVC.popChild(containerView: mainVC.containerView)
    }

}

extension NewAssetPlacementVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return equipmentArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssetAddAssetCell", for: indexPath) as! AssetAddAssetCell
        cell.setupCell(parentVC: self, indexPath: indexPath)
        return cell
    }

}

extension NewAssetPlacementVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }

}

extension NewAssetPlacementVC: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        toggleSearchView(shouldExpand: true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {

    }
}

extension NewAssetPlacementVC: YYTextViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateAgreedBy()
    }
}
