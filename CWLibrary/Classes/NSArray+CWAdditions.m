//
//  NSArray+Additions.m
//  CWLibrary
//
//  Created by Bill Shirley on 11/14/13.
//  Copyright (c) 2013 Bill Shirley. All rights reserved.
//

#import "NSArray+CWAdditions.h"

@implementation NSArray (CWAdditions)

- (NSArray *)arrayByRemovingObject:(id)object {
  NSUInteger index = [self indexOfObject:object];
  
  if (index == NSNotFound) {
    return self;
  }
  
  NSMutableArray *mutable = [self mutableCopy];
  [mutable removeObjectAtIndex:index];
  return [NSArray arrayWithArray:mutable];
}

@end
