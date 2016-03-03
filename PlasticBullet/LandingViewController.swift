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

class LandingViewController: UIViewController  {
    
    @IBOutlet weak var background: UIImageView!
    
    
    @IBOutlet weak var cameraText: PBCircleLabel!
    @IBOutlet weak var cameraLeft: NSLayoutConstraint!
    @IBOutlet weak var cameraTop: NSLayoutConstraint!
    
    @IBOutlet weak var libraryText: PBCircleLabel!
    @IBOutlet weak var libraryLeft: NSLayoutConstraint!
    @IBOutlet weak var libraryTop: NSLayoutConstraint!
    
    // constraints
    @IBOutlet weak var backgroundAspect: NSLayoutConstraint!
    @IBOutlet weak var barAspect: NSLayoutConstraint!
    @IBOutlet weak var libraryProportionalHeight: NSLayoutConstraint!
    @IBOutlet weak var cameraProportionalHeight: NSLayoutConstraint!
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Determine how large the phone is compared to Interface Builder
        let IB_MANUAL_WIDTH = CGFloat(414)
        let scale = view.frame.size.width / IB_MANUAL_WIDTH
        
        // -- ipad change constraints before altering...
        var fontSize:CGFloat = 18.0
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            tweakConstraintsForIPad()
            fontSize = 12.0
        }
        
        // -- circular text labels --------------------------------------------
        
        let font = UIFont(name: "Helvetica Bold", size: fontSize * scale)
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
    
    func tweakConstraintsForIPad() {
        
        // ignore aspect ratios for background and bar, using the fallbacks in the storyboard
        backgroundAspect.priority = 100
        barAspect.priority = 100
        
        // manually set position of buttons
        print(cameraLeft.constant, cameraTop.constant)
        cameraLeft.constant = 353
        
        print(libraryLeft.constant, libraryTop.constant)
        libraryLeft.constant = 300
        libraryTop.constant = 444
        
        // manually set font
//        let font = UIFont(name: "Helvetica Bold", size: 24.0)
//        cameraText.font = font
//        libraryText.font = font
        
        libraryProportionalHeight.priority = 100
        cameraProportionalHeight.priority = 100
        
    }
    
//    override func viewDidLayoutSubviews() {
//        print(self.view.frame)
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    @IBAction func didTapLibrary(sender: AnyObject) {
        print("LIBRARY")
        let nav = self.navigationController as! NavigationController
        nav.openLibrary()
    }
    
    @IBAction func didTapCamera(sender: AnyObject) {
        print("CAMERA")
        let nav = self.navigationController as! NavigationController
        nav.openCamera()
    }
    
    @IBAction func didTapInfo(sender: AnyObject) {
        print("INFO")
        let nav = self.navigationController as! NavigationController
        print(self.navigationController)
        nav.openInfo()
    }
}

