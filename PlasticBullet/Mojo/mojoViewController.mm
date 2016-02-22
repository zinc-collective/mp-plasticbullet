//
//  mojoViewController.mm
//  mojo
//


#define TOOLBAR_OFFSET_HEIGHT 44

/*
 TODO
 * Name change to Mojo (capital)
 * Remove sound
 * Saved image doesn't have the same look as chosen image
 * Bug Full Screen -> Save -> Load -> Stays in Full screen
 * Buttons wrong after you Save image
 * When there is no image we should not allow Full view to be selected (stay in quad mode always)
 * When clicking a button and releasing outside it was still triggering the event
 * After Save, Click Cancel, does not render and update
 * One large, 3 small after transition from Full to Quad (with rotate in middle)
 * One small, 3 large after transition from Full to Quad (with rotate in middle)
 
 
 * Glow ball PNG is drawn under, not over button PNGs (maybe revert to system icons)
 (INVESTIGATED - Alpha in png seems weird for Camera and Library - eg bring them up in the Apple "Preview" application and zoom up - seem like problem areas are black pixels with full white alpha)
 
 
 
 
 
 
 * Loading spinny animation sometimes appears in upper rt. of screen instead of center, then hangs app (after camera)
 */

#include <math.h>
#import "mojoViewController.h"
#import "mojoView.h"
// #import "mojoAppDelegate.h"
// #import "PostToFacebookViewController.h"
// #import "PostToFlickrViewController.h"

#import "Utilities.h"

#import <AssetsLibrary/AssetsLibrary.h>

#ifdef __MOJO__
//#include "Plugin_Render.h"
#else //__PlasticBullet__
#import "ImageProcess.h"
#import "Renderer.h"
#import "DataFile.h"
#import "FileCache.h"
//#import "SaveShareViewController.h"
//#import "TumblrLoginViewController.h"
//#import "PostToTumblrViewController.h"
//#import "PostToTwitterViewController.h"
//#import "Setting2ViewController.h"
//#import "SaveShareViewController2.h"

#endif

#define FORMAT_PREVIEW "cachedPreview_%d"
#define FORMAT_RENDER "cachedRender_%d"

#define LOCATION_SERVICE_TIME_OUT_SECONDS	10

NSThread *sWorkerThread = nil;

//static RenderArguments renderArgsArray[4];
//static bool quadMode = true;
//static bool nineMode = false;

//static int TOOLBAR_OFFSET_HEIGHT = 44;

static int numberMode = 9;
static int lastNumberMode = 9;

//static bool isNineMode = false;

static int s_isCameraPick = false;
//static UIActionSheet *actionSheet = nil;
static bool isActionSheetViewOn = false;
static int actionSheetNo = 0;
static CGSize sRenderTarget;	
static bool sPostRenderScale = false;

//add by Guno
static int fullImageWidth = 0;
static int fullImageHeight = 0;
static UIImage *portraitImage1 = nil;
static UIImage *portraitImage4 = nil;
static UIImage *portraitImage9 = nil;
static UIImage *s_loadedImage = nil;

//end Guno




#ifdef SUBVIEW
static UIView *s_mySubView = nil;
#endif

#ifdef __MOJO__
static void setDefaultRenderArg(RenderArguments &renderArgs)
{
	renderArgs.FXid_BlueShadows			= 25.f; 
	renderArgs.FXid_ShadowTint			= 50.f; 
	renderArgs.FXid_ShadowPoint			= 75.f;  
	renderArgs.FXid_WarmCool			= 0.f;  
	renderArgs.FXid_Contrast			= 25.f;  
	renderArgs.FXid_Bleach				= 0.f;  
	renderArgs.FXid_SkinColor			= 0.f;  
	renderArgs.FXid_SkinSqueeze			= 0.f;  
	renderArgs.FXid_SkinSolo			= 0.f;   
	renderArgs.FXid_ShowSkinOverlay		= false;   
	renderArgs.FXid_SkinCenter			= 6.8f;   
	renderArgs.FXid_SkinLowHiRadius		= 3.8f;   
	renderArgs.FXid_SkinColorSqueezeMin	= 35.f;   
	renderArgs.FXid_SkinColorSqueezeMax	= 65.f;   
	renderArgs.FXid_SkinSoloMin			= 25.f;   
	renderArgs.FXid_SkinSoloMax			= 70.f;   
	renderArgs.FXid_LUTSize				= 5;   
	renderArgs.FXid_SkinColorSpace		= 1;   
	renderArgs.FXid_ShowLumaRadius		= 15.f;   
	renderArgs.FXid_ScopeColor[0]		= 1.f;   
	renderArgs.FXid_ScopeColor[1]		= 104.f/255.f;   
	renderArgs.FXid_ScopeColor[2]		= 0.f;   
	renderArgs.FXid_ShowOpacity			= 50.f;   
	renderArgs.FXid_GridSize			= 64;   
	renderArgs.FXid_BorderSize			= 1.f;   
	renderArgs.FXid_ScopeRadius			= 1.5f;   
	renderArgs.FXid_SqueezeNormalize	= true;   	
}

static float getNormalizedRandomNumber(float min, float max)
{
	float f = float(rand()&65535)/65535.f;
	return f*max + (1.f-f)*min;
}

#define NUM_RANDOM_PROPS 6

static int axisXProperty = -1;
static int axisYProperty = -1;



static void randomizeAxis()
{
	axisXProperty = rand()%NUM_RANDOM_PROPS;
	do
	{
		axisYProperty = rand()%NUM_RANDOM_PROPS;	
	}
	while(axisXProperty==axisYProperty);
}

static float getAmountRandomNumber(float value, float min, float max, float amount)
{
	float f = value;
	f += (max-min)*amount;
	if(f<min)
		f = min;
	else if(f>max)
		f = max;
	return f;
}

static void randomizeRenderArg(RenderArguments &renderArgs, int index)
{
	int i = 0;
	if(index == i++ || index == -1)
		renderArgs.FXid_BlueShadows			= getNormalizedRandomNumber(0, 100); 
	if(index == i++ || index == -1)
		renderArgs.FXid_ShadowTint			= getNormalizedRandomNumber(0, 100); 
	if(index == i++ || index == -1)
		renderArgs.FXid_ShadowPoint			= getNormalizedRandomNumber(30, 80);   
	if(index == i++ || index == -1)
		renderArgs.FXid_WarmCool			= getNormalizedRandomNumber(-25, 80);   
	if(index == i++ || index == -1)
		renderArgs.FXid_Contrast			= getNormalizedRandomNumber(-25, 100);   
	if(index == i++ || index == -1)
		renderArgs.FXid_Bleach				= getNormalizedRandomNumber(-23, 80);   
#if 0
	if(index == i++ || index == -1)
		renderArgs.FXid_SkinColor			= getNormalizedRandomNumber(-100, 100);   
	if(index == i++ || index == -1)
		renderArgs.FXid_SkinSqueeze			= getNormalizedRandomNumber(0, 100);  
	if(index == i++ || index == -1)
		renderArgs.FXid_SkinSolo			= getNormalizedRandomNumber(0, 100);   
#endif
}



static void setAmountRenderArg(RenderArguments &renderArgs, int index, float amount)
{
	int i = 0;
	if(index == i++ || index == -1)
		renderArgs.FXid_BlueShadows			= getAmountRandomNumber(renderArgs.FXid_BlueShadows, 0, 200, amount); 
	if(index == i++ || index == -1)
		renderArgs.FXid_ShadowTint			= getAmountRandomNumber(renderArgs.FXid_ShadowTint, -100, 300, amount); 
	if(index == i++ || index == -1)
		renderArgs.FXid_ShadowPoint			= getAmountRandomNumber(renderArgs.FXid_ShadowPoint, 0, 200, amount);   
	if(index == i++ || index == -1)
		renderArgs.FXid_WarmCool			= getAmountRandomNumber(renderArgs.FXid_WarmCool, -200, 200, amount);   
	if(index == i++ || index == -1)
		renderArgs.FXid_Contrast			= getAmountRandomNumber(renderArgs.FXid_Contrast, -100, 500, amount);   
	if(index == i++ || index == -1)
		renderArgs.FXid_Bleach				= getAmountRandomNumber(renderArgs.FXid_Bleach, -100, 100, amount);   
	if(index == i++ || index == -1)
		renderArgs.FXid_SkinColor			= getAmountRandomNumber(renderArgs.FXid_SkinColor, -100, 100, amount);   
	if(index == i++ || index == -1)
		renderArgs.FXid_SkinSqueeze			= getAmountRandomNumber(renderArgs.FXid_SkinSqueeze, 0, 100, amount);  
	if(index == i++ || index == -1)
		renderArgs.FXid_SkinSolo			= getAmountRandomNumber(renderArgs.FXid_SkinSolo, 0, 100, amount);    
}

bool checkAbort(int y)
{
	const int numLinesCheckAbort = 10;
	if( y % numLinesCheckAbort == 0 && sWorkerThread)
	{
		if([sWorkerThread isCancelled])
			return true;
	}
	
	return false;
}

static int doRender(int width, int height, int rowbytes, unsigned char *buffer, const RenderArguments &renderArgs)
{
	//sleep(1);//hack
	return PluginRender(renderArgs, width, height, rowbytes, buffer, 1.f, 1.f, 1.f);
}

static UIImage* createImage(int width, int height, UIImage *image, RenderArguments *pRenderArgs = NULL, bool histogramEqualization = false)
{
	if(!image)
		return NULL;
	int rowbytes = width*4;	
	unsigned char *buffer = (unsigned char*)malloc( height * rowbytes );
	if(buffer == nil) 
		return NULL;
	CGContextRef imageContextRef = CGBitmapContextCreate(buffer, 
														 width, 
														 height, 
														 8, 
														 rowbytes, 
														 CGImageGetColorSpace(image.CGImage), 
														 kCGImageAlphaPremultipliedLast
														 );
	CGContextDrawImage(imageContextRef, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), image.CGImage);
	
	if(pRenderArgs)
	{
		if(doRender(width, height, rowbytes, buffer, *pRenderArgs)!=0)
		{
			CGContextRelease(imageContextRef);
			free(buffer);
			return NULL;
		}
	}
	if(histogramEqualization)
	{
		if(PluginRenderHistogramEqualization(width, height, rowbytes, buffer)!=0)
		{
			CGContextRelease(imageContextRef);
			free(buffer);
			return NULL;
		}
	}
	
	UIImageOrientation o = image.imageOrientation;
	if(o ==  UIImageOrientationLeft ||  o ==  UIImageOrientationRight || o == UIImageOrientationRightMirrored || o == UIImageOrientationLeftMirrored )
	{
		int t = width;
		width = height;
		height = t;
		int rowbytes2 = width*4;	
		unsigned char *buffer2 = (unsigned char*)malloc( height * rowbytes2 );
		if(buffer2 == nil) 
			return NULL;
		
		// Transposition
		for(int y=0; y<height; ++y)
		{
			unsigned char *oT = &buffer2[y*rowbytes2];
			unsigned char *iT = &buffer[y*4];
			for(int x=0; x<width; ++x)
			{
				memcpy(oT, iT, 4);
				oT+=4;
				iT+=rowbytes;
			}
		}
		
		CGContextRelease(imageContextRef);
		free(buffer);
		buffer = buffer2;
		rowbytes = rowbytes2;
		imageContextRef = CGBitmapContextCreate(buffer, 
												width, 
												height, 
												8, 
												rowbytes, 
												CGImageGetColorSpace(image.CGImage), 
												kCGImageAlphaPremultipliedLast
												);
		
	}
	
	if(o ==  UIImageOrientationDown || o ==  UIImageOrientationRight || o == UIImageOrientationRightMirrored || o == UIImageOrientationUpMirrored )
	{
		// Flip x-axis
		//
		int width2 = width/2;
		for(int y=0; y<height; ++y)
		{
			unsigned char *oT = &buffer[y*rowbytes];
			unsigned char *oT2 = oT + (width-1)*4;
			for(int x=0; x<width2; ++x)
			{
				unsigned char pixel[4];
				memcpy(pixel, oT, 4);					
				memcpy(oT, oT2, 4);
				memcpy(oT2, pixel, 4);					
				oT+=4;
				oT2-=4;
			}
		}
	}
	if(o ==  UIImageOrientationLeft || o ==  UIImageOrientationDown || o == UIImageOrientationRightMirrored || o == UIImageOrientationDownMirrored)
	{
		// Flip y-axis
		//
		int height2 = height/2;
		unsigned char *lineBuffer = (unsigned char *)malloc(rowbytes);
		for(int y=0; y<height2; ++y)
		{
			unsigned char *oT = &buffer[y*rowbytes];
			unsigned char *oT2 = &buffer[(height-1-y)*rowbytes];
			memcpy(lineBuffer, oT, rowbytes);
			memcpy(oT, oT2, rowbytes);
			memcpy(oT2, lineBuffer, rowbytes);			
		}
		free(lineBuffer);
	}	
	
	
	// get the new CGImage
	CGImageRef newImageRef = CGBitmapContextCreateImage(imageContextRef);
	// get the UIImage back	
	UIImage* newImage = [[UIImage alloc] initWithCGImage:newImageRef];
	CGImageRelease(newImageRef);	
	CGContextRelease(imageContextRef);
	free(buffer);
	
	return newImage;
}

static RenderArguments renderArgsArray[4];
#else //__PlasticBullet__
static ffRenderArguments ffRenderArgsArray[9];
#endif

@implementation mojoViewController
//@synthesize button1;
@synthesize spinner;
//@synthesize soundFileURLRef;
//@synthesize soundFileObject;
@synthesize topLeftView;
@synthesize topRightView;
@synthesize bottomLeftView;
@synthesize bottomRightView;

@synthesize topMiddleView;
@synthesize middleLeftView;
@synthesize middleMiddleView;
@synthesize middleRightView;
@synthesize bottomMiddleView;

@synthesize toolbarView;
@synthesize topbarView;

@synthesize button_topLeftView;
@synthesize button_topRightView;
@synthesize button_bottomLeftView;
@synthesize button_bottomRightView;

@synthesize button_topMiddleView;
@synthesize button_middleLeftView;
@synthesize button_middleMiddleView;
@synthesize button_middleRightView;
@synthesize button_bottomMiddleView;

@synthesize button_back;
@synthesize button_camera;
@synthesize button_library;
@synthesize button_refresh;
@synthesize button_refresh2;
@synthesize button_save;

@synthesize button_four;
@synthesize button_nine;


#ifdef __MOJO__
#else //__PlasticBullet__
@synthesize cvVigArtImg;
@synthesize leakImg;
@synthesize VigArtImg;
@synthesize borderImg;
@synthesize blurImage;
#endif


//@synthesize pView;
@synthesize fullImage;
@synthesize portraitImage;
//save small pictures array
static UIImage *viewImageArray[9] = {nil};

@synthesize navigationFlickr;
@synthesize navigationFacebook;
@synthesize flickrSession;

@synthesize imagePickerPopover;
@synthesize imagePicker;

@synthesize saveSharePopoverController;

@synthesize saveToState;

@synthesize postToAllViewController;

@synthesize m_quadIndex;

@synthesize shareProgressView;

@synthesize nowInterfaceOrientation;



- (void)setViewState
{	
	
	//quadMode = (m_viewState == 1);	
	
	if(m_viewState == 2)
	{
		//quadMode = NO;
		[button_save setHidden:NO];
		[button_back setHidden:NO];		
		[button_camera setHidden:YES];
		[button_library setHidden:YES];	
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			[button_refresh setHidden:YES];	
			[button_refresh2 setHidden:NO];	
			
			[button_four setHidden:YES];	
			[button_nine setHidden:YES];
		}
		
		//if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		//			[button_refresh setFrame:CGRectMake(button_refresh.frame.origin.x + 220, button_refresh.frame.origin.y, button_refresh.frame.size.width, button_refresh.frame.size.height)];
		//		}
		
		
	}
	else
	{
		//quadMode = YES;
		[button_save setHidden:YES];
		[button_back setHidden:YES];		
		[button_camera setHidden:NO];
		[button_library setHidden:NO];
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			[button_refresh setHidden:NO];
			[button_refresh2 setHidden:YES];
			[button_four setHidden:NO];	
			[button_nine setHidden:NO];
		}
		
		
		
		if (numberMode == 4) {
			[button_four  setImage:[UIImage imageNamed:@"four_ipad.png"]  forState:UIControlStateNormal];
			//[button_four  setImage:[UIImage imageNamed:@"four_ipad.png"]  forState:UIControlStateHighlighted];
			[button_nine  setImage:[UIImage imageNamed:@"nine_down_ipad.png"]  forState:UIControlStateNormal];
		} else {
			[button_four  setImage:[UIImage imageNamed:@"four_down_ipad.png"] forState:UIControlStateNormal];
			[button_nine  setImage:[UIImage imageNamed:@"nine_ipad.png"] forState:UIControlStateNormal];
			//[button_nine  setImage:[UIImage imageNamed:@"nine_ipad.png"] forState:UIControlStateHighlighted];
			
		}
		
	}
}

- (void)activateButton:(int)i
{
	if(i == 0)
	{
		bool doRender = false;
		switch(m_viewState)
		{
			case 0:
				[self getExistingPicture];
				break;
			case 1:
				[self getExistingPicture];
				//m_viewState = 0;
				break;
			case 2:
				// Goto Quad Mode
				//back
				[UIView beginAnimations:@"Rotate" context:nil];
				[UIView  setAnimationDelegate:self];
				[UIView setAnimationDidStopSelector:@selector (animationDidStopAndRender:finished:context:) ];
				[UIView  setAnimationWillStartSelector:@selector (animationWillStart:context:) ];
				numberMode = lastNumberMode;
				
				m_viewState = 1;
				[self setWidgetGeometry]; // Account for rotation to set up animation start state
				
				[UIView commitAnimations];	
				
				//m_viewState = 2;
				//				//numberMode = 1;
				//				[self setWidgetGeometry]; // Account for rotation to set up animation start state
				//				
				//				m_viewState = 1;
				
				
				//doRender = true;
				break;
		}
		[self setViewState];
		if(m_viewState == 1)
		{
			if(doRender)
			{
				
				[UIView beginAnimations:@"RenderAnim" context:nil];
				[UIView  setAnimationDelegate:self];
				[UIView setAnimationDidStopSelector:@selector (animationDidStopAndRender:finished:context:) ];
				[UIView  setAnimationWillStartSelector:@selector (animationWillStart:context:) ];
				[self setWidgetGeometry];
				[UIView commitAnimations];	
			}
			mojoView *pView = (mojoView *)self.view;
			[pView setNeedsDisplay];	
		}
	}
	else if(i==1)
	{
		switch(m_viewState)
		{
			case 1:
				//m_viewState = 0;
				[self getCameraPicture];
				break;
			case 2: 
			{ //save and share
			}
		}		
	}
	
	else if(i==3) {
		if (numberMode == 4) {
			return;
		}
		m_viewState = 1;
		numberMode = 4;
		
		
		[self setWidgetGeometry]; 
		[self setViewState];
		
		//refresh
		//Render regular
		[self randomizeQuad:-2];
		//mojoView *pView = (mojoView *)self.view;
		//		[pView setNeedsDisplay];
		
	}
	
	else if(i==4) {
		if (numberMode == 9) {
			return;
		}
		
		m_viewState = 1;
		numberMode = 9;
		
		[self setWidgetGeometry]; 
		[self setViewState];
		
		//refresh
		//Render regular
		[self randomizeQuad:-2];
		//mojoView *pView = (mojoView *)self.view;
		//		[pView setNeedsDisplay];
	}
	
	else //refresh
	{
		switch(m_viewState)
		{
			case 0:
				break;
			case 1:
			{
				[self randomizeQuad:-1];
				mojoView *pView = (mojoView *)self.view;
				[pView setNeedsDisplay];
				break;
			}
			case 2:
			{
				[self randomizeQuad:m_quadIndex];
				mojoView *pView = (mojoView *)self.view;
				[pView setNeedsDisplay];
			}
		}
	}
}


