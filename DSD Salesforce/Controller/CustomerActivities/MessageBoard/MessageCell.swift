//
//  MessageCell.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/16/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import SDWebImage

class MessageCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeDurationLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var bottomLine: UILabel!
    @IBOutlet weak var messageTypeLabel: UILabel!
    // @IBOutlet weak var attachmentLabel: UILabel!
    @IBOutlet weak var attachmentCV: UICollectionView!
    @IBOutlet weak var attachmentCVTopConstraint: NSLayoutConstraint!

    var parentVC: MessageBoardVC?
    var indexPath: IndexPath?
    var attachmentNameArray = [String]()
    var attachmentTypeArray = [String]()

    let kAttachmentCellHeight: CGFloat = 40.0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        //let tapMainViewGesture = UITapGestureRecognizer(target: self, action: #selector(MessageCell.onTapMainView))
        //mainView.addGestureRecognizer(tapMainViewGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {

    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {

        if animated == true {
            UIView.animate(withDuration: 1.0, animations: {
                if highlighted == true {
                    self.mainView.backgroundColor = kMessageCellSelectedColor
                }
                else {
                    self.mainView.backgroundColor = kMessageCellNormalColor
                }
            })
        }
        else {
            if highlighted == true {
                self.mainView.backgroundColor = kMessageCellSelectedColor
            }
            else {
                self.mainView.backgroundColor = kMessageCellNormalColor
            }
        }
    }

    func setupCell(parentVC: MessageBoardVC, indexPath: IndexPath) {
        self.parentVC = parentVC
        self.indexPath = indexPath

        // load attachment
        let index = indexPath.row
        let custNote = parentVC.custNoteArray[index]

        let fileNames = custNote.fileNames ?? ""
        let fileTypes = custNote.fileTypes ?? ""

        if fileNames == "" {
            attachmentNameArray = []
        }
        else {
            attachmentNameArray = fileNames.components(separatedBy: ",")
        }
        if fileTypes == "" {
            attachmentTypeArray = []
        }
        else {
            attachmentTypeArray = fileTypes.components(separatedBy: ",")
        }
        configCell()
    }

    func configCell() {

        let index = indexPath!.row
        let custNote = parentVC!.custNoteArray[index]
        selectionStyle = .none
        attachmentCV.backgroundColor = .clear
        attachmentCV.backgroundView?.backgroundColor = .clear

        let noteDate = Date.fromDateString(dateString: custNote.noteDate ?? "", format: kTightJustDateFormat)
        self.dateLabel.text = noteDate?.toDateString(format: "EEEE, d MMMM") ?? ""

        let noteTime = Date.fromDateString(dateString: custNote.noteTime ?? "", format: "HHmm")
        let noteTimeString = noteTime?.toDateString(format: "HH-mm a") ?? ""
        let createdby = custNote.createdby ?? ""

        self.timeDurationLabel.text = "at \(noteTimeString) by \(createdby)"
        self.messageLabel.text = custNote.note ?? ""

        let globalInfo = GlobalInfo.shared
        let noteType = custNote.noteType ?? ""
        let descType = DescType.getBy(context: globalInfo.managedObjectContext, descTypeID: "NOTETYPE".lowercased(), numericKey: noteType)
        messageTypeLabel.text = descType?.desc ?? ""

        if index == parentVC!.custNoteArray.count-1 {
            self.bottomLine.isHidden = true
        }
        else {
            self.bottomLine.isHidden = false
        }

        attachmentCV.dataSource = self
        attachmentCV.delegate = self

        refreshAttachmentCV()
    }

    func refreshAttachmentCV() {
        if attachmentTypeArray.count == 0 {
            attachmentCV.isHidden = true
            attachmentCVTopConstraint.constant = -1*kAttachmentCellHeight
        }
        else {
            attachmentCV.isHidden = false
            attachmentCVTopConstraint.constant = 10.0
        }
        attachmentCV.reloadData()
    }

    func onTapMainView() {

    }

}

