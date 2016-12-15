//
//  GroupsCustomTableView.m
//  MasterAPI
//
//  Created by sim on 09.11.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "GroupsCustomTableView.h"

@implementation GroupsCustomTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
-(NSMenu*)menuForEvent:(NSEvent*)theEvent
{
    NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    _row = [self rowAtPoint:mousePoint];
    
    if (theEvent.type==NSRightMouseDown) {
        
        NSMenu *menu=[[NSMenu alloc] initWithTitle:@"Groups list"];
        NSString *groupInfoInBrowserText = @"Visit group page";
//        NSString *userBanAndDeleteDialogText = @"Ban this user and delete dialog";
        
        NSMenuItem *groupInfoInBrowserItem = [[NSMenuItem alloc] initWithTitle:groupInfoInBrowserText action:@selector(openGroupInfoInBrowser:) keyEquivalent:@""];
//        NSMenuItem *userBanAndDeleteDialogItem = [[NSMenuItem alloc] initWithTitle:userBanAndDeleteDialogText action:@selector(userBanAndDeleteDialog) keyEquivalent:@""];
        [menu addItem:groupInfoInBrowserItem];
        //        [menu addItem:userBanAndDeleteDialogItem];
        return menu;
    }
    return nil;
}

-(void)userBanAndDeleteDialog{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userBanAndDeleteDialog" object:self userInfo:@{@"row":[NSNumber numberWithInteger:_row]}];
}
- (IBAction)openGroupInfoInBrowser:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VisitGroupPageFromBanlist" object:self userInfo:@{@"row":[NSNumber numberWithInteger:_row]}];
}
@end
