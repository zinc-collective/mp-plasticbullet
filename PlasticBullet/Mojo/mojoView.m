//
//  mojoView.m
//  mojo
//
//  Copyright 2010 RedSafi LLC. All rights reserved.
//

#import "mojoView.h"
#import "mojoViewController.h"



@implementation mojoView
@synthesize firstTouch;
@synthesize lastTouch;

- (id)initWithCoder:(NSCoder*)coder
{
	if((self = [super initWithCoder:coder])) 
	{
		timer = nil;
		fullImage = nil;
		portraitImage = nil;
		myViewController = nil;
		
		isRotating = false;
		//NSLog(@"mojoView init");
		theLock = [[NSRecursiveLock alloc] init];
		
	}
	return self;
}


- (void)setMojoViewController:(mojoViewController*)pController
{
	myViewController = pController;
}


- (void)drawRect:(CGRect)rect 
{
#if 0
	static bool firstTime = true;
	if(firstTime && myViewController!=nil)
	{
		// On startup bring up the media browser
		firstTime = false;
		[myViewController setViewState];
		[myViewController getCameraPicture];	
		NSLog(@"mojoView drawRect");
//		[myViewController getExistingPicture];	
	}
#endif
}

- (void)setFullImage:(UIImage*)img
{
	[theLock lock]; 
	fullImage = img;
	[theLock unlock]; 
}

- (void)setPortraitImage:(UIImage*)img
{
	[theLock lock]; 
	portraitImage = img;
	[theLock unlock]; 
}

- (UIImage*)getFullImage
{
	return fullImage;
}
- (UIImage*)getPortraitImage
{
	return portraitImage;
}
@end
