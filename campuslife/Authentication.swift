//
//  Authentication.swift
//  LCSC
//
//  Created by Eric de Baere Grassl on 2/29/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

import UIKit

@objc class Authentication: NSObject {
    private var prefs = NSUserDefaults.standardUserDefaults()
    override init(){
        super.init()
        if (((prefs.stringForKey("wwlogin") == nil || prefs.stringForKey("wwpassword") == nil || prefs.stringForKey("bblogin") == nil || prefs.stringForKey("bbpassword") == nil))){
            clearProfile()
        }
        if (prefs.stringForKey("userHaveEverBeenAtResourcesPage") == nil){
            prefs.setObject("false", forKey: "userHaveEverBeenAtResourcesPage")
            prefs.synchronize()
        }
    }
    
    func clearProfile(){
        clearWarriorWebProfile()
        clearBlackBoardProfile()
        prefs.synchronize()
    }
    
    func clearWarriorWebProfile(){
        prefs.setObject("", forKey: "wwlogin")
        prefs.setObject("", forKey: "wwpassword")
    }
    
    func clearBlackBoardProfile(){
        prefs.setObject("", forKey: "bblogin")
        prefs.setObject("", forKey: "bbpassword")
    }
    
    func clearLCMailProfile(){
        prefs.setObject("", forKey: "lcmlogin")
        prefs.setObject("", forKey: "lcmpasswor")
    }
    
    func userHaveEverBeenAtResourcesPage() -> Bool{
        print(prefs.stringForKey("userHaveEverBeenAtResourcesPage"))
        let bool = prefs.stringForKey("userHaveEverBeenAtResourcesPage")
        if bool == "false"{
            return false
        }else if bool == "true"{
            return true
        }
        return false
    }
    
    func setUserHaveEverBeenAtResourcesPage(bool: String){
        if (bool != "true" && bool != "false") {return}
        prefs.setObject(bool, forKey: "userHaveEverBeenAtResourcesPage")
        print("changed for \(bool)")
        prefs.synchronize()
    }
    
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
        }
        else if destination == "blackboard"{
            if (newLogin != ""){
                if (newPassword != ""){
                    prefs.setObject(newLogin!, forKey: "bblogin")
                    prefs.setObject(newPassword!, forKey: "bbpassword")
                    prefs.synchronize()
                    return true
                }
            }
        }
        return false
    }
    
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
