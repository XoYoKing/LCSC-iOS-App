//
//  File.swift
//  LCSC
//
//  Created by Eric de Baere Grassl on 3/11/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

import Foundation
import UIKit

class CardViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var imageView: UIImageView!
    var imagePicker: UIImagePickerController!
    
    @IBAction func cameraButtonTapped(sender: UIBarButtonItem) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        presentViewController((imagePicker), animated: true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        let image = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        
        
        NSUserDefaults.standardUserDefaults().setObject(UIImagePNGRepresentation(image), forKey: "card")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        let alert:UIAlertView = UIAlertView()
        alert.title = "Success!"
        alert.message = "Your card picture was saved."
        alert.delegate = self
        alert.addButtonWithTitle("Ok")
        alert.show()
        checkAndLoadCard()
    }

    func checkAndLoadCard(){
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        if let imageToLoad = NSUserDefaults.standardUserDefaults().objectForKey("card"){
            imageView.image = UIImage(data: imageToLoad as! NSData)
        } else {
            let alert:UIAlertView = UIAlertView()
            alert.title = "No card picture is registered!"
            alert.message = "You can regiter your card picture by taping the camera button."
            alert.delegate = self
            alert.addButtonWithTitle("Ok")
            alert.show()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //mycode
        menuButton.target = revealViewController()
        menuButton.action = Selector("revealToggle:")
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        checkAndLoadCard()
    }
}
