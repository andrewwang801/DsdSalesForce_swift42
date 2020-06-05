//
//  APIManager.swift
//  iRis
//
//  Created by iOS Developer on 6/29/16.
//  Copyright © 2016 Q-Scope. All rights reserved.
//

import UIKit
import Alamofire

class APIManager: NSObject {

    static let kSMSServerURL = "http://api.smsbroadcast.com.au"

    static func doNormalRequest(baseURL: String, methodName: String, httpMethod: String, params: [String: Any], shouldShowHUD: Bool, completion: @escaping (Any?, String) -> Void) {
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 20

        NSLog("methodName: \(methodName), params: \(params)")
        var hud: MBProgressHUD?
        if shouldShowHUD == true {
            if UIApplication.shared.keyWindow == nil {
                hud = nil
            }
            else {
                DispatchQueue.main.async {
                    hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow, animated: true)
                }
            }
        }
        
        let apiURL = "\(baseURL)\(methodName)"
        let _method: HTTPMethod = httpMethod == "POST" ? HTTPMethod.post : HTTPMethod.get
        
//        Alamofire.request("\(apiURL)", method: _method, parameters: params)
        manager.request("\(apiURL)", method: _method, parameters: params)
        .validate()
        .responseJSON { response in
            guard response.result.isSuccess else {
                NSLog("Response error: \(response.result.error!)")
                hud?.hide(true)
                let errorDesc = response.result.error!.localizedDescription ?? ""
                completion(nil, errorDesc)
                return
            }
            guard let responseData = response.data else {
                NSLog("Invalid response: \(response.result.error!)")
                hud?.hide(true)
                let errorDesc = response.result.error!.localizedDescription ?? ""
                completion(nil, errorDesc)
                return
            }
            hud?.hide(true)
            // Log.debug("response: \(responseData)")
            completion(responseData, "")
            return
        }
    }

    static func doNormalRequest(baseURL: String, methodName: String, httpMethod: String, headers: [String: String], params: [String: Any], shouldShowHUD: Bool, completion: @escaping (Any?, String) -> Void) {
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 20
        
        NSLog("methodName: \(methodName), param: \(params)")

        var hud: MBProgressHUD?
        if shouldShowHUD == true {
            DispatchQueue.main.async {
                if UIApplication.shared.keyWindow == nil {
                    hud = nil
                }
                else {
                    hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow, animated: true)
                }
            }
        }

        let apiURL = "\(baseURL)\(methodName)"
        let _method: HTTPMethod = httpMethod == "POST" ? HTTPMethod.post : HTTPMethod.get

//        Alamofire.request(apiURL, method: _method, parameters: params, encoding: URLEncoding.default, headers: headers)
        manager.request(apiURL, method: _method, parameters: params, encoding: URLEncoding.default, headers: headers)
            .responseJSON { (response) in
                guard response.result.isSuccess else {
                    NSLog("Response error: \(response.result.error!)")
                    hud?.hide(true)
                    completion(nil, "response error")
                    return
                }
                guard let responseData = response.data else {
                    NSLog("Invalid response: \(response.result.error!)")
                    hud?.hide(true)
                    completion(nil, "response error")
                    return
                }
                hud?.hide(true)
                completion(responseData, "")
                return
        }
    }

    static func doNormalJSONRequest(baseURL: String, methodName: String, httpMethod: String, headers: [String: String], params: [String: Any], shouldShowHUD: Bool, completion: @escaping (Any?, String) -> Void) {

        NSLog("methodName: \(methodName), param: \(params)")

        var hud: MBProgressHUD?
        if shouldShowHUD == true {
            if UIApplication.shared.keyWindow == nil {
                hud = nil
            }
            else {
                DispatchQueue.main.async {
                    hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow, animated: true)
                }
            }
        }

        let apiURL = "\(baseURL)\(methodName)"
        let _method: HTTPMethod = httpMethod == "POST" ? HTTPMethod.post : HTTPMethod.get

        Alamofire.request(apiURL, method: _method, parameters: params, encoding: Alamofire.JSONEncoding.default, headers: headers)
            .responseJSON { (response) in
                guard response.result.isSuccess else {
                    NSLog("Response error: \(response.result.error!)")
                    hud?.hide(true)
                    let errorDesc = response.result.error?.localizedDescription ?? ""
                    completion(nil, errorDesc)
                    return
                }
                guard let responseData = response.data else {
                    NSLog("Invalid response: \(response.result.error!)")
                    hud?.hide(true)
                    let errorDesc = response.result.error?.localizedDescription ?? ""
                    completion(nil, errorDesc)
                    return
                }
                hud?.hide(true)
                completion(responseData, "")
                return
        }
    }

    static func downloadMedia(sourceURL: String, downloadPath: String, completion: @escaping (Bool, String) -> Void) {

        //NSLog("methodName: \(methodName), filepath: \(title)")
        var hud: MBProgressHUD?
        if UIApplication.shared.keyWindow == nil {
            hud = nil
        }
        else {
            DispatchQueue.main.async {
                hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow, animated: true)
            }
        }

        NSLog("Download from \(sourceURL)")

        let destination: DownloadRequest.DownloadFileDestination = { url, response in
            let fileURL = URL(fileURLWithPath: downloadPath)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        backgroundManager.download(sourceURL, to: destination)
            .downloadProgress { progress in
                print("Download Progress: \(progress.fractionCompleted)")
            }
            .responseData { response in
                hud?.hide(true)
                if let data = response.result.value {
                    let json = JSON(data: data)
                    if let error = json["error"].string {
                        completion(false, error)
                    }
                    else {
                        completion(true, "")
                    }
                }
                else {
                    completion(false, response.error?.localizedDescription ?? "")
                    NSLog(response.error?.localizedDescription ?? "")
                }
            }
    }

    static func downloadFile(sourceURL: String, downloadPath: String, completion: @escaping (Bool, String) -> Void) {

        NSLog("Download from \(sourceURL)")

        let destination: DownloadRequest.DownloadFileDestination = { url, response in
            let fileURL = URL(fileURLWithPath: downloadPath)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        backgroundManager.download(sourceURL, to: destination)
            .downloadProgress { progress in
                print("Download Progress: \(progress.fractionCompleted)")
            }
            .responseData { response in
                if let data = response.result.value {
                    let json = JSON(data: data)
                    if let error = json["error"].string {
                        completion(false, error)
                    }
                    else {
                        completion(true, "")
                    }
                }
                else {
                    completion(false, response.error?.localizedDescription ?? "")
                    NSLog(response.error?.localizedDescription ?? "")
                }
        }
    }

    static func getBasicCredential(userName: String, password: String) -> String {
        return "Bearer \(userName)"
    }

    // MARK: -- background manager --
    static let backgroundManager: Alamofire.SessionManager = {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? ""
        let configuration = URLSessionConfiguration.background(withIdentifier: bundleIdentifier + ".background")
//        return Alamofire.SessionManager(configuration: URLSessionConfiguration.background(withIdentifier: bundleIdentifier + ".background"))
        return Alamofire.SessionManager(configuration: configuration)
    }()

}
