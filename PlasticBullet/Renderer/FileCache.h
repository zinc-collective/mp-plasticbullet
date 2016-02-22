//
//  FileCache.h
//
//  Created by Jack on 3/12/09.
//  Copyright 2009 Redsafi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FileCache : NSObject {
    
    
}

/*****************************************/
/** Get shared instance					 */
/*****************************************/
+ (FileCache *)sharedCacher;

/*****************************************/
/** Cache image from local				 */
/*****************************************/
- (void) cacheLocalImage:(NSString *)filename image:(UIImage*)image;

/*****************************************/
/** Delete cached image file			 */
/*****************************************/
- (void) deleteCacheLocalImage:(NSString *)filename;

/*****************************************/
/** If cached, return the cached image   */
/*****************************************/
- (UIImage *) cachedLocalImage:(NSString*)filename;

/*****************************************/
/** Asynchronized caching to file        */
/*****************************************/
- (void) cacheLocalImageAsync:(NSString *)filename image:(UIImage*)image;
- (void) cacheFileAsync:(NSDictionary *)info;

@end 