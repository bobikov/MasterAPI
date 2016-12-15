//
//  DialogsListCustomCellView.h
//  vkapp
//
//  Created by sim on 26.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DialogsListCustomCellView : NSTableCellView{
    
}
@property (weak) IBOutlet NSTextField *unreadStatus;

@property (weak) IBOutlet NSImageView *userOnlineImage;
@property (weak) IBOutlet NSImageView *profileImage;
@property (weak) IBOutlet NSTextField *userFullName;
@property (weak) IBOutlet NSTextField *previewText;
@property (weak) IBOutlet NSButton *removeDialogButton;
@property(nonatomic)NSTrackingArea *trackingArea;
@end
