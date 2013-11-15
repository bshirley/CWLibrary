//
//  CWUpdatablePropertyListWrapper.m
//  
//
//  Created by Bill Shirley on 11/13/13.
//
//

#import "CWUpdatablePropertyListWrapper.h"

@implementation CWUpdatablePropertyListWrapper

- (NSUInteger)indexForIdentifier:(NSString *)uniqueIdentifier {
  NSAssert(_uniqueKey != nil, @"must identify the unique key to fid it in the plist");
  
  __block NSUInteger index = NSNotFound;
  [self.plist enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger idx, BOOL *stop) {
    NSString *key = item[_uniqueKey];
    if ([key isEqualToString:uniqueIdentifier]) {
      *stop = YES;
      index = idx;
    }
  }];
  
  return index;
}

- (NSDictionary *)itemForIdentifier:(NSString *)uniqueItentifier {
  NSUInteger index = [self indexForIdentifier:uniqueItentifier];
  return self.plist[index];
}


- (void)replaceValue:(id)value forKey:(NSString *)key atIndex:(NSUInteger)index {
  NSMutableDictionary *item = self.plist[index];
  
  if ([item isKindOfClass:[NSMutableDictionary class]] == NO) {
    NSMutableDictionary *newItem = [item mutableCopy];
    [self.plist replaceObjectAtIndex:index withObject:newItem];
    item = newItem;
  }
  
  item[key] = value;
}


- (NSArray *)oldItemsNotInNewArray:(NSArray *)newValues {
  NSMutableArray *deletedItems = [NSMutableArray array];
  
  [_plist enumerateObjectsUsingBlock:^(NSDictionary *oldItem, NSUInteger idx, BOOL *stop) {
    NSString *oldId = oldItem[_uniqueKey];
    __block NSUInteger newItemIndex = NSNotFound;
    [newValues enumerateObjectsUsingBlock:^(NSDictionary *newItem, NSUInteger idx, BOOL *stop) {
      NSString *newId = newItem[_uniqueKey];
      if ([newId isEqualToString:oldId]) {
        newItemIndex = idx;
        *stop = YES;
      }
    }];
    if (newItemIndex == NSNotFound) {
      [deletedItems addObject:oldItem];
    }
  }];
  
  return deletedItems;
}


- (NSArray *)newItemsNotInArray:(NSArray *)newValues {
  NSMutableArray *actuallyNewValues = [NSMutableArray array];
  [newValues enumerateObjectsUsingBlock:^(NSDictionary *newItem, NSUInteger idx, BOOL *stop) {
    NSUInteger existingIndex = [self indexForIdentifier:newItem[_uniqueKey]];
    if (existingIndex == NSNotFound) {
      [actuallyNewValues addObject:newItem];
    }
  }];
  
  return actuallyNewValues;
}

@end
