//
//  VKLikesCellTableView.h
//  MasterAPI
//
//  Created by sim on 14/07/17.
//  Copyright © 2017 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VKLikesCellTableView : NSTableCellView
@property (weak) IBOutlet NSImageView *photo;
@property (weak) IBOutlet NSTextField *fullName;

@end
