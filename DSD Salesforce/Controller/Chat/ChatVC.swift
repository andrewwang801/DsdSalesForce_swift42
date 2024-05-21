//
//  ChatViewController.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/1/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import CoreTelephony
import SafariServices
import Quickblox
import MobileCoreServices
import TTTAttributedLabel
import AVKit

var messageTimeDateFormatter: DateFormatter {
    struct Static {
        static let instance : DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter
        }()
    }
    
    return Static.instance
}

class ChatVC: QMChatViewController, QMChatServiceDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, QMChatAttachmentServiceDelegate, QMChatConnectionDelegate, QMChatCellDelegate, QMDeferredQueueManagerDelegate, QMPlaceHolderTextViewPasteDelegate {
    
    @IBOutlet weak var separatorView: UIView!

    let maxCharactersNumber = 1024 // 0 - unlimited
    
    var failedDownloads: Set<String> = []
    var dialog: QBChatDialog!
    var willResignActiveBlock: AnyObject?
    var attachmentCellsMap: NSMapTable<AnyObject, AnyObject>!
    var detailedCells: Set<String> = []
    
    var typingTimer: Timer?
    var popoverController: UIPopoverController?

    var skipPagination = 0
    
    lazy var imagePickerViewController : UIImagePickerController = {
        let imagePickerViewController = UIImagePickerController()
        imagePickerViewController.delegate = self
        
        return imagePickerViewController
    }()
    
    var unreadMessages: [QBChatMessage]?

    var dismissHandler: ((QBChatDialog)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // top layout inset for collectionView
        //self.topContentAdditionalInset = self.navigationController!.navigationBar.frame.size.height + UIApplication.shared.statusBarFrame.size.height;
        
        view.backgroundColor = UIColor.white
        self.collectionView.backgroundColor = UIColor.clear

        UIApplication.shared.isStatusBarHidden = false

        if let currentUser:QBUUser = ServicesManager.instance().currentUser {
            self.senderID = currentUser.id
            self.senderDisplayName = currentUser.login
            
            ServicesManager.instance().chatService.addDelegate(self)
            ServicesManager.instance().chatService.chatAttachmentService.addDelegate(self)
            
            self.heightForSectionHeader = 40.0

            self.initChat()
            self.updateTitle()
            
            self.inputToolbar?.contentView?.backgroundColor = UIColor.white
            self.inputToolbar?.contentView?.textView?.placeHolder = L10n.Message()
            
            self.attachmentCellsMap = NSMapTable(keyOptions: NSPointerFunctions.Options.strongMemory, valueOptions: NSPointerFunctions.Options.weakMemory)
            
            if self.dialog.type == QBChatDialogType.private {
                
                self.dialog.onUserIsTyping = {
                    [weak self] (userID)-> Void in
                    
                    if ServicesManager.instance().currentUser.id == userID {
                        return
                    }
                    
                    self?.title = L10n.typing()
                }
                
                self.dialog.onUserStoppedTyping = {
                    [weak self] (userID)-> Void in
                    
                    if ServicesManager.instance().currentUser.id == userID {
                        return
                    }
                    
                    self?.updateTitle()
                }
            }
            
            // Retrieving messages
            let messagesCount = self.storedMessages()?.count
            if (messagesCount == 0) {
                self.startSpinProgress()
            }
            else if (self.chatDataSource.messagesCount() == 0) {
                self.chatDataSource.add(self.storedMessages()!)
            }
            
            self.loadMessages()
            
            self.enableTextCheckingTypes = NSTextCheckingAllTypes
        }
        else {
            SVProgressHUD.showInfo(withStatus: L10n.dsdChatterNotConnected())
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.queueManager().add(self)
        
        self.willResignActiveBlock = NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil) { [weak self] (notification) in
            
            self?.fireSendStopTypingIfNecessary()
        }

        reconfigUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Saving current dialog ID.
        ServicesManager.instance().currentDialogID = self.dialog.id!
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let willResignActive = self.willResignActiveBlock {
            NotificationCenter.default.removeObserver(willResignActive)
        }
        
        // Resetting current dialog ID.
        ServicesManager.instance().currentDialogID = ""
        
        // clearing typing status blocks
        self.dialog.clearTypingStatusBlocks()
        
        self.queueManager().remove(self)

        if (self.isBeingDismissed || self.isMovingFromParent) {
            releaseChat()
            UIApplication.shared.isStatusBarHidden = true
        }
    }

