//
//  AthleticsViewController.swift
//  LCSC
//
//  Created by Eric de Baere Grassl on 3/16/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

import UIKit

class AthleticsViewController: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // my code :)
        //loads the slide menu function
        menuButton.target = revealViewController()
        menuButton.action = Selector("revealToggle:")
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        //loads Athletics livestream page
        let url = NSURL(string:"http://livestream.com/accounts/8399277/lcwarriors")
        let req = NSURLRequest(URL:url!)
        webView!.loadRequest(req)
    }
    
}
