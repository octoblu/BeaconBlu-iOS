//
//  Meshblu.swift
//  FlowYo
//
//  Created by Peter DeMartini on 11/4/14.
//  Copyright (c) 2014 Octoblu, Inc. All rights reserved.
//

import Foundation

class Meshblu {
    
  let meshbluUrl : String = "https://meshblu.octoblu.com"
  
  var uuid : String = "8f218bb0-8237-11e4-8019-f97967ce66a8"
  var token : String = "4fp9t1uhn6uvj9k9ght5oppvxe83q5mi"
  
  func makeRequest(path : String, parameters : AnyObject, onResponse: () -> ()){
    let manager :AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
    let url :String = self.meshbluUrl + path
    
    // Request Success
    let requestSuccess = {
      (operation :AFHTTPRequestOperation!, responseObject :AnyObject!) -> Void in
      
      //SVProgressHUD.showSuccessWithStatus("Sent!")
      onResponse();
      NSLog("requestSuccess \(responseObject)")
    }
    
    // Request Failure
    let requestFailure = {
        (operation :AFHTTPRequestOperation!, error :NSError!) -> Void in
      
        //SVProgressHUD.showErrorWithStatus("Error!")
      onResponse();
      NSLog("requestFailure: \(error)")
    }
  

    //SVProgressHUD.showWithStatus("Triggering...")
    // Set Headers
    manager.requestSerializer.setValue(self.uuid, forHTTPHeaderField: "skynet_auth_uuid")
    manager.requestSerializer.setValue(self.token, forHTTPHeaderField: "skynet_auth_token")
    
    manager.POST(url, parameters: parameters, success: requestSuccess, failure: requestFailure)
  }
}