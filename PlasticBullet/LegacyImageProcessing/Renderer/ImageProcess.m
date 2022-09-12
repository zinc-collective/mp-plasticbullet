//
//  ImageProcess.m
//  PlasticBullet
//
//  Created by WXP on 10-1-15.
//  Copyright 2010 RedSafi LLC. All rights reserved.
//

//#import "ImageProcessSlow.h"
#import "ImageProcess.h"
//#import "DataFile.h"

@implementation ImageProcess

#pragma mark image scale
+(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{	
	
	//float width = image.size.width;
//	float height = image.size.height;
//	float x, x1, y1;
//	
//	if(width > height)
//	{
//		x1 = width / newSize.height;
//		y1 = height / newSize.width;
//	}
//	else
//	{
//		x1 = width / newSize.width;
//		y1 = height / newSize.height;
//	}
//	
//	x = (x1 < y1) ? x1:y1;
//	
//	newSize = CGSizeMake(width/x,height/x);
	
	
	CGSize size = image.size;
	
	double scaleWidth,scaleHeight;
	scaleWidth = newSize.width / size.width;
	scaleHeight = newSize.height / size.height;
	
	UIGraphicsBeginImageContext(newSize);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGAffineTransform transform = CGAffineTransformIdentity;
	transform = CGAffineTransformScale(transform,scaleWidth,scaleHeight);
	transform = CGAffineTransformTranslate(transform, 0, 0);
	
	CGContextConcatCTM(context, transform);
	[image drawAtPoint:CGPointMake(0.0f, 0.0f)];
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();  
    return newimg;  
}

#pragma mark 图片缩放
+(UIImage *)imageNewWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
	
	//float fwidth = image.size.width;
//	float fheight = image.size.height;
//	float x, x1, y1;
//	
//	if(fwidth > fheight)
//	{
//		x1 = fwidth / newSize.height;
//		y1 = fheight / newSize.width;
//	}
//	else
//	{
//		x1 = fwidth / newSize.width;
//		y1 = fheight / newSize.height;
//	}
//	
//	x = (x1 < y1) ? x1:y1;
//	
//	newSize = CGSizeMake(fwidth/x,fheight/x);
	
	
	
	if(!image)
		return NULL;
	int width = newSize.width;
	int height = newSize.height;
	
	int rowbytes = width*4;	
	unsigned char *buffer = (unsigned char*)malloc( height * rowbytes );
	if(buffer == nil) 
		return NULL;
	CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
	CGContextRef imageContextRef = CGBitmapContextCreate(buffer, 
														 width, 
														 height, 
														 8, 
														 rowbytes, 
														colorSpace, 
														 kCGImageAlphaPremultipliedLast
														 );
	CGContextDrawImage(imageContextRef, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), image.CGImage);
	
	UIImageOrientation o = image.imageOrientation;
	if(o ==  UIImageOrientationLeft || o ==  UIImageOrientationRight || o == UIImageOrientationRightMirrored || o == UIImageOrientationLeftMirrored )
	{
		int t = width;
		width = height;
		height = t;
		int rowbytes2 = width*4;	
		unsigned char *buffer2 = (unsigned char*)malloc( height * rowbytes2 );
		if(buffer2 == nil) 
		{
			CGColorSpaceRelease(colorSpace);
			CGContextRelease(imageContextRef);
			return NULL;
		}
		
		// Transposition
		for(int y=0; y<height; ++y)
		{
			unsigned char *oT = &buffer2[y*rowbytes2];
			unsigned char *iT = &buffer[y*4];
			for(int x=0; x<width; ++x)
			{
				memcpy(oT, iT, 4);
				oT+=4;
				iT+=rowbytes;
			}
		}
		
		CGContextRelease(imageContextRef);
		free(buffer);
		buffer = buffer2;
		rowbytes = rowbytes2;
		imageContextRef = CGBitmapContextCreate(buffer, 
												width, 
												height, 
												8, 
												rowbytes, 
												colorSpace, 
												kCGImageAlphaPremultipliedLast
												);
		
	}
	
	if(o ==  UIImageOrientationDown || o ==  UIImageOrientationRight || o == UIImageOrientationRightMirrored || o == UIImageOrientationUpMirrored )
	{
		//Flip x-axis
		//
		int width2 = width/2;
		for(int y=0; y<height; ++y)
		{
			unsigned char *oT = &buffer[y*rowbytes];
			unsigned char *oT2 = oT + (width-1)*4;
			for(int x=0; x<width2; ++x)
			{
				unsigned char pixel[4];
				memcpy(pixel, oT, 4);					
				memcpy(oT, oT2, 4);
				memcpy(oT2, pixel, 4);					
				oT+=4;
				oT2-=4;
			}
		}
	}
	if(o ==  UIImageOrientationLeft || o ==  UIImageOrientationDown || o == UIImageOrientationRightMirrored || o == UIImageOrientationDownMirrored )
	{
		// Flip y-axis
		//
		int height2 = height/2;
		unsigned char *lineBuffer = (unsigned char *)malloc(rowbytes);
		for(int y=0; y<height2; ++y)
		{
			unsigned char *oT = &buffer[y*rowbytes];
			unsigned char *oT2 = &buffer[(height-1-y)*rowbytes];
			memcpy(lineBuffer, oT, rowbytes);
			memcpy(oT, oT2, rowbytes);
			memcpy(oT2, lineBuffer, rowbytes);			
		}
		free(lineBuffer);
	}	
	
	// get the new CGImage
	CGImageRef newImageRef = CGBitmapContextCreateImage(imageContextRef);
	// get the UIImage back	
	UIImage *newImage = [[UIImage alloc] initWithCGImage:newImageRef];
	CGColorSpaceRelease(colorSpace);
	CGContextRelease(imageContextRef);
	CGImageRelease(newImageRef);	
	free(buffer);
	return newImage;
}

