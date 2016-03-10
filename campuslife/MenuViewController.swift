//
//  ViewController.swift
//  SlideoutMenu
//
//  Created by Eric de Baere Grassl on 3/3/16.
//  Copyright © 2016 Eric de Baere Grassl. All rights reserved.
//

import UIKit
import LCSC

class ViewController: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        menuButton.target = revealViewController()
        menuButton.action = Selector("revealToggle:")
        
        
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

