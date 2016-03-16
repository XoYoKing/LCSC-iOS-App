//
//  BackTableVC.swift
//  SlideoutMenu
//
//  Created by Eric de Baere Grassl on 3/3/16.
//  Copyright © 2016 Eric de Baere Grassl. All rights reserved.
//

import Foundation
import UIKit

class BackTableVC: UITableViewController {
    
    var TableArray = [String]()
    
    override func viewDidLoad() {
        self.tableView.tableFooterView = UIView()
        TableArray = ["🏠 Main Page","🎉 All Events","🗓 Calendar","🗂 Resources","📞 Emergency","💳 WarriorCard", "🗺 Campus Map"]
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableArray[indexPath.row], forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel?.text =  TableArray[indexPath.row]
        
        return cell
    }
    
    
}