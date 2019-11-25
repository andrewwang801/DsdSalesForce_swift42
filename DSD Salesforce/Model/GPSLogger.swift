//
//  GPSLogger.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 8/6/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class GPSLogger: NSObject {

    let globalInfo = GlobalInfo.shared
    var interval: Double = 0
    var loggerTimer: Timer?

    func startLogger(interval: Double) {
        stopLogger()
        loggerTimer = Timer(timeInterval: interval, target: self, selector: #selector(GPSLogger.onLoggingHandler), userInfo: nil, repeats: true)
        onLoggingHandler()
    }

    func stopLogger() {
        if loggerTimer != nil {
            loggerTimer!.invalidate()
            loggerTimer = nil
        }
    }

    @objc func onLoggingHandler() {

        // UTransaction
        let now = Date()
        let chainNo = "0"
        let custNo = "0"

        let gpsLog = GPSLog.make(chainNo: chainNo, custNo: custNo, docType: "GPS", date: now, location: globalInfo.getCurrentLocation())
        let gpsLogTransaction = gpsLog.makeTransaction()

        // GPS XML gile
        let gpsLogPath = GPSLog.saveToXML(gpsLogArray: [gpsLog])

        // transaction file
        let transactionPath = UTransaction.saveToXML(transactionArray: [gpsLogTransaction], shouldIncludeLog: true)
        globalInfo.uploadManager.zipAndScheduleUpload(filePathArray: [gpsLogPath, transactionPath])
    }
    
}
