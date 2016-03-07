//
//  Renderer.h
//  PlasticBullet
//
//  Created by Guno on 11-3-3
//  Copyright 2011 RedSafi LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DataTypeDef.h"

@protocol RenderDelegate
-(void)renderProgress:(float)progress;
@end

@interface Renderer : NSObject
{

}

@property (weak, nonatomic) id<RenderDelegate> delegate;

//+(UIImage *)borderFlip:(UIImage *)_image  randomX:(double)_x randomY:(double)_y;
//
//+(UIImage*)borderTreatment:(UIImage *)_image  
//	randomX:(double)_x 
//	randomY:(double)_y 
//	randomBorderScale:(double)_scale
//	randomBorderDoScale:(double)_doScale;
//
//+(BOOL) prepareBorderImg:(UIImage *)_bordImg 
//						width:(int)_width
//					   height:(int)_height
//					  randomX:(double)randX 
//					  randomY:(double)randY 
//			randomBorderScale:(double)randBorderScale 
//		  randomBorderDoScale:(double)randBorderDoScale;

-(BOOL) multiplyBorder:(NSString*)path
			  longside:(int)_longside
			 shortside:(int)_shortside
			borderSide:(int)_borderSide
		  borderBuffer:(unsigned char*) poutb
		  buffer_width:(int)_width
		 buffer_height:(int)_height
	 randomBorderScale:(double)randBorderScale;

-(BOOL) prepareBorderType:(int)_borderType
					width:(int)_width
				   height:(int)_height
			   borderLeft:(int)_borderLeft
				borderTop:(int)_borderTop
			  borderRight:(int)_borderRight
			 borderBottom:(int)_borderBottom
		randomBorderScale:(double)randBorderScale
					hiRes:(bool)_hiRes
			  isLandscape:(bool)_isLandscape;


-(BOOL) prepareSoftBlurImage:(UIImage *)_sourceImg softImage:(UIImage *)_softImg width:(int)_width height:(int)_height hiRes:(bool)_hiRes ;
;

//+(UIImage *) prepareCircleVignetteImage:(UIImage *)_cvVigArt 
//								  width:(int)_width 
//								 height:(int)_height;
//
//+(UIImage *) prepareSquareVignetteImage:(UIImage *)_sqrVigArt 
//								  width:(int)_width
//								 height:(int)_height
//							  sqrScaleX:(double)_sqrX 
//							  sqrScaleY:(double)_sqrY;

-(UIImage*)leakWithImage:(UIImage *)_sourceImage
			leakArtWidth:(int)leakWidth 
		   leakArtHeight:(int)leakHeight 
			   landscape:(int)isLandscape
			 aspectRatio:(float)ratio
					 RGB:(ffColor3D)_leakRgb 
			OpacityValue:(ffOpacity3D)_leakopacity3d 
		randStartYIndex1:(float)startIndex1 
		randStartYIndex2:(float)startIndex2 
		randStartYIndex3:(float)startIndex3;

//+(UIImage*)LeakRotateWithImage:(UIImage *)image 
//				  scaledToSize:(CGSize)newSize;

-(BOOL) prepareLeakImage:(UIImage *)_leakImg
						width:(int)_width 
					   height:(int)_height
						  RGB:(ffColor3D)_leakRgb 
				 OpacityValue:(ffOpacity3D)_leakopacity3d 
			 randStartYIndex1:(float)startIndex1 
			 randStartYIndex2:(float)startIndex2 
			 randStartYIndex3:(float)startIndex3
				   hiRes:(bool)_hiRes
			 isLandscape:(bool)_isLandscape;

-(UIImage*)blurImg:(UIImage *)_image;
-(BOOL)slowBlurImg:(UIImage *)_image;
-(unsigned char *)blurImgFile:(NSString*)filename width:(int)_width height:(int)_height startProgress:(float)_startProgress progressDuration:(float)_progressDuration hiRes:(bool)_hiRes ;

-(int) progressUpdate:(double)degree;
-(void) progressSetResolution:(double)degree;

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
					   hiRes:(bool)_hiRes ;

-(UIImage*)imageWithSourceImg:(UIImage **)_sourceImgPtr softImage:(UIImage *)_softImg 
	cvVigArtImage:(UIImage *)_cvVigArt 
	cvOpacity:(double)cvOpacity
	SqrVigArtImage:(UIImage *)_sqrVigArt 
	sqrScaleX:(double)_sqrX 
	sqrScaleY:(double)_sqrY 
	leakImage:(UIImage *)_leakImg 
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
	borderImage:(UIImage *)_bordImg  
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
	isLandscape:(bool)_isLandscape;


@end
