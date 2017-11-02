//
//  CreateFavesGroupController.m
//  MasterAPI
//
//  Created by sim on 17.01.17.
//  Copyright © 2017 sim. All rights reserved.
//

#import "CreateFavesGroupController.h"
#import "AppDelegate.h"

@interface CreateFavesGroupController ()

@end

@implementation CreateFavesGroupController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", _source);
    
}
- (void)keyDown:(NSEvent *)event{
    NSLog(@"%d", event.keyCode);
    //    NSLog(@"%d", NSRightArrowFunctionKey);
    NSString*   const   character   =   [event charactersIgnoringModifiers];
    unichar     const   code        =   [character characterAtIndex:0];
    switch (event.keyCode){
        case 53:
            [self dismissController:self];
            break;
    }
}

-(BOOL)acceptsFirstResponder{
    return YES;
}

-(void)mouseDown:(NSEvent *)event{
    AppDelegate *appDelegate = ((AppDelegate *)[NSApplication sharedApplication].delegate);
    
   [self.view.window makeFirstResponder:nil];
    NSLog(@"KKKKKK");
    

}
-(void)viewDidAppear{
//    [self.view.window setAcceptsMouseMovedEvents:YES];
    [self.view.window makeFirstResponder:self];
//    self.view.window.delegate=self;
   
}
- (IBAction)create:(id)sender {
    NSLog(@"CREATE");
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
