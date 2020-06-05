//
//  AppDelegate.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 7/3/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData
import QuickLook
import UserNotifications
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let _ = GlobalInfo.shared
        // Use the Firebase library to configure APIs.
        FirebaseApp.configure()
        
        GMSServices.provideAPIKey("AIzaSyDXcFkYnf2e1498ZugjFhd9N-33O57SaHU")
        Utils.buildBaseURLMap()

        initQbCredentials()

        // app was launched from push notification, handling it
        let remoteNotification: NSDictionary! = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? NSDictionary
        if (remoteNotification != nil) {
            ServicesManager.instance().notificationService.pushDialogID = remoteNotification["SA_STR_PUSH_NOTIFICATION_DIALOG_ID".localized] as? String
        }

        return true
    }

    func initQbCredentials() {

        // Quick Blox
        QBSettings.applicationID = kQBApplicationID;
        QBSettings.authKey = kQBAuthKey
        QBSettings.authSecret = kQBAuthSecret
        QBSettings.accountKey = kQBAccountKey
        // enabling carbons for chat
        QBSettings.carbonsEnabled = true
        // Enables Quickblox REST API calls debug console output.
        QBSettings.logLevel = .nothing

        QBSettings.apiEndpoint = kAPIEndPoint
        QBSettings.chatEndpoint = kChatEndPoint

        // Enables detailed XMPP logging in console output.
        QBSettings.enableXMPPLogging()
    }

    // MARK: Remote notifications
    func registerForRemoteNotification() {

        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_,_  in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }

        UIApplication.shared.registerForRemoteNotifications()
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        let deviceIdentifier: String = UIDevice.current.identifierForVendor!.uuidString
        let subscription: QBMSubscription! = QBMSubscription()

        subscription.notificationChannel = QBMNotificationChannel.APNS
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = deviceToken
        QBRequest.createSubscription(subscription, successBlock: { (response: QBResponse!, objects: [QBMSubscription]?) -> Void in
            NSLog("Subscribed in push notification")
        }) { (response: QBResponse!) -> Void in
            NSLog("Failed in push notification subscription")
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Push failed to register with error: %@", error)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {

        print("my push is: %@", userInfo)

        // calling dispatch async for push notification handling to have priority in main queue
        DispatchQueue.main.async {

            ServicesManager.instance().notificationService.handlePushNotificationWithDelegate(delegate: self)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {

        DialogUtils.refreshAppBadge()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Logging out from chat.
        if Utils.dialogsManager != nil {
            ServicesManager.instance().chatService.disconnect(completionBlock: nil)
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Logging in to chat.
        if Utils.dialogsManager != nil {
            //SVProgressHUD.show(withStatus: "SA_STR_CONNECTING_TO_CHAT".localized, maskType: SVProgressHUDMaskType.none)
            ServicesManager.instance().chatService.connect(completionBlock: nil)
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Logging out from chat.
        if Utils.dialogsManager != nil {
            ServicesManager.instance().chatService.disconnect(completionBlock: nil)
        }
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.scott.CoreDataTest1" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "DSDSalesforce", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            var options = [ NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true ] as [String : Any]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }

        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    var queueManagedObjectContext: NSManagedObjectContext {
        let coordinator = self.persistentStoreCoordinator
        let _managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        _managedObjectContext.persistentStoreCoordinator = coordinator
        return _managedObjectContext
    }

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
                //try managedObjectContext.save()
            
                managedObjectContext.automaticallyMergesChangesFromParent = true
                managedObjectContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
                managedObjectContext.performAndWait { () -> Void in
                    do {
                        try managedObjectContext.save()
                    }
                    catch {
                        let nserror = error as NSError
                        NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                    }
                    NSLog("OrderDetail is saved")
                }
        }
    }
}

// MARK: -NotificationServiceDelegate
extension AppDelegate: NotificationServiceDelegate {

    func notificationServiceDidStartLoadingDialogFromServer() {
    }

    func notificationServiceDidFinishLoadingDialogFromServer() {
    }

    func notificationServiceDidSucceedFetchingDialog(chatDialog: QBChatDialog!) {
        /*
         let navigatonController: UINavigationController! = self.window?.rootViewController as! UINavigationController

         let chatController: ChatViewController = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
         chatController.dialog = chatDialog

         let dialogWithIDWasEntered = ServicesManager.instance().currentDialogID
         if !dialogWithIDWasEntered.isEmpty {
         // some chat already opened, return to dialogs view controller first
         navigatonController.popViewController(animated: false);
         }

         navigatonController.pushViewController(chatController, animated: true)*/
    }

    func notificationServiceDidFailFetchingDialog() {
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("my push is: %@", userInfo)
        DialogUtils.refreshAppBadge()

        // open main activity
        //let mainVC = UIViewController.getViewController(storyboardName: "Main", storyboardID: "MainVC")
        //mainVC.setAsRoot()

        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //completionHandler([.alert, .badge, .sound])
    }
}

