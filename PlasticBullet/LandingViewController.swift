//
//  ViewController.swift
//  PlasticBullet
//
//  Created by Sean Hess on 2/18/16.
//  Copyright © 2016 JustStartGo. All rights reserved.
//

import UIKit
import AVFoundation
import XMCircleType

class LandingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet weak var background: UIImageView!
    
    
    @IBOutlet weak var cameraText: PBCircleLabel!
    @IBOutlet weak var cameraLeft: NSLayoutConstraint!
    @IBOutlet weak var cameraTop: NSLayoutConstraint!
    
    @IBOutlet weak var libraryText: PBCircleLabel!
    @IBOutlet weak var libraryLeft: NSLayoutConstraint!
    @IBOutlet weak var libraryTop: NSLayoutConstraint!
    
    @IBAction func didTapLibrary(sender: AnyObject) {
        print("LIBRARY")
        
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)) {
            let picker = UIImagePickerController.init()
            let nav = self
            picker.delegate = nav
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapCamera(sender: AnyObject) {
//        print("CAMERA")
//        
//        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
//            let picker = UIImagePickerController.init()
//            picker.delegate = self
//            picker.allowsEditing = false
//            picker.sourceType = UIImagePickerControllerSourceType.Camera
//            self.presentViewController(picker, animated: true, completion: nil)
//        }
//        
    }
    
    @IBAction func didTapInfo(sender: AnyObject) {
        print("INFO")
        self.performSegueWithIdentifier("Info", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Determine how large the phone is compared to Interface Builder
        let IB_MANUAL_WIDTH = CGFloat(414)
        let scale = view.frame.size.width / IB_MANUAL_WIDTH
        
        // -- circular text labels --------------------------------------------
        
        let font = UIFont(name: "Helvetica Bold", size: 18.0 * scale)
        let color = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        
        cameraText.text = "Camera"
        cameraText.baseAngle = PBCircleLeftCenter + Float(0.25 * M_PI)
        cameraText.font = font
        cameraText.fontColor = color
        
        libraryText.text = "Photo Library"
        libraryText.baseAngle = PBCircleLeftCenter + Float(0.2 * M_PI)
        libraryText.font = font
        libraryText.fontColor = color
        
        // -- correct button placement to match image scaling -----------------
        
        libraryLeft.constant = libraryLeft.constant * scale
        libraryTop.constant = libraryTop.constant * scale
        
        cameraLeft.constant = cameraLeft.constant * scale
        cameraTop.constant = cameraTop.constant * scale
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func closeInfo(segue:UIStoryboardSegue) {
        print("Close info")
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("PICKED!")
        
        let chosenImage = info[UIImagePickerControllerOriginalImage]
        print(info)
        print(chosenImage)
        // imageView.image = chosenImage;
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        self.performSegueWithIdentifier("Filters", sender: chosenImage)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("PREPARE FOR SEGUE")
        print(segue.identifier)
        
        if (segue.identifier == "Filters") {
            let filters = segue.destinationViewController as! FilterPickerViewController
            let image = sender as! UIImage
            print("SET IMAGE FOR FILTERS YO")
            print(filters)
            print(image)
        }
    }
    
    // unowned(unsafe) var delegate: protocol<UIImagePickerControllerDelegate, UINavigationControllerDelegate>?
}

