//
//  AddMessageVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 12/25/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable
import QBImagePickerController

class AddMessageVC: UIViewController {

    @IBOutlet weak var messageTypeButton: AnimatableButton!
    @IBOutlet weak var messageNoteTextView: AnimatableTextView!
    @IBOutlet weak var attachmentButton: AnimatableButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageTypeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var attachmentLabel: UILabel!
    @IBOutlet weak var backButton: AnimatableButton!
    @IBOutlet weak var addButton: AnimatableButton!
    
    enum DismissOption {
        case back
        case add
    }

    let globalInfo = GlobalInfo.shared
    var customerDetail: CustomerDetail!
    var dismissHandler: ((DismissOption) -> ())?
    var messageTypeDropDown = DropDown()
    var messageTypeDescTypeArray = [DescType]()

    var selectedMessageType: DescType? {
        didSet {
            let typeName = selectedMessageType?.desc ?? ""
            messageTypeButton.setTitleForAllState(title: typeName)
        }
    }

    var attachmentFileNameArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
        initUI()

        selectedMessageType = nil
        messageNoteTextView.text = ""
        updateAttachmentButton()
    }

    func updateAttachmentButton() {
        let attachCount = attachmentFileNameArray.count
        if attachCount == 0 {
            attachmentButton.setTitleForAllState(title: "No attachments")
        }
        else {
            if attachCount == 1 {
                attachmentButton.setTitleForAllState(title: "\(attachCount) attachment")
            }
            else {
                attachmentButton.setTitleForAllState(title: "\(attachCount) attachments")
            }
        }
    }

    func initData() {
        messageTypeDescTypeArray = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "NOTETYPE")
        messageTypeDescTypeArray = messageTypeDescTypeArray.filter({ (descType) -> Bool in
            let numericKey = descType.numericKey ?? ""
            if numericKey == "99" {
                return false
            }
            else {
                return true
            }
        })
    }

    func initUI() {
        titleLabel.text = L10n.addNewMessage()
        messageLabel.text = L10n.Message()
        messageTypeLabel.text = L10n.messageType()
        attachmentLabel.text = L10n.attachment()
        backButton.setTitleForAllState(title: L10n.Back())
        addButton.setTitleForAllState(title: L10n.Add())
        
        setupMessageTypeDropDown()
    }

    func setupMessageTypeDropDown() {
        messageTypeDropDown.cellHeight = messageTypeButton.bounds.height
        messageTypeDropDown.anchorView = messageTypeButton
        messageTypeDropDown.bottomOffset = CGPoint(x: 0, y: messageTypeButton.bounds.height)
        messageTypeDropDown.backgroundColor = UIColor.white
        messageTypeDropDown.textFont = messageTypeButton.titleLabel!.font

        let messageTypeStringArray = messageTypeDescTypeArray.map({ (descType) -> String in
            return descType.desc ?? ""
        })
        messageTypeDropDown.dataSource = messageTypeStringArray
        messageTypeDropDown.cellNib = UINib(nibName: "GeneralDropDownCell", bundle: nil)
        messageTypeDropDown.customCellConfiguration = {_index, item, cell in
        }
        messageTypeDropDown.selectionAction = { index, item in
            self.selectedMessageType = self.messageTypeDescTypeArray[index]
        }
    }
    
    @IBAction func onMessageType(_ sender: Any) {
        messageTypeDropDown.show()
    }

    @IBAction func onAttachment(_ sender: Any) {

        let picker = QBImagePickerController()
        picker.maximumNumberOfSelection = UInt(kMessageAttachmentChoosePhotoCount)
        picker.prompt = "Select the images(up to \(picker.maximumNumberOfSelection)) you want to add!"
        picker.showsNumberOfSelectedAssets = true

        picker.delegate = self
        picker.allowsMultipleSelection = true
        picker.assetCollectionSubtypes = [PHAssetCollectionSubtype.smartAlbumUserLibrary.rawValue, PHAssetCollectionSubtype.albumMyPhotoStream.rawValue, PHAssetCollectionSubtype.smartAlbumPanoramas.rawValue, PHAssetCollectionSubtype.smartAlbumVideos.rawValue, PHAssetCollectionSubtype.smartAlbumBursts.rawValue]
        picker.mediaType = .image
        picker.numberOfColumnsInLandscape = 6
        picker.setDefaultModalPresentationStyle()
        self.present(picker, animated: true, completion: nil)
    }

    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?(.back)
        }
    }

    @IBAction func onAdd(_ sender: Any) {

        if selectedMessageType == nil {
            SVProgressHUD.showInfo(withStatus: "Please select a message type")
            return
        }

        let uploadManager = globalInfo.uploadManager
        let chainNo = customerDetail.chainNo ?? ""
        let custNo = customerDetail.custNo ?? ""
        let trip = globalInfo.routeControl?.trip ?? ""

        var fileTransactionArray = [FileTransaction]()
        var transactionArray = [UTransaction]()

        // upload photo
        let fileTrxnDate = Date()
        let fileTrxnDateString = fileTrxnDate.toDateString(format: kTightJustDateFormat) ?? ""
        let fileTrxnTimeString = fileTrxnDate.toDateString(format: kTightJustTimeFormat) ?? ""

        var zipFilePathArray = [String]()

        for fileName in attachmentFileNameArray {
            var docNo = ""
            if fileName.length > 4 {
                docNo = fileName.subString(startIndex: 0, length: fileName.length-4)
            }
            else {
                docNo = fileName
            }
            let fileTransaction = FileTransaction.make(chainNo: chainNo, custNo: custNo, docType: "FARC", fileTrxnDate: fileTrxnDate, trip: trip, trnxDate: Date(), fileDocNo: docNo, fileShortDesc: "ATTACHMENT", fileLongDesc: "MESSAGE ATTACHMENT", fileCreateDate: fileTrxnDateString, fileCreateTime: fileTrxnTimeString, fileName: fileName)
            fileTransactionArray.append(fileTransaction)
            transactionArray.append(fileTransaction.makeTransaction())

            // file copy
            uploadManager?.scheduleUpload(localFileName: fileName, remoteFileName: fileTransaction.fileFileName, uploadItemType: .normalCustomerFile)
        }

        // UCustNote
        var noteTypeString = selectedMessageType?.numericKey ?? ""
        let messageTypeDesc = selectedMessageType?.desc ?? ""
        if messageTypeDesc == "Post Visit Task" {
            noteTypeString = "99"
        }
        let messageNote = messageNoteTextView.text ?? ""

        let attachmentCount = attachmentFileNameArray.count
        let attachmentString = attachmentFileNameArray.joined(separator: ",")
        let uCustNote = UCustNote.make(chainNo: chainNo, custNo: custNo, docType: "NOTE", date: fileTrxnDate, noteType: noteTypeString, note: messageNote, attachmentString: attachmentString)
        transactionArray.append(uCustNote.makeTransaction())

        // GPS
        let gpsLog = GPSLog.make(chainNo: chainNo, custNo: custNo, docType: "GPS", date: Date(), location: globalInfo.getCurrentLocation())
        let gpsLogTransaction = gpsLog.makeTransaction()
        transactionArray.append(gpsLogTransaction)

        // files
        // cust note
        let uCustNotePath = UCustNote.saveToXML(uCustNoteArray: [uCustNote])
        if uCustNotePath.isEmpty == false {
            zipFilePathArray.append(uCustNotePath)
        }

        // file trasaction
        let fileTransactionPath = FileTransaction.saveToXML(fileTransactionArray: fileTransactionArray)
        if fileTransactionPath.isEmpty == false {
            zipFilePathArray.append(fileTransactionPath)
        }

        // gps
        let gpsLogPath = GPSLog.saveToXML(gpsLogArray: [gpsLog])
        zipFilePathArray.append(gpsLogPath)

        // transaction
        let transactionPath = UTransaction.saveToXML(transactionArray: transactionArray, shouldIncludeLog: true)
        zipFilePathArray.append(transactionPath)

        uploadManager?.zipAndScheduleUpload(filePathArray: zipFilePathArray)

        // add new cust note
        let now = Date()
        let newCustNote = CustNote(context: globalInfo.managedObjectContext, forSave: true)
        newCustNote.chainNo = customerDetail.chainNo ?? "0"
        newCustNote.custNo = customerDetail.custNo ?? "0"
        newCustNote.noteType = noteTypeString
        newCustNote.noteDate = now.toDateString(format: kTightJustDateFormat) ?? ""
        newCustNote.noteTime = now.toDateString(format: "HHmm") ?? ""
        newCustNote.createdby = globalInfo.routeControl?.userName ?? ""
        newCustNote.note = messageNote
        newCustNote.noteId = "\(now.getTimestamp())"
        newCustNote.attachment = "\(attachmentCount)"
        newCustNote.fileNames = ""
        newCustNote.fileTypes = ""

        GlobalInfo.saveCache()

        self.dismiss(animated: true) {
            self.dismissHandler?(.add)
        }
    }

}

