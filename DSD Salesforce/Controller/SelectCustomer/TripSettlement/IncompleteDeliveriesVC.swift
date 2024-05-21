//
//  IncompleteDeliveriesVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 12/26/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import WebKit

class IncompleteInfo: NSObject {
    var customerDetail: CustomerDetail?
    var nReasonIdx = -1
    var nCases = 0
    var nUnits = 0
}

class IncompleteDeliveriesVC: UIViewController {

    @IBOutlet weak var doneButton: AnimatableButton!
    @IBOutlet weak var reasonCodeTableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    //@IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    let globalInfo = GlobalInfo.shared

    enum DismissOption {
        case completed
        case cancelled
    }
    var dismissHander: ((IncompleteDeliveriesVC, DismissOption)->())?

    var reasonDescTypeArray = [DescType]()
    var incompleteInfoArray = [IncompleteInfo]()
    var pdfTrxnNo: Int64 = 0
    var strPdfFileName = ""
    var printEngine: PrintEngine!
    var printWebView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
        initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }

    func initData() {

        // reason array
        reasonDescTypeArray = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "NOSERVRSN")

        // no reason array
        let dayNo = "\(Utils.getWeekday(date: Date()))"
        var customerArray = CustomerDetail.getScheduled(context: globalInfo.managedObjectContext, dayNo: dayNo, shouldExcludeCompleted: false)
        customerArray = customerArray.sorted(by: { (customerDetail1, customerDetail2) -> Bool in
            let seqNo1 = Int(customerDetail1.seqNo ?? "") ?? 0
            let seqNo2 = Int(customerDetail2.seqNo ?? "") ?? 0
            let periodNo1 = Int(customerDetail1.periodNo ?? "") ?? 0
            let periodNo2 = Int(customerDetail2.periodNo ?? "") ?? 0
            let deliveryDate1 = customerDetail1.deliveryDate ?? ""
            let deliveryDate2 = customerDetail2.deliveryDate ?? ""

            if deliveryDate1 != deliveryDate2 {
                return deliveryDate1 < deliveryDate2
            }
            else {
                if periodNo1 != periodNo2 {
                    return periodNo1 < periodNo2
                }
                else {
                    return seqNo1 < seqNo2
                }
            }
        })
        for customerDetail in customerArray {
            if customerDetail.isCompleted == true {
                continue
            }
            let incompleteInfo = IncompleteInfo()
            incompleteInfo.customerDetail = customerDetail
            incompleteInfo.nReasonIdx = -1
            incompleteInfo.nCases = 0
            incompleteInfo.nUnits = 0

            let chainNo = customerDetail.chainNo ?? "0"
            let custNo = customerDetail.custNo ?? "0"
            let periodNo = customerDetail.periodNo ?? ""
            let presoldOrHeaderArray = PresoldOrHeader.getBy(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo, periodNo: periodNo)
            for presoldOrHeader in presoldOrHeaderArray {
                let detailFile = presoldOrHeader.detailFile ?? ""
                let presoldOrDetailArray = PresoldOrDetail.getBy(context: globalInfo.managedObjectContext, detailFile: detailFile)
                for presoldOrDetail in presoldOrDetailArray {
                    let itemNo = presoldOrDetail.itemNo ?? ""
                    let prodLocnArray = ProductLocn.getBy(context: globalInfo.managedObjectContext, itemNo: itemNo)
                    let firstProdLocn = prodLocnArray.first
                    let fullCase = firstProdLocn?.fullCase
                    if firstProdLocn != nil && fullCase != nil && fullCase?.uppercased() == "Y" {
                        incompleteInfo.nCases += presoldOrDetail.nOrderQty
                    }
                    else {
                        incompleteInfo.nUnits += presoldOrDetail.nOrderQty
                    }
                }
            }
            incompleteInfoArray.append(incompleteInfo)
        }
    }

    func initUI() {
        titleLabel.text = L10n.incompleteVisits()
        descLabel.text = L10n.TheFollowingCustomerVisitsAreNotYetCompleted()
        
        printWebView = UIWebView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        printWebView.isHidden = true
        view.addSubview(printWebView)

        noDataLabel.isHidden = true
        reasonCodeTableView.dataSource = self
        reasonCodeTableView.delegate = self
        checkIfCanProceed()
    }

    func checkIfCanProceed() {
        var isReasonEmpty = false
        for incompleteInfo in incompleteInfoArray {
            if incompleteInfo.nReasonIdx == -1 {
                isReasonEmpty = true
                break
            }
        }
        doneButton.isEnabled = !isReasonEmpty
    }

    func refreshData() {
        reasonCodeTableView.reloadData()
        if incompleteInfoArray.count == 0 {
            noDataLabel.isHidden = false
        }
        else {
            noDataLabel.isHidden = true
        }
        checkIfCanProceed()
    }

    func doCreatePDF() {
        let pdfDirPath = CommData.getFilePathAppended(byCacheDir: kPDFDirName)
        CommData.createDirectory(pdfDirPath)
        pdfTrxnNo = Date().getTimestamp()
        strPdfFileName = Utils.getPDFFileName()

        let document = generatePDFDocument()
        if document == nil {
            SVProgressHUD.showInfo(withStatus: "Failed in pdf generation")
            return
        }
        printEngine = PrintEngine()
        printEngine.isForOnePage = false
        let pdfPath = CommData.getFilePathAppended(byCacheDir: kPDFDirName+"/"+strPdfFileName) ?? ""
        printEngine.createPDF(webView: self.printWebView, isDuplicated: false, path: pdfPath, xmlDocument: document!, shouldShowHUD: true) { (completed) in
            if completed == true {
                self.dismiss(animated: true) {
                    self.dismissHander?(self, .completed)
                }
            }
            else {
                SVProgressHUD.showInfo(withStatus: "Failed in pdf generation")
                return
            }
        }
    }

    func generatePDFDocument() -> GDataXMLDocument? {
        let kDocumentMargin = "20"
        let rootElement = GDataXMLNode.element(withName: "Document")
        let pageSizeAttribute = GDataXMLNode.element(withName: "pageSize", stringValue: "A4")
        rootElement?.addAttribute(pageSizeAttribute)
        let marginLeftAttribute = GDataXMLNode.element(withName: "marginLeft", stringValue: kDocumentMargin)
        rootElement?.addAttribute(marginLeftAttribute)
        let marginRightAttribute = GDataXMLNode.element(withName: "marginRight", stringValue: kDocumentMargin)
        rootElement?.addAttribute(marginRightAttribute)
        let marginTopAttribute = GDataXMLNode.element(withName: "marginTop", stringValue: kDocumentMargin)
        rootElement?.addAttribute(marginTopAttribute)
        let marginBottomAttribute = GDataXMLNode.element(withName: "marginBottom", stringValue: kDocumentMargin)
        rootElement?.addAttribute(marginBottomAttribute)

        let headerNode = createPDFHeader()
        rootElement?.addChild(headerNode)

        let bodyNode = createPDFBody()
        rootElement?.addChild(bodyNode)

        let document = GDataXMLDocument(rootElement: rootElement)
        return document
    }

    func createPDFHeader() -> GDataXMLNode? {
        let tableElement = GDataXMLNode.element(withName: "Table")
        tableElement?.addAttribute(GDataXMLNode.element(withName: "columnCount", stringValue: "3"))
        let columnWeightArray = ["1", "1", "1"]
        for (index, columnWeight) in columnWeightArray.enumerated() {
            tableElement?.addAttribute(GDataXMLNode.element(withName: "column\(index+1)Weight", stringValue: columnWeight))
        }

        // logo cell
        var cellElement = GDataXMLNode.element(withName: "Cell")
        cellElement?.addAttribute(GDataXMLNode.element(withName: "horzAlignment", stringValue: "center"))
        let companyLogoPath = CommData.getFilePathAppended(byCacheDir: kReportsDirName+"/"+kCompanyLogoFileName) ?? ""
        if CommData.isExistingFile(atPath: companyLogoPath) == true {
            if let image = UIImage.loadImageFromLocal(filePath: companyLogoPath) {
                let imageData = image.jpegData(compressionQuality: 1.0)
                var imageBase64String = imageData?.base64EncodedString() ?? ""
                imageBase64String = "data:image/jpg;base64," + imageBase64String
                let imageElement = GDataXMLNode.element(withName: "Image", stringValue: imageBase64String)
                imageElement?.addAttribute(GDataXMLNode.element(withName: "width", stringValue: "120"))
                imageElement?.addAttribute(GDataXMLNode.element(withName: "height", stringValue: "120"))
                cellElement?.addChild(imageElement!)
            }
            else {
                let phraseElement = GDataXMLNode.element(withName: "Phrase", stringValue: "No Logo File")
                phraseElement?.addAttribute(GDataXMLNode.element(withName: "size", stringValue: "18"))
                phraseElement?.addAttribute(GDataXMLNode.element(withName: "type", stringValue: "bold"))
                cellElement?.addChild(phraseElement!)
            }
        }
        else {
            let phraseElement = GDataXMLNode.element(withName: "Phrase", stringValue: "No Logo File")
            phraseElement?.addAttribute(GDataXMLNode.element(withName: "size", stringValue: "18"))
            phraseElement?.addAttribute(GDataXMLNode.element(withName: "type", stringValue: "bold"))
            cellElement?.addChild(phraseElement!)
        }
        tableElement?.addChild(cellElement!)

        // trip number, date, time, user name
        cellElement = GDataXMLNode.element(withName: "Cell")
        let infoTableElement = GDataXMLNode.element(withName: "Table")

        var infoRowArray = [String]()
        let tripNumber = globalInfo.routeControl?.trip ?? ""
        infoRowArray.append("Trip Number: " + tripNumber)
        let now = Date()
        let dateString = now.toDateString(format: "dd/MM/yy") ?? ""
        infoRowArray.append("Date: " + dateString)
        let timeString = now.toDateString(format: "HH:mm") ?? ""
        infoRowArray.append("Time: " + timeString)
        let userName = globalInfo.routeControl?.userName ?? ""
        infoRowArray.append("User Name: " + userName)
        let route = globalInfo.routeControl?.routeNumber ?? ""
        infoRowArray.append("Route #: " + route)
        let vehicleNumber = globalInfo.routeControl?.vehicleNumber ?? ""
        infoRowArray.append("Vehicle #: " + vehicleNumber)
        let transactionNo = "\(pdfTrxnNo)"
        infoRowArray.append("Transaction #: " + transactionNo)

        for infoRow in infoRowArray {
            let infoCellElement = GDataXMLNode.element(withName: "Cell")
            let phraseElement = GDataXMLNode.element(withName: "Phrase", stringValue: infoRow)
            phraseElement?.addAttribute(GDataXMLNode.element(withName: "size", stringValue: "12"))
            infoCellElement?.addChild(phraseElement)
            infoTableElement?.addChild(infoCellElement)
        }
        cellElement?.addChild(infoTableElement!)
        tableElement?.addChild(cellElement!)

        // document no
        cellElement = GDataXMLNode.element(withName: "Cell")
        var documentName = ""
        if strPdfFileName.length > 4 {
            documentName = strPdfFileName.subString(startIndex: 0, length: strPdfFileName.length-4)
        }
        let phraseElement = GDataXMLNode.element(withName: "Phrase", stringValue: "Document #: " + documentName)
        phraseElement?.addAttribute(GDataXMLNode.element(withName: "size", stringValue: "12"))
        cellElement?.addChild(phraseElement!)
        cellElement?.addAttribute(GDataXMLNode.element(withName: "horzAlignment", stringValue: "center"))

        tableElement?.addChild(cellElement!)

        return tableElement
    }

    func createPDFBody() -> GDataXMLNode? {
        let tableElement = GDataXMLNode.element(withName: "Table")
        tableElement?.addAttribute(GDataXMLNode.element(withName: "columnCount", stringValue: "4"))
        let columnWeightArray = ["2","3","4","2"]
        for (index, columnWeight) in columnWeightArray.enumerated() {
            tableElement?.addAttribute(GDataXMLNode.element(withName: "column\(index+1)Weight", stringValue: columnWeight))
        }

        // title cell
        var cellElement = GDataXMLNode.element(withName: "Cell")
        cellElement?.addAttribute(GDataXMLNode.element(withName: "horzAlignment", stringValue: "center"))
        cellElement?.addAttribute(GDataXMLNode.element(withName: "span", stringValue: "4"))
        cellElement?.addAttribute(GDataXMLNode.element(withName: "paddingTop", stringValue: "25"))
        cellElement?.addAttribute(GDataXMLNode.element(withName: "paddingBottom", stringValue: "5"))
        var phraseElement = GDataXMLNode.element(withName: "Phrase", stringValue: "Undelivered Customers Report")
        phraseElement?.addAttribute(GDataXMLNode.element(withName: "size", stringValue: "18"))
        phraseElement?.addAttribute(GDataXMLNode.element(withName: "type", stringValue: "bold"))
        cellElement?.addChild(phraseElement!)
        tableElement?.addChild(cellElement!)

        // headers
        let headerTitleArray = ["Customer Number", "Customer Name", "Ship To Address", "Undelivered Reason"]
        for headerTitle in headerTitleArray {
            cellElement = GDataXMLNode.element(withName: "Cell")
            phraseElement = GDataXMLNode.element(withName: "Phrase", stringValue: headerTitle)
            phraseElement?.addAttribute(GDataXMLNode.element(withName: "size", stringValue: "12"))
            phraseElement?.addAttribute(GDataXMLNode.element(withName: "type", stringValue: "bold"))
            cellElement?.addChild(phraseElement!)
            tableElement?.addChild(cellElement!)
        }

        // values
        for info in incompleteInfoArray {
            var valueArray = [String]()
            let custNo = info.customerDetail?.custNo ?? ""
            let custName = info.customerDetail?.name ?? ""
            var address = info.customerDetail?.address1 ?? ""
            let address2 = info.customerDetail?.address2 ?? ""
            if address2.length > 0 {
                if address.length > 0 {
                    address += ", "
                }
                address += address2
            }
            let city = info.customerDetail?.city ?? ""
            if city.length > 0 {
                if address.length > 0 {
                    address += ", "
                }
                address += city
            }
            let reasonDesc = reasonDescTypeArray[info.nReasonIdx].desc ?? ""
            valueArray = [custNo, custName, address, reasonDesc]
            for value in valueArray {
                cellElement = GDataXMLNode.element(withName: "Cell")
                phraseElement = GDataXMLNode.element(withName: "Phrase", stringValue: value)
                phraseElement?.addAttribute(GDataXMLNode.element(withName: "size", stringValue: "12"))
                cellElement?.addChild(phraseElement!)
                tableElement?.addChild(cellElement!)
            }
        }
        return tableElement
    }

    @IBAction func onReturn(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHander?(self, .cancelled)
        }
    }

    @IBAction func onDone(_ sender: Any) {

        // should make and upload service
        var trxnDate = Date()
        for incompleteInfo in incompleteInfoArray {
            let customerDetail = incompleteInfo.customerDetail
            let chainNo = customerDetail?.chainNo ?? ""
            let custNo = customerDetail?.custNo ?? ""
            let reason = reasonDescTypeArray[incompleteInfo.nReasonIdx].numericKey ?? "0"
            trxnDate = trxnDate.addingTimeInterval(0.001)
            let _ = Visit.make(chainNo: chainNo, custNo: custNo, docType: "VIS", date: trxnDate, customerDetail: customerDetail!, reference: reason)
            let _ = UploadService.make(chainNo: chainNo, custNo: custNo, docType: "SERV", date: trxnDate, reason: reason, done: "0")
        }
        GlobalInfo.saveCache()

        doCreatePDF()
    }

}

extension IncompleteDeliveriesVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return incompleteInfoArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IncompleteDeliveryCell", for: indexPath) as! IncompleteDeliveryCell
        cell.setupCell(parentVC: self, indexPath: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }

}
