//
//  FullGroupInfoViewController.h
//  MasterAPI
//
//  Created by sim on 01.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
#import "StringHighlighter.h"
@interface FullGroupInfoViewController : NSViewController{
    
    __weak IBOutlet NSTextField *name;
    __weak IBOutlet NSTextField *status;
    __weak IBOutlet NSTextField *groupId;
    __weak IBOutlet NSImageView *photo;
    __weak IBOutlet NSTextField *screenName;

    __weak IBOutlet NSTextField *desc;
    
   
    __weak IBOutlet NSTextField *site;
    __weak IBOutlet NSTextField *country;
    __weak IBOutlet NSTextField *city;
    __weak IBOutlet NSTextField *startDate;
    NSMutableArray *groupDataById;
    __weak IBOutlet NSStackView *mainStack;
    __weak IBOutlet NSTextField *membersCount;
}
@property(nonatomic) StringHighlighter *stringHighlighter;
@property (nonatomic, readwrite) NSDictionary *receivedData;
@property (nonatomic, readwrite) appInfo *app;
@end
