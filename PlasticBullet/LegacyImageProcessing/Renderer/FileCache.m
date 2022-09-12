//
//  FileCache.m
//
//  Created by Jack on 3/12/09.
//  Copyright 2009 Redsafi. All rights reserved.
//

#import "FileCache.h"

static FileCache *_sharedCacher;

@implementation FileCache


- (id)init {
	if((self = [super init]))
	{
		
	}
	return self;
}

+ (FileCache *)sharedCacher{
	if (!_sharedCacher) {
		_sharedCacher = [[FileCache alloc] init];
	}
	return _sharedCacher;
}

/*****************************************/
/** Cache image from local				 */
/*****************************************/
- (void) cacheLocalImage:(NSString *)filename image:(UIImage*)image
{
	NSData* imageData = UIImageJPEGRepresentation(image, 1.0);
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString* cachesDirectory = [paths objectAtIndex:0];
	NSString* fullPathToFile = [cachesDirectory stringByAppendingPathComponent:filename];
	[imageData writeToFile:fullPathToFile atomically:NO];
}

- (void) cacheLocalImageAsync:(NSString *)filename image:(UIImage*)image 
{
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:filename,@"filename",image,@"image",nil];
	[self deleteCacheLocalImage:filename];
	[NSThread detachNewThreadSelector:@selector(cacheFileAsync:) toTarget:self withObject:info];
}

-(void) cacheFileAsync:(NSDictionary *)info
{
	@try {
		[self cacheLocalImage:[info objectForKey:@"filename"] image:[info objectForKey:@"image"]];
	}
	@catch (NSException * e) {
		;
	}
	@finally {
		;
	}
}

/*****************************************/
/** Delete cached image file			 */
/*****************************************/
- (void) deleteCacheLocalImage:(NSString *)filename{
		
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cachesDirectory = [paths objectAtIndex:0];
	NSError* error;
	NSString* fullPathToFile = [cachesDirectory stringByAppendingPathComponent:filename];
	
	if ([fileManager fileExistsAtPath:fullPathToFile] == YES)
	{
		[fileManager removeItemAtPath:fullPathToFile error:&error];
	}
}

/*****************************************/
/** If cached, return the cached image   */
/*****************************************/
- (UIImage *) cachedLocalImage:(NSString*)filename{
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cachesDirectory = [paths objectAtIndex:0];
	NSString* fullPathToFile = [cachesDirectory stringByAppendingPathComponent:filename];
	
	if ([fileManager fileExistsAtPath:fullPathToFile] == YES){
		
		NSData * data = [NSData dataWithContentsOfFile:fullPathToFile];
		return [UIImage imageWithData:data];
	}
	return nil;
	
}


@end 