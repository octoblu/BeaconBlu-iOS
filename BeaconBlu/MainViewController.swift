//
//  ViewController.swift
//  FlowYo
//
//  Created by Peter DeMartini on 11/3/14.
//  Copyright (c) 2014 Octoblu, Inc. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate {

  var iBeaconPaired : Bool = false
  var iBeacon: iBeaconLocation?
  var uuid: String?
  var token: String?
  var message: String = "Listening..."
  let LOGIN_URL = "http://app.octoblu.com/static/auth-login.html"
  
  @IBOutlet var tableView: UITableView!
  
  @IBOutlet var webView: UIWebView!
  
  func logoutButton(){
    let settings = NSUserDefaults.standardUserDefaults()
    settings.removeObjectForKey("uuid")
    settings.removeObjectForKey("token")
    self.uuid = nil
    self.token = nil
    self.startWebView()
  }
  
  func startWebView(){
    let frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
    self.webView = UIWebView(frame: frame)
    self.webView.delegate = self
    self.loadUrl()
    self.view.addSubview(self.webView)
  }
  
  func initalize() {
    let settings = NSUserDefaults.standardUserDefaults()
    let uuid  = settings.stringForKey("uuid")
    let token = settings.stringForKey("token")
    
    if(uuid == nil || token == nil){
      self.startWebView()
      return
    }
    
    self.uuid = uuid
    self.token = token
    let ibeacon = iBeaconLocation(uuid: self.uuid!, token: self.token!, onUpdate : {
      update in
      self.message = update
      self.tableView.reloadData()
    })
    ibeacon.requestAlwaysAuthorization()
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
    return 1
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
    
    cell.backgroundColor = UIColor(red : CGFloat(68 / 255.0), green: CGFloat(140 / 255.0), blue : CGFloat(203 / 255.0), alpha : 1.0)
    
    cell.textLabel?.textAlignment = NSTextAlignment.Center

    cell.textLabel?.text = self.message
    
    cell.textLabel?.textColor = UIColor.whiteColor()
    cell.textLabel?.font = UIFont(name: "Helvetica-Bold", size: CGFloat(22.0))
    cell.selectionStyle = UITableViewCellSelectionStyle.None
    
    return cell
  }
  
  func clearCookies(){
    let cookieStore = NSHTTPCookieStorage.sharedHTTPCookieStorage()
    for cookie in cookieStore.cookies as Array<NSHTTPCookie> {
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
    settings.setObject(uuid, forKey: "uuid")
    settings.setObject(token, forKey: "token")
    NSLog("UUID : \(uuid) TOKEN : \(token)")
    self.webView.removeFromSuperview()
    self.initalize()
  }
  
  func webViewDidFinishLoad(webView: UIWebView) {
    let currentUrl : String? = webView.request?.URL.absoluteString;
    if currentUrl == nil || currentUrl! == "" {
      return
    }
    if currentUrl!.rangeOfString("?") == nil {
      return
    }
    
    let queryItems  = NSURLComponents(string: currentUrl!)?.queryItems
      as Array<NSURLQueryItem>
    
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

  
}
