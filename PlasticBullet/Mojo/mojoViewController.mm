//
//  mojoViewController.mm
//  mojo
//


#define TOOLBAR_OFFSET_HEIGHT 44
#define ICON_SIZE 24
#define DOT_SIZE 80
#define BORDER_SIZE 5

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
 #import "mojoAppDelegate.h"
#import "DataTypeDef.h"
// #import "PostToFacebookViewController.h"
// #import "PostToFlickrViewController.h"

#import "Utilities.h"

// #import <AssetsLibrary/AssetsLibrary.h>

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

//static bool isNineMode = false;

//static UIActionSheet *actionSheet = nil;

//add by Guno
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
@synthesize delegate;
@synthesize renderer;
@synthesize originalImage;
//@synthesize button1;
//@synthesize spinner;
//@synthesize soundFileURLRef;
//@synthesize soundFileObject;
@synthesize focusedView;
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


#ifdef __MOJO__
#else //__PlasticBullet__
@synthesize cvVigArtImg;
@synthesize leakImg;
@synthesize VigArtImg;
@synthesize borderImg;
@synthesize blurImage;
#endif


//@synthesize pView;
@synthesize portraitImage;
//save small pictures array
static UIImage *viewImageArray[9] = {nil};

@synthesize navigationFlickr;
@synthesize navigationFacebook;
@synthesize flickrSession;

@synthesize saveToState;

@synthesize postToAllViewController;

@synthesize shareProgressView;

@synthesize nowInterfaceOrientation;



int loadTime = 0;
- (void)viewDidLoad 
{
	if (loadTime == 1) {
		return;
	}
	loadTime = 1;
	[super viewDidLoad];
	
	NSLog(@"=====");
	
	m_isImageOnceLoaded = false;
	doScale = false;
	isInverted = false;
	isPortrait = true;
	isSaveToAlbum = false;
	workerThread = nil;
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		numberMode = 9;
	} else {
		numberMode = 4;
	}
	
	
	
	
//	[self setWidgetGeometry];
//	[self setViewState];
	
	
	
	//theLock = [[NSRecursiveLock alloc] init];
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

- (void)focusImage:(UIImageView *)view {
    numberMode = 1;
    self.focusedView = view;
//    [self renderImage:self.originalImage];
    [self startRenderBackground:true image:nil clearAlpha:false];
}

- (void)defocusImage {
    numberMode = (int)gridMode;
}

- (void)initGrid:(GRID_MODE)mode {
    gridMode = mode;
    numberMode = (int)mode;
}

- (void)checkTimeOut:(id)sender
{
	[locationManager stopUpdatingLocation];
	locationManager.delegate = nil;
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs removeObjectForKey:@"latitude"];
	[prefs removeObjectForKey:@"longitude"];
}

