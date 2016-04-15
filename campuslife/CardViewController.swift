//
//  File.swift
//  LCSC
//
//  Created by Eric de Baere Grassl on 3/11/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

import Foundation
import UIKit




class CardViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ImageCropViewControllerDelegate {
    
    
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var imageView: UIImageView!
    var imagePicker: UIImagePickerController!
    
    
    //opens the imagepicker to take a photo
    @IBAction func cameraButtonTapped(sender: UIBarButtonItem) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        presentViewController((imagePicker), animated: true, completion: nil)
    }
    
    
    func promptAlet(title: String, message: String){
        let alert:UIAlertView = UIAlertView()
        alert.title = title
        alert.message = message
        alert.delegate = self
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
    
    //save the card image
    func saveImage(image: UIImage){
        NSUserDefaults.standardUserDefaults().setObject(UIImageJPEGRepresentation(image,1), forKey: "card")
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    //allows the user to crop the image
    func ImageCropViewControllerSuccess(controller: UIViewController!, didFinishCroppingImage croppedImage: UIImage!) {
        saveImage(croppedImage)
        promptAlet("Success!", message: "Your card picture was saved.")
        checkAndLoadCardPicture()
        navigationController?.popViewControllerAnimated(true)
    }


    func ImageCropViewControllerDidCancel(controller: UIViewController!) {
        navigationController?.popViewControllerAnimated(true)
    }

    //saves the photo taken by the user
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        let image = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        saveImage(image)
        checkAndLoadCardPicture()
        let controller = ImageCropViewController(image: image)
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    
    //check if there is a picture and load it in case it has
    func checkAndLoadCardPicture(){
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        if let imageToLoad = NSUserDefaults.standardUserDefaults().objectForKey("card"){
            imageView.image = UIImage(data: imageToLoad as! NSData)
        } else {
            promptAlet("No card picture is registered!", message: "You can regiter your card picture by taping the camera button.")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //mycode
        //loads the slide menu function
        menuButton.target = revealViewController()
        menuButton.action = Selector("revealToggle:")
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        
        checkAndLoadCardPicture()
    }
}
