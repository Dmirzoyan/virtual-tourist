//
//  AppDelegate.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 6/24/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import GoogleMaps

let googleApiKey = "YOUR_GOOGLE_MAPS_API_KEY_HERE"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        GMSServices.provideAPIKey(googleApiKey)
        
        let navigationController = UINavigationController()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        let mapRouter = MapRouterFactory(navigationController: navigationController).make()
        mapRouter.start()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {
        self.saveViewContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {
        self.saveViewContext()
    }
    
    private func saveViewContext() {
//        try? dataController.viewContext.save()
    }
}

