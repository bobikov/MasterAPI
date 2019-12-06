//
//  AddRepostGroupController.h
//  MasterAPI
//
//  Created by sim on 09.11.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AddRepostGroupController : NSViewController{
    
    __weak IBOutlet NSTextField *groupName;
    NSManagedObjectContext *moc;
}
@property(nonatomic, readwrite) NSMutableArray *receivedData;
@end
