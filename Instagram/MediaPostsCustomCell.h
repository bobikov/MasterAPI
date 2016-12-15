//
//  MediaPostsCustomCell.h
//  MasterAPI
//
//  Created by sim on 14.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MediaPostsCustomCell : NSTableCellView

@property (weak) IBOutlet NSButton *postImage;
@property (weak) IBOutlet NSTextField *caption;
@property (weak) IBOutlet NSTextField *date;

@end
