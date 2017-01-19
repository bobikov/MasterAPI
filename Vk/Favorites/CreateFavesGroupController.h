//
//  CreateFavesGroupController.h
//  MasterAPI
//
//  Created by sim on 17.01.17.
//  Copyright © 2017 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CreateFavesGroupController : NSViewController{
    
    __weak IBOutlet NSTextField *groupNameField;
}
@property(nonatomic)BOOL onlyCreate;
@property(nonatomic)NSString *source;
@end
