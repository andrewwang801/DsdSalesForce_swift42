//
//  FTPManager.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/18/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import Foundation
import SSZipArchive

class FTPManager: NSObject {

    var isBusy = false
    var networkActivityIndicatorTimer: Timer!
    var requestsManager: GRRequestsManager!

    var ftpHostName = ""
    var ftpUserName = ""
    var ftpPassword = ""
    var ftpRoot = ""
    var territory = ""

    var downloadLocalPath = ""
    var downloadRemotePath = ""
    var downloadFileNameArray = [String]()
    var downloadItemCount = 0

    let kCancelTimerInterval = 100.0
    var cancelTimer: Timer?

    var shouldShowHUD = false

    let globalInfo = GlobalInfo.shared

    enum DownloadType {
        case xml
        case directory
        case directoryFiles
    }

    var downloadType: DownloadType = .xml

    var hud: MBProgressHUD?

    var completionHandler: ((Bool, String)->())?

    override init() {
        super.init()

        isBusy = false
        //Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(FTPManager.onCheckNetworkActivityIndicator(_:)), userInfo: nil, repeats: true)
    }

    func onCheckNetworkActivityIndicator(_ sender: Any) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = isBusy
    }

    func setupManager() {
        requestsManager = GRRequestsManager(hostname: ftpHostName, user: ftpUserName, password: ftpPassword)
        requestsManager.delegate = self
    }

    func stop() {
        self.requestsManager.stopAndCancelAllRequests()
    }

    func downloadXmls(hostname: String, user: String, password: String, root: String, territory: String, shouldShowHUD: Bool, completion: ((Bool, String) -> ())?) {
        if isBusy == true {
            completion?(false, "Manager is busy")
            return
        }

        self.ftpHostName = hostname
        self.ftpUserName = user
        self.ftpPassword = password
        self.ftpRoot = root
        self.territory = territory
        self.shouldShowHUD = shouldShowHUD
        self.completionHandler = completion

        self.setupManager()

        let remotePath = "/\(root)/REPS/000000/Download/\(territory).zip"
        let localPath = CommData.getFilePathAppended(byCacheDir: "\(territory).zip") ?? ""
        downloadRemotePath = remotePath
        downloadLocalPath = localPath

        self.downloadType = .xml

        isBusy = true

        if shouldShowHUD == true {
            hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow, animated: true)
        }

        requestsManager.addRequestForDownloadFile(atRemotePath: remotePath, toLocalPath: downloadLocalPath)
        requestsManager.startProcessingRequests()
    }

    func downloadDirectory(hostname: String, user: String, password: String, root: String, territory: String, remoteDirName: String, localDirName: String, shouldShowHUD: Bool, completion: ((Bool, String) -> ())?) {
        if isBusy == true {
            completion?(false, "Manager is busy")
            return
        }

        // create catalog directory
        let localDirPath = CommData.getFilePathAppended(byCacheDir: localDirName) ?? ""
        CommData.createDirectory(localDirPath)

        self.ftpHostName = hostname
        self.ftpUserName = user
        self.ftpPassword = password
        self.ftpRoot = root
        self.territory = territory
        self.shouldShowHUD = shouldShowHUD
        self.completionHandler = completion

        self.setupManager()

        downloadRemotePath = "/\(root)/\(remoteDirName)"
        downloadLocalPath = localDirPath

        self.downloadType = .directory

        isBusy = true

        if shouldShowHUD == true {
            hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow, animated: true)
        }

        requestsManager.addRequestForListDirectory(atPath: downloadRemotePath)
        requestsManager.startProcessingRequests()
    }

    func downloadDirectoryFiles(hostname: String, user: String, password: String, root: String, territory: String, remoteDirName: String, remoteFileNames: [String], localDirName: String, shouldShowHUD: Bool, completion: ((Bool, String) -> ())?) {
        if isBusy == true {
            completion?(false, "Manager is busy")
            return
        }

        // create catalog directory
        let localDirPath = CommData.getFilePathAppended(byCacheDir: localDirName) ?? ""
        CommData.createDirectory(localDirPath)

        self.ftpHostName = hostname
        self.ftpUserName = user
        self.ftpPassword = password
        self.ftpRoot = root
        self.territory = territory
        self.shouldShowHUD = shouldShowHUD
        self.completionHandler = completion

        self.setupManager()

        downloadRemotePath = "/\(root)/\(remoteDirName)"
        downloadLocalPath = localDirPath
        downloadFileNameArray = remoteFileNames

        self.downloadType = .directoryFiles

        isBusy = true

        if shouldShowHUD == true {
            hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow, animated: true)
        }

        requestsManager.addRequestForListDirectory(atPath: downloadRemotePath)
        requestsManager.startProcessingRequests()
    }

    func uploadFile(hostname: String, user: String, password: String, localPath: String, uploadPath: String, shouldShowHUD: Bool, completion: ((Bool, String) -> ())?) {
        if isBusy == true {
            completion?(false, "Manager is busy")
            return
        }

        self.ftpHostName = hostname
        self.ftpUserName = user
        self.ftpPassword = password
        self.shouldShowHUD = shouldShowHUD
        self.completionHandler = completion

        self.setupManager()

        isBusy = true

        if shouldShowHUD == true {
            hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow, animated: true)
        }

        requestsManager.addRequestForUploadFile(atLocalPath: localPath, toRemotePath: uploadPath)
        requestsManager.startProcessingRequests()
    }

    func extractZipFile() {
        let destinationPath = CommData.getFilePathAppended(byCacheDir: kXMLDirName) ?? ""
        CommData.deleteFileIfExist(destinationPath)

        SSZipArchive.unzipFile(atPath: downloadLocalPath, toDestination: destinationPath, overwrite: true, password: nil, progressHandler: nil) { (message, success, error) in
            if success == true {
                self.finishDownload(success: true, message: "")
            }
            else {
                self.finishDownload(success: false, message: "FTP downloaded file extraction failed: \(error?.localizedDescription ?? "")")
            }
        }
    }

    func finishDownload(success: Bool, message: String) {
        stopCancelTimer()
        self.isBusy = false
        requestsManager.stopAndCancelAllRequests()
        DispatchQueue.main.async {
            self.hud?.hide(true)
            self.completionHandler?(success, message)
        }
    }

    @objc func onCancelIntervalExpired(_ sender: Any) {
        cancelTimer = nil
        NSLog("FTPManager Cancel interval expired")
        finishDownload(success: false, message: "Cancel interval expired.")
    }

    func triggerCancelTimer() {
        stopCancelTimer()
        cancelTimer = Timer.scheduledTimer(timeInterval: kCancelTimerInterval, target: self, selector: #selector(FTPManager.onCancelIntervalExpired(_:)), userInfo: nil, repeats: false)
    }

    func stopCancelTimer() {
        if cancelTimer != nil {
            NSLog("FTPManager stopped cancel timer")
            cancelTimer!.invalidate()
            cancelTimer = nil
        }
    }
}

