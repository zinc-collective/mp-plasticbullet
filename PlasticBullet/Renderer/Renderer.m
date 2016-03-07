//
//  renderer.m
//  PlasticBullet
//
//  Created by Guno on 11-3-3.
//  Copyright 2010 RedSafi LLC. All rights reserved.
//

//#import "ImageProcessSlow.h"
#import "Renderer.h"
#import "ImageProcess.h"
#import "DataTypeDef.h"
#import "DataFile.h"
#import "pb_render.h"
#import "fastBlur.h"
#import "Utilities.h"
#import "fileOutput.h"
#import <math.h>
#define MAX_RENDER_TILE (1000000)

@implementation Renderer

//+(UIImage *)borderFlip:(UIImage *)_image  randomX:(double)_x randomY:(double)_y
//{
//	CGSize size = _image.size;
//	
//	int width = size.width;
//	int height = size.height;
//	
//	
//	int rowbytes = width*4;	
//	unsigned char *buffer = (unsigned char*)malloc( height * rowbytes );
//	if(buffer == nil) 
//		return nil;
//	CGContextRef context = CGBitmapContextCreate(buffer, 
//												 width, 
//												 height, 
//												 8, 
//												 rowbytes, 
//												 CGColorSpaceCreateDeviceRGB(), 
//												 kCGImageAlphaPremultipliedLast
//												 );
//	//Flip the X and Y axis
//	//
//	CGAffineTransform transform = CGAffineTransformIdentity;
//	if(_x>0.5f)
//	{
//		transform = CGAffineTransformScale(transform,-1,1);
//		transform = CGAffineTransformTranslate(transform, -size.width, 0);
//	}
//	if(_y>0.5f)
//	{
//		transform = CGAffineTransformScale(transform,1,-1);
//		transform = CGAffineTransformTranslate(transform, 0.0f, -size.height);
//	}
//	
//	
//	CGContextConcatCTM(context, transform);
//	CGContextDrawImage(context, CGRectMake(0.0, 0.0, size.width, size.height), _image.CGImage);
//	CGImageRef newImageRef = CGBitmapContextCreateImage(context);
//	// get the UIImage back	
//	UIImage* newImage = [[UIImage alloc] initWithCGImage:newImageRef];
//	CGImageRelease(newImageRef);	
//	CGContextRelease(context);
//	free(buffer);
//	return newImage;
//}
//
//#pragma mark border treatment
//+(UIImage *)borderTreatment:(UIImage *)_image  randomX:(double)_x randomY:(double)_y randomBorderScale:(double)_scale randomBorderDoScale:(double)_doScale
//{
//	UIImage *newImage = [self borderFlip:_image  randomX:_x randomY:_y];
//
//	if (_doScale < 0.5f)
//	{
//		return newImage;
//	}
//
//	//Scale the border and cut to size
//	//Ensure the scale is propotionally scale the border to maintain same border spacing
//	//
//	CGSize _size = _image.size;
//	int width = _size.width;
//	int height = _size.height;
//	int newWidth;
//	int newHeight;
//
//	if (width < height)
//	{
//		newWidth = width * _scale;
//		newHeight = height * ((_scale-1.0f)*width/height + 1.0f);
//	}
//	else 
//	{
//		newWidth = width * ((_scale-1.0f)*height/width + 1.0f);
//		newHeight = height * _scale;
//	}
//
//	UIImage *tempBorderImg = [ImageProcess imageNewWithImage:newImage scaledToSize:CGSizeMake(newWidth,newHeight)];
//	[newImage release];
//	newImage = tempBorderImg;
//	
//	if (tempBorderImg)
//	{		
//		int startX = (newWidth - width)>>1;
//		CGImageRef tempRef = CGImageCreateWithImageInRect(tempBorderImg.CGImage, CGRectMake(startX, startX, width, height));
//		[tempBorderImg release];
//		UIImage *borderImg = [[UIImage alloc]initWithCGImage:tempRef];
//		CGImageRelease(tempRef);
//		newImage = borderImg;
//	}
//	return newImage;
//}
//
//+(BOOL) prepareBorderImg:(UIImage *)_bordImg 
//						 width:(int)_width
//					   height:(int)_height
//					  randomX:(double)randX 
//					  randomY:(double)randY 
//			randomBorderScale:(double)randBorderScale 
//		  randomBorderDoScale:(double)randBorderDoScale
//{
//	UIImage *borderTempImg = nil;
//	if (!_bordImg)
//	{
//		if (_width>_height)
//		{
//			if (_width>3000)
//			{
//#ifdef _IMAGE_FAST_LOAD_
//				borderTempImg = [[UIImage imageNamed:PROCESS_BORDER_LANDSCAPE_4K]retain];
//#else
//				borderTempImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:PROCESS_BORDER_LANDSCAPE_4K_WITHOUT_EXT ofType:@"png"]];
//#endif
//			}
//			else if (_width>1600)
//			{
//#ifdef _IMAGE_FAST_LOAD_
//				borderTempImg = [[UIImage imageNamed:PROCESS_BORDER_LANDSCAPE_2K]retain];
//#else
//				borderTempImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:PROCESS_BORDER_LANDSCAPE_2K_WITHOUT_EXT ofType:@"png"]];
//#endif
//			}
//			else if (_width>1000)
//			{
//#ifdef _IMAGE_FAST_LOAD_
//				borderTempImg = [[UIImage imageNamed:PROCESS_BORDER_LANDSCAPE_1K]retain];
//#else
//				borderTempImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:PROCESS_BORDER_LANDSCAPE_1K_WITHOUT_EXT ofType:@"png"]];
//#endif
//			}
//			else 
//			{
//				borderTempImg = [[UIImage imageNamed:PROCESS_BORDER_LANDSCAPE]retain];
//			}
//		}
//		else
//		{
//			if (_height>3000)
//			{
//#ifdef _IMAGE_FAST_LOAD_
//				borderTempImg = [[UIImage imageNamed:PROCESS_BORDER_4K]retain];
//#else
//				borderTempImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:PROCESS_BORDER_4K_WITHOUT_EXT ofType:@"png"]];
//#endif
//			}
//			else if (_height>1600)
//			{
//#ifdef _IMAGE_FAST_LOAD_
//				borderTempImg = [[UIImage imageNamed:PROCESS_BORDER_2K]retain];
//#else
//				borderTempImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:PROCESS_BORDER_2K_WITHOUT_EXT ofType:@"png"]];
//#endif
//			}
//			else if (_height>1000)
//			{
//#ifdef _IMAGE_FAST_LOAD_
//				borderTempImg = [[UIImage imageNamed:PROCESS_BORDER_1K]retain];
//#else
//				borderTempImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:PROCESS_BORDER_1K_WITHOUT_EXT ofType:@"png"]];
//#endif
//			}
//			else 
//			{
//				borderTempImg = [[UIImage imageNamed:PROCESS_BORDER]retain];
//			}
//		}
//	}
//	else {
//		borderTempImg = [[UIImage alloc]initWithCGImage:_bordImg.CGImage];
//	}
//	
//	// Flip the border based on random number
//	//
//	UIImage *borderTempImg2 = [Renderer borderTreatment:borderTempImg randomX:randX randomY:randY randomBorderScale:randBorderScale randomBorderDoScale:randBorderDoScale];
//	[borderTempImg release];
//	
//	// Scale to fit the target resolution
//	//
//	UIImage *borderImg = [ImageProcess imageNewWithImage:borderTempImg2 scaledToSize:CGSizeMake(_width, _height)];
//	[borderTempImg2 release];
//	
//	if (!borderImg)
//		return FALSE;
//	else if ( [Utilities cacheToRawDataFromImage:borderImg filename:TMP_BORDER_FILE_NAME] )
//	{
//		[borderImg release];
//		return TRUE;
//	}	
//	return FALSE;
//}
//
-(BOOL) prepareSoftBlurImage:(UIImage *)_sourceImg softImage:(UIImage *)_softImg width:(int)_width height:(int)_height hiRes:(bool)_hiRes

{
	bool useLowMemMethod = !_sourceImg;
	
	
#if NO_TILE_RENDER_SUPPORT
#else
	_softImg = nil;
#endif
	
	unsigned char* softImgBuffer;
	UIImage* softImg;
	if (!_softImg || ((_width>320) && (_height>320)) )
	{
		// Recalculate the soft image for the final rendering quality
		//
		if (useLowMemMethod)
		{
			//NSLog(@"blur step1");
			[Utilities printDateTime];
			softImgBuffer = [self blurImgFile:RENDER_SOURCE_FILE_NAME width:_width height:_height startProgress:0.05 progressDuration:0.1 hiRes:_hiRes];

			if (!softImgBuffer) {
				return FALSE;
			}
			
			//NSLog(@"blur cache");
			[Utilities printDateTime];
			if ( [Utilities cacheToRawDataFromImageBuffer:(char*)softImgBuffer length:(_width*_height*4) filename:TMP_SOFTIMAGE_FILE_NAME] )
			{
				free(softImgBuffer);
				
				//NSLog(@"blur step2");
				[Utilities printDateTime];
				softImgBuffer = [self blurImgFile:TMP_SOFTIMAGE_FILE_NAME width:_width height:_height startProgress:0.15 progressDuration:0.1 hiRes:_hiRes];

				if (!softImgBuffer) {
					return FALSE;
				}
				
				//NSLog(@"blur cache");
				[Utilities printDateTime];
				if ( [Utilities cacheToRawDataFromImageBuffer:(char*)softImgBuffer length:(_width*_height*4) filename:TMP_SOFTIMAGE_FILE_NAME] )
				{					
					free(softImgBuffer);
					return TRUE;
				}
				[Utilities printDateTime];
			}
			free(softImgBuffer);
			return FALSE;			
		}
		else {
			softImg = [self blurImg:_sourceImg];
			UIImage *softImg2 = [self blurImg:softImg];
			if ( softImg2 )
			{
//				[softImg release];
				softImg = softImg2;
			}
		}
	}
	else
	{
		// Use Tmp soft image.  No need to recalculate
		//
		softImg = [ImageProcess imageNewWithImage:_softImg scaledToSize:CGSizeMake(_width, _height)];
	}
	
	if (!softImg)
		return FALSE;
	else
	{
//		[softImg release];
		return TRUE;
	}	
}

#define BORDER_LENGTH (2000)
#define BORDER_HEIGHT (300)
#define BORDER_LEFT   0
#define BORDER_TOP    1
#define BORDER_RIGHT  2
#define BORDER_BOTTOM 3


-(BOOL) multiplyBorder:(NSString*)path
			  longside:(int)_longside
			 shortside:(int)_shortside
			borderSide:(int)_borderSide
		  borderBuffer:(unsigned char*) poutb
		  buffer_width:(int)_width
		 buffer_height:(int)_height
	 randomBorderScale:(double)randBorderScale
{
	// Do the top
	//
    UIImage *borderSideImg = [UIImage imageNamed:path];
	if (!borderSideImg) {
		return FALSE;
	}
	
	// Deal with scale offset
	//
	int longSideScaled = _longside * randBorderScale;			// border side width after scale up
	int shortSideScaled = _shortside * randBorderScale;			// border side height after scale up
	int shortOffset = (shortSideScaled - _shortside) >> 1;		// offset for the border height to use
	int longOffset = shortOffset;								// offset for the border width to use
	int longBorderOverlap = longSideScaled - longOffset;		// actual side width used in compositing
	int shortBorderOverlap = shortSideScaled - shortOffset;		// actual side height used in compositing
	
	UIImage* borderScaleImg = [ImageProcess imageNewWithImage:borderSideImg scaledToSize:CGSizeMake(longSideScaled,shortSideScaled)];
//	[borderSideImg release];
	if (!borderScaleImg) {
		return FALSE;
	}

	// get the buffer and multiply to output buffer
	//
	CFDataRef borderdata = CGDataProviderCopyData(CGImageGetDataProvider(borderScaleImg.CGImage));
	int *m_borderdata = (int *)CFDataGetBytePtr(borderdata);
	unsigned char* pBorderb = (unsigned char *)&m_borderdata[0];

	int outHeightStart = 0, outHeightEnd = 0, outWidthStart = 0, outWidthEnd = 0, inStartX = 0, inStartStepX = 0, inStartStepY = 0;
	switch (_borderSide) {
		case BORDER_LEFT:
			outHeightStart = 0;
			outHeightEnd = _height;
			outWidthStart = 0;
			outWidthEnd = shortBorderOverlap;
			
			inStartX = ((shortBorderOverlap - 1) * longSideScaled + longOffset)* 4;
			inStartStepX = -(longSideScaled*4);
			inStartStepY = 4;
			break;
		case BORDER_TOP:
			outHeightStart = 0;
			outHeightEnd = shortBorderOverlap;
			outWidthStart = 0;
			outWidthEnd = _width;

			inStartX = ((shortSideScaled - shortOffset) * longSideScaled - (longBorderOverlap - _width)  - 1) * 4;
			inStartStepX = -4;
			inStartStepY = -(longSideScaled * 4);
			break;
		case BORDER_RIGHT:
			outHeightStart = 0;
			outHeightEnd = _height;
			outWidthStart = _width - shortBorderOverlap;
			outWidthEnd = _width;
			
			inStartX = (_height + longOffset - 1) * 4;
			inStartStepX = (longSideScaled*4);
			inStartStepY = -4;
			break;
		case BORDER_BOTTOM:
			outHeightStart = _height - shortBorderOverlap;
			outHeightEnd = _height;
			outWidthStart = 0;
			outWidthEnd = _width;

			inStartX = (longOffset) * 4;
			inStartStepX = 4;
			inStartStepY = longSideScaled * 4;
			break;
		default:
			break;
	}
	
	int val;
	unsigned char bVal;
	unsigned char *pout;
	unsigned char *pBorder;
	int yCount = 0;
	for (int y=outHeightStart; y<outHeightEnd; y++)
	{
		pBorder = pBorderb + (inStartX + inStartStepY * yCount);
		pout = poutb + (y*_width+outWidthStart)*4;
		for (int x=outWidthStart; x<outWidthEnd; x++)
		{
			bVal = (unsigned char) *pBorder;
			val = *pout;
			val *= bVal;
			*pout++ = (unsigned char) (val / 255);
			*pout++ = (unsigned char) (val / 255);
			*pout++ = (unsigned char) (val / 255);
			*pout++ = 255;
			pBorder += inStartStepX;
		}
		yCount++;
	}
	CFRelease(borderdata);

	return TRUE;
}

