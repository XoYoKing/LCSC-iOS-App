//
//  HangoutsViewController.swift
//  LCSC
//
//  Created by Eric de Baere Grassl on 3/24/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

import UIKit

class HangoutsViewController: UIViewController,UIWebViewDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //code
        //slide menu functions
        menuButton.target = revealViewController()
        menuButton.action = Selector("revealToggle:")
    
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        //open hangoutswebpage
        webView.hidden = true
        let url = NSURL(string:"https://hangouts.google.com")
        let req = NSURLRequest(URL:url!)
        webView!.loadRequest(req)
//        self.navigationController?.popViewControllerAnimated(true)
        self.performSegueWithIdentifier("backToMenu", sender: self)
    }
    
}
