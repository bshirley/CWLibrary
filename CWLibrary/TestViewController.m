//
//  TestViewController.m
//  CWLibrary
//
//  Created by Bill Shirley on 11/26/13.
//  Copyright (c) 2013 shirl.com. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return self.source.sectionNames.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSArray *items = [self.source itemsForSectionIndex:section];
  return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

  NSArray *items = [self.source itemsForSectionIndex:indexPath.section];
  NSDictionary *item = items[indexPath.row];
  cell.textLabel.text = [NSString stringWithFormat:@"%@", item[self.source.uniqueKey]];

  return cell;
}

@end