-(BOOL) prepareBorderType:(int)_borderType
					width:(int)_width
				   height:(int)_height
			   borderLeft:(int)_borderLeft
				borderTop:(int)_borderTop
			  borderRight:(int)_borderRight
			 borderBottom:(int)_borderBottom
		randomBorderScale:(double)randBorderScale
					hiRes:(bool)_hiRes
			  isLandscape:(bool)_isLandscape
{
	int rowBytes = _width * 4;
	int buffer_len = _height * rowBytes;
	unsigned char* pout = (unsigned char*) malloc(buffer_len);
	unsigned char* poutb = pout;
	if (!pout)
		return FALSE;
	
	// Reset the output buffer
	//
	for (int y=0; y<_height; y++) {
		for (int x=0; x<_width; x++) {
			*pout++ = 255;
			*pout++ = 255;
			*pout++ = 255;
			*pout++ = 255;
		}
	}
	
	// Decide which border type to use
	//
	BOOL hasBorder = TRUE;
	BOOL useSmallBorder = _isLandscape ? _width<=480 : _height<=480;		
	BOOL useMidSizeBorder = _isLandscape ? _width<=960 : _height<=960;		
	NSString *filename;	
	switch (_borderType) {
		case 0:
			filename = _hiRes? FLEXBORDER_TYPE_BP1_NAME_2K :
						(useSmallBorder? FLEXBORDER_TYPE_BP1_NAME_SMALL : (useMidSizeBorder ? FLEXBORDER_TYPE_BP1_NAME_MID : FLEXBORDER_TYPE_BP1_NAME_2K));
			break;
		case 1:
			filename = _hiRes? FLEXBORDER_TYPE_SMOOTH_NAME_2K :
						(useSmallBorder? FLEXBORDER_TYPE_SMOOTH_NAME_SMALL : (useMidSizeBorder ? FLEXBORDER_TYPE_SMOOTH_NAME_MID : FLEXBORDER_TYPE_SMOOTH_NAME_2K));
			break;
		case 2:
			filename = _hiRes? FLEXBORDER_TYPE_SOFT_NAME_2K :
						(useSmallBorder? FLEXBORDER_TYPE_SOFT_NAME_SMALL : (useMidSizeBorder ? FLEXBORDER_TYPE_SOFT_NAME_MID : FLEXBORDER_TYPE_SOFT_NAME_2K));
			break;
		default:
			// No border
			hasBorder = FALSE;	
			break;
	}
	
	if (hasBorder)
	{
		// determine the scale factor for border
		//
		double scale;
		int _longside, _shortside;
		if (_isLandscape)
		{
			scale = 1.0 * _width / BORDER_LENGTH;
		}
		else
		{
			scale = 1.0 * _height / BORDER_LENGTH;
		}
		
		_longside = (int)(BORDER_LENGTH * scale);
		_shortside = (int)(BORDER_HEIGHT * scale);
		
		// Do the top
		//
		if (![self multiplyBorder:[filename stringByAppendingFormat:@"%d.png",_borderTop] 
						 longside:_longside 
						shortside:_shortside 
					   borderSide:BORDER_TOP 
					 borderBuffer:poutb 
					 buffer_width:_width 
					buffer_height:_height 
				randomBorderScale:randBorderScale])
		{
			free(poutb);
			return FALSE;
		}

		if(_hiRes){
			if ([self progressUpdate:0.01])
			{
				free(poutb);
				return FALSE;
			}
		}
		
		// Do the Left
		//
		if (![self multiplyBorder:[filename stringByAppendingFormat:@"%d.png",_borderLeft] 
						 longside:_longside 
						shortside:_shortside 
					   borderSide:BORDER_LEFT
					 borderBuffer:poutb 
					 buffer_width:_width 
					buffer_height:_height 
				randomBorderScale:randBorderScale])
		{
			free(poutb);
			return FALSE;
		}

		if(_hiRes){
			if ([self progressUpdate:0.02])
			{
				free(poutb);
				return FALSE;
			}
		}
		
		// Do the bottom
		//
		if (![self multiplyBorder:[filename stringByAppendingFormat:@"%d.png",_borderBottom] 
						 longside:_longside 
						shortside:_shortside 
					   borderSide:BORDER_BOTTOM 
					 borderBuffer:poutb 
					 buffer_width:_width 
					buffer_height:_height 
				randomBorderScale:randBorderScale])
		{
			free(poutb);
			return FALSE;
		}
		
		if(_hiRes){
			if ([self progressUpdate:0.03])
			{
				free(poutb);
				return FALSE;
			}
		}
		
		// Do the right
		//
		if (![self multiplyBorder:[filename stringByAppendingFormat:@"%d.png",_borderRight] 
						 longside:_longside 
						shortside:_shortside 
					   borderSide:BORDER_RIGHT
					 borderBuffer:poutb 
					 buffer_width:_width 
					buffer_height:_height 
				randomBorderScale:randBorderScale])
		{
			free(poutb);
			return FALSE;
		}
	}

	if(_hiRes){
		if ([self progressUpdate:0.04])
		{
			free(poutb);
			return FALSE;
		}
	}
	
	
	if ([Utilities cacheToRawDataFromImageBuffer:(char*)poutb length:buffer_len filename:TMP_BORDER_FILE_NAME])
	{
		free(poutb);
		return TRUE;
	}
	free(poutb);
	return FALSE;	
}

//+(UIImage *) prepareCircleVignetteImage:(UIImage *)_cvVigArt 
//								  width:(int)_width 
//								 height:(int)_height
//{
//	// Since the vignette is symmetrical, we just need to prepare a quarter of it.  Could optimize by dealing with single channel image instead of 4 channels
//	//   but remember to change the renderer to deal with only one channel.
//	//
//	int cvTempWidth = _width/2.0f + 0.5f;
//	int cvTempHeight = _height/2.0f + 0.5f;
//	UIImage *cvTempVigArtImg = nil;
//	if (!_cvVigArt)
//	{
//		if (_width > _height)
//		{
//			if (_width>1600)
//			{
//#ifdef _IMAGE_FAST_LOAD_
//				cvTempVigArtImg = [ImageProcess imageNewWithImage:[UIImage imageNamed:PROCESS_VIGART_LANDSCAPE_2K] scaledToSize:CGSizeMake(cvTempWidth,cvTempHeight)];
//#else
//				UIImage *tempImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:PROCESS_VIGART_LANDSCAPE_2K_WITHOUT_EXT ofType:@"png"]];
//				cvTempVigArtImg = [ImageProcess imageNewWithImage:tempImage scaledToSize:CGSizeMake(cvTempWidth,cvTempHeight)];
//				[tempImage release];
//#endif
//				
//			}
//			else if (_width>1000)
//			{
//#ifdef _IMAGE_FAST_LOAD_
//				cvTempVigArtImg = [ImageProcess imageNewWithImage:[UIImage imageNamed:PROCESS_VIGART_LANDSCAPE_1K] scaledToSize:CGSizeMake(cvTempWidth,cvTempHeight)];
//#else
//				UIImage *tempImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:PROCESS_VIGART_LANDSCAPE_1K_WITHOUT_EXT ofType:@"png"]];
//				cvTempVigArtImg = [ImageProcess imageNewWithImage:tempImage scaledToSize:CGSizeMake(cvTempWidth,cvTempHeight)];
//				[tempImage release];
//#endif
//			}
//			else 
//			{
//				cvTempVigArtImg = [ImageProcess imageNewWithImage:[UIImage imageNamed:PROCESS_VIGART_LANDSCAPE] scaledToSize:CGSizeMake(cvTempWidth,cvTempHeight)];
//			}
//			
//		}
//		else {
//			if (_height>1600)
//			{
//#ifdef _IMAGE_FAST_LOAD_
//				cvTempVigArtImg = [ImageProcess imageNewWithImage:[UIImage imageNamed:PROCESS_VIGART_2K] scaledToSize:CGSizeMake(cvTempWidth,cvTempHeight)];
//#else
//				UIImage *tempImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:PROCESS_VIGART_2K_WITHOUT_EXT ofType:@"png"]];
//				cvTempVigArtImg = [ImageProcess imageNewWithImage:tempImage scaledToSize:CGSizeMake(cvTempWidth,cvTempHeight)];
//				[tempImage release];	
//#endif
//				
//			}
//			else if (_height>1000)
//			{
//#ifdef _IMAGE_FAST_LOAD_
//				cvTempVigArtImg = [ImageProcess imageNewWithImage:[UIImage imageNamed:PROCESS_VIGART_1K] scaledToSize:CGSizeMake(cvTempWidth,cvTempHeight)];
//#else
//				UIImage *tempImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:PROCESS_VIGART_1K_WITHOUT_EXT ofType:@"png"]];
//				cvTempVigArtImg = [ImageProcess imageNewWithImage:tempImage scaledToSize:CGSizeMake(cvTempWidth,cvTempHeight)];
//				[tempImage release];
//#endif
//			}
//			else 
//			{
//				cvTempVigArtImg = [ImageProcess imageNewWithImage:[UIImage imageNamed:PROCESS_VIGART] scaledToSize:CGSizeMake(cvTempWidth,cvTempHeight)];
//			}
//		}
//		
//	}
//	else {
//		cvTempVigArtImg = [ImageProcess imageNewWithImage:_cvVigArt scaledToSize:CGSizeMake(cvTempWidth,cvTempHeight)];
//	}
//	return cvTempVigArtImg;
//}

