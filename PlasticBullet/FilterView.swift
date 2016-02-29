//
//  FilterView.swift
//  PlasticBullet
//
//  Created by Sean Hess on 2/22/16.
//  Copyright © 2016 JustStartGo. All rights reserved.
//

import UIKit

class FilterView: UIImageView {
    
//    var imageView:UIImageView = UIImageView.init()
//    var padding:CGFloat = 4
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.contentMode = UIViewContentMode.ScaleAspectFit
    }

//    override func layoutSubviews() {
//        super.layoutSubviews()
//        let size = self.frame.size
//        imageView.frame = CGRectMake(padding, padding, size.width - (3/2) * padding, size.height - (3/2) * padding)
//    }
    
    // this needs to be called in a background thread
    // then update in the foreground...
//    func renderImage(image:UIImage, renderArgs:ffRenderArguments, blurImage:UIImage?, cvVigArtImage:UIImage?, sqrVigArtImage:UIImage?, leakImage: UIImage?, borderImage: UIImage?) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//        
//            let renderedImage = self.createImage(image, renderArgs: renderArgs, blurImage: blurImage, cvVigArtImage: cvVigArtImage, sqrVigArtImage: sqrVigArtImage, leakImage: leakImage, borderImage: borderImage)
//            
//            dispatch_async(dispatch_get_main_queue()) {
//                self.imageView.image = renderedImage
//            }
//        }
//    }
//    
//    func createImage(image:UIImage, renderArgs:ffRenderArguments, blurImage:UIImage?, cvVigArtImage:UIImage?, sqrVigArtImage:UIImage?, leakImage: UIImage?, borderImage: UIImage?) -> UIImage {
//        let isLandscape = (image.imageOrientation == UIImageOrientation.Right) || (image.imageOrientation == UIImageOrientation.Left)
//        let doConserveMem = false
//        let doHiRes = true
//        
//        print("ORIGINAL", image.size)
//        print("RESIZED", image.size)
//        
//        // crashes for some reason if I resize
////        let resized = FilterView.scaleUIImageToSize(image, size: self.bounds.size)
//        
//        var copy = UIImage(data: UIImagePNGRepresentation(image)!);
//        
//        print("RESIZED", copy?.size)
//        
//		let rendered = Renderer.imageWithSourceImg(&copy,
//                    softImage:blurImage,
//                cvVigArtImage:cvVigArtImage,
//                    cvOpacity:renderArgs.cvOpacity,
//               sqrVigArtImage:sqrVigArtImage,
//                    sqrScaleX:renderArgs.sqrScaleX,
//                    sqrScaleY:renderArgs.sqrScaleY,
//                    leakImage:leakImage,
//                      leakRGB:renderArgs.leakTintRGB,
//             randStartYIndex1:renderArgs.startY1,
//             randStartYIndex2:renderArgs.startY2,
//             randStartYIndex3:renderArgs.startY3,
//					imageSize:image.size,
//             diffusionOpacity:renderArgs.difOpacity,
//                  sqrVignette:renderArgs.SqrOpacity,
//                  leakopacity:renderArgs.opacity3D,
//             CCRGBMaxMinValue:renderArgs.CCRGBMaxMin,
//					  monoRGB:renderArgs.rgbValue,
//               desatBlendrand:renderArgs.blendrand,
//                 desatRandNum:renderArgs.randNum,
//				  borderImage:borderImage,
//				  borderRandX:renderArgs.randX,
//                  borderRandY:renderArgs.randY,
//                  borderRandS:renderArgs.randBorderScale,
//            borderRandDoScale:renderArgs.randBorderDoScale,
//				   borderType:renderArgs.borderType,
//				   borderLeft:renderArgs.borderLeft,
//					borderTop:renderArgs.borderTop,
//				  borderRight:renderArgs.borderRight,
//				 borderBottom:renderArgs.borderBottom,
//			   sCurveContrast:renderArgs.contrast,
//           colorFadeRGBMaxMin:renderArgs.colorFadeRGB,
//            cornerSoftOpacity:renderArgs.cornerOpacity,
//                        hiRes:doHiRes,
//              convserveMemory:doConserveMem,
//				  isLandscape:isLandscape)
//        
//        return rendered
//    }
//    
//    /*
//    // Only override drawRect: if you perform custom drawing.
//    // An empty implementation adversely affects performance during animation.
//    override func drawRect(rect: CGRect) {
//        // Drawing code
//    }
//    */
//    
//    // CREATE IMAGES
//	// pOutputImage = [self createNewImage:&portraitImage imgWidth:width imgHeight:height imgParameter:index];
//    // OR
//    // pOutputImage = [[UIImage alloc] initWithCGImage:viewImageArray[index].CGImage];
//    
//    // viewImageArray[index] = [[UIImage alloc] initWithCGImage:pOutputImage.CGImage];
//    
//    
//    // SET IMAGES (on main thread) I guess this is in the background
////		[imageViewArray[index] performSelectorOnMainThread:@selector(setImage:) withObject:pOutputImage waitUntilDone:NO];	
////		[pOutputImage release];
////		[self performSelectorOnMainThread:@selector(animateImageView:) withObject:imageViewArray[index] waitUntilDone:NO];
//    
//    // CACHING?
//    // RENDER IN THE BACKGROUND
//    // renderImages ...
//    
////    /*
////    Image Resizing Techniques: http://bit.ly/1Hv0T6i
////    */
//    class func scaleUIImageToSize(let image: UIImage, let size: CGSize) -> UIImage {
//        let hasAlpha = false
//        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
//        
//        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
//        image.drawInRect(CGRect(origin: CGPointZero, size: size))
//        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return scaledImage
//    }
//


}