static bool s_cameraPicture = false;


int loadTime = 0;
- (void)viewDidLoad 
{
	if (loadTime == 1) {
		return;
	}
	loadTime = 1;
	[super viewDidLoad];
	
	NSLog(@"=====");
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		//init picker
		imagePicker = [[UIImagePickerController alloc] init];
		imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		imagePicker.delegate = self;
    
	}
	
	m_isImageOnceLoaded = false;
	doScale = false;
	isInverted = false;
	m_quadIndex = 0;
	isPortrait = true;	
	isSaveToAlbum = false;
	m_viewState = 1;
	workerThread = nil;
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		numberMode = 9;
	} else {
		numberMode = 4;
	}
	
	
	
	
	//[self setWidgetGeometry];
	[self setViewState];
	
	
	
	mojoView *pView = (mojoView *)self.view;
	
#ifdef SUBVIEW
	s_mySubView = [[UIView alloc] initWithFrame:CGRectMake(0, TOOLBAR_OFFSET_HEIGHT,320, 480-TOOLBAR_OFFSET_HEIGHT)];
	[pView addSubview:s_mySubView];
	[pView sendSubviewToBack:s_mySubView];
#endif
	
	[pView setMojoViewController:self];
	
	//theLock = [[NSRecursiveLock alloc] init];
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 40)];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];	
	
	//baiwei add for ipad rotate
	//[self willAnimateRotationToInterfaceOrientation:initInterfaceOrientation duration:1];
	
	/*
	 // Get the main bundle for the app
	 CFBundleRef mainBundle;
	 mainBundle = CFBundleGetMainBundle ();
	 
	 // Get the URL to the sound file to play
	 soundFileURLRef  =	CFBundleCopyResourceURL (
	 mainBundle,
	 CFSTR ("tap"),
	 CFSTR ("aif"),
	 NULL
	 );
	 
	 // Create a system sound object representing the sound file
	 AudioServicesCreateSystemSoundID (
	 soundFileURLRef,
	 &soundFileObject
	 );
	 
	 */
	
	//[self getDeviceName];
	
	
	
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
	
}

- (void)checkTimeOut:(id)sender
{
	[locationManager stopUpdatingLocation];
	locationManager.delegate = nil;
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs removeObjectForKey:@"latitude"];
	[prefs removeObjectForKey:@"longitude"];
}

- (void)animationWillStart:(NSString*)animationID context:(void*)context
{
	
}

- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	//	[self setWidgetGeometry];
}


- (void) animationDidStopAndRender:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	[self startRenderBackground:true image:nil clearAlpha:false];
}


static void scaleWidgetView(UIView *pView, float xScale, float yScale)
{
	CGRect r = pView.frame;
	float originX = r.origin.x;
	float originY = r.origin.y;
	float width = r.size.width;
	float height = r.size.height;
	float centerX = originX + width*0.5;
	float centerY = originY + height*0.5;
	
	width /= xScale;
	height /= yScale;
	
	pView.frame = CGRectMake(centerX - width*0.5, centerY - height*0.5, width, height);
}

- (void)setWidgetGeometry
{
	float rotate = 0.f;
	if(!isPortrait)
	{
		if(isInverted) { //left
			rotate = M_PI/2.0;
			
			//self.toolbarView.frame = CGRectMake(0, 0, 1024, 768);
			//[self.toolbarView  setImage:[UIImage imageNamed:@"backcolor_left.png"]];
			//self.toolbarView.frame = CGRectMake(0, 0, 768, 1024);
		}
		else { //rgiht
			//self.toolbarView.frame = CGRectMake(0, 0, 1024, 768);
			//[self.toolbarView  setImage:[UIImage imageNamed:@"backcolor_right.png"]];
			//self.toolbarView.frame = CGRectMake(0, 0, 768, 1024);
			
			rotate = -M_PI/2.0;
		}
	}
	else
	{
		if(isInverted) { //down
			//[self.toolbarView  setImage:[UIImage imageNamed:@"backcolor_down.png"]];
			//self.toolbarView.frame = CGRectMake(0, 0, 768, 1024);
			
			rotate = M_PI;
		} else { //up
			//[self.toolbarView  setImage:[UIImage imageNamed:@"backcolor_up.png"]];
			//self.toolbarView.frame = CGRectMake(0, 0, 768, 1024);
			
			rotate = 0.f;
		}
		
	}
	
	//UIImageView *imageViewArray[] = {bottomRightView, topRightView, bottomLeftView, topLeftView};
	//	UIButton *button_imageViewArray[] = {button_bottomRightView, button_topRightView, button_bottomLeftView, button_topLeftView};
	
	UIImageView *imageViewArray[] = {topLeftView, topRightView, bottomLeftView, bottomRightView, topMiddleView, middleLeftView, middleMiddleView, middleRightView, bottomMiddleView};
	UIButton *button_imageViewArray[] = {button_topLeftView, button_topRightView, button_bottomLeftView,  button_bottomRightView,  button_topMiddleView, button_middleLeftView, button_middleMiddleView, button_middleRightView, button_bottomMiddleView};
	
	//	UIImageView *imageViewArray[] = {topLeftView, topMiddleView, topRightView, middleLeftView, middleMiddleView, middleRightView, bottomLeftView, bottomMiddleView, bottomRightView };
	//	UIButton *button_imageViewArray[] = {button_topLeftView, button_topMiddleView, button_topRightView, button_middleLeftView, button_middleMiddleView, button_middleRightView, button_bottomLeftView,  button_bottomMiddleView, button_bottomRightView};
	
	if(numberMode == 4)
	{
		for(int i=0; i<9; ++i)
		{
			[imageViewArray[i]  setHidden:YES];
			
		}
		
		for(int i=0; i<4; ++i)
		{
			
			
			[imageViewArray[i]  setHidden:NO];
			//			[button_imageViewArray[i]  setHidden:NO];
			//[button_imageViewArray[i]  setHidden: YES ];
		}
		
	}
	
	else if (numberMode == 9) {
		for(int i=0; i<9; ++i)
		{
			[imageViewArray[i]  setHidden:NO];
			//			[button_imageViewArray[i]  setHidden:NO];
			//[button_imageViewArray[i]  setHidden: YES ];
		}
	}
	
	else
	{
		for(int i=0; i<9; ++i)
		{
			[imageViewArray[i]  setHidden:YES];
			
		}
		
		for(int i=0; i<9; ++i)
		{
			[imageViewArray[i]  setHidden: i!=m_quadIndex ? YES : NO ];
			//[button_imageViewArray[i]  setHidden: YES ];
		}
	}
	
	float width, height;
	
	
	CGAffineTransform m = CGAffineTransformMakeRotation(rotate);
	if(numberMode == 4)
	{
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		{
			
			
			if(isPortrait)
			{
				width = (768 - 3*BORDER_SIZE)/2;
				height = (1024 - (TOOLBAR_OFFSET_HEIGHT + 3*BORDER_SIZE))/2;
				
				if(isInverted) {//down
					topLeftView.frame = CGRectMake(BORDER_SIZE, BORDER_SIZE, width, height);
					topRightView.frame = CGRectMake(width+2*BORDER_SIZE, BORDER_SIZE, width, height);
					bottomLeftView.frame = CGRectMake(BORDER_SIZE, height+BORDER_SIZE*2, width, height);
					bottomRightView.frame = CGRectMake(width+2*BORDER_SIZE, height+BORDER_SIZE*2, width, height);
				} else { //up
					topLeftView.frame = CGRectMake(BORDER_SIZE, TOOLBAR_OFFSET_HEIGHT+BORDER_SIZE, width, height);
					topRightView.frame = CGRectMake(width+2*BORDER_SIZE, TOOLBAR_OFFSET_HEIGHT+BORDER_SIZE, width, height);
					bottomLeftView.frame = CGRectMake(BORDER_SIZE, height+TOOLBAR_OFFSET_HEIGHT+BORDER_SIZE*2, width, height);
					bottomRightView.frame = CGRectMake(width+2*BORDER_SIZE, height+TOOLBAR_OFFSET_HEIGHT+BORDER_SIZE*2, width, height);
				}
			}
			else
			{
				width = (768 - (TOOLBAR_OFFSET_HEIGHT + 3*BORDER_SIZE))/2;
				height = (1024 - 3*BORDER_SIZE)/2;
				
				if(isInverted) { //left
					topLeftView.frame = CGRectMake(BORDER_SIZE, BORDER_SIZE, width, height);
					topRightView.frame = CGRectMake(width+2*BORDER_SIZE, BORDER_SIZE, width, height);
					bottomLeftView.frame = CGRectMake(BORDER_SIZE, height+BORDER_SIZE*2, width, height);
					bottomRightView.frame = CGRectMake(width+2*BORDER_SIZE, height+BORDER_SIZE*2, width, height);
				} else { //right
					topLeftView.frame = CGRectMake(TOOLBAR_OFFSET_HEIGHT+BORDER_SIZE, BORDER_SIZE, width, height);
					topRightView.frame = CGRectMake(TOOLBAR_OFFSET_HEIGHT+width+2*BORDER_SIZE, BORDER_SIZE, width, height);
					bottomLeftView.frame = CGRectMake(TOOLBAR_OFFSET_HEIGHT+BORDER_SIZE, height+BORDER_SIZE*2, width, height);
					bottomRightView.frame = CGRectMake(TOOLBAR_OFFSET_HEIGHT+width+2*BORDER_SIZE, height+BORDER_SIZE*2, width, height);
					
					
					//topMiddleView.frame = CGRectMake(TOOLBAR_OFFSET_HEIGHT+width+2*BORDER_SIZE, BORDER_SIZE, width, height);					
					//					middleLeftView.frame = CGRectMake(TOOLBAR_OFFSET_HEIGHT+BORDER_SIZE, height +BORDER_SIZE*2, width, height);
					//					middleMiddleView.frame = CGRectMake(TOOLBAR_OFFSET_HEIGHT+width+2*BORDER_SIZE, height+BORDER_SIZE*2, width, height);
					//					middleRightView.frame = CGRectMake(TOOLBAR_OFFSET_HEIGHT+2*width+3*BORDER_SIZE, height+BORDER_SIZE*2, width, height);
					//					bottomMiddleView.frame = CGRectMake(TOOLBAR_OFFSET_HEIGHT+width+2*BORDER_SIZE, 2*height+BORDER_SIZE*3, width, height);
				}
				
			}
			
			topRightView.transform = m;
			topMiddleView.transform = m;
			topLeftView.transform = m;
			middleRightView.transform = m;
			middleMiddleView.transform = m;
			middleLeftView.transform = m;
			bottomRightView.transform = m;
			bottomMiddleView.transform = m;
			bottomLeftView.transform = m;
			
		}
		else
		{
			width = (320 - 3*BORDER_SIZE)/2;
			height = (480 - (TOOLBAR_OFFSET_HEIGHT + 3*BORDER_SIZE))/2;
			
			topLeftView.frame = CGRectMake(BORDER_SIZE, TOOLBAR_OFFSET_HEIGHT+BORDER_SIZE, width, height);
			topRightView.frame = CGRectMake(width+2*BORDER_SIZE, TOOLBAR_OFFSET_HEIGHT+BORDER_SIZE, width, height);
			bottomLeftView.frame = CGRectMake(BORDER_SIZE, height+TOOLBAR_OFFSET_HEIGHT+BORDER_SIZE*2, width, height);
			bottomRightView.frame = CGRectMake(width+2*BORDER_SIZE, height+TOOLBAR_OFFSET_HEIGHT+BORDER_SIZE*2, width, height);
			
			topRightView.transform = m;
			bottomRightView.transform = m;
			topLeftView.transform = m;
			bottomLeftView.transform = m;
		}
		
	}
	
	else if (numberMode == 9) {
		
		if(isPortrait)
		{
			width = (768 - 4*BORDER_SIZE)/3;
			height = (1024 - (TOOLBAR_OFFSET_HEIGHT + 4*BORDER_SIZE))/3;
			
			if(isInverted) {//down
				topLeftView.frame = CGRectMake(BORDER_SIZE, BORDER_SIZE, width, height);
				topMiddleView.frame = CGRectMake(width+2*BORDER_SIZE, BORDER_SIZE, width, height);
				topRightView.frame = CGRectMake(2*width+3*BORDER_SIZE, BORDER_SIZE, width, height);
				
				middleLeftView.frame = CGRectMake(BORDER_SIZE, height+BORDER_SIZE*2, width, height);
				middleMiddleView.frame = CGRectMake(width+2*BORDER_SIZE, height+BORDER_SIZE*2, width, height);
				middleRightView.frame = CGRectMake(2*width+3*BORDER_SIZE, height+BORDER_SIZE*2, width, height);
				
				bottomLeftView.frame = CGRectMake(BORDER_SIZE, 2*height+BORDER_SIZE*3, width, height);
				bottomMiddleView.frame = CGRectMake(width+2*BORDER_SIZE, 2*height+BORDER_SIZE*3, width, height);
				bottomRightView.frame = CGRectMake(2*width+3*BORDER_SIZE, 2*height+BORDER_SIZE*3, width, height);
			} else { //up
				topLeftView.frame = CGRectMake(BORDER_SIZE, TOOLBAR_OFFSET_HEIGHT+BORDER_SIZE, width, height);
				topMiddleView.frame = CGRectMake(width+2*BORDER_SIZE, TOOLBAR_OFFSET_HEIGHT+BORDER_SIZE, width, height);
				topRightView.frame = CGRectMake(2*width+3*BORDER_SIZE, TOOLBAR_OFFSET_HEIGHT+BORDER_SIZE, width, height);
				
				middleLeftView.frame = CGRectMake(BORDER_SIZE, height + TOOLBAR_OFFSET_HEIGHT+BORDER_SIZE*2, width, height);
				middleMiddleView.frame = CGRectMake(width+2*BORDER_SIZE, height + TOOLBAR_OFFSET_HEIGHT+BORDER_SIZE*2, width, height);
				middleRightView.frame = CGRectMake(2*width+3*BORDER_SIZE, height + TOOLBAR_OFFSET_HEIGHT+BORDER_SIZE*2, width, height);
				
				bottomLeftView.frame = CGRectMake(BORDER_SIZE, 2*height+TOOLBAR_OFFSET_HEIGHT+BORDER_SIZE*3, width, height);
				bottomMiddleView.frame = CGRectMake(width+2*BORDER_SIZE, 2*height+TOOLBAR_OFFSET_HEIGHT+BORDER_SIZE*3, width, height);
				bottomRightView.frame = CGRectMake(2*width+3*BORDER_SIZE, 2*height+TOOLBAR_OFFSET_HEIGHT+BORDER_SIZE*3, width, height);
			}
		}
		else
		{
			
			
			width = (768 - (TOOLBAR_OFFSET_HEIGHT + 4*BORDER_SIZE))/3;
			height = (1024 - 4*BORDER_SIZE)/3;
			
			if(isInverted) { //left
				topLeftView.frame = CGRectMake(BORDER_SIZE, BORDER_SIZE, width, height);
				topMiddleView.frame = CGRectMake(width+2*BORDER_SIZE, BORDER_SIZE, width, height);
				topRightView.frame = CGRectMake(2*width+3*BORDER_SIZE, BORDER_SIZE, width, height);
				
				middleLeftView.frame = CGRectMake(BORDER_SIZE, height+BORDER_SIZE*2, width, height);
				middleMiddleView.frame = CGRectMake(width+2*BORDER_SIZE, height+BORDER_SIZE*2, width, height);
				middleRightView.frame = CGRectMake(2*width+3*BORDER_SIZE, height+BORDER_SIZE*2, width, height);
				
				bottomLeftView.frame = CGRectMake(BORDER_SIZE, 2*height+BORDER_SIZE*3, width, height);
				bottomMiddleView.frame = CGRectMake(width+2*BORDER_SIZE, 2*height+BORDER_SIZE*3, width, height);
				bottomRightView.frame = CGRectMake(2*width+3*BORDER_SIZE, 2*height+BORDER_SIZE*3, width, height);
			} else { //right
				
				topLeftView.frame = CGRectMake(TOOLBAR_OFFSET_HEIGHT+BORDER_SIZE, BORDER_SIZE, width, height);
				topMiddleView.frame = CGRectMake(TOOLBAR_OFFSET_HEIGHT+width+2*BORDER_SIZE, BORDER_SIZE, width, height);
				topRightView.frame = CGRectMake(TOOLBAR_OFFSET_HEIGHT+2*width+3*BORDER_SIZE, BORDER_SIZE, width, height);
				
				middleLeftView.frame = CGRectMake(TOOLBAR_OFFSET_HEIGHT+BORDER_SIZE, height +BORDER_SIZE*2, width, height);
				middleMiddleView.frame = CGRectMake(TOOLBAR_OFFSET_HEIGHT+width+2*BORDER_SIZE, height+BORDER_SIZE*2, width, height);
				middleRightView.frame = CGRectMake(TOOLBAR_OFFSET_HEIGHT+2*width+3*BORDER_SIZE, height+BORDER_SIZE*2, width, height);
				
				bottomLeftView.frame = CGRectMake(TOOLBAR_OFFSET_HEIGHT+BORDER_SIZE, 2*height+BORDER_SIZE*3, width, height);
				bottomMiddleView.frame = CGRectMake(TOOLBAR_OFFSET_HEIGHT+width+2*BORDER_SIZE, 2*height+BORDER_SIZE*3, width, height);
				bottomRightView.frame = CGRectMake(TOOLBAR_OFFSET_HEIGHT+2*width+3*BORDER_SIZE, 2*height+BORDER_SIZE*3, width, height);
				
				
			}
			
		}
		
		topRightView.transform = m;
		topMiddleView.transform = m;
		topLeftView.transform = m;
		middleRightView.transform = m;
		middleMiddleView.transform = m;
		middleLeftView.transform = m;
		bottomRightView.transform = m;
		bottomMiddleView.transform = m;
		bottomLeftView.transform = m;
		
	}
	
	else //1up
	{
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		{
			
			if(isPortrait)
			{
				width = 768;
				height = 1024 - TOOLBAR_OFFSET_HEIGHT;
				
				if(isInverted) {//down
					button_imageViewArray[m_quadIndex].frame = CGRectMake(0, 0, width, height);
					imageViewArray[m_quadIndex].frame = CGRectMake(0, 0, width, height);
				} else { //up
					button_imageViewArray[m_quadIndex].frame = CGRectMake(0, TOOLBAR_OFFSET_HEIGHT, width, height);
					imageViewArray[m_quadIndex].frame = CGRectMake(0, TOOLBAR_OFFSET_HEIGHT, width, height);
				}
			}
			else
			{
				width = 768 - TOOLBAR_OFFSET_HEIGHT;
				height = 1024;
				
				if(isInverted) { //left
					button_imageViewArray[m_quadIndex].frame = CGRectMake(0, 0, width, height);
					imageViewArray[m_quadIndex].frame = CGRectMake(0, 0, width, height);
				} else { //right
					button_imageViewArray[m_quadIndex].frame = CGRectMake(TOOLBAR_OFFSET_HEIGHT, 0, width, height);
					imageViewArray[m_quadIndex].frame = CGRectMake(TOOLBAR_OFFSET_HEIGHT, 0, width, height);
				}
				
			}
		}
		else
		{
			width = 320;
			height = 480 - TOOLBAR_OFFSET_HEIGHT;
			
			button_imageViewArray[m_quadIndex].frame = CGRectMake(0, TOOLBAR_OFFSET_HEIGHT, width, height);
			imageViewArray[m_quadIndex].frame = CGRectMake(0, TOOLBAR_OFFSET_HEIGHT, width, height);
		}
		
		
		
		for (int i=0; i<9; i++)
		{
			// Still need to apply transform to all the hidden views to ensure when it pops back out, everything is fine.
			//
			imageViewArray[i].transform = m;
			button_imageViewArray[i].transform = m;
		}
		
		[[imageViewArray[m_quadIndex] superview] bringSubviewToFront: imageViewArray[m_quadIndex]];
		[[button_imageViewArray[m_quadIndex] superview] bringSubviewToFront: button_imageViewArray[m_quadIndex]];
		
#ifdef SUBVIEW
		if (s_mySubView)
		{
			// Adjust for device orientation change for correct pop up orientation
			//
			s_mySubView.transform = m;
			s_mySubView.frame = CGRectMake(0, TOOLBAR_OFFSET_HEIGHT, 320, 480-TOOLBAR_OFFSET_HEIGHT);
			[[s_mySubView superview] sendSubviewToBack: s_mySubView];
		}
#endif			
		// To ensure any existing spinner continue if rotate orientation
		//
		[[spinner superview] bringSubviewToFront:spinner];
	}
	
	// for test
	//UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
//													message:@"test" 
//												   delegate:self
//										  cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
//	[alert show];
//	[alert release];
	
	button_save.transform = m;
	button_back.transform = m;
	button_camera.transform = m;
	button_library.transform = m;
	button_refresh.transform = m;
	button_refresh2.transform = m;
	
	button_four.transform = m;
	button_nine.transform = m;
	
	//baiwei add for ipad bg rotate
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		toolbarView.transform = m;
		
		
		if(!isPortrait)
		{
			if(isInverted) { //left
				[self.toolbarView  setImage:[UIImage imageNamed:@"backcolor_left.png"]];
				self.toolbarView.frame = CGRectMake(0, 0, 768, 1024);
			}
			else { //rgiht
				[self.toolbarView  setImage:[UIImage imageNamed:@"backcolor_left.png"]];
				self.toolbarView.frame = CGRectMake(0, 0, 768, 1024);
				
			}
		}
		else
		{
			if(isInverted) { //down
				[self.toolbarView  setImage:[UIImage imageNamed:@"backcolor_up.png"]];
				self.toolbarView.frame = CGRectMake(0, 0, 768, 1024);
				
			} else { //up
				[self.toolbarView  setImage:[UIImage imageNamed:@"backcolor_up.png"]];
				self.toolbarView.frame = CGRectMake(0, 0, 768, 1024);
				
			}
			
		}
	}
	
	
	if(doScale)
	{
		float yScale = width/height;
		float xScale = height/width;
		
		if(numberMode == 4)
		{
			
			scaleWidgetView(topRightView, xScale, yScale);
			scaleWidgetView(topMiddleView, xScale, yScale);
			scaleWidgetView(topLeftView, xScale, yScale);
			scaleWidgetView(middleRightView, xScale, yScale);
			scaleWidgetView(middleMiddleView, xScale, yScale);
			scaleWidgetView(middleLeftView, xScale, yScale);
			scaleWidgetView(bottomRightView, xScale, yScale);
			scaleWidgetView(bottomMiddleView, xScale, yScale);
			scaleWidgetView(bottomLeftView, xScale, yScale);
		}
		
		else if (numberMode == 9) {
			scaleWidgetView(topRightView, xScale, yScale);
			scaleWidgetView(topMiddleView, xScale, yScale);
			scaleWidgetView(topLeftView, xScale, yScale);
			scaleWidgetView(middleRightView, xScale, yScale);
			scaleWidgetView(middleMiddleView, xScale, yScale);
			scaleWidgetView(middleLeftView, xScale, yScale);
			scaleWidgetView(bottomRightView, xScale, yScale);
			scaleWidgetView(bottomMiddleView, xScale, yScale);
			scaleWidgetView(bottomLeftView, xScale, yScale);
			
			
		}
		
		else
		{
			scaleWidgetView(imageViewArray[m_quadIndex], xScale, yScale);
			//scaleWidgetView(button_imageViewArray[m_quadIndex], xScale, yScale);
		}
	}
	
	
	mojoAppDelegate *app = (mojoAppDelegate*)[[UIApplication sharedApplication] delegate];
	[app roteProgressView:m];
    
    //baiwei add for share progress rotate
    if (shareProgressView != nil) {
        shareProgressView.transform = m;
    }
    
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration 
{
	if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
		const float violence = 1.5;
		static BOOL beenhere;
		BOOL shake = FALSE;
		static int numTries = 0;
		
		
		if (!beenhere) 
		{
			beenhere = TRUE;
			if (acceleration.x > violence * 1.5 || acceleration.x < (-1.5* violence))
				shake = TRUE;
			if (acceleration.y > violence * 2 || acceleration.y < (-2 * violence))
				shake = TRUE;
			if (acceleration.z > violence * 3 || acceleration.z < (-3 * violence))
				shake = TRUE;
			if(shake)
				numTries = 0;
			if (shake && ![workerThread isExecuting]) 
			{
				//			[self randomizeQuad index];
				mojoView *pView = (mojoView *)self.view;
				[pView setNeedsDisplay];	
				return;
			} 
		}
		
		beenhere = FALSE;
		
		// TODO - Other angles
		bool doTransform = false;
		const float kMinValue = 0.5f;
		const float kMaxValue = 1.f-kMinValue;
		const int NUM_TRIES = 4;
		
		if(fabs(acceleration.x) >= kMaxValue && fabs(acceleration.y) <= kMinValue && isPortrait)
		{
			numTries++;
			if(numTries>NUM_TRIES)
			{
				doTransform = true;
				isPortrait = false;
				isInverted = acceleration.x<0.f;
			}
		}
		else if(fabs(acceleration.y) >= kMaxValue  && fabs(acceleration.x) <= kMinValue && !isPortrait)
		{
			numTries++;
			if(numTries>NUM_TRIES)
			{
				doTransform = true;
				isPortrait = true;
				isInverted = acceleration.y>0.f;
			}
		}
		
		if(doTransform)
		{
			numTries = 0;
			[UIView beginAnimations:@"Rotate" context:nil];
			
			[UIView  setAnimationDelegate:self];
			
			[UIView  setAnimationCurve: UIViewAnimationCurveEaseInOut];
			[UIView  setAnimationDuration:(NSTimeInterval)0.4];
			
			[UIView setAnimationDidStopSelector:@selector (animationDidStop:finished:context:) ];
			[UIView  setAnimationWillStartSelector:@selector (animationWillStart:context:) ];
			
			doScale = true;
			[self setWidgetGeometry];
			doScale = false;
			
			[UIView commitAnimations];		
			return;
		}
		
	}
	
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		//baiwei add for ipad rotate
		//[self willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:0];
		
		if (interfaceOrientation == UIInterfaceOrientationPortrait)
		{
			isPortrait = true;
			isInverted = false;			
		} else if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
			isPortrait = true;
			isInverted = true;
		} else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
			isPortrait = false;
			isInverted = true;
		} else {
			isPortrait = false;
			isInverted = false;
		}
		
		//if(imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera) {
		//			return NO;
		//		} else {
		//			return NO;
		//		}
		
		//if (s_isCameraPick == true) {
		//			//s_isCameraPick = false;
		//			return NO;
		//		} else {
		//			
		//			return YES;
		//		}
		
		return YES;
		
		
		
	} else {
		return NO;
	}
	
}