//{
//	if (_width > _height)
//	{
//		target_short  1.125f * _height;
//		cvTempVigArtImg = [ImageProcess imageNewWithImage:[UIImage imageNamed:PROCESS_VIGART_1K] scaledToSize:CGSizeMake(cvTempWidth,cvTempHeight)];
//	}
	//scale side to short side first

	
	//Get the new dimension
	
	//Scale the body to the ratio 
	
	//Draw top then body then bottom
	
	
//}

//+(UIImage *) prepareSquareVignetteImage:(UIImage *)_sqrVigArt 
//								  width:(int)_width
//								 height:(int)_height
//							  sqrScaleX:(double)_sqrX 
//							  sqrScaleY:(double)_sqrY 
//{
//	// Expand sqrVigArt
//	//
//	UIImage *sqrTempVigArt = nil;
//	if (!_sqrVigArt)
//	{
//		if (_width>_height)
//		{
//			if (_width>1600)
//			{
//#ifdef _IMAGE_FAST_LOAD_
//				sqrTempVigArt = [[UIImage imageNamed:PROCESS_SQRVIG_LANDSCAPE_2K]retain];
//#else
//				sqrTempVigArt = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:PROCESS_SQRVIG_LANDSCAPE_2K_WITHOUT_EXT ofType:@"png"]];
//#endif
//				
//			}
//			else if (_width>1000)
//			{
//#ifdef _IMAGE_FAST_LOAD_
//				sqrTempVigArt = [[UIImage imageNamed:PROCESS_SQRVIG_LANDSCAPE_1K]retain];
//#else
//				sqrTempVigArt = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:PROCESS_SQRVIG_LANDSCAPE_1K_WITHOUT_EXT ofType:@"png"]];
//#endif
//			}
//			else 
//			{
//#ifdef _IMAGE_FAST_LOAD_
//				sqrTempVigArt = [[UIImage imageNamed:PROCESS_SQRVIG_LANDSCAPE]retain];
//#else
//				sqrTempVigArt = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:PROCESS_SQRVIG_LANDSCAPE_WITHOUT_EXT ofType:@"png"]];
//#endif
//			}
//			
//		}
//		else 
//		{
//			if (_height>1600)
//			{
//#ifdef _IMAGE_FAST_LOAD_
//				sqrTempVigArt = [[UIImage imageNamed:PROCESS_SQRVIG_2K]retain];
//#else
//				sqrTempVigArt = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:PROCESS_SQRVIG_2K_WITHOUT_EXT ofType:@"png"]];
//#endif
//			}
//			else if (_height>1000)
//			{
//#ifdef _IMAGE_FAST_LOAD_
//				sqrTempVigArt = [[UIImage imageNamed:PROCESS_SQRVIG_1K]retain];
//#else
//				sqrTempVigArt = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:PROCESS_SQRVIG_1K_WITHOUT_EXT ofType:@"png"]];
//#endif
//			}
//			else 
//			{
//#ifdef _IMAGE_FAST_LOAD_
//				sqrTempVigArt = [[UIImage imageNamed:PROCESS_SQRVIG]retain];
//#else
//				sqrTempVigArt = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:PROCESS_SQRVIG_WITHOUT_EXT ofType:@"png"]];
//#endif
//			}
//		}
//	}
//	else {
//		sqrTempVigArt = _sqrVigArt;
//	}
//	
//	// sqrVigArt Preparation: Expand the Art for random offset calculation
//	//
//	int sqrVigWidth = CGImageGetWidth(sqrTempVigArt.CGImage);
//	int sqrVigHeight = CGImageGetHeight(sqrTempVigArt.CGImage);
//	double factor = 1.125f;
//	double scale = (_width>_height? (factor * _width / sqrVigWidth): (factor * _height / sqrVigHeight) );
//	int newWidth = scale*sqrVigWidth;
//	int newHeight = scale*sqrVigHeight;	
//	
//	UIImage *sqrTempVigArtImg = [ImageProcess imageNewWithImage:sqrTempVigArt scaledToSize:CGSizeMake(newWidth,newHeight)];
//	if (!_sqrVigArt)
//	{
//		[sqrTempVigArt release];
//	}	
//	
//	int sqrStartX = (CGImageGetWidth(sqrTempVigArtImg.CGImage) - _width) * _sqrX;
//	int sqrStartY = (CGImageGetHeight(sqrTempVigArtImg.CGImage) - _height) * _sqrY;
//	
//	// Find the offset from expanded sqrVigArt
//	//
//	CGImageRef tempRef = CGImageCreateWithImageInRect(sqrTempVigArtImg.CGImage, CGRectMake(sqrStartX, sqrStartY, _width, _height));
//	[sqrTempVigArtImg release];
//	UIImage *sqrVigArtImg1 = [[UIImage alloc]initWithCGImage:tempRef];
//	CGImageRelease(tempRef);
//	UIImage *sqrVigArtImg = [ImageProcess imageNewWithImage:sqrVigArtImg1 scaledToSize:CGSizeMake(_width, _height)];
//	[sqrVigArtImg1 release];
//	
//	// Smooth out the banding artifact
//	//
//	if ( scale >= 2.0f )
//	{
//		UIImage *tmpVig2 = [Renderer blurImg:sqrVigArtImg];
//		if (tmpVig2)
//		{
//			[sqrVigArtImg release];
//			sqrVigArtImg = tmpVig2;
//		}	
//	}
//
//	return sqrVigArtImg;
//}
//
#pragma mark Leak
static CGBitmapInfo generic_bitmapInfo;
-(UIImage *)leakWithImage:(UIImage *)_sourceImage leakArtWidth:(int)leakWidth leakArtHeight:(int)leakHeight landscape:(int)isLandscape aspectRatio:(float)ratio RGB:(ffColor3D)_leakRgb OpacityValue:(ffOpacity3D)_leakopacity3d randStartYIndex1:(float)startIndex1 randStartYIndex2:(float)startIndex2 randStartYIndex3:(float)startIndex3
{
	int width = leakWidth;
	int height = width*ratio;
	int maxOffset = leakHeight - height;
	int leakStartY1 = maxOffset * startIndex1;
	int leakStartY2 = maxOffset * startIndex2;
	int leakStartY3 = maxOffset * startIndex3;
	
	int tile_height = height;
	
	uint8_t *pout, *poutb;
	int rowbytes = width * 4;
	int length = height * rowbytes;
	
	// output buffer
	pout = poutb = (uint8_t *)malloc(length); 
	if(!pout)
		return 0;
	
	
#if NO_TILE_RENDER_SUPPORT
	CFDataRef sourcedata = CGDataProviderCopyData(CGImageGetDataProvider(_sourceImage.CGImage));
	int *m_sourcedata = (int *)CFDataGetBytePtr(sourcedata);
	
	//CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(_sourceImage.CGImage);
	
	uint8_t *lppb1 = (unsigned char *)&m_sourcedata[leakStartY1 * width];
	uint8_t *lppb2 = (unsigned char *)&m_sourcedata[leakStartY2 * width];
	uint8_t *lppb3 = (unsigned char *)&m_sourcedata[leakStartY3 * width];
#else	
	NSString *path = [Utilities documentsPath:LEAK_FILE_NAME];
		
	// Define tile size
	if (length > MAX_RENDER_TILE)
	{
		tile_height = MAX_RENDER_TILE / rowbytes;
		length = tile_height * rowbytes;
	}
	
	uint8_t *lppb1 =  (unsigned char *)malloc(length);
	uint8_t *lppb1p = lppb1;
	uint8_t *lppb2 =  (unsigned char *)malloc(length);
	uint8_t *lppb2p = lppb2;
	uint8_t *lppb3 =  (unsigned char *)malloc(length);
	uint8_t *lppb3p = lppb3;
#endif
	
	int x,y;
	int r,g,b;
	int h = 0;
	
#if NO_TILE_RENDER_SUPPORT
#else
	for (h=0; h<height; h+=tile_height)
	{
		// read the file - tile by tile
		//
		int yOffset = h * rowbytes;
		if ( (height - h) < tile_height )
		{
			tile_height = (height - h);
			length =  tile_height * rowbytes;
		}

		lppb1 = lppb1p;
		readFile((unsigned char*) lppb1, [path UTF8String], leakStartY1 * rowbytes + yOffset, length);
		lppb2 = lppb2p;
		readFile((unsigned char*) lppb2, [path UTF8String], leakStartY2 * rowbytes + yOffset, length);
		lppb3 = lppb3p;
		readFile((unsigned char*) lppb3, [path UTF8String], leakStartY3 * rowbytes + yOffset, length);
#endif
		
		for (y=0; y<tile_height; y++)
		{
			for(x=0;x<width;x++)
			{
				r = (lppb1[0]*_leakRgb.r*_leakopacity3d.opacity1)+(lppb2[0]*_leakRgb.r*_leakopacity3d.opacity2)+(lppb3[0]*_leakRgb.r*_leakopacity3d.opacity3);
				g = (lppb1[1]*_leakRgb.g*_leakopacity3d.opacity1)+(lppb2[1]*_leakRgb.g*_leakopacity3d.opacity2)+(lppb3[1]*_leakRgb.g*_leakopacity3d.opacity3);
				b = (lppb1[2]*_leakRgb.b*_leakopacity3d.opacity1)+(lppb2[2]*_leakRgb.b*_leakopacity3d.opacity2)+(lppb3[2]*_leakRgb.b*_leakopacity3d.opacity3);
				
				if(r>255) r = 255;
				if(g>255) g = 255;
				if(b>255) b = 255;
				
				lppb1 += 4;
				lppb2 += 4;
				lppb3 += 4;
				
				if (isLandscape)
				{
					pout = poutb + (x*height+y+h)*4;
				}
				
				*pout++ = (unsigned char)r;  
				*pout++ = (unsigned char)g;   
				*pout++ = (unsigned char)b;   
				*pout++ = (unsigned char)255;
			}
		}
		
#if NO_TILE_RENDER_SUPPORT
#else
	}	
	free(lppb1p);
	free(lppb2p);
	free(lppb3p);
#endif

	CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
	CGContextRef context;
	
	if (isLandscape)
	{
		context=CGBitmapContextCreate(poutb, height, width, 8, height*4, colorSpace, generic_bitmapInfo);//sizeof(uint32_t)
	}
	else
	{
		context=CGBitmapContextCreate(poutb, width, height, 8, width*4, colorSpace, generic_bitmapInfo);//sizeof(uint32_t)
	}
	
	CGImageRef image=CGBitmapContextCreateImage(context);
	
	
    free(poutb);
	
#if NO_TILE_RENDER_SUPPORT
	CFRelease(sourcedata);
#endif
	
	CGColorSpaceRelease(colorSpace);
	CGContextRelease(context);
	UIImage *newImage = [[UIImage alloc]initWithCGImage:image];
	CGImageRelease(image);
	return newImage;
}

