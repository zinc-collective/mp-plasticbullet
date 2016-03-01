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
    
    var selectedImage: UIImage?
    
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
        
        self.allImageViews.forEach { (filterView) in
            filterView.onTap = self.focusImage
        }
        
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
        
        if let img = self.selectedImage {
            let activity = UIActivityViewController(activityItems: [img], applicationActivities: nil)
            self.presentViewController(activity, animated: true, completion: nil)
        }
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
    
    func focusImage(view:FilterView) {
        
        // Update buttons
        self.cameraButton.hidden = true
        self.libraryButton.hidden = true
        self.backButton.hidden = false
        self.shareButton.hidden = false
        
        // Focus the view
        self.imagesView.focusView(view)
        
        // Remember which one we've focused
        self.selectedImage = view.image
    }
    
    func unfocusImage() {
        
        // Update buttons
        self.cameraButton.hidden = false
        self.libraryButton.hidden = false
        self.backButton.hidden = true
        self.shareButton.hidden = true
        
        // Defocus the view
        self.imagesView.removeFocus()
        
        self.selectedImage = nil
    }
}
