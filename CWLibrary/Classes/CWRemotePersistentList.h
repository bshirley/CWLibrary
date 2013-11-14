//
//  PersistentNotificationList.h
//  Gwee
//
//  Created by Bill Shirley on 8/23/13.
//  Copyright (c) 2013 Bill Shirley. All rights reserved.
//

#import "CWUpdatablePropertyListWrapper.h"

/**
 * This class abstacts a plist maintained in a file.
 * Usually the file exists on a remote system defined by
 * the URL used to initialize this persistent list.
 * The plist is expected to be assembled as an array.
 */
@interface CWRemotePersistentList : CWUpdatablePropertyListWrapper

/**
 * the last time this list was refreshed from the remote URL.
 * the value is persisted for each persistent name (not relating
 * to the remote URL used).
 */
@property (nonatomic, strong) NSDate *latestRefreshDate;



/** Designated Initializer.
 * The URL passed will be used to updated the locally persisted list when needed.
 * The persistence name will be used as a key in the user defaults database
 * to store this array.
 */
- (instancetype)initWithURL:(NSURL *)remotePlistURL persistenceName:(NSString *)pname;

/**
 * Upon the user's discretion, this method can be called to update the local
 * persistant version of the plist from the version in the remote URL.
 * The underlying NSMutableArray will be modified and the targeted RPL will
 * be delivered in the callback block.
 */
- (void)refreshWithCallback:(void(^) (CWRemotePersistentList *rpl))callback;

/**
 * Empties the underlying plist and erases the persistent version.
 */
- (void)flushPersistence;

/**
 * If you directly modify the underlying plist (add details to the contents),
 * this method should be invoked to ensure that the update is locally persisted.
 */
- (void)synchronize;


@end
