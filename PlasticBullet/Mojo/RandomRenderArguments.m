//
//  RandomRenderArguments.m
//  PlasticBullet
//
//  Created by Sean Hess on 7/11/16.
//  Copyright © 2016 JustStartGo. All rights reserved.
//

#import "RandomRenderArguments.h"
#import "RenderArguments.h"

// this works with negative numbers so long as the RANGE is positive
int randomBetween(int min, int max) {
    return min + arc4random_uniform(max - min + 1);
}

float randomPercent(float min, float max) {
    int minThousands = round(min * 1000.0);
    int maxThousands = round(max * 1000.0);
    int randValue = randomBetween(minThousands, maxThousands);
    float value = (float)randValue / 1000.0;
//    NSLog(@"randomPercent min=%i max=%i rand=%i value=%f", minThousands, maxThousands, randValue, value);
    return value;
}

@implementation RandomRenderArguments



+(ffRenderArguments)generate
{
	ffRenderArguments renderArg;
    
	//cornerSoft
    renderArg.cornerOpacity = randomPercent(0.1, 1.0); // arc4random_uniform(901) / 1000.0f + 0.1f;
	
	//diffusion
    // from 0.1 to 0.801
    renderArg.difOpacity = randomPercent(0, 0.6); // arc4random_uniform(701) / 1000.0f + 0.1f;
    
	//circleVignette
    renderArg.cvOpacity = randomPercent(0, 0.6); //    arc4random_uniform(701) / 1000.0f + 0.3f;
    
	//sqrVignette
    renderArg.SqrOpacity = randomPercent(0, 0.6); // arc4random_uniform(801) / 1000.0f + 0.1f;
    renderArg.sqrScaleX = randomPercent(0, 1.0); // arc4random_uniform(1001) / 1000.0f;
    renderArg.sqrScaleY = randomPercent(0, 1.0); // arc4random_uniform(1001) / 1000.0f;
    
    //gamma
    // http://www.dfstudios.co.uk/articles/programming/image-programming-algorithms/image-processing-algorithms-part-6-gamma-correction/
    renderArg.gamma = randomPercent(0.85, 1.0);
    
	//leakTint
    renderArg.leakTintRGB.r = randomPercent(0.8, 1.0); // arc4random_uniform(201)/1000.0f+0.8f;
    renderArg.leakTintRGB.g = randomPercent(0.3, 0.6); // arc4random_uniform(301)/1000.0f+0.3f;
    renderArg.leakTintRGB.b = randomPercent(0, 0.3); // arc4random_uniform(301)/1000.0f;
    
	//leak offset
    renderArg.opacity3D.opacity1 = randomPercent(0, 1.0); // arc4random_uniform(1001)/1000.0f;
    renderArg.opacity3D.opacity2 = randomPercent(0, 0.8); // arc4random_uniform(801)/1000.0f;
    renderArg.opacity3D.opacity3 = randomPercent(0, 0.5); // arc4random_uniform(501)/1000.0f;
	
    renderArg.startY1 = randomPercent(0, 1.0); // arc4random_uniform(1001)/1000.0f;
    renderArg.startY2 = randomPercent(0, 1.0); // arc4random_uniform(1001)/1000.0f;
    renderArg.startY3 = randomPercent(0, 1.0); // arc4random_uniform(1001)/1000.0f;
    
    // colorClip
    renderArg.CCRGBMaxMin = [self colorClip];
    
	//monoChrome
	renderArg.rgbValue.r = (arc4random_uniform(1001)/1000.0f) * 0.5f + 0.5f;
	renderArg.rgbValue.g = (arc4random_uniform(1001)/1000.0f) * 0.5f + 0.5f;
	renderArg.rgbValue.b = (arc4random_uniform(1001)/1000.0f) * 0.45f + 0.05f;
	//desat
	renderArg.blendrand = (arc4random_uniform(1001)/1000.0f) * 0.65f + 0.05f;
	renderArg.randNum = arc4random_uniform(100);
    
	//border
    renderArg.border = [self border];
	
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

+(BorderArguments)border {
    BorderArguments border;
	border.x = (arc4random_uniform(2)) * 1.0f; // 0.00 or 1.00
	border.y = (arc4random_uniform(2)) * 1.0f; // 0.00 or 1.00
    border.scale = randomPercent(1.3, 1.6); // (arc4random_uniform(301)) / 1000.0f + 1.0f;
	border.doScale = (arc4random_uniform(2)) * 1.0f; // 0.00 or 1.00
	
    int numBorderTypes = 3;
    int noBorderWeight = 4;
    
    int borderTypeValue = arc4random_uniform(numBorderTypes + noBorderWeight);
    
    if (borderTypeValue < numBorderTypes) {
        border.type = borderTypeValue;
    }
    else {
        border.type = none;
    }
    
	border.left = arc4random_uniform(10);
	border.top = arc4random_uniform(10);
	border.right = arc4random_uniform(10);
	border.bottom = arc4random_uniform(10);
    
    return border;
}


+(ffRGBMaxMin3D)colorClip {
    
	//colorClip:
    ffRGBMaxMin3D rgbMaxMin;
    // was -0.25 to 0.35
    rgbMaxMin.expose = randomPercent(-0.25, 0.0);
    
	//r
    rgbMaxMin.rMin = randomPercent(0.0, 0.3);
    rgbMaxMin.rMax = randomPercent(0.75, 1.0) - rgbMaxMin.expose;
    
	//g
    rgbMaxMin.gMin = randomPercent(0.0, 0.1);
    rgbMaxMin.gMax = randomPercent(0.8, 1.0) - rgbMaxMin.expose;
    
	//b
	rgbMaxMin.bMin = 0.0f;
	rgbMaxMin.bMax = 1.0f - rgbMaxMin.expose;
//    NSLog(@"RGBMax expose=%f r=%f g=%f b=%f", rgbMaxMin.expose, rgbMaxMin.rMax, rgbMaxMin.gMax, rgbMaxMin.bMax);
    
    return rgbMaxMin;
}

@end
