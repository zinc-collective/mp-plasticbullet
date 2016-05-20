//
//  InfoViewController.swift
//  PlasticBullet
//
//  Created by Sean Hess on 2/20/16.
//  Copyright © 2016 JustStartGo. All rights reserved.
//

import UIKit
import SwiftyMarkdown

class InfoViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var beforeText: UITextView!
    @IBOutlet weak var afterText: UITextView!
    @IBOutlet weak var resolutionSwitch: UISwitch!
    
    let appState = AppState.state()
    let redColor = UIColor(red: 0.827, green: 0.392, blue: 0.2235, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        beforeText.dataDetectorTypes = .All
        beforeText.delegate = self
        afterText.dataDetectorTypes = .All
        afterText.delegate = self
//          #D36457
        beforeText.linkTextAttributes = [NSForegroundColorAttributeName: redColor]
        afterText.linkTextAttributes = [NSForegroundColorAttributeName: redColor]
        
        resolutionSwitch.on = appState.unlimitedResolution
        
        if let before = loadMD("info-text1"), after = loadMD("info-text2") {
            before.body.color = UIColor.whiteColor()
            after.body.color = UIColor.whiteColor()
            before.link.color = UIColor.greenColor() //
            after.link.color = UIColor.greenColor()
            
            beforeText.attributedText = before.attributedString()
            afterText.attributedText = after.attributedString()
        }
    }
    
    func loadMD(name:String) -> SwiftyMarkdown? {
        if let url = NSBundle.mainBundle().URLForResource(name, withExtension: "md") {
            return SwiftyMarkdown(url: url)
        }
        return nil
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.title = "Plastic Bullet"
        self.navigationController?.navigationBarHidden = false
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func resolutionSwitchChanged(sender: AnyObject) {
        appState.unlimitedResolution = resolutionSwitch.on
    }
    
    @IBAction func didTapBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
