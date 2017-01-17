//
//  CustomFaveritesTableView.m
//  MasterAPI
//
//  Created by sim on 31.10.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "CustomFaveritesTableView.h"

@implementation CustomFaveritesTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
-(NSMenu*)menuForEvent:(NSEvent*)theEvent
{
    NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    _row = [self rowAtPoint:mousePoint];
    
    if (theEvent.type==NSRightMouseDown) {
        
        NSMenu *menu=[[NSMenu alloc] initWithTitle:@"Favorite users context menu"];
        [menu setAutoenablesItems:NO];
//      NSString *userBanAndDeleteDialogText = @"Ban this user and delete dialog";
        NSMenuItem *userInfoInBrowserItem = [[NSMenuItem alloc] initWithTitle:@"Visit user page" action:@selector(openUserInfoInBrowser:) keyEquivalent:@""];
        NSMenuItem *createGroupsFromSelectedUsers = [[NSMenuItem alloc] initWithTitle:@"Create group from selected" action:@selector(createGroupWithSelectedUsers) keyEquivalent:@""];
//        NSMenuItem *userBanAndDeleteDialogItem = [[NSMenuItem alloc] initWithTitle:userBanAndDeleteDialogText action:@selector(userBanAndDeleteDialog) keyEquivalent:@""];
        [menu insertItem:createGroupsFromSelectedUsers atIndex:0];
        [createGroupsFromSelectedUsers setEnabled:[[self selectedRowIndexes]count]];
        [menu insertItem:userInfoInBrowserItem atIndex:1];
        //[menu addItem:userBanAndDeleteDialogItem];
        return menu;
    }
    return nil;
}
-(void)createGroupWithSelectedUsers{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateGroupFromSelectedFavesUsers" object:nil userInfo:@{@"row":[NSNumber numberWithInteger:_row]}];
}
-(void)userBanAndDeleteDialog{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userBanAndDeleteDialog" object:self userInfo:@{@"row":[NSNumber numberWithInteger:_row]}];
}
- (IBAction)openUserInfoInBrowser:(id)sender{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VisitUserPageFromFavoriteUsers" object:self userInfo:@{@"row":[NSNumber numberWithInteger:_row]}];
}
@end
