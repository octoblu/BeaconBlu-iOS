//
//  ViewController.swift
//  FlowYo
//
//  Created by Peter DeMartini on 11/3/14.
//  Copyright (c) 2014 Octoblu, Inc. All rights reserved.
//

import UIKit
import MeshbluKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate {

  var userUuid: String?
  var userEmail: String?
  var message: String = "Initializing..."
  let LOGIN_URL = "http://app.octoblu.com/static/auth-login.html"
  
  var emailTextField : UITextField?
  let meshblu = MeshbluKit()
  
  @IBOutlet var tableView: UITableView!
  
  @IBOutlet var webView: UIWebView!
  
  @IBOutlet var profileView: UIView!
  
  func logoutButton(){
    let settings = NSUserDefaults.standardUserDefaults()
    settings.removeObjectForKey("uuid")
    settings.removeObjectForKey("token")
    settings.removeObjectForKey("deviceUuid")
    settings.removeObjectForKey("deviceToken")
    settings.removeObjectForKey("email")
    self.userUuid = nil
    self.userEmail = nil
    self.startWebView()
  }
  
  func doneWithProfile(){
    let settings = NSUserDefaults.standardUserDefaults()
    let email = self.emailTextField!.text
    settings.setObject(email, forKey: "email")
    self.userEmail = email
    self.profileView.removeFromSuperview()
    self.tableView.reloadData()
  }
  
  func startWebView(){
    NSLog("Starting Web View")
    let frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
    self.webView = UIWebView(frame: frame)
    self.webView.delegate = self
    self.loadUrl()
    self.view.addSubview(self.webView)
  }
  
  func startProfileView(){
    NSLog("Starting Profile View")
    
    let profileViewFrame = CGRect(x: 0, y: 16, width: self.view.bounds.width, height: self.view.bounds.height)
    
    self.profileView = UIView(frame: profileViewFrame)
    self.profileView.backgroundColor = UIColor.darkGrayColor()
    
    // Add Title
    let titleFieldFrame = CGRect(x: 15, y: 15, width: self.view.bounds.width, height: 45)
    let titleField = UITextView(frame: titleFieldFrame)
    titleField.text = "Edit Profile Settings"
    titleField.textColor = UIColor.whiteColor()
    titleField.backgroundColor = UIColor.clearColor()
    titleField.font = UIFont(name: "Helvetica", size: 22.0)
    self.profileView.addSubview(titleField)
    
    // Add Text Field
    let textFieldFrame = CGRect(x: 15, y: 65, width: self.view.bounds.width - 30, height: 30)
    emailTextField = UITextField(frame: textFieldFrame)
    emailTextField!.backgroundColor = UIColor.whiteColor()
    emailTextField!.text = self.userEmail
    emailTextField!.placeholder = "Email Address"
    emailTextField!.keyboardType = UIKeyboardType.EmailAddress
    self.profileView.addSubview(self.emailTextField!)
    
    // Add Button
    let buttonFrame = CGRect(x: self.view.bounds.width - 100, y: 85, width: 100, height: 50)
    let doneWithProfileButton = UIButton(frame: buttonFrame)
    doneWithProfileButton.setTitle("Done", forState: .Normal)
    doneWithProfileButton.addTarget(self, action: Selector("doneWithProfile"), forControlEvents: .TouchUpInside)
    self.profileView.addSubview(doneWithProfileButton)
    
    self.view.addSubview(self.profileView)
  }
  
  func initalize() {
    let settings = NSUserDefaults.standardUserDefaults()
    let uuid  = settings.stringForKey("uuid")
    let token = settings.stringForKey("token")
    let deviceUuid  = settings.stringForKey("deviceUuid")
    let deviceToken = settings.stringForKey("deviceToken")
    let email = settings.stringForKey("email")
    
    if uuid == nil || token == nil {
      self.startWebView()
      return
    }
    
    if email == nil {
      self.startProfileView()
      return
    }
    
    self.userUuid = uuid
    self.userEmail = email
    
    if deviceUuid == nil && deviceToken == nil {
      self.meshblu.register({ (responseObj: Dictionary<String, AnyObject>?) in
    
      })
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let bounds = self.view.bounds;
    //let buttonFrame = CGRect(x: bounds.width, y: bounds.height, width: 100, height: 50)
    let buttonFrame = CGRect(x: bounds.width - 100, y: bounds.height - 55, width: 100, height: 50)
    let logoutButton = UIButton(frame: buttonFrame)
    logoutButton.setTitle("Logout", forState: .Normal)
    logoutButton.addTarget(self, action: Selector("logoutButton"), forControlEvents: .TouchUpInside)
    self.tableView.addSubview(logoutButton)
    
    let profileButtonFrame = CGRect(x: 5, y: bounds.height - 55, width: 100, height: 50)
    let profileButton = UIButton(frame: profileButtonFrame)
    profileButton.setTitle("Profile", forState: .Normal)
    profileButton.addTarget(self, action: Selector("startProfileView"), forControlEvents: .TouchUpInside)
    self.tableView.addSubview(profileButton)
    
    self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    
    self.tableView.separatorColor = UIColor.clearColor()
    self.tableView.rowHeight = CGFloat(69.0) // Hehe
    self.tableView.backgroundColor = UIColor.darkGrayColor()
    self.initalize()
    
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  override func didReceiveMemoryWarning(){
    super.didReceiveMemoryWarning()
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
    cell.textLabel?.textAlignment = NSTextAlignment.Center
    
    switch indexPath.item {
    case 0:
      if self.meshblu.uuid == nil {
        return cell
      }
      cell.backgroundColor = UIColor.grayColor()
      cell.textLabel?.text = "UUID: \(self.meshblu.uuid)"
    default:
      cell.backgroundColor = UIColor(red : CGFloat(68 / 255.0), green: CGFloat(140 / 255.0), blue : CGFloat(203 / 255.0), alpha : 1.0)
      cell.textLabel?.text = self.message
    }
    
    cell.textLabel?.textColor = UIColor.whiteColor()
    cell.textLabel?.font = UIFont(name: "Helvetica-Bold", size: CGFloat(16.0))
    cell.selectionStyle = UITableViewCellSelectionStyle.None
    
    return cell
  }
  
  func clearCookies(){
    let cookieStore = NSHTTPCookieStorage.sharedHTTPCookieStorage()
    for cookie in cookieStore.cookies as! Array<NSHTTPCookie> {
      cookieStore.deleteCookie(cookie)
    }
  }
  
  func loadUrl(){
    let url = NSURL(string: LOGIN_URL)
    
    let request = NSURLRequest(URL: url!)
    
    webView.loadRequest(request)
  }
  
  func setUuidAndToken(uuid : String, token : String) {
    let settings = NSUserDefaults.standardUserDefaults()
    self.userUuid = uuid
    settings.setObject(uuid, forKey: "uuid")
    settings.setObject(token, forKey: "token")
    NSLog("UUID : \(uuid) TOKEN : \(token)")
    self.webView.removeFromSuperview()
    self.initalize()
  }
  
  func webViewDidFinishLoad(webView: UIWebView) {
    let currentUrl : String? = webView.request?.URL!.absoluteString;
    if currentUrl == nil || currentUrl! == "" {
      return
    }
    if currentUrl!.rangeOfString("?") == nil {
      return
    }
    
    let queryItems  = NSURLComponents(string: currentUrl!)?.queryItems
      as! Array<NSURLQueryItem>
    
    let keys = queryItems.map({(queryItem) -> String in queryItem.name})
    if(!contains(keys, "uuid") || !contains(keys, "token")) {
      return
    }
    
    let uuid : String? = queryItems[0].value
    let token : String? = queryItems[1].value
    
    if uuid == "undefined" || token == "undefined" {
      let alert = UIAlertView()
      alert.title = "Error"
      alert.message = "Unable to Login"
      alert.addButtonWithTitle("Retry")
      alert.show()
      self.loadUrl()
      return;
    }
    
    if uuid != nil && token != nil {
      webView.stopLoading()
      setUuidAndToken(uuid!, token: token!)
    }
    
  }
  
  func updateLocation(proximity: String, code : Int){
    if self.userUuid == nil {
      NSLog("Meshblu not initialized")
      return
    }
    
    var message = Dictionary<String, AnyObject>()
    
    message["payload"] = [
      "proximity" : proximity,
      "code" : code,
      "userUuid" : self.userUuid!,
      "email" : self.userEmail!
    ]
    message["devices"] = "*"
    message["topic"] = "location_update"

    self.meshblu.makeRequest("/messages", parameters:
      message as AnyObject, onResponse: { (responseObj : Dictionary<String, AnyObject>?) in
        NSLog("Message Sent: \(message)")
      })
  }
  
}
