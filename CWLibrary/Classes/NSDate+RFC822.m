//
//  NSDate+RFC822.m
//  Gwee
//
//  Created by Bill Shirley on 8/1/13.
//  Borrowed from http://forrst.com/posts/NSDate_from_Internet_Date_Time_String-evA
//  Copyright (c) 2013 Bill Shirley.


#import "NSDate+RFC822.h"

@implementation NSDate (RFC822)

// Return date for internet date string (RFC822 or RFC3339)
// - RFC822  http://www.ietf.org/rfc/rfc822.txt
// - RFC3339 http://www.ietf.org/rfc/rfc3339.txt
// - Good QA on internet dates: http://developer.apple.com/iphone/library/qa/qa2010/qa1480.html
// - Cocoa date formatting: http://unicode.org/reports/tr35/tr35-6.html#Date_Format_Patterns
+ (NSDate *)dateFromInternetDateTimeString:(NSString *)dateString {
  
  if (dateString == nil)
    return nil;
  
  // Setup Date & Formatter
  NSDate *date = nil;
  static NSDateFormatter *formatter = nil;
  if (!formatter) {
    NSLocale *en_US_POSIX = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:en_US_POSIX];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
  }
  
  /*
   *  RFC3339
   */
  
  NSString *RFC3339String = [[NSString stringWithString:dateString] uppercaseString];
  RFC3339String = [RFC3339String stringByReplacingOccurrencesOfString:@"Z" withString:@"-0000"];
  
  // Remove colon in timezone as iOS 4+ NSDateFormatter breaks
  // See https://devforums.apple.com/thread/45837
  if (RFC3339String.length > 20) {
    RFC3339String = [RFC3339String stringByReplacingOccurrencesOfString:@":"
                                                             withString:@""
                                                                options:0
                                                                  range:NSMakeRange(20, RFC3339String.length-20)];
  }
  
  if (!date) { // 1996-12-19T16:39:57-0800
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"];
    date = [formatter dateFromString:RFC3339String];
  }
  if (!date) { // 1937-01-01T12:00:27.87+0020
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZZZ"];
    date = [formatter dateFromString:RFC3339String];
  }
  if (!date) { // 1937-01-01T12:00:27
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"];
    date = [formatter dateFromString:RFC3339String];
  }
  if (date) return date;
  
  /*
   *  RFC822
   */
  
  NSString *RFC822String = [[NSString stringWithString:dateString] uppercaseString];
  if (!date) { // Sun, 19 May 02 15:21:36 GMT
    [formatter setDateFormat:@"EEE, d MMM yy HH:mm:ss zzz"];
    date = [formatter dateFromString:RFC822String];
  }
  if (!date) { // Sun, 19 May 2002 15:21:36 GMT
    [formatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss zzz"];
    date = [formatter dateFromString:RFC822String];
  }
  if (!date) {  // Sun, 19 May 2002 15:21 GMT
    [formatter setDateFormat:@"EEE, d MMM yyyy HH:mm zzz"];
    date = [formatter dateFromString:RFC822String];
  }
  if (!date) {  // 19 May 2002 15:21:36 GMT
    [formatter setDateFormat:@"d MMM yyyy HH:mm:ss zzz"];
    date = [formatter dateFromString:RFC822String];
  }
  if (!date) {  // 19 May 2002 15:21 GMT
    [formatter setDateFormat:@"d MMM yyyy HH:mm zzz"];
    date = [formatter dateFromString:RFC822String];
  }
  if (!date) {  // 19 May 2002 15:21:36
    [formatter setDateFormat:@"d MMM yyyy HH:mm:ss"];
    date = [formatter dateFromString:RFC822String];
  }
  if (!date) {  // 19 May 2002 15:21
    [formatter setDateFormat:@"d MMM yyyy HH:mm"];
    date = [formatter dateFromString:RFC822String];
  }
  if (date) return date;
  
  // Failed
  return nil;
  
}

/*
 *  Tests
 */

//NSLog(@"2010-07-22T06:30:00Z = %@", [NSDate dateFromInternetDateTimeString:@"2010-07-22T06:30:00Z"]);
//NSLog(@"2010-07-22T06:30:00+01:00 = %@", [NSDate dateFromInternetDateTimeString:@"2010-07-22T06:30:00+01:00"]);
//NSLog(@"2010-07-22T06:30:00 = %@", [NSDate dateFromInternetDateTimeString:@"2010-07-22T06:30:00"]);
//NSLog(@"2010-07-22T06:30:00.50+0200 = %@", [NSDate dateFromInternetDateTimeString:@"2010-07-22T06:30:00.50+0200"]);
//NSLog(@"2010-07-22T06:30:00.505+0200 = %@", [NSDate dateFromInternetDateTimeString:@"2010-07-22T06:30:00.505+0200"]);
//NSLog(@"2010-07-22T06:30:00.5+0200 = %@", [NSDate dateFromInternetDateTimeString:@"2010-07-22T06:30:00.5+0200"]);
//NSLog(@"2010-07-22T06:30:00+0000 = %@", [NSDate dateFromInternetDateTimeString:@"2010-07-22T06:30:00+0000"]);
//NSLog(@"2010-07-22T06:30:00+0100 = %@", [NSDate dateFromInternetDateTimeString:@"2010-07-22T06:30:00+0100"]);
//NSLog(@"2010-07-22T06:30:00.50+01:00 = %@", [NSDate dateFromInternetDateTimeString:@"2010-07-22T06:30:00.50+01:00"]);
//NSLog(@"2010-07-22T06:30:00+01 = %@", [NSDate dateFromInternetDateTimeString:@"2010-07-22T06:30:00+01"]);
//NSLog(@"1996-12-19t16:39:57-08:00 = %@", [NSDate dateFromInternetDateTimeString:@"1996-12-19t16:39:57-08:00"]);
//NSLog(@"1996-12-19T16:39:57-08:00 = %@", [NSDate dateFromInternetDateTimeString:@"1996-12-19T16:39:57-08:00"]);
//NSLog(@"1937-01-01T12:00:27.87+00:20 = %@", [NSDate dateFromInternetDateTimeString:@"1937-01-01T12:00:27.87+00:20"]);
//NSLog(@"Sun, 19 May 02 15:21:36 GMT = %@", [NSDate dateFromInternetDateTimeString:@"Sun, 19 May 02 15:21:36 GMT"]);
//NSLog(@"Sun, 19 May 2002 15:21:36 GMT = %@", [NSDate dateFromInternetDateTimeString:@"Sun, 19 May 2002 15:21:36 GMT"]);
//NSLog(@"Sun, 19 May 2002 15:21 GMT = %@", [NSDate dateFromInternetDateTimeString:@"Sun, 19 May 2002 15:21 GMT"]);
//NSLog(@"19 May 2002 15:21:36 GMT = %@", [NSDate dateFromInternetDateTimeString:@"19 May 2002 15:21:36 GMT"]);
//NSLog(@"19 May 2002 15:21 GMT = %@", [NSDate dateFromInternetDateTimeString:@"19 May 2002 15:21 GMT"]);
//NSLog(@"SUN, 19 MAY 02 15:21:36 GMT = %@", [NSDate dateFromInternetDateTimeString:@"SUN, 19 MAY 02 15:21:36 GMT"]);
//NSLog(@"19 May 2002 15:21:36 GMT = %@", [NSDate dateFromInternetDateTimeString:@"19 May 2002 15:21:36 GMT"]);
//NSLog(@"19 May 2002 15:21:36 = %@", [NSDate dateFromInternetDateTimeString:@"19 May 2002 15:21:36"]);
//NSLog(@"19 May 2002 15:21 = %@", [NSDate dateFromInternetDateTimeString:@"19 May 2002 15:21"]);

@end
