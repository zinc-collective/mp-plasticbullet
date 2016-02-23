//
//  FilterPickerViewController.swift
//  PlasticBullet
//
//  Created by Sean Hess on 2/20/16.
//  Copyright © 2016 JustStartGo. All rights reserved.
//

import UIKit

class FilterPickerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MojoDelegate {
    
    @IBOutlet weak var topLeftImage: FilterView!
    @IBOutlet weak var topRightImage: FilterView!
    @IBOutlet weak var bottomLeftImage: FilterView!
    @IBOutlet weak var bottomRightImage: FilterView!
    @IBOutlet weak var imagesView: UIView!
    
    var image:UIImage?
    
    var mojo:mojoViewController = mojoViewController.init()
    
    var allImageViews:[FilterView] {
        get {
            return [topLeftImage, topRightImage, bottomLeftImage, bottomRightImage]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        self.title = "UMMM"
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
        // set blurImage
        // prepTmpArt: resolution landscape
            // leakImg = [UIImage imageNamed:PROCESS_LEAK_6K]
            // borderImg = [UIImage imageNamed:PROCESS_BORDER_LANDSCAPE_2K]
            // cvVigArtImg null
            // VigArtImg is null
    }
    
    func didTransformOrientations(isPortrait: Bool) {
        print("SWITCHING!", isPortrait)
    }
    
//    func updateImages() {
//        if let img = self.image {
////            let view = self.allImageViews[0]
////            view.renderImage(img, renderArgs: renderArgs, blurImage: nil, cvVigArtImage: nil, sqrVigArtImage: nil, leakImage: nil, borderImage: nil)
//            allImageViews.forEach({(view: FilterView) -> () in
//                view.renderImage(img, renderArgs: renderArgs, blurImage: nil, cvVigArtImage: nil, sqrVigArtImage: nil, leakImage: nil, borderImage: nil)
//            })
//        }
//    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
