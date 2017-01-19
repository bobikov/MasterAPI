//
//  CreateFavesGroupController.m
//  MasterAPI
//
//  Created by sim on 17.01.17.
//  Copyright © 2017 sim. All rights reserved.
//

#import "CreateFavesGroupController.h"

@interface CreateFavesGroupController ()

@end

@implementation CreateFavesGroupController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (IBAction)create:(id)sender {
    if([_source isEqual:@"users"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateFavesGroup" object:nil userInfo:@{@"group_name":groupNameField.stringValue, @"only_create":[NSNumber numberWithInteger:_onlyCreate], @"source":_source}];
        [self dismissController:self];
    }
    else if([_source isEqual:@"groups"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateGroupsFavesGroup" object:nil userInfo:@{@"group_name":groupNameField.stringValue, @"only_create":[NSNumber numberWithInteger:_onlyCreate],@"source":_source}];
        [self dismissController:self];
    }
    
}

@end
