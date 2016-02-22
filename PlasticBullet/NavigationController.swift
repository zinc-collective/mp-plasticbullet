//
//  NavigationViewController.swift
//  PlasticBullet
//
//  Created by Sean Hess on 2/22/16.
//  Copyright © 2016 JustStartGo. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.tintColor = TintColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func woot(segue:UIStoryboardSegue) {
        print("Close info")
    }
    
    func openLibrary() {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)) {
            let picker = UIImagePickerController.init()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    func openCamera() {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            let picker = UIImagePickerController.init()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    func openInfo() {
        print("INFO")
        self.performSegueWithIdentifier("Info", sender: self)
    }
    
    @IBAction func closeInfo(segue:UIStoryboardSegue) {
        print("Close info")
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage]
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("Filters", sender: chosenImage)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "Filters") {
            let image = sender as! UIImage
            let filters = segue.destinationViewController as! FilterPickerViewController
            filters.image = image
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