- (void)viewWillAppear:(BOOL)animated{
	//if (s_isCameraPick == true) {
	//		return;
	//	}
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0];
        [self didRotateFromInterfaceOrientation:self.interfaceOrientation];
	}
}



- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		if (nowInterfaceOrientation == UIInterfaceOrientationPortrait) {
            if (numberMode == 1) {
                button_back.hidden = NO;
                button_save.hidden = NO;
                button_refresh2.hidden = NO;
                button_refresh.hidden = NO;

            } else if (numberMode == 4 || numberMode == 9) {
                button_library.hidden = NO;
                button_camera.hidden = NO;
                button_four.hidden = NO;
                button_nine.hidden = NO;
                button_refresh2.hidden = NO;
                button_refresh.hidden = NO;

            }
            
            [button_library setFrame:CGRectMake(0, -2, button_library.frame.size.width, button_library.frame.size.height)];
			[button_back setFrame:CGRectMake(button_library.frame.origin.x, button_library.frame.origin.y, button_back.frame.size.width, button_back.frame.size.height)];
			[button_save setFrame:CGRectMake(360, button_library.frame.origin.y, button_save.frame.size.width, button_save.frame.size.height)];
			
			[button_camera setFrame:CGRectMake(232, button_library.frame.origin.y, button_camera.frame.size.width, button_camera.frame.size.height)];
			[button_refresh setFrame:CGRectMake(720, button_library.frame.origin.y, button_refresh.frame.size.width, button_refresh.frame.size.height)];
			
			[button_four setFrame:CGRectMake(465, button_library.frame.origin.y, button_four.frame.size.width, button_four.frame.size.height)];
			[button_nine setFrame:CGRectMake(505, button_library.frame.origin.y, button_nine.frame.size.width, button_nine.frame.size.height)];
			
			
			[button_refresh2 setFrame:CGRectMake(720, button_library.frame.origin.y, button_refresh2.frame.size.width, button_refresh2.frame.size.height)];

        } else if (nowInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            if (numberMode == 1) {
                button_back.hidden = NO;
                button_save.hidden = NO;
                button_refresh2.hidden = NO;
                button_refresh.hidden = NO;

            } else if (numberMode == 4 || numberMode == 9) {
                button_library.hidden = NO;
                button_camera.hidden = NO;
                button_four.hidden = NO;
                button_nine.hidden = NO;
                button_refresh2.hidden = NO;
                button_refresh.hidden = NO;

            }
            
            [button_library setFrame:CGRectMake(720, 978, button_library.frame.size.width, button_library.frame.size.height)];
			[button_back setFrame:CGRectMake(button_library.frame.origin.x, button_library.frame.origin.y, button_back.frame.size.width, button_back.frame.size.height)];
			[button_save setFrame:CGRectMake(360, button_library.frame.origin.y, button_save.frame.size.width, button_save.frame.size.height)];
			
			[button_camera setFrame:CGRectMake(486, button_library.frame.origin.y, button_camera.frame.size.width, button_camera.frame.size.height)];
			[button_refresh setFrame:CGRectMake(0, button_library.frame.origin.y, button_refresh.frame.size.width, button_refresh.frame.size.height)];
			
			[button_four setFrame:CGRectMake(253, button_library.frame.origin.y, button_four.frame.size.width, button_four.frame.size.height)];
			[button_nine setFrame:CGRectMake(213, button_library.frame.origin.y, button_nine.frame.size.width, button_nine.frame.size.height)];
			
			[button_refresh2 setFrame:CGRectMake(0, button_library.frame.origin.y, button_refresh2.frame.size.width, button_refresh2.frame.size.height)];
        } else if (nowInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            if (numberMode == 1) {
                button_back.hidden = NO;
                button_save.hidden = NO;
                button_refresh2.hidden = NO;
                button_refresh.hidden = NO;

            } else if (numberMode == 4 || numberMode == 9) {
                button_library.hidden = NO;
                button_camera.hidden = NO;
                button_four.hidden = NO;
                button_nine.hidden = NO;
                button_refresh2.hidden = NO;
                button_refresh.hidden = NO;

            }
            
            [button_library setFrame:CGRectMake(723, 5, button_library.frame.size.width, button_library.frame.size.height)];
			[button_back setFrame:CGRectMake(button_library.frame.origin.x, button_library.frame.origin.y, button_back.frame.size.width, button_back.frame.size.height)];
			[button_save setFrame:CGRectMake(button_library.frame.origin.x, 500, button_save.frame.size.width, button_save.frame.size.height)];
			
			[button_camera setFrame:CGRectMake(button_library.frame.origin.x, 317, button_camera.frame.size.width, button_camera.frame.size.height)];
			
			[button_four setFrame:CGRectMake(button_library.frame.origin.x, 635, button_four.frame.size.width, button_four.frame.size.height)];
			[button_nine setFrame:CGRectMake(button_library.frame.origin.x, 675, button_nine.frame.size.width, button_nine.frame.size.height)];
			
			[button_refresh setFrame:CGRectMake(button_library.frame.origin.x, 970, button_refresh.frame.size.width, button_refresh.frame.size.height)];
			
			[button_refresh2 setFrame:CGRectMake(button_library.frame.origin.x, 970, button_refresh2.frame.size.width, button_refresh2.frame.size.height)];
        } else {
            if (numberMode == 1) {
                button_back.hidden = NO;
                button_save.hidden = NO;
                button_refresh2.hidden = NO;
                button_refresh.hidden = NO;

            } else if (numberMode == 4 || numberMode == 9) {
                button_library.hidden = NO;
                button_camera.hidden = NO;
                button_four.hidden = NO;
                button_nine.hidden = NO;
                button_refresh2.hidden = NO;
                button_refresh.hidden = NO;

            }
            
            [button_library setFrame:CGRectMake(-3, 970, button_library.frame.size.width, button_library.frame.size.height)];
			[button_back setFrame:CGRectMake(button_library.frame.origin.x, button_library.frame.origin.y, button_back.frame.size.width, button_back.frame.size.height)];
			[button_save setFrame:CGRectMake(button_library.frame.origin.x, 500, button_save.frame.size.width, button_save.frame.size.height)];
			
			[button_camera setFrame:CGRectMake(button_library.frame.origin.x, 657, button_camera.frame.size.width, button_camera.frame.size.height)];
			[button_refresh setFrame:CGRectMake(button_library.frame.origin.x, 5, button_refresh.frame.size.width, button_refresh.frame.size.height)];
			[button_refresh2 setFrame:CGRectMake(button_library.frame.origin.x, 5, button_refresh2.frame.size.width, button_refresh2.frame.size.height)];
			
			[button_four setFrame:CGRectMake(button_library.frame.origin.x, 338, button_four.frame.size.width, button_four.frame.size.height)];
			[button_nine setFrame:CGRectMake(button_library.frame.origin.x, 298, button_nine.frame.size.width, button_nine.frame.size.height)];
        }
        
        if (self.saveSharePopoverController.popoverVisible == YES) {
			
			
			[self.saveSharePopoverController presentPopoverFromRect:self.button_save.frame
															 inView:self.view
										   permittedArrowDirections:UIPopoverArrowDirectionAny
														   animated:NO];
			
			self.saveSharePopoverController.popoverContentSize = CGSizeMake(320, 480);
			
			
			//self.saveSharePopoverController.contentSizeForViewInPopover = CGSizeMake(320, 1000);
			
		}
        
    }
            
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	nowInterfaceOrientation = toInterfaceOrientation;
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		if (toInterfaceOrientation == UIInterfaceOrientationPortrait)
		{
			isPortrait = true;
			isInverted = false;
            
            if (numberMode == 1) {
                button_back.hidden = YES;
                button_save.hidden = YES;
                button_refresh2.hidden = YES;
                button_refresh.hidden = YES;
            } else if (numberMode == 4 || numberMode == 9) {
                button_library.hidden = YES;
                button_camera.hidden = YES;
                button_four.hidden = YES;
                button_nine.hidden = YES;
                button_refresh2.hidden = YES;
                button_refresh.hidden = YES;
            }


			
		} else if (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
			isPortrait = true;
			isInverted = true;
            
            if (numberMode == 1) {
                button_back.hidden = YES;
                button_save.hidden = YES;
                button_refresh2.hidden = YES;
                button_refresh.hidden = YES;

            } else if (numberMode == 4 || numberMode == 9) {
                button_library.hidden = YES;
                button_camera.hidden = YES;
                button_four.hidden = YES;
                button_nine.hidden = YES;
                button_refresh2.hidden = YES;
                button_refresh.hidden = YES;

            }
            

		} else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
			isPortrait = false;
			isInverted = true;
            
            if (numberMode == 1) {
                button_back.hidden = YES;
                button_save.hidden = YES;
                button_refresh2.hidden = YES;
                button_refresh.hidden = YES;

            } else if (numberMode == 4 || numberMode == 9) {
                button_library.hidden = YES;
                button_camera.hidden = YES;
                button_four.hidden = YES;
                button_nine.hidden = YES;
                button_refresh2.hidden = YES;
                button_refresh.hidden = YES;

            }
            

		} else {
			isPortrait = false;
			isInverted = false;
            
            if (numberMode == 1) {
                button_back.hidden = YES;
                button_save.hidden = YES;
                button_refresh2.hidden = YES;
                button_refresh.hidden = YES;

            } else if (numberMode == 4 || numberMode == 9) {
                button_library.hidden = YES;
                button_camera.hidden = YES;
                button_four.hidden = YES;
                button_nine.hidden = YES;
                button_refresh2.hidden = YES;
                button_refresh.hidden = YES;

            }
            

		}

		
		doScale = true;
		[self setWidgetGeometry];
		doScale = false;
		
		
		if (self.saveSharePopoverController.popoverVisible == YES) {
			
			
			[self.saveSharePopoverController presentPopoverFromRect:self.button_save.frame
															 inView:self.view
										   permittedArrowDirections:UIPopoverArrowDirectionAny
														   animated:NO];
			
			self.saveSharePopoverController.popoverContentSize = CGSizeMake(320, 480);
			
			
			//self.saveSharePopoverController.contentSizeForViewInPopover = CGSizeMake(320, 1000);
			
		}

		
		if (self.imagePickerPopover.popoverVisible == YES) {
		}

	}
}



