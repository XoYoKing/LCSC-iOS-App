//
//  ProfileViewController.swift
//  LCSC
//
//  Created by Eric de Baere Grassl on 3/23/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate, ImageCropViewControllerDelegate {
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var imageView: UIImageView!
    var imagePicker: UIImagePickerController!
    let auth = Authentication()
    
    
    
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
    
    //load the card image in case it exists
    func checkAndLoadCardPicture(){
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        if let imageToLoad = NSUserDefaults.standardUserDefaults().objectForKey("card"){
            imageView.image = UIImage(data: imageToLoad as! NSData)
        } else {
            imageView.image = UIImage(named: "squirrelCard")
            if !auth.userHaveEverBeenAtProfilePage(){
                promptAlet("No card picture is registered!", message: "You can register your card picture by tapping the camera button.")
                auth.setUserHaveEverBeenAtProfilePage(true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //my code :)
        menuButton.target = revealViewController()
        menuButton.action = Selector("revealToggle:")
        
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.blackColor().CGColor
        imageView.layer.borderWidth = 2.0
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundCollor")!)
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        checkAndLoadCardPicture()
    }
}
