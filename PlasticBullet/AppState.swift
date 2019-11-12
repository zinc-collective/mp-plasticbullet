//
//  AppState.swift
//  PlasticBullet
//
//  Created by Sean Hess on 4/22/16.
//  Copyright © 2019 Zinc Collective LLC. All rights reserved.
//

import UIKit


// simple storage of stuffs
class AppState: NSObject {

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

    var usedImages : [String] {
        get {
            if let imgs = defaults.objectForKey("usedImages") as? [String] {
                return imgs
            }
            return []
        }
        set (val) {
            defaults.setObject(val, forKey: "usedImages")
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

        usedImages = usedImages + [nextImage.lastPathComponent!]

        defaults.synchronize()
        return nextImage
    }

    // this doesn't actually store the state, it's all backed by NSUserDefaults
    static func state() -> AppState {
        return AppState()
    }

    // Archiving and unarchiving
//    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
//    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("pb-app-state")
//
//    required init?(coder decoder: NSCoder) {
//        usedImages = decoder.decodeObjectForKey("usedImages") as! [String]
//        super.init()
//    }
//
//    override init() {
//        usedImages = []
//        super.init()
//    }
//
//    func encodeWithCoder(coder: NSCoder) {
//        coder.encodeObject(usedImages, forKey: "usedImages")
//    }
//
//    static func loadState() -> AppState {
//        if let state = NSKeyedUnarchiver.unarchiveObjectWithFile(AppState.ArchiveURL.path!) as? AppState {
//            return state
//        }
//        else {
//            return AppState()
//        }
//    }
//
//    func saveState() {
//        let success = NSKeyedArchiver.archiveRootObject(self, toFile: AppState.ArchiveURL.path!)
//        if !success {
//            print("Could not save: ", AppState.ArchiveURL)
//        }
//    }


}
