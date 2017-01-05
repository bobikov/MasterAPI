//
//  CustomSearchCell.h
//  vkapp
//
//  Created by sim on 02.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CustomSearchCell : NSTableCellView{
    

}
@property (weak) IBOutlet NSTextField *userStatus;

@property (weak) IBOutlet NSTextField *name;
@property (weak) IBOutlet NSTextField *fieldId;
@property (weak) IBOutlet NSImageView *photo;
@property (weak) IBOutlet NSImageView *status;
@property (weak) IBOutlet NSImageView *blacklisted;
@property (weak) IBOutlet NSTextField *lastSeen;

@end
