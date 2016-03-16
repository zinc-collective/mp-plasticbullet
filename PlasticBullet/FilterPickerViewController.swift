//
//  FilterPickerViewController.swift
//  PlasticBullet
//
//  Created by Sean Hess on 2/20/16.
//  Copyright © 2016 JustStartGo. All rights reserved.
//

import UIKit

class FilterPickerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MojoDelegate, RenderDelegate {
    
    var topLeftImage: FilterView
    var topRightImage: FilterView
    var bottomLeftImage: FilterView
    var bottomRightImage: FilterView
    
    var topMiddleImage: FilterView
    var middleLeftImage: FilterView
    var middleMiddleImage: FilterView
    var middleRightImage: FilterView
    var bottomMiddleView: FilterView
    
    var gridSize:GRID_MODE
    
    @IBOutlet weak var imagesView: FilterGridView!
    
    var selectedImage: UIImageView?
    
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var progressContainer: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var image:UIImage?
    
    var mojo:mojoViewController = mojoViewController.init()
    var renderer:Renderer = Renderer.init()
    
    var share:UIActivityViewController?
    
    @IBOutlet var refreshSwipe: UISwipeGestureRecognizer!
    
    var allImageViews:[FilterView] {
        get {
            return [topLeftImage, topRightImage, bottomLeftImage, bottomRightImage, topMiddleImage, middleLeftImage, middleMiddleImage, middleRightImage, bottomMiddleView]
        }
    }
    
    var allButtons:[UIButton] {
        get {
            return [cameraButton, refreshButton, backButton, shareButton]
        }
    }
    
