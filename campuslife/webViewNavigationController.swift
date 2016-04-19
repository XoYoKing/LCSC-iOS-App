//
//  webViewNavigationController.swift
//  LCSC
//
//  Created by Eric de Baere Grassl on 4/18/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

import UIKit

class webViewNavigationController: UINavigationController {
    public var url = NSURL(string: "")
    public var webTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("hi")
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? WebViewViewController{
            destination.url = url
            destination.title = title
            
        }
    }
}
