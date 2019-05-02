//
//  AppDelegate.swift
//  Nuke
//
//  Created by Owen Campbell on 2018-08-22.
//  Copyright © 2018 Owen Campbell. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        api = GiantBombAPI(apiKey: "")
//        api?.getShows(limit:nil, offset: nil, sort: nil) { result in
//            switch result {
//            case .failure(let error):
//                print(error)
//            case .success(let shows):
//                for show in shows {
//                    print(show.name)
//                }
//            }
//        }
        
//        let urlSessionConfig = URLSessionConfiguration.default
//        urlSessionConfig.requestCachePolicy = .useProtocolCachePolicy
//        let session = URLSession(configuration: urlSessionConfig)
//        
//        let keychainManager = KeychainManager()
//        keychainManager.removeApiKey()
//        let apiKey = keychainManager.getApiKey()
//        let networkController = NetworkController(apiKey: apiKey ?? "", session: session)
//        
//        let vc = window?.rootViewController
//        
//        if let svvc = vc as? UISplitViewController,
//            let nvvc = svvc.viewControllers.first as? UINavigationController,
//            let clvc = nvvc.viewControllers.last as? CategoryListViewController {
//            clvc.networkController = networkController
//        }
        
//        let resource = ShowsResource()
//        
//        let task = networkController.load(with: resource) { (result) in
//            switch result {
//            case .failure(let error):
//                print(error)
//            case .success(let response):
//                var sorted = response
//                sorted.results.sort { (first, second) in
//                    first.position > second.position
//                }
//                print(sorted.description)
//            }
//        }
//        
//        var videoResource = VideosResource()
//        
//        let videoTask = networkController.load(with: videoResource) { (result) in
//            switch result {
//            case .failure(let error):
//                print(error)
//            case .success(let response):
//                print(response.description)
//            }
//        }
//        
//        videoResource.filter(show: 2)
//        
//        let filteredVideoTask = networkController.load(with: videoResource) { (result) in
//            switch result {
//            case .failure(let error):
//                print(error)
//            case .success(let response):
//                print(response.description)
//            }
//        }
        
//        let authTask = networkController.authenticate(with: "5CA587") { result in
//            switch result {
//            case .failure(let error):
//                print(error)
//            case .success(let key):
//                print(key)
//            }
//        }
        
        
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


}