+(UIImage *)imageNewWithImage2:(UIImage *)image scaledToSize:(CGSize)newSize
{
	
	float fwidth = image.size.width;
	float fheight = image.size.height;
	float x, x1, y1;
	
	if(fwidth > fheight)
	{
		x1 = fwidth / newSize.height;
		y1 = fheight / newSize.width;
	}
	else
	{
		x1 = fwidth / newSize.width;
		y1 = fheight / newSize.height;
	}
	
	x = (x1 < y1) ? x1:y1;
	
	newSize = CGSizeMake(fwidth/x,fheight/x);
	
	
	
	if(!image)
		return NULL;
	int width = newSize.width;
	int height = newSize.height;
	
	int rowbytes = width*4;	
	unsigned char *buffer = (unsigned char*)malloc( height * rowbytes );
	if(buffer == nil) 
		return NULL;
	CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
	CGContextRef imageContextRef = CGBitmapContextCreate(buffer, 
														 width, 
														 height, 
														 8, 
														 rowbytes, 
														 colorSpace, 
														 kCGImageAlphaPremultipliedLast
														 );
	CGContextDrawImage(imageContextRef, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), image.CGImage);
	
	UIImageOrientation o = image.imageOrientation;
	if(o ==  UIImageOrientationLeft || o ==  UIImageOrientationRight || o == UIImageOrientationRightMirrored || o == UIImageOrientationLeftMirrored )
	{
		int t = width;
		width = height;
		height = t;
		int rowbytes2 = width*4;	
		unsigned char *buffer2 = (unsigned char*)malloc( height * rowbytes2 );
		if(buffer2 == nil) 
		{
			CGColorSpaceRelease(colorSpace);
			CGContextRelease(imageContextRef);
			return NULL;
		}
		
		// Transposition
		for(int y=0; y<height; ++y)
		{
			unsigned char *oT = &buffer2[y*rowbytes2];
			unsigned char *iT = &buffer[y*4];
			for(int x=0; x<width; ++x)
			{
				memcpy(oT, iT, 4);
				oT+=4;
				iT+=rowbytes;
			}
		}
		
		CGContextRelease(imageContextRef);
		free(buffer);
		buffer = buffer2;
		rowbytes = rowbytes2;
		imageContextRef = CGBitmapContextCreate(buffer, 
												width, 
												height, 
												8, 
												rowbytes, 
												colorSpace, 
												kCGImageAlphaPremultipliedLast
												);
		
	}
	
	if(o ==  UIImageOrientationDown || o ==  UIImageOrientationRight || o == UIImageOrientationRightMirrored || o == UIImageOrientationUpMirrored )
	{
		//Flip x-axis
		//
		int width2 = width/2;
		for(int y=0; y<height; ++y)
		{
			unsigned char *oT = &buffer[y*rowbytes];
			unsigned char *oT2 = oT + (width-1)*4;
			for(int x=0; x<width2; ++x)
			{
				unsigned char pixel[4];
				memcpy(pixel, oT, 4);					
				memcpy(oT, oT2, 4);
				memcpy(oT2, pixel, 4);					
				oT+=4;
				oT2-=4;
			}
		}
	}
	if(o ==  UIImageOrientationLeft || o ==  UIImageOrientationDown || o == UIImageOrientationRightMirrored || o == UIImageOrientationDownMirrored )
	{
		// Flip y-axis
		//
		int height2 = height/2;
		unsigned char *lineBuffer = (unsigned char *)malloc(rowbytes);
		for(int y=0; y<height2; ++y)
		{
			unsigned char *oT = &buffer[y*rowbytes];
			unsigned char *oT2 = &buffer[(height-1-y)*rowbytes];
			memcpy(lineBuffer, oT, rowbytes);
			memcpy(oT, oT2, rowbytes);
			memcpy(oT2, lineBuffer, rowbytes);			
		}
		free(lineBuffer);
	}	
	
	// get the new CGImage
	CGImageRef newImageRef = CGBitmapContextCreateImage(imageContextRef);
	// get the UIImage back	
	UIImage *newImage = [[UIImage alloc] initWithCGImage:newImageRef];
	CGColorSpaceRelease(colorSpace);
	CGContextRelease(imageContextRef);
	CGImageRelease(newImageRef);	
	free(buffer);
	return newImage;
}


@end
