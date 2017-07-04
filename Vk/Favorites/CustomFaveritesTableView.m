//
//  CustomFaveritesTableView.m
//  MasterAPI
//
//  Created by sim on 31.10.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "CustomFaveritesTableView.h"
@implementation CustomFaveritesTableView
- (void)awakeFromNib{
    if(self)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUserFavesGroups:) name:@"getUserFavesGroupsForContextMenu" object:nil];
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(banAndUnbanStatus:) name:@"banAndUnbanUserInFaves" object:nil];
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    
}
-(void)banAndUnbanStatus:(NSNotification*)obj{
//    _bannedUser = [obj.userInfo[@"banned"] intValue];
    _favesUsersData = obj.userInfo[@"favesUsersData"];
}
-(void)getUserFavesGroups:(NSNotification*)notification{
//    NSLog(@"%@", notification.userInfo[@"groups"]);
  
    _favesUserGroupsNames = notification.userInfo[@"groups"];

    
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
        NSMenuItem *userGroupsMenuItem = [[NSMenuItem alloc]initWithTitle:@"Add to user group" action:NULL keyEquivalent:@""];
        
        [menu insertItem:userGroupsMenuItem atIndex:2];
        [userGroupsMenuItem setEnabled:[[self selectedRowIndexes]count]];
        
        
        if(userGroupsMenuItem.isEnabled){
            NSMenu *userGroupsMenu = [[NSMenu alloc]init];
            [userGroupsMenu setAutoenablesItems:NO];
            for(NSString *i in _favesUserGroupsNames){
                NSMenuItem *item = [[NSMenuItem alloc]initWithTitle:i action:@selector(selectUserGroup:) keyEquivalent:@""];
                [item setEnabled:YES];
                [userGroupsMenu addItem:item];
              
            }
            [userGroupsMenuItem setSubmenu:userGroupsMenu];
        }
        
        NSMenuItem *unbanAndBanUser = [[NSMenuItem alloc]initWithTitle:[_favesUsersData[_row][@"blacklisted_by_me"] intValue] ? @"Remove from blacklist" : @"Add to blacklist" action:@selector(banAndUnbanUser) keyEquivalent:@""];
        [unbanAndBanUser setEnabled:YES];
        [menu addItem:unbanAndBanUser];
        
        return menu;
    }
    return nil;
}
-(void)banAndUnbanUser{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddFavesUserToBanOrUnbun" object:nil userInfo:@{@"row":[NSNumber numberWithInteger:_row], @"bannedStatus":_favesUsersData[_row][@"blacklisted_by_me"]}];
    
}
-(void)selectUserGroup:(NSMenuItem*)obj{
//    NSLog(@"%@", obj.title);
    if([self.identifier isEqual:@"FavesGroups"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddFavesGroupsUserGroupsItemIntoGroup" object:nil userInfo:@{@"group_name":obj.title}];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddFavesUserGroupsItemIntoGroup" object:nil userInfo:@{@"group_name":obj.title}];
    }
}
-(void)createGroupWithSelectedUsers{
    if([self.identifier isEqual:@"FavesGroups"]){
         [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateGroupFromSelectedFavesGroups" object:nil userInfo:@{@"row":[NSNumber numberWithInteger:_row],@"source":@"groups"}];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateGroupFromSelectedFavesUsers" object:nil userInfo:@{@"row":[NSNumber numberWithInteger:_row],@"source":@"users"}];
    }

}
-(void)userBanAndDeleteDialog{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userBanAndDeleteDialog" object:self userInfo:@{@"row":[NSNumber numberWithInteger:_row]}];
}
- (IBAction)openUserInfoInBrowser:(id)sender{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VisitUserPageFromFavoriteUsers" object:self userInfo:@{@"row":[NSNumber numberWithInteger:_row]}];
}
@end
