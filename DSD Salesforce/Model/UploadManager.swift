//
//  UploadManager.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/31/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import Reachability
import SSZipArchive
import Alamofire

class UploadManager: NSObject {

    enum UploadItemType {
        case customerCatalog
        case normalCustomerFile
    }

    let globalInfo = GlobalInfo.shared
    var isBusy = false
    var isUploading = false
    var shouldStop = false
    var reachability: Reachability!

    func initManager() {
        initReachabiltyService()
        startIfNeeded(completionHandler: nil)
    }

    func initReachabiltyService() {
        reachability = Reachability()
        reachability.whenReachable = { _reachability in
            self.startIfNeeded(completionHandler: nil)
        }
        reachability.whenUnreachable = { _reachability in
            self.stop()
        }
        try? reachability.startNotifier()
    }

    func stop() {
        shouldStop = true
    }

    func startIfNeeded(completionHandler: (() -> ())?) {

        if isBusy == true {
            NSLog("Upload manager is busy")
            return
        }

        shouldStop = false
        var firstUploadItem = UploadItem.getFirst(context: self.globalInfo.managedObjectContext)

        DispatchQueue.global().async {

            while firstUploadItem != nil {

                if self.shouldStop == true {
                    break
                }
                
                Thread.sleep(forTimeInterval: 0.5)
                
                // should remove delete requested items
                let allUploadItems = UploadItem.getAll(context: self.globalInfo.managedObjectContext, shouldExcludePostponed: false)
                for uploadItem in allUploadItems {
                    if uploadItem.shouldRemoved == true {
                        UploadItem.deleteUploadItem(context: self.globalInfo.managedObjectContext, uploadItem: uploadItem)
                    }
                }
                
                if self.isBusy == true {
                    break
                }

                guard let firstItem = UploadItem.getFirst(context: self.globalInfo.managedObjectContext) else {continue}

                let hostname = firstItem.ftpHostname ?? ""
                let username = firstItem.ftpUsername ?? ""
                let password = firstItem.ftpPassword ?? ""
                let localPath = CommData.getFilePathAppended(byDocumentDir: firstItem.localName ?? "") ?? ""
                let companyName = firstItem.companyName ?? ""
                let remotePath = firstItem.ftpPath ?? ""
                
                // if local file size is 0, continue
                if CommData.isExistingFile(atPath: localPath) == false {
                    // remove the item and the files
                    UploadItem.delete(context: self.globalInfo.managedObjectContext, uploadItem: firstItem)
                    GlobalInfo.saveCache()
                    firstUploadItem = UploadItem.getFirst(context: self.globalInfo.managedObjectContext)
                    continue
                }
                
                let localFileSize = CommData.getFileSize(localPath)
                if localFileSize == 0 {
                    continue
                }
                
                if self.reachability.isReachable == false {
                    continue
                }
                
                self.isBusy = true

                NSLog("Uploading file - local name: \(firstItem.localName ?? "") - ftp path: \(remotePath)")

                let uploadResult = self.uploadFile(hostname: hostname, username: username, password: password, companyName: companyName, localPath: localPath, uploadPath: remotePath, shouldShowHUD: false)
                
                if uploadResult == true {
                    // remove the item and the files
                    UploadItem.delete(context: self.globalInfo.managedObjectContext, uploadItem: firstItem)
                    GlobalInfo.saveCache()
                    firstUploadItem = UploadItem.getFirst(context: self.globalInfo.managedObjectContext)
                }
                else {
                    self.shouldStop = true
                }
                self.isBusy = false
            }
            if let _completionHandler = completionHandler {
                _completionHandler()
            }
        }

    }
    
    func uploadFile(hostname: String, username: String, password: String, companyName: String, localPath: String, uploadPath: String, shouldShowHUD: Bool) -> Bool {
        
        // try http upload
        let httpUploadResult = uploadFileToFTPServerUsingHTTP(companyName: companyName, serverIP: hostname, username: username, localPath: localPath, uploadPath: uploadPath)
        
        // if failed try ftp upload
        if httpUploadResult == false {
            // upload it to ftp server
            return uploadFileToFTPServerUsingFTP(hostname: hostname, username: username, password: password, localPath: localPath, uploadPath: uploadPath)
        }
        return true
    }
    
    func uploadFileToFTPServerUsingFTP(hostname: String, username: String, password: String, localPath: String, uploadPath: String) -> Bool {
        
        let ftpManager = self.globalInfo.ftpManager!
        var hasCallingFinished = false
        var uploadResult = false
        ftpManager.uploadFile(hostname: hostname, user: username, password: password, localPath: localPath, uploadPath: uploadPath, shouldShowHUD: false, completion: { (success, message) in
            uploadResult = success
            hasCallingFinished = true
            NSLog(uploadPath + "success")
        })
        while hasCallingFinished == false {
            Thread.sleep(forTimeInterval: 0.5)
        }
        return uploadResult
    }
    
