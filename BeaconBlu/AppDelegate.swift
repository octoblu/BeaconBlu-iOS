//
//  AppDelegate.swift
//  BeaconBlu
//
//  Created by Peter DeMartini on 11/3/14.
//  Copyright (c) 2014 Octoblu, Inc. All rights reserved.
//

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
  var window: UIWindow?
  var locationManager: CLLocationManager?
  var lastProximity: CLProximity?
  let iBeaconUUID : NSString = "CF593B78-DA79-4077-ABA3-940085DF45CA"
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
    
    let beaconIdentifier = "iBeaconModules.us"
    let beaconUUID:NSUUID? = NSUUID(UUIDString: self.iBeaconUUID)
    let beaconRegion:CLBeaconRegion = CLBeaconRegion(proximityUUID:beaconUUID, identifier: beaconIdentifier)
    
    locationManager = CLLocationManager()
    
    if(locationManager!.respondsToSelector("requestAlwaysAuthorization")) {
      locationManager!.requestAlwaysAuthorization()
    }
    
    locationManager!.delegate = self
    locationManager!.pausesLocationUpdatesAutomatically = false
    
    locationManager!.startMonitoringForRegion(beaconRegion)
    locationManager!.startRangingBeaconsInRegion(beaconRegion)
    locationManager!.startUpdatingLocation()
    
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

extension AppDelegate: CLLocationManagerDelegate {
  
  func getMainControler() -> MainViewController {
    let viewController:MainViewController = window!.rootViewController as MainViewController
    return viewController
  }
  
  func updateMainViewWithMessage(message: String){
    let viewController = getMainControler()
    NSLog(message)
    viewController.message = message
    viewController.tableView!.reloadData()
  }
  
  func locationManager(manager: CLLocationManager!, didRangeBeacons beacons:[AnyObject]!, inRegion region: CLBeaconRegion!) {
    var message:String = ""
    var code: Int = -1
    if(beacons.count > 0) {
      let nearestBeacon:CLBeacon = beacons[0] as CLBeacon
      
      if(nearestBeacon.proximity == lastProximity ||
        nearestBeacon.proximity == CLProximity.Unknown) {
          return;
      }
      lastProximity = nearestBeacon.proximity;
      
      switch nearestBeacon.proximity {
      case CLProximity.Far:
        message = "Far away from beacon"
        code = 3
      case CLProximity.Near:
        message = "You are near the beacon"
        code = 2
      case CLProximity.Immediate:
        message = "Immediate proximity to beacon"
        code = 1
      case CLProximity.Unknown:
        return
      }
    } else {
      
      if(lastProximity == CLProximity.Unknown) {
        return;
      }
      
      message = "No beacons are nearby"
      code = 0
      lastProximity = CLProximity.Unknown
    }
    let viewController = getMainControler()
    viewController.updateLocation(message, code: code)
    self.updateMainViewWithMessage(message)
  }
  
  func locationManager(manager: CLLocationManager!,
    didEnterRegion region: CLRegion!) {
      manager.startRangingBeaconsInRegion(region as CLBeaconRegion)
      manager.startUpdatingLocation()
      
      self.updateMainViewWithMessage("Beacon Entered Region")
  }
  
  func locationManager(manager: CLLocationManager!,
    didExitRegion region: CLRegion!) {
      manager.stopRangingBeaconsInRegion(region as CLBeaconRegion)
      manager.stopUpdatingLocation()
      
      self.updateMainViewWithMessage("Beacon Exitied Region")
  }
}
