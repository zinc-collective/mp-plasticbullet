//Guno Test
//
//  mojoViewController.h
//  mojo
//
//

#import <UIKit/UIKit.h>
#include <AudioToolbox/AudioToolbox.h>
#import "RenderArguments.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import "Renderer.h"


//add by jack
typedef enum SAVE_TO_TYPE{
	SAVE_TO_ALBUM = 0,
}SAVE_TO;

typedef enum GRID_MODE {
    GRID_4 = 4,
    GRID_9 = 9
}GRID_MODE;

#define KEY_SAVE_TO		@"saveto"
//end add

@class PostToFlickrViewController;
@class PostToAllViewController;
@class ProgressView;

@protocol MojoDelegate
-(void)mojoDidRefreshGesture;
-(void)mojoIsWorking:(BOOL)working;
@end

@interface mojoViewController : UIViewController <UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIAccelerometerDelegate, CLLocationManagerDelegate> {
//	IBOutlet	UIButton *button1;
    
//	IBOutlet	UIActivityIndicatorView *spinner;
	IBOutlet	UIImageView *topLeftView;
	IBOutlet	UIImageView *topRightView;
	IBOutlet	UIImageView *bottomLeftView;
	IBOutlet	UIImageView *bottomRightView;
	IBOutlet	UIImageView *toolbarView;
	IBOutlet	UIImageView *topbarView;
	
	IBOutlet	UIImageView *topMiddleView;
	IBOutlet	UIImageView *middleLeftView;
	IBOutlet	UIImageView *middleMiddleView;
	IBOutlet	UIImageView *middleRightView;
	IBOutlet	UIImageView *bottomMiddleView;
	
//	CFURLRef		soundFileURLRef;
//	SystemSoundID	soundFileObject;	
	NSThread *workerThread;
	bool isPortrait;
	bool isSaveToAlbum;
	bool doScale;
	bool isInverted;
	bool m_isImageOnceLoaded;
	
	UIImage *cvVigArtImg;
	UIImage *leakImg;
	UIImage *VigArtImg;
	UIImage *borderImg;
	UIImage *blurImage;
	int prevWidth;
	
	UIImage *portraitImage;
	BOOL isFullImageLandscape;

	
	BOOL isRefresh[9];
	
	//PostToFacebookViewController *facebookSession;
	PostToFlickrViewController *flickrSession;
	UINavigationController *navigationFlickr;
	UINavigationController *navigationFacebook;
	
	
	UIImage * saveImage2;
	
	NSMutableDictionary *imageMetadata;
	
	CLLocation *myLocation;
	CLLocationManager *locationManager;
	
	SAVE_TO saveToState;
	
	PostToAllViewController *postToAllViewController;
	
	
	BOOL   isImageFromCamera;
    
    UIInterfaceOrientation nowInterfaceOrientation;
    
    ProgressView *shareProgressView;
    
    int numberMode;
    GRID_MODE gridMode;
}

@property (weak, nonatomic) UIImageView * focusedView;
@property (weak, nonatomic) id<MojoDelegate> delegate;
@property (weak, nonatomic) Renderer * renderer;

@property (nonatomic, assign) UIInterfaceOrientation nowInterfaceOrientation;

@property (retain, nonatomic)PostToAllViewController *postToAllViewController;
@property (retain, nonatomic) UIImage *originalImage;
@property(retain,nonatomic)UIImage *portraitImage;

//@property (retain, nonatomic) UIActivityIndicatorView *spinner;
@property (retain, nonatomic) UIImageView *topLeftView;
@property (retain, nonatomic) UIImageView *topRightView;
@property (retain, nonatomic) UIImageView *bottomLeftView;
@property (retain, nonatomic) UIImageView *bottomRightView;
@property (retain, nonatomic) UIImageView *toolbarView;
@property (retain, nonatomic) UIImageView *topbarView;

@property (retain, nonatomic) UIImageView *topMiddleView;
@property (retain, nonatomic) UIImageView *middleLeftView;
@property (retain, nonatomic) UIImageView *middleMiddleView;
@property (retain, nonatomic) UIImageView *middleRightView;
@property (retain, nonatomic) UIImageView *bottomMiddleView;

//@property (readwrite)	CFURLRef		soundFileURLRef;
//@property (readonly)	SystemSoundID	soundFileObject;

@property(retain,nonatomic)UIImage *cvVigArtImg;

@property(retain,nonatomic)UIImage *leakImg;
@property(retain,nonatomic)UIImage *VigArtImg;
@property(retain,nonatomic)UIImage *borderImg;
@property(retain,nonatomic)UIImage *blurImage;

@property (nonatomic, retain) UINavigationController *navigationFlickr;
@property (nonatomic, retain) UINavigationController *navigationFacebook;
@property (nonatomic, retain) PostToFlickrViewController *flickrSession;


@property (nonatomic, retain) UIImagePickerController *imagePicker;

@property (nonatomic) SAVE_TO saveToState;

@property (nonatomic, retain) ProgressView *shareProgressView;

- (void)focusImage:(UIImageView *)focusedView;
- (void)defocusImage;
- (void)initGrid:(GRID_MODE)gridMode;

- (int)renderImages;
- (void)randomizeQuad:(int)_index;
- (void) generateInputImages;


- (void)startRenderBackground:(bool)renderInputs image:(UIImage *)image  clearAlpha:(bool)clearAlpha;
- (void)backgroundRenderingFull;
- (void)backgroundRenderingRegular;
- (void)backgroundRenderingQuick;
- (void)renderTerminated:(NSString *)answer;

-(void)startAnimating:(NSString *)answer;
-(void)stopAnimating:(NSString *)answer;

-(void)animateImageView:(UIImageView *)imageView;

-(void)prepTmpArt:(int)resolution landscape:(bool)_landscape;
-(void)prepTmpImg:(UIImage *)_image;
-(UIImage *)prepSourceImg:(UIImage *)_sourceImg;

-(UIImage *)createNewImage:(UIImage **)_imagePtr imgWidth:(float)_width imgHeight:(float)_height imgParameter:(int)_index;
-(void) newRenderArg:(int)_index;

-(bool) isSaveCameraShot;
-(NSString *)getDeviceName;
-(void) printAvailMem;

-(void)renderImage:(UIImage*)originalImage;

- (UIImage*)fullyRenderedImage:(UIImageView*)view scaleDown:(BOOL)scaleDown;

- (void)setRotations:(CGFloat)rotate scale:(CGFloat)scale;

@end

