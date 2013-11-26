//
//  CWLibraryTests.m
//  CWLibraryTests
//
//  Created by Bill Shirley on 11/14/13.
//  Copyright (c) 2013 shirl.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CWSimpleFlatTableViewSource.h"
#import "TestViewController.h"
#import "CWAppDelegate.h"


@interface CWSimpleFlatTableViewSourceTest : XCTestCase
@property (nonatomic, strong) NSDictionary *model;
@end


/*!
 These tests check that manipulating the data objects reflects what
 is expected. They do not test the UITableView interaction to assure
 that the table updates are invoked correctly.
 @internal
 */
@implementation CWSimpleFlatTableViewSourceTest

- (void)setUp {
  [super setUp];
  self.model = @{
                 @"simple1": @[
                     @{@"uid": @"id1",
                       @"cat": @"foo",
                       @"dat": @"content",
                       },
                     ],
                 
                 @"simple2": @[
                     @{@"uid": @"id2",
                       @"cat": @"bar",
                       @"dat": @"content",
                       },
                     ],
                 
                 @"twoItemsOneSection": @[
                     @{@"uid": @"id1",
                       @"cat": @"bar",
                       @"dat": @"content x",
                       },
                     @{@"uid": @"id2",
                       @"cat": @"bar",
                       @"dat": @"content y",
                       },
                     ],
                 
                 @"threeSections": @[
                     @{@"uid": @"id3-1",
                       @"cat": @"foo",
                       @"dat": @"content f",
                       },
                     @{@"uid": @"id3-2",
                       @"cat": @"bar",
                       @"dat": @"content b",
                       },
                     @{@"uid": @"id3-3",
                       @"cat": @"baz",
                       @"dat": @"content z",
                       },
                     ],

                 /// Group used for one test
                 @"testa-base": @[ // base state
                     @{@"uid": @"id1",
                       @"cat": @"Section1",
                       @"dat": @"content 1",
                       },
                     @{@"uid": @"id2",
                       @"cat": @"Section1",
                       @"dat": @"content 2",
                       },
                     ],

                 @"testa-1": @[ // deleted id2
                     @{@"uid": @"id1",
                       @"cat": @"Section1",
                       @"dat": @"content 1",
                       },
                     ],

                 @"testa-2": @[ // deleted id1
                     @{@"uid": @"id2",
                       @"cat": @"Section1",
                       @"dat": @"content 2 update", // content changed
                       },
                     ],

                 @"testa-3": @[
                     @{@"uid": @"id1",
                       @"cat": @"Section1",
                       @"dat": @"content 1",
                       },
                     @{@"uid": @"id2",
                       @"cat": @"Section2", // changed sections, creating new section
                       @"dat": @"content 2",
                       },
                     ],

                 @"testa-4": @[ // changed both sections, deleting original
                     @{@"uid": @"id1",
                       @"cat": @"Section2",
                       @"dat": @"content 1",
                       },
                     @{@"uid": @"id2",
                       @"cat": @"Section2",
                       @"dat": @"content 2",
                       },
                     ],

                 
                 /// -----------
                 @"empty1": @[ // is empty because section is not defined
                     @{@"uid": @"id3",
                       @"cat": @"",
                       @"dat": @"content not seen",
                       },
                     ],
                 };
}

- (void)tearDown {
  [super tearDown];
}

- (void)testCreation {
  CWSimpleFlatTableViewSource *source = [[CWSimpleFlatTableViewSource alloc] initWithArray:_model[@"simple1"]];
  XCTAssertNotNil(source, @"creation works");
  XCTAssertEqualObjects(source.plist, _model[@"simple1"], @"array is still the same");
}

- (void)testSectionsSingle {
  CWSimpleFlatTableViewSource *source = [[CWSimpleFlatTableViewSource alloc] initWithArray:_model[@"threeSections"]];
  // sectionKey not set:
  XCTAssertEqual((NSUInteger)1, source.sectionNames.count, @"divying up section correctly");
  
  source = [[CWSimpleFlatTableViewSource alloc] initWithArray:_model[@"twoItemsOneSection"]];
  source.sectionKey = @"cat";
  XCTAssertEqual((NSUInteger)1, source.sectionNames.count, @"divying up section correctly");
  XCTAssertEqual((NSUInteger)2, [[source itemsForSection:@"bar"] count], @"two items in section");
}

- (void)testSectionsMulti {
  CWSimpleFlatTableViewSource *source = [[CWSimpleFlatTableViewSource alloc] initWithArray:_model[@"threeSections"]];
  source.sectionKey = @"cat";
  XCTAssertEqual((NSUInteger)3, source.sectionNames.count, @"divying up section correctly");
}

- (void)testExceptionsForDeleting {
  CWSimpleFlatTableViewSource *source = [[CWSimpleFlatTableViewSource alloc] initWithArray:_model[@"simple1"]];
  source.sectionKey = @"cat";
  XCTAssertThrows([source updateSource:@[] informTableView:nil], @"should require a section identifier for deletion");

  source = [[CWSimpleFlatTableViewSource alloc] initWithArray:_model[@"simple1"]];
  source.uniqueKey = @"uid";
  XCTAssertThrows([source updateSource:@[] informTableView:nil], @"should require a unique id for deletion");
}

- (void)testEmptyArrays {
  CWSimpleFlatTableViewSource *source = [[CWSimpleFlatTableViewSource alloc] initWithArray:_model[@"simple1"]];
  source.sectionKey = @"cat";
  source.uniqueKey = @"uid";
  source.updatableKeys = @[@"dat"];
  XCTAssertEqual((NSUInteger)1, source.plist.count, @"initilizes with one item");
  XCTAssertNoThrow([source updateSource:@[] informTableView:nil], @"expecting no problems");
  XCTAssertEqual((NSUInteger)0, source.plist.count, @"handled being held an empty array");
  XCTAssertNoThrow([source updateSource:_model[@"simple1"] informTableView:nil], @"expecting no problems");
  XCTAssertEqual((NSUInteger)1, source.plist.count, @"resets to one item");
  XCTAssertNoThrow([source updateSource:_model[@"simple2"] informTableView:nil], @"expecting no problems");
  XCTAssertEqual((NSUInteger)1, source.plist.count, @"changes to new one item");
  XCTAssertNoThrow([source updateSource:_model[@"simple2"] informTableView:nil], @"expecting no problems");
  XCTAssertEqual((NSUInteger)1, source.plist.count, @"a no-op update didn't cause a problem");
}

- (void)subtestA_modifications:(TestViewController *)tvc {
  CWSimpleFlatTableViewSource *source = [[CWSimpleFlatTableViewSource alloc] initWithArray:_model[@"testa-base"]];
  source.sectionKey = @"cat";
  source.uniqueKey = @"uid";
  source.updatableKeys = @[@"dat"];
  
  XCTAssertNoThrow(tvc.source = source, @"Expecting passed argument to be a valid class type");
  
  XCTAssertEqual((NSUInteger)2, source.plist.count, @"underlying setup correct");
  XCTAssertEqual((NSUInteger)1, source.sectionNames.count, @"one section");
  XCTAssertEqual((NSUInteger)2, [[source itemsForSectionIndex:0] count], @"section with two items");
  XCTAssertEqualObjects(@"id1", source.plist[0][@"uid"], @"only item is id1");
  XCTAssertEqualObjects(@"id2", source.plist[1][@"uid"], @"only item is id2");
  
  // delete second item
  XCTAssertNoThrow([source updateSource:_model[@"testa-1"] informTableView:nil], @"update without incident");
  XCTAssertEqual((NSUInteger)1, source.plist.count, @"underlying update correct");
  XCTAssertEqual((NSUInteger)1, source.sectionNames.count, @"still one section");
  XCTAssertEqual((NSUInteger)1, [[source itemsForSectionIndex:0] count], @"section with one item");
  XCTAssertEqualObjects(@"id1", source.plist[0][@"uid"], @"only item is id1");

  // reset
  XCTAssertNoThrow([source updateSource:_model[@"testa-base"] informTableView:nil], @"update without incident");
  XCTAssertEqual((NSUInteger)2, source.plist.count, @"underlying update correct");
  XCTAssertEqual((NSUInteger)1, source.sectionNames.count, @"still one section");
  XCTAssertEqual((NSUInteger)2, [[source itemsForSectionIndex:0] count], @"section with two items");
  XCTAssertEqualObjects(@"id1", source.plist[0][@"uid"], @"only item is id1");
  XCTAssertEqualObjects(@"id2", source.plist[1][@"uid"], @"only item is id2");
  XCTAssertEqualObjects([source itemForIdentifier:@"id2"][@"dat"], @"content 2", @"should have expected content");

  // delete first item, change second item's data
  XCTAssertNoThrow([source updateSource:_model[@"testa-2"] informTableView:nil], @"update without incident");
  XCTAssertEqual((NSUInteger)1, source.plist.count, @"underlying update correct");
  XCTAssertEqual((NSUInteger)1, source.sectionNames.count, @"still one section");
  XCTAssertEqual((NSUInteger)1, [[source itemsForSectionIndex:0] count], @"section with one item");
  XCTAssertEqualObjects(@"id2", source.plist[0][@"uid"], @"only item is id2");
  XCTAssertEqualObjects([source itemForIdentifier:@"id2"][@"dat"], @"content 2 update", @"should have expected content");

  // remove single item while adding different single item, same section
  XCTAssertNoThrow([source updateSource:_model[@"testa-1"] informTableView:nil], @"update without incident");
  XCTAssertEqual((NSUInteger)1, source.plist.count, @"underlying update correct");
  XCTAssertEqual((NSUInteger)1, source.sectionNames.count, @"still one section");
  XCTAssertEqual((NSUInteger)1, [[source itemsForSectionIndex:0] count], @"section with one item");
  XCTAssertEqualObjects(@"id1", source.plist[0][@"uid"], @"only item is id1");

  // reset
  XCTAssertNoThrow([source updateSource:_model[@"testa-base"] informTableView:nil], @"update without incident");
  XCTAssertEqual((NSUInteger)2, source.plist.count, @"underlying update correct");
  XCTAssertEqual((NSUInteger)1, source.sectionNames.count, @"still one section");
  XCTAssertEqual((NSUInteger)2, [[source itemsForSectionIndex:0] count], @"section with two items");
  XCTAssertEqualObjects(@"id1", source.plist[0][@"uid"], @"only item is id1");
  XCTAssertEqualObjects(@"id2", source.plist[1][@"uid"], @"only item is id2");


  // changed the sections for one of the two items
  XCTAssertNoThrow([source updateSource:_model[@"testa-3"] informTableView:nil], @"update without incident");
  XCTAssertEqual((NSUInteger)2, source.plist.count, @"underlying update correct");
  XCTAssertEqual((NSUInteger)2, source.sectionNames.count, @"now two sections");
  XCTAssertEqual((NSUInteger)1, [[source itemsForSectionIndex:0] count], @"section with one item");
  XCTAssertEqual((NSUInteger)1, [[source itemsForSectionIndex:1] count], @"section with one item");
  XCTAssertEqualObjects(@"id1", source.plist[0][@"uid"], @"only item is id1");
  XCTAssertEqualObjects(@"id2", source.plist[1][@"uid"], @"only item is id2");

  XCTAssertEqualObjects([source itemsForSectionIndex:0], [source itemsForSection:@"Section1"], @"equivalence of method calls");
  XCTAssertEqualObjects([source itemsForSectionIndex:1], [source itemsForSection:@"Section2"], @"equivalence of method calls");

  // reset
  XCTAssertNoThrow([source updateSource:_model[@"testa-base"] informTableView:nil], @"update without incident");
  XCTAssertEqual((NSUInteger)2, source.plist.count, @"underlying update correct");
  XCTAssertEqual((NSUInteger)1, source.sectionNames.count, @"still one section");
  XCTAssertEqual((NSUInteger)2, [[source itemsForSectionIndex:0] count], @"section with two items");
  XCTAssertEqualObjects(@"id1", source.plist[0][@"uid"], @"item is id1");
  XCTAssertEqualObjects(@"id2", source.plist[1][@"uid"], @"item is id2");
  XCTAssertEqualObjects(@"Section1", source.sectionNames[0], @"expected section name");

  // changed the sections both items
  XCTAssertNoThrow([source updateSource:_model[@"testa-4"] informTableView:nil], @"update without incident");
  XCTAssertEqual((NSUInteger)2, source.plist.count, @"underlying update correct");
  XCTAssertEqual((NSUInteger)1, source.sectionNames.count, @"still one section");
  XCTAssertEqual((NSUInteger)2, [[source itemsForSectionIndex:0] count], @"section with two items");
  XCTAssertEqualObjects(@"id1", source.plist[0][@"uid"], @"item is id1");
  XCTAssertEqualObjects(@"id2", source.plist[1][@"uid"], @"item is id2");
  XCTAssertEqualObjects(@"Section2", source.sectionNames[0], @"expected section name");

  
}

- (void)testA_modifications_withoutTable {
  [self subtestA_modifications:nil];
}

- (void)testA_modifications_withTable {
  TestViewController *tvc = (TestViewController *)[(CWAppDelegate *)[[UIApplication sharedApplication] delegate] tableViewController];
  [self subtestA_modifications:tvc];
}

@end