    // must run in background thread
    func uploadFileToFTPServerUsingHTTP(companyName: String, serverIP: String, username: String, localPath: String, uploadPath: String) -> Bool {
        
        if localPath == "" || uploadPath == "" {
            return false
        }
        
        if CommData.isExistingFile(atPath: localPath) == false {
            return false
        }
    
        let url = URL(fileURLWithPath: localPath)
        guard let data = try? Data(contentsOf: url) else {return false}
        
        let max_buffer_size: Int = 1000000
        let fileSize: Int = data.count
        var offset: Int = 0
        
        let rootPath = "http://\(serverIP)"
        let apiPath = "\(rootPath)/dsd/index.php/Backend/uploadChunk"
        
        var readSize: Int = 0
        var _file_handler = 0
        
        while (offset < fileSize) {
            
            if fileSize-offset < max_buffer_size {
                readSize = fileSize-offset
            }
            else {
                readSize = max_buffer_size
            }
            
            let subData = data.subdata(in: offset..<offset+readSize)
            
            let chunkFileName = UUID().uuidString + ".tmp"
            let chunkFilePath = CommData.getFilePathAppended(byDocumentDir: chunkFileName) ?? ""
            let chunkFileURL = URL(fileURLWithPath: chunkFilePath)
            try? subData.write(to: chunkFileURL, options: .atomic)
            
            var hasCallingFinished = false
            var uploadResult = false
            
            let uploadFileName = String.getFilenameFromPath(filePath: uploadPath)
            let uploadFolderName = String.getFileDir(filePath: uploadPath)
            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(Data("\(_file_handler)".utf8), withName: "file_handler")
                multipartFormData.append(Data(username.utf8), withName: "ftp_user_name")
                multipartFormData.append(Data(serverIP.utf8), withName: "ftp_ip_address")
                multipartFormData.append(Data(companyName.utf8), withName: "company_name")
                multipartFormData.append(Data(uploadFileName.utf8), withName: "target_file")
                multipartFormData.append(Data(uploadFolderName.utf8), withName: "target_folder")
                multipartFormData.append(Data("\(fileSize)".utf8), withName: "file_size")
                //multipartFormData.append(subData, withName: "source_file")
                multipartFormData.append(chunkFileURL, withName: "source_file")
                
            }, to: apiPath) { (encodingResult) in
                
                // remove temp file
                CommData.deleteFileIfExist(chunkFilePath)
                
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        guard let responseValue = response.result.value else {
                            NSLog("Invalid response: \(response.result.error!)")
                            uploadResult = false
                            hasCallingFinished = true
                            return
                        }
                        guard let responseDictionary = responseValue as? [AnyHashable: Any] else {
                            NSLog("Failed to uploading")
                            uploadResult = false
                            hasCallingFinished = true
                            return
                        }
                        
                        let result = responseDictionary["result"] as? String ?? ""
                        let message = responseDictionary["message"] as? String ?? ""
                        if result != "1" {
                            NSLog("Failed to uploading - \(message)")
                            uploadResult = false
                            hasCallingFinished = true
                            return
                        }
                        _file_handler = Int(responseDictionary["file_handler"] as? String ?? "") ?? 0
                        uploadResult = true
                        hasCallingFinished = true
                        return
                    }
                    break
                case .failure(let encodingError):
                    NSLog("Invalid response: \(encodingError.localizedDescription)")
                    uploadResult = false
                    hasCallingFinished = true
                    break
                }
                //uploadResult = false
                //hasCallingFinished = true
            }
            
            while hasCallingFinished == false {
                Thread.sleep(forTimeInterval: 0.5)
            }
            
            // check upload result
            if uploadResult == false {
                NSLog("FTP upload failed")
                return false
            }
            
            offset = offset+readSize
        }
        
        NSLog("FTP upload success")
        
        return true
    }

    func zipFiles(filePathArray: [String]) -> String {
        let date = Date()
        let timeString = date.toDateString(format: kTightFullDateFormat) ?? ""
        let zipFileName = "upload\(timeString).zip"
        let zipFilePath = CommData.getFilePathAppended(byDocumentDir: zipFileName) ?? ""
        CommData.deleteFileIfExist(zipFilePath)

        SSZipArchive.createZipFile(atPath: zipFilePath, withFilesAtPaths: filePathArray)

        DispatchQueue.main.asyncAfter(deadline: .now()+kUploadHandleDelay) {
            for filePath in filePathArray {
                CommData.deleteFileIfExist(filePath)
            }
        }
        return zipFileName
    }
    
    func zipAndScheduleUpload(filePathArray: [String], completionHandler: (() -> ())?)  {

        let date = Date()
        let timeString = date.toDateString(format: kTightFullDateFormat) ?? ""
        let zipFileName = "upload\(timeString).zip"
        let zipFilePath = CommData.getFilePathAppended(byDocumentDir: zipFileName) ?? ""
        CommData.deleteFileIfExist(zipFilePath)
        SSZipArchive.createZipFile(atPath: zipFilePath, withFilesAtPaths: filePathArray)

        // remove old xml files
        DispatchQueue.main.asyncAfter(deadline: .now()+kUploadHandleDelay) {

            for filePath in filePathArray {
                CommData.deleteFileIfExist(filePath)
            }

            // queue image file and zip file into upload queue
            self.globalInfo.loadFTPSetting()
            
            // zip file
            let zipUploadItem = UploadItem(context: self.globalInfo.managedObjectContext, forSave: true)
            zipUploadItem.ftpHostname = self.globalInfo.ftpHostname
            zipUploadItem.ftpUsername = self.globalInfo.ftpUsername
            zipUploadItem.ftpPassword = self.globalInfo.ftpPassword
            zipUploadItem.companyName = self.globalInfo.ftpRoot
            zipUploadItem.localName = zipFileName
            let root = self.globalInfo.ftpRoot
            let routeNumber = self.globalInfo.routeControl?.routeNumber ?? ""
            zipUploadItem.ftpPath = "/\(root)/REPS/\(routeNumber)/Upload/\(zipFileName)"
            zipUploadItem.queuedDate = Date()
            //zipUploadItem.shouldPostpone = shouldPostpone
            
            GlobalInfo.saveCache()

            self.startIfNeeded(completionHandler: completionHandler)
        }
    }

    func scheduleUpload(localFileName: String, remoteFileName: String, uploadItemType: UploadItemType) {

        let globalInfo = GlobalInfo.shared
        
        // self.requestRemoveUploadWithSameLocalName(localName: localFileName)
        
        let uploadItem = UploadItem(context: globalInfo.managedObjectContext, forSave: true)
        uploadItem.ftpHostname = globalInfo.ftpHostname
        uploadItem.ftpUsername = globalInfo.ftpUsername
        uploadItem.ftpPassword = globalInfo.ftpPassword
        uploadItem.companyName = globalInfo.ftpRoot
        uploadItem.localName = localFileName
        let root = globalInfo.ftpRoot
        let routeNumber = globalInfo.routeControl?.routeNumber ?? ""

        if uploadItemType == .normalCustomerFile {
            uploadItem.ftpPath = "/\(root)/REPS/\(routeNumber)/Upload/\(remoteFileName)"
        }
        else if uploadItemType == .customerCatalog {
            uploadItem.ftpPath = "/\(root)/CustomerCatalog/\(remoteFileName)"
        }
        uploadItem.queuedDate = Date()
        //uploadItem.shouldPostpone = shouldPostpone
        
        GlobalInfo.saveCache()

        self.startIfNeeded(completionHandler: nil)
    }

    func uploadVisit(selectedCustomer: CustomerDetail, completionHandler: (() -> ())?) {
        
        let chainNo = selectedCustomer.chainNo ?? ""
        let custNo = selectedCustomer.custNo ?? ""
        let orderHeaderArray = OrderHeader.getBy(context: globalInfo.managedObjectContext, chainNo: chainNo, custNo: custNo)
        let notUploadedHeaderArray = orderHeaderArray.filter { (orderHeader) -> Bool in
            return orderHeader.isSaved == true && orderHeader.isUploaded == false
        }

        for orderHeader in notUploadedHeaderArray {
            orderHeader.scheduleUpload()
        }

        let now = Date()

        // upload visit upload
        var transactionArray = [UTransaction]()

        let visit = Visit.make(chainNo: chainNo, custNo: custNo, docType: "VIS", date: now, customerDetail: selectedCustomer, reference: "")
        transactionArray.append(visit.makeTransaction())

        var filePathArray = [String]()

        let visitPath = Visit.saveToXML(visitArray: [visit])
        filePathArray.append(visitPath)

        let uploadManager = globalInfo.uploadManager
        uploadManager?.zipAndScheduleUpload(filePathArray: filePathArray, completionHandler: completionHandler)
    }
    /*
    func recoverAllPostpones() {
        UploadItem.resetAllPostpones(context: globalInfo.managedObjectContext)
    }*/
    
    /*
    func requestRemoveUploadWithSameLocalName(localName: String) {
        let allUploadItems = UploadItem.getAll(context: globalInfo.managedObjectContext, shouldExcludePostponed: false)
        for uploadItem in allUploadItems {
            let oldLocalName = uploadItem.localName ?? ""
            if oldLocalName == localName {
                uploadItem.shouldRemoved = true
                //UploadItem.deleteUploadItem(context: globalInfo.managedObjectContext, uploadItem: uploadItem)
            }
        }
    }*/
}
