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
        //fill the menu with the itens listed on the arrays
        TableArray = ["🏠 Main Page","🎉 All Events","🗓 Calendar","🗂 Resources","📞 Emergency", "🗺 Campus Map", "📻 Radio", "🎥 Athletics Videos", "💬 Hangouts"]
        
        
        let myBtn: UIButton = UIButton()
        myBtn.setImage(UIImage(named: "Facebook_icon.jpg"), forState: .Normal)
        myBtn.frame = CGRectMake(0, 0, 40, 40)
        myBtn.addTarget(self, action: "gotoFacebook", forControlEvents: .TouchUpInside)
        
        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(customView: myBtn), animated: true)
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .ScaleAspectFit
        let image1 = UIImage(named: "twitter-logo-high-res-1024x1024.jpg")
        imageView.image = image1
        self.navigationItem.titleView = imageView
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableArray[indexPath.row], forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel?.text =  TableArray[indexPath.row]
        
        return cell
    }
    //Social network links
    @IBAction func gotoInstagram(sender: AnyObject) {
        if let url = NSURL(string: "http://www.instagram.com/lewisclarkstate/") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func gotoFacebook(sender: AnyObject) {
        if let url = NSURL(string: "http://www.facebook.com/LewisClarkState") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func gotoTwitter(sender: AnyObject) {
        if let url = NSURL(string: "http://twitter.com/LCSC") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
}