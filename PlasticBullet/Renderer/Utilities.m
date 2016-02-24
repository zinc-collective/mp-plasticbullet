//
//  Utilities.m
//  MobileLooks
//
//  Created by jack on 8/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Utilities.h"
#import <CommonCrypto/CommonDigest.h>
#include "fileOutput.h"


@implementation Utilities

+(NSString *)md5Encode:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG) strlen(cStr), result );
    NSString *string = [NSString stringWithFormat:
						@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
						result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
						result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
						];
    return [string lowercaseString];
}

+(NSString *)bundlePath:(NSString *)fileName {
	return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:fileName];
}

+(NSString *)documentsPath:(NSString *)fileName {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:fileName];
}

+(BOOL) cacheToRawDataFromImage:(UIImage*)image filename:(NSString*)filename{
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *path = [Utilities documentsPath:filename];
	
	if([fileManager fileExistsAtPath:path]){
		[fileManager removeItemAtPath:path error:nil];
	}
	
	CGImageRef imageRef = image.CGImage;
	size_t width = CGImageGetWidth(imageRef);
	size_t height = CGImageGetHeight(imageRef);	
	uint8_t* tempBuffer = (uint8_t*)malloc(width * height * 4);
	CGColorSpaceRef imgColorSpace = CGImageGetColorSpace(imageRef);
	CGContextRef bufferContext = CGBitmapContextCreate(tempBuffer, width, height, 8, width * 4, imgColorSpace, kCGImageAlphaNoneSkipLast);
	CGContextSetBlendMode(bufferContext, kCGBlendModeCopy);
	CGContextDrawImage(bufferContext, CGRectMake(0.0, 0.0, width, height), imageRef);
	
	NSData *rawData = [[NSData alloc] initWithBytes:tempBuffer length:width * height * 4];
	
	
	BOOL bRes = [rawData writeToFile:path atomically:NO];
	
	CGContextRelease(bufferContext);
	free(tempBuffer);
	
	
	
	return bRes;
}

+(BOOL) cacheToRawDataFromImageBuffer:(char*)imageBuffer length:(size_t)length filename:(NSString*)filename;{
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *path = [Utilities documentsPath:filename];
	
	if([fileManager fileExistsAtPath:path]){
		[fileManager removeItemAtPath:path error:nil];
	}
	
	NSData *rawData = [[NSData alloc] initWithBytes:imageBuffer length:length];
	BOOL bRes = [rawData writeToFile:path atomically:NO];
	
	return bRes;
}

+(BOOL) cacheToFileFromImage:(UIImage*)image filename:(NSString*)filename{
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *path = [Utilities documentsPath:filename];
	
	if([fileManager fileExistsAtPath:path]){
		[fileManager removeItemAtPath:path error:nil];
	}

	NSData *data = UIImageJPEGRepresentation(image, 1);
	
	BOOL bRes = [data writeToFile:path atomically:NO];
	
	return bRes;
	
}

+(UIImage*) imageFromFileCache:(NSString*)filename{
	
	NSString *path = [Utilities documentsPath:filename];
	
	return [UIImage imageWithContentsOfFile:path];
}

+(unsigned char*) imageBufferFromFileCache:(NSString*)filename{
	
	long length = filelength([filename UTF8String]);
	unsigned char* buffer = (unsigned char*)malloc(length);
	
	readFile(buffer, [filename UTF8String], 0, length);
	
	//need free outside
	return buffer;
	
}

+(int) appendImageBufferToCacheFile:(FILE*)fp imageBuffer:(const char*)buffer length:(long)length{
	
	return appendFile(fp, buffer,length);
}

+(FILE*) openCacheFileByBinary:(NSString*)filename{
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *path = [Utilities documentsPath:filename];
	
	if([fileManager fileExistsAtPath:path]){
		[fileManager removeItemAtPath:path error:nil];
	}
	return createFile([path UTF8String]);
}

+(void) closeFile:(FILE*)fp{
	closeBinaryFile(fp);
}

+(void) printAvailMemory
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

+(void)printDateTime{
//	return;
//	NSDate *date = [NSDate date];
//	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//	NSString *dateString = [formatter stringFromDate:date];
//	NSLog(@"%@",dateString);
}

@end
