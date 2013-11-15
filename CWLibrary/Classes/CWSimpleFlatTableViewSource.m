//
//  TableViewSource.m
//  CWLibrary
//
//  Created by Bill Shirley on 11/9/13.
//  Copyright (c) 2013 Bill Shirley. All rights reserved.
//

#import "CWSimpleFlatTableViewSource.h"

@interface CWSimpleFlatTableViewSource ()
/// a temporary placeholder
@property (nonatomic, strong) NSArray *unprocessedData;

/// array of arrays
@property (nonatomic, strong) NSMutableArray *tableData;
@property (nonatomic, strong) NSMutableArray *discoveredSectionNames;
@end

@implementation CWSimpleFlatTableViewSource

- (void)_verifyUpdatableKeys {
  NSAssert([self.updatableKeys containsObject:_sectionKey] == NO, @"The sectionKey should not be listed in the updatableKeys.");
  // the sectionKey IS automatically updated, no option
  // it's also handled differently because it can tweak the table
}

- (void)setUpdatableKeys:(NSArray *)updatableKeys {
  [super setUpdatableKeys:updatableKeys];
  [self _verifyUpdatableKeys];
}

- (void)setSectionKey:(NSString *)sectionKey {
  _sectionKey = sectionKey;
  [self _verifyUpdatableKeys];
}

- (NSArray *)sectionNames {
  [self plist]; // force cache creation
  return [_discoveredSectionNames copy];
}

- (NSMutableArray *)plist {
  if (_unprocessedData != nil) {
    [super.plist removeAllObjects];
    [self _updateData:_unprocessedData];
    self.unprocessedData = nil;
  }
  
  return super.plist;
}

- (instancetype)initWithArray:(NSArray *)values {
  self = [super init];
  self.plist = [NSMutableArray arrayWithCapacity:values.count]; // same object for the life of self
  self.unprocessedData = values;
  return self;
}


#pragma mark -

- (void)_addItem:(NSDictionary *)item {
  NSString *sectionName = item[_sectionKey];
  
  if (sectionName == nil) {
    /* If there are no section keys in the data, a single section
     * will be created.  If the user is interating through the section
     * array it should just work.  They should not use the value as a
     * section title, though.
     */
    sectionName = @"Section"; // the default section
  }

  if (sectionName.length > 0) {
    NSUInteger sectionIndex = [_discoveredSectionNames indexOfObject:sectionName];
    if (sectionIndex == NSNotFound) {
      sectionIndex = _discoveredSectionNames.count;
      [_discoveredSectionNames addObject:sectionName];
      [_tableData addObject:[NSMutableArray array]];
    }
    
    [_tableData[sectionIndex] addObject:item];
  } else {
    // If the section is a zero length string, the item is excluded from the table
    NSLog(@"%s: item '%@' has no section name, it will not be displayed",
          __PRETTY_FUNCTION__, item[self.uniqueKey]);
  }
  
  [super.plist addObject:item];
  
}

- (void)_deleteItem:(NSDictionary *)item {
  NSString *uniqueKey = self.uniqueKey;
  NSAssert(uniqueKey != nil, @"Must have a uniqueKey defined to delete items.");
  NSAssert(item[uniqueKey] != nil, @"Cannot delete item %@ without a unique key of '%@'", item, uniqueKey);

  NSString *sectionName = item[_sectionKey];
  if (sectionName == nil) {
    sectionName = @"Section"; // the default section
  }
  NSUInteger sectionIndex = [_discoveredSectionNames indexOfObject:sectionName];
  
  __block NSUInteger foundIndex = NSNotFound;
  [self.plist enumerateObjectsUsingBlock:^(NSDictionary *possibleItem, NSUInteger idx, BOOL *stop) {
    if ([possibleItem[uniqueKey] isEqualToString:item[uniqueKey]]) {
      *stop = YES;
      foundIndex = idx;
    }
  }];
  NSAssert(foundIndex != NSNotFound, @"Item not found in raw data. identifier = '%@'", item[uniqueKey]);
  [self.plist removeObjectAtIndex:foundIndex];
  
  if (sectionIndex != NSNotFound) {
    foundIndex = NSNotFound;
    [_tableData[sectionIndex] enumerateObjectsUsingBlock:^(NSDictionary *possibleItem, NSUInteger idx, BOOL *stop) {
      if ([possibleItem[uniqueKey] isEqualToString:item[uniqueKey]]) {
        *stop = YES;
        foundIndex = idx;
      }
    }];
    NSAssert(foundIndex != NSNotFound, @"Item not found in table data. identifier = '%@'", item[uniqueKey]);
    [_tableData[sectionIndex] removeObjectAtIndex:foundIndex];
    
    if ([_tableData[sectionIndex] count] == 0) { // if last item from section is removed
      [_discoveredSectionNames removeObjectAtIndex:sectionIndex];
      [_tableData removeObjectAtIndex:sectionIndex];
    }
  }
}

/**
 * Resets internal data structure from scratch. No table view updating.
 */
- (void)_updateData:(NSArray *)newData {
  if (newData == nil) {
    [super.plist removeAllObjects];
    self.tableData = nil;
    return;
  }
  
  [super.plist removeAllObjects];
  self.tableData = [NSMutableArray array];
  self.discoveredSectionNames = [NSMutableArray array];
  
  [newData enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger idx, BOOL *stop) {
    [self _addItem:item];
  }];
}

- (void)replaceValue:(id)value forKey:(NSString *)key atIndex:(NSUInteger)index {
  if ([key isEqualToString:_sectionKey]) {
    NSDictionary *item = super.plist[index];
    [self _deleteItem:item];
    NSMutableDictionary *newItem = [item mutableCopy];
    newItem[key] = value;
    [self _addItem:newItem];
  } else {
    [super replaceValue:value forKey:key atIndex:index];
  }
}

#pragma mark -

- (instancetype)init {
  return [self initWithArray:nil];
}


- (NSArray *)itemsForSection:(NSString *)sectionName {
  NSUInteger sectionIndex = [_discoveredSectionNames indexOfObject:sectionName];
  if (sectionIndex == NSNotFound)
  NSAssert(sectionIndex != NSNotFound, @"The value '%@' is not a valid section name", sectionName);
  return [self itemsForSectionIndex:sectionIndex];
}

- (NSArray *)itemsForSectionIndex:(NSUInteger)sectionIndex {
  [self plist]; // force cache creation
  return _tableData[sectionIndex];
}

- (NSIndexPath *)indexPathForItem:(NSDictionary *)item {
  NSUInteger section = [self.sectionNames indexOfObject:item[_sectionKey]];
  NSUInteger row = [[self itemsForSection:item[_sectionKey]] indexOfObject:item];
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
  return indexPath;
}

#pragma mark - Updating Source

- (NSArray *)_sectionNameListForArray:(NSArray *)values {
  NSMutableArray *sectionNames = [NSMutableArray arrayWithCapacity:self.sectionNames.count];
  
  [values enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger idx, BOOL *stop) {
    NSString *name = item[_sectionKey];
    if (name.length > 0 && [sectionNames containsObject:name] == NO) {
      [sectionNames addObject:name];
    }
  }];
  
  return sectionNames;
}

- (void)_processDeletionsWithNewValues:(NSArray *)newValues
                       informTableView:(UITableView *)tableView {
  
  NSArray *oldItems = [self oldItemsNotInNewArray:newValues];
  
  if (oldItems.count > 0) {
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:oldItems.count];
    [oldItems enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger idx, BOOL *stop) {
      NSIndexPath *indexPath = [self indexPathForItem:item];
      [indexPaths addObject:indexPath];
      
      [self _deleteItem:item];
    }];
    
#warning not hangling tableview management for deleting the last item of a section
    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
  }
  
}

- (void)_processInsertsWithNewValues:(NSArray *)newValues
                     informTableView:(UITableView *)tableView {
  
  NSArray *newItems = [self newItemsNotInArray:newValues];

  if (newItems.count > 0) {
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:newItems.count];
    NSMutableArray *newSectionNames = [NSMutableArray array];
    [newItems enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger idx, BOOL *stop) {
      NSString *sectionName = item[_sectionKey];
      NSUInteger section = [self.sectionNames indexOfObject:sectionName];
      if (section == NSNotFound) {
        [self _addItem:item];
        [newSectionNames addObject:sectionName];
      } else {
        NSArray *itemsInSection = [self itemsForSection:sectionName];
        NSUInteger row = itemsInSection.count;
        [self _addItem:item];
        [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
      }
    }];

    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [newSectionNames enumerateObjectsUsingBlock:^(NSString *sectionName, NSUInteger idx, BOOL *stop) {
      NSUInteger index = [self.sectionNames indexOfObject:sectionName];
      [indexSet addIndex:index];
    }];
    if (indexSet.count > 0) {
      [tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
      [[indexPaths copy] enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        if ([indexSet containsIndex:indexPath.section]) {
          [indexPaths removeObject:indexPath];
        }
      }];
    }
    if (indexPaths.count > 0) {
      [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
  }
}

- (void)_processUpdatesWithNewValues:(NSArray *)newValues
                     informTableView:(UITableView *)tableView {
  
  NSAssert(self.updatableKeys.count > 0, @"must define the updatableKeys value");
  NSString *uniqueKey = self.uniqueKey;
  NSArray *updatedKeys = self.updatableKeys;
  
  [newValues enumerateObjectsUsingBlock:^(NSDictionary *newItem, NSUInteger idx1, BOOL *stop1) {
    NSString *itemId = newItem[uniqueKey];
    NSUInteger oldIndex = [self indexForIdentifier:itemId];
    NSDictionary *oldItem = self.plist[oldIndex];
    __block BOOL changed = NO;
    [updatedKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx2, BOOL *stop2) {
      id oldValue = oldItem[key];
      id newValue = newItem[key];
      if ([oldValue isEqual:newValue] == NO) {
        [self replaceValue:newValue forKey:key atIndex:oldIndex];
        changed = YES;
      }
    }];
    if (changed && [oldItem[_sectionKey] length] > 0) {
      NSArray *indexPaths = @[[self indexPathForItem:oldItem]];
      [tableView reloadRowsAtIndexPaths:indexPaths
                       withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [self _subprocessNewSectionFor:oldItem newItem:newItem atIndex:oldIndex informTableView:tableView];
  }];
}

- (void)_subprocessNewSectionFor:(NSDictionary *)oldItem
                          newItem:(NSDictionary *)newItem
                         atIndex:(NSUInteger)index
                  informTableView:(UITableView *)tableView {
  
  NSString *oldSection = oldItem[_sectionKey];
  NSString *newSection = newItem[_sectionKey];
  if ([oldSection isEqualToString:newSection] == NO) {

    if (oldSection.length == 0) {
      NSUInteger section = [self.sectionNames indexOfObject:newSection];
      [self replaceValue:newSection forKey:_sectionKey atIndex:index];
      
      if (section == NSNotFound) { // adding a section
        section = [self.sectionNames indexOfObject:newSection];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
        [tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
      } else { // adding a new row in a section
        NSUInteger row = [[self itemsForSection:newSection] count] - 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
      }
      
    } else if (newSection.length == 0) {
      NSUInteger section = [self.sectionNames indexOfObject:oldSection];
      [self replaceValue:newSection forKey:_sectionKey atIndex:index];
      NSUInteger sectionAfterDelete = [self.sectionNames indexOfObject:oldSection];
      
      if (sectionAfterDelete == NSNotFound) { // section deleted
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
        [tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
      } else { // row in section deleted
        NSUInteger row = [[self itemsForSection:oldSection] count];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
      }
      
    } else { // moving sections
      NSUInteger toSection = [self.sectionNames indexOfObject:newSection];
      [self replaceValue:newSection forKey:_sectionKey atIndex:index];
      NSUInteger fromSection = [self.sectionNames indexOfObject:oldSection];
      
      [tableView beginUpdates];
      
      if (toSection == NSNotFound) { // creating section
        toSection = [self.sectionNames indexOfObject:newSection];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:toSection];
        [tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
      } else { // adding to section
        NSUInteger row = [[self itemsForSection:newSection] count] - 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:toSection];
        [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
      }
      
      if (fromSection == NSNotFound) { // deleting section
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:fromSection];
        [tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
      } else { // removing from section
        NSUInteger row = [[self itemsForSection:newSection] count];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:fromSection];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
      }
      
      [tableView endUpdates];
      
      
    }
  }
}

- (void)updateSource:(NSArray *)newValues informTableView:(UITableView *)tableView {
  NSAssert(_sectionKey != nil, @"can't delete without knowing the section");
  NSAssert(_unprocessedData == nil, @"Expecting the underlying data to be in a steady state");
  NSAssert(self.uniqueKey != nil, @"A unique item identifier must me set and used in the collection");
  
  NSArray *newSectionList = [self _sectionNameListForArray:newValues];
  if ([newSectionList isEqualToArray:self.sectionNames]) {
    [self _processDeletionsWithNewValues:newValues informTableView:tableView];
    [self _processInsertsWithNewValues:newValues informTableView:tableView];
    // there's a little bit of extra work being done, updating what was
    [self _processUpdatesWithNewValues:newValues informTableView:tableView];
  } else {
    /// could be made to handle it more elegantly, depending on change
    NSLog(@"%s: section list modification not yet supported. Was %@, Now %@",
          __PRETTY_FUNCTION__, self.sectionNames, newSectionList);
    self.unprocessedData = newValues;
    [self plist];
    [tableView reloadData];
  }
}


@end