extension FTPManager: GRRequestsManagerDelegate {

    func requestsManager(_ requestsManager: GRRequestsManagerProtocol!, didScheduleRequest request: GRRequestProtocol!) {

        NSLog("requestManager:didScheduleRequest")
        triggerCancelTimer()
    }

    func requestsManager(_ requestsManager: GRRequestsManagerProtocol!, didCompleteListingRequest request: GRRequestProtocol!, listing: [Any]!) {

        stopCancelTimer()

        /*
        if downloadType == .logo {
            var isFound = false
            var shouldDownload = false
            for _fileInfo in listing {
                guard let fileInfo = _fileInfo as? [CFString: Any] else {continue}
                let fileName = fileInfo[kCFFTPResourceName] as? String ?? ""
                if fileName == kCompanyLogoFileName {
                    isFound = true
                }
                else {
                    continue
                }

                let fileSize = fileInfo[kCFFTPResourceSize] as? UInt64 ?? 0

                let isExist = CommData.isExistingFile(atPath: downloadLocalPath)
                if isExist == false {
                    shouldDownload = true
                }
                else {
                    let localFileSize = CommData.getFileSize(downloadLocalPath)
                    if fileSize == localFileSize {
                        shouldDownload = false
                    }
                    else {
                        shouldDownload = true
                    }
                }
                break
            }
            if isFound == false {
                finishDownload(success: false, message: "FTP Logo download failed. Can't find the logo file.")
            }
            else {
                if shouldDownload == false {
                    finishDownload(success: true, message: "")
                }
                else {
                    requestsManager.addRequestForDownloadFile(atRemotePath: downloadRemotePath, toLocalPath: downloadLocalPath)
                    requestsManager.startProcessingRequests()
                }
            }
        }*/
        if downloadType == .directoryFiles {
            var shouldDownloadArray = [String]()
            for _fileInfo in listing {
                guard let fileInfo = _fileInfo as? [CFString: Any] else {continue}
                let fileName = fileInfo[kCFFTPResourceName] as? String ?? ""
                let fileSize = fileInfo[kCFFTPResourceSize] as? UInt64 ?? 0

                if fileName == "." || fileName == ".." {
                    continue
                }

                let index = downloadFileNameArray.index(of: fileName)
                if index == nil {
                    continue
                }

                let localPath = downloadLocalPath + "/" + fileName
                let isExist = CommData.isExistingFile(atPath: localPath)
                if isExist == false {
                    shouldDownloadArray.append(fileName)
                }
                else {
                    let localFileSize = CommData.getFileSize(localPath)
                    if fileSize != localFileSize {
                        shouldDownloadArray.append(fileName)
                    }
                }
            }

            if shouldDownloadArray.count == 0 {
                finishDownload(success: true, message: "")
            }
            else {
                for fileName in shouldDownloadArray {
                    let remotePath = downloadRemotePath + "/" + fileName
                    let localPath = downloadLocalPath + "/" + fileName
                    requestsManager.addRequestForDownloadFile(atRemotePath: remotePath, toLocalPath: localPath)
                }
                downloadItemCount = shouldDownloadArray.count
                requestsManager.startProcessingRequests()
            }
        }
        else if downloadType == .directory {

            var shouldDownloadArray = [String]()
            for _fileInfo in listing {
                guard let fileInfo = _fileInfo as? [CFString: Any] else {continue}
                let fileName = fileInfo[kCFFTPResourceName] as? String ?? ""
                let fileSize = fileInfo[kCFFTPResourceSize] as? UInt64 ?? 0

                if fileName == "." || fileName == ".." {
                    continue
                }

                let localPath = downloadLocalPath + "/" + fileName
                let isExist = CommData.isExistingFile(atPath: localPath)
                if isExist == false {
                    shouldDownloadArray.append(fileName)
                }
                else {
                    let localFileSize = CommData.getFileSize(localPath)
                    if fileSize != localFileSize {
                        shouldDownloadArray.append(fileName)
                    }
                }
            }

            if shouldDownloadArray.count == 0 {
                finishDownload(success: true, message: "")
            }
            else {
                for fileName in shouldDownloadArray {
                    let remotePath = downloadRemotePath + "/" + fileName
                    let localPath = downloadLocalPath + "/" + fileName
                    requestsManager.addRequestForDownloadFile(atRemotePath: remotePath, toLocalPath: localPath)
                }
                downloadItemCount = shouldDownloadArray.count
                requestsManager.startProcessingRequests()
            }
        }
    }

