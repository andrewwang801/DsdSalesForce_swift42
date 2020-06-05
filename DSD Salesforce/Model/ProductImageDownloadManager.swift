//
//  ProductImageDownloadManager.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 9/2/19.
//  Copyright © 2019 iOS Developer. All rights reserved.
//

import Foundation

class ProductImageDownloadManager: NSObject {

    let globalInfo = GlobalInfo.shared
    var shouldStop = false
    var itemNoArray = [String]()
    var itemNoImageFileNameDictionary: [String: String] = [:]
    var itemNoRemoteImageURLDictionary: [String: String] = [:]
    var productDetailArray = [ProductDetail]()
    //var isBusy = false
    // var isDownloading = false

    func start() {
        collectProductDetailArray()
        startDownload()
    }

    func stop() {
        shouldStop = true
    }

    func collectProductDetailArray() {
        // collect all product details.
        productDetailArray = ProductDetail.getAll(context: globalInfo.managedObjectContext)

        itemNoArray = []
        itemNoImageFileNameDictionary = [:]
        itemNoRemoteImageURLDictionary = [:]

        for productDetail in productDetailArray {
            guard let _imageURL = productDetail.imageURL else {continue}
            var imageURL: String = ""
            /*
            if _imageURL == "" {
                continue
            }*/
            if _imageURL == "" {
                continue
                //imageURL = kProductImageSampleURL
            }
            else {
                imageURL = _imageURL
            }

            let itemNo = productDetail.itemNo ?? ""
            if itemNo == "" {
                continue
            }
            var imageFileName = Utils.getProductImageFileName(itemNo: itemNo)
            if imageFileName == "" {
                imageFileName = itemNo + ".png"
                //continue
            }

            itemNoArray.append(itemNo)
            itemNoImageFileNameDictionary[itemNo] = imageFileName
            itemNoRemoteImageURLDictionary[itemNo] = imageURL
        }
    }

    func startDownload() {

        shouldStop = false
        DispatchQueue.global().async {
            for itemNo in self.itemNoArray {
                if self.shouldStop == true {
                    break
                }
                var shouldDownload = false
                let localImageFileName = self.itemNoImageFileNameDictionary[itemNo] ?? ""
                let catalogPath = CommData.getFilePathAppended(byDocumentDir: kProductCatalogDirName) ?? ""
                let localImageFilePath = catalogPath + "/" + localImageFileName
                let localFileSize = CommData.getFileSize(localImageFilePath)
                let remoteImageURLPath = self.itemNoRemoteImageURLDictionary[itemNo] ?? ""
                guard let remoteFileURL = URL(string: remoteImageURLPath) else {
                    continue
                }
                let remoteFileSize = Int64(Utils.getRemoteFileSize(url: remoteFileURL))
                if localFileSize != remoteFileSize || localFileSize == 0 {
                    // should download file and replace
                    shouldDownload = true
                }

                if shouldDownload == true {
                    let tempFileName = UUID().uuidString
                    let tempFilePath = catalogPath + "/" + tempFileName
                    var isDownloading = true
                    APIManager.downloadFile(sourceURL: remoteImageURLPath, downloadPath: tempFilePath, completion: { (isCompleted, message) in
                        if isCompleted == true {
                            // copy temp file into target path and delete old file
                            let fileManager = FileManager.default
                            try? fileManager.removeItem(atPath: localImageFilePath)
                            try? fileManager.copyItem(atPath: tempFilePath, toPath: localImageFilePath)
                            try? fileManager.removeItem(atPath: tempFilePath)
                        }
                        isDownloading = false
                    })
                    while isDownloading == true {
                        Thread.sleep(forTimeInterval: 0.5)
                    }
                }
                else {
                    Thread.sleep(forTimeInterval: 0.5)
                }
            }
        }
    }

}