    func reconfigUI() {
        // show send button
        let sendButton = self.inputToolbar.contentView.rightBarButtonItem
        sendButton?.setTitleForAllState(title: L10n.send())
        sendButton?.tintColor = UIColor.black
        sendButton?.isHidden = false
        sendButton?.isEnabled = true
        sendButton?.setTitleColor(kChatSendButtonNormalColor, for: .normal)
        sendButton?.setTitleColor(kChatSendButtonHighlightColor, for: .highlighted)

        // hide record button
        let rightBarButtonContainerView = self.inputToolbar.contentView.subviews[1]
        for view in rightBarButtonContainerView.subviews {
            if view is QMAudioRecordButton {
                view.isHidden = true
            }
        }

        self.collectionView.showsVerticalScrollIndicator = false
    }

    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: {
            self.dismissHandler?(self.dialog)
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func initChat() {
        switch dialog.type {
        case .group, .publicGroup:
            joinGroupChat()
            break
        case .private:
            break
        }
    }

    func joinGroupChat() {
        SVProgressHUD.show(with: .clear)
        dialog.join { (error) in
            if error == nil {
                self.loadDialogUsers()
            }
            else {
                SVProgressHUD.dismiss()
            }
        }
    }

    func loadDialogUsers() {
        Utils.dialogsManager!.getUsersFromDialog(dialog: dialog) { (users, bundle) in
            SVProgressHUD.dismiss()
            if users != nil {
                self.loadMessages()
            }
            else {
                QMMessageNotificationManager.showNotification(withTitle: "Load chat users errors", subtitle: "", type: QMMessageNotificationType.warning)
            }
        }
    }

    func releaseChat() {
        ServicesManager.instance().chatService.removeDelegate(self)
        ServicesManager.instance().chatService.chatAttachmentService.removeDelegate(self)
        if dialog.type != QBChatDialogType.private {
            leaveGroupDialog()
        }
    }

    func leaveGroupDialog() {
        dialog.leave { (error) in
        }
    }
    
    // MARK: Update
    
    func updateTitle() {
        
        if self.dialog.type != QBChatDialogType.private {
            self.navigationItem.title = self.dialog.name ?? ""
        }
        else {
            self.navigationItem.title = "Chat with \(self.dialog.name ?? "")"
        }
    }
    
    func storedMessages() -> [QBChatMessage]? {
        return ServicesManager.instance().chatService.messagesMemoryStorage.messages(withDialogID: self.dialog.id!)
    }
    
    func loadMessages() {
        // Retrieving messages for chat dialog ID.
        guard let currentDialogID = self.dialog.id else {
            print ("Current chat dialog is nil")
            return
        }
        
        ServicesManager.instance().chatService.messages(withChatDialogID: currentDialogID, completion: {
            [weak self] (response, messages) -> Void in
            
            guard let strongSelf = self else { return }
            
            guard response.error == nil else {
                SVProgressHUD.showError(withStatus: response.error?.error?.localizedDescription)
                return
            }

            if !(self?.progressView.isHidden)! {
                self?.stopSpinProgress()
            }

            if messages?.count ?? 0 > 0 {
                strongSelf.chatDataSource.add(messages)
            }
            
            SVProgressHUD.dismiss()
        })
    }
    
    func sendReadStatusForMessage(message: QBChatMessage) {
        
        guard QBSession.current.currentUser != nil else {
            return
        }
        guard message.senderID != QBSession.current.currentUser?.id else {
            return
        }
        
        if self.messageShouldBeRead(message: message) {
            ServicesManager.instance().chatService.read(message, completion: { (error) -> Void in
                
                guard error == nil else {
                    print("Problems while marking message as read! Error: %@", error!)
                    return
                }

                DialogUtils.refreshAppBadge()
                /*
                if UIApplication.shared.applicationIconBadgeNumber > 0 {
                    let badgeNumber = UIApplication.shared.applicationIconBadgeNumber
                    UIApplication.shared.applicationIconBadgeNumber = badgeNumber - 1
                }*/
            })
        }
    }
    
    func messageShouldBeRead(message: QBChatMessage) -> Bool {
        
        let currentUserID = NSNumber(value: QBSession.current.currentUser!.id as UInt)
        
        return !message.isDateDividerMessage
            && message.senderID != self.senderID
            && !(message.readIDs?.contains(currentUserID))!
    }
    
    func readMessages(messages: [QBChatMessage]) {
        
        if QBChat.instance.isConnected {
            
            ServicesManager.instance().chatService.read(messages, forDialogID: self.dialog.id!, completion: nil)
        }
        else {
            
            self.unreadMessages = messages
        }
        
        var messageIDs = [String]()
        
        for message in messages {
            messageIDs.append(message.id!)
        }
    }
    
    // MARK: Actions
    
    override func didPickAttachmentImage(_ image: UIImage!) {
        
        let message = QBChatMessage()
        message.senderID = self.senderID
        message.dialogID = self.dialog.id
        message.dateSent = Date()
        
        DispatchQueue.global().async { [weak self] () -> Void in
            
            guard let strongSelf = self else { return }
            
            var newImage : UIImage! = image
            if strongSelf.imagePickerViewController.sourceType == UIImagePickerController.SourceType.camera {
                newImage = newImage.fixOrientation()
            }
            
            let largestSide = newImage.size.width > newImage.size.height ? newImage.size.width : newImage.size.height
            let scaleCoeficient = largestSide/560.0
            let newSize = CGSize(width: newImage.size.width/scaleCoeficient, height: newImage.size.height/scaleCoeficient)
            
            // create smaller image
            
            UIGraphicsBeginImageContext(newSize)
            
            newImage.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            // Sending attachment.
            DispatchQueue.main.async(execute: {
                self?.chatDataSource.add(message)
                // sendAttachmentMessage method always firstly adds message to memory storage
                ServicesManager.instance().chatService.sendAttachmentMessage(message, to: self!.dialog, withAttachmentImage: resizedImage!, completion: {
                    [weak self] (error) -> Void in
                    
                    self?.attachmentCellsMap.removeObject(forKey: message.id as AnyObject?)
                    
                    guard error != nil else { return }
                    
                    self?.chatDataSource.delete(message)
                })
            })
        }
    }

    override func didPickAttachmentVideo(_ videoURL: URL) {

        let message = QBChatMessage()
        message.senderID = self.senderID
        message.dialogID = self.dialog.id
        message.dateSent = Date()

        DispatchQueue.global().async { [weak self] () -> Void in

            guard let strongSelf = self else { return }

            // Sending attachment.
            DispatchQueue.main.async(execute: {
                self?.chatDataSource.add(message)

                let attachment = QBChatAttachment.videoAttachment(withFileURL: videoURL)

                // sendAttachmentMessage method always firstly adds message to memory storage
                ServicesManager.instance().chatService.sendAttachmentMessage(message, to: self!.dialog, with: attachment, completion: {
                    [weak self] (error) -> Void in

                    self?.attachmentCellsMap.removeObject(forKey: message.id as AnyObject?)

                    guard error != nil else { return }

                    self?.chatDataSource.delete(message)
                })
            })
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: UInt, senderDisplayName: String!, date: Date!) {
        
        if !self.queueManager().shouldSendMessagesInDialog(withID: self.dialog.id!) {
            return
        }
        self.fireSendStopTypingIfNecessary()
        
        let message = QBChatMessage()
        message.text = text
        message.senderID = self.senderID
        message.deliveredIDs = [(NSNumber(value: self.senderID))]
        message.readIDs = [(NSNumber(value: self.senderID))]
        message.markable = true
        message.dateSent = date
        
        self.sendMessage(message: message)
    }
    
    override func didPressSend(_ button: UIButton!, withTextAttachments textAttachments: [Any]!, senderId: UInt, senderDisplayName: String!, date: Date!) {
        
        if let attachment = textAttachments.first as? NSTextAttachment {
            
            if (attachment.image != nil) {
                let message = QBChatMessage()
                message.senderID = self.senderID
                message.dialogID = self.dialog.id
                message.dateSent = Date()
                ServicesManager.instance().chatService.sendAttachmentMessage(message, to: self.dialog, withAttachmentImage: attachment.image!, completion: {
                    [weak self] (error: Error?) -> Void in
                    
                    self?.attachmentCellsMap.removeObject(forKey: message.id as AnyObject?)
                    
                    guard error != nil else { return }
                    
                    // perform local attachment message deleting if error
                    ServicesManager.instance().chatService.deleteMessageLocally(message)
                    
                    self?.chatDataSource.delete(message)
                    
                })
                
                self.finishSendingMessage(animated: true)
            }
        }
    }
    
    func sendMessage(message: QBChatMessage) {
        
        // Sending message.
        ServicesManager.instance().chatService.send(message, type: QMMessageType.text, to: self.dialog, saveToHistory: true, saveToStorage: true) { (error) ->
            Void in
            
            if error != nil {
                
                QMMessageNotificationManager.showNotification(withTitle: L10n.error(), subtitle: error?.localizedDescription, type: QMMessageNotificationType.warning)
            }
        }

        // Sending push notification
        var userIdsList = self.dialog.occupantIDs ?? []
        // remove current user from the list

        let currentUser = QBSession.current.currentUser!
        for (index, userId) in userIdsList.enumerated() {
            if currentUser.id == userId.uintValue {
                userIdsList.remove(at: index)
            }
        }

        var messageText = ""
        if message.messageType == .text {
            messageText = message.text ?? ""
        }
        else {
            if let _ = message.attachments?.first {
                messageText = getAttachDetails(fromMessage: message)
            }
        }

        //DialogUtils.sendPushNotification(userIdsList: userIdsList, dialogId: self.dialog.id!, message: messageText, sender: senderDisplayName)
        
        self.finishSendingMessage(animated: true)
    }
    
    // MARK: Helper
    func canMakeACall() -> Bool {
        
        var canMakeACall = false
        
        if (UIApplication.shared.canOpenURL(URL.init(string: "tel://")!)) {
            
            // Check if iOS Device supports phone calls
            let networkInfo = CTTelephonyNetworkInfo()
            let carrier = networkInfo.subscriberCellularProvider
            if carrier == nil {
                return false
            }
            let mnc = carrier?.mobileNetworkCode
            if mnc?.length == 0 {
                // Device cannot place a call at this time.  SIM might be removed.
            }
            else {
                // iOS Device is capable for making calls
                canMakeACall = true
            }
        }
        else {
            // iOS Device is not capable for making calls
        }
        
        return canMakeACall
    }
    
    func placeHolderTextView(_ textView: QMPlaceHolderTextView, shouldPasteWithSender sender: Any) -> Bool {
        
        if UIPasteboard.general.image != nil {
            
            let textAttachment = NSTextAttachment()
            textAttachment.image = UIPasteboard.general.image!
            textAttachment.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
            
            let attrStringWithImage = NSAttributedString.init(attachment: textAttachment)
            self.inputToolbar.contentView.textView.attributedText = attrStringWithImage
            self.textViewDidChange(self.inputToolbar.contentView.textView)
            
            return false
        }
        
        return true
    }
    
    func showCharactersNumberError() {
        let title  = L10n.error();
        let subtitle = String(format: "The character limit is %lu.", maxCharactersNumber)
        QMMessageNotificationManager.showNotification(withTitle: title, subtitle: subtitle, type: .error)
    }
    
    /**
     Builds a string
     Read: login1, login2, login3
     Delivered: login1, login3, @12345
     
     If user does not exist in usersMemoryStorage, then ID will be used instead of login
     
     - parameter message: QBChatMessage instance
     
     - returns: status string
     */
    func statusStringFromMessage(message: QBChatMessage) -> String {
        
        var statusString = ""
        
        let currentUserID = NSNumber(value:self.senderID)
        
        var readLogins: [String] = []
        
        if message.readIDs != nil {
            
            let messageReadIDs = message.readIDs!.filter { (element) -> Bool in
                
                return !element.isEqual(to: currentUserID)
            }
            
            if !messageReadIDs.isEmpty {
                for readID in messageReadIDs {
                    let user = ServicesManager.instance().usersService.usersMemoryStorage.user(withID: UInt(truncating: readID))
                    
                    guard let unwrappedUser = user else {
                        let unknownUserLogin = "@\(readID)"
                        readLogins.append(unknownUserLogin)
                        
                        continue
                    }
                    
                    readLogins.append(unwrappedUser.login!)
                }
                
                statusString += message.isMediaMessage() ? L10n.seen() : L10n.read();
                statusString += ": " + readLogins.joined(separator: ", ")
            }
        }
        
        if message.deliveredIDs != nil {
            var deliveredLogins: [String] = []
            
            let messageDeliveredIDs = message.deliveredIDs!.filter { (element) -> Bool in
                return !element.isEqual(to: currentUserID)
            }
            
            if !messageDeliveredIDs.isEmpty {
                for deliveredID in messageDeliveredIDs {
                    let user = ServicesManager.instance().usersService.usersMemoryStorage.user(withID: UInt(truncating: deliveredID))
                    
                    guard let unwrappedUser = user else {
                        let unknownUserLogin = "@\(deliveredID)"
                        deliveredLogins.append(unknownUserLogin)
                        
                        continue
                    }
                    
                    if readLogins.contains(unwrappedUser.login!) {
                        continue
                    }
                    
                    deliveredLogins.append(unwrappedUser.login!)
                    
                }
                
                if readLogins.count > 0 && deliveredLogins.count > 0 {
                    statusString += "\n"
                }
                
                if deliveredLogins.count > 0 {
                    statusString += L10n.delivered() + ": " + deliveredLogins.joined(separator: ", ")
                }
            }
        }
        
        if statusString.isEmpty {
            
            let messageStatus: QMMessageStatus = self.queueManager().status(for: message)
            
            switch messageStatus {
            case .sent:
                statusString = L10n.sent()
            case .sending:
                statusString = L10n.sending()
            case .notSent:
                statusString = L10n.didnTSend()
            }
            
        }
        
        return statusString
    }

    func getAttachDetails(fromMessage message: QBChatMessage) -> String {
        guard let attachment = message.attachments?.first else {return ""}
        if attachment.attachmentType == .contentTypeAudio {
            return "Audio"
        }
        else if attachment.attachmentType == .contentTypeImage {
            return "Image"
        }
        else if attachment.attachmentType == .contentTypeVideo {
            return "Video"
        }
        else {
            return "Other"
        }
    }
    
    // MARK: Override
    
    override func viewClass(forItem item: QBChatMessage) -> AnyClass? {
        // TODO: check and add QMMessageType.AcceptContactRequest, QMMessageType.RejectContactRequest, QMMessageType.ContactRequest
        
        if item.isNotificationMessage() || item.isDateDividerMessage {
            return QMChatNotificationCell.self
        }
        
        if (item.senderID != self.senderID) {
            
            if (item.isMediaMessage() && item.attachmentStatus != QMMessageAttachmentStatus.error) {
                
                return QMChatAttachmentIncomingCell.self
                
            }
            else {
                
                return QMChatIncomingCell.self
            }
            
        }
        else {
            
            if (item.isMediaMessage() && item.attachmentStatus != QMMessageAttachmentStatus.error) {
                
                return QMChatAttachmentOutgoingCell.self
                
            }
            else {
                
                return QMChatOutgoingCell.self
            }
        }
    }
    
    // MARK: Strings builder
    
    override func attributedString(forItem messageItem: QBChatMessage!) -> NSAttributedString? {
        
        guard messageItem.text != nil else {
            return nil
        }

        let incomingTextColor = UIColor(red: 20.0/255, green: 20.0/255, blue: 20.0/255, alpha: 1.0)
        let outgoingTextColor = UIColor(red: 0.0/255, green: 0.0/255, blue: 0.0/255, alpha: 1.0)
        var textColor = messageItem.senderID == self.senderID ? outgoingTextColor : incomingTextColor
        if messageItem.isNotificationMessage() || messageItem.isDateDividerMessage {
            textColor = UIColor(red: 118.0/255, green: 118.0/255, blue: 118.0/255, alpha: 1.0)
        }
        
        var attributes = [NSAttributedString.Key:Any]()
        attributes[NSAttributedString.Key.foregroundColor] = textColor
        attributes[NSAttributedString.Key.font] = UIFont(name: "Helvetica", size: 17)

        var text = messageItem.text!
        if messageItem.isDateDividerMessage == true {
            text = messageItem.dateSent!.toDateString(format: "MMMM d") ?? ""
            text = text.uppercased()
            attributes[NSAttributedString.Key.font] = UIFont(name: "Helvetica", size: 15)
        }

        let attributedString = NSAttributedString(string: text, attributes: attributes)
        
        return attributedString
    }
    
    
    /**
     Creates top label attributed string from QBChatMessage
     
     - parameter messageItem: QBCHatMessage instance
     
     - returns: login string, example: @SwiftTestDevUser1
     */
    override func topLabelAttributedString(forItem messageItem: QBChatMessage!) -> NSAttributedString? {
        
        guard messageItem.senderID != self.senderID else {
            return nil
        }

        let paragrpahStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragrpahStyle.lineBreakMode = NSLineBreakMode.byTruncatingTail

        var attributes = [NSAttributedString.Key:Any]()
        attributes[NSAttributedString.Key.foregroundColor] = UIColor(red: 118.0/255.0, green: 118.0/255.0, blue: 118.0/255.0, alpha: 1.0)
        attributes[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 16)
        attributes[NSAttributedString.Key.paragraphStyle] = paragrpahStyle
        
        var topLabelAttributedString : NSAttributedString?
        
        if let topLabelText =  ServicesManager.instance().usersService.usersMemoryStorage.user(withID: messageItem.senderID)?.fullName {
            topLabelAttributedString = NSAttributedString(string: topLabelText, attributes: attributes)
        } else { // no user in memory storage
            topLabelAttributedString = NSAttributedString(string: "@\(messageItem.senderID)", attributes: attributes)
        }
        
        return topLabelAttributedString
    }
    
    /**
     Creates bottom label attributed string from QBChatMessage using self.statusStringFromMessage
     
     - parameter messageItem: QBChatMessage instance
     
     - returns: bottom label status string
     */
    override func bottomLabelAttributedString(forItem messageItem: QBChatMessage!) -> NSAttributedString! {

        /*
        let textColor = messageItem.senderID == self.senderID ? UIColor.white : UIColor.black*/
        let textColor = UIColor(red: 118.0/255.0, green: 118.0/255.0, blue: 118.0/255.0, alpha: 1.0)
        
        let paragrpahStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragrpahStyle.lineBreakMode = NSLineBreakMode.byWordWrapping

        var attributes = [NSAttributedString.Key:Any]()
        attributes[NSAttributedString.Key.foregroundColor] = textColor
        attributes[NSAttributedString.Key.font] = UIFont(name: "Helvetica", size: 13)
        attributes[NSAttributedString.Key.paragraphStyle] = paragrpahStyle
        
        var text = messageItem.dateSent != nil ? messageTimeDateFormatter.string(from: messageItem.dateSent!) : ""
        
        if messageItem.senderID == self.senderID {
            text = text + "\n" + self.statusStringFromMessage(message: messageItem)
        }
        
        let bottomLabelAttributedString = NSAttributedString(string: text, attributes: attributes)
        
        return bottomLabelAttributedString
    }
    
    // MARK: Collection View Datasource
    
    override func collectionView(_ collectionView: QMChatCollectionView!, dynamicSizeAt indexPath: IndexPath!, maxWidth: CGFloat) -> CGSize {
        
        var size = CGSize.zero
        let collectionViewSize = collectionView.bounds.size
        var messageWidth = floor(collectionViewSize.width*0.3)

        guard let message = self.chatDataSource.message(for: indexPath) else {
            return size
        }

        if self.detailedCells.contains(message.id!) {
            messageWidth = floor(collectionViewSize.width*0.4)
        }
        
        let messageCellClass: AnyClass! = self.viewClass(forItem: message)

        if messageCellClass === QMChatAttachmentIncomingCell.self {
            size = CGSize(width: min(messageWidth, maxWidth), height: 200)
        }
        else if messageCellClass === QMChatAttachmentOutgoingCell.self {
            size = CGSize(width: min(messageWidth, maxWidth), height: 200)
        }
        else if messageCellClass === QMChatNotificationCell.self {
            let attributedString = self.attributedString(forItem: message)
            size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines: 0)
        }
        else {
            let attributedString = self.attributedString(forItem: message)
            
            size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: messageWidth, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines: 0)
            size = CGSize(width:messageWidth, height:size.height)
        }
        
        return size
    }
    