#pragma mark leak rotate and scale 
//+(UIImage *)LeakRotateWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
//{
//	if(!image)
//		return NULL;
//	int width = newSize.width;
//	int height = newSize.height;
//	
//	int rowbytes = width*4;	
//	unsigned char *buffer = (unsigned char*)malloc( height * rowbytes );
//	if(buffer == nil) 
//		return NULL;
//	CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
//	//CGColorSpaceRelease(colorSpace);
//	CGContextRef imageContextRef = CGBitmapContextCreate(buffer, 
//														 width, 
//														 height, 
//														 8, 
//														 rowbytes, 
//														 colorSpace, 
//														 kCGImageAlphaPremultipliedLast
//														 );
//	
//	CGAffineTransform transform = CGAffineTransformIdentity;
//	transform = CGAffineTransformRotate(transform, -M_PI / 2.0f);
//	transform = CGAffineTransformTranslate(transform, -newSize.height, 0.0f);
//	newSize = CGSizeMake(newSize.height, newSize.width);
//	CGContextConcatCTM(imageContextRef, transform);
//	int tempK = width;
//	width = height;
//	height = tempK;
//	
//	CGContextDrawImage(imageContextRef, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), image.CGImage);
//	
//	// get the new CGImage
//	CGImageRef newImageRef = CGBitmapContextCreateImage(imageContextRef);
//	// get the UIImage back	
//	UIImage *newImage = [[UIImage alloc] initWithCGImage:newImageRef];
//	CGColorSpaceRelease(colorSpace);
//	CGContextRelease(imageContextRef);
//	CGImageRelease(newImageRef);	
//	free(buffer);
//	return newImage;
//}

