//
//  Authorization.swift
//  authorizationTest1
//
//  Created by Eric de Baere Grassl on 2/21/16.
//  Copyright © 2016 Eric de Baere Grassl. All rights reserved.
//

import Foundation

class Authorization{
    private var prefs = NSUserDefaults.standardUserDefaults()
    
    init(){
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
