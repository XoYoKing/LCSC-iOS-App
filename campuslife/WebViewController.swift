 //
//  WebViewController.swift
//  authorizationTest1
//
//  Created by Eric de Baere Grassl on 2/21/16.
//  Copyright © 2016 Eric de Baere Grassl. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate  {



    
    var webView: WKWebView!
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let url = NSURL(string: "https://lcsc.blackboard.com")!
//        let url = NSURL(string: "https://warriorwebss.lcsc.edu/Student/Account/Login?ReturnUrl=%2fStudent%2fPlanning%2fDegreePlans")!
        webView.loadRequest(NSURLRequest(URL: url))
        webView.allowsBackForwardNavigationGestures = true
    
    }
    
 
    func webView(webView: WKWebView,
        didFinishNavigation navigation: WKNavigation!){

            let savedUsername = NSUserDefaults.standardUserDefaults().stringForKey("login")
            let savedPassword = NSUserDefaults.standardUserDefaults().stringForKey("password")
            
//blackboard:
            
            let script = "var pwd=\"\(savedPassword!)\"; var usr=\"\(savedUsername!)\"; document.getElementById(\"user_id\").value=usr; document.getElementById(\"password\").value=pwd;document.getElementById('entry-login').click();"
       
//warriorweb:
//        let script = "var pwd=\"\(savedPassword!)\"; var usr=\"\(savedUsername!)\"; document.getElementById(\"UserName\").value = usr; document.getElementById(\"Password\").value = pwd;document.getElementsByClassName(\"login-partial-input form\")[0].click()"
            
            
            while(webView.loading){}
            
            webView.evaluateJavaScript(script, completionHandler: nil)
    }
}