    override func collectionView(_ collectionView: QMChatCollectionView!, minWidthAt indexPath: IndexPath!) -> CGFloat {
        
        guard let _ = self.chatDataSource.message(for: indexPath) else {
            return 0
        }
        return 50.0
    }
    
    override func collectionView(_ collectionView: QMChatCollectionView!, layoutModelAt indexPath: IndexPath!) -> QMChatCellLayoutModel {
        
        var layoutModel: QMChatCellLayoutModel = super.collectionView(collectionView, layoutModelAt: indexPath)
        
        layoutModel.avatarSize = CGSize(width: 0, height: 0)
        layoutModel.topLabelHeight = 0.0
        layoutModel.spaceBetweenTextViewAndBottomLabel = 0
        layoutModel.maxWidthMarginSpace = 0.0
        
        guard let item = self.chatDataSource.message(for: indexPath) else {
            return layoutModel
        }
        
        let viewClass: AnyClass = self.viewClass(forItem: item)! as AnyClass
        
        if viewClass === QMChatIncomingCell.self || viewClass === QMChatAttachmentIncomingCell.self {

            let topAttributedString = self.topLabelAttributedString(forItem: item)
            let size = TTTAttributedLabel.sizeThatFitsAttributedString(topAttributedString, withConstraints: CGSize(width: collectionView.frame.width - kMessageContainerWidthPadding, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines:1)
            layoutModel.topLabelHeight = size.height
            layoutModel.spaceBetweenTopLabelAndTextView = 5
        }
        
        let size = CGSize.zero
        layoutModel.bottomLabelHeight = floor(size.height)
        return layoutModel
    }
    
    override func collectionView(_ collectionView: QMChatCollectionView!, configureCell cell: UICollectionViewCell!, for indexPath: IndexPath!) {
        
        super.collectionView(collectionView, configureCell: cell, for: indexPath)
        
        // subscribing to cell delegate
        let chatCell = cell as! QMChatCell

        chatCell.containerView.arrow = true
        chatCell.containerView.arrowSize = CGSize.zero
        chatCell.containerView.cornerRadius = 10.0
        chatCell.delegate = self
        
        let message = self.chatDataSource.message(for: indexPath)
        
        if let attachmentCell = cell as? QMChatAttachmentCell {
            
            if attachmentCell is QMChatAttachmentIncomingCell {
                chatCell.containerView?.bgColor = UIColor(red: 226.0/255.0, green: 226.0/255.0, blue: 226.0/255.0, alpha: 1.0)
                chatCell.containerView?.highlightColor = chatCell.containerView?.bgColor
            }
            else if attachmentCell is QMChatAttachmentOutgoingCell {
                chatCell.containerView?.bgColor = UIColor(red: 247.0/255.0, green: 210.0/255.0, blue: 172.0/255.0, alpha: 1.0)
                chatCell.containerView?.highlightColor = chatCell.containerView?.bgColor
            }

            let attachDetails = self.getAttachDetails(fromMessage: message!)
            chatCell.attachDetailsLabel.text = attachDetails
            
            if let attachment = message?.attachments?.first {
                
                var keysToRemove: [String] = []
                
                let enumerator = self.attachmentCellsMap.keyEnumerator()
                
                while let existingAttachmentID = enumerator.nextObject() as? String {
                    let cachedCell = self.attachmentCellsMap.object(forKey: existingAttachmentID as AnyObject?)
                    if cachedCell === cell {
                        keysToRemove.append(existingAttachmentID)
                    }
                }
                
                for key in keysToRemove {
                    self.attachmentCellsMap.removeObject(forKey: key as AnyObject?)
                }

                let error_image = UIImage(named:"icon_DownloadError")
                
                if let attachmentID = attachment.id {
                    if self.failedDownloads.contains(attachmentID) {
                        attachmentCell.setAttachmentImage(error_image, isCenter: true)
                        return
                    }
                }
                
                self.attachmentCellsMap.setObject(attachmentCell, forKey: attachment.id as AnyObject?)
                
                attachmentCell.attachmentID = attachment.id
                
                // Getting image from chat attachment cache.
                if attachment.attachmentType == .contentTypeImage {

                    ServicesManager.instance().chatService.chatAttachmentService.image(forAttachmentMessage: message!, completion: { [weak self] (error, image) in

                        guard attachmentCell.attachmentID == attachment.id else {
                            attachmentCell.setAttachmentImage(error_image, isCenter: true)
                            return
                        }

                        self?.attachmentCellsMap.removeObject(forKey: attachment.id as AnyObject?)

                        guard error == nil else {
                            if (error! as NSError).code == 404 {
                                self?.failedDownloads.insert(attachment.id!)

                                attachmentCell.setAttachmentImage(error_image, isCenter: true)
                            }
                            print("Error downloading image from server: \(error!.localizedDescription)")
                            return
                        }

                        if image == nil {
                            attachmentCell.setAttachmentImage(error_image, isCenter: true)
                            print("Image is nil")
                        }
                        else {
                            attachmentCell.setAttachmentImage(image, isCenter: false)
                        }

                        cell.updateConstraints()
                    })
                }
                else {
                    let messageStatus: QMMessageStatus = self.queueManager().status(for: message!)
                    if messageStatus != .sent {
                        attachmentCell.setAttachmentImage(nil, isCenter: false)
                    }
                    else {
                        let otherAttachImage = UIImage(named: "icon_Terms")
                        attachmentCell.setAttachmentImage(otherAttachImage, isCenter: true)
                    }
                    cell.updateConstraints()
                }
            }
            
        }
        else if cell is QMChatIncomingCell || cell is QMChatAttachmentIncomingCell {
            
            chatCell.containerView?.bgColor = UIColor(red: 226.0/255.0, green: 226.0/255.0, blue: 226.0/255.0, alpha: 1.0)
            chatCell.containerView?.highlightColor = chatCell.containerView?.bgColor
        }
        else if cell is QMChatOutgoingCell {
            
            let status: QMMessageStatus = self.queueManager().status(for: message!)

            chatCell.containerView?.bgColor = UIColor(red: 247.0/255.0, green: 210.0/255.0, blue: 172.0/255.0, alpha: 1.0)
            chatCell.containerView?.highlightColor = chatCell.containerView?.bgColor
        }
        else if cell is QMChatAttachmentOutgoingCell {
            chatCell.containerView?.bgColor = UIColor(red: 247.0/255.0, green: 210.0/255.0, blue: 172.0/255.0, alpha: 1.0)
            chatCell.containerView?.highlightColor = chatCell.containerView?.bgColor
        }
        else if cell is QMChatNotificationCell {
            cell.isUserInteractionEnabled = false
            chatCell.containerView?.bgColor = self.collectionView?.backgroundColor
            chatCell.containerView?.highlightColor = chatCell.containerView?.bgColor
        }

        if cell is QMChatIncomingCell || cell is QMChatOutgoingCell || cell is QMChatAttachmentIncomingCell || cell is QMChatAttachmentOutgoingCell {
            // date/time
            let sentAt = message?.dateSent?.toDateString(format: "h:mm a") ?? ""
            chatCell.rightLabel.text = sentAt

            /*
            if self.detailedCells.contains(message!.id!) {
                chatCell.rightLabel.isHidden = true
            } else {
                chatCell.rightLabel.isHidden = false
            }*/
        }
    }
    
    /**
     Allows to copy text from QMChatIncomingCell and QMChatOutgoingCell
     */
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {

        return false
    }
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {

        let item = self.chatDataSource.message(for: indexPath)
        
        if (item?.isMediaMessage())! {
            ServicesManager.instance().chatService.chatAttachmentService.localImage(forAttachmentMessage: item!, completion: { (image) in
                
                if image != nil {
                    guard let imageData = image!.jpegData(compressionQuality: 1) else { return }
                    
                    let pasteboard = UIPasteboard.general
                    
                    pasteboard.setValue(imageData, forPasteboardType:kUTTypeJPEG as String)
                }
            })
        }
        else {
            UIPasteboard.general.string = item?.text
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let lastSection = self.collectionView!.numberOfSections - 1
        
        if (indexPath.section == lastSection && indexPath.item == (self.collectionView?.numberOfItems(inSection: lastSection))! - 1) {
            // the very first message
            // load more if exists
            // Getting earlier messages for chat dialog identifier.
            
            guard let dialogID = self.dialog.id else {
                print("DialogID is nil")
                return super.collectionView(collectionView, cellForItemAt: indexPath)
            }
            
            ServicesManager.instance().chatService.loadEarlierMessages(withChatDialogID: dialogID).continueWith(block: {[weak self](task) -> Any? in
                
                guard let strongSelf = self else { return nil }
                
                if (task.result?.count ?? 0 > 0) {
                    
                    strongSelf.chatDataSource.add(task.result as! [QBChatMessage]!)
                }
                
                return nil
            })
        }
        
        // marking message as read if needed
        if let message = self.chatDataSource.message(for: indexPath) {
            self.sendReadStatusForMessage(message: message)
        }
        
        return super.collectionView(collectionView, cellForItemAt
            : indexPath)
    }
    
    // MARK: QMChatCellDelegate
    
    /**
     Removes size from cache for item to allow cell expand and show read/delivered IDS or unexpand cell
     */
    func chatCellDidTapContainer(_ cell: QMChatCell!) {
        let indexPath = self.collectionView?.indexPath(for: cell)
        
        guard let currentMessage = self.chatDataSource.message(for: indexPath) else {
            return
        }
        
        let messageStatus: QMMessageStatus = self.queueManager().status(for: currentMessage)
        
        if messageStatus != .sent {
            //self.handleNotSentMessage(currentMessage, forCell:cell)
            return
        }

        if cell is QMChatAttachmentIncomingCell || cell is QMChatAttachmentOutgoingCell {
            // show image
            let firstAttachment = currentMessage.attachments!.first!
            let attachmentType = firstAttachment.attachmentType

            if attachmentType == .contentTypeImage {

                SVProgressHUD.show(with: .none)
                ServicesManager.instance().chatService.chatAttachmentService.image(forAttachmentMessage: currentMessage, completion: { [weak self] (error, image) in

                    SVProgressHUD.dismiss()

                    var imageToOpen = image
                    if error != nil  {
                        imageToOpen = UIImage(named: "error_image")
                        print("Error downloading image from server: \(error!.localizedDescription)")
                    }
                    let imageViewerVC = UIViewController.getViewController(storyboardName: "Chat", storyboardID: "ImageViewerVC") as! ImageViewerVC
                    imageViewerVC.setDefaultModalPresentationStyle()
                    imageViewerVC.image = imageToOpen
                    self?.present(imageViewerVC, animated: true, completion: nil)
                })
            }
            else {
                let attachId = firstAttachment.id ?? ""
                if attachId == "" {
                    SVProgressHUD.showInfo(withStatus: "It is not uploaded yet.")
                    return
                }

                SVProgressHUD.show(with: .none)
                ServicesManager.instance().chatService.chatAttachmentService.attachment(withID: attachId, message: currentMessage, progressBlock: nil, completion: { (operation) in

                    DispatchQueue.main.async {

                        //SVProgressHUD.dismiss()

                        let attachment = operation.attachment
                        guard let localFileURL = attachment.localFileURL else {
                            SVProgressHUD.showError(withStatus: L10n.failedToDownloadTheAttachment())
                            return
                        }

                        if attachmentType == .contentTypeVideo {
                            let asset = AVURLAsset(url: localFileURL)
                            if asset.isPlayable == true {
                                let player = AVPlayer(url: localFileURL)
                                let playerVC = AVPlayerViewController()
                                playerVC.player = player
                                playerVC.setFullScreenPresentation()
                                self.present(playerVC, animated: true, completion: {
                                    playerVC.player!.play()
                                })
                                SVProgressHUD.dismiss()
                            }
                            else {
                                SVProgressHUD.showError(withStatus: L10n.WeCanTOpenTheFile())
                            }
                            return
                        }
                        else {
                            SVProgressHUD.showError(withStatus: L10n.WeCanTOpenTheFile())
                            return
                        }
                    }
                })
            }
            return
        }

        if self.detailedCells.contains(currentMessage.id!) {
            self.detailedCells.remove(currentMessage.id!)
        } else {
            self.detailedCells.insert(currentMessage.id!)
        }
        
        self.collectionView?.collectionViewLayout.removeSizeFromCache(forItemID: currentMessage.id)
        self.collectionView?.performBatchUpdates(nil, completion: nil)

        if cell is QMChatIncomingCell || cell is QMChatOutgoingCell {
            // date/time
            let sentAt = currentMessage.dateSent?.toDateString(format: "h:mm a") ?? ""
            cell.rightLabel.text = sentAt

            /*
            if self.detailedCells.contains(currentMessage.id!) {
                cell.rightLabel.isHidden = true
            } else {
                cell.rightLabel.isHidden = false
            }*/
        }
    }
    
    func chatCell(_ cell: QMChatCell!, didTapAtPosition position: CGPoint) {}
    
    func chatCell(_ cell: QMChatCell!, didPerformAction action: Selector!, withSender sender: Any!) {}
    
    func chatCell(_ cell: QMChatCell!, didTapOn result: NSTextCheckingResult) {
        
        switch result.resultType {
            
        case NSTextCheckingResult.CheckingType.link:
            
            let strUrl : String = (result.url?.absoluteString)!
            
            let hasPrefix = strUrl.lowercased().hasPrefix("https://") || strUrl.lowercased().hasPrefix("http://")
            
            if #available(iOS 9.0, *) {
                if hasPrefix {
                    
                    let controller = SFSafariViewController(url: URL(string: strUrl)!)
                    controller.setFullScreenPresentation()
                    self.present(controller, animated: true, completion: nil)
                    
                    break
                }
                
            }
            // Fallback on earlier versions
            
            if UIApplication.shared.canOpenURL(URL(string: strUrl)!) {
                UIApplication.shared.openURL(URL(string: strUrl)!)
            }
            
            break
            
        case NSTextCheckingResult.CheckingType.phoneNumber:
            
            if !self.canMakeACall() {
                
                SVProgressHUD.showInfo(withStatus: L10n.yourDeviceCanTMakeAPhoneCall(), maskType: .none)
                break
            }
            
            let urlString = String(format: "tel:%@",result.phoneNumber!)
            let url = URL(string: urlString)
            
            self.view.endEditing(true)
            
            let alertController = UIAlertController(title: "",
                                                    message: result.phoneNumber,
                                                    preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: L10n.cancel(), style: .cancel) { (action) in
                
            }
            
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: L10n.call(), style: .destructive) { (action) in
                UIApplication.shared.openURL(url!)
            }
            alertController.addAction(openAction)
            
            self.present(alertController, animated: true) {
            }
            
            break
            
        default:
            break
        }
    }
    
