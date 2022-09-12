//
//  FilterableImage.swift
//  PlasticBullet
//
//  Created by Christopher Wallace on 3/23/21.
//  Copyright © 2021 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

struct FilterableImage: Identifiable, Equatable {
    var processedImage: UIImage = testImages[4]!
//    @State var processedImage: UIImage?
    var imageLens: ModuleLens = ModuleLens()
    var id: String = UUID().uuidString
//    @State var rawImage: UIImage
    var rawImage: UIImage
    var selectedTile: UIImageView?
    
    init(rawImage: UIImage) {
        self.rawImage = rawImage
        self.processImage()
    }
    
    static func == (lhs: FilterableImage, rhs: FilterableImage) -> Bool {
        return (lhs.rawImage == rhs.rawImage)
    }
    
    static func != (lhs: FilterableImage, rhs: FilterableImage) -> Bool {
        return !(lhs.rawImage == rhs.rawImage)
    }
    
//    static func == (lhs: FilterableImage, rhs: FilterableImage) -> Bool {
//        return (lhs.$rawImage.wrappedValue == rhs.$rawImage.wrappedValue)
//    }
//
//    static func != (lhs: FilterableImage, rhs: FilterableImage) -> Bool {
//        return !(lhs.$rawImage.wrappedValue == rhs.$rawImage.wrappedValue)
//    }
    
    public mutating func processImage(){
        print("------------ PROCESSING!!!!!!")
//        self.processedImage = self.imageLens.processFilters(source: self.rawImage)
        
//        The problem is with the @State that needs to be a @StateObject--an ObservableObject
//        Other question should self.rawImage be Observable as well?
//        self.processedImage = self.imageLens.processFilters(source: (self.processedImage ?? self.rawImage))
        
        // Objc Test
        // This should go into the ModuleLens; but it has no concept of image size yet. (it could pull dimensions from the image arg)
//        self.processedImage = ImageProcess.imageNew(withImage2: self.rawImage, scaledTo: CGSize(width: 150, height: 150))
        self.processedImage = self.rawImage.copy() as! UIImage
        
        self.selectedTile = self.selectedTile ?? UIImageView(image: self.processedImage)
        mojo.topLeftView = self.selectedTile
        mojo.renderImage(self.selectedTile?.image)
        /* take NOTE of - (int)renderImages
         - (int)renderImages
         -(void)renderImage:(UIImage *)image
         
         STRATEGY: TODO: recommend dupeing the MojoViewController and editing it to work with a single image and return images from render Calls
         -- it seems to change the image in-place. I need changes to affect the image NOT the UIImageView  (mojo.topLeftView)
         */
        
        /*
         This is just here for reference.  I may not need any of these:
                mojo.delegate = self
                mojo.initGrid(self.gridSize)
                mojo.topLeftView = self.topLeftImage
                mojo.topRightView = self.topRightImage
                mojo.bottomLeftView = self.bottomLeftImage
                mojo.bottomRightView = self.bottomRightImage
                
                mojo.topMiddleView = self.topMiddleImage
                mojo.middleLeftView = self.middleLeftImage
                mojo.middleMiddleView = self.middleMiddleImage
                mojo.middleRightView = self.middleRightImage
                mojo.bottomMiddleView = self.bottomMiddleView
                
                mojo.view = self.imagesView
                
                self.renderer.delegate = self
                mojo.renderer = self.renderer
                
                mojo.viewDidLoad()
         
         */
    }
    
    // Objc Test  from ImageViewController (Legacy Branch)
    let mojo:mojoViewController = mojoViewController.init()
    let renderer:Renderer = Renderer.init()
    private func updateImage(image:UIImage) {
        print("UPDATE IMAGE", image)
        mojo.renderImage(image)
    }
}
