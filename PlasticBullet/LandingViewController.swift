//
//  ViewController.swift
//  PlasticBullet
//
//  Created by Sean Hess on 2/18/16.
//  Copyright © 2016 JustStartGo. All rights reserved.
//

import UIKit
import AVFoundation

class LandingViewController: UIViewController {

    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var background: UIImageView!
    
    @IBOutlet weak var libraryLeft: NSLayoutConstraint!
    @IBOutlet weak var libraryTop: NSLayoutConstraint!
    
    @IBOutlet weak var cameraLeft: NSLayoutConstraint!
    @IBOutlet weak var cameraTop: NSLayoutConstraint!
    
    @IBAction func didTapLibrary(sender: AnyObject) {
        print("LIBRARY")
        self.navigationController?.performSegueWithIdentifier("Library", sender: self)
    }
    
    @IBAction func didTapCamera(sender: AnyObject) {
        print("CAMERA")
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // cameraButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        let IB_MANUAL_WIDTH = CGFloat(414)
        
        let scale = view.frame.size.width / IB_MANUAL_WIDTH
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

