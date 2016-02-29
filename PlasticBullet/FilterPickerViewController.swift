//
//  FilterPickerViewController.swift
//  PlasticBullet
//
//  Created by Sean Hess on 2/20/16.
//  Copyright © 2016 JustStartGo. All rights reserved.
//

import UIKit

class FilterPickerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MojoDelegate {
    
    var topLeftImage: FilterView
    var topRightImage: FilterView
    var bottomLeftImage: FilterView
    var bottomRightImage: FilterView
    @IBOutlet weak var imagesView: FilterGridView!
    
    weak var selectedImage: FilterView?
    
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    
    var image:UIImage?
    
    var mojo:mojoViewController = mojoViewController.init()
    
    var allImageViews:[FilterView] {
        get {
            return [topLeftImage, topRightImage, bottomLeftImage, bottomRightImage]
        }
    }
    
    var allButtons:[UIButton] {
        get {
            return [libraryButton, cameraButton, refreshButton, backButton, shareButton]
        }
    }
    
    required init(coder dec: NSCoder) {
        self.topLeftImage = FilterView(coder: dec)
        self.topRightImage = FilterView(coder: dec)
        self.bottomLeftImage = FilterView(coder: dec)
        self.bottomRightImage = FilterView(coder: dec)
        super.init(coder: dec)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagesView.addSubview(self.topLeftImage)
        self.imagesView.addSubview(self.topRightImage)
        self.imagesView.addSubview(self.bottomLeftImage)
        self.imagesView.addSubview(self.bottomRightImage)
        
        mojo.delegate = self
        mojo.topLeftView = self.topLeftImage
        mojo.topRightView = self.topRightImage
        mojo.bottomLeftView = self.bottomLeftImage
        mojo.bottomRightView = self.bottomRightImage
        mojo.view = self.imagesView
        
        mojo.viewDidLoad()
        
        if let img = image {
            updateImage(img)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let motion = app.motion
        
        // this interval was in the old code at 1/40. Slowing it down makes it less responsive
        motion.accelerometerUpdateInterval = 1 / 40
        motion.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler:
            {data, error in
                if let a = data?.acceleration {
                    self.mojo.setAcceleration(a)
                }
            }
        )
    }
    
    override func viewWillDisappear(animated: Bool) {
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let motion = app.motion
        motion.stopAccelerometerUpdates()
    }

    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    @IBAction func didTapRefresh(sender: AnyObject) {
        print("REFRESH")
        if let img = image {
            updateImage(img)
        }
    }
    
    @IBAction func didTapBack(sender: AnyObject) {
        self.unfocusImage()
    }
    
    @IBAction func didTapShare(sender: AnyObject) {
        print("SHARE")
    }
    
    func didRefreshGesture() {
        if let img = image {
            updateImage(img)
        }
    }
    
    
    @IBAction func didTapCamera(sender: AnyObject) {
        print("CAMERA")
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            let picker = UIImagePickerController.init()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapLibrary(sender: AnyObject) {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)) {
            let picker = UIImagePickerController.init()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("PICKED!")
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        print(info)
        print(chosenImage)
        
        self.image = chosenImage
        updateImage(chosenImage)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func updateImage(image:UIImage) {
        print("UPDATE IMAGE", image)
        mojo.renderImage(image)
    }
    
    func didRotate(isPortrait: Bool, rotation: CGFloat, scale: CGFloat) {
        let m = CGAffineTransformMakeRotation(rotation);
        self.allButtons.forEach { (button) -> () in
            button.transform = m
        }
    }
    
    @IBAction func didTapImage(gesture: UITapGestureRecognizer) {
        
        // First, hide all
        let view = gesture.view as! FilterView
        self.focusImage(view)
        
    }
    
    func focusImage(view:FilterView) {
        
        // I'm in "focused" mode
        
        // fully hide the original, put the focused image equal to its size
//        view.hidden = true
        
//        self.imagesView.removeConstraints(cs)
//        self.view.removeConstraints(cs)
//        self.imagesView.addConstraints(self.focusedConstraints(view))
//        print(view.constraints)
        
//        self.focusedImage.frame = view.frame
//        self.focusedImage.hidden = false
//        self.focusedImage.image = view.image
        
        // Update buttons
        self.cameraButton.hidden = true
        self.libraryButton.hidden = true
        self.backButton.hidden = false
        self.shareButton.hidden = false
        
        // animate them fading and the focused growing
//        UIView.animateWithDuration(0.7) { () -> Void in
        
//            self.allImageViews.forEach { (filterView) -> () in
//                filterView.alpha = 0.0
//            }
            
//            view.layoutIfNeeded()
//        }
    }
    
    func unfocusImage() {
//        
//        // we should animate the image back down
//        // then show everything else
//        // Update buttons
//        // Maybe I should physically grow that one... 
//        // save the original constraints...
//        // and go from there
//        
//        // Update buttons
//        self.cameraButton.hidden = false
//        self.libraryButton.hidden = false
//        self.backButton.hidden = true
//        self.shareButton.hidden = true
//        
//        self.focusedImage.hidden = true
//        self.allImageViews.forEach { (filterView) -> () in
//            filterView.hidden = false
//        }
//        
//        if let view = self.selectedImage {
//            UIView.animateWithDuration(0.7, animations: {
//                self.focusedImage.frame = view.frame
//                self.focusedImage.image = view.image
//                
//                self.allImageViews.forEach { (filterView) -> () in
//                    filterView.alpha = 1.0
//                }
//                
//            }, completion: { (stopped) -> Void in
//                self.focusedImage.hidden = true
//                view.hidden = false
//                self.selectedImage = nil
//            })
//        }
    }
}
