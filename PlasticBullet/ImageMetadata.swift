//
//  ImageMetadata.swift
//  PlasticBullet
//
//  Created by Sean Hess on 4/18/16.
//  Copyright © 2019 Zinc Collective LLC. All rights reserved.
//

import Foundation
import UIKit
import Photos


typealias PhotoMeta = [String : AnyObject]

class ImageMetadata {

    // these don't always return. Only if they find it
    class func fetchMetadataForURL(url:NSURL, found: (PhotoMeta) -> Void) {
        if let asset = PHAsset.fetchAssetsWithALAssetURLs([url], options: nil).lastObject as? PHAsset {
            ImageMetadata.fetchMetadataForAsset(asset, found: found)
        }
    }

    class func fetchMetadataForAsset(asset:PHAsset, found: (PhotoMeta) -> Void) {
        let options = PHContentEditingInputRequestOptions()
        options.networkAccessAllowed = true // download from iCloud if needed
        asset.requestContentEditingInputWithOptions(options, completionHandler: { (contentEditingInput, _) in

            if let fullURL = contentEditingInput?.fullSizeImageURL {
                let fullImage = CIImage(contentsOfURL: fullURL)
                if let meta = fullImage?.properties {
                    found(meta)
                }
            }
        })
    }
}