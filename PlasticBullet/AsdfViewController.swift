//
//  AsdfViewController.swift
//  PlasticBullet
//
//  Created by Sean Hess on 3/14/16.
//  Copyright © 2016 JustStartGo. All rights reserved.
//

import UIKit

class AsdfViewController: UIViewController {

    @IBOutlet weak var asdf: UIView!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let share = UIActivityViewController(activityItems: [image!], applicationActivities: nil)
//        share.modalPresentationStyle = .Popover
//        share.popoverPresentationController?.sourceView = self.view
//        share.popoverPresentationController?.sourceRect = self.shareButton.frame
//        self.presentViewController(share, animated: true, completion: nil)
        share.view.frame = self.asdf.bounds
        self.asdf.addSubview(share.view)
        self.addChildViewController(share)
    }
}
