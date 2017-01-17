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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateFavesGroup" object:nil userInfo:@{@"group_name":groupNameField.stringValue}];
    [self dismissController:self];
    
}

@end
