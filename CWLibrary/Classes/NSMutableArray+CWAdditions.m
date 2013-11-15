//  $Id$
//
//  CWLibrary
//
//  Created by Bill Shirley on 9/4/13.
//  Copyright (c) 2013 Bill Shirley. All rights reserved.

#import "NSMutableArray+CWAdditions.h"

@implementation NSMutableArray (CWAdditions)

- (void)reverse {
  NSInteger i = 0;
  NSInteger j = self.count - 1;
  
  while (i < j) {
    [self exchangeObjectAtIndex:i
              withObjectAtIndex:j];
		
    i++;
    j--;
  }
}

@end