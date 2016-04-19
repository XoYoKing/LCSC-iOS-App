//
//  scriptWebView.swift
//  LCSC
//
//  Created by Eric de Baere Grassl on 3/2/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

import UIKit

class ScriptWebView: Authentication{
    
    private let warriorURL: String = "https://warriorwebss.lcsc.edu/Student/Account/Login?ReturnUrl=%2fStudent%2fPlanning%2fDegreePlans"
    private let blackboardURL: String = "https://lcsc.blackboard.com/"
    
    override init() {
        super.init()
    }

    
    func getScript(url: String) -> String {
        if url == warriorURL{
            let savedUsername = super.getWarriorWebUsername()
            let savedPassword = super.getWarriorWebPassword()
            if (savedPassword != "" && savedUsername != ""){
                return "var pwd=\"\(savedPassword)\"; var usr=\"\(savedUsername)\"; document.getElementById(\"UserName\").value = usr; document.getElementById(\"Password\").value = pwd;document.getElementsByClassName(\"login-partial-input form\")[0].click()"
            }
        }else if url == blackboardURL{
            let savedUsername = super.getBlackBoardUsername()
            let savedPassword = super.getBlackBoardPassword()
            if (savedPassword != "" && savedUsername != ""){
                return "var pwd=\"\(savedPassword)\"; var usr=\"\(savedUsername)\"; document.getElementById(\"user_id\").value=usr; document.getElementById(\"password\").value=pwd;document.getElementById('entry-login').click();"
            }
        }
        return ""
    }
    
}