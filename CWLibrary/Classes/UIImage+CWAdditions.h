//  $Id: UIImageExtras.h 170 2010-11-09 05:24:05Z bshirley $
//  UIImageExtras.h
//  CWLibrary
//
//  Created by Bill Shirley on 1/12/10.
//  Copyright (c) 2013 Bill Shirley. All rights reserved.


@import UIKit;

@interface UIImage (CWSAdditions)
- (UIImage *)imageResizedTo:(CGSize)newSize;
+ (UIImage *)imageWithName:(NSString *)imageName inBundle:(NSBundle *)bundleOrNil;
- (UIImage *)imageWithAppliedMask:(UIImage *)maskImage;
- (UIImage *)imageResizedTo:(CGSize)size withMask:(UIImage *)mask;
@end