    required init(coder dec: NSCoder) {
        
        if UI_USER_INTERFACE_IDIOM() == .Pad {
            gridSize = GRID_9
        } else {
            gridSize = GRID_4
        }
        
        self.topLeftImage = FilterView(coder: dec)
        self.topRightImage = FilterView(coder: dec)
        self.bottomLeftImage = FilterView(coder: dec)
        self.bottomRightImage = FilterView(coder: dec)
        
        self.topMiddleImage = FilterView(coder: dec)
        self.middleLeftImage = FilterView(coder: dec)
        self.middleMiddleImage = FilterView(coder: dec)
        self.middleRightImage = FilterView(coder: dec)
        self.bottomMiddleView = FilterView(coder: dec)
        
        super.init(coder: dec)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagesView.addSubview(self.topLeftImage)
        self.imagesView.addSubview(self.topRightImage)
        self.imagesView.addSubview(self.bottomLeftImage)
        self.imagesView.addSubview(self.bottomRightImage)
        
        if gridSize == GRID_9 {
            self.imagesView.addSubview(self.topMiddleImage)
            self.imagesView.addSubview(self.middleLeftImage)
            self.imagesView.addSubview(self.middleMiddleImage)
            self.imagesView.addSubview(self.middleRightImage)
            self.imagesView.addSubview(self.bottomMiddleView)
            
            self.imagesView.rows = 3
            self.imagesView.cols = 3
        }
        
        self.allImageViews.forEach { (filterView) in
            filterView.onTap = self.focusImage
        }
        
        mojo.delegate = self
        mojo.initGrid(self.gridSize)
        mojo.topLeftView = self.topLeftImage
        mojo.topRightView = self.topRightImage
        mojo.bottomLeftView = self.bottomLeftImage
        mojo.bottomRightView = self.bottomRightImage
        
        mojo.topMiddleView = self.topMiddleImage
        mojo.middleLeftView = self.middleLeftImage
        mojo.middleMiddleView = self.middleMiddleImage
        mojo.middleRightView = self.middleRightImage
        mojo.bottomMiddleView = self.bottomMiddleView
        
        mojo.view = self.imagesView
        
        self.renderer.delegate = self
        mojo.renderer = self.renderer
        
        mojo.viewDidLoad()
        
        if let img = image {
            updateImage(img)
        }
        
        // Orientation changes
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationDidChange", name:UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        
        // See PlasticBullet-Bridging-Header.h
        PBDevice().beginGeneratingDeviceOrientationNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        PBDevice().endGeneratingDeviceOrientationNotifications()
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
        
        if let view = self.selectedImage, thumbnail = view.image {
            let activity = ImageActivityItemProvider(image: thumbnail) {
                
                print("GENERATING...")
                dispatch_async(dispatch_get_main_queue()) {
                    self.share?.dismissViewControllerAnimated(true, completion: nil)
                    self.progressBar.progress = 0.0
                    self.progressContainer.hidden = false
                }
                
                let fullImage = self.mojo.fullyRenderedImage(view)
                print("SHARING IMAGE", fullImage.size)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.progressContainer.hidden = true
                }
                
                return fullImage
            }
        
            let share = UIActivityViewController(activityItems: [activity], applicationActivities: nil)
            share.modalPresentationStyle = .Popover
            share.popoverPresentationController?.sourceView = self.view
            share.popoverPresentationController?.sourceRect = self.shareButton.frame
            self.presentViewController(share, animated: true, completion: nil)
            self.share = share
        }
    }
    
    
    @IBAction func didTapCamera(sender: AnyObject) {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            let picker = UIImagePickerController.init()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = .Camera
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapLibrary(sender: AnyObject) {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)) {
            let picker = UIImagePickerController.init()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = .PhotoLibrary
            picker.modalPresentationStyle = UIModalPresentationStyle.Popover
            picker.popoverPresentationController?.sourceView = self.view
            picker.popoverPresentationController?.sourceRect = self.libraryButton.frame
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("PICKED!")
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        print(info)
        print(chosenImage)
        
        self.image = chosenImage
        
        // save the original image
        if (NSUserDefaults.standardUserDefaults().boolForKey("save_camera_shot") && picker.sourceType == .Camera) {
            UIImageWriteToSavedPhotosAlbum(chosenImage, nil, nil, nil);
        }
        
        // update the view
        updateImage(chosenImage)
        
        // ditch the picker
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func updateImage(image:UIImage) {
        print("UPDATE IMAGE", image)
        mojo.renderImage(image)
    }
    
    
    func focusImage(view:FilterView) {
        
        // Update buttons
        self.cameraButton.hidden = true
//        self.libraryButton.hidden = true
        self.backButton.hidden = false
        self.shareButton.hidden = false
        
        // Focus the view
        self.imagesView.focusView(view)
        
        // Remember which one we've focused
        // umm... no, we need the full-res image
        self.selectedImage = view
        
        self.mojo.focusImage(view)
    }
    
    func unfocusImage() {
        
        // Update buttons
        self.cameraButton.hidden = false
//        self.libraryButton.hidden = false
        self.backButton.hidden = true
        self.shareButton.hidden = true
        
        // Defocus the view
        self.imagesView.removeFocus()
        
        self.selectedImage = nil
        mojo.defocusImage()
    }
    
    // Mojo Delegate ////////////////////////////////////////////////////////
    
    
    func mojoDidRefreshGesture() {
        if let img = image {
            updateImage(img)
        }
    }
    
    func mojoIsWorking(working: Bool) {
        if (working) {
            spinner.hidden = false
            spinner.startAnimating()
        }
        else {
            spinner.hidden = true
            spinner.stopAnimating()
        }
    }
    
    
    // ----------------------------------------------------------------
    
    func renderProgress(percent: Float) {
        dispatch_async(dispatch_get_main_queue()) {
            self.progressBar.progress = percent
        }
    }
    
    
    // Rotations /////////////////////////////////////////////////////
    
    func orientationDidChange() {
        
        let orientation = PBDevice().orientation
        var rotate : CGFloat = 0.0
        
        if (orientation == .Portrait) {
            rotate = 0.0
            refreshSwipe.direction = .Left
        }
        
        else if (orientation == .LandscapeLeft){
			rotate = CGFloat(M_PI)/2.0
            refreshSwipe.direction = .Up
        }
        
        else if (orientation == .PortraitUpsideDown) {
            rotate = CGFloat(M_PI)
            refreshSwipe.direction = .Right
        }
        
        else {
            rotate = -CGFloat(M_PI)/2.0
            refreshSwipe.direction = .Down
        }
        
        
        let m = CGAffineTransformMakeRotation(CGFloat(rotate));
        UIView.animateWithDuration(0.4) {
            self.allButtons.forEach { (button) -> () in
                button.transform = m
            }
        }
        
        // in the "unnatural" orientation. Always requires scaling!
        var scale : CGFloat = 1.0
        if (orientation == .LandscapeLeft || orientation == .LandscapeRight) {
            if let img = self.image {
                let widthScale = topLeftImage.bounds.size.width / img.size.width;
                let heightScale = topLeftImage.bounds.size.height / img.size.height;
                let imageScale = min(widthScale, heightScale);
                scale = topLeftImage.bounds.size.width / (imageScale * img.size.height);
            }
        }
        
        mojo.setRotations(rotate, scale: scale)
    }
}
