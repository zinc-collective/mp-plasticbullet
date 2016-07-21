//
//  mojoViewController.mm
//  mojo
//


#define TOOLBAR_OFFSET_HEIGHT 44
#define ICON_SIZE 24
#define DOT_SIZE 80
#define BORDER_SIZE 5

#include <math.h>
#import "mojoViewController.h"
#import "RenderArguments.h"
#import "RandomRenderArguments.h"
// #import "PostToFacebookViewController.h"
// #import "PostToFlickrViewController.h"

#import "Utilities.h"

// #import <AssetsLibrary/AssetsLibrary.h>

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

#define FORMAT_PREVIEW "cachedPreview_%d"
#define FORMAT_RENDER "cachedRender_%d"

#define LOCATION_SERVICE_TIME_OUT_SECONDS	10

NSThread *sWorkerThread = nil;

static UIImage *portraitImage1 = nil;
static UIImage *portraitImage4 = nil;
static UIImage *portraitImage9 = nil;
static UIImage *s_loadedImage = nil;

static ffRenderArguments ffRenderArgsArray[9];

@implementation mojoViewController
@synthesize delegate;
@synthesize renderer;
@synthesize originalImage;
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


@synthesize cvVigArtImg;
@synthesize leakImg;
@synthesize VigArtImg;
@synthesize borderImg;
@synthesize blurImage;


@synthesize portraitImage;

//save small pictures array
static UIImage *viewImageArray[9] = {nil};


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
}

- (void)focusImage:(UIImageView *)view {
    numberMode = 1;
    self.focusedView = view;
//    [self renderImage:self.originalImage];
    [self startRenderBackground:true image:nil clearAlpha:false];
}

- (void)defocusImage {
    numberMode = (int)gridMode;
    [self startRenderBackground:true image:nil clearAlpha:true];
    self.focusedView.alpha = 1.0;
    self.focusedView = nil;
}

- (void)initGrid:(GRID_MODE)mode {
    gridMode = mode;
    numberMode = (int)mode;
}

- (void)setRotations:(CGFloat)rotate scale:(CGFloat)scale
{
	CGAffineTransform m = CGAffineTransformMakeRotation(rotate);
    CGAffineTransform n = CGAffineTransformMakeScale(scale, scale);
    CGAffineTransform mn = CGAffineTransformConcat(m, n);
    
    [UIView animateWithDuration:0.4 animations:^(void) {
    	self.topRightView.transform = mn;
    	self.topMiddleView.transform = mn;
    	self.topLeftView.transform = mn;
    	self.middleRightView.transform = mn;
    	self.middleMiddleView.transform = mn;
    	self.middleLeftView.transform = mn;
    	self.bottomRightView.transform = mn;
    	self.bottomMiddleView.transform = mn;
    	self.bottomLeftView.transform = mn;
    }];
}


- (void)didReceiveMemoryWarning 
{
	[super didReceiveMemoryWarning];
}