- (void)didReceiveMemoryWarning 
{
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
	
#if 0
	for (int i=0; i<4; i++)
	{
		if (viewImageArray[i])
		{
			[viewImageArray[i] release];
			viewImageArray[i] = nil;
			isRefresh[i] = YES;
		}
	}
#endif
}



- (void)generateInputImages
{
	
	UIImage *image = s_loadedImage;
	int inputWidth = CGImageGetWidth( image.CGImage );
	int inputHeight = CGImageGetHeight( image.CGImage );
	
	//NSLog(@"%@", fullImage);
	
	//int retainCount1 = [fullImage retainCount];
	//	
	//	// FullSize
	//	if (fullImage!=nil)
	//	{
	//		[fullImage release];
	//		fullImage = nil;
	//	}
	
	[Utilities printAvailMemory];
	
	fullImage = [self createNewImage:&image imgWidth:inputWidth imgHeight:inputHeight imgParameter:-1];
	
	CGSize size2 = fullImage.size;
	NSLog(@"load image size: %f : %f", size2.width,size2.height);
	
	// add by Guno
	inputWidth = fullImageWidth = CGImageGetWidth( fullImage.CGImage );
	inputHeight = fullImageHeight = CGImageGetHeight( fullImage.CGImage );
	isFullImageLandscape = inputWidth > inputHeight;
	// end Guno
	
	
	//mojoView *pView = (mojoView *)self.view;
	
	//add by jack
	//	if(portraitImage != nil){
	//		fullImage = [Utilities imageFromFileCache:ORIGINAL_IMAGE_FILE_NAME];
	//	}
	//end add
	
	
	//UIImage *fullImage = [pView getFullImage];
	//	int inputWidth = CGImageGetWidth( fullImage.CGImage );
	//	int inputHeight = CGImageGetHeight( fullImage.CGImage );
	//int inputWidth = fullImageWidth;
	//	int inputHeight = fullImageHeight;
	//	
	int width1, height1;
	int width4, height4;
	int width9, height9;
	float offset = TOOLBAR_OFFSET_HEIGHT;
	float border = BORDER_SIZE;
	
	
	// Portrait
	float smallDisplayDimension = 320;
	float bigDisplayDimension = 480-offset;
	
	float xScale;
	float yScale;
	float scale;
	
	//add by Guno
	{
		smallDisplayDimension = 320 -border*3;
		bigDisplayDimension = 480-offset - border*3;
		
		smallDisplayDimension = smallDisplayDimension/2;
		bigDisplayDimension = bigDisplayDimension/2;
		
		xScale = float(smallDisplayDimension)/float(inputWidth);
		yScale = float(bigDisplayDimension)/float(inputHeight);
		scale = xScale < yScale ? xScale : yScale;
		width4 = (int)(float(scale*inputWidth) + 0.5f);
		height4 = (int)(float(scale*inputHeight) + 0.5f);
	}
	
	{
		smallDisplayDimension = 320 -border*4;
		bigDisplayDimension = 480-offset - border*4;
		
		smallDisplayDimension = smallDisplayDimension/3;
		bigDisplayDimension = bigDisplayDimension/3;
		
		xScale = float(smallDisplayDimension)/float(inputWidth);
		yScale = float(bigDisplayDimension)/float(inputHeight);
		scale = xScale < yScale ? xScale : yScale;
		width9 = (int)(float(scale*inputWidth) + 0.5f);
		height9 = (int)(float(scale*inputHeight) + 0.5f);
	}
	
	{
		smallDisplayDimension = 320;
		bigDisplayDimension = 480-offset;
		
		xScale = float(smallDisplayDimension)/float(inputWidth);
		yScale = float(bigDisplayDimension)/float(inputHeight);
		scale = xScale < yScale ? xScale : yScale;
		width1 = (int)(float(scale*inputWidth) + 0.5f);
		height1 = (int)(float(scale*inputHeight) + 0.5f);
	}
	//end Guno
	
	//baiwei add for ipad quality in 2011-5-13
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		//add by Guno
		width1 *= 2.0;
		height1 *= 2.0;
		width4 *= 1.5;
		height4 *= 1.5;
		width9 *= 1.5;
		height9 *= 1.5;
		//endGuno
	}
	else 
	{
		NSString* machine = [self getDeviceName];
		if (!( [machine hasPrefix:@"iPhone1,"] 
			  || [machine hasPrefix:@"iPhone2,"]
			  || [machine hasPrefix:@"iPod1,"]
			  || [machine hasPrefix:@"iPod2,"]			
			  ))
		{
			// For iPhone 4 or later and iTouch 4th generation and later
			width1 *= 1.5;
			height1 *= 1.5;
		}
	}
	
	//add by Guno
	if (portraitImage1 != nil)
		[portraitImage1 release];
	portraitImage1 = [self createNewImage:&fullImage imgWidth:width1 imgHeight:height1 imgParameter:-1];
	
	if (portraitImage4 != nil)
		[portraitImage4 release];
	portraitImage4 = [self createNewImage:&fullImage imgWidth:width4 imgHeight:height4 imgParameter:-1];
	
	if (portraitImage9 != nil)
		[portraitImage9 release];
	portraitImage9 = [self createNewImage:&fullImage imgWidth:width9 imgHeight:height9 imgParameter:-1];
	//end Guno
	
	switch (numberMode) {
		case 4:
			portraitImage = portraitImage4;
			break;
		case 9:
			portraitImage = portraitImage9;
			break;
		default:
			portraitImage = portraitImage1;
			break;
	}
	
	//#ifdef __DEBUG_PB__
	[Utilities cacheToFileFromImage:fullImage filename:ORIGINAL_IMAGE_FILE_NAME];
	[fullImage release];
	fullImage = nil;
	//#endif
}


- (double) getLimitResolution
{
	
	NSString* machine = [self getDeviceName];
	if ( [machine hasPrefix:@"iPhone1,"] || [machine hasPrefix:@"iPod1,"] || [machine hasPrefix:@"iPod2,"])
	{
		return 5100000;
	}
	else if ( [machine hasPrefix:@"iPhone2,"] || [machine hasPrefix:@"iPod3,"] || [machine hasPrefix:@"iPad1,"] || [machine hasPrefix:@"iPod4,"] )
	{
		return 12100000;		
	}
	else if ( [machine hasPrefix:@"iPhone3,"] || [machine hasPrefix:@"iPad2,"])
	{
		return 30100000;		
	}
	else
	{
		//High than iPhone4, or High than iPad2
		return 30100000;	
		
	}
	
}



#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	if (newLocation.horizontalAccuracy < 0) return;
    
	if (newLocation.horizontalAccuracy <= manager.desiredAccuracy)
	{
		NSLog(@"Location Found.");
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkTimeOut:) object:nil];
		
		[manager stopUpdatingLocation];
		manager.delegate = nil;
		
		
		double latitude = newLocation.coordinate.latitude;
		double longitude = newLocation.coordinate.longitude;
		
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		
		[prefs setObject:[NSNumber numberWithDouble:latitude] forKey:@"latitude"];
		[prefs setObject:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
		[prefs synchronize];
		
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSLog(@"Location Failed.");
	
	if ([error code] != kCLErrorLocationUnknown)
	{
		[manager stopUpdatingLocation];
		manager.delegate = nil;
		
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkTimeOut:) object:nil];
	}
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs removeObjectForKey:@"latitude"];
	[prefs removeObjectForKey:@"longitude"];
}

