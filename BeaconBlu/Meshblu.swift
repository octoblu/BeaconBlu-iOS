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
    
    var uuid : String
    var token : String
  
    // Constructor
    init(uuid : String, token : String){
      self.uuid = uuid
      self.token = token
    }
  
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