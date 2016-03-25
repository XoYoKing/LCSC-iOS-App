//
//  Authentication.swift
//  LCSC
//
//  Created by Eric de Baere Grassl on 2/29/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

import UIKit


//saves the user username and password
@objc class Authentication: NSObject {
    
    private var prefs = NSUserDefaults.standardUserDefaults()
    override init(){
        super.init()
        //initializing data in case it is nil
        if (((prefs.stringForKey("wwlogin") == nil || prefs.stringForKey("wwpassword") == nil || prefs.stringForKey("bblogin") == nil || prefs.stringForKey("bbpassword") == nil)) || (prefs.stringForKey("lcmlogin") == nil) || (prefs.stringForKey("lcmpassword")) == nil){
            clearProfile()
        }
        if (prefs.stringForKey("userHaveEverBeenAtResourcesPage") == nil){
            prefs.setBool(false, forKey: "userHaveEverBeenAtResourcesPage")
            prefs.synchronize()
        }
    }
    
    func clearProfile(){
        clearWarriorWebProfile()
        clearBlackBoardProfile()
        clearLCMailProfile()
    }
    
    func clearWarriorWebProfile(){
        prefs.setObject("", forKey: "wwlogin")
        prefs.setObject("", forKey: "wwpassword")
        prefs.synchronize()
    }
    
    func clearBlackBoardProfile(){
        prefs.setObject("", forKey: "bblogin")
        prefs.setObject("", forKey: "bbpassword")
        prefs.synchronize()
    }
    
    func clearLCMailProfile(){
        prefs.setObject("", forKey: "lcmlogin")
        prefs.setObject("", forKey: "lcmpassword")
        prefs.synchronize()
    }
    
    //function to avoid showingt he alert in resources table more than once
    func userHaveEverBeenAtResourcesPage() -> Bool{
        let bool = prefs.boolForKey("userHaveEverBeenAtResourcesPage")
        return bool
    }
    
    
    func setUserHaveEverBeenAtResourcesPage(bool: Bool){
        prefs.setBool(bool, forKey: "userHaveEverBeenAtResourcesPage")
        prefs.synchronize()
    }
    
    
    //save your data acording to the profile destination and returns a bool representing if it was successfull operation or not
    func setProfile(destination: String, newLogin: String?, newPassword: String?) -> Bool{
        if destination == "warriorweb"{
            if (newLogin != ""){
                if (newPassword != ""){
                    prefs.setObject(newLogin!, forKey: "wwlogin")
                    prefs.setObject(newPassword!, forKey: "wwpassword")
                    prefs.synchronize()
                    return true
                }
            }
        }else if destination == "blackboard"{
            if (newLogin != ""){
                if (newPassword != ""){
                    prefs.setObject(newLogin!, forKey: "bblogin")
                    prefs.setObject(newPassword!, forKey: "bbpassword")
                    prefs.synchronize()
                    return true
                }
            }
        }else if destination == "lcmail"{
            if (newLogin != ""){
                let lcDomain = "@lcmail.lcsc.edu"
                let lcDomainLength = lcDomain.characters.count
                //checking if the email contains the @lcmail.lcsc.edu string in th ending
                if(newLogin?.characters.count > lcDomainLength){
                    let domainSubstr = (newLogin?.substringFromIndex((newLogin?.startIndex.advancedBy((newLogin?.characters.count)! - lcDomainLength))!))
                    if (domainSubstr! == "@lcmail.lcsc.edu") {
                        prefs.setObject(newLogin!, forKey: "lcmlogin")
                        prefs.setObject(newPassword!, forKey: "lcmpassword")
                        prefs.synchronize()
                        return true
                    }
                }
            }
        }
        return false
    }
    
    
    //gets
    func getWarriorWebUsername() -> String{
        return prefs.stringForKey("wwlogin")!
    }
    
    func getWarriorWebPassword() -> String{
        return prefs.stringForKey("wwpassword")!
    }
    
    func getBlackBoardUsername() -> String{
        return prefs.stringForKey("bblogin")!
    }
    
    func getBlackBoardPassword() -> String{
        return prefs.stringForKey("bbpassword")!
    }
    
    func getLCMailUsername() -> String{
        return prefs.stringForKey("lcmlogin")!
    }
    
    func getLCMailPassword() -> String{
        return prefs.stringForKey("lcmpassword")!
    }
}

