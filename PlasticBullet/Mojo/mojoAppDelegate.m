//
//  mojoAppDelegate.m
//  mojo
//
//

#import "mojoAppDelegate.h"
#import "mojoViewController.h"

@interface UIWindow (PBRedsafi)

- (void)layoutSubviews;

@end

@implementation UIWindow (PBRedsafi)

- (void)layoutSubviews{
    
#ifdef __APPVERSION__
    UIView *view = [self viewWithTag:1000];
    [self bringSubviewToFront:view];
#endif
}

@end


@implementation mojoAppDelegate


//- (void)applicationDidFinishLaunching:(UIApplication *)application {
//
//	[self initSettingsBundle];
//	StartViewController *startView = [[StartViewController alloc]init];
//
//	progressView = [[ImageProcessProgressView alloc] initWithFrame:window.bounds];
//	[progressView setTitle:NSLocalizedString(@"Developing", nil)];
//	progressView.delegate_ = self;
//
//	navigationStart = [[UINavigationController alloc] initWithRootViewController:startView];
//	navigationStart.navigationBar.hidden = YES;
//	[window addSubview:navigationStart.view];
//
//	NSLog(@"%@",NSLocalizedString(@"_LocaleLanguage" ,nil));
//
//	cancelAlert = nil;
//	bIsCancelProcessing = NO;
//
//#ifdef __APPVERSION__
//	VersionWatermark *watermark = [[VersionWatermark alloc] initWithFrame:CGRectMake(0.0, 0.0, window.bounds.size.width, 30.0)];
//	watermark.tag = 1000;
//	[watermark showInView:window];
//	[watermark release];
//#endif
//
//	//add 2010-07-16
//	NSString* first_run = [[NSUserDefaults standardUserDefaults] valueForKey:@"pb_first_run"];
//	if(first_run == nil){
//		[[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"pb_first_run"];
//		[[NSUserDefaults standardUserDefaults] synchronize];
//
//		NSString *message = NSLocalizedString(@"New sharing and resolution options are available in the Settings app.", nil);
//		UIAlertView *firstRun = [[UIAlertView alloc] initWithTitle:@""
//														   message:message delegate:nil
//												 cancelButtonTitle:NSLocalizedString(@"Dismiss",nil) otherButtonTitles:nil];
//		[firstRun show];
//		[firstRun release];
//	}
//	//end add
//
//
//
//
//	[startView release];
//
//}


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
}


- (void) initSettingsBundle{
}


- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
}

- (void) flyProgressView{
}

- (void) progressViewLeaveFromScreen{
}

- (void) showProgressView:(id)show {
}

- (void) hiddenProgressViewBar{
}
- (void) updateProgressViewDegree:(NSNumber*)degree{
}


- (void) setResolution:(int)res{
}

- (void) showProcessProgress:(BOOL)show{
}

- (void) showWaitProgressViewThread{
}
- (void) showInitialiationView{
}

- (void) updateProgressDegree:(float)degree{
}

- (void) roteProgressView:(CGAffineTransform)transform{
}

- (void) didCancelButtonPressed:(id)object{
}

- (void) checkIsResolutionChanging{
}
- (void) didButton1Pressed:(id)object{
}

- (void) didButton2Pressed:(id)object{
}

- (void) didButton3Pressed:(id)object{
}

- (void)didStopRender{
}

- (void)saveBackground{
}

- (void) removeLoadingView {
}

- (BOOL) isCancel{
    return NO;
}

- (void) freezeAll:(BOOL)isFrozen {
}

+ (mojoAppDelegate*)fakeAppDelegate {
    return [mojoAppDelegate new];
}




@end
