//
//  NavigationViewController.swift
//  PlasticBullet
//
//  Created by Sean Hess on 2/22/16.
//  Copyright © 2016 JustStartGo. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController, UINavigationControllerDelegate {

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
    
    func openInfo() {
        print("INFO")
        self.performSegueWithIdentifier("Info", sender: self)
    }
    
    @IBAction func closeInfo(segue:UIStoryboardSegue) {
        print("Close info")
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
