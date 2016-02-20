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

class LandingViewController: UIViewController {

    
    @IBOutlet weak var background: UIImageView!
    
    
    @IBOutlet weak var cameraText: PBCircleLabel!
    @IBOutlet weak var cameraLeft: NSLayoutConstraint!
    @IBOutlet weak var cameraTop: NSLayoutConstraint!
    
    @IBOutlet weak var libraryText: PBCircleLabel!
    @IBOutlet weak var libraryLeft: NSLayoutConstraint!
    @IBOutlet weak var libraryTop: NSLayoutConstraint!
    
    @IBAction func didTapLibrary(sender: AnyObject) {
        print("LIBRARY")
        // self.navigationController?.performSegueWithIdentifier("Library", sender: self)
    }
    
    @IBAction func didTapCamera(sender: AnyObject) {
        print("CAMERA")
    }
    
    @IBAction func didTapInfo(sender: AnyObject) {
        print("INFO")
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Determine how large the phone is compared to Interface Builder
        let IB_MANUAL_WIDTH = CGFloat(414)
        let scale = view.frame.size.width / IB_MANUAL_WIDTH
        
        // -- circular text labels --------------------------------------------
        
        let font = UIFont(name: "Helvetica Bold", size: 18.0 * scale)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

