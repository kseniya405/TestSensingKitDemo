//
//  AppDelegate.swift
//  TestSensingKit
//
//  Created by Ксения Шкуренко on 01.10.2020.
//

import UIKit
//import DropDown
//import GooglePlaces


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var navigationController: UINavigationController?
    let loginVCIdentifier = "LoginViewController"
    let containerVCIdentifier = "ContainerViewController"
    let homeVCIdentifier = "HomeViewController"
    
    let googleMapsApiKey = "AIzaSyBKQI1fv2mUXURpaQGFztfT0U9yOTM0yUE"
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        window = UIWindow()
                
//        if UserProfile.shared.token?.isEmpty ?? true {
//            let startViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: loginVCIdentifier) as! LoginViewController
//            navigationController = UINavigationController(rootViewController: startViewController)
//
//        } else {
//            let startViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: containerVCIdentifier) as! ContainerViewController
//            startViewController.identifier = .home
//            navigationController = UINavigationController(rootViewController: startViewController)
//        }
        
        // Override point for customization after application launch.
        
                    let startViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
                    navigationController = UINavigationController(rootViewController: startViewController)
        navigationController?.navigationBar.isHidden = true
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
                
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // 1. Convert device token to string
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        // 2. Print device token to use for PNs payloads
        print("Device Token: \(token)")
        let bundleID = Bundle.main.bundleIdentifier;
        print("Bundle ID: \(token) \(String(describing: bundleID))");
        // 3. Save the token to local storeage and post to app server to generate Push Notification. ...
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("failed to register for remote notifications: \(error.localizedDescription)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("Received push notification: \(userInfo)")
        let aps = userInfo["aps"] as! [String: Any]
        print("\(aps)")
    }
    
    
}
