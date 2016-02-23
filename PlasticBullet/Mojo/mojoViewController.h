//Guno Test
//
//  mojoViewController.h
//  mojo
//
//

#import <UIKit/UIKit.h>
#include <AudioToolbox/AudioToolbox.h>
#import "DataTypeDef.h"
#import <CoreLocation/CoreLocation.h>


//add by jack
typedef enum SAVE_TO_TYPE{
	SAVE_TO_ALBUM = 0,
}SAVE_TO;

#define KEY_SAVE_TO		@"saveto"
//end add

@class PostToFlickrViewController;
@class PostToAllViewController;
@class ProgressView;

@protocol MojoDelegate
-(void)didRotate:(BOOL)isPortrait rotation:(CGFloat)rot scale:(CGFloat)scale;
-(void)didRefreshGesture;
@end

@interface mojoViewController : UIViewController <UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIAccelerometerDelegate, CLLocationManagerDelegate> {
//	IBOutlet	UIButton *button1;
    
	IBOutlet	UIActivityIndicatorView *spinner;
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
	
	int m_viewState;
//	CFURLRef		soundFileURLRef;
//	SystemSoundID	soundFileObject;	
	int m_quadIndex;
	NSThread *workerThread;
	bool isPortrait;
	bool isSaveToAlbum;
	bool doScale;
	bool isInverted;
	bool m_isImageOnceLoaded;
	
#ifdef __MOJO__
#else //__PlasticBullet__
	UIImage *cvVigArtImg;	
	UIImage *leakImg;
	UIImage *VigArtImg;
	UIImage *borderImg;
	UIImage *blurImage;
	int prevWidth;
#endif
	
	UIImage *fullImage;
	UIImage *portraitImage;
	BOOL isFullImageLandscape;

	
	BOOL isRefresh[9];
	
	//PostToFacebookViewController *facebookSession;
	PostToFlickrViewController *flickrSession;
	UINavigationController *navigationFlickr;
	UINavigationController *navigationFacebook;
	
	
	UIPopoverController *imagePickerPopover;
	UIImagePickerController *imagePicker;
	
	UIPopoverController *saveSharePopoverController;
	
	UIImage * saveImage2;
	
	NSMutableDictionary *imageMetadata;
	
	CLLocation *myLocation;
	CLLocationManager *locationManager;
	
	SAVE_TO saveToState;
	
	PostToAllViewController *postToAllViewController;
	
	
	BOOL   isImageFromCamera;
    
    UIInterfaceOrientation nowInterfaceOrientation;
    
    ProgressView *shareProgressView;
	
}

@property (weak, nonatomic) id<MojoDelegate> delegate;

@property (nonatomic, assign) UIInterfaceOrientation nowInterfaceOrientation;

@property (retain, nonatomic)PostToAllViewController *postToAllViewController;
@property (retain,nonatomic) UIImage *fullImage;
@property (retain, nonatomic) UIImage *originalImage;
@property(retain,nonatomic)UIImage *portraitImage;

@property (retain, nonatomic) UIActivityIndicatorView *spinner;
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

#ifdef __MOJO__
#else //__PlasticBullet__
@property(retain,nonatomic)UIImage *cvVigArtImg;

@property(retain,nonatomic)UIImage *leakImg;
@property(retain,nonatomic)UIImage *VigArtImg;
@property(retain,nonatomic)UIImage *borderImg;
@property(retain,nonatomic)UIImage *blurImage;
#endif


@property (nonatomic, retain) UINavigationController *navigationFlickr;
@property (nonatomic, retain) UINavigationController *navigationFacebook;
@property (nonatomic, retain) PostToFlickrViewController *flickrSession;


@property (nonatomic, retain) UIPopoverController *imagePickerPopover;
@property (nonatomic, retain) UIImagePickerController *imagePicker;

@property (nonatomic, retain) UIPopoverController *saveSharePopoverController;

@property (nonatomic) SAVE_TO saveToState;

@property (nonatomic, assign) int m_quadIndex;

@property (nonatomic, retain) ProgressView *shareProgressView;


- (void)setViewState;
- (void)activateButton:(int)i;
- (void)getCameraPicture;
- (void)getCameraRoll;
- (void)getExistingPicture;
- (int)renderImages;
//- (void)showMenu;
//- (void)renderAmount:(float)xAmount yArgAmount:(float)yAmount;
//- (bool)getQuadMode;
- (void)selectQuad:(int)index;
- (void)randomizeQuad:(int)_index;
- (void) generateInputImages;
- (int) getViewState;
//- (void) playSystemSound;
//- (void) playAlertSound;

//modify by jack
- (void)startSaveBackground:(SAVE_TO)saveTo;

//info: key = @"saveto"
- (void)backgroundSaving:(NSDictionary*)info;

- (void)saveTerminated:(NSString *)answer;
//- (bool)cancelSave;


//add by jack
- (void)shareOnFacebook:(UIImage*)image;
- (void)shareOnFlickr:(UIImage*)image;

- (void)startRenderBackground:(bool)renderInputs image:(UIImage *)image  clearAlpha:(bool)clearAlpha;
- (void)backgroundRenderingFull;
- (void)backgroundRenderingRegular;
- (void)backgroundRenderingQuick;
- (void)renderTerminated:(NSString *)answer;
//- (bool)cancelRender;

//- (void) renderRedraw;
- (void)setWidgetGeometry;
- (IBAction)selectImageView:(id)sender;

- (IBAction)selectToolBarButton:(id)sender;

-(void)startAnimating:(NSString *)answer;
-(void)stopAnimating:(NSString *)answer;

-(void)animateImageView:(UIImageView *)imageView;

-(void)prepTmpArt:(int)resolution landscape:(bool)_landscape;
-(void)prepTmpImg:(UIImage *)_image;
-(UIImage *)prepSourceImg:(UIImage *)_sourceImg;

-(UIImage *)createNewImage:(UIImage **)_imagePtr imgWidth:(float)_width imgHeight:(float)_height imgParameter:(int)_index;
-(void) newRenderArg:(int)_index;

#ifdef __MOJO__
#else //__PlasticBullet__
-(ffRenderArguments)randomImgParameter;
#endif

-(bool) isSaveCameraShot;
-(int) isHalfResolution;
-(bool) is3QuarterResolution;
-(CGSize) getMaxResolution;
-(CGSize) getMaxRenderResolution:(CGSize)imgres;
-(NSString *)getDeviceName;
-(bool) isLowRes;
-(bool) useFacebook;
-(bool) useFlickr;
-(void) printAvailMem;

- (void) resetNumberModel;

- (void)backToFour;
- (void)showFourViewScreen;
- (void)cancelUploasShowOneViewScreen;
-(void)renderImage:(UIImage*)originalImage;

@end

