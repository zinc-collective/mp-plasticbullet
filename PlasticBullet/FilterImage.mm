//
//  FilteredImage.m
//  PlasticBullet
//
//  Created by Sean Hess on 2/22/16.
//  Copyright © 2016 JustStartGo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FilterImage.h"
#import "DataTypeDef.h"
#import "Plugin_Render.h"

static int doRender(int width, int height, int rowbytes, unsigned char *buffer, const RenderArguments &renderArgs)
{
    //sleep(1);//hack
    return PluginRender(renderArgs, width, height, rowbytes, buffer, 1.f, 1.f, 1.f);
}


static UIImage* createImage(int width, int height, UIImage *image, RenderArguments *pRenderArgs = NULL, bool histogramEqualization = false)
{
	if(!image)
		return NULL;
	int rowbytes = width*4;	
	unsigned char *buffer = (unsigned char*)malloc( height * rowbytes );
	if(buffer == nil) 
		return NULL;
	CGContextRef imageContextRef = CGBitmapContextCreate(buffer, 
														 width, 
														 height, 
														 8, 
														 rowbytes, 
														 CGImageGetColorSpace(image.CGImage), 
														 kCGImageAlphaPremultipliedLast
														 );
	CGContextDrawImage(imageContextRef, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), image.CGImage);
	
	if(pRenderArgs)
	{
		if(doRender(width, height, rowbytes, buffer, *pRenderArgs)!=0)
		{
			CGContextRelease(imageContextRef);
			free(buffer);
			return NULL;
		}
	}
	if(histogramEqualization)
	{
		if(PluginRenderHistogramEqualization(width, height, rowbytes, buffer)!=0)
		{
			CGContextRelease(imageContextRef);
			free(buffer);
			return NULL;
		}
	}
	
	UIImageOrientation o = image.imageOrientation;
	if(o ==  UIImageOrientationLeft ||  o ==  UIImageOrientationRight || o == UIImageOrientationRightMirrored || o == UIImageOrientationLeftMirrored )
	{
		int t = width;
		width = height;
		height = t;
		int rowbytes2 = width*4;	
		unsigned char *buffer2 = (unsigned char*)malloc( height * rowbytes2 );
		if(buffer2 == nil) 
			return NULL;
		
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
												CGImageGetColorSpace(image.CGImage), 
												kCGImageAlphaPremultipliedLast
												);
		
	}
	
	if(o ==  UIImageOrientationDown || o ==  UIImageOrientationRight || o == UIImageOrientationRightMirrored || o == UIImageOrientationUpMirrored )
	{
		// Flip x-axis
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
	if(o ==  UIImageOrientationLeft || o ==  UIImageOrientationDown || o == UIImageOrientationRightMirrored || o == UIImageOrientationDownMirrored)
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
	UIImage* newImage = [[UIImage alloc] initWithCGImage:newImageRef];
	CGImageRelease(newImageRef);	
	CGContextRelease(imageContextRef);
	free(buffer);
	
	return newImage;
}


// ----------------------------------------------------------


@implementation FilterImage

