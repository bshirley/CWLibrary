//
//  TableViewSource.h
//  Gwee
//
//  Created by Bill Shirley on 11/9/13.
//  Copyright (c) 2013 Bill Shirley. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CWUpdatablePropertyListWrapper.h"

/**
 @brief A wrapper that manages updates to a list for a UITableView.
 
 @description

  Uses an array of dictionaries as data for a UITableView.
  This class is intended to be used by a UITableViewController
  to maintain the data for the table view; the controller itself
  should declare compliance to UITableViewDataSource and/or
  UITableViewDelegate.
 
  If the source data wants there to be multiple sections in the
  table view, it should define a sectionKey and provide a value
  for that key in each item description in the data.
 
  Updates for the collection do NOT manage reordering the collection
  but only the content of the items.  The items maintain an order in
  which they were added to the collection.
 */
@interface CWSimpleFlatTableViewSource : CWUpdatablePropertyListWrapper


- (instancetype)initWithArray:(NSArray *)values;

/**
 * If the data will be broken into multiple sections, this is
 * the key within the data that will define that.  If there is
 * only one section for the data, this can be ignored.
 */
@property (nonatomic, strong) NSString *sectionKey;

/**
 * This array will be created by reading all the items in the list
 * and obtaining a unique list of sectionKey values.  It will be in
 * the order that the sectionKeys are found in the data array.
 *
 * The count of this array should be used to determine the number of sections.
 */
@property (nonatomic, readonly) NSArray *sectionNames;

/**
 * Returns the items present in this section.  Each item will be a
 * dictionary, and each item will have a sectionKey with a value of
 * sectionName.
 */
- (NSArray *)itemsForSection:(NSString *)sectionName;
- (NSArray *)itemsForSectionIndex:(NSUInteger)sectionIndex;


/**
 * When the underlying data has been updated, invoke this method with the
 * new array.  If the tableView is non-nil, it will be updated as to the
 * changes.
 *
 * Optionally you can pass nil as the tableView and then reloadData for
 * a brute force update.
 */
- (void)updateSource:(NSArray *)newValues informTableView:(UITableView *)tableView;

@end
