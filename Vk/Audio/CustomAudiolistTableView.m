//
//  CustomAudiolistTableView.m
//  MasterAPI
//
//  Created by sim on 17.11.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "CustomAudiolistTableView.h"

@implementation CustomAudiolistTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
-(NSMenu*)menuForEvent:(NSEvent*)theEvent
{
    NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    _row = [self rowAtPoint:mousePoint];
    
    if (theEvent.type==NSRightMouseDown) {
        
        NSMenu *menu=[[NSMenu alloc] initWithTitle:@"List of audiolist options"];
        NSString *createAlbumFromArtistText = @"Create album from Artist";
        //        NSString *userBanAndDeleteDialogText = @"Ban this user and delete dialog";
        NSMenuItem *createAlbumFromArtistItem = [[NSMenuItem alloc] initWithTitle:createAlbumFromArtistText action:@selector(createAlbumFromArtist:) keyEquivalent:@""];
        //        NSMenuItem *userBanAndDeleteDialogItem = [[NSMenuItem alloc] initWithTitle:userBanAndDeleteDialogText action:@selector(userBanAndDeleteDialog) keyEquivalent:@""];
        [menu addItem:createAlbumFromArtistItem];
        //        [menu addItem:userBanAndDeleteDialogItem];
        return menu;
    }
    return nil;
}

-(void)userBanAndDeleteDialog{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userBanAndDeleteDialog" object:self userInfo:@{@"row":[NSNumber numberWithInteger:_row]}];
}
- (IBAction)createAlbumFromArtist:(id)sender{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"createAlbumFromArtistInAudiolist" object:self userInfo:@{@"row":[NSNumber numberWithInteger:_row]}];
}
@end
