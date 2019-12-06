//
//  EditDocsViewController.h
//  MasterAPI
//
//  Created by sim on 28.11.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EditDocsViewController : NSViewController{
    
    __weak IBOutlet NSTextField *titleField;
    __weak IBOutlet NSTextField *tagsField;
    __weak IBOutlet NSButton *indexCheck;
    __weak IBOutlet NSButton *checkOwnerID;
        
}
@property(nonatomic,readwrite)NSMutableArray *receivedData;
@property(nonatomic,readwrite)NSString *owner;
@end
