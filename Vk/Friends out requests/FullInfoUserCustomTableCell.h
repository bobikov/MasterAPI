//
//  FullInfoUserCustomTableCell.h
//  MasterAPI
//
//  Created by sim on 15/07/17.
//  Copyright © 2017 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FullInfoUserCustomTableCell : NSTableCellView
@property (weak) IBOutlet NSTextField *fieldName;
@property (weak) IBOutlet NSTextField *valueField;

@end
