//
//  CustomFaveritesTableView.h
//  MasterAPI
//
//  Created by sim on 31.10.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CustomFaveritesTableView : NSTableView
@property(nonatomic,readwrite)NSUInteger row;
@property(nonatomic)NSArray *favesUserGroupsNames;
@property(nonatomic)BOOL bannedUser;
@property(nonatomic)NSMutableArray *favesUsersData;
@end