    func chatCellDidTapAvatar(_ cell: QMChatCell!) {
    }
    
    // MARK: QMDeferredQueueManager
    
    func deferredQueueManager(_ queueManager: QMDeferredQueueManager, didAddMessageLocally addedMessage: QBChatMessage) {
        
        if addedMessage.dialogID == self.dialog.id {
            self.chatDataSource.add(addedMessage)
        }
    }
    
    func deferredQueueManager(_ queueManager: QMDeferredQueueManager, didUpdateMessageLocally addedMessage: QBChatMessage) {
        
        if addedMessage.dialogID == self.dialog.id {
            self.chatDataSource.update(addedMessage)
        }
    }
    
    // MARK: QMChatServiceDelegate
    
    func chatService(_ chatService: QMChatService, didLoadMessagesFromCache messages: [QBChatMessage], forDialogID dialogID: String) {
        
        if self.dialog.id == dialogID {
            if !self.progressView.isHidden {
                self.stopSpinProgress()
            }
            self.chatDataSource.add(messages)
        }
    }
    
    func chatService(_ chatService: QMChatService, didAddMessageToMemoryStorage message: QBChatMessage, forDialogID dialogID: String) {
        
        if self.dialog.id == dialogID {
            // Insert message received from XMPP or self sent
            if self.chatDataSource.messageExists(message) {
                
                self.chatDataSource.update(message)
            }
            else {
                
                self.chatDataSource.add(message)
            }
        }
    }
    
