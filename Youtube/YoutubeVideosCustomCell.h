//
//  YoutubeVideosCustomCell.h
//  MasterAPI
//
//  Created by sim on 14.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface YoutubeVideosCustomCell : NSTableCellView
@property (weak) IBOutlet NSImageView *thumb;
@property (weak) IBOutlet NSTextField *vtitle;
@property (weak) IBOutlet NSTextField *publishedDate;
@property (weak) IBOutlet NSButton *playButton;
@property (weak) IBOutlet NSButton *openPlaylistButton;
@property (weak) IBOutlet NSImageView *successMark;
@property (weak) IBOutlet NSTextField *desc;
@property (weak) IBOutlet NSTextField *duration;
@property (weak) IBOutlet NSImageView *onAir;

@end
