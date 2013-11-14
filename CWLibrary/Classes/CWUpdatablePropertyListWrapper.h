//
//  CWUpdatablePropertyListWrapper.h
//  
//
//  Created by Bill Shirley on 11/13/13.
//
//

#import <Foundation/Foundation.h>

/*!
 @class CWUpdatablePropertyListWrapper
 
  Superclass for classes that are wrapping and added functionality
  to property list arrays.
 
  Each array is a list of dictionaries describing and "item".
  Each item should have a unique value at the key listed and
  when updated will copy a defined list of keys from the updated
  collection.
 */
@interface CWUpdatablePropertyListWrapper : NSObject

/**
 * The actual data updated and persisted by this class. The user should
 * not directly modify it unless otherwise noted.
 */
@property (nonatomic, strong) NSMutableArray *plist;

@property (nonatomic, strong) NSString *uniqueKey;

@property (nonatomic, strong) NSArray *updatableKeys;

/**
 * Returns the index for the item with presented identifier.
 * Or NSNotFound if now present.
 */
- (NSUInteger)indexForIdentifier:(NSString *)uniqueIdentifier;

- (NSDictionary *)itemForIdentifier:(NSString *)uniqueItentifier;


/**
 * Replaces the value of a particular key of a particular item.
 * You need to invoke synchronize to ensure this updating is saved.
 */
- (void)replaceValue:(id)value forKey:(NSString *)key atIndex:(NSUInteger)index;



/*!
 @functiongroup List Updates Support
 */


/**
 * Given the passed new values, it returns a collection of old items
 * not present in this array.  They will thus need to be removed from
 * the current array.
 */
- (NSArray *)oldItemsNotInNewArray:(NSArray *)newValues;


/*!
 @abstract returns and NSArray of which items are new
 @discussion
  Informs the called of the actual new items contain in the newValues
 array passed into the method.
 
 @param newValues
  An NSArray of new values that the underlying plist is about to be set to.
 @return
  The items in the parameter that do not yet exist in the underlying plist.
 */
- (NSArray *)newItemsNotInArray:(NSArray *)newValues;

@end
