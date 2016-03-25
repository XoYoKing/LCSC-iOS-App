//
//  HangoutsViewController.swift
//  LCSC
//
//  Created by Eric de Baere Grassl on 3/24/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

import UIKit

class HangoutsViewController: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //code
        
        menuButton.target = revealViewController()
        menuButton.action = Selector("revealToggle:")
    
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        let url = NSURL(string:"https://hangouts.google.com")
        let req = NSURLRequest(URL:url!)
        webView!.loadRequest(req)
    }
}