#pragma mark Leak prepare
-(BOOL) prepareLeakImage:(UIImage *)_leakImg
						width:(int)_width 
					   height:(int)_height
						  RGB:(ffColor3D)_leakRgb 
				 OpacityValue:(ffOpacity3D)_leakopacity3d 
			 randStartYIndex1:(float)startIndex1 
			 randStartYIndex2:(float)startIndex2 
			 randStartYIndex3:(float)startIndex3
				   hiRes:(bool)_hiRes
			 isLandscape:(bool)_isLandscape
{
	UIImage *leakArt = nil;
	if (!_leakImg)
	{
		if ((_width>3000) || (_height>3000))
		{
            leakArt = [UIImage imageNamed:PROCESS_LEAK_6K];
		}
		else if ((_width>1200) || (_height>1200))
		{
            leakArt = [UIImage imageNamed:PROCESS_LEAK_2K];
		}
		else
		{
            leakArt = [UIImage imageNamed:PROCESS_LEAK_1K];
		}
	}
	else {
		leakArt = _leakImg;
	}
	
	// Prepare the leak art
	//
	int leakWidth = roundf(CGImageGetWidth(leakArt.CGImage));
	int leakHeight = roundf(CGImageGetHeight(leakArt.CGImage));
	//generic_bitmapInfo = CGImageGetBitmapInfo(leakArt.CGImage);
	
#if NO_TILE_RENDER_SUPPORT
	UIImage *leakImg = [ImageProcess imageNewWithImage:leakArt scaledToSize:CGSizeMake(leakWidth,leakHeight)];
	if (!_leakImg)
	{
		[leakArt release];
	}
#else
	if (![Utilities cacheToRawDataFromImage:leakArt filename:LEAK_FILE_NAME])
		return FALSE;
	UIImage *leakImg = nil;
#endif
	
	float ratio = _isLandscape ? (1.0 * _width / _height) : (1.0 * _height / _width);
	if (ratio > 5.0) ratio = 5.0;
	
	UIImage *leakImg1 = [self leakWithImage:leakImg leakArtWidth:leakWidth leakArtHeight:leakHeight landscape:(int)_isLandscape aspectRatio:ratio RGB:_leakRgb OpacityValue:_leakopacity3d randStartYIndex1:startIndex1 randStartYIndex2:startIndex2 randStartYIndex3:startIndex3];
	
	leakImg = [ImageProcess imageNewWithImage:leakImg1 scaledToSize:CGSizeMake(_width, _height)];
	
	if (!leakImg)
		return FALSE;
	else if ([Utilities cacheToRawDataFromImage:leakImg filename:TMP_LEAK_FILE_NAME])
	{
		return TRUE;
	}	
	return FALSE;
}

#pragma mark Prepare SoftImg
#define RADIUS 5 //5
-(unsigned char *)blurImgFile:(NSString*)filename width:(int)_width height:(int)_height startProgress:(float)_startProgress progressDuration:(float)_progressDuration hiRes:(bool)_hiRes
{
	int rowbytes = _width * 4;
	int buffer_length = rowbytes * _height;
	NSString *path = [Utilities documentsPath:filename];
	
	unsigned char* poutb = (unsigned char *)malloc(buffer_length);
	unsigned char* pout = poutb;
	if ( !poutb )
		return nil;
	
	// Define tile size
	int tile_height = _height;
	int tile_length = buffer_length;
	if (buffer_length > MAX_RENDER_TILE)
	{
		tile_height =  MAX_RENDER_TILE / rowbytes;
		if (tile_height <= 2*RADIUS )
		{
			// not big enough, cancel operation
			free(poutb);
			return nil;
		}
		tile_length = tile_height * rowbytes;
	}
	
	for (int h=0; h<_height; )
	{
		if (_height-h < tile_height)
		{
			tile_height = _height-h;
			tile_length = tile_height * rowbytes;
		}
		
		// Read source from disk
		//
		unsigned char *outbuffer =  (unsigned char *)malloc(tile_length);
		readFile(outbuffer, [path UTF8String], h*rowbytes, tile_length);
		
		// Blur the source
		unsigned char* pSrcb = fast_blur((unsigned char*)outbuffer, RADIUS, _width, tile_height);
		unsigned char* pSrc = pSrcb;
		free(outbuffer);
		if (!pSrcb)
		{
			free(poutb);
			return nil;
		}		

		if (_hiRes)
		{
			double degree = _startProgress + h * _progressDuration / _height;
			if ([self progressUpdate:degree])
			{
				free(pSrcb);
				free(poutb);
				return nil;
			}
		}
		
		// Determine the portion of tile that needs to be copied to the output buffer
		//
		int copyCount;		
		if (h + tile_height >= _height)
		{
			if ( h < RADIUS )
			{
				pout = poutb + rowbytes*h;
				pSrc = pSrcb;
				copyCount = rowbytes*(_height-h);
			}
			else
			{
				pout = poutb + rowbytes*(h+RADIUS);
				pSrc = pSrcb + rowbytes*RADIUS;
				copyCount = rowbytes*(_height-h-RADIUS);
			}
			h = _height;
		}
		else if (h<RADIUS)
		{
			pout = poutb;
			pSrc = pSrcb;
			copyCount = tile_height * rowbytes;
			h += (tile_height - 2*RADIUS);
		}
		else 
		{
			pout = poutb + rowbytes*(h+RADIUS);
			pSrc = pSrcb + rowbytes*RADIUS;
			copyCount = rowbytes*(tile_height-2*RADIUS);
			h += (tile_height - 2*RADIUS);
		}
		
		// Memory copy
		//
		for (int p=0; p<copyCount; p++)
		{
			*pout++ = *pSrc++;
		}
		
		free(pSrcb);
	}
	
	return poutb;
	
//	// Keep the blur image
//	//
//	CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
//	CGContextRef context=CGBitmapContextCreate(poutb, _width, _height, 8, _width*4, colorSpace, generic_bitmapInfo);	
//	CGImageRef imageRef=CGBitmapContextCreateImage(context);	
//    free(poutb);  
//
//	UIImage *softImg = [[UIImage alloc] initWithCGImage:imageRef];
//	CGContextRelease(context);
//	CGImageRelease(imageRef);
//	CGColorSpaceRelease(colorSpace);
//	
//	return softImg;
}

-(UIImage *)blurImg:(UIImage *)_image
{	
	int theWidth = roundf(CGImageGetWidth(_image.CGImage));
	int theHeight = roundf(CGImageGetHeight(_image.CGImage));
	CFDataRef theData = CGDataProviderCopyData(CGImageGetDataProvider(_image.CGImage));
	int *m_data = (int *)CFDataGetBytePtr(theData);

	unsigned char* poutb = fast_blur((unsigned char*) m_data, RADIUS, theWidth, theHeight);	
	CFRelease(theData);
	
	//Add by jack
	//Cache Soft image to Raw data
	

	// Keep the blur image
	//
	CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(_image.CGImage);
	CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
	CGContextRef context=CGBitmapContextCreate(poutb, theWidth, theHeight, 8, theWidth*4, colorSpace, bitmapInfo);	
	CGImageRef imageRef=CGBitmapContextCreateImage(context);	
    free(poutb);  
	UIImage *softImg = [[UIImage alloc] initWithCGImage:imageRef];
	CGContextRelease(context);
	CGImageRelease(imageRef);
	CGColorSpaceRelease(colorSpace);
	
	return softImg;
}	

#pragma mark Prepare SoftImg
-(BOOL)slowBlurImg:(UIImage *)_image;
{
	int theWidth = roundf(CGImageGetWidth(_image.CGImage));
	int theHeight = roundf(CGImageGetHeight(_image.CGImage));
	
	unsigned char *outbuffer =  (unsigned char *)malloc(theWidth * theHeight * 4);
	NSString *path = [Utilities documentsPath:ORIGINAL_IMAGE_FILE_NAME];
	readFile(outbuffer, [path UTF8String], 0, theWidth * theHeight * 4);
	
	unsigned char* poutb = fast_blur((unsigned char*)outbuffer, RADIUS, theWidth, theHeight);	
	free(outbuffer);
	
	size_t length = theWidth*theHeight*4;
	[Utilities cacheToRawDataFromImageBuffer:(char*)poutb length:length filename:SOFT_IMAGE_FILE_NAME];
	free(poutb);

	return YES;
}

