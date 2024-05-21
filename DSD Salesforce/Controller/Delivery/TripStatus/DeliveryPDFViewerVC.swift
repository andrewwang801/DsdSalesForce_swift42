//
//  DeliveryPDFViewerVC.swift
//  DSDConnect
//
//  Created by iOS Developer on 3/17/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class DeliveryPDFViewerVC: UIViewController {

    @IBOutlet weak var webView: UIWebView!

    var hud: MBProgressHUD?
    var pdfURL: URL!
    var data: Data!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let urlRequest = URLRequest(url: pdfURL)
        webView.loadRequest(urlRequest)
        //let url = URL(dataRepresentation: data, relativeTo: nil)
        //webView.load(data, mimeType: "application/pdf", textEncodingName: "UTF-8", baseURL: url!)

    }

    @IBAction func onClose(_ sender: Any) {
        webView.stopLoading()
        self.dismiss(animated: true, completion: nil)
    }
}

extension DeliveryPDFViewerVC: UIWebViewDelegate {

    func webViewDidStartLoad(_ webView: UIWebView) {
        hud?.hide(true)
        hud = MBProgressHUD.showAdded(to: webView, animated: true)
        NSLog("Web view loading started")
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        hud?.hide(true)
        NSLog("Web view loading error: \(error.localizedDescription)")
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        hud?.hide(true)
        NSLog("Web view loading finished")
    }

}

