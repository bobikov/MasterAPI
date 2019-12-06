//
//  SearchGroupsCellView.h
//  MasterAPI
//
//  Created by sim on 13.01.17.
//  Copyright © 2017 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SearchGroupsCellView : NSTableCellView
@property (weak) IBOutlet NSTextField *desc;
@property (weak) IBOutlet NSImageView *groupAvatar;
@property (weak) IBOutlet NSTextField *groupName;
@property (weak) IBOutlet NSTextField *groupCountry;

@end
