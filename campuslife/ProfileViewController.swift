//
//  ProfileViewController.swift
//  LCSC
//
//  Created by Eric de Baere Grassl on 3/23/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    //load the card image in case it exists
    func checkAndLoadCardPicture(){
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        if let imageToLoad = NSUserDefaults.standardUserDefaults().objectForKey("card"){
            imageView.image = UIImage(data: imageToLoad as! NSData)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //my code :)
        
        checkAndLoadCardPicture()
    }
}
