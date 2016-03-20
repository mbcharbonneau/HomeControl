//
//  AppDelegate.swift
//  Home Control
//
//  Created by mbcharbonneau on 7/20/15.
//  Copyright (c) 2015 Once Living LLC. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, LoggingObject, UIApplicationDelegate {

    var window: UIWindow?
    var rootViewController: RootViewController? {
        get {
            guard let navigationController = window?.rootViewController as? UINavigationController else { return nil }
            return navigationController.topViewController as? RootViewController
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        RoomSensor.registerSubclass()
        SwitchedDevice.registerSubclass()

        Parse.setApplicationId( Configuration.Parse.AppID, clientKey:Configuration.Parse.ClientKey )
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Badge, .Alert, .Sound], categories: nil))
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        UINavigationBar.appearance().tintColor = Configuration.Colors.Blue
        SlidingToggleButton.appearance().tintColor = Configuration.Colors.Blue
        
        log("Application finished launching.")
        
        return true
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        log("Performing background fetch...")

        guard let dataController = rootViewController?.dataController else { return completionHandler(.Failed) }

        dataController.refresh() { (success, error) in
            completionHandler(success ? .NewData : .Failed)
            self.log("Background fetch complete.")
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        log("Application entered background state.")
        LogController.sharedController.archiveMessages()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        log("Application became active.")
        if let dataController = rootViewController?.dataController {
            dataController.locationController.requestLocationUpdate()
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        log("Application is terminating.")
    }
}
