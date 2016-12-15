//
//  SelectedDialogCustomCellView.h
//  vkapp
//
//  Created by sim on 26.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SelectedDialogCustomCellView : NSTableCellView{
    
}
@property (weak) IBOutlet NSTextField *textMessage;

@property (weak) IBOutlet NSImageView *profileImage;

@property (weak) IBOutlet NSTextField *userFullName;
@property (weak) IBOutlet NSTextField *dateOfMessage;

@end
