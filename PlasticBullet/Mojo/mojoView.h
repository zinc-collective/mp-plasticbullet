//
//  mojoView.h
//  mojo
//
//

#import <UIKit/UIKit.h>
#import "mojoViewController.h"

#define ICON_SIZE 24
#define DOT_SIZE 80
#define BORDER_SIZE 5

@interface mojoView : UIView 
{
	CGPoint		firstTouch;
	CGPoint		lastTouch;
	UIImage		*fullImage;
	UIImage		*portraitImage;
//	UIImage		*landscapeImage;
//	UIImage		*portraitImageOutput[4];
//	UIImage		*landscapeImageOutput[4];
	mojoViewController *myViewController;
	NSTimer *timer;
	bool isRotating;
	NSRecursiveLock *theLock;
}
@property CGPoint firstTouch;
@property CGPoint lastTouch;
- (void)setFullImage:(UIImage*)img;
- (UIImage*)getFullImage;
- (void)setPortraitImage:(UIImage*)img;
//- (void)setLandscapeImage:(UIImage*)img;
- (UIImage*)getPortraitImage;
//- (UIImage*)getLandscapeImage;
//- (void)setPortraitImageOutput:(UIImage*)img index:(int)i;
//- (void)setLandscapeImageOutput:(UIImage*)img index:(int)i;

//- (UIImage*)getPortraitImageOutput:(int)i;
//- (UIImage*)getLandscapeImageOutput:(int)i;


- (void)setMojoViewController:(mojoViewController*)pController;





@end

