//
//  iBeaconLocation.swift
//  BeaconBlu
//
//  Created by Peter DeMartini on 12/10/14.
//  Copyright (c) 2014 Octoblu, Inc. All rights reserved.
//

import Foundation
import CoreLocation

class iBeaconLocation: NSObject, CLLocationManagerDelegate {
  let iBeaconUUID : NSString = "cf593b78-da79-4077-aba3-940085df45ca"
  let meshbluToUuid : String = "*"
  var locationManager: CLLocationManager = CLLocationManager()
  var beaconRegion: CLBeaconRegion?
  var meshblu: Meshblu?
  let _onUpdate : (String) -> ()?
  let _presentAlert: (UIAlertController) -> ()?
  
  init(uuid: String, token: String, onUpdate: (String) -> (), presentAlert: (UIAlertController) -> ()){
    self._onUpdate = onUpdate
    self._presentAlert = presentAlert
    super.init()
    self.locationManager.delegate = self
    self.locationManager.requestWhenInUseAuthorization()
    self.locationManager.requestAlwaysAuthorization()
    let proximityUuid = NSUUID(UUIDString: self.iBeaconUUID)
    self.beaconRegion = CLBeaconRegion(proximityUUID: proximityUuid, major: 1, minor: 1, identifier: "Holy")
    self.beaconRegion?.notifyEntryStateOnDisplay = true
    self.locationManager.pausesLocationUpdatesAutomatically = false
    self.locationManager.startMonitoringForRegion(self.beaconRegion)
    self.locationManager.startRangingBeaconsInRegion(self.beaconRegion)
    self.meshblu = Meshblu(uuid: uuid, token: token)
  }
  
  func updateStatus(status: CLAuthorizationStatus){
    var title : String?
    
    switch CLLocationManager.authorizationStatus() {
    case CLAuthorizationStatus.Authorized:
      title = "Location Authorized"
    case CLAuthorizationStatus.AuthorizedWhenInUse:
      title = "Location Authorized When In Use"
    case CLAuthorizationStatus.NotDetermined:
      title = "Location Not Determined"
    case CLAuthorizationStatus.Denied:
      title = "Location Denied"
    case CLAuthorizationStatus.Restricted:
      title = "Location Restricted"
    }
    self._onUpdate(title!)
  }
  
  func requestAlwaysAuthorization(){
    let status : CLAuthorizationStatus = CLLocationManager.authorizationStatus()
    self.updateStatus(status)
    
    switch status {
    case .Authorized:
      self.locationManager.startUpdatingLocation()
    case .NotDetermined:
      self.locationManager.startUpdatingLocation()
      self.locationManager.requestAlwaysAuthorization()
    case .AuthorizedWhenInUse, .Restricted, .Denied:
      let alertController = UIAlertController(
        title: "Background Location Access Disabled",
        message: "In order to be notified about adorable kittens near you, please open this app's settings and set location access to 'Always'.",
        preferredStyle: .Alert)
      
      let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
      alertController.addAction(cancelAction)
      
      let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
        if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
          UIApplication.sharedApplication().openURL(url)
        }
      }
      alertController.addAction(openAction)
      self._presentAlert(alertController)
    }
  
  }
  
  func locationManager(manager: CLLocationManager!, didStartMonitoringForRegion region: CLRegion!) {
    self._onUpdate("Scanning...")
  }
  
  func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
    self._onUpdate("Error :(")
  }
  
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    if locations.count == 0 {
      self._onUpdate("No location updates")
      return
    }
    let lastObject: AnyObject = locations[locations.count - 1]
    self._onUpdate("Updated Location \(lastObject)")
  }
  
  func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
    
    if beacons.count == 0 {
      self._onUpdate("No beacons found")
      return
    }
    let lastBeacon: CLBeacon = beacons[beacons.count - 1] as CLBeacon;
    var message : String = ""
    let code = lastBeacon.proximity.rawValue
    switch lastBeacon.proximity {
    case CLProximity.Unknown:
      message = "Location Unkown"
    case CLProximity.Near:
      message = "Location Near"
    case CLProximity.Far:
      message = "Location Far"
    case CLProximity.Immediate:
      message = "Location Immediate"
    default:
      message = "Location Undetermined"
    }
    
    self._onUpdate(message)
    
    let meshbluMessage : AnyObject = [
      "devices" : meshbluToUuid,
      "topic" : "LocationUpdate",
      "payload" : [
        "code" : code,
        "message" : message
      ]
    ]
    
    self.meshblu?.makeRequest("/messages", parameters: meshbluMessage, onResponse: {
      NSLog("Sent Message for locationUpdate")
    })
  }
  
  func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
    self.locationManager.startRangingBeaconsInRegion(self.beaconRegion)
    
    let meshbluMessage : AnyObject = [
      "devices" : meshbluToUuid,
      "topic" : "EnterRegion",
      "payload" : []
    ]
    
    self._onUpdate("Did Enter Region")
    
    self.meshblu?.makeRequest("/messages", parameters: meshbluMessage, onResponse: {
      NSLog("Sent Message for didEnterRegion")
    })
    
  }
  
  func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
    self._onUpdate("Did Exit Region")
    manager.stopRangingBeaconsInRegion(self.beaconRegion)
    manager.stopUpdatingLocation()
  }
  
  func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    self._onUpdate("didChangeAuthorizationStatus")
    self.updateStatus(status)
    if status == .Authorized || status == .AuthorizedWhenInUse {
      self.locationManager.startUpdatingLocation()
      self._onUpdate("Authorized Location Updates")
    }
  }
  
}