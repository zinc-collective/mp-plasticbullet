/*
 *  renderArguments.h
 *  PlasticBullet
 *
 *  Created by WXP on 10-1-8.
 *  Copyright 2010 RedSafi LLC. All rights reserved.
 *
 */

//rgb in floating point
typedef struct _ffColor3D
	{
		double r;
		double g;
		double b;
	} ffColor3D;
//3 opacities for leak tint
typedef struct _ffOpacity3D
	{
		double opacity1;
		double opacity2;
		double opacity3;
	} ffOpacity3D;

//min-max range for rgb channels
//
typedef struct _ffRGBMaxMin3D
	{
		double rMax;
		double rMin;
		double gMax;
		double gMin;
		double bMax;
		double bMin;
	} ffRGBMaxMin3D;

//rendering parameters
typedef struct {
	//cornerSoft
	double cornerOpacity;
	
	//diffusion
	double difOpacity;
	//CircleVignette
	double cvOpacity;
	//sqrVignette
	double SqrOpacity;
	
	double sqrScaleX;
	double sqrScaleY;
	
	//leakTint
	ffColor3D leakTintRGB;
	//leak art offset
	float startY1,startY2,startY3;
	//leak
	ffOpacity3D opacity3D;
	//colorClip
	float CCExpose;
	ffRGBMaxMin3D CCRGBMaxMin;
	//monoChrome
	ffColor3D rgbValue;
	//desat
	double blendrand;
	int randNum;
	//border
	double randX,randY,randBorderScale,randBorderDoScale;
	int borderType, borderLeft, borderTop, borderRight, borderBottom;
	
	//sCurve
	double contrast;
	//colorFade
	ffRGBMaxMin3D colorFadeRGB;
	
	int cachedRenderImage;
	int cachedPreviewImage;
	
} ffRenderArguments;

