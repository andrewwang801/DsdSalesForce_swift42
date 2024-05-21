//
//  CollectionsBalancingVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/24/19.
//  Copyright © 2019 iOS Developer. All rights reserved.
//

import UIKit

class CollectionsBalancingVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var returnButton: AnimatableButton!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var titleLabel: UILabel!
    
    let globalInfo = GlobalInfo.shared
    var uarPaymentArray = [[UARPayment]]()

    var printEngine: PrintEngine!
    var pdfPath = ""
    var pdfFileName = ""

    enum DismissOption {
        case done
    }

    var dismissHandler: ((CollectionsBalancingVC) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
        initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshTableView()
    }

    func initData() {
        // load all uar remainings
        var payments = UARPayment.getAll(context: globalInfo.managedObjectContext)
        payments = payments.sorted(by: { (payment1, payment2) -> Bool in
            let trxnNo1 = payment1.trxnNo ?? ""
            let trxnNo2 = payment2.trxnNo ?? ""
            return trxnNo1 < trxnNo2
        })

        uarPaymentArray.removeAll()
        var cashGroup = [UARPayment]()
        var chequeGroup = [UARPayment]()
        var cardGroup = [UARPayment]()
        for payment in payments {
            let paymentType = payment.paymentType ?? ""
            if paymentType == "\(kCollectionCash)" {
                cashGroup.append(payment)
            }
            if paymentType == "\(kCollectionCheque)" {
                chequeGroup.append(payment)
            }
            if paymentType == "\(kCollectionCard)" {
                cardGroup.append(payment)
            }
        }
        uarPaymentArray.append(contentsOf: [cashGroup, chequeGroup, cardGroup])
    }

    func initUI() {
        titleLabel.text = L10n.collectionsBalancing()
        returnButton.setTitleForAllState(title: L10n.return())
        
        tableView.dataSource = self
        tableView.delegate = self
        noDataLabel.isHidden = true
    }

    func refreshTableView() {
        tableView.reloadData()
    }

    func doMakePdf() {

        printEngine = PrintEngine()

        let pdfFileName = Utils.getPDFFileName()
        let pdfPath = CommData.getFilePathAppended(byCacheDir: kPDFDirName+"/"+pdfFileName) ?? ""

        var docNo = ""
        if pdfFileName.length > 4 {
            docNo = pdfFileName.subString(startIndex: 0, length: pdfFileName.length-4)
        }
        else {
            docNo = pdfFileName
        }

        printEngine.prepareCollectionPrint(uarPaymentArray: uarPaymentArray, docNo: docNo)
        printEngine.isForOnePage = true

        printEngine.createPDF(webView: webView, isDuplicated: false, path: pdfPath, type: kCollectionConfirmPrint, shouldShowHUD: true) { (success) in
            if success == true {
                self.pdfFileName = pdfFileName
                self.pdfPath = self.printEngine.printPDFPath
                self.onPDFCompleted(success: success, pdfPath: self.pdfPath)
            }
        }
    }

    func onPDFCompleted(success: Bool, pdfPath: String) {

        if success == true {
            self.pdfPath = pdfPath
            NSLog("PDF creation success")

            /*
            let pdfViewerVC = UIViewController.getViewController(storyboardName: "Misc", storyboardID: "PDFViewerVC") as! PDFViewerVC
            pdfViewerVC.pdfPath = pdfPath
            self.present(pdfViewerVC, animated: true, completion: nil)*/

            self.doFinalize()
            /*
            if isCreatePdfForPrint == false {
                self.doFinalize()
            }
            else {
                if pdfPath != "" {
                    ZebraPrintEngine.tryPrint(vc: self, pdfPath: pdfPath, completionHandler: { success, message in
                        if success == true {
                            self.isPrinted = true
                        }
                    })
                }
            }*/
        }
        else {
            NSLog("PDF creation failed")
        }
    }

    func doFinalize() {
        // save pdf file name
        Utils.setStringSetting(key: kCollectionsBalancingPDFNameKey, value: self.pdfFileName)
        self.dismiss(animated: true) {
            self.dismissHandler?(self)
        }
    }

    @IBAction func onReturn(_ sender: Any) {
        doMakePdf()
    }
}

extension CollectionsBalancingVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uarPaymentArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionsBalancingPaymentCell", for: indexPath) as! CollectionsBalancingPaymentCell
        cell.setupCell(parentVC: self, indexPath: indexPath)
        return cell
    }

}

extension CollectionsBalancingVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

}

