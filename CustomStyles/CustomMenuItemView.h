//
//  CustomMenuItemView.h
//  MasterAPI
//
//  Created by Константин on 09.12.2019.
//  Copyright © 2019 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>




NS_ASSUME_NONNULL_BEGIN

@interface CustomMenuItemView : NSView{
    NSColor *backgroundColor;
}
@property (weak) IBOutlet NSTextField *nameField;

@property (weak) IBOutlet NSImageView *photo;

@end

NS_ASSUME_NONNULL_END
