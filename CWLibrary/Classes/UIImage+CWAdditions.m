//  $Id: UIImageExtras.m 170 2010-11-09 05:24:05Z bshirley $
//  UIImageExtras.m
//  CWLibrary
//
//  Created by Bill Shirley on 1/12/10.
//  Copyright (c) 2013 Bill Shirley. All rights reserved.

#import "UIImage+CWAdditions.h"


@implementation UIImage (CWSAdditions)

- (UIImage *)imageResizedTo:(CGSize)newSize {
  CGImageRef image = [self CGImage];
  CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
  CGContextRef context = CGBitmapContextCreate(NULL, newSize.width, newSize.height,
                                               CGImageGetBitsPerComponent(image),
                                               0, /* calculated automatically */
                                               colorspace,
                                               (kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst) );
  CGColorSpaceRelease(colorspace);
  
  if (context == NULL)
    return nil;
  
  // draw image to context (resizing it)
  CGContextDrawImage(context, CGRectMake(0, 0, newSize.width, newSize.height), image);
  // extract resulting image from context
  CGImageRef imgRef = CGBitmapContextCreateImage(context);
  CGContextRelease(context);
  
  UIImage *result = [UIImage imageWithCGImage:imgRef];
  CGImageRelease(imgRef);
  return result;
}

+ (UIImage *)imageWithName:(NSString *)imageName inBundle:(NSBundle *)bundleOrNil {
	if (bundleOrNil == nil)
		bundleOrNil = [NSBundle mainBundle];
	
	NSString *fileName = [imageName stringByDeletingPathExtension];
	NSString *extension = [imageName pathExtension];
	NSString *imageFileName = [bundleOrNil pathForResource:fileName ofType:extension];
	UIImage *image = [UIImage imageWithContentsOfFile:imageFileName];
	return image;
}

- (UIImage *)imageWithAppliedMask:(UIImage *)maskImage {
  CGImageRef image = [self CGImage];
  CGImageRef mask = [maskImage CGImage];
  CGColorSpaceRef colorspace = CGImageGetColorSpace(image);
  CGContextRef context = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                               CGImageGetBitsPerComponent(image),
                                               CGImageGetBytesPerRow(image),
                                               colorspace,
                                               (kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst) );
  //CGColorSpaceRelease(colorspace);
  CGRect frame = CGRectMake(0, 0, self.size.width, self.size.height);
  CGContextClipToMask(context, frame, mask);
  CGContextDrawImage(context, frame, image);
  
  CGImageRef imgRef = CGBitmapContextCreateImage(context);
  CGContextRelease(context);
  UIImage *result = [UIImage imageWithCGImage:imgRef];
  CGImageRelease(imgRef);
  return result;
}

- (UIImage *)imageResizedTo:(CGSize)size withMask:(UIImage *)mask {
  UIImage *result;
  
  if (CGSizeEqualToSize(size, mask.size) == NO) {
    mask = [mask imageResizedTo:size];
  }
  
  if (CGSizeEqualToSize(self.size, size) == NO) {
    result = [self imageResizedTo:size];
  }

  if (mask != nil) {
    result = [result imageWithAppliedMask:mask];
  }

  return result;
}

@end