// MARK: -QBImagePickerControllerDelegate
extension AddMessageVC: QBImagePickerControllerDelegate {

    func qb_imagePickerController(_ imagePickerController: QBImagePickerController!, didFinishPickingAssets assets: [Any]!) {
        for asset in assets {
            let phAsset = asset as! PHAsset
            guard let convertedImage = UIImage.loadImageFromPHAsset(asset: phAsset) else {continue}
            let fileName = (Date().toDateString(format: "yyyyMMddHHmmssSSS") ?? "") + ".jpg"
            let filePath = CommData.getFilePathAppended(byCacheDir: fileName) ?? ""
            UIImage.saveImageToLocal(image: convertedImage, filePath: filePath)
            attachmentFileNameArray.append(fileName)
        }
        DispatchQueue.main.async {
            if assets.count > self.attachmentFileNameArray.count {
                Utils.showAlert(vc: self, title: "", message: L10n.failedInAddingSomePhotos(), failed: false, customerName: "", leftString: "", middleString: L10n.ok(), rightString: "", dismissHandler: nil)
            }
            else {
                SVProgressHUD.showSuccess(withStatus: L10n.addedSelectedPhotosSuccessfully())
            }
        }
        imagePickerController.dismiss(animated: true, completion: {
            self.updateAttachmentButton()
        })
    }

    func qb_imagePickerControllerDidCancel(_ imagePickerController: QBImagePickerController!) {
        imagePickerController.dismiss(animated: true, completion: nil)
    }

}
