//
//  AppDelegate.swift
//  BeaconBlu
//
//  Created by Peter DeMartini on 11/3/14.
//  Copyright (c) 2014 Octoblu, Inc. All rights reserved.
//

import UIKit
import CoreLocation
import MeshbluBeaconKit
import SwiftyJSON
import SwiftyOAuth
import MeshbluHttp

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, MeshbluBeaconKitDelegate {
  var window: UIWindow?
  var meshbluBeaconKit : MeshbluBeaconKit!
  var inAuth: Bool!
  var meshbluHttp : MeshbluHttp!
  var meshbluConfig : [String:AnyObject]!
  let provider = Provider(
    clientID:     "ee245a67-6dec-431f-a03d-718d73ea076d",
    authorizeURL: "https://oauth.octoblu.com/authorize",
    redirectURL:  "beaconblu://beaconblu.octoblu.com/callback"
  )
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.

    inAuth = false
    self.meshbluHttp = MeshbluHttp(meshbluConfig: [:])
    self.meshbluConfig = [:]
    let settings = NSUserDefaults.standardUserDefaults()
    let uuid = settings.stringForKey("uuid")
    let token = settings.stringForKey("token")
    
    self.meshbluConfig["uuid"] = uuid
    self.meshbluConfig["token"] = token
    self.meshbluBeaconKit = MeshbluBeaconKit(meshbluConfig: meshbluConfig, delegate: self)
    self.startBeacon()
    
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
    let settings = NSUserDefaults.standardUserDefaults()
    let bearerToken = settings.getTokenForProvider(provider)
    if bearerToken == nil && inAuth == false {
      inAuth = true
      provider.state = NSUUID().UUIDString.lowercaseString
      provider.authorize { (result: Result<Token, Error>) -> Void in
        switch result {
        case .Success(let token):
          self.startBeacon()
        case .Failure(let error):
          print(error)
        }
      }
    }
  }
  
  func startBeacon() {
    let settings = NSUserDefaults.standardUserDefaults()
    let bearerToken = settings.getTokenForProvider(provider)

    if bearerToken != nil {
      self.meshbluHttp.setCredentials(bearerToken!.accessToken)
      self.meshbluBeaconKit.start(["CF593B78-DA79-4077-ABA3-940085DF45CA":"iBeaconModules.us"])
    }
  }
  
  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    let settings = NSUserDefaults.standardUserDefaults()
    settings.setObject(false, forKey: "inAuth")
  }
  
  func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
    if #available(iOS 9.0, *) {
      print(url.fragment)
      provider.handleURL(url, options: options)
    } else {
      // Fallback on earlier versions
    }
    
    return true
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
  
  func proximityChanged(response: [String: AnyObject]) {
    var message = ""
    let proximity = response["proximity"] as! [String: AnyObject]
    switch(proximity["code"] as! Int) {
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
    self.updateMainViewWithMessage(message)
    self.meshbluBeaconKit.sendLocationUpdate(response) {
      (result) -> () in
    }
  }
  
  func meshbluBeaconIsNotRegistered() {
    self.meshbluHttp.whoami() { (result) -> () in
      switch result {
      case .Failure(let error):
        print(error)
      case .Success(let whoami):
        let uuid = whoami["uuid"].stringValue
        let data = ["owner":uuid]
        self.meshbluBeaconKit.register(data)
      }
    }
  }
  
  func meshbluBeaconRegistrationSuccess(device: [String: AnyObject]) {
    let settings = NSUserDefaults.standardUserDefaults()
    let uuid = device["uuid"] as! String
    let token = device["token"] as! String

    settings.setObject(uuid, forKey: "uuid")
    settings.setObject(token, forKey: "token")
  }
  
  func beaconEnteredRegion() {
    self.updateMainViewWithMessage("Beacon Entered Region")
  }

  func beaconExitedRegion() {
    self.updateMainViewWithMessage("Beacon Exited Region")
  }
  
}
