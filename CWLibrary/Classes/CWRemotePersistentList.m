//
//  PersistentNotificationList.m
//  CWLibrary
//
//  Created by Bill Shirley on 8/23/13.
//  Copyright (c) 2013 Bill Shirley. All rights reserved.
//

#import "CWRemotePersistentList.h"
#import <ASIHTTPRequest/ASIHTTPRequest.h>

@interface CWRemotePersistentList () <ASIHTTPRequestDelegate>
@property (nonatomic, strong) NSString *persistenceKey;
@property (nonatomic, strong) NSURL *remote;
@property (nonatomic, copy) void (^callback) (CWRemotePersistentList *rpl);

@end


@implementation CWRemotePersistentList


#pragma mark -

#define kLatestRefreshDate [NSString stringWithFormat:@"%@.latestRefreshDate", _persistenceKey]

/**
 * A single operations queue for all instances.
 */
+ (NSOperationQueue *)queue {
  static NSOperationQueue *queue;
  @synchronized (self) {
    if (queue == nil) {
      queue = [[NSOperationQueue alloc] init];
    }
  }
  
  return queue;
}

- (instancetype)initWithURL:(NSURL *)remotePlistURL
            persistenceName:(NSString *)pname {
  self = [super init];
  self.remote = remotePlistURL;
  self.latestRefreshDate = [NSDate distantPast];
  self.persistenceKey = pname;
  [self restoreData];
  // These default values are for the Notification format - explicitly set them for different behavior
  self.uniqueKey = @"gid";
  self.updatableKeys = @[@"category", @"message"];
  return self;
}

- (id)init {
  return nil;
}

- (void)refreshWithCallback:(void(^) (CWRemotePersistentList *rpl))callback {
  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:self.remote];
  request.delegate = self;
  [[[self class] queue] addOperation:request];
  self.callback = callback;
}

- (void)saveData {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:self.plist forKey:self.persistenceKey];
  [defaults setObject:self.latestRefreshDate forKey:kLatestRefreshDate];
  [defaults synchronize];
}

- (void)restoreData {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSMutableArray *a = [defaults valueForKey:self.persistenceKey];
  if (a == nil) {
    self.plist = [NSMutableArray array];
  } else {
    self.plist = [a mutableCopy];
  }
  
  NSDate *date = [defaults valueForKey:kLatestRefreshDate];
  if (date == nil) {
    date = [NSDate distantPast];
  }
  
  self.latestRefreshDate = date;
}

- (void)flushPersistence {
  self.plist = [NSMutableArray array];
  [self saveData];
}

- (void)synchronize {
  [self saveData];
}


#pragma mark - Update Methods

- (void)insertOrModifyItem:(NSDictionary *)data {
  __block BOOL found = NO;
  NSString *uniqueKey = self.uniqueKey;
  NSString *newGid = data[uniqueKey];
  
  [self.plist enumerateObjectsUsingBlock:^(NSMutableDictionary *oldData, NSUInteger idx, BOOL *stop) {
    NSString *oldGid = oldData[uniqueKey];
    if ([newGid isEqualToString:oldGid]) {
      oldData = [oldData mutableCopy];
      [self.updatableKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        oldData[key] = data[key];
      }];
      [self.plist replaceObjectAtIndex:idx withObject:oldData];
      found = YES;
      *stop = YES;
    }
  }];
  
  if (found == NO) {
    [(NSMutableArray *)self.plist addObject:[data mutableCopy]];
  }
}


- (void)checkForDeletions:(NSArray *)newList {
  NSArray *immutableArray = [self.plist copy];
  NSString *uniqueKey = self.uniqueKey;
  
  [immutableArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSDictionary *data, NSUInteger oldIndex, BOOL *stopA) {
    __block BOOL isInNewList = NO;
    NSString *oldGid = data[uniqueKey];
    
    [newList enumerateObjectsUsingBlock:^(NSDictionary *newData, NSUInteger newIndex, BOOL *stopB) {
      NSString *newGid = newData[uniqueKey];

      if ([oldGid isEqualToString:newGid]) {
        isInNewList = YES;
        *stopB = YES;
      }
    }];
    
    if (isInNewList == NO) {
      [(NSMutableArray *)self.plist removeObjectAtIndex:oldIndex]; // CAN i delete these in the loop? -CWS
    }
  }];
}

- (void)processUpdate:(NSArray *)newList {
  [self checkForDeletions:newList];
  [newList enumerateObjectsUsingBlock:^(NSDictionary *data, NSUInteger idx, BOOL *stop) {
    [self insertOrModifyItem:data];
  }];
}

/**
 * ASIHTTPRequest callback method.
 */

- (NSString *)generateTempFilename {
  NSString *path = [NSString stringWithFormat:@"%@/%.0f", NSTemporaryDirectory(), [[NSDate date] timeIntervalSince1970]];
  return path;
}

- (void)requestFinished:(ASIHTTPRequest *)request {
  NSFileManager *fm = [NSFileManager defaultManager];
  NSError *error = nil;
  NSData *responseData = request.responseData;
  NSString *filename = [self generateTempFilename];
  
  [responseData writeToFile:filename atomically:YES];
  NSArray *newPlist = [NSArray arrayWithContentsOfFile:filename];
  
  if (newPlist == nil) {
    NSLog(@"%s ERROR: %@\n couldn't parse response as array: %@",
          __PRETTY_FUNCTION__, request.url, request.responseString);
  } else {
    [self processUpdate:newPlist];
  }
  
  [fm removeItemAtPath:filename error:&error];
  if (error != nil) {
    NSLog(@"%s ERROR: %@", __PRETTY_FUNCTION__, error);
  }
  
  self.latestRefreshDate = [NSDate date];
  self.callback(self);
  self.callback = NULL;
  [self saveData];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
  NSError *error = [request error];
  NSLog(@"%s ERROR: %@", __PRETTY_FUNCTION__, error);
}


@end