- (void)setRotations {
    
	float rotate = 0.f;
    float scale = 1.f;
    
	if(!isPortrait)
	{
		if(isInverted) {
			rotate = M_PI/2.0;
		}
		else {
			rotate = -M_PI/2.0;
		}
        
        // When in portrait, we need to shrink the images to fit the new aspect ratio
        // if they don't MATCH
        // shoot
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
    
    // in the "unnatural" orientation. Always requires scaling!
    // convert to units of view width
    if (!isPortrait) {
        CGFloat widthScale = self.topLeftView.bounds.size.width / self.originalImage.size.width;
        CGFloat heightScale = self.topLeftView.bounds.size.height / self.originalImage.size.height;
        CGFloat imageScale = MIN(widthScale, heightScale);
        scale = self.topLeftView.bounds.size.width / (imageScale * self.originalImage.size.height);
    }
	
	CGAffineTransform m = CGAffineTransformMakeRotation(rotate);
    CGAffineTransform n = CGAffineTransformMakeScale(scale, scale);
    CGAffineTransform mn = CGAffineTransformConcat(m, n);

	topRightView.transform = mn;
	topMiddleView.transform = mn;
	topLeftView.transform = mn;
	middleRightView.transform = mn;
	middleMiddleView.transform = mn;
	middleLeftView.transform = mn;
	bottomRightView.transform = mn;
	bottomMiddleView.transform = mn;
	bottomLeftView.transform = mn;
    
    [delegate mojoDidRotate:isPortrait rotation:rotate scale:scale];
}

- (BOOL)isOriginalImagePortrait {
    return self.originalImage.size.width < self.originalImage.size.height;
}


- (void)setAcceleration:(CMAcceleration)acceleration
{
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
        
        doScale = true;
        [self setRotations];
        doScale = false;
        
        [UIView commitAnimations];
        
        return;
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
	CGFloat inputWidth = CGImageGetWidth( image.CGImage );
	CGFloat inputHeight = CGImageGetHeight( image.CGImage );
	
	//int retainCount1 = [fullImage retainCount];
	//	
	//	// FullSize
	//	if (fullImage!=nil)
	//	{
	//		[fullImage release];
	//		fullImage = nil;
	//	}
	
//	[Utilities printAvailMemory];
	
    UIImage * newFullImage = [self createNewImage:&image imgWidth:inputWidth imgHeight:inputHeight imgParameter:-1];
	
	CGSize size2 = newFullImage.size;
	NSLog(@"load image size: %f : %f", size2.width,size2.height);
	
	// add by Guno
	inputWidth = roundf(CGImageGetWidth( newFullImage.CGImage ));
	inputHeight = roundf(CGImageGetHeight( newFullImage.CGImage ));
    
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
	portraitImage1 = [self createNewImage:&newFullImage imgWidth:width1 imgHeight:height1 imgParameter:-1];
	
	portraitImage4 = [self createNewImage:&newFullImage imgWidth:width4 imgHeight:height4 imgParameter:-1];
	
	portraitImage9 = [self createNewImage:&newFullImage imgWidth:width9 imgHeight:height9 imgParameter:-1];
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
	[Utilities cacheToFileFromImage:newFullImage filename:ORIGINAL_IMAGE_FILE_NAME];
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
	
	int theWidth = roundf(CGImageGetWidth(lutImage.CGImage));
	int theHeight = roundf(CGImageGetHeight(lutImage.CGImage));
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
	
	
	int _width = roundf(CGImageGetWidth(sourceImage.CGImage));
	int _height = roundf(CGImageGetHeight(sourceImage.CGImage));
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
	
	CGContextRef context = CGBitmapContextCreate(pout, _width, _height, 8, _width*4, colorSpace, bitmapInfo);
	CGImageRef imageRef = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	free(pout); 

	
	UIImage* newImage = [[UIImage alloc] initWithCGImage:imageRef];
	CGImageRelease(imageRef);
	
	
	//UIImageWriteToSavedPhotosAlbum(newImage, self, nil, nil);
	
    return newImage;
	
}

//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
//
// REFACTOR image metadata
//	UIInterfaceOrientation toInterfaceOrientation = self.interfaceOrientation;
//
//	baiwei add for imageMetadata
//	UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
//    mojoAppDelegate *appDelegate = (mojoAppDelegate*)[mojoAppDelegate fakeAppDelegate];
//
//	if ( picker.sourceType == UIImagePickerControllerSourceTypeCamera ) //from camera
//	{
//		float version = [[[UIDevice currentDevice] systemVersion] floatValue];
//		if (version > 4.1) {
//			appDelegate.imageMetadata = [info objectForKey:@"UIImagePickerControllerMediaMetadata"];
//			
//			NSMutableDictionary *GPS = [[NSMutableDictionary alloc]init];
//			NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//			double latitude = [prefs doubleForKey: @"latitude"];
//			double longitude = [prefs doubleForKey: @"longitude"];
//			
//			//[GPS setObject:@"126.603" forKey:@"ImgDirection"];
//			//				[GPS setObject:@"T" forKey:@"ImgDirectionRef"];
//			
//			[GPS setObject:[NSNumber numberWithDouble:latitude] forKey:@"Latitude"];
//			if (latitude > 0) {
//				[GPS setObject:@"N" forKey:@"LatitudeRef"];
//			} else {
//				[GPS setObject:@"S" forKey:@"LatitudeRef"];
//			}
//			
//			[GPS setObject:[NSNumber numberWithDouble:longitude] forKey:@"Longitude"];
//			if (latitude > 0) {
//				[GPS setObject:@"E" forKey:@"LongitudeRef"];
//			} else {
//				[GPS setObject:@"W" forKey:@"LongitudeRef"];
//			}
//			
//			NSDate *date = [NSDate date];
//			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//			[formatter setDateFormat:@"HH:mm:ss"];
//			NSString *dateString = [formatter stringFromDate:date];
//			[GPS setObject:dateString forKey:@"TimeStamp"];
//			
//			[appDelegate.imageMetadata setObject:GPS forKey:@"{GPS}"];
//			
//			NSLog(@"imageMetadata2=%@", appDelegate.imageMetadata);
//			
//		} else {
//			appDelegate.imageMetadata = nil;
//		}
//		
//		
//		if ([self isSaveCameraShot])
//		{
//			if (appDelegate.imageMetadata == nil) {
//				UIImageWriteToSavedPhotosAlbum(originalImage, self, nil, nil); 
//			} else {
////                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
////				CGImageRef imageMetadataRef=originalImage.CGImage;
////				[library writeImageToSavedPhotosAlbum:imageMetadataRef metadata:appDelegate.imageMetadata completionBlock:^(NSURL *newURL, NSError *error) {
////					if (error) {
////					} else {
////					}
////				}];
//			}
//		}
//	} else { //from Lib
//		float version = [[[UIDevice currentDevice] systemVersion] floatValue];
//		if (version > 4.1) {
//			NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
//			
//			ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//			[library assetForURL:assetURL
//					 resultBlock:^(ALAsset *asset)  {
//						 NSDictionary *metadata = asset.defaultRepresentation.metadata;
//						 
//						 appDelegate.imageMetadata = [[NSMutableDictionary alloc] initWithDictionary:metadata];
//						 
//					 }
//					failureBlock:^(NSError *error) {
//					}];
//		} else {
//			appDelegate.imageMetadata = nil;	
//		}
//	}
//	//end add
//	
//
//	//s_isCameraPick = true;
//	
//	//baiwei add for dismisspopover
//}

-(void)renderImage:(UIImage *)image {
	
    self.originalImage = nil;
	m_isImageOnceLoaded = true;
	
	//[self setWidgetGeometry];
	
	// Randomize and clear cache
	for(int i=0;i<9;i++)
	{
		[self newRenderArg:i];
		isRefresh[i] = NO;
		if(viewImageArray[i])
		{
			viewImageArray[i] = nil;
		}
	}
	
	CGSize size = image.size;
	NSLog(@"load image size: %f : %f", size.width,size.height);
	
	//baiwei add for memery resolution
	
// REFACTOR: warnings for min / max size images. worth it?
	
	//Added by jack
	//Cache the raw data of image
	//[Utilities cacheToRawDataFromImage:image filename:ORIGINAL_IMAGE_FILE_NAME];
	//[Utilities cacheToRawDataFromImage:image filename:RENDER_SOURCE_FILE_NAME];
	
	if(image == nil)return;
	
	
	//add by jack 0525
    mojoAppDelegate *app = (mojoAppDelegate*)[mojoAppDelegate fakeAppDelegate];
	[app showInitialiationView];
	[app hiddenProgressViewBar];
	//end add
	
	
	//add by jack 2011-07-18
	//iPhone 4 reverse contrast curve definition
	NSString* machine = [self getDeviceName];
	if ( [machine hasPrefix:@"iPhone3,"] && isImageFromCamera){
		int inputWidth = roundf(CGImageGetWidth( image.CGImage ));
		int inputHeight = roundf(CGImageGetHeight( image.CGImage ));
		image = [ImageProcess imageNewWithImage:image scaledToSize:CGSizeMake(inputWidth, inputHeight)];
		image = [self uncontrastiPhone4Image:image];
	}
	//end add
	
//	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//	{
//		numberMode = 9;
//	} else {
//		numberMode = 4;
//	}
	
	[Utilities printAvailMemory];
#ifdef CROP_RATIO_4_3
	UIImage *tmpImage = [self prepSourceImg:image];
	[self prepTmpImg:tmpImage];
	
	[self startRenderBackground:true image:tmpImage clearAlpha:true];
#else
	UIImage *tmpImage = image;
	[self prepTmpImg:tmpImage];
	
	//CGSize size2 = tmpImage.size;
	//	NSLog(@"load image size: %f : %f", size2.width,size2.height);
	
    self.originalImage = image;
    
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
	int xOffset = 0;
	int yOffset = 0;
	int cropWidth = 0;
	int cropHeight = 0;
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
		resultImg = [[UIImage alloc]initWithCGImage:tempRef];
		CGImageRelease(tempRef);		
	}
	
	return resultImg;
	
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
		switch (resolution) {
			case 3000:
			{
                leakImg = [UIImage imageNamed:PROCESS_LEAK_6K];
				if (_landscape)
				{
					//					cvVigArtImg = [[UIImage imageNamed:PROCESS_VIGART_LANDSCAPE_2K]retain];
					//					VigArtImg = [[UIImage imageNamed:PROCESS_SQRVIG_LANDSCAPE_2K]retain];
                    borderImg = [UIImage imageNamed:PROCESS_BORDER_LANDSCAPE_4K];
				}
				else
				{
					//					cvVigArtImg = [[UIImage imageNamed:PROCESS_VIGART_2K]retain];
					//					VigArtImg = [[UIImage imageNamed:PROCESS_SQRVIG_2K]retain];
                    borderImg = [UIImage imageNamed:PROCESS_BORDER_4K];
				}
			}
				break;
			case 2592:
                leakImg = [UIImage imageNamed:PROCESS_LEAK_2K];
				if (_landscape)
				{
					//					cvVigArtImg = [[UIImage imageNamed:PROCESS_VIGART_LANDSCAPE_2K]retain];
					//					VigArtImg = [[UIImage imageNamed:PROCESS_SQRVIG_LANDSCAPE_2K]retain];
                    borderImg = [UIImage imageNamed:PROCESS_BORDER_LANDSCAPE_2K];
				}
				else
				{
					//					cvVigArtImg = [[UIImage imageNamed:PROCESS_VIGART_2K]retain];
					//					VigArtImg = [[UIImage imageNamed:PROCESS_SQRVIG_2K]retain];
                    borderImg = [UIImage imageNamed:PROCESS_BORDER_2K];
				}
				break;
			case 2048:
                leakImg = [UIImage imageNamed:PROCESS_LEAK_2K];
				if (_landscape)
				{
					//					cvVigArtImg = [[UIImage imageNamed:PROCESS_VIGART_LANDSCAPE_2K]retain];
					//					VigArtImg = [[UIImage imageNamed:PROCESS_SQRVIG_LANDSCAPE_2K]retain];
                    borderImg = [UIImage imageNamed:PROCESS_BORDER_LANDSCAPE_2K];
				}
				else
				{
					//					cvVigArtImg = [[UIImage imageNamed:PROCESS_VIGART_2K]retain];
					//					VigArtImg = [[UIImage imageNamed:PROCESS_SQRVIG_2K]retain];
                    borderImg = [UIImage imageNamed:PROCESS_BORDER_2K];
				}
				break;
			case 1600:
                leakImg = [UIImage imageNamed:PROCESS_LEAK_1K];
				if (_landscape)
				{
					//					cvVigArtImg = [[UIImage imageNamed:PROCESS_VIGART_LANDSCAPE_1K]retain];
					//					VigArtImg = [[UIImage imageNamed:PROCESS_SQRVIG_LANDSCAPE_1K]retain];
                    borderImg = [UIImage imageNamed:PROCESS_BORDER_LANDSCAPE_1K];
				}
				else
				{
					//					cvVigArtImg = [[UIImage imageNamed:PROCESS_VIGART_1K]retain];
					//					VigArtImg = [[UIImage imageNamed:PROCESS_SQRVIG_1K]retain];
                    borderImg = [UIImage imageNamed:PROCESS_BORDER_1K];
				}
				break;
			case 1024:
                leakImg = [UIImage imageNamed:PROCESS_LEAK_1K];
				if (_landscape)
				{
					//					cvVigArtImg = [[UIImage imageNamed:PROCESS_VIGART_LANDSCAPE_1K]retain];
					//					VigArtImg = [[UIImage imageNamed:PROCESS_SQRVIG_LANDSCAPE_1K]retain];
                    borderImg = [UIImage imageNamed:PROCESS_BORDER_LANDSCAPE_1K];
				}
				else
				{
					//					cvVigArtImg = [[UIImage imageNamed:PROCESS_VIGART_1K]retain];
					//					VigArtImg = [[UIImage imageNamed:PROCESS_SQRVIG_1K]retain];
                    borderImg = [UIImage imageNamed:PROCESS_BORDER_1K];
				}
				break;
			case 800:
                leakImg = [UIImage imageNamed:PROCESS_LEAK];
				if (_landscape)
				{
					//					cvVigArtImg = [[UIImage imageNamed:PROCESS_VIGART_LANDSCAPE]retain];
					//					VigArtImg = [[UIImage imageNamed:PROCESS_SQRVIG_LANDSCAPE]retain];
                    borderImg = [UIImage imageNamed:PROCESS_BORDER_LANDSCAPE];
				}
				else
				{
					//					cvVigArtImg = [[UIImage imageNamed:PROCESS_VIGART]retain];
					//					VigArtImg = [[UIImage imageNamed:PROCESS_SQRVIG]retain];
                    borderImg = [UIImage imageNamed:PROCESS_BORDER];
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
	
	int width = roundf(CGImageGetWidth(_image.CGImage));
	int height = roundf(CGImageGetHeight(_image.CGImage));
	
	prevWidth = 0;
	//    [self prepTmpArt:800 landscape:width > height ];
    [self prepTmpArt:800 landscape:isFullImageLandscape ];
	
	// Repare for Blurred Soft Image
	//
	if (blurImage){
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
		
		blurImage = [self.renderer blurImg:tmpImage2];
		if (blurImage)
		{
			tmpImage2 = [self.renderer blurImg:blurImage];
			if ( tmpImage2 )
			{
				blurImage = tmpImage2;
			}
		}
	}
	
#endif
}



- (int)renderImages
{
	//mojoView *pView = (mojoView *)self.view;
    CGFloat width = 0;
    CGFloat height = 0;
	int numRenderIndexs = 1;
	int renderIndex = 0;
    NSArray * imageViewArray = @[self.topLeftView, self.topRightView, self.bottomLeftView, self.bottomRightView, self.topMiddleView, self.middleLeftView, self.middleMiddleView, self.middleRightView, self.bottomMiddleView];
	
	if (numberMode == 4) {
		numRenderIndexs = 4;
	} else if (numberMode == 9) {
		numRenderIndexs = 9;
	} else {
        renderIndex = (int)[imageViewArray indexOfObject:self.focusedView];
        isRefresh[renderIndex] = YES;
		numRenderIndexs = renderIndex+1;
	}
	
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
		
		
        UIImage *portraitImageCopy = [UIImage imageWithCGImage:[self.portraitImage CGImage]];
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
//			if(m_viewState==1)
//			{
				if(isRefresh[index]||(!viewImageArray[index]))
				{
					pOutputImage = [self createNewImage:&portraitImageCopy imgWidth:width imgHeight:height imgParameter:index];
                    
					if(pOutputImage)
					{
						if(viewImageArray[index])
						{
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
//			}
//			else if(m_viewState==2)
//			{
//				if (ffRenderArgsArray[index].cachedPreviewImage)
//				{
//					NSString *filename = [NSString stringWithFormat:@FORMAT_PREVIEW,index ];
//                    pOutputImage = [[FileCache sharedCacher] cachedLocalImage:filename];
//				}
//				else
//				{
//					pOutputImage = [self createNewImage:&portraitImageCopy imgWidth:width imgHeight:height imgParameter:index];
//					if (pOutputImage)
//					{
//						NSString *filename = [NSString stringWithFormat:@FORMAT_PREVIEW,index ];
//						[[FileCache sharedCacher] cacheLocalImage:filename image:pOutputImage];
//						ffRenderArgsArray[index].cachedPreviewImage = true;
//					}
//				}
//			}
			//NSLog(@"pOutputImage = %d", [viewImageArray[index] retainCount]);
			if(pOutputImage)
			{
				[imageViewArray[index] performSelectorOnMainThread:@selector(setImage:) withObject:pOutputImage waitUntilDone:NO];	
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
//			if(m_viewState==1)
//			{
				//		NSLog(@"m_viewState=1");
				if(isRefresh[index] || !viewImageArray[index] ) 
				{
					pOutputImage = [self createNewImage:&landscapeImage imgWidth:width imgHeight:height imgParameter:index];
					if(pOutputImage)
					{
						if(viewImageArray[index])
						{
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
//			}//*
//			else if(m_viewState==2)
//			{
//				if (ffRenderArgsArray[index].cachedPreviewImage)
//				{
//					NSString *filename = [NSString stringWithFormat:@FORMAT_PREVIEW,index ];
//                    pOutputImage = [[FileCache sharedCacher] cachedLocalImage:filename];
//				}
//				else
//				{
//					pOutputImage = [self createNewImage:&landscapeImage imgWidth:width imgHeight:height imgParameter:index];
//					if (pOutputImage)
//					{
//						NSString *filename = [NSString stringWithFormat:@FORMAT_PREVIEW,index ];
//						[[FileCache sharedCacher] cacheLocalImage:filename image:pOutputImage];
//						ffRenderArgsArray[index].cachedPreviewImage = true;
//					}
//				}
//			}
			if(pOutputImage)
			{
				[imageViewArray[index] performSelectorOnMainThread:@selector(setImage:) withObject:pOutputImage waitUntilDone:NO];	
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


- (void) refreshRendering{
	[self startRenderBackground:true image:nil clearAlpha:false];
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
	
//	float width = spinner.frame.size.width;
//	float height = spinner.frame.size.height;
//	spinner.frame = CGRectMake(x-width/2.0, TOOLBAR_OFFSET_HEIGHT + y-height/2.0, width, height);
//	[[spinner superview] bringSubviewToFront:spinner];
	//	[spinner startAnimating];
	if(workerThread != nil)
	{
		[workerThread cancel];
		do
		{
			// Spin
		}
		while (![workerThread isFinished]);
	}
	
	if(clearAlpha)
	{
//		[topLeftView setImage:nil];
//		[topMiddleView setImage:nil];
//		[topRightView setImage:nil];
//		[middleLeftView setImage:nil];
//		[middleMiddleView setImage:nil];
//		[middleRightView setImage:nil];
//		[bottomLeftView setImage:nil];
//		[bottomMiddleView setImage:nil];
//		[bottomRightView setImage:nil];
		
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
		mojoAppDelegate *app = (mojoAppDelegate*)[mojoAppDelegate fakeAppDelegate];
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
					viewImageArray[i] = nil;
				}
			}
			//end add
			[self renderImages];
		}
		s_loadedImage = nil;
	}
	else {
		//add by jack 0525
        mojoAppDelegate *app = (mojoAppDelegate*)[mojoAppDelegate fakeAppDelegate];
		[app showProcessProgress:NO];
		//end add
	}
	
	
	[self performSelectorOnMainThread:@selector(renderTerminated:) withObject:@"Finish" waitUntilDone:NO];
	sWorkerThread = nil;
	
	
	
	[self performSelectorOnMainThread:@selector(stopAnimating:) withObject:@"stopAnimating" waitUntilDone:NO];
	
	//[Utilities printAvailMemory];
}

// Render mid size
//
- (void)backgroundRenderingRegular
{
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
}

// Render thumbnail
//
- (void)backgroundRenderingQuick
{
	[self performSelectorOnMainThread:@selector(startAnimating:) withObject:@"startAnimating" waitUntilDone:NO];
	
	sWorkerThread = workerThread;
	[self renderImages];
    [self performSelectorOnMainThread:@selector(renderTerminated:) withObject:@"Finish" waitUntilDone:NO];
	
	sWorkerThread = nil;
	
	[self performSelectorOnMainThread:@selector(stopAnimating:) withObject:@"stopAnimating" waitUntilDone:NO];
}

- (void)renderTerminated:(NSString *)answer
{
	//[self playSystemSound];
	//	[self cancelRender];
}

-(void)startAnimating:(NSString *)answer
{
//	[spinner startAnimating];
    [self.delegate mojoIsWorking:YES];
}

-(void)stopAnimating:(NSString *)answer
{
//	[spinner stopAnimating];
    [self.delegate mojoIsWorking:NO];
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

//- (IBAction)selectImageView:(id)sender
//{
//	if(!m_isImageOnceLoaded)
//		return;
//	int index;
//	if(sender == button_topLeftView )
//	{
//		index = 0;
//	}
//	else if(sender == button_topRightView )
//	{
//		index = 1;
//	}
//	else if(sender == button_bottomLeftView )
//	{
//		index = 2;
//	}
//	else  if(sender == button_bottomRightView )
//	{
//		index = 3;
//	}
//	else  if(sender == button_topMiddleView )
//	{
//		index = 4;
//	}
//	else  if(sender == button_middleLeftView )
//	{
//		index = 5;
//	}
//	else  if(sender == button_middleMiddleView )
//	{
//		index = 6;
//	}
//	else  if(sender == button_middleRightView )
//	{
//		index = 7;
//	}
//	else  if(sender == button_bottomMiddleView )
//	{
//		index = 8;
//	}
//	else
//		return;
//	
//	[self selectQuad:index];
//	
//}

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
		
		UIImage *resultImg = [self.renderer imageWithSourceImg:_imagePtr  softImage:blurImage cvVigArtImage:cvVigArtImg cvOpacity:pRenderArgs.cvOpacity SqrVigArtImage:VigArtImg sqrScaleX:pRenderArgs.sqrScaleX sqrScaleY:pRenderArgs.sqrScaleY leakImage:leakImg leakRGB:pRenderArgs.leakTintRGB randStartYIndex1:pRenderArgs.startY1 randStartYIndex2:pRenderArgs.startY2 randStartYIndex3:pRenderArgs.startY3
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



// Get default save camera original setting
//
- (bool) isSaveCameraShot
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults boolForKey:@"save_camera_shot"];
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

- (UIImage*)fullyRenderedImage:(UIImageView*)view
{
    
    NSArray * imageViewArray = @[self.topLeftView, self.topRightView, self.bottomLeftView, self.bottomRightView, self.topMiddleView, self.middleLeftView, self.middleMiddleView, self.middleRightView, self.bottomMiddleView];
    int renderIndex = (int)[imageViewArray indexOfObject:view];
    int m_quadIndex = renderIndex;
	
	UIImage * fullImage = [Utilities imageFromFileCache:ORIGINAL_IMAGE_FILE_NAME];
	CGFloat fullImageWidth = CGImageGetWidth( fullImage.CGImage );
	CGFloat fullImageHeight = CGImageGetHeight( fullImage.CGImage );
	
	CGFloat width = fullImageWidth;
	CGFloat height = fullImageHeight;
    
	UIImage *renderImage = [self createNewImage:&fullImage imgWidth:width imgHeight:height imgParameter:-1];
	
	int tempWidth = width;
	int tempHeight = height;
	
	bool re_cache = false;
	UIImage *saveImage = nil;
	if ( ffRenderArgsArray[m_quadIndex].cachedRenderImage )
	{
		NSString *filename = [NSString stringWithFormat:@FORMAT_RENDER,m_quadIndex ];
        saveImage = [[FileCache sharedCacher] cachedLocalImage:filename];
		if ( !saveImage )
		{
			ffRenderArgsArray[m_quadIndex].cachedRenderImage = false;
		}
		else if (tempWidth > CGImageGetWidth( saveImage.CGImage ))
		{
			// File cache is not hi res enough.  Need re-render
			//
			saveImage = nil;
			re_cache = true;
		}
		else if (tempWidth < CGImageGetWidth( saveImage.CGImage ))
		{
			// Smaller target.  Just shrink down and finish.
			//
			UIImage *targetImage = [ImageProcess imageNewWithImage:saveImage scaledToSize:CGSizeMake(tempWidth, tempHeight)];
			saveImage = targetImage;
		}
		
	}
	
//	mojoAppDelegate *app = (mojoAppDelegate*)[[UIApplication sharedApplication] delegate];
	if ( !saveImage )
	{
		saveImage = [self createNewImage:&renderImage imgWidth:tempWidth imgHeight:tempHeight imgParameter:m_quadIndex];
	}
    
    return saveImage;
}

@end
