//
//  ViewController.swift
//  authorizationTest1
//
//  Created by Eric de Baere Grassl on 2/8/16.
//  Copyright © 2016 Eric de Baere Grassl. All rights reserved.
//

import UIKit

@objc class ProfileViewControllerSwift: UIViewController {

    var auth = Authorization()
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var login: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBAction func signinTapped(sender: UIButton) {
        //Authentication
        if !auth.setProfile(login.text, newPassword: password.text){
            let newLogin = prefs.stringForKey("login")!
            let newPassword = prefs.stringForKey("password")!
            changeDisplayText(newLogin, newPassword: newPassword)
        }
        
        //printing
       // print("login txt: \(login.text!) and password txt: \(password.text!)")
        
        printNSUserDefaults()
        
    }
    
    func changeDisplayText(newLogin: String, newPassword: String){
        login.text = newLogin
        password.text = newPassword
    }
    
    func printNSUserDefaults(){
        if let a = prefs.stringForKey("login"){
            if let b = prefs.stringForKey("password"){
                print("login: \(a) and Password: \(b)")
            }
        }
    }
    
    @IBAction func clearTapped(sender: UIButton) {
        auth.clearProfile()
        changeDisplayText("", newPassword: "")
        
        
        printNSUserDefaults()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userLogin = prefs.stringForKey("login"){
            if let userPassword = prefs.stringForKey("password"){
                changeDisplayText(userLogin, newPassword: userPassword)
            }
            
        }
        print("hi")
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

