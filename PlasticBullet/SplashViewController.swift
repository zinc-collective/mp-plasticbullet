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

class SplashViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var bottomBar: UIView!
    
    @IBOutlet weak var bottomBarBottom: NSLayoutConstraint!
    
    var picker: UIImagePickerController?
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        libraryButton.alpha = 0
        cameraButton.alpha = 0
        bottomBarBottom.constant = -bottomBar.frame.size.height
        
        dispatch_async(dispatch_get_main_queue()) {
            UIView.animateWithDuration(0.500, animations: {
                self.libraryButton.alpha = 1
                self.cameraButton.alpha = 1
                self.bottomBarBottom.constant = 0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func didTapLibrary(sender: AnyObject) {
        print("LIBRARY")
        openLibrary()
    }
    
    @IBAction func didTapCamera(sender: AnyObject) {
        print("CAMERA")
        openCamera()
    }
    
    @IBAction func didTapInfo(sender: AnyObject) {
        print("INFO")
        self.performSegueWithIdentifier("Info", sender: self)
    }
    
    func openLibrary() {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)) {
            let picker = UIImagePickerController.init()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            picker.modalPresentationStyle = .Popover
            picker.popoverPresentationController?.sourceView = self.view
            picker.popoverPresentationController?.sourceRect = self.libraryButton.frame
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    func openCamera() {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            let picker = UIImagePickerController.init()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            self.picker = picker
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        let filters = UIStoryboard(name: "Image", bundle: nil).instantiateInitialViewController() as! FilterPickerViewController
        filters.chooseImage(info, sourceType: picker.sourceType)
        filters.modalTransitionStyle = .FlipHorizontal
        
        self.presentViewController(filters, animated: true, completion: nil)
    }
    
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//    }
//    
//    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
//        if let picker = self.picker {
//            picker.dismissViewControllerAnimated(true, completion: nil)
//        }
//    }
    
    @IBAction func unwindToLanding(segue:UIStoryboardSegue) {
        
    }
}

//class PickedImage : NSObject {
//    let mediaInfo : [String : AnyObject]
//    let sourceType : UIImagePickerControllerSourceType
//    init(mediaInfo: [String : AnyObject], sourceType: UIImagePickerControllerSourceType) {
//        self.mediaInfo = mediaInfo
//        self.sourceType = sourceType
//        super.init()
//    }
//}
//
