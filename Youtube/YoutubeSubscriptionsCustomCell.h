//
//  YoutubeSubscriptionsCustomCell.h
//  MasterAPI
//
//  Created by sim on 12.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface YoutubeSubscriptionsCustomCell : NSTableCellView
@property (weak) IBOutlet NSImageView *photo;
@property (weak) IBOutlet NSTextField *desc;
@property (weak) IBOutlet NSTextField *gtitle;
@property (weak) IBOutlet NSTextField *publishedDate;
@property (weak) IBOutlet NSTextField *chId;


@end