- (UIImage*) uncontrastiPhone4Image:(UIImage*)sourceImage{
	
	//LUT
	//iPhone4uncontrastLUT.png
	
	UIImage* lutImage = [UIImage imageNamed:@"iPhone4uncontrastLUT.png"];
	
	int theWidth = CGImageGetWidth(lutImage.CGImage);
	int theHeight = CGImageGetHeight(lutImage.CGImage);
	CFDataRef theData = CGDataProviderCopyData(CGImageGetDataProvider(lutImage.CGImage));
	int *m_data = (int *)CFDataGetBytePtr(theData);
	
	uint8_t *sourcR = (unsigned char *)&m_data[0];
	uint8_t *sourcG = sourcR+theWidth*4;
	uint8_t *sourcB = sourcG+theWidth*4;
	uint8_t *sourcA = sourcB+theWidth*4;
	
	int iPhone4LUT[256][4];
	
	if(theHeight != 4)return sourceImage;
	
	for(int i = 0; i < theWidth; i++){
	
		iPhone4LUT[i][0] = *sourcR;
		iPhone4LUT[i][1] = *sourcG;
		iPhone4LUT[i][2] = *sourcB;
		iPhone4LUT[i][3] = *sourcA;

		
	//	NSLog(@"R=%d, G=%d, B=%d, A=%d",*sourcR,*(sourcR+1),*(sourcB+2),*(sourcA+3));
//		NSLog(@"R=%d, G=%d, B=%d, A=%d",*sourcR,*sourcG,*sourcB,*sourcA);
//		
		sourcR+=4;
		sourcG+=4;
		sourcB+=4;
		sourcA+=4;
	}
	
	CFRelease(theData);
	
	
	int _width = CGImageGetWidth(sourceImage.CGImage);
	int _height = CGImageGetHeight(sourceImage.CGImage);	
	CFDataRef sourceData = CGDataProviderCopyData(CGImageGetDataProvider(sourceImage.CGImage));
	int *m_sourcedata = (int *)CFDataGetBytePtr(sourceData);
	uint8_t *sourceb = (unsigned char *)&m_sourcedata[0];
	

	uint8_t *poutb;
	uint8_t* pout;
	pout = poutb = (uint8_t *)malloc(_width * _height * 4);
    if (!poutb)
	{
		CFRelease(sourceData);
		return nil;
	}
	
	
	
	for(int i = 0; i < _height; i++){
		for(int i = 0; i < _width; i++){
			
			int pR = *sourceb++;
			int pG = *sourceb++;
			int pB = *sourceb++;
			int pA = *sourceb++;
			
			//NSLog(@"R=%d,G=%d,B=%d,A=%d",pR,pG,pB,pA);
			
			*poutb++ = iPhone4LUT[pR][0];
			*poutb++ = iPhone4LUT[pG][1];
			*poutb++ = iPhone4LUT[pB][2];
			*poutb++ = iPhone4LUT[pA][3];
		}
	}
	
	CFRelease(sourceData);
	
	CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(sourceImage.CGImage);
	
	[sourceImage release];
	
	CGContextRef context = CGBitmapContextCreate(pout, _width, _height, 8, _width*4, colorSpace, bitmapInfo);
	CGImageRef imageRef = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	free(pout); 

	
	UIImage* newImage = [[UIImage alloc] initWithCGImage:imageRef];
	CGImageRelease(imageRef);
	
	
	//UIImageWriteToSavedPhotosAlbum(newImage, self, nil, nil);
	
	return [newImage autorelease];
	
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	
	//UIInterfaceOrientation toInterfaceOrientation = self.interfaceOrientation;
	
	//baiwei add for imageMetadata
	UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	mojoAppDelegate *appDelegate = (mojoAppDelegate*)[[UIApplication sharedApplication]delegate];
	
	if ( picker.sourceType == UIImagePickerControllerSourceTypeCamera ) //from camera
	{
		float version = [[[UIDevice currentDevice] systemVersion] floatValue];
		if (version > 4.1) {
			appDelegate.imageMetadata = [info objectForKey:@"UIImagePickerControllerMediaMetadata"];
			
			NSMutableDictionary *GPS = [[NSMutableDictionary alloc]init];
			NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
			double latitude = [prefs doubleForKey: @"latitude"];
			double longitude = [prefs doubleForKey: @"longitude"];
			
			//[GPS setObject:@"126.603" forKey:@"ImgDirection"];
			//				[GPS setObject:@"T" forKey:@"ImgDirectionRef"];
			
			[GPS setObject:[NSNumber numberWithDouble:latitude] forKey:@"Latitude"];
			if (latitude > 0) {
				[GPS setObject:@"N" forKey:@"LatitudeRef"];
			} else {
				[GPS setObject:@"S" forKey:@"LatitudeRef"];
			}
			
			[GPS setObject:[NSNumber numberWithDouble:longitude] forKey:@"Longitude"];
			if (latitude > 0) {
				[GPS setObject:@"E" forKey:@"LongitudeRef"];
			} else {
				[GPS setObject:@"W" forKey:@"LongitudeRef"];
			}
			
			NSDate *date = [NSDate date];
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateFormat:@"HH:mm:ss"];
			NSString *dateString = [formatter stringFromDate:date];
			[formatter release];
			[GPS setObject:dateString forKey:@"TimeStamp"];
			
			[appDelegate.imageMetadata setObject:GPS forKey:@"{GPS}"];
			
			NSLog(@"imageMetadata2=%@", appDelegate.imageMetadata);
			
		} else {
			appDelegate.imageMetadata = nil;
		}
		
		
		if ([self isSaveCameraShot])
		{
			if (appDelegate.imageMetadata == nil) {
				UIImageWriteToSavedPhotosAlbum(originalImage, self, nil, nil); 
			} else {
				ALAssetsLibrary *library = [[[ALAssetsLibrary alloc] init] autorelease];
				CGImageRef imageMetadataRef=originalImage.CGImage;
				[library writeImageToSavedPhotosAlbum:imageMetadataRef metadata:appDelegate.imageMetadata completionBlock:^(NSURL *newURL, NSError *error) {
					if (error) {
					} else {
					}
				}];
			}
		}
	} else { //from Lib
		float version = [[[UIDevice currentDevice] systemVersion] floatValue];
		if (version > 4.1) {
			NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
			
			ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
			[library assetForURL:assetURL
					 resultBlock:^(ALAsset *asset)  {
						 NSDictionary *metadata = asset.defaultRepresentation.metadata;
						 
						 appDelegate.imageMetadata = [[NSMutableDictionary alloc] initWithDictionary:metadata];
						 
					 }
					failureBlock:^(NSError *error) {
					}];
			[library autorelease];
		} else {
			appDelegate.imageMetadata = nil;	
		}
	}
	//end add
	
	
	[appDelegate.window addSubview:self.view];
	
	[picker dismissModalViewControllerAnimated:YES];
	
	//s_isCameraPick = true;
	
	//baiwei add for dismisspopover
	
	//modify by jack
	if(imagePickerPopover.popoverVisible)
		[self.imagePickerPopover dismissPopoverAnimated:YES];
	
	m_isImageOnceLoaded = true;	
	
	//[self setWidgetGeometry];
	
	// Randomize and clear cache
	for(int i=0;i<9;i++)
	{
		[self newRenderArg:i];
		isRefresh[i] = NO;
		if(viewImageArray[i])
		{
			[viewImageArray[i] release];
			viewImageArray[i] = nil;
		}
	}
	
	
	
	CGSize size = originalImage.size;
	NSLog(@"load image size: %f : %f", size.width,size.height);
	
	//baiwei add for memery resolution
	
	appDelegate.highWidth = size.width;
	appDelegate.highHeight = size.height;
	appDelegate.midWidth = size.width*0.75;
	appDelegate.midHeight = size.height*0.75;
	appDelegate.lowWidth = size.width*0.5;
	appDelegate.lowHeight = size.height*0.5;
	
	
	if(size.width< 100 || size.height < 100){
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
														message:NSLocalizedString(@"Min Resolution limit", nil) 
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	float rat = 0;
	if(size.width > size.height){
		rat = size.width/size.height;
	}
	else {
		rat = size.height/size.width;
	}
	
	if(rat > 5.0){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
														message:NSLocalizedString(@"Aspecr Ratio Limit", nil)
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	double maxSize = [self getLimitResolution];
	if(size.width*size.height > maxSize){
		int iMax = maxSize/10000-10;
		iMax = iMax/100;
		NSString *alertMsg = [NSString stringWithFormat:NSLocalizedString(@"Max Resolution limit",nil),iMax];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
														message:alertMsg
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	
	//Added by jack
	//Cache the raw data of image
	//[Utilities cacheToRawDataFromImage:originalImage filename:ORIGINAL_IMAGE_FILE_NAME];
	//[Utilities cacheToRawDataFromImage:originalImage filename:RENDER_SOURCE_FILE_NAME];
	
	if(originalImage == nil)return;
	
	
	//add by jack 0525
	mojoAppDelegate *app = (mojoAppDelegate*)[[UIApplication sharedApplication] delegate];
	[app showInitialiationView];
	[app hiddenProgressViewBar];
	//end add
	
	
	//add by jack 2011-07-18
	//iPhone 4 reverse contrast curve definition
	NSString* machine = [self getDeviceName];
	if ( [machine hasPrefix:@"iPhone3,"] && isImageFromCamera){
		int inputWidth = CGImageGetWidth( originalImage.CGImage );
		int inputHeight = CGImageGetHeight( originalImage.CGImage );
		originalImage = [ImageProcess imageNewWithImage:originalImage scaledToSize:CGSizeMake(inputWidth, inputHeight)];
		originalImage = [self uncontrastiPhone4Image:originalImage];
	}
	//end add
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		numberMode = 9;
	} else {
		numberMode = 4;
	}
	
	[self setWidgetGeometry]; 
	m_viewState = 1;
	[self setViewState];
	
	//add by jack
	//	if (portraitImage!=nil)
	//	{
	//		[portraitImage release];
	//		portraitImage = nil;
	//	}
	//end add
	
	[Utilities printAvailMemory];
#ifdef CROP_RATIO_4_3
	UIImage *tmpImage = [self prepSourceImg:originalImage];
	[self prepTmpImg:tmpImage];
	
	[self startRenderBackground:true image:tmpImage clearAlpha:true];
	[tmpImage release];
#else
	UIImage *tmpImage = originalImage;
	[self prepTmpImg:tmpImage];
	
	//CGSize size2 = tmpImage.size;
	//	NSLog(@"load image size: %f : %f", size2.width,size2.height);
	
	[self startRenderBackground:true image:tmpImage clearAlpha:true];
#endif
	[Utilities printAvailMemory];
	
}

/*
 - (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)originalImage editingInfo:(NSDictionary *)editingInfo 
 {
 [picker dismissModalViewControllerAnimated:YES];
 
 m_viewState = 1;
 m_isImageOnceLoaded = true;	
 [self setViewState];
 [self setWidgetGeometry];
 
 // Randomize and clear cache
 for(int i=0;i<4;i++)
 {
 [self newRenderArg:i];
 isRefresh[i] = NO;
 if(viewImageArray[i])
 {
 [viewImageArray[i] release];
 viewImageArray[i] = nil;
 }
 }
 
 if ( picker.sourceType == UIImagePickerControllerSourceTypeCamera )
 {
 // Saved captured camera photo
 //
 //		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
 //		if ([defaults boolForKey:@"save_camera_shot"])
 if ([self isSaveCameraShot])
 {
 UIImageWriteToSavedPhotosAlbum(originalImage, self, nil, nil);
 }
 }
 
 UIImage *tmpImage = [self prepSourceImg:originalImage];
 [self prepTmpImg:tmpImage];
 
 [self startRenderBackground:true image:tmpImage clearAlpha:true];
 [tmpImage release];
 }
 */


// Deal with original image by cropping and scaling
//
#pragma mark Treatment for origianl Image
-(UIImage *)prepSourceImg:(UIImage *)_sourceImg
{
	double originalWidth = CGImageGetWidth(_sourceImg.CGImage);
	double originalHeight = CGImageGetHeight(_sourceImg.CGImage);
	double standardValue = 0.75f;
	double tolerance = 0.01f;
	
	// Force to deal with orientation
	//
	UIImage *tmpImg = [ImageProcess imageNewWithImage:_sourceImg scaledToSize:CGSizeMake(originalWidth, originalHeight)];
	if (!tmpImg)
		return nil;
	originalWidth = CGImageGetWidth(tmpImg.CGImage);
	originalHeight = CGImageGetHeight(tmpImg.CGImage);
	
	CGSize maxRes;
	if(originalWidth>originalHeight)
	{
		maxRes.width = originalWidth;
		maxRes.height = originalHeight;
	}
	else 
	{
		maxRes.width = originalHeight;
		maxRes.height = originalWidth;
	}
	
	bool doCrop = false;
	int xOffset;
	int yOffset;
	int cropWidth;
	int cropHeight;
	UIImage *resultImg = nil;
	
	if((fabs(originalWidth/originalHeight-standardValue)<tolerance) || 
	   (fabs(originalHeight/originalWidth-standardValue)<tolerance) )
	{
		doCrop = false;
		resultImg = tmpImg;
	}
	else if(originalWidth==originalHeight)
	{
		//Square image - crop horizontally
		float tempHeight = standardValue * originalWidth;
		float startY = (originalHeight - tempHeight) / 2.0f;
		doCrop = true;
		xOffset = 0;
		yOffset = startY;
		cropWidth = originalWidth;
		cropHeight = tempHeight;
		
	}
	else if(originalHeight/originalWidth<standardValue)
	{
		// height:width < 3:4 - crop width
		//
		float tempWidth = originalHeight / standardValue;
		float startX = (originalWidth - tempWidth) / 2.0f;
		doCrop = true;
		xOffset = startX;
        yOffset = 0;
		cropWidth = tempWidth;
		cropHeight = originalHeight;
		
	}
	else if((originalHeight/originalWidth>standardValue)&&(originalHeight/originalWidth<1.0f))
	{
		// ratio is close to square - crop horizontally
		//
		float tempHeight = standardValue * originalWidth;
		float startY = (originalHeight - tempHeight) / 2.0f;
		doCrop = true;
		xOffset = 0;
		yOffset = startY;
		cropWidth = originalWidth;
		cropHeight = tempHeight;
	}
	else if(originalWidth/originalHeight<standardValue)
	{
		// Width:Height < 3:4 - crop height
		//
		float tempHeight = originalWidth / standardValue;
		float startY = (originalHeight - tempHeight) / 2.0f;
		doCrop = true;
		xOffset = 0;
		yOffset = startY;
		cropWidth = originalWidth;
		cropHeight = tempHeight;
	}
	else if((originalWidth/originalHeight>standardValue)&&(originalWidth/originalHeight<1.0f))
	{
		// Close to square - crop horizontally
		//
		float tempWidth = originalHeight * standardValue;
		float startX = (originalWidth - tempWidth) / 2.0f;
		doCrop = true;
		xOffset = startX;
		yOffset = 0;
		cropWidth = tempWidth;
		cropHeight = originalHeight;
	}
	else
	{
		doCrop = false;
		resultImg = tmpImg;
	}
	
	if (doCrop)
	{
		CGImageRef tempRef = CGImageCreateWithImageInRect(tmpImg.CGImage, CGRectMake(xOffset, yOffset, cropWidth, cropHeight));
		[tmpImg release];
		resultImg = [[UIImage alloc]initWithCGImage:tempRef];
		CGImageRelease(tempRef);		
	}
	
	return resultImg;
	
}


- (void)selectQuad:(int)index
{
	
	m_quadIndex = index;
    
    //baiwei add for select resolution
    [[NSUserDefaults standardUserDefaults] setInteger:m_quadIndex forKey: @"m_quadIndex"];
	
	[UIView beginAnimations:@"Rotate" context:nil];
	[UIView  setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector (animationDidStopAndRender:finished:context:) ];
	[UIView  setAnimationWillStartSelector:@selector (animationWillStart:context:) ];
	
	
	lastNumberMode = numberMode;
	numberMode = 1;
	[self setWidgetGeometry];
	m_viewState = 2;
	[self setViewState];
	
	
	[UIView commitAnimations];		
}

-(void)animateImageView:(UIImageView *)imageView
{
	[UIView beginAnimations:@"Alpha" context:nil];
	[imageView setAlpha:1.0];
	[UIView commitAnimations];		
}

-(void)prepTmpArt:(int)resolution  landscape:(bool)_landscape
{
	if ((prevWidth != resolution) || !cvVigArtImg || !VigArtImg || !borderImg || !leakImg)
	{		
		if (cvVigArtImg)	
		{
			[cvVigArtImg release];
			cvVigArtImg = nil;
		}
		if (VigArtImg)		
		{
			[VigArtImg release];
			VigArtImg = nil;
		}
		if (borderImg)		
		{
			[borderImg release];
			borderImg = nil;
		}
		if (leakImg) 		
		{
			[leakImg release];
			leakImg = nil;
		}
		
		switch (resolution) {
			case 3000:
			{
				leakImg = [[UIImage imageNamed:PROCESS_LEAK_6K]retain];
				if (_landscape)
				{
					//					cvVigArtImg = [[UIImage imageNamed:PROCESS_VIGART_LANDSCAPE_2K]retain];
					//					VigArtImg = [[UIImage imageNamed:PROCESS_SQRVIG_LANDSCAPE_2K]retain];
					borderImg = [[UIImage imageNamed:PROCESS_BORDER_LANDSCAPE_4K]retain];
				}
				else
				{
					//					cvVigArtImg = [[UIImage imageNamed:PROCESS_VIGART_2K]retain];
					//					VigArtImg = [[UIImage imageNamed:PROCESS_SQRVIG_2K]retain];
					borderImg = [[UIImage imageNamed:PROCESS_BORDER_4K]retain];
				}
			}
				break;
			case 2592:
				leakImg = [[UIImage imageNamed:PROCESS_LEAK_2K]retain];
				if (_landscape)
				{
					//					cvVigArtImg = [[UIImage imageNamed:PROCESS_VIGART_LANDSCAPE_2K]retain];
					//					VigArtImg = [[UIImage imageNamed:PROCESS_SQRVIG_LANDSCAPE_2K]retain];
					borderImg = [[UIImage imageNamed:PROCESS_BORDER_LANDSCAPE_2K]retain];
				}
				else
				{
					//					cvVigArtImg = [[UIImage imageNamed:PROCESS_VIGART_2K]retain];
					//					VigArtImg = [[UIImage imageNamed:PROCESS_SQRVIG_2K]retain];
					borderImg = [[UIImage imageNamed:PROCESS_BORDER_2K]retain];
				}
				break;
			case 2048:
				leakImg = [[UIImage imageNamed:PROCESS_LEAK_2K]retain];
				if (_landscape)
				{
					//					cvVigArtImg = [[UIImage imageNamed:PROCESS_VIGART_LANDSCAPE_2K]retain];
					//					VigArtImg = [[UIImage imageNamed:PROCESS_SQRVIG_LANDSCAPE_2K]retain];
					borderImg = [[UIImage imageNamed:PROCESS_BORDER_LANDSCAPE_2K]retain];
				}
				else
				{
					//					cvVigArtImg = [[UIImage imageNamed:PROCESS_VIGART_2K]retain];
					//					VigArtImg = [[UIImage imageNamed:PROCESS_SQRVIG_2K]retain];
					borderImg = [[UIImage imageNamed:PROCESS_BORDER_2K]retain];
				}
				break;
			case 1600:
				leakImg = [[UIImage imageNamed:PROCESS_LEAK_1K]retain];
				if (_landscape)
				{
					//					cvVigArtImg = [[UIImage imageNamed:PROCESS_VIGART_LANDSCAPE_1K]retain];
					//					VigArtImg = [[UIImage imageNamed:PROCESS_SQRVIG_LANDSCAPE_1K]retain];
					borderImg = [[UIImage imageNamed:PROCESS_BORDER_LANDSCAPE_1K]retain];
				}
				else
				{
					//					cvVigArtImg = [[UIImage imageNamed:PROCESS_VIGART_1K]retain];
					//					VigArtImg = [[UIImage imageNamed:PROCESS_SQRVIG_1K]retain];
					borderImg = [[UIImage imageNamed:PROCESS_BORDER_1K]retain];
				}
				break;
			case 1024:
				leakImg = [[UIImage imageNamed:PROCESS_LEAK_1K]retain];
				if (_landscape)
				{
					//					cvVigArtImg = [[UIImage imageNamed:PROCESS_VIGART_LANDSCAPE_1K]retain];
					//					VigArtImg = [[UIImage imageNamed:PROCESS_SQRVIG_LANDSCAPE_1K]retain];
					borderImg = [[UIImage imageNamed:PROCESS_BORDER_LANDSCAPE_1K]retain];
				}
				else
				{
					//					cvVigArtImg = [[UIImage imageNamed:PROCESS_VIGART_1K]retain];
					//					VigArtImg = [[UIImage imageNamed:PROCESS_SQRVIG_1K]retain];
					borderImg = [[UIImage imageNamed:PROCESS_BORDER_1K]retain];
				}
				break;
			case 800:
				leakImg = [[UIImage imageNamed:PROCESS_LEAK]retain];
				if (_landscape)
				{
					//					cvVigArtImg = [[UIImage imageNamed:PROCESS_VIGART_LANDSCAPE]retain];
					//					VigArtImg = [[UIImage imageNamed:PROCESS_SQRVIG_LANDSCAPE]retain];
					borderImg = [[UIImage imageNamed:PROCESS_BORDER_LANDSCAPE]retain];
				}
				else
				{
					//					cvVigArtImg = [[UIImage imageNamed:PROCESS_VIGART]retain];
					//					VigArtImg = [[UIImage imageNamed:PROCESS_SQRVIG]retain];
					borderImg = [[UIImage imageNamed:PROCESS_BORDER]retain];
				}
				break;
			default:
				resolution = 0;
				break;
		}			
		prevWidth = resolution;
	}
}

#pragma mark Load Resource Images
-(void)prepTmpImg:(UIImage *)_image
{
#ifdef __MOJO__
#else //__PlasticBullet__
	
	int width = CGImageGetWidth(_image.CGImage);
	int height = CGImageGetHeight(_image.CGImage);
	
	prevWidth = 0;
	//    [self prepTmpArt:800 landscape:width > height ];
    [self prepTmpArt:800 landscape:isFullImageLandscape ];
	
	// Repare for Blurred Soft Image
	//
	if (blurImage){
		[blurImage release];
		
		//safty release
		blurImage = nil;
	}
	
	
	if ( (width < 320) && (height < 320) )
	{		
		UIImage *tmpImage2;
		tmpImage2 = [ImageProcess imageNewWithImage:_image scaledToSize:CGSizeMake(width,height)];
		//		if ( width > height )
		//		{
		//			tmpImage2 = [ImageProcess imageNewWithImage:_image scaledToSize:CGSizeMake(320,240)];
		//		}
		//		else
		//		{
		//			tmpImage2 = [ImageProcess imageNewWithImage:_image scaledToSize:CGSizeMake(240,320)];
		//		}
		
		blurImage = [Renderer blurImg:tmpImage2];
		[tmpImage2 release];
		if (blurImage)
		{
			tmpImage2 = [Renderer blurImg:blurImage];
			if ( tmpImage2 )
			{
				[blurImage release];
				blurImage = tmpImage2;
			}
		}
	}
	
#endif
}



- (int)renderImages
{
	//mojoView *pView = (mojoView *)self.view;
	int width, height;
	int numRenderIndexs = 1;
	int renderIndex = 0;
	
	if (numberMode == 4) {
		numRenderIndexs = 4;
	} else if (numberMode == 9) {
		numRenderIndexs = 9;
	} else {
		renderIndex = m_quadIndex;
		numRenderIndexs = renderIndex+1;
	}
	
	UIImageView *imageViewArray[] = {topLeftView, topRightView, bottomLeftView, bottomRightView, topMiddleView,  middleLeftView, middleMiddleView, middleRightView,  bottomMiddleView};
	
	
	
	
	int err = 0;
	
	if(isPortrait)
	{
		int renderOrder[9];
		
		if (isInverted == true) { //down
			if (numberMode == 4) {
				int renderOrder2[4] = {3, 2, 1, 0};
				for(int i=0; i<=4;i++) {
					renderOrder[i] = renderOrder2[i];
					
				}
			} else {
				int renderOrder2[9] = {3, 8, 2, 7, 6, 5, 1, 4, 0};
				for(int i=0; i<9;i++) {
					renderOrder[i] = renderOrder2[i];
					
				}
			}
		} else { //up
			if (numberMode == 4) {
				int renderOrder2[4] = {0, 1, 2, 3};
				for(int i=0; i<4;i++) {
					renderOrder[i] = renderOrder2[i];
					
				}
			} else {
				int renderOrder2[9] = {0, 4, 1, 5, 6, 7, 2, 8, 3};
				for(int i=0; i<9;i++) {
					renderOrder[i] = renderOrder2[i];
					
				}
			}
			
		}
		
		
		//UIImage *portraitImage = [pView getPortraitImage];
		width = CGImageGetWidth( portraitImage.CGImage );
		height = CGImageGetHeight( portraitImage.CGImage );
		
		
		for(; renderIndex<numRenderIndexs; ++renderIndex)
		{
			int index = renderIndex;
			if(numberMode == 4 || numberMode == 9) {
				if (isInverted == true) {
					index = renderOrder[renderIndex];
				} else {
					index = renderOrder[renderIndex];
				}
				
			}
			UIImage *pOutputImage = nil;
			if(m_viewState==1)
			{
				if(isRefresh[index]||(!viewImageArray[index]))
				{
					pOutputImage = [self createNewImage:&portraitImage imgWidth:width imgHeight:height imgParameter:index];
					if(pOutputImage)
					{
						if(viewImageArray[index])
						{
							[viewImageArray[index] release];
							viewImageArray[index] = nil;
						}
						viewImageArray[index] = [[UIImage alloc] initWithCGImage:pOutputImage.CGImage];
						if (viewImageArray[index])
						{
							isRefresh[index] = NO;
						}
					}
				}
				else
				{
					pOutputImage = [[UIImage alloc] initWithCGImage:viewImageArray[index].CGImage];
				}
			}//*
			else if(m_viewState==2)
			{
				if (ffRenderArgsArray[index].cachedPreviewImage)
				{
					NSString *filename = [NSString stringWithFormat:@FORMAT_PREVIEW,index ];
					pOutputImage = [[[FileCache sharedCacher] cachedLocalImage:filename] retain];
				}
				else
				{
					pOutputImage = [self createNewImage:&portraitImage imgWidth:width imgHeight:height imgParameter:index];
					if (pOutputImage)
					{
						NSString *filename = [NSString stringWithFormat:@FORMAT_PREVIEW,index ];
						[[FileCache sharedCacher] cacheLocalImage:filename image:pOutputImage];
						ffRenderArgsArray[index].cachedPreviewImage = true;
					}
				}
			}
			//NSLog(@"pOutputImage = %d", [viewImageArray[index] retainCount]);
			if(pOutputImage)
			{
				[imageViewArray[index] performSelectorOnMainThread:@selector(setImage:) withObject:pOutputImage waitUntilDone:NO];	
				[pOutputImage release];
				[self performSelectorOnMainThread:@selector(animateImageView:) withObject:imageViewArray[index] waitUntilDone:NO];	
			}
			else
				err = 1;
			if([workerThread isCancelled])
				err = 1;
			if(err)
				break;
		}
	}
	else
	{
		int renderOrder[9];
		
		if (isInverted == true) { //left
			if (numberMode == 4) {
				int renderOrder2[4] = {1, 3, 0, 2};
				for(int i=0; i<=4 ;i++) {
					renderOrder[i] = renderOrder2[i];
					
				}
			} else {
				int renderOrder2[9] = {1, 7, 3, 4, 6, 8, 0, 5, 2};
				for(int i=0; i<=8;i++) {
					renderOrder[i] = renderOrder2[i];
					
				}
			}
			
		} else { //right
			if (numberMode == 4) {
				int renderOrder2[4] = {2, 0, 3, 1};
				for(int i=0; i<=4;i++) {
					renderOrder[i] = renderOrder2[i];
					
				}
			} else {
				int renderOrder2[9] = {2, 5, 0, 8, 6, 4, 3, 7, 1};
				for(int i=0; i<=8;i++) {
					renderOrder[i] = renderOrder2[i];
					
				}
			}
			
		}
		
		UIImage *landscapeImage = portraitImage;
		width = CGImageGetWidth( landscapeImage.CGImage );
		height = CGImageGetHeight( landscapeImage.CGImage );
		for(; renderIndex<numRenderIndexs; ++renderIndex)
		{
			int index = renderIndex;
			if(numberMode == 4 || numberMode == 9) {
				index = renderOrder[renderIndex];
			}
			UIImage *pOutputImage = nil;
			if(m_viewState==1)
			{
				//		NSLog(@"m_viewState=1");
				if(isRefresh[index] || !viewImageArray[index] ) 
				{
					pOutputImage = [self createNewImage:&landscapeImage imgWidth:width imgHeight:height imgParameter:index];
					if(pOutputImage)
					{
						if(viewImageArray[index])
						{
							[viewImageArray[index] release];
							viewImageArray[index] = nil;
						}
						viewImageArray[index] = [[UIImage alloc]initWithCGImage:pOutputImage.CGImage];
						if (viewImageArray[index])
						{
							isRefresh[index] = NO;
						}
					}
				}
				else
				{
					pOutputImage = [[UIImage alloc]initWithCGImage:viewImageArray[index].CGImage];
				}
			}//*
			else if(m_viewState==2)
			{
				if (ffRenderArgsArray[index].cachedPreviewImage)
				{
					NSString *filename = [NSString stringWithFormat:@FORMAT_PREVIEW,index ];
					pOutputImage = [[[FileCache sharedCacher] cachedLocalImage:filename] retain];
				}
				else
				{
					pOutputImage = [self createNewImage:&landscapeImage imgWidth:width imgHeight:height imgParameter:index];
					if (pOutputImage)
					{
						NSString *filename = [NSString stringWithFormat:@FORMAT_PREVIEW,index ];
						[[FileCache sharedCacher] cacheLocalImage:filename image:pOutputImage];
						ffRenderArgsArray[index].cachedPreviewImage = true;
					}
				}
			}
			if(pOutputImage)
			{
				[imageViewArray[index] performSelectorOnMainThread:@selector(setImage:) withObject:pOutputImage waitUntilDone:NO];	
				[self performSelectorOnMainThread:@selector(animateImageView:) withObject:imageViewArray[index] waitUntilDone:NO];	
				[pOutputImage release];		
			}
			else
				err = 1;	
			if([workerThread isCancelled])
				err = 1;
			if(err)
				break;
		}
	}
	if(err)
	{
		return err;
	}
	
	
	return 0;
}
/*
 -(void) renderRedraw
 {
 mojoView *pView = (mojoView *)self.view;
 [pView setNeedsDisplay];
 }
 
 */
/*
 - (void)renderAmount:(float)xAmount yArgAmount:(float)yAmount
 {
 int renderIndex = 0;
 
 setAmountRenderArg(renderArgsArray[renderIndex], axisXProperty, xAmount);
 setAmountRenderArg(renderArgsArray[renderIndex], axisYProperty, yAmount);
 [self startRenderBackground:false image:nil clearAlpha:true];
 }
 */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	
	
	
	[picker dismissModalViewControllerAnimated:YES];
	
	if ( !m_isImageOnceLoaded )
	{
		// Nothing is picked yet. Go back to the splash screen
		//
		//mojoAppDelegate *appDelegate = (mojoAppDelegate*)[[UIApplication sharedApplication]delegate];
		//[appDelegate.window addSubview:appDelegate.navigationStart.view];
		
		return;
	} else {
		mojoAppDelegate *appDelegate = (mojoAppDelegate*)[[UIApplication sharedApplication]delegate];
		[appDelegate.window addSubview:self.view];
	}
	
	
	m_viewState = 1;
	
	[self setWidgetGeometry];
	[self setViewState];
	
	
	//	if(m_viewState == 1)
	//{
	/*
	 #if 0
	 [self startRenderBackground clearAlpha:true];
	 #endif		*/
	//	mojoView *pView = (mojoView *)self.view;
	//[pView setNeedsDisplay];	
	//}
	[self startRenderBackground:false image:nil clearAlpha:true];
	
}
/*
 - (void)showMenu
 {
 // REMOVE
 }
 */
