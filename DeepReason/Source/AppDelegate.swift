//
//  AppDelegate.swift
//  DeepReason
//
//  Created by Sierra on 7/17/17.
//  Copyright © 2017 Sierra. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import HockeySDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        BITHockeyManager.shared().configure(withIdentifier: "7ae19d2dc70a42358c946fc5b298580e")
        BITHockeyManager.shared().crashManager.isMachExceptionHandlerEnabled = true
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation()

        self.configureUserNotifications()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
 
    func applicationDidEnterBackground(_ application: UIApplication) {
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "lastTime")
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        let diff = Date().timeIntervalSince1970 - UserDefaults.standard.double(forKey: "lastTime")
        if (diff > 10) {
            let userDefaults = UserDefaults.standard
            let token = userDefaults.string(forKey: UserProfile.token) ?? ""
            if (token == "") {
                return
            }
            let param : Parameters = [
                UserProfile.token: token,
                "activity": Int(diff)
            ]
            Alamofire.request(ACTIVITY_ENDPOINT, method: .post, parameters: param, encoding: URLEncoding.default).responseJSON { response in
                switch response.result {
                case .failure(let _):
                    return
                default:
                    break
                }
                if let data = response.data {
                    let json = JSON(data: data)
                    let status = json["status"].string!
                    switch status {
                    case "fail":
                        print("1")
                        return
                    default:
                        print("2")
                        break
                    }
                }
            }
 
        }
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func configureUserNotifications() {
        let rejectAction = UIMutableUserNotificationAction()
        rejectAction.activationMode = .background
        rejectAction.title = "Reject"
        rejectAction.identifier = "reject"
        rejectAction.isDestructive = true
        rejectAction.isAuthenticationRequired = false
        
        let acceptAction = UIMutableUserNotificationAction()
        acceptAction.activationMode = .background
        acceptAction.title = "Accept"
        acceptAction.identifier = "accept"
        acceptAction.isDestructive = false
        acceptAction.isAuthenticationRequired = false
        
        let actionCategory = UIMutableUserNotificationCategory()
        actionCategory.identifier = "ACTIONABLE"
        actionCategory.setActions([rejectAction, acceptAction], for: .default)
        
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: [actionCategory])
        UIApplication.shared.registerUserNotificationSettings(settings)
    }
}

