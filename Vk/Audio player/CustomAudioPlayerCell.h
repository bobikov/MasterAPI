//
//  CustomAudioPlayerCell.h
//  vkapp
//
//  Created by sim on 05.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CustomAudioPlayerCell : NSTableCellView
@property (weak) IBOutlet NSTextField *title;
@property (weak) IBOutlet NSTextField *duration;

@end
