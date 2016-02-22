//
//  FilterPickerViewController.swift
//  PlasticBullet
//
//  Created by Sean Hess on 2/20/16.
//  Copyright © 2016 JustStartGo. All rights reserved.
//

import UIKit

class FilterPickerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var topLeftImage: FilterView!
    @IBOutlet weak var topRightImage: FilterView!
    @IBOutlet weak var bottomLeftImage: FilterView!
    @IBOutlet weak var bottomRightImage: FilterView!
    
    var image:UIImage?
    var renderArgs:ffRenderArguments = FilterImage.randomImgParameters()
    
    var allImageViews:[FilterView] {
        get {
            return [topLeftImage, topRightImage, bottomLeftImage, bottomRightImage]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateImages()
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
    
    @IBAction func didTapRefresh(sender: AnyObject) {
        print("REFRESH")
        renderArgs = FilterImage.randomImgParameters()
        updateImages()
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
        updateImages()
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateImage(image:UIImage) {
        // set blurImage
        // prepTmpArt: resolution landscape
            // leakImg = [UIImage imageNamed:PROCESS_LEAK_6K]
            // borderImg = [UIImage imageNamed:PROCESS_BORDER_LANDSCAPE_2K]
            // cvVigArtImg null
            // VigArtImg is null
    }
    
    func updateImages() {
        if let img = self.image {
//            let view = self.allImageViews[0]
//            view.renderImage(img, renderArgs: renderArgs, blurImage: nil, cvVigArtImage: nil, sqrVigArtImage: nil, leakImage: nil, borderImage: nil)
            allImageViews.forEach({(view: FilterView) -> () in
                view.renderImage(img, renderArgs: renderArgs, blurImage: nil, cvVigArtImage: nil, sqrVigArtImage: nil, leakImage: nil, borderImage: nil)
            })
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
