//
//  FilterPickerViewController.swift
//  PlasticBullet
//
//  Created by Sean Hess on 2/20/16.
//  Copyright © 2016 JustStartGo. All rights reserved.
//

import UIKit
import Photos

class ImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MojoDelegate, RenderDelegate {
    
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
    var imageMetadata:PhotoMeta?
    
    var mojo:mojoViewController = mojoViewController.init()
    var renderer:Renderer = Renderer.init()
    
    var share:UIActivityViewController?
    
    @IBOutlet var refreshSwipe: UISwipeGestureRecognizer!
    
    var allImageViews:[FilterView] {
        get {
            return [topLeftImage, topRightImage, bottomLeftImage, bottomRightImage, topMiddleImage, middleLeftImage, middleMiddleImage, middleRightImage, bottomMiddleView]
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
        
        self.spinner.hidden = true
        self.progressContainer.hidden = true
        self.backButton.hidden = true
        self.shareButton.hidden = true
        
        self.imagesView.addGridItem(self.topLeftImage)
        self.imagesView.addGridItem(self.topRightImage)
        self.imagesView.addGridItem(self.bottomLeftImage)
        self.imagesView.addGridItem(self.bottomRightImage)
        
        if gridSize == GRID_9 {
            self.imagesView.addGridItem(self.topMiddleImage)
            self.imagesView.addGridItem(self.middleLeftImage)
            self.imagesView.addGridItem(self.middleMiddleImage)
            self.imagesView.addGridItem(self.middleRightImage)
            self.imagesView.addGridItem(self.bottomMiddleView)
            
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ImageViewController.orientationDidChange), name:UIDeviceOrientationDidChangeNotification, object: nil)
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
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
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
        
            let srcRect = self.shareButton.frame
            let share = UIActivityViewController(activityItems: [activity], applicationActivities: nil)
            share.modalPresentationStyle = .Popover
            share.popoverPresentationController?.sourceView = self.view
            share.popoverPresentationController?.sourceRect = CGRect(x: srcRect.origin.x, y: srcRect.origin.y + 30, width: srcRect.size.width, height: srcRect.size.height)
            share.popoverPresentationController?.permittedArrowDirections = .Up
            
            share.completionWithItemsHandler = { activityType, completed, returnedItems, error in
                // this will hide even if cancelled
                self.progressContainer.hidden = true
            }
            
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
        
        let img = chooseImage(info, sourceType: picker.sourceType)
        
        // update the view
        updateImage(img)
        
        // ditch the picker
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func chooseImage(info: [String : AnyObject], sourceType : UIImagePickerControllerSourceType) -> UIImage {
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        print(info)
        print(chosenImage)
        
        // only valid for newly taken photos
        let meta = info[UIImagePickerControllerMediaMetadata] as? PhotoMeta
        self.imageMetadata = meta
        
        
        let murl = info[UIImagePickerControllerReferenceURL] as? NSURL
        print("MURL", murl)
        if let url = murl {
            ImageMetadata.fetchMetadataForURL(url) { meta in
                print("META", meta)
                self.imageMetadata = meta
            }
        }
        
        self.image = chosenImage
        
        // save the original image
        // the chosen image doesn't have GPS data yet.
        if (NSUserDefaults.standardUserDefaults().boolForKey("save_camera_shot") && sourceType == .Camera) {
            UIImageWriteToSavedPhotosAlbum(chosenImage, nil, nil, nil)
        }
        
        return chosenImage
    }
    
    
    private func updateImage(image:UIImage) {
        print("UPDATE IMAGE", image)
        mojo.renderImage(image)
    }
    
    
    func focusImage(view:FilterView) {
        
        // Update buttons
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
        
        switch orientation {
        case .Portrait:
            rotate = 0.0
            refreshSwipe.direction = .Left
        case .LandscapeLeft:
			rotate = CGFloat(M_PI)/2.0
            refreshSwipe.direction = .Up
        case .PortraitUpsideDown:
            rotate = CGFloat(M_PI)
            refreshSwipe.direction = .Right
        case .LandscapeRight:
            rotate = -CGFloat(M_PI)/2.0
            refreshSwipe.direction = .Down
        default:
            return
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
