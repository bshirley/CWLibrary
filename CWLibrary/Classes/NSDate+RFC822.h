//
//  NSDate+RFC822.h
//  Gwee
//
//  Created by Bill Shirley on 8/1/13.
//  Copyright (c) 2013 Bill Shirley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (RFC822)

+ (NSDate *)dateFromInternetDateTimeString:(NSString *)dateString;


@end
