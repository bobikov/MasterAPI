//
//  GroupsCustomCellView.h
//  vkapp
//
//  Created by sim on 14.07.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GroupsCustomCellView : NSTableCellView

@property (weak) IBOutlet NSTextField *nameOfGroup;
@property (weak) IBOutlet NSTextField *descriptionOfGroup;
@property (weak) IBOutlet NSImageView *groupImage;
@property (weak) IBOutlet NSTextField *groupId;

@end