- (void)generateInputImages
{
	
	UIImage *image = s_loadedImage;
	CGFloat inputWidth = CGImageGetWidth( image.CGImage );
	CGFloat inputHeight = CGImageGetHeight( image.CGImage );
	
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

-(void)renderImage:(UIImage *)image {
	
    self.originalImage = nil;
	m_isImageOnceLoaded = true;
	
	//[self setWidgetGeometry];
	
	// Randomize and clear cache
	for(int i=0;i<9;i++)
	{
		[self newRenderArg:i];
		isRefresh[i] = YES;
		if(viewImageArray[i])
		{
			viewImageArray[i] = nil;
		}
	}
	
	CGSize size = image.size;
	NSLog(@"load image size: %f : %f", size.width,size.height);
	
	if(image == nil)return;
	
	
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
}



- (int)renderImages
{
	//mojoView *pView = (mojoView *)self.view;
    CGFloat width = 0;
    CGFloat height = 0;
	int numRenderIndexs = 1;
	int renderIndex = 0;
    NSArray * imageViewArray = @[self.topLeftView, self.topRightView, self.bottomLeftView, self.bottomRightView, self.topMiddleView, self.middleLeftView, self.middleMiddleView, self.middleRightView, self.bottomMiddleView];
	
	if (numberMode == GRID_4) {
		numRenderIndexs = 4;
	} else if (numberMode == GRID_9) {
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


- (void)startRenderBackground:(bool)renderInputs image:(UIImage *)image clearAlpha:(bool)clearAlpha
{
 	float x = 320/2.0;
	float y = (480-TOOLBAR_OFFSET_HEIGHT)/2.0;
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		x = 768/2.0;
		y = (1024-TOOLBAR_OFFSET_HEIGHT)/2.0;
	}
	
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
	
	if(![workerThread isCancelled])
	{
		[self generateInputImages];
		
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
	
	[self performSelectorOnMainThread:@selector(renderTerminated:) withObject:@"Finish" waitUntilDone:NO];
	sWorkerThread = nil;
	
	
	
	[self performSelectorOnMainThread:@selector(stopAnimating:) withObject:@"stopAnimating" waitUntilDone:NO];
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
	// [self playSystemSound];
	// [self cancelRender];
}

-(void)startAnimating:(NSString *)answer
{
    [self.delegate mojoIsWorking:YES];
}

-(void)stopAnimating:(NSString *)answer
{
//	[spinner stopAnimating];
    [self.delegate mojoIsWorking:NO];
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
        
        BorderArguments border = pRenderArgs.border;
		
		UIImage *resultImg = [self.renderer imageWithSourceImg:_imagePtr  softImage:blurImage cvVigArtImage:cvVigArtImg cvOpacity:pRenderArgs.cvOpacity SqrVigArtImage:VigArtImg sqrScaleX:pRenderArgs.sqrScaleX sqrScaleY:pRenderArgs.sqrScaleY leakImage:leakImg leakRGB:pRenderArgs.leakTintRGB randStartYIndex1:pRenderArgs.startY1 randStartYIndex2:pRenderArgs.startY2 randStartYIndex3:pRenderArgs.startY3
												imageSize:_size  diffusionOpacity:pRenderArgs.difOpacity SqrVignette:pRenderArgs.SqrOpacity Leakopacity:pRenderArgs.opacity3D CCRGBMaxMinValue:pRenderArgs.CCRGBMaxMin
												  monoRGB:pRenderArgs.rgbValue desatBlendrand:pRenderArgs.blendrand desatRandNum:pRenderArgs.randNum 
											  borderImage: borderImg 
											  borderRandX:border.x borderRandY:border.y borderRandS:border.scale borderRandDoScale:border.doScale
											   borderType:border.type
											   borderLeft:border.left
												borderTop:border.top
											  borderRight:border.right
											 borderBottom:border.bottom
										   sCurveContrast:pRenderArgs.contrast colorFadeRGBMaxMin:pRenderArgs.colorFadeRGB cornerSoftOpacity:pRenderArgs.cornerOpacity hiRes:doHiRes convserveMemory:doConserveMem
											  isLandscape:isFullImageLandscape
                                        gammaCorrection:pRenderArgs.gammaCorrection
                              ];
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
}

- (void) newRenderArg:(int)_index
{
    ffRenderArgsArray[_index] = [RandomRenderArguments generate];
	ffRenderArgsArray[_index].cachedRenderImage = false;
	ffRenderArgsArray[_index].cachedPreviewImage = false;
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

- (NSArray*)allImages {
    return @[self.topLeftView, self.topRightView, self.bottomLeftView, self.bottomRightView, self.topMiddleView, self.middleLeftView, self.middleMiddleView, self.middleRightView, self.bottomMiddleView];
}

- (UIImage*)fullyRenderedImage:(UIImageView*)view scaleDown:(BOOL)scaleDown
{
    
    NSArray * imageViewArray = self.allImages;
    int renderIndex = (int)[imageViewArray indexOfObject:view];
    int m_quadIndex = renderIndex;
	
	UIImage * fullImage = [Utilities imageFromFileCache:ORIGINAL_IMAGE_FILE_NAME];
    
    // Render the image at a smaller resolution if it's too big
    CGFloat fullImageWidth = CGImageGetWidth( fullImage.CGImage );
    CGFloat fullImageHeight = CGImageGetHeight( fullImage.CGImage );
    CGFloat width = fullImageWidth;
    CGFloat height = fullImageHeight;
    
    if (scaleDown) {
        CGFloat maxArea =  (4032/2) * (3024/2); // half iphone 6 resolution
        CGFloat imageArea = fullImageHeight * fullImageWidth;
        CGFloat scaleFactor = MIN((maxArea / imageArea)*2, 1.0);
    
        width = fullImageWidth * scaleFactor;
        height = fullImageHeight * scaleFactor;
        NSLog(@"Scale Down by %f", scaleFactor);
    }
    
//    NSLog(@"RENDER SCALE %f", scaleFactor);
//    NSLog(@"wh (%f, %f)", width, height);
//    NSLog(@"full wh (%f, %f)", fullImageWidth, fullImageHeight);
//    NSLog(@"total area %f", width * height);
    
    NSLog(@"Fully Rendered Image %f x %f", width, height);
    
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
	
	if ( !saveImage )
	{
		saveImage = [self createNewImage:&renderImage imgWidth:tempWidth imgHeight:tempHeight imgParameter:m_quadIndex];
	}
    
    return saveImage;
}

@end
