//
//  UIImage+metadata.swift
//  NoirPhoto
//
//  Created by Sean Hess on 4/29/16.
//  Copyright © 2016 Moment Park. All rights reserved.
//

import Foundation
import ImageIO

extension UIImage {

    func imageWithMetadata(metadata:NSDictionary) -> NSData? {
        let destData = NSMutableData()
        
        if let photoData = UIImageJPEGRepresentation(self, 1.0), source = CGImageSourceCreateWithData(photoData, nil), uti = CGImageSourceGetType(source), destination = CGImageDestinationCreateWithData(destData, uti, 1, nil) {
            CGImageDestinationAddImageFromSource(destination, source, 0, metadata)
            
            if CGImageDestinationFinalize(destination) {
                return destData
            }
            else {
                return nil
            }
        }
        return nil
    }
    
}