//
//  Utilities.h
//  MobileLooks
//
//  Created by jack on 8/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define ORIGINAL_IMAGE_FILE_NAME			@"original_will_process.raw"
#define SOFT_IMAGE_FILE_NAME				@"soft_image_will_process.raw"
#define LEAK_FILE_NAME						@"leak_art.raw"
#define RENDER_SOURCE_FILE_NAME				@"temp_source_for_render.raw"
#define TMP_SOFTIMAGE_FILE_NAME				@"temp_softimage_for_render.raw"
#define TMP_BORDER_FILE_NAME				@"temp_border_for_render.raw"
#define TMP_LEAK_FILE_NAME					@"temp_leak_for_render.raw"
#define TMP_TILE_RENDER_OUTPUT				@"temp_buffer_for_tile_render.raw"


@interface Utilities : NSObject
{

}
+(NSString *)md5Encode:(NSString *)str;
+(NSString *)bundlePath:(NSString *)fileName;
+(NSString *)documentsPath:(NSString *)fileName;

+(BOOL) cacheToRawDataFromImage:(UIImage*)image filename:(NSString*)filename;
+(BOOL) cacheToRawDataFromImageBuffer:(char*)imageBuffer length:(size_t)length filename:(NSString*)filename;
+(BOOL) cacheToFileFromImage:(UIImage*)image filename:(NSString*)filename;
+(UIImage*) imageFromFileCache:(NSString*)filename;
+(unsigned char*) imageBufferFromFileCache:(NSString*)filename;
+(FILE*) openCacheFileByBinary:(NSString*)filename;
+(int) appendImageBufferToCacheFile:(FILE*)fp imageBuffer:(const char*)buffer length:(long)length;
+(void) closeFile:(FILE*)fp;
+(void) printAvailMemory;
+(void) printDateTime;
@end
