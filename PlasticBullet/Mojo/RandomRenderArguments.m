//
//  RandomRenderArguments.m
//  PlasticBullet
//
//  Created by Sean Hess on 7/11/16.
//  Copyright © 2016 JustStartGo. All rights reserved.
//

#import "RandomRenderArguments.h"
#import "RenderArguments.h"

// this is only 2-digit precision, but that's enough. that's 100 values per axis.
float randomPercent(int min, int max) {
    u_int32_t upper_random = (max - min) + 1;
    float random_value = arc4random_uniform(upper_random);
    float value = ((float)(min + random_value) / 100.f);
    return value;
}

@implementation RandomRenderArguments


+(ffRenderArguments)generate
{
	ffRenderArguments renderArg;
	//cornerSoft
    renderArg.cornerOpacity = randomPercent(10, 100); // arc4random_uniform(901) / 1000.0f + 0.1f;
	
	//diffusion
    // from 0.1 to 0.801
    renderArg.difOpacity = randomPercent(0, 60); // arc4random_uniform(701) / 1000.0f + 0.1f;
	//circleVignette
    renderArg.cvOpacity = randomPercent(30, 100); //    arc4random_uniform(701) / 1000.0f + 0.3f;
    
	//sqrVignette
    renderArg.SqrOpacity = randomPercent(10, 90); // arc4random_uniform(801) / 1000.0f + 0.1f;
    renderArg.sqrScaleX = randomPercent(0, 100); // arc4random_uniform(1001) / 1000.0f;
    renderArg.sqrScaleY = randomPercent(0, 100); // arc4random_uniform(1001) / 1000.0f;
    
	//leakTint
    renderArg.leakTintRGB.r = randomPercent(80, 100); // arc4random_uniform(201)/1000.0f+0.8f;
    renderArg.leakTintRGB.g = randomPercent(30, 60); // arc4random_uniform(301)/1000.0f+0.3f;
    renderArg.leakTintRGB.b = randomPercent(0, 30); // arc4random_uniform(301)/1000.0f;
    
	//leak offset
    renderArg.opacity3D.opacity1 = randomPercent(0, 100); // arc4random_uniform(1001)/1000.0f;
    renderArg.opacity3D.opacity2 = randomPercent(0, 80); // arc4random_uniform(801)/1000.0f;
    renderArg.opacity3D.opacity3 = randomPercent(0, 50); // arc4random_uniform(501)/1000.0f;
	
    renderArg.startY1 = randomPercent(0, 100); // arc4random_uniform(1001)/1000.0f;
    renderArg.startY2 = randomPercent(0, 100); // arc4random_uniform(1001)/1000.0f;
    renderArg.startY3 = randomPercent(0, 100); // arc4random_uniform(1001)/1000.0f;
    
	//colorClip
	renderArg.CCExpose = (arc4random_uniform(601)/1000.0f) - 0.25f;
	//r
	renderArg.CCRGBMaxMin.rMin = (arc4random_uniform(1001)/1000.0f) * 0.3f;
	renderArg.CCRGBMaxMin.rMax = (arc4random_uniform(1001)/1000.0f) * 0.25f + 0.75f - renderArg.CCExpose;
	//g
	renderArg.CCRGBMaxMin.gMin = (arc4random_uniform(1001)/1000.0f) * 0.1f;
	renderArg.CCRGBMaxMin.gMax = (arc4random_uniform(1001)/1000.0f) * 0.2f + 0.8f - renderArg.CCExpose;
	//b
	renderArg.CCRGBMaxMin.bMin = 0.0f;
	renderArg.CCRGBMaxMin.bMax = 1.0f - renderArg.CCExpose;
	
	//monoChrome
	renderArg.rgbValue.r = (arc4random_uniform(1001)/1000.0f) * 0.5f + 0.5f;
	renderArg.rgbValue.g = (arc4random_uniform(1001)/1000.0f) * 0.5f + 0.5f;
	renderArg.rgbValue.b = (arc4random_uniform(1001)/1000.0f) * 0.45f + 0.05f;
	//desat
	renderArg.blendrand = (arc4random_uniform(1001)/1000.0f) * 0.65f + 0.05f;
	renderArg.randNum = arc4random_uniform(100);
	//border
	renderArg.randX = (arc4random_uniform(2)) * 1.0f;
	renderArg.randY = (arc4random_uniform(2)) * 1.0f;
	renderArg.randBorderScale = (arc4random_uniform(301)) / 1000.0f + 1.0f;
	renderArg.randBorderDoScale = (arc4random_uniform(2)) * 1.0f;
	
	// new boder random numbers
	renderArg.borderType = (arc4random_uniform(4));
	renderArg.borderLeft = (arc4random_uniform(10));
	renderArg.borderTop = (arc4random_uniform(10));
	renderArg.borderRight = (arc4random_uniform(10));
	renderArg.borderBottom = (arc4random_uniform(10));
	
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