    func chatService(_ chatService: QMChatService, didUpdateChatDialogInMemoryStorage chatDialog: QBChatDialog) {
        
        if self.dialog.type != QBChatDialogType.private && self.dialog.id == chatDialog.id {
            self.dialog = chatDialog
            self.updateTitle()
        }
    }
    
    func chatService(_ chatService: QMChatService, didUpdate message: QBChatMessage, forDialogID dialogID: String) {
        
        if self.dialog.id == dialogID {
            self.chatDataSource.update(message)
        }
    }
    
    func chatService(_ chatService: QMChatService, didUpdate messages: [QBChatMessage], forDialogID dialogID: String) {
        
        if self.dialog.id == dialogID {
            self.chatDataSource.update(messages)
        }
    }
    
    // MARK: UITextViewDelegate
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
    }
    
    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Prevent crashing undo bug
        let currentCharacterCount = textView.text?.length ?? 0
        
        if (range.length + range.location > currentCharacterCount) {
            return false
        }
        
        if !QBChat.instance.isConnected { return true }
        
        if let timer = self.typingTimer {
            timer.invalidate()
            self.typingTimer = nil
            
        } else {
            
            self.sendBeginTyping()
        }
        
        self.typingTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(ChatVC.fireSendStopTypingIfNecessary), userInfo: nil, repeats: false)
        
        if maxCharactersNumber > 0 {
            
            if currentCharacterCount >= maxCharactersNumber && text.length > 0 {
                
                self.showCharactersNumberError()
                return false
            }
            
            let newLength = currentCharacterCount + text.length - range.length
            
            if  newLength <= maxCharactersNumber || text.length == 0 {
                return true
            }
            
            let oldString = textView.text ?? ""
            
            let numberOfSymbolsToCut = maxCharactersNumber - oldString.length
            
            var stringRange = NSMakeRange(0, min(text.length, numberOfSymbolsToCut))
            
            
            // adjust the range to include dependent chars
            stringRange = (text as NSString).rangeOfComposedCharacterSequences(for: stringRange)
            
            // Now you can create the short string
            let shortString = (text as NSString).substring(with: stringRange)
            
            let newText = NSMutableString()
            newText.append(oldString)
            newText.insert(shortString, at: range.location)
            textView.text = newText as String
            
            self.showCharactersNumberError()
            
            self.textViewDidChange(textView)
            
            return false
        }
        
        return true
    }
    
    override func textViewDidEndEditing(_ textView: UITextView) {
        
        super.textViewDidEndEditing(textView)
        
        self.fireSendStopTypingIfNecessary()
    }
    
    @objc func fireSendStopTypingIfNecessary() -> Void {
        
        if let timer = self.typingTimer {
            
            timer.invalidate()
        }
        
        self.typingTimer = nil
        self.sendStopTyping()
    }
    
    func sendBeginTyping() -> Void {
        self.dialog.sendUserIsTyping()
    }
    
    func sendStopTyping() -> Void {
        
        self.dialog.sendUserStoppedTyping()
    }
    
    // MARK: QMChatAttachmentServiceDelegate
    
    func chatAttachmentService(_ chatAttachmentService: QMChatAttachmentService, didChange status: QMMessageAttachmentStatus, for message: QBChatMessage) {
        
        if status != QMMessageAttachmentStatus.notLoaded {
            
            if message.dialogID == self.dialog.id {
                self.chatDataSource.update(message)
            }
        }
    }
    
    func chatAttachmentService(_ chatAttachmentService: QMChatAttachmentService, didChangeLoadingProgress progress: CGFloat, for attachment: QBChatAttachment) {
        
        if let attachmentCell = self.attachmentCellsMap.object(forKey: attachment.id! as AnyObject?) {
            attachmentCell.updateLoadingProgress(progress)
        }
    }
    
    func chatAttachmentService(_ chatAttachmentService: QMChatAttachmentService, didChangeUploadingProgress progress: CGFloat, for message: QBChatMessage) {
        
        guard message.dialogID == self.dialog.id else {
            return
        }
        var cell = self.attachmentCellsMap.object(forKey: message.id as AnyObject?)
        
        if cell == nil && progress < 1.0 {
            
            if let indexPath = self.chatDataSource.indexPath(for: message) {
                cell = self.collectionView?.cellForItem(at: indexPath) as? QMChatAttachmentCell
                self.attachmentCellsMap.setObject(cell, forKey: message.id as AnyObject?)
            }
        }
        
        cell?.updateLoadingProgress(progress)
    }
    
    // MARK : QMChatConnectionDelegate
    
    func refreshAndReadMessages() {
        
        SVProgressHUD.show(withStatus: L10n.loadingMessages(), maskType: SVProgressHUDMaskType.clear)
        self.loadMessages()
        
        if let messagesToRead = self.unreadMessages {
            self.readMessages(messages: messagesToRead)
        }
        
        self.unreadMessages = nil
    }
    
    func chatServiceChatDidConnect(_ chatService: QMChatService) {
        
        self.refreshAndReadMessages()
    }
    
    func chatServiceChatDidReconnect(_ chatService: QMChatService) {

        skipPagination = 0
        joinGroupChat()
        self.refreshAndReadMessages()
    }
    
    func queueManager() -> QMDeferredQueueManager {
        return ServicesManager.instance().chatService.deferredQueueManager
    }
    
    func handleNotSentMessage(_ message: QBChatMessage,
                              forCell cell: QMChatCell!) {
        
        let alertController = UIAlertController(title: "", message: L10n.messageFailedToSend(), preferredStyle:.actionSheet)
        
        let resend = UIAlertAction(title: L10n.tryAgain(), style: .default) { (action) in
            self.queueManager().perfromDefferedAction(for: message, withCompletion: nil)
        }
        alertController.addAction(resend)
        
        let delete = UIAlertAction(title: L10n.delete(), style: .destructive) { (action) in
            self.queueManager().remove(message)
            self.chatDataSource.delete(message)
        }
        alertController.addAction(delete)
        
        let cancelAction = UIAlertAction(title: L10n.cancel(), style: .cancel) { (action) in
            
        }
        
        alertController.addAction(cancelAction)
        
        if alertController.popoverPresentationController != nil {
            self.view.endEditing(true)
            alertController.popoverPresentationController!.sourceView = cell.containerView
            alertController.popoverPresentationController!.sourceRect = cell.containerView.bounds
        }
        
        self.present(alertController, animated: true) {
        }
    }
}