-(int) progressUpdate:(double)degree
{
    [self.delegate renderProgress:(float)degree];
	return 0;
}

-(void) progressSetResolution:(double)degree
{
    [self.delegate renderProgress:(float)degree];
}

// C progress callback used by the renderer
//
int progressCodeCallback( double completion, void * context )
{
    Renderer * self = (__bridge Renderer *)(context);
    [self.delegate renderProgress:(float)completion];
	return 0;
}


#pragma mark 所有计算方法汇总
-(unsigned char *)tileRender:(NSString *)sourceFile
				   softImage:(NSString *)softFile
					 cvOpacity:(double)cvOpacity
					 sqrScaleX:(double)_sqrX 
					 sqrScaleY:(double)_sqrY 
					 leakImage:(NSString *)leakFile
			  diffusionOpacity:(double)diffOpacity 
				   SqrVignette:(double)SqrOpacity 
			  CCRGBMaxMinValue:(ffRGBMaxMin3D)_CCrgbMaxMin 
					   monoRGB:(ffColor3D)_monorgb 
				desatBlendrand:(double)blendrand 
				  desatRandNum:(int)randNum
				   borderImage:(NSString *)borderFile
				sCurveContrast:(double)sCcontrast 
			colorFadeRGBMaxMin:(ffRGBMaxMin3D)_colorFadergbMaxMin 
			 cornerSoftOpacity:(double)cornerOpacity
					   width:(int)_width
					  height:(int)_height
					   hiRes:(bool)_hiRes 
{	
	int rowbytes = _width * 4;
	
	//Do Tile Rendering
	BOOL doTileRender = FALSE;
	int tile_height = _height;
	int tile_length = tile_height * rowbytes;
	if (tile_length > MAX_RENDER_TILE)
	{
		tile_height = MAX_RENDER_TILE / rowbytes;
		tile_length = tile_height * rowbytes;
		doTileRender = TRUE;
	}

//	unsigned char *poutb = malloc(tile_length);
//	unsigned char *pout = poutb;
//	if (!poutb)
//		return nil;
	
	unsigned char *m_borderdata = nil;
	unsigned char *m_leakdata = nil;
	unsigned char *m_sourcedata = nil;
	unsigned char *m_softdata = nil;

	// Prepare for temp art tile buffer
	//
	m_borderdata = malloc(tile_length);
	if (!m_borderdata) 
	{
		//free(poutb);
		return nil;
	}
	m_leakdata = malloc(tile_length);
	if (!m_leakdata) 
	{
		//free(poutb);
		free(m_borderdata);
		return nil;
	}
	m_sourcedata = malloc(tile_length);
	if (!m_sourcedata) 
	{
		//free(poutb);
		free(m_borderdata);
		free(m_leakdata);
		return nil;
	}
	m_softdata = malloc(tile_length);
	if (!m_softdata) 
	{
		//free(poutb);
		free(m_borderdata);
		free(m_leakdata);
		free(m_sourcedata);
		return nil;
	}
	
#pragma mark progress
	
	//Progress
	//double progress_step = 0.80 / _height * tile_height;
	//double progress_mark = 0.20;

	// tile rendering requiring the LUT to be prepared before tile rendering
	// Without doing this, the tile_rendering will be garbage
	//	
	pb_Prep_LUT(_CCrgbMaxMin, _monorgb, _colorFadergbMaxMin, cornerOpacity, sCcontrast, cvOpacity, SqrOpacity, diffOpacity);
	unsigned char *tile_poutb = nil;
	FILE *fp = nil;
	for (int h=0; h<_height; h+=tile_height)
	{
		if ( h + tile_height > _height )
		{
			tile_height = _height - h;
			tile_length = tile_height * rowbytes;
		}		
	
		// Read the correct images for rendering
		//
		int offset = h*rowbytes;
		if ( readFile(m_borderdata, [borderFile UTF8String], offset, tile_length) != tile_length )
		{
			free(m_borderdata);
			m_borderdata = nil;
		}
		if ( readFile(m_leakdata, [leakFile UTF8String], offset, tile_length) != tile_length )
		{
			free(m_leakdata);
			m_leakdata = nil;
		}
		if ( readFile(m_sourcedata, [sourceFile UTF8String], offset, tile_length) != tile_length )
		{
			//free(poutb);
			if (m_borderdata) free(m_borderdata);
			if (m_leakdata) free(m_leakdata);
			free(m_sourcedata);
			free(m_softdata);
			return nil;
		}
		if ( readFile(m_softdata, [softFile UTF8String], offset, tile_length) != tile_length )
		{
			//free(poutb);
			if (m_borderdata) free(m_borderdata);
			if (m_leakdata) free(m_leakdata);
			free(m_sourcedata);
			free(m_softdata);
			return nil;
		}

		// Render the tile
		tile_poutb = pb_tile_render(
							  _width, tile_height, h, _height, randNum,
							  nil, nil, m_softdata, m_sourcedata, m_leakdata, m_borderdata,
							  blendrand, _sqrX, _sqrY, (__bridge void *)(self), _hiRes? (&progressCodeCallback) : NULL
							  );

//		if(_hiRes){
//			if ([self progressUpdate:progress_mark])
//			{
//				//free(poutb);
//				if (m_borderdata) free(m_borderdata);
//				if (m_leakdata) free(m_leakdata);
//				free(m_sourcedata);
//				free(m_softdata);
//				free(tile_poutb);
//				return nil;
//			}
//			progress_mark += progress_step;
//		}

		if (!tile_poutb) 
		{
			//free(poutb);
			if (m_borderdata) free(m_borderdata);
			if (m_leakdata) free(m_leakdata);
			free(m_sourcedata);
			free(m_softdata);
			return nil;
		}

		// Copy the tile to the correct offset of the buffer
		//
//		unsigned char *tile_pout = tile_poutb;
//		for (int p=0; p<tile_length; p++)
//		{
//			*pout++ = *tile_pout++;
//		}

		// Output to Disk Cache
		//
		if ( doTileRender )
		{
			if (h==0)
			{
				fp = [Utilities openCacheFileByBinary:TMP_TILE_RENDER_OUTPUT];
			}
			
			if (fp)
			{
				if ( [Utilities appendImageBufferToCacheFile:fp imageBuffer:(char*)tile_poutb length:tile_length] != tile_length )
				{
					[Utilities closeFile:fp];
					free(tile_poutb);
					//free(poutb);
					if (m_borderdata) free(m_borderdata);
					if (m_leakdata) free(m_leakdata);
					free(m_sourcedata);
					free(m_softdata);
					return nil;
				}
			}
			free(tile_poutb);
		}
		else {
			// only do this loop once... we can't free tile_poutb here since we need this to be returned
			//
		}
	}
	
	if (fp) 
	{
		[Utilities closeFile:fp];
		fp = nil;
	}
		
	if (m_borderdata) free(m_borderdata);
	if (m_leakdata) free(m_leakdata);
	free(m_sourcedata);
	free(m_softdata);

	if (doTileRender)
	{
		return [Utilities imageBufferFromFileCache:[Utilities documentsPath:TMP_TILE_RENDER_OUTPUT]];
	}
	else 
	{
		return tile_poutb;
	}

}