- (void)randomizeQuad:(int)_index
{
	if (_index == -1 || _index == -2)
	{
		for(int k=0;k<9;k++)
		{
			[self newRenderArg:k];
			isRefresh[k] = YES;
		}
	}
	else if ( _index<9 )
	{
		[self newRenderArg:_index];
		isRefresh[_index] = YES;		
	}
	
	if(_index == -2){
		[self startRenderBackground:true image:nil clearAlpha:true];
	}
	else {
		[self startRenderBackground:false image:nil clearAlpha:true];
	}
	
}

- (int) getViewState
{
	return m_viewState;
}
/*
 // Respond to a tap on the System Sound button
 - (void)playSystemSound
 {
 // Disabled
 //	AudioServicesPlaySystemSound (self.soundFileObject);
 }
 
 // Respond to a tap on the Alert Sound button
 - (void)playAlertSound 
 {	
 // Disabled
 //	AudioServicesPlayAlertSound (self.soundFileObject);
 }
 */

- (void)startSaveBackground:(SAVE_TO)saveTo
{
    //int a = m_quadIndex;
	saveToState = saveTo;
	
	[[NSUserDefaults standardUserDefaults] setInteger:saveToState forKey: @"saveToState"];
	
	//mojoAppDelegate *app = (mojoAppDelegate*)[[UIApplication sharedApplication] delegate];
//	app.saveToState = saveTo;
	
 	float x = 320/2.0;
	float y = (480-TOOLBAR_OFFSET_HEIGHT)/2.0;
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		x = 768/2.0;
		y = (1024-TOOLBAR_OFFSET_HEIGHT)/2.0;
	}
	
	
	float width = spinner.frame.size.width;
	float height = spinner.frame.size.height;
	spinner.frame = CGRectMake(x-width/2.0, TOOLBAR_OFFSET_HEIGHT + y-height/2.0, width, height);
	if(workerThread != nil)
	{
		[workerThread cancel];
		do
		{
			// Spin
		}
		while (![workerThread isFinished]);
		[workerThread release];
	}
	
	
	//add by jack
	//pass param to thread
	NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", saveTo], KEY_SAVE_TO,nil];
	//end add
	workerThread = [[NSThread alloc] initWithTarget:self selector:@selector(backgroundSaving:) object:dic];
	[workerThread start];
	
}

- (UIImage *)getUploadImage
{
	double downres = 1.0f;
	if([self isHalfResolution])
	{
		downres = 0.5f;
	}
	else if ([self is3QuarterResolution] )
	{
		downres = 0.75f;
	}
	
	fullImage = [Utilities imageFromFileCache:ORIGINAL_IMAGE_FILE_NAME];
	//add by Guno
	//	int inputWidth = CGImageGetWidth( fullImage.CGImage ) * downres;
	//	int inputHeight = CGImageGetHeight( fullImage.CGImage ) * downres;
	int inputWidth = fullImageWidth * downres;
	int inputHeight = fullImageHeight * downres;
	isFullImageLandscape = (inputWidth > inputHeight);
	//end Guno
	
	// Prepare target source render image
	// Need to deal with device memory limitation by first scale down the image and post scale the image after render
	//
	int width = inputWidth;
	int height = inputHeight;
	//CGSize maxRes = [self getMaxRenderResolution:CGSizeMake(width, height)];
	//	if ((maxRes.width!=width) || (maxRes.height!=height))
	//	{
	//		width = maxRes.width;
	//		height = maxRes.height;
	//	}
	//baiwei add for progress
	mojoAppDelegate *app = (mojoAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[app setResolution:[defaults integerForKey:@"resolution_select"]];
	[app showProcessProgress:YES];
	[app updateProgressDegree:0.0];
	
	UIImage *renderImage = [self createNewImage:&fullImage imgWidth:width imgHeight:height imgParameter:-1];
	
	//int tempWidth,tempHeight;
	
	int tempWidth = width;
	int tempHeight = height;
	//	if(CGImageGetWidth(portraitImage.CGImage)>CGImageGetHeight(portraitImage.CGImage))
	//	{
	//		tempWidth = width;
	//		tempHeight = height;
	//	}
	//	else
	//	{
	//		tempWidth = width<height?width:height;
	//		tempHeight = width>height?width:height;
	//	}
	
	// Retreive from file cache if already rendered previously
	//
	bool re_cache = false;
	UIImage *saveImage = nil;
	if ( ffRenderArgsArray[m_quadIndex].cachedRenderImage )
	{
		NSString *filename = [NSString stringWithFormat:@FORMAT_RENDER,m_quadIndex ];
		saveImage = [[[FileCache sharedCacher] cachedLocalImage:filename] retain];
		if ( !saveImage )
		{
			ffRenderArgsArray[m_quadIndex].cachedRenderImage = false;
		}
		else if (tempWidth > CGImageGetWidth( saveImage.CGImage ))
		{
			// File cache is not hi res enough.  Need re-render
			//
			[saveImage release];
			saveImage = nil;
			re_cache = true;
		}
		else if (tempWidth < CGImageGetWidth( saveImage.CGImage ))
		{
			// Smaller target.  Just shrink down and finish.
			//
			UIImage *targetImage = [ImageProcess imageNewWithImage:saveImage scaledToSize:CGSizeMake(tempWidth, tempHeight)];
			[saveImage release];
			saveImage = targetImage;
		}
		
	}
	
	BOOL isNeedCreateImage = NO;
	
	//mojoAppDelegate *app = (mojoAppDelegate*)[[UIApplication sharedApplication] delegate];
	if ( !saveImage )
	{
		isNeedCreateImage = YES;
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[app setResolution:[defaults integerForKey:@"resolution_select"]];
		//[app showProcessProgress:YES];
		//		[app updateProgressDegree:0.0];
		
		// Do actual rendering
		//
		[self printAvailMem];
		saveImage = [self createNewImage:&renderImage imgWidth:tempWidth imgHeight:tempHeight imgParameter:m_quadIndex];
		[self printAvailMem];
	}
	
	[app updateProgressDegree:1.0];
	[app showProcessProgress:NO];
	
	return saveImage;
	
	//return saveImage2;
}

// Render full res and Save to Photo Album
//
- (void)backgroundSaving:(NSDictionary*)info
{
	isSaveToAlbum = true;
	
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self performSelectorOnMainThread:@selector(startAnimating:) withObject:@"startAnimating" waitUntilDone:NO];
	
	sWorkerThread = workerThread;
	
	// Check the target render resolution
	//
	double downres = 1.0f;
	if([self isHalfResolution])
	{
		downres = 0.5f;
	}
	else if ([self is3QuarterResolution] )
	{
		downres = 0.75f;
	}
	
	//#ifdef __DEBUG_PB__
	fullImage = [Utilities imageFromFileCache:ORIGINAL_IMAGE_FILE_NAME];
	fullImageWidth = CGImageGetWidth( fullImage.CGImage );
	fullImageHeight = CGImageGetHeight( fullImage.CGImage );	
	//#endif
	
	int inputWidth = fullImageWidth * downres;
	int inputHeight = fullImageHeight * downres;
	
	[Utilities printAvailMemory];
	
	// Prepare target source render image
	// Need to deal with device memory limitation by first scale down the image and post scale the image after render
	//
	int width = inputWidth;
	int height = inputHeight;
	//CGSize maxRes = [self getMaxRenderResolution:CGSizeMake(width, height)];
	//	if ((maxRes.width!=width) || (maxRes.height!=height))
	//	{
	//		width = maxRes.width;
	//		height = maxRes.height;
	//	}
	UIImage *renderImage = [self createNewImage:&fullImage imgWidth:width imgHeight:height imgParameter:-1];
	
	int tempWidth = width;
	int tempHeight = height;
	//	int pWidth = CGImageGetWidth(portraitImage.CGImage);
	//	int pHeight = CGImageGetHeight(portraitImage.CGImage);
	//
	//	if (pWidth <= pHeight)
	//	{
	//		tempWidth = width;
	//		tempHeight = height;
	//	}
	//	else
	//	{
	//		tempWidth = width<height?width:height;
	//		tempHeight = width>height?width:height;
	//	}
	
	// Retreive from file cache if already rendered previously
	//
	bool re_cache = false;
	UIImage *saveImage = nil;
	if ( ffRenderArgsArray[m_quadIndex].cachedRenderImage )
	{
		NSString *filename = [NSString stringWithFormat:@FORMAT_RENDER,m_quadIndex ];
		saveImage = [[[FileCache sharedCacher] cachedLocalImage:filename] retain];
		if ( !saveImage )
		{
			ffRenderArgsArray[m_quadIndex].cachedRenderImage = false;
		}
		else if (tempWidth > CGImageGetWidth( saveImage.CGImage ))
		{
			// File cache is not hi res enough.  Need re-render
			//
			[saveImage release];
			saveImage = nil;
			re_cache = true;
		}
		else if (tempWidth < CGImageGetWidth( saveImage.CGImage ))
		{
			// Smaller target.  Just shrink down and finish.
			//
			UIImage *targetImage = [ImageProcess imageNewWithImage:saveImage scaledToSize:CGSizeMake(tempWidth, tempHeight)];
			[saveImage release];
			saveImage = targetImage;
		}
		
	}
	
	BOOL isNeedCreateImage = NO;
	
	mojoAppDelegate *app = (mojoAppDelegate*)[[UIApplication sharedApplication] delegate];
	if ( !saveImage )
	{
		isNeedCreateImage = YES;
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[app setResolution:[defaults integerForKey:@"resolution_select"]];
		[app showProcessProgress:YES];
		[app updateProgressDegree:0.0];
		if(info)
		{
			int operation = [[info valueForKey:KEY_SAVE_TO] intValue];
			switch (operation)
			{
				case SAVE_TO_ALBUM:
				{
					
				}
					break;
				case SAVE_TO_FACEBOOK:
				{
					
				}
					break;
				case SAVE_TO_FLICKR:
				{
					
				}
					break;
			}
		}
		
		// Do actual rendering
		//
		[self printAvailMem];
		saveImage = [self createNewImage:&renderImage imgWidth:tempWidth imgHeight:tempHeight imgParameter:m_quadIndex];
		[self printAvailMem];
	}
	
	//NSLog(@"createNewImage end");
	if(renderImage != nil)
		[renderImage release];
	
	mojoAppDelegate *appDelegate = (mojoAppDelegate*)[[UIApplication sharedApplication]delegate];
	
	if(saveImage && ![workerThread isCancelled])
	{
		
		if(info)
		{
			
			int operation = [[info valueForKey:KEY_SAVE_TO] intValue];
			
			switch (operation)
			{
				case SAVE_TO_ALBUM:
				{
					// Always save to album regardless of cache
					//
					if (!isNeedCreateImage)
					{
						NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
						[app setResolution:[defaults integerForKey:@"resolution_select"]];
						[app showProcessProgress:YES];
						[app updateProgressDegree:1.0];
					}
					
					[app setResolution:3];
					[app showProcessProgress:YES];
					
					if ( !ffRenderArgsArray[m_quadIndex].cachedRenderImage || re_cache )
					{
						if (sPostRenderScale)
						{
							UIImage *targetImage = [ImageProcess imageNewWithImage:saveImage scaledToSize:sRenderTarget];
							[saveImage release];
							saveImage = targetImage;
						}
					}
					
#ifdef __DEBUG_PB__
					NSLog(@"Prepare to save to Album");
					//[Utilities printAvailMemory];
#endif
					//baiwei edit for metadata
					
					NSLog(@"saveMetaData=%@", appDelegate.imageMetadata);
					if (appDelegate.imageMetadata == nil) {
						UIImageWriteToSavedPhotosAlbum(saveImage, self, nil, nil); 
					} else {
						[appDelegate.imageMetadata setObject:[NSNumber numberWithInteger:saveImage.imageOrientation] forKey:@"Orientation"]; 
						ALAssetsLibrary *library = [[[ALAssetsLibrary alloc] init] autorelease];
						CGImageRef imageMetadataRef=saveImage.CGImage;
						[library writeImageToSavedPhotosAlbum:imageMetadataRef metadata:appDelegate.imageMetadata completionBlock:^(NSURL *newURL, NSError *error) {
							if (error) {
							} else {
							}
						}];
					}
					//end edit
					
					if ( !ffRenderArgsArray[m_quadIndex].cachedRenderImage || re_cache )
					{
						NSString *filename = [NSString stringWithFormat:@FORMAT_RENDER,m_quadIndex ];
						[[FileCache sharedCacher] cacheLocalImage:filename image:saveImage];
						ffRenderArgsArray[m_quadIndex].cachedRenderImage = true;
					}
					else
					{
						// Waste some cycle to ensure the image is saved properly
						//
						NSString *filename = [NSString stringWithFormat:@FORMAT_RENDER,99 ];
						[[FileCache sharedCacher] cacheLocalImage:filename image:saveImage];
					}
					
					[app updateProgressDegree:1.0];
					[app showProcessProgress:NO];
                    
                    //baiwei add back to Four
                    [self backToFour];
				}
					break;
				case SAVE_TO_FACEBOOK:
				{
					if ( !ffRenderArgsArray[m_quadIndex].cachedRenderImage || re_cache )
					{
						if(isNeedCreateImage){
							[app setResolution:3];
							[app showProcessProgress:YES];
						}
						
						if (sPostRenderScale)
						{
							UIImage *targetImage = [ImageProcess imageNewWithImage:saveImage scaledToSize:sRenderTarget];
							[saveImage release];
							saveImage = targetImage;
						}
						
						//baiwei edit for metadata
						if (appDelegate.imageMetadata == nil) {
							UIImageWriteToSavedPhotosAlbum(saveImage, self, nil, nil); 
						} else {
							[appDelegate.imageMetadata setObject:[NSNumber numberWithInteger:saveImage.imageOrientation] forKey:@"Orientation"]; 
							ALAssetsLibrary *library = [[[ALAssetsLibrary alloc] init] autorelease];
							CGImageRef imageMetadataRef=saveImage.CGImage;
							[library writeImageToSavedPhotosAlbum:imageMetadataRef metadata:appDelegate.imageMetadata completionBlock:^(NSURL *newURL, NSError *error) {
								if (error) {
								} else {
								}
							}];
						}
						//end edit
						
						NSString *filename = [NSString stringWithFormat:@FORMAT_RENDER,m_quadIndex ];
						[[FileCache sharedCacher] cacheLocalImage:filename image:saveImage];
						ffRenderArgsArray[m_quadIndex].cachedRenderImage = true;
					}
					if(isNeedCreateImage){
						[app updateProgressDegree:1.0];
						[app showProcessProgress:NO];
					}
					
					int width = CGImageGetWidth( saveImage.CGImage );
					int height = CGImageGetHeight( saveImage.CGImage );
					double scale = 1.0;
					//					if ( width > height )
					if ( isFullImageLandscape )
					{
						if (width > 800)
						{
							scale = 800.0 / width;
							width = 800;
							height = height * scale;
						}
						
						if (height > 600)
						{
							scale = 600.0 / height;
							width = width * scale;
							height = 600;
						}
					}
					else 
					{
						if (height > 800)
						{
							scale = 800.0 / height;
							height = 800;
							width = width * scale;
						}
						
						if (width > 600)
						{
							scale = 600.0 / width;
							height = height * scale;
							width = 600;
						}
					}
					
					if (scale != 1.0)
					{
						UIImage *uploadImg = [ImageProcess imageNewWithImage:saveImage scaledToSize:CGSizeMake(width,height)];
						[saveImage release];
						saveImage = uploadImg;
					}
					
					[self performSelectorOnMainThread:@selector(shareOnFacebook:) withObject:saveImage waitUntilDone:NO];
				}
					break;
				case SAVE_TO_FLICKR:
				{
					if ( !ffRenderArgsArray[m_quadIndex].cachedRenderImage || re_cache)
					{
						if(isNeedCreateImage){
							[app setResolution:3];
							[app showProcessProgress:YES];
						}
						
						if (sPostRenderScale)
						{
							UIImage *targetImage = [ImageProcess imageNewWithImage:saveImage scaledToSize:sRenderTarget];
							[saveImage release];
							saveImage = targetImage;
						}
						
						//baiwei edit for metadata
						if (appDelegate.imageMetadata == nil) {
							UIImageWriteToSavedPhotosAlbum(saveImage, self, nil, nil); 
						} else {
							[appDelegate.imageMetadata setObject:[NSNumber numberWithInteger:saveImage.imageOrientation] forKey:@"Orientation"]; 
							ALAssetsLibrary *library = [[[ALAssetsLibrary alloc] init] autorelease];
							CGImageRef imageMetadataRef=saveImage.CGImage;
							[library writeImageToSavedPhotosAlbum:imageMetadataRef metadata:appDelegate.imageMetadata completionBlock:^(NSURL *newURL, NSError *error) {
								if (error) {
								} else {
								}
							}];
						}
						//end edit
						
						NSString *filename = [NSString stringWithFormat:@FORMAT_RENDER,m_quadIndex ];
						[[FileCache sharedCacher] cacheLocalImage:filename image:saveImage];
						ffRenderArgsArray[m_quadIndex].cachedRenderImage = true;
					}
					if(isNeedCreateImage){
						[app updateProgressDegree:1.0];
						[app showProcessProgress:NO];
					}
					[self performSelectorOnMainThread:@selector(shareOnFlickr:) withObject:saveImage waitUntilDone:NO];
				}
					break;
					
				case SAVE_TO_TWITTER:
				{
					if ( !ffRenderArgsArray[m_quadIndex].cachedRenderImage || re_cache)
					{
						if(isNeedCreateImage){
							[app setResolution:3];
							[app showProcessProgress:YES];
						}
						
						if (sPostRenderScale)
						{
							UIImage *targetImage = [ImageProcess imageNewWithImage:saveImage scaledToSize:sRenderTarget];
							[saveImage release];
							saveImage = targetImage;
						}
						
						//baiwei edit for metadata
						if (appDelegate.imageMetadata == nil) {
							UIImageWriteToSavedPhotosAlbum(saveImage, self, nil, nil); 
						} else {
							[appDelegate.imageMetadata setObject:[NSNumber numberWithInteger:saveImage.imageOrientation] forKey:@"Orientation"]; 
							ALAssetsLibrary *library = [[[ALAssetsLibrary alloc] init] autorelease];
							CGImageRef imageMetadataRef=saveImage.CGImage;
							[library writeImageToSavedPhotosAlbum:imageMetadataRef metadata:appDelegate.imageMetadata completionBlock:^(NSURL *newURL, NSError *error) {
								if (error) {
								} else {
								}
							}];
						}
						//end edit
						
						NSString *filename = [NSString stringWithFormat:@FORMAT_RENDER,m_quadIndex ];
						[[FileCache sharedCacher] cacheLocalImage:filename image:saveImage];
						ffRenderArgsArray[m_quadIndex].cachedRenderImage = true;
					}
					if(isNeedCreateImage){
						[app updateProgressDegree:1.0];
						[app showProcessProgress:NO];
					}
					[self performSelectorOnMainThread:@selector(shareOnTwitter:) withObject:saveImage waitUntilDone:NO];
					
				}
					break;
					
				case SAVE_TO_TUMBLR:
				{
					if ( !ffRenderArgsArray[m_quadIndex].cachedRenderImage || re_cache)
					{
						if(isNeedCreateImage){
							[app setResolution:3];
							[app showProcessProgress:YES];
						}
						
						if (sPostRenderScale)
						{
							UIImage *targetImage = [ImageProcess imageNewWithImage:saveImage scaledToSize:sRenderTarget];
							[saveImage release];
							saveImage = targetImage;
						}
						
						//baiwei edit for metadata
						if (appDelegate.imageMetadata == nil) {
							UIImageWriteToSavedPhotosAlbum(saveImage, self, nil, nil); 
						} else {
							[appDelegate.imageMetadata setObject:[NSNumber numberWithInteger:saveImage.imageOrientation] forKey:@"Orientation"]; 
							ALAssetsLibrary *library = [[[ALAssetsLibrary alloc] init] autorelease];
							CGImageRef imageMetadataRef=saveImage.CGImage;
							[library writeImageToSavedPhotosAlbum:imageMetadataRef metadata:appDelegate.imageMetadata completionBlock:^(NSURL *newURL, NSError *error) {
								if (error) {
								} else {
								}
							}];
						}
						//end edit
						
						NSString *filename = [NSString stringWithFormat:@FORMAT_RENDER,m_quadIndex ];
						[[FileCache sharedCacher] cacheLocalImage:filename image:saveImage];
						ffRenderArgsArray[m_quadIndex].cachedRenderImage = true;
					}
					if(isNeedCreateImage){
						[app updateProgressDegree:1.0];
						[app showProcessProgress:NO];
					}
					[self performSelectorOnMainThread:@selector(shareOnTumblr:) withObject:saveImage waitUntilDone:NO];
					
				}
					break;
					
				case SAVE_TO_ALL:
				{
					if ( !ffRenderArgsArray[m_quadIndex].cachedRenderImage || re_cache)
					{
						if(isNeedCreateImage){
							[app setResolution:3];
							[app showProcessProgress:YES];
						}
						
						if (sPostRenderScale)
						{
							UIImage *targetImage = [ImageProcess imageNewWithImage:saveImage scaledToSize:sRenderTarget];
							[saveImage release];
							saveImage = targetImage;
						}
						
						//baiwei edit for metadata
						if (appDelegate.imageMetadata == nil) {
							UIImageWriteToSavedPhotosAlbum(saveImage, self, nil, nil); 
						} else {
							[appDelegate.imageMetadata setObject:[NSNumber numberWithInteger:saveImage.imageOrientation] forKey:@"Orientation"]; 
							ALAssetsLibrary *library = [[[ALAssetsLibrary alloc] init] autorelease];
							CGImageRef imageMetadataRef=saveImage.CGImage;
							[library writeImageToSavedPhotosAlbum:imageMetadataRef metadata:appDelegate.imageMetadata completionBlock:^(NSURL *newURL, NSError *error) {
								if (error) {
								} else {
								}
							}];
						}
						//end edit
						
						NSString *filename = [NSString stringWithFormat:@FORMAT_RENDER,m_quadIndex ];
						[[FileCache sharedCacher] cacheLocalImage:filename image:saveImage];
						ffRenderArgsArray[m_quadIndex].cachedRenderImage = true;
					}
					if(isNeedCreateImage){
						[app updateProgressDegree:1.0];
						[app showProcessProgress:NO];
					}
					
					
					[self performSelectorOnMainThread:@selector(shareOnAll:) withObject:saveImage waitUntilDone:NO];
					
				}
					break;
					
				default:
					break;
			}
		}
	}
	if(isNeedCreateImage){
		[app showProcessProgress:NO];
	}
	
	if(saveImage != nil)
		[saveImage release];
	
	
	if(![workerThread isCancelled])
		[self performSelectorOnMainThread:@selector(saveTerminated:) withObject:@"Finish" waitUntilDone:NO];
	
 	sWorkerThread = nil;
	
	[self performSelectorOnMainThread:@selector(saveStopAnimating:) withObject:@"saveStopAnimating" waitUntilDone:NO];
	[pool release];
	
	isSaveToAlbum = false;
}

