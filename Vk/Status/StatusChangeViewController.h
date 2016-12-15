//
//  StatusChangeViewController.h
//  vkapp
//
//  Created by sim on 24.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
@interface StatusChangeViewController : NSViewController{
    __weak IBOutlet NSTextField *currentStatus;
    __unsafe_unretained IBOutlet NSTextView *textNewStatus;
    __weak IBOutlet NSTableView *listOfStatus;
    __weak IBOutlet NSButton *setNewStatusButton;
    __weak IBOutlet NSTextField *symbolCounter;
    NSMutableArray *statusListData;
    NSString *currentStatusData;
    __weak IBOutlet NSButton *saveStatus;
    
}
@property (nonatomic)appInfo *app;

@end