-(UIImage *)imageWithSourceImg:(UIImage **)_sourceImgPtr		// can't be nil
					 softImage:(UIImage *)_softImg			// can be nil; will regenerate
				 cvVigArtImage:(UIImage *)_cvVigArt			// can be nil; will regenerate
					 cvOpacity:(double)cvOpacity
				SqrVigArtImage:(UIImage *)_sqrVigArt 
					 sqrScaleX:(double)_sqrX 
					 sqrScaleY:(double)_sqrY 
					 leakImage:(UIImage *)_leakImg			// can be nil; will regenerate
					   leakRGB:(ffColor3D)_leakRgb 
			  randStartYIndex1:(float)startIndex1 
			  randStartYIndex2:(float)startIndex2 
			  randStartYIndex3:(float)startIndex3
					 imageSize:(CGSize)_size 
			  diffusionOpacity:(double)diffOpacity 
				   SqrVignette:(double)SqrOpacity 
				   Leakopacity:(ffOpacity3D)_leakopacity3d
			  CCRGBMaxMinValue:(ffRGBMaxMin3D)_CCrgbMaxMin 
					   monoRGB:(ffColor3D)_monorgb 
				desatBlendrand:(double)blendrand 
				  desatRandNum:(int)randNum
				   borderImage:(UIImage *)_bordImg			// can be nil; will regenerate
				   borderRandX:(double)randX 
				   borderRandY:(double)randY 
				   borderRandS:(double)randBorderScale 
			 borderRandDoScale:(double)randBorderDoScale
					borderType:(int)_borderType
					borderLeft:(int)_borderLeft
					 borderTop:(int)_borderTop
				   borderRight:(int)_borderRight
				  borderBottom:(int)_borderBottom
				sCurveContrast:(double)sCcontrast 
			colorFadeRGBMaxMin:(ffRGBMaxMin3D)_colorFadergbMaxMin 
			 cornerSoftOpacity:(double)cornerOpacity
						 hiRes:(bool)_hiRes 
			   convserveMemory:(bool)_conserveMem
				   isLandscape:(bool)_isLandscape
{	
//	_borderType = 3;
	
	if (!_sourceImgPtr)
		return nil;
	
	UIImage *_sourceImg = *_sourceImgPtr;
	generic_bitmapInfo = CGImageGetBitmapInfo(_sourceImg.CGImage);
	
	int _width=_size.width;
	int _height=_size.height;

	if ( !_sourceImg )
		return nil;
	
	NSLog(@"width = %d, height = %d", _width,_height);
	[Utilities printDateTime];
	// Use this diskcache for instead of keeping the _sourceImg buffer
	//
	if (![Utilities cacheToRawDataFromImage:_sourceImg filename:RENDER_SOURCE_FILE_NAME])
		return nil;	
//#ifdef __DEBUG_PB__
	if(_conserveMem)
	{
//		[_sourceImg release];
		*_sourceImgPtr = nil;
	}
//#endif
	_sourceImg = nil;
	
	[Utilities printDateTime];
	//Progress
	//
#pragma mark progress
	if(_hiRes){
		[self progressSetResolution:0.0];
	}
		
	// Prepare for the border art
	//   Need to prepare buffer for m_borderdata that is _width*_height*4 in resolution
	//
//	if (randBorderDoScale < 0.5f)
//		randBorderScale = 1.0f;	// no scale
	if ( ![self prepareBorderType:_borderType
							width:_width 
						   height:_height 
					   borderLeft:_borderLeft
						borderTop:_borderTop
					  borderRight:_borderRight
					 borderBottom:_borderBottom
				randomBorderScale:randBorderScale
							hiRes:_hiRes
					 isLandscape:_isLandscape] )
			return nil;
	
	[Utilities printDateTime];
#pragma mark progress
	//Progress
	if(_hiRes){
		if ( [self progressUpdate:0.05] )
		{
			return nil;
		}
	}
	
#ifdef __DEBUG_PB__
	NSLog(@"Prepare for the soft blur image");
	NSLog(@"width = %d, height = %d", _width,_height);
	[Utilities printAvailMemory];
#endif
	// Prepare for the soft blur image
	//   Need to prepare buffer for m_softdata that is _width*_height*4 in resolution
	//
	if ( ![self prepareSoftBlurImage:_sourceImg softImage:_softImg width:_width height:_height hiRes:_hiRes ] )
		return nil;
	
	[Utilities printDateTime];
#pragma mark progress
	//Progress
	if(_hiRes){
		if ( [self progressUpdate:0.25] )
		{
			return nil;
		}
	}	
#ifdef __DEBUG_PB__
	NSLog(@"Prepare the leak art");
	NSLog(@"width = %d, height = %d", _width,_height);
	[Utilities printAvailMemory];
#endif
	// Prepare the leak art
	//   Need to prepare buffer for m_leakdata that is _width*_height*4 in resolution
	//
	double ratio = (_width>_height)? (1.0*_width/_height) : (1.0*_height/_width);
	BOOL isLandScape = _isLandscape;
	if (ratio < 1.01)	// near square
	{
		isLandScape = (randBorderDoScale < 0.5);
	}
	if ( ![self prepareLeakImage:_leakImg width:_width height:_height RGB:_leakRgb OpacityValue:_leakopacity3d randStartYIndex1:startIndex1 randStartYIndex2:startIndex2 randStartYIndex3:startIndex3 hiRes:_hiRes isLandscape:isLandScape] )
	{
		return nil;
	}
	
	[Utilities printDateTime];
#pragma mark progress
	//Progress
	if(_hiRes){
		if ([self progressUpdate:0.30])
		{
			return nil;
		}
	}


#ifdef __DEBUG_PB__
	NSLog(@"Render");
	NSLog(@"width = %d, height = %d", _width,_height);
	[Utilities printAvailMemory];
#endif

	// Render
	//
	unsigned char *poutb = [self	tileRender:[Utilities documentsPath:RENDER_SOURCE_FILE_NAME]
									softImage:[Utilities documentsPath:TMP_SOFTIMAGE_FILE_NAME]
									cvOpacity:cvOpacity
									sqrScaleX:_sqrX 
									sqrScaleY:_sqrY 
									leakImage:[Utilities documentsPath:TMP_LEAK_FILE_NAME]
									diffusionOpacity:diffOpacity 
									SqrVignette:SqrOpacity 
									CCRGBMaxMinValue:_CCrgbMaxMin 
									monoRGB:_monorgb 
									desatBlendrand:blendrand 
									desatRandNum:randNum
									borderImage:[Utilities documentsPath:TMP_BORDER_FILE_NAME]
									sCurveContrast:sCcontrast 
									colorFadeRGBMaxMin:_colorFadergbMaxMin 
									cornerSoftOpacity:cornerOpacity
									width:_width
									height:_height
									hiRes:_hiRes 
									];
	
	[Utilities printDateTime];
	// Failed render
	//
	if ( !poutb )
	{
		return nil;
	}		

	// Extract the pixels into context to create UIImage for returning
	//
	CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
	CGContextRef context=CGBitmapContextCreate(poutb, _width, _height, 8, _width*4, colorSpace, generic_bitmapInfo);	
	CGImageRef imageRef=CGBitmapContextCreateImage(context);
	free(poutb);  
	
	UIImage* newImage = [[UIImage alloc] initWithCGImage:imageRef];
	CGContextRelease(context);
	CGImageRelease(imageRef);
	CGColorSpaceRelease(colorSpace);

#ifdef __DEBUG_PB__
	NSLog(@"End Render and Create new Image");
	[Utilities printAvailMemory];
#endif
	
	return newImage;
}

@end