- (void)saveTerminated:(NSString *)answer
{
	//[self cancelSave];
	
	//baiwei edit for wrong toolbar state in 2011-5-13
	//m_viewState = 1;
	//	[self setViewState];
	//	
	//	
	//	// Force Render
	//	[self generateInputImages];
	//	//[self renderImages];
	//	//*
	//	//m_viewState = 0;
	//	//[self setViewState];
	//	m_viewState = 1;
	//	[self setWidgetGeometry];
	
	//[self startRenderBackground:false image:nil clearAlpha:true];
	// */
	/*
	 if(s_isCameraPick)
	 [self activateButton:1];
	 else
	 [self activateButton:0];
	 //*/
}

-(void)saveStopAnimating:(NSString *)answer
{
	[spinner stopAnimating];
	[self startRenderBackground:false image:nil clearAlpha:true];
    
    //baiwei add for back to 4up
    //[self back
    

	
}

- (void) refreshRendering{
	[self startRenderBackground:true image:nil clearAlpha:false];
}
- (void)backToFour {

	
#if 0
	numberMode = 4;
    m_viewState = 1;
	
    [UIView beginAnimations:@"Rotate" context:nil];
    [UIView  setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector (animationDidStopAndRender:finished:context:) ];
    [UIView  setAnimationWillStartSelector:@selector (animationWillStart:context:) ];
    
	[self setWidgetGeometry];
	[self setViewState];
    
    [UIView commitAnimations];
	
#else
	
	numberMode = 4;
    m_viewState = 1;
    
    [self setWidgetGeometry];
    [self setViewState];
	
	[NSTimer scheduledTimerWithTimeInterval:0.45 target:self selector:@selector(refreshRendering) userInfo:nil repeats:NO];
	
	
#endif

}
- (void)showFourViewScreen{
    m_viewState = 1;
    
    //[self setWidgetGeometry];
    [self setViewState];
}

- (void)cancelUploasShowOneViewScreen{
    m_viewState = 2;
    
    //[self setWidgetGeometry];
    [self setViewState];
}


/*
 -(bool)cancelSave
 {
 //	if(!isSaving)
 //		return false;
 //	isSaving = false;
 //	[workerThread cancel];
 //	[spinner stopAnimating];
 //#if 1
 //	[self startRenderBackground:true image:nil];
 //#else
 //	[self generateInputImages];
 //	[self renderImages];	
 //#endif
 return true;
 }
 */


- (void)startRenderBackground:(bool)renderInputs image:(UIImage *)image clearAlpha:(bool)clearAlpha
{
 	float x = 320/2.0;
	float y = (480-TOOLBAR_OFFSET_HEIGHT)/2.0;
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		x = 768/2.0;
		y = (1024-TOOLBAR_OFFSET_HEIGHT)/2.0;
	}
	
	float width = spinner.frame.size.width;
	float height = spinner.frame.size.height;
	spinner.frame = CGRectMake(x-width/2.0, TOOLBAR_OFFSET_HEIGHT + y-height/2.0, width, height);
	[[spinner superview] bringSubviewToFront:spinner];
	//	[spinner startAnimating];	
	if(workerThread != nil)
	{
		[workerThread cancel];
		do
		{
			// Spin
		}
		while (![workerThread isFinished]);
		[workerThread release];
	}
	
	if(clearAlpha)
	{
		[topLeftView setImage:nil];
		[topMiddleView setImage:nil];
		[topRightView setImage:nil];
		[middleLeftView setImage:nil];
		[middleMiddleView setImage:nil];
		[middleRightView setImage:nil];
		[bottomLeftView setImage:nil];
		[bottomMiddleView setImage:nil];
		[bottomRightView setImage:nil];
		
		[topLeftView setAlpha:0.f];
		[topMiddleView setAlpha:0.f];
		[topRightView setAlpha:0.f];
		[middleLeftView setAlpha:0.f];
		[middleMiddleView setAlpha:0.f];
		[middleRightView setAlpha:0.f];
		[bottomLeftView setAlpha:0.f];
		[bottomMiddleView setAlpha:0.f];
		[bottomRightView setAlpha:0.f];
	}
	
	if(image!=nil)
	{
		[image retain];
		s_loadedImage = image;
		
		CGSize size = s_loadedImage.size;
		
		NSLog(@"s_loadedImage: %f-%f", size.width,size.height);
		
		workerThread = [[NSThread alloc] initWithTarget:self selector:@selector(backgroundRenderingFull) object:nil];
	}
	else if(renderInputs)
	{
		workerThread = [[NSThread alloc] initWithTarget:self selector:@selector(backgroundRenderingRegular) object:nil];
	}
	else
		workerThread = [[NSThread alloc] initWithTarget:self selector:@selector(backgroundRenderingQuick) object:nil];
	[workerThread start];
	
}


// Rendering the Full res image
//
- (void)backgroundRenderingFull
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self performSelectorOnMainThread:@selector(startAnimating:) withObject:@"startAnimating" waitUntilDone:NO];
	
	sWorkerThread = workerThread;
	
	//	NSLog(@"start");
	//mojoView *pView = (mojoView *)self.view;	
	//	NSLog(@"pView fullImage");
	//[pView setFullImage:fullImage];
	
	if(![workerThread isCancelled])
	{
		[self generateInputImages];
		
		//add by jack 0525
		mojoAppDelegate *app = (mojoAppDelegate*)[[UIApplication sharedApplication] delegate];
		[app showProcessProgress:NO];
		//end add
		
		if(![workerThread isCancelled])
		{
			//add by jack
			for(int i=0;i<9;i++)
			{
				isRefresh[i] = NO;
				if(viewImageArray[i])
				{
					[viewImageArray[i] release];
					viewImageArray[i] = nil;
				}
			}
			//end add
			[self renderImages];
		}
		[s_loadedImage release];
		s_loadedImage = nil;	
	}
	else {
		//add by jack 0525
		mojoAppDelegate *app = (mojoAppDelegate*)[[UIApplication sharedApplication] delegate];
		[app showProcessProgress:NO];
		//end add
	}
	
	
	[self performSelectorOnMainThread:@selector(renderTerminated:) withObject:@"Finish" waitUntilDone:NO];
	sWorkerThread = nil;
	
	
	
	[self performSelectorOnMainThread:@selector(stopAnimating:) withObject:@"stopAnimating" waitUntilDone:NO];
	
	[pool release];
	
	
	//[Utilities printAvailMemory];
}

// Render mid size
//
- (void)backgroundRenderingRegular
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self performSelectorOnMainThread:@selector(startAnimating:) withObject:@"startAnimating" waitUntilDone:NO];
	
	sWorkerThread = workerThread;
	
	
	// add by Guno
	//[self generateInputImages];
	switch (numberMode) {
		case 4:
			portraitImage = portraitImage4;
			break;
		case 9:
			portraitImage = portraitImage9;
			break;
		default:
			portraitImage = portraitImage1;
			break;
	}	
	// end Guno
	
	if(![workerThread isCancelled])
	{
		[self renderImages];
	}
    [self performSelectorOnMainThread:@selector(renderTerminated:) withObject:@"Finish" waitUntilDone:NO];
	
	sWorkerThread = nil;
	
	[self performSelectorOnMainThread:@selector(stopAnimating:) withObject:@"stopAnimating" waitUntilDone:NO];
	[pool release];
}

// Render thumbnail
//
- (void)backgroundRenderingQuick
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self performSelectorOnMainThread:@selector(startAnimating:) withObject:@"startAnimating" waitUntilDone:NO];
	
	sWorkerThread = workerThread;
	[self renderImages];
    [self performSelectorOnMainThread:@selector(renderTerminated:) withObject:@"Finish" waitUntilDone:NO];
	
	sWorkerThread = nil;
	
	[self performSelectorOnMainThread:@selector(stopAnimating:) withObject:@"stopAnimating" waitUntilDone:NO];
	[pool release];
}

- (void)renderTerminated:(NSString *)answer
{
	//[self playSystemSound];
	//	[self cancelRender];
	mojoView *pView = (mojoView *)self.view;		
	[pView setNeedsDisplay];
}

-(void)startAnimating:(NSString *)answer
{
	[spinner startAnimating];
}

-(void)stopAnimating:(NSString *)answer
{
	[spinner stopAnimating];
}
/*
 -(bool)cancelRender
 {
 //	if(!isRendering)
 //		return false;
 //	isRendering = false;
 //	[workerThread cancel];
 //	[spinner stopAnimating];
 return true;
 }
 */

/*
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
 {
 return interfaceOrientation == UIInterfaceOrientationPortrait;
 }
 */

- (IBAction)selectImageView:(id)sender
{
	if(!m_isImageOnceLoaded)
		return;
	int index;
	if(sender == button_topLeftView )
	{
		index = 0;
	}
	else if(sender == button_topRightView )
	{
		index = 1;
	}
	else if(sender == button_bottomLeftView )
	{
		index = 2;
	}
	else  if(sender == button_bottomRightView )
	{
		index = 3;
	}
	else  if(sender == button_topMiddleView )
	{
		index = 4;
	}
	else  if(sender == button_middleLeftView )
	{
		index = 5;
	}
	else  if(sender == button_middleMiddleView )
	{
		index = 6;
	}
	else  if(sender == button_middleRightView )
	{
		index = 7;
	}
	else  if(sender == button_bottomMiddleView )
	{
		index = 8;
	}
	else
		return;
	
	[self selectQuad:index];
	
}

- (IBAction)selectToolBarButton:(id)sender
{
	if(sender == button_save)
	{
		// If in the middle of saving.  Ignore event.
		if (!isSaveToAlbum)
		{
			[self activateButton:1];
		}
	}
	else if(sender == button_back)
	{
		// If in the middle of saving.  Ignore event.
		
		if (!isSaveToAlbum)
		{
			[self activateButton:0];
		}
	}
	else if(sender == button_camera)
	{
		if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) 
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"No camera available.",nil) 
														   delegate:nil 
												  cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
			[alert show];
			[alert release];
			return;
		}
		else{
			m_viewState = 1;
			[self activateButton:1];
		}
	}
	else if(sender == button_library)
	{
		[self activateButton:0];
	}
	else if(sender == button_refresh || sender == button_refresh2)
	{
		if ([workerThread isFinished])
		{
			[self activateButton:2];
		}
		//[self activateButton:2];
	} 
	
	// baiwei add for ipad in 2011-5-12
	else if (sender == button_four) {
		button_four.highlighted = YES;
		button_nine.highlighted = NO;
		
		[self activateButton:3];
	}  else if (sender == button_nine) {
		button_four.highlighted = NO;
		button_nine.highlighted = YES;
		
		[self activateButton:4];
	}
	
	
	else
		return;	
}

