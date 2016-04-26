//
//  AppState.swift
//  PlasticBullet
//
//  Created by Sean Hess on 4/22/16.
//  Copyright © 2016 JustStartGo. All rights reserved.
//

import UIKit


// simple storage of stuffs
class AppState: NSObject, NSCoding {
    
    var usedImages:[String]
    
    private var defaults = NSUserDefaults.standardUserDefaults()
    
    var unlimitedResolution : Bool {
        get {
            return defaults.boolForKey("unlimitedResolution")
        }
        set (val) {
            defaults.setBool(val, forKey: "unlimitedResolution")
            defaults.synchronize()
        }
    }
    
    func findNextImage(allImageURLs:[NSURL]) -> NSURL {
        var unusedImageURLs = allImageURLs.filter({imgURL in
            return !usedImages.contains(imgURL.lastPathComponent!)
        })
        
        if unusedImageURLs.count == 0 {
            unusedImageURLs = allImageURLs
            usedImages = []
        }

        let nextImage = unusedImageURLs[0]

        usedImages.append(nextImage.lastPathComponent!)
        saveState()
        
        return nextImage
    }
    
    
    
    // Archiving and unarchiving
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("pb-app-state")
    
    required init?(coder decoder: NSCoder) {
        usedImages = decoder.decodeObjectForKey("usedImages") as! [String]
        super.init()
    }
    
    override init() {
        usedImages = []
        super.init()
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(usedImages, forKey: "usedImages")
    }
    
    static func loadState() -> AppState {
        if let state = NSKeyedUnarchiver.unarchiveObjectWithFile(AppState.ArchiveURL.path!) as? AppState {
            return state
        }
        else {
            return AppState()
        }
    }
    
    func saveState() {
        let success = NSKeyedArchiver.archiveRootObject(self, toFile: AppState.ArchiveURL.path!)
        if !success {
            print("Could not save: ", AppState.ArchiveURL)
        }
    }
    
    
}
