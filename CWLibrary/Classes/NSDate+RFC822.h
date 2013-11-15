//
//  NSDate+RFC822.h
//  CWLibrary
//
//  Borrowed from Michael Waterfall http://forrst.com/posts/NSDate_from_Internet_Date_Time_String-evA
//

#import <Foundation/Foundation.h>

@interface NSDate (RFC822)

+ (NSDate *)dateFromInternetDateTimeString:(NSString *)dateString;


@end
