//
//  AppDelegate.swift
//  BeaconBlu
//
//  Created by Peter DeMartini on 11/3/14.
//  Copyright (c) 2014 Octoblu, Inc. All rights reserved.
//

import UIKit
import MeshbluBeaconKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, MeshbluBeaconKitDelegate {
  var window: UIWindow?
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
    
    let meshbluBeaconKit = MeshbluBeaconKit(uuid:"CF593B78-DA79-4077-ABA3-940085DF45CA", delegate: self)
    
    return true
  }
  
  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
}

extension AppDelegate: MeshbluBeaconKitDelegate {
  
  func proximityChanged(code: Int) {
    NSLog("proximityChanged")
    var message : String
    switch code {
    case 3:
      message = "Far away from beacon"
    case 2:
      message = "You are near the beacon"
    case 1:
      message = "Immediate proximity to beacon"
    case 0:
      message = "No beacons are nearby"
    default:
      message = "No beacons are nearby"
    }
    
    let viewController = getMainControler()
    viewController.updateLocation(message, code: code)
    self.updateMainViewWithMessage(message)
    
  }
  
  func getMainControler() -> MainViewController {
    let viewController:MainViewController = window!.rootViewController as! MainViewController
    return viewController
  }

  func updateMainViewWithMessage(message: String){
    let viewController = getMainControler()
    NSLog(message)
    viewController.message = message
    viewController.tableView!.reloadData()
  }
}