//
//  CustomMenuItemView.h
//  MasterAPI
//
//  Created by sim on 06.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CustomMenuItemView : NSView{
    NSColor *backgroundColor;
}
@property (weak) IBOutlet NSTextField *nameField;

@property (weak) IBOutlet NSImageView *photo;

@end