extension MessageCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return attachmentTypeArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageAttachmentCell", for: indexPath) as! MessageAttachmentCell
        cell.backgroundView?.backgroundColor = .clear
        cell.backgroundColor = .clear

        let index = indexPath.row
        let attachmentType = attachmentTypeArray[index].lowercased()
        // let attachmentName = attachmentNameArray[index]

        var fileTypeImageName = ""
        if attachmentType == kAttachmentTypePDF {
            fileTypeImageName = "Attachment_PDF"
        }
        else if attachmentType != "" {
            fileTypeImageName = "Attachment_Image"
        }
        let fileTypeImage = UIImage(named: fileTypeImageName)
        cell.contentImageView.image = fileTypeImage
        // try to load the image from local
        /*
        let attachmentFilePath = CommData.getFilePathAppended(byCacheDir: attachmentFileName) ?? ""
        if let attachmentImage = UIImage.loadImageFromLocal(filePath: attachmentFilePath) {
            cell.contentImageView.image = attachmentImage
        }
        else {
            let noteIndex = self.indexPath!.row
            let custNote = parentVC!.custNoteArray[noteIndex]
            let noteId = custNote.noteId ?? ""

            let userDefaults = UserDefaults.standard
            let strPinNumber = userDefaults.string(forKey: kDeliveryLoginPinNumberKey) ?? ""
            //let strPinNumber = kDeliveryPinNumber
            let baseURL = Utils.getBaseURL(pinNumber: strPinNumber)
            //let strToken = userDefaults.string(forKey: kDeliveryLoginTokenKey) ?? ""
            let remoteImageURL = baseURL+"api/customer-note-attachments?noteId=\(noteId)"
            let url = URL(string: remoteImageURL)
            cell.contentImageView.sd_setImage(with: url, placeholderImage: nil, options: []) { (image, error, cacheType, url) in

            }
        }*/
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: kAttachmentCellHeight, height: kAttachmentCellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let custNote = parentVC!.custNoteArray[self.indexPath!.row]
        let noteId = custNote.noteId ?? ""
        let index = indexPath.row
        let attachmentType = attachmentTypeArray[index].lowercased()
        let attachmentName = attachmentNameArray[index]
        let attachmentPath = CommData.getFilePathAppended(byDocumentDir: noteId+"_"+attachmentName) ?? ""
        if CommData.isExistingFile(atPath: attachmentPath) == true {
            // show file content
            showFileContent(fileType: attachmentType, filePath: attachmentPath)
        }
        else {
            let userDefaults = UserDefaults.standard
            let strPinNumber = userDefaults.string(forKey: kDeliveryLoginPinNumberKey) ?? ""
            // let strToken = userDefaults.string(forKey: kDeliveryLoginTokenKey) ?? ""
            let baseURL = Utils.getBaseURL(pinNumber: strPinNumber)
            let strURL = baseURL + "api/customer-note-attachments/file?noteId=" + noteId + "&fileName=" + attachmentName
            APIManager.downloadMedia(sourceURL: strURL, downloadPath: attachmentPath) { (success, message) in
                if success == true {
                    self.showFileContent(fileType: attachmentType, filePath: attachmentPath)
                }
                else {
                    SVProgressHUD.showInfo(withStatus: "Attachment download failed.")
                }
            }
        }
    }

    func showFileContent(fileType: String, filePath: String) {

        if fileType == kAttachmentTypePDF {
            // open pdf
            Utils.launchPDF(vc: parentVC!, strPath: filePath)
        }
        else if fileType != "" {
            let image = UIImage.loadImageFromLocal(filePath: filePath)
            if image != nil {
                SVProgressHUD.showInfo(withStatus: "Can't open the attachment")
            }
            else {
                let imageViewerVC = UIViewController.getViewController(storyboardName: "Chat", storyboardID: "ImageViewerVC") as! ImageViewerVC
                imageViewerVC.setDefaultModalPresentationStyle()
                imageViewerVC.image = image
                parentVC?.present(imageViewerVC, animated: true, completion: nil)
            }
        }
    }
}