+(ffRenderArguments)randomImgParameters//:(ffRenderArguments &)renderArg
{
    ffRenderArguments renderArg;
    //cornerSoft
    renderArg.cornerOpacity =  (arc4random() % 901) / 1000.0f + 0.1f;
    
    //diffusion
    renderArg.difOpacity = (arc4random() % 701) / 1000.0f + 0.1f;
    //circleVignette
    renderArg.cvOpacity = (arc4random() % 701) / 1000.0f + 0.3f;
    //sqrVignette
    renderArg.SqrOpacity = (arc4random() % 801) / 1000.0f + 0.1f;
    renderArg.sqrScaleX = (arc4random() % 1001) / 1000.0f;
    renderArg.sqrScaleY = (arc4random() % 1001) / 1000.0f;
    //leakTint
    renderArg.leakTintRGB.r = (arc4random() % 201)/1000.0f+0.8f;
    renderArg.leakTintRGB.g = (arc4random() % 301)/1000.0f+0.3f;
    renderArg.leakTintRGB.b = (arc4random() % 301)/1000.0f;
    //leak offset
    renderArg.opacity3D.opacity1 = (arc4random() % 1001)/1000.0f;
    renderArg.opacity3D.opacity2 = (arc4random() % 801)/1000.0f;
    renderArg.opacity3D.opacity3 = (arc4random() % 501)/1000.0f;
    
    renderArg.startY1 = (arc4random() % 1001)/1000.0f;
    renderArg.startY2 = (arc4random() % 1001)/1000.0f;
    renderArg.startY3 = (arc4random() % 1001)/1000.0f;
    //colorClip
    renderArg.CCExpose = ((arc4random() % 601)/1000.0f) - 0.25f;
    //r
    renderArg.CCRGBMaxMin.rMin = ((arc4random() % 1001)/1000.0f) * 0.3f;
    renderArg.CCRGBMaxMin.rMax = ((arc4random() % 1001)/1000.0f) * 0.25f + 0.75f - renderArg.CCExpose;
    //g
    renderArg.CCRGBMaxMin.gMin = ((arc4random() % 1001)/1000.0f) * 0.1f;
    renderArg.CCRGBMaxMin.gMax = ((arc4random() % 1001)/1000.0f) * 0.2f + 0.8f - renderArg.CCExpose;
    //b
    renderArg.CCRGBMaxMin.bMin = 0.0f;
    renderArg.CCRGBMaxMin.bMax = 1.0f - renderArg.CCExpose;
    
    //monoChrome
    renderArg.rgbValue.r = ((arc4random() % 1001)/1000.0f) * 0.5f + 0.5f;
    renderArg.rgbValue.g = ((arc4random() % 1001)/1000.0f) * 0.5f + 0.5f;
    renderArg.rgbValue.b = ((arc4random() % 1001)/1000.0f) * 0.45f + 0.05f;
    //desat
    renderArg.blendrand = ((arc4random() % 1001)/1000.0f) * 0.65f + 0.05f;
    renderArg.randNum = arc4random() % 100;
    //border
    renderArg.randX = (arc4random() % 2) * 1.0f;
    renderArg.randY = (arc4random() % 2) * 1.0f;
    renderArg.randBorderScale = (arc4random() % 301) / 1000.0f + 1.0f;
    renderArg.randBorderDoScale = (arc4random() % 2) * 1.0f;
    
    // new boder random numbers
    renderArg.borderType = (arc4random() % 4);
    renderArg.borderLeft = (arc4random() % 10);
    renderArg.borderTop = (arc4random() % 10);
    renderArg.borderRight = (arc4random() % 10);
    renderArg.borderBottom = (arc4random() % 10);
    
    //sCurve
    renderArg.contrast = ((arc4random() % 1501)/1000.0f) + 1.1f;
    //colorFade
    //r
    renderArg.colorFadeRGB.rMin = ((arc4random() % 1001)/1000.0f) * 0.1f;
    renderArg.colorFadeRGB.rMax = ((arc4random() % 1001)/1000.0f) * 0.3f + 0.7f;
    //g
    renderArg.colorFadeRGB.gMin = ((arc4random() % 1001)/1000.0f) * 0.1f;
    renderArg.colorFadeRGB.gMax = ((arc4random() % 1001)/1000.0f) * 0.3f + 0.7f;
    //b
    renderArg.colorFadeRGB.bMin = ((arc4random() % 1001)/1000.0f) * 0.1f;
    renderArg.colorFadeRGB.bMax = ((arc4random() % 1001)/1000.0f) * 0.3f + 0.7f;
    
    double dinge = renderArg.colorFadeRGB.rMax;
    if (dinge < renderArg.colorFadeRGB.gMax)
        dinge = renderArg.colorFadeRGB.gMax;
        if (dinge < renderArg.colorFadeRGB.bMax)
            dinge = renderArg.colorFadeRGB.bMax;
            dinge = 1.0f - dinge;
            renderArg.colorFadeRGB.rMax += dinge;
            renderArg.colorFadeRGB.gMax += dinge;
            renderArg.colorFadeRGB.bMax += dinge;
            
            return renderArg;
}

@end


