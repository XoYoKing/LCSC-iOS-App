//
//  BackTableVC.swift
//  SlideoutMenu
//
//  Created by Eric de Baere Grassl on 3/3/16.
//  Copyright © 2016 Eric de Baere Grassl. All rights reserved.
//

import Foundation
import UIKit


//Takes care of the slide menu itens
class BackTableVC: UITableViewController {
    
    @IBOutlet var twitterButton: UIBarButtonItem!
    @IBOutlet var facebookButton: UIBarButtonItem!
    @IBOutlet var instaButton: UIBarButtonItem!
    var TableArray = [String]()
    
    override func viewDidLoad() {
        self.tableView.tableFooterView = UIView()
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? UINavigationController{
            let title = segue.identifier
            destination.title = title
        }
    }
    
}