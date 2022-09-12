//
//  RandomRenderArguments.h
//  PlasticBullet
//
//  Created by Sean Hess on 7/11/16.
//  Copyright © 2016 JustStartGo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RenderArguments.h"

float randomPercent(float min, float max);
int randomBetween(int min, int max);

@interface RandomRenderArguments : NSObject
+(ffRenderArguments) generate;
@end
