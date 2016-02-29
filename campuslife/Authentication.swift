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
        if (prefs.stringForKey("login") == nil || prefs.stringForKey("password") == nil){
            clearProfile()
        }
    }
    
    func clearProfile(){
        prefs.setObject("", forKey: "login")
        prefs.setObject("", forKey: "password")
        prefs.synchronize()
    }
    
    func setProfile(newLogin: String?, newPassword: String?) -> Bool{
        if (newLogin != ""){
            if (newPassword != ""){
                prefs.setObject(newLogin!, forKey: "login")
                prefs.setObject(newPassword!, forKey: "password")
                prefs.synchronize()
                return true
            }
        }
        return false
    }
    
    func getUsername() -> String{
        return prefs.stringForKey("login")!
    }
    
    func getPassword() -> String{
        return prefs.stringForKey("password")!
    }
}
