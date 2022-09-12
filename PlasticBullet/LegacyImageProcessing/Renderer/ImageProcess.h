//
//  ImageProcess.h
//  PlasticBullet
//
//  Created by WXP on 10-1-15.
//  Copyright 2010 RedSafi LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import "DataFile.h"
//#import "DataTypeDef.h"
//#import "mojoAppDelegate.h"


@interface ImageProcess : NSObject
{

}

+(UIImage*)imageWithImage:(UIImage*)image 
	scaledToSize:(CGSize)newSize;

+(UIImage*)imageNewWithImage:(UIImage *)image 
	scaledToSize:(CGSize)newSize;

+(UIImage*)imageNewWithImage2:(UIImage *)image 
				scaledToSize:(CGSize)newSize;



@end
