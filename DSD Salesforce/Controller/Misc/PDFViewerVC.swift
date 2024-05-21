//
//  PDFViewerVC.swift
//  PropertyManagement
//
//  Created by iOS Developer on 7/12/17.
//  Copyright © 2017 iOS Developer. All rights reserved.
//
import UIKit
import MessageUI

class PDFViewerVC: UIViewController {

    enum DismissOption {
        case close
        case print
    }

    var pdfPath: String = ""
    var dismissHandler: ((DismissOption) -> ())?

    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let url = URL(fileURLWithPath: pdfPath)
        let urlRequest = URLRequest(url: url)
        webView.loadRequest(urlRequest)
    }

    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?(.close)
        }
        //self.dismiss(animated: true, completion: nil)
    }

    /*
    @IBAction func onPrint(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?(.print)
        }
    }*/

}