- (UIImage*) createNewImage:(UIImage **)_imagePtr
				   imgWidth:(float)_width
				  imgHeight:(float)_height
			   imgParameter:(int)_index
{
	if (!_imagePtr)
		return nil;
	
	UIImage *_image = *_imagePtr;
	if(!_image)
		return nil;
	
#ifdef __MOJO__
	if (_index == -1)
	{
		return createImage(_width, _height, _image);
	}
	else 
	{
		return createImage(_width, _height, _image, &renderArgsArray[_index]);
	}
#else //__PlasticBullet__
	if (_index == -1)
	{
		return [ImageProcess imageNewWithImage:_image scaledToSize:CGSizeMake(_width, _height)];
	}
	else 
	{
		ffRenderArguments pRenderArgs = ffRenderArgsArray[_index];
		CGSize _size = CGSizeMake(_width, _height);
		
		bool doHiRes = false;
		bool doConserveMem = false;
		//		int longside = _width>_height?_width:_height;
		int longside = isFullImageLandscape?_width:_height;
		if(longside >= 2592){//2592
			// hi res
			//
			doHiRes = true;		
			doConserveMem = true;
			//			[self prepTmpArt:0 landscape:_width>_height ];
			[self prepTmpArt:0 landscape:isFullImageLandscape ];
		}
		else if (longside >= 2048)
		{
			// 3GS hi res; OS4 hi res
			//
			doHiRes = true;			
			[self prepTmpArt:0 landscape:isFullImageLandscape ];
		}
		else if (longside >= 1944)
		{
			// OS4 3/4 res
			//
			[self prepTmpArt:0 landscape:isFullImageLandscape ];
			doHiRes = true;			
		}
		else if (longside >= 1536)
		{
			// 3GS 3/4 res; 3G High res
			//
			[self prepTmpArt:0 landscape:isFullImageLandscape ];
			doHiRes = true;			
		}
		else if (longside >= 1200)
		{
			// 3G 3/4 res; OS4 low res
			//
			[self prepTmpArt:0 landscape:isFullImageLandscape ];
			doHiRes = true;			
		}
		else if (longside > 1000)
		{
			// 3GS low res
			//
			[self prepTmpArt:0 landscape:isFullImageLandscape ];
			doHiRes = true;			
		}
		else 
		{
			[self prepTmpArt:800 landscape:isFullImageLandscape ];
			if ( (_width > 320) && (_height > 320) )
			{
				doHiRes = true;
				doConserveMem = false;
			}
		}
		
		UIImage *resultImg = [Renderer imageWithSourceImg:_imagePtr  softImage:blurImage cvVigArtImage:cvVigArtImg cvOpacity:pRenderArgs.cvOpacity SqrVigArtImage:VigArtImg sqrScaleX:pRenderArgs.sqrScaleX sqrScaleY:pRenderArgs.sqrScaleY leakImage:leakImg leakRGB:pRenderArgs.leakTintRGB randStartYIndex1:pRenderArgs.startY1 randStartYIndex2:pRenderArgs.startY2 randStartYIndex3:pRenderArgs.startY3
												imageSize:_size  diffusionOpacity:pRenderArgs.difOpacity SqrVignette:pRenderArgs.SqrOpacity Leakopacity:pRenderArgs.opacity3D CCRGBMaxMinValue:pRenderArgs.CCRGBMaxMin
												  monoRGB:pRenderArgs.rgbValue desatBlendrand:pRenderArgs.blendrand desatRandNum:pRenderArgs.randNum 
											  borderImage: borderImg 
											  borderRandX:pRenderArgs.randX borderRandY:pRenderArgs.randY borderRandS:pRenderArgs.randBorderScale borderRandDoScale:pRenderArgs.randBorderDoScale
											   borderType:pRenderArgs.borderType
											   borderLeft:pRenderArgs.borderLeft
												borderTop:pRenderArgs.borderTop
											  borderRight:pRenderArgs.borderRight
											 borderBottom:pRenderArgs.borderBottom
										   sCurveContrast:pRenderArgs.contrast colorFadeRGBMaxMin:pRenderArgs.colorFadeRGB cornerSoftOpacity:pRenderArgs.cornerOpacity hiRes:doHiRes convserveMemory:doConserveMem
											  isLandscape:isFullImageLandscape];
		if (doHiRes)
		{
			// Release all big assets and revert to small assets
			//
			
			if (cvVigArtImg) [cvVigArtImg release];
			if (VigArtImg) [VigArtImg release];
			if (leakImg) [leakImg release];
			if (borderImg) [borderImg release];
			
			cvVigArtImg = nil;
			VigArtImg = nil;
			leakImg = nil;
			borderImg = nil;
			
			//[self prepTmpArt:800];
		}		
		return resultImg;
	}
#endif
}

- (void) newRenderArg:(int)_index
{
#ifdef __MOJO__
	randomizeRenderArg(renderArgsArray[_index],-1);
#else //__PlasticBullet__
	ffRenderArgsArray[_index] = [self randomImgParameter];
	ffRenderArgsArray[_index].cachedRenderImage = false;
	ffRenderArgsArray[_index].cachedPreviewImage = false;
#endif
}

#ifdef __MOJO__
#else //__PlasticBullet__
#pragma mark Build Random Parameters
-(ffRenderArguments)randomImgParameter//:(ffRenderArguments &)renderArg
{
	ffRenderArguments renderArg;
	//cornerSoft
	renderArg.cornerOpacity =  (arc4random() % 901) / 1000.0f + 0.1f;
	
	//diffusion
	renderArg.difOpacity = (arc4random() % 701) / 1000.0f + 0.1f;
	//circleVignette
	renderArg.cvOpacity = (arc4random() % 701) / 1000.0f + 0.3f;
	//sqrVignette
	renderArg.SqrOpacity = (arc4random() % 801) / 1000.0f + 0.1f;
	renderArg.sqrScaleX = (arc4random() % 1001) / 1000.0f;
	renderArg.sqrScaleY = (arc4random() % 1001) / 1000.0f;
	//leakTint
	renderArg.leakTintRGB.r = (arc4random() % 201)/1000.0f+0.8f;
	renderArg.leakTintRGB.g = (arc4random() % 301)/1000.0f+0.3f;
	renderArg.leakTintRGB.b = (arc4random() % 301)/1000.0f;
	//leak offset
	renderArg.opacity3D.opacity1 = (arc4random() % 1001)/1000.0f;
	renderArg.opacity3D.opacity2 = (arc4random() % 801)/1000.0f;
	renderArg.opacity3D.opacity3 = (arc4random() % 501)/1000.0f;
	
	renderArg.startY1 = (arc4random() % 1001)/1000.0f;
	renderArg.startY2 = (arc4random() % 1001)/1000.0f;
	renderArg.startY3 = (arc4random() % 1001)/1000.0f;
	//colorClip
	renderArg.CCExpose = ((arc4random() % 601)/1000.0f) - 0.25f;
	//r
	renderArg.CCRGBMaxMin.rMin = ((arc4random() % 1001)/1000.0f) * 0.3f;
	renderArg.CCRGBMaxMin.rMax = ((arc4random() % 1001)/1000.0f) * 0.25f + 0.75f - renderArg.CCExpose;
	//g
	renderArg.CCRGBMaxMin.gMin = ((arc4random() % 1001)/1000.0f) * 0.1f;
	renderArg.CCRGBMaxMin.gMax = ((arc4random() % 1001)/1000.0f) * 0.2f + 0.8f - renderArg.CCExpose;
	//b
	renderArg.CCRGBMaxMin.bMin = 0.0f;
	renderArg.CCRGBMaxMin.bMax = 1.0f - renderArg.CCExpose;
	
	//monoChrome
	renderArg.rgbValue.r = ((arc4random() % 1001)/1000.0f) * 0.5f + 0.5f;
	renderArg.rgbValue.g = ((arc4random() % 1001)/1000.0f) * 0.5f + 0.5f;
	renderArg.rgbValue.b = ((arc4random() % 1001)/1000.0f) * 0.45f + 0.05f;
	//desat
	renderArg.blendrand = ((arc4random() % 1001)/1000.0f) * 0.65f + 0.05f;
	renderArg.randNum = arc4random() % 100;
	//border
	renderArg.randX = (arc4random() % 2) * 1.0f;
	renderArg.randY = (arc4random() % 2) * 1.0f;
	renderArg.randBorderScale = (arc4random() % 301) / 1000.0f + 1.0f;
	renderArg.randBorderDoScale = (arc4random() % 2) * 1.0f;
	
	// new boder random numbers
	renderArg.borderType = (arc4random() % 4);
	renderArg.borderLeft = (arc4random() % 10);
	renderArg.borderTop = (arc4random() % 10);
	renderArg.borderRight = (arc4random() % 10);
	renderArg.borderBottom = (arc4random() % 10);
	
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
#endif


#define kGestureXVariance 200
#define kGestureYVariance 200
static CGPoint s_gestureStartPoint;

#pragma mark -
#pragma mark touch
- (void) touchesCanceled 
{
}
- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event 
{
	NSSet *allTouches = [event allTouches];
    switch ([allTouches count]) {
        case 1: {
            UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
            CGPoint currentLocation = [touch locationInView:self.view];
			s_gestureStartPoint = currentLocation;
			
        }
			break;
        default:
            break;
    }
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event 
{
	NSSet *allTouches = [event allTouches];
    switch ([allTouches count]) 
	{
        case 1: 
		{
			UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
			CGPoint currentLocation = [touch locationInView:self.view];			
			
			float deltaX = currentLocation.x - s_gestureStartPoint.x;
			float deltaY = currentLocation.y - s_gestureStartPoint.y;
			
			if(fabsf(deltaX) >= kGestureXVariance || fabsf(deltaY) >= kGestureYVariance)
			{
				// As if Refresh button is click
				//
				[self selectToolBarButton:button_refresh];
			}
			
        } 
			break;
        default:
            break;
    }
	
}
- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event 
{
	NSSet *allTouches = [event allTouches];	
    switch ([allTouches count]) {
        case 1: 
		{
            UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
            switch (touch.tapCount) 
			{
                case 1: 
				{	
					if (m_viewState == 1)
					{
						float nowFrameWidth  = 320.0;
						float nowFrameHeight = 480.0;
						if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
						{
							nowFrameWidth  = 768.0;
							nowFrameHeight = 1024.0;
						}
						
						CGPoint currentLocation = [touch locationInView:self.view];	
                        
                        //baiwei add for toolbar click
                        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                            if (nowInterfaceOrientation == UIInterfaceOrientationPortrait)
                            {
                                if (currentLocation.y < TOOLBAR_OFFSET_HEIGHT) {
                                    return;
                                }
                                
                            } else if (nowInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
                                if (currentLocation.y > 1024 - TOOLBAR_OFFSET_HEIGHT) {
                                    return;
                                }
                                
                                
                            } else if (nowInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
                                if (currentLocation.x > 768 - TOOLBAR_OFFSET_HEIGHT) {
                                    return;
                                }
                                
                                
                            } else {
                                
                                if (currentLocation.x < TOOLBAR_OFFSET_HEIGHT ) {
                                    return;
                                }
                                
                            }
                        } else { //iphone
                            if (currentLocation.y < TOOLBAR_OFFSET_HEIGHT) {
                                return;
                            }
                        }
                        
                        
						
						if (numberMode == 4) {
							if ( currentLocation.x < nowFrameWidth/2 )
							{
								if ( currentLocation.y < TOOLBAR_OFFSET_HEIGHT+(nowFrameHeight-TOOLBAR_OFFSET_HEIGHT)/2 )
								{
                                    
                                    
									[self selectImageView:button_topLeftView];
								}
								else {
									[self selectImageView:button_bottomLeftView];
								}
							}
							else
							{
								if ( currentLocation.y < TOOLBAR_OFFSET_HEIGHT+(nowFrameHeight-TOOLBAR_OFFSET_HEIGHT)/2 )
								{
									[self selectImageView:button_topRightView];
								}
								else {
									[self selectImageView:button_bottomRightView];
								}
							}
						} else if (numberMode == 9) {
							if ( currentLocation.x < nowFrameWidth/3 )
							{
								if ( currentLocation.y < TOOLBAR_OFFSET_HEIGHT+(nowFrameHeight-TOOLBAR_OFFSET_HEIGHT)/3 )
								{
									[self selectImageView:button_topLeftView];
								} else if (TOOLBAR_OFFSET_HEIGHT+(nowFrameHeight-TOOLBAR_OFFSET_HEIGHT)/3 < currentLocation.y and currentLocation.y < TOOLBAR_OFFSET_HEIGHT+(nowFrameHeight-TOOLBAR_OFFSET_HEIGHT)*2/3) {
									[self selectImageView:button_middleLeftView];
								} else {
									[self selectImageView:button_bottomLeftView];
								}
							} else if (nowFrameWidth/3 < currentLocation.x and currentLocation.x < nowFrameWidth*2/3) {
								if ( currentLocation.y < TOOLBAR_OFFSET_HEIGHT+(nowFrameHeight-TOOLBAR_OFFSET_HEIGHT)/3 )
								{
									[self selectImageView:button_topMiddleView];
								} else if (TOOLBAR_OFFSET_HEIGHT+(nowFrameHeight-TOOLBAR_OFFSET_HEIGHT)/3 < currentLocation.y and currentLocation.y < TOOLBAR_OFFSET_HEIGHT+(nowFrameHeight-TOOLBAR_OFFSET_HEIGHT)*2/3) {
									[self selectImageView:button_middleMiddleView];
								} else {
									[self selectImageView:button_bottomMiddleView];
								}
							} else {
								if ( currentLocation.y < TOOLBAR_OFFSET_HEIGHT+(nowFrameHeight-TOOLBAR_OFFSET_HEIGHT)/3 )
								{
									[self selectImageView:button_topRightView];
								} else if (TOOLBAR_OFFSET_HEIGHT+(nowFrameHeight-TOOLBAR_OFFSET_HEIGHT)/3 < currentLocation.y and currentLocation.y < TOOLBAR_OFFSET_HEIGHT+(nowFrameHeight-TOOLBAR_OFFSET_HEIGHT)*2/3) {
									[self selectImageView:button_middleRightView];
								} else {
									[self selectImageView:button_bottomRightView];
								}
							}
							
						}
						
						
					}
				}
					break;
				default:
					break;
            }
        }
			break;
		default:
			break;
	}
}

// Get default save camera original setting
//
- (bool) isSaveCameraShot
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults boolForKey:@"save_camera_shot"];
}

- (int) isHalfResolution
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults integerForKey:@"resolution_select"]==0;
}

- (bool) is3QuarterResolution
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults integerForKey:@"resolution_select"]==1;
}

- (CGSize) getMaxResolution
{
	CGSize maxSize;
	NSString* machine = [self getDeviceName];
	if ( [machine hasPrefix:@"iPhone1,"] )
	{
		maxSize.width = 1400; //1500; //1600;
		maxSize.height = 1050; //1125; //1200;
	}
	else if ( [machine hasPrefix:@"iPod"] )
	{
		maxSize.width = 800;
		maxSize.height = 600;
	}
	else if ( [machine hasPrefix:@"iPhone2,"] )
	{
		maxSize.width = 2048;
		maxSize.height = 1536;		
	}
	else if ( [machine hasPrefix:@"iPhone3,"] )
	{
		// OS 4
		maxSize.width = 2592;
		maxSize.height = 1936;		
	}
	else if ( [machine hasPrefix:@"iPad"] )
	{
		// iPad
		//Modify by jack
		maxSize.width = 4000;//2592;
		maxSize.height = 3000;//1944;		
	}
	else
	{
		// Future Hi-res product
		//
		maxSize.width = 2592;
		maxSize.height = 1944;
	}
	return maxSize;
}

- (CGSize) getMaxRenderResolution:(CGSize)imgres
{
	CGSize maxResolution = [self getMaxResolution];
	
	sPostRenderScale = false;
	if (imgres.width > imgres.height)
	{
		if (imgres.width > maxResolution.width)
		{
			sPostRenderScale = true;
			sRenderTarget.width = imgres.width;
			sRenderTarget.height = imgres.height;
			
			imgres.width = maxResolution.width;
			imgres.height = maxResolution.height;
		}
	}
	else 
	{
		if (imgres.height > maxResolution.width)
		{
			sPostRenderScale = true;
			sRenderTarget.width = imgres.width;
			sRenderTarget.height = imgres.height;
			
			imgres.height = maxResolution.width;
			imgres.width = maxResolution.height;
		}
	}
	
	return imgres;
}

#include <sys/types.h>
#include <sys/sysctl.h>
- (NSString *)getDeviceName
{
	// Device Name:
	// iPone1,2 = 3G iPhone
	// iPhone2,1 = 3GS iPhone
	// iPhone3,1 = iPhone4
	// iPod1,2 = 1st gen iPod
	// iPod2,1 = 2nd gen iPod
	// iPod3,1 = 4th gen iPod
	// iPad... = iPad
	// i386 = simulator
	//
	
	size_t size;
	
	// Set 'oldp' parameter to NULL to get the size of the data
	// returned so we can allocate appropriate amount of space
	sysctlbyname("hw.machine", NULL, &size, NULL, 0); 
	
	// Allocate the space to store name
	char *name = (char*) malloc(size);
	
	// Get the platform name
	sysctlbyname("hw.machine", name, &size, NULL, 0);
	
	// Place name into a string
	//NSString *machine = [NSString stringWithCString:name];
	
	NSString *machine = [NSString stringWithUTF8String:name];
	
	// Done with this
	free(name);
	
	return machine;
}

- (bool) isLowRes
{
	bool lowRes = false;
	NSString* machine = [self getDeviceName];
	if ( [machine hasPrefix:@"iPod"] )
	{
		lowRes = true;
	}
	else if ( [machine isEqualToString:@"iPhone1,2"] )
	{
		lowRes = true;
	}
	return lowRes;
}

- (bool) useFacebook
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults boolForKey:@"use_facebook"];
}

- (bool) useFlickr
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults boolForKey:@"use_flickr"];
}

- (void) printAvailMem
{
#ifdef __DEBUG_PB__
	char *membuffer = nil;
	int maxSize = 600000000;
	while ( !(membuffer = (char*) malloc(maxSize)) )
	{
		maxSize -= 1000000;
	}
	NSLog(@"AVAILABLE MEMORY %d",maxSize);
	free (membuffer);
#endif
}

- (void) resetNumberModel{
	numberMode = 1;
}

@end