    func requestsManager(_ requestsManager: GRRequestsManagerProtocol!, didCompleteCreateDirectoryRequest request: GRRequestProtocol!) {
        stopCancelTimer()
        NSLog("requestManager:didCompleteCreateDirectoryRequest:")
    }

    func requestsManager(_ requestsManager: GRRequestsManagerProtocol!, didCompleteDeleteRequest request: GRRequestProtocol!) {
        stopCancelTimer()
        NSLog("requestManager:didCompleteDeleteRequest:")
    }

    func requestsManager(_ requestsManager: GRRequestsManagerProtocol!, didCompletePercent percent: Float, forRequest request: GRRequestProtocol!) {
        stopCancelTimer()
        NSLog("requestManager:didCompletePercent: \(percent)")
    }

    func requestsManager(_ requestsManager: GRRequestsManagerProtocol!, didCompleteUploadRequest request: GRDataExchangeRequestProtocol!) {
        NSLog("requestManager:didCompleteUploadRequest:")
        finishDownload(success: true, message: "")
    }

    func requestsManager(_ requestsManager: GRRequestsManagerProtocol!, didCompleteDownloadRequest request: GRDataExchangeRequestProtocol!) {
        NSLog("requestManager:didCompleteDownloadRequest:")
        triggerCancelTimer()
        if downloadType == .xml {
            extractZipFile()
        }
        else if downloadType == .directory || downloadType == .directoryFiles {
            downloadItemCount -= 1
            if downloadItemCount <= 0 {
                finishDownload(success: true, message: "")
            }
            else {
                triggerCancelTimer()
            }
        }
    }

    func requestsManager(_ requestsManager: GRRequestsManagerProtocol!, didFailWritingFileAtPath path: String!, forRequest request: GRDataExchangeRequestProtocol!, error: Error!) {
        NSLog("requestManager:didFailWritingFileAt: \(path)")
        if downloadType != .directory && downloadType != .directoryFiles {
            finishDownload(success: false, message: "FTP download failed: \(error.localizedDescription)")
        }
        else {
            downloadItemCount -= 1
            if downloadItemCount <= 0 {
                finishDownload(success: true, message: "")
            }
            else {
                triggerCancelTimer()
            }
        }
    }

    func requestsManager(_ requestsManager: GRRequestsManagerProtocol!, didFailRequest request: GRRequestProtocol!, withError error: Error!) {
        NSLog("requestManager:didFailRequest: \(error.localizedDescription)")
        finishDownload(success: false, message: "FTP download failed: \(error.localizedDescription)")
    }

}
