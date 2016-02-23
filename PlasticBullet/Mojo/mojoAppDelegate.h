//
//  mojoAppDelegate.h
//  mojo
//
//

#import <UIKit/UIKit.h>


@class mojoViewController;

@interface mojoAppDelegate : NSObject {
    
}

@property (nonatomic, assign)int highWidth;
@property (nonatomic, assign)int highHeight;
@property (nonatomic, assign)int midWidth;
@property (nonatomic, assign)int midHeight;
@property (nonatomic, assign)int lowWidth;
@property (nonatomic, assign)int lowHeight;
@property (nonatomic, retain) NSMutableDictionary *imageMetadata;

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) mojoViewController *viewController;
@property (nonatomic, retain) UINavigationController *navigationStart;
@property (nonatomic, assign) int resolution;





- (void) setResolution:(int)res;
- (void) showProcessProgress:(BOOL)show;
- (void) updateProgressDegree:(float)degree;
- (void) roteProgressView:(CGAffineTransform)transform;
- (BOOL) isCancel;
- (void) initSettingsBundle;

//add by jack 0525
- (void) showInitialiationView;
- (void) hiddenProgressViewBar;
//end

- (void) didButton1Pressed:(id)object;
- (void) didButton2Pressed:(id)object;
- (void) didButton3Pressed:(id)object;
- (void)didStopRender;

- (void) removeLoadingView;

- (void) freezeAll:(BOOL)isFrozen;

+(mojoAppDelegate*)fakeAppDelegate;

@end


