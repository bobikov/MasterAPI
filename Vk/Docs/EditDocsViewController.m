//
//  EditDocsViewController.m
//  MasterAPI
//
//  Created by sim on 28.11.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "EditDocsViewController.h"

@interface EditDocsViewController ()

@end

@implementation EditDocsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}
- (IBAction)startEdit:(id)sender {
    NSString *title = [titleField.stringValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString *tags = [tagsField.stringValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VKEditDocs" object:nil userInfo:@{@"title":title, @"tags":tags, @"indexed":[NSNumber numberWithInteger:indexCheck.state]}];
}

@end
