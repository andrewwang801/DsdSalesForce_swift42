//
//  MessageBoardVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/16/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class MessageBoardVC: UIViewController {

    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var addNewMessageLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    let globalInfo = GlobalInfo.shared
    var mainVC: MainVC!
    var customerDetail: CustomerDetail!
    var custNoteArray = [CustNote]()
    // var messageArray = [Message]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        mainVC.setTitleBarText(title: "MESSAGE BOARD")
        reloadMessages()
    }

    func initUI() {
        addNewMessageLabel.text = L10n.addNewMessage()
        doneButton.setTitleForAllState(title: L10n.done())
        
        // search view
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.delaysContentTouches = false

        noDataLabel.isHidden = true
    }

    func reloadMessages() {
        let chainNo = customerDetail.chainNo ?? "0"
        let custNo = customerDetail.custNo ?? "0"
        custNoteArray = CustNote.getBy(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo)

        var loadCustNoteArray = [CustNote]()
        for custNote in custNoteArray {
            let attachment = custNote.attachment ?? ""
            if attachment == "" || attachment == "0" {
                continue
            }
            let fileNames = custNote.fileNames ?? ""
            let _ = custNote.fileTypes ?? ""

            if fileNames == "" {
                loadCustNoteArray.append(custNote)
            }
            else {
                let fileNameArray = fileNames.components(separatedBy: ",")
                for fileName in fileNameArray {
                    let filePath = CommData.getFilePathAppended(byDocumentDir: fileName) ?? ""
                    if CommData.isExistingFile(atPath: filePath) == false {
                        loadCustNoteArray.append(custNote)
                        break
                    }
                    if CommData.getFileSize(filePath) == 0 {
                        loadCustNoteArray.append(custNote)
                        break
                    }
                }
            }
        }

        if loadCustNoteArray.count == 0 {
            refreshMessages()
        }
        else {
            Utils.refreshTokenForGeneral { (success, message) in
                self.loadAttachmentsFromServer(custNoteArray: loadCustNoteArray)
            }
        }
    }

    func loadAttachmentsFromServer(custNoteArray: [CustNote]) {
        let userDefaults = UserDefaults.standard
        let strPinNumber = userDefaults.string(forKey: kDeliveryLoginPinNumberKey) ?? ""
        let strToken = userDefaults.string(forKey: kDeliveryLoginTokenKey) ?? ""
        let headers = ["X-Auth-Token": strToken]
        let baseURL = Utils.getBaseURL(pinNumber: strPinNumber)

        DispatchQueue.global().async {
            for custNote in custNoteArray {
                let noteId = custNote.noteId ?? ""
                var isCalling = true
                let methodName = "api/customer-note-attachments"
                APIManager.doNormalRequest(baseURL: baseURL, methodName: methodName, httpMethod: "GET", headers: headers, params: ["noteId":noteId], shouldShowHUD: true) { (response, message) in
                    if response != nil {
                        var fileNameArray = [String]()
                        var fileTypeArray = [String]()
                        if let attachmentJSONArray = JSON(data: response as! Data).array {
                            fileNameArray = attachmentJSONArray.map({ (json) -> String in
                                return json["fileName"].stringValue
                            })
                            fileTypeArray = attachmentJSONArray.map({ (json) -> String in
                                return json["fileType"].stringValue
                            })
                            custNote.fileNames = fileNameArray.joined(separator: ",")
                            custNote.fileTypes = fileTypeArray.joined(separator: ",")
                        }
                    }
                    isCalling = false
                }
                while isCalling == true {
                    Thread.sleep(forTimeInterval: 0.5)
                }
            }
            DispatchQueue.main.async {
                GlobalInfo.saveCache()
                self.refreshMessages()
            }
        }
    }

    func refreshMessages() {
        messageTableView.reloadData()
        if custNoteArray.count > 0 {
            noDataLabel.isHidden = true
        }
        else {
            noDataLabel.isHidden = false
        }
    }

    @IBAction func onAddNewMessage(_ sender: Any) {
        let addMessageVC = UIViewController.getViewController(storyboardName: "CustomerActivities", storyboardID: "AddMessageVC") as! AddMessageVC
        addMessageVC.customerDetail = customerDetail
        addMessageVC.setDefaultModalPresentationStyle()
        addMessageVC.dismissHandler = { dismissOption in
            self.reloadMessages()
        }
        self.present(addMessageVC, animated: true, completion: nil)
    }

    @IBAction func onDone(_ sender: Any) {
        mainVC.popChild(containerView: mainVC.containerView)
    }

    @IBAction func onBack(_ sender: Any) {
        mainVC.popChild(containerView: mainVC.containerView)
    }

}

extension MessageBoardVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return custNoteArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        cell.setupCell(parentVC: self, indexPath: indexPath)
        return cell
    }

}

extension MessageBoardVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}

