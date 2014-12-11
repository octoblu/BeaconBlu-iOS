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
  
  init(uuid: String, token: String, onUpdate: (String) -> ()){
    self._onUpdate = onUpdate
    super.init()
    self.locationManager.delegate = self
    self.locationManager.requestWhenInUseAuthorization()
    self.locationManager.requestAlwaysAuthorization()
    
    let proximityUuid = NSUUID(UUIDString: self.iBeaconUUID)
    self.beaconRegion = CLBeaconRegion(proximityUUID: proximityUuid, major: 1, minor: 1, identifier: "Conference Room")
    
    self.locationManager.startMonitoringForRegion(self.beaconRegion)
    self.locationManager.startRangingBeaconsInRegion(self.beaconRegion)
    
    self.meshblu = Meshblu(uuid: uuid, token: token)
  }
  
  func requestAlwaysAuthorization(){
    let status : CLAuthorizationStatus = CLLocationManager.authorizationStatus()
    var title : String?
    
    if status != CLAuthorizationStatus.NotDetermined {
      self.locationManager.requestAlwaysAuthorization()
      return
    }
    
    let message : String = "To use background location you must turn on 'Always' in the Location Services Settings"
    
    if status == CLAuthorizationStatus.AuthorizedWhenInUse {
      title = "Location services are off"
    }
    
    if status == CLAuthorizationStatus.Denied {
      title = "Background location is not enabled"
    }
    
    let alert : UIAlertView = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "Cancel")
    
    alert.show()
  
  }
  
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    if locations.count == 0 {
      return
    }
    let lastObject: AnyObject = locations[locations.count - 1]
    NSLog("Updated Location \(lastObject)")
    self._onUpdate("Updated Location \(lastObject)")
  }
  
  func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
    
    if beacons.count == 0 {
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
    
    NSLog(message)
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
    self.locationManager.stopRangingBeaconsInRegion(self.beaconRegion)
  }
  
}