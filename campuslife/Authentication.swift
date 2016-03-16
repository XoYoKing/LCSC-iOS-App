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
        if (prefs.stringForKey("wwlogin") == nil || prefs.stringForKey("wwpassword") == nil){
            clearProfile()
        }
    }
    
    func clearProfile(){
        prefs.setObject("", forKey: "wwlogin")
        prefs.setObject("", forKey: "wwpassword")
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
}
