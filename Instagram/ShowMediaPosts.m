//
//  ShowMediaPosts.m
//  MasterAPI
//
//  Created by sim on 14.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "ShowMediaPosts.h"
#import "HTMLReader.h"
#import "MediaPostsCustomCell.h"
#import "PhotoSliderViewController.h"
#import "MyTableRowView.h"
@interface ShowMediaPosts ()<NSSearchFieldDelegate,NSTableViewDelegate, NSTableViewDataSource,NSControlTextEditingDelegate>

@end

@implementation ShowMediaPosts

- (void)viewDidLoad {
    [super viewDidLoad];
    mediaPostsList.delegate=self;
    mediaPostsList.dataSource=self;
    postsData = [[NSMutableArray alloc]init];
    mediaURLS = [[NSMutableArray alloc]init];
    searchField.delegate=self;
    instaClient = [[InstagramClient alloc]initWithTokensFromCoreData];
    [[mediaPostsScroll contentView]setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(viewDidScroll:) name:NSViewBoundsDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(copyImageURL:) name:@"Copy instagram image URL" object:nil];
    cellMenu = [[NSMenu alloc] initWithTitle:NSLocalizedString(@"Search Menu", @"Search Menu title")];
    [self searchFieldMenu];
}
- (void)copyImageURL:(NSNotification*)obj{
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [pasteBoard setString:[[mediaURLS objectsAtIndexes:obj.userInfo[@"rows"]] componentsJoinedByString:@"\n"] forType:NSStringPboardType];
}
//-(void)controlTextDidEndEditing:(NSNotification *)obj{
//
//
//    NSRect frame = [searchField frame];
//    NSPoint menuOrigin = [[searchField superview] convertPoint:NSMakePoint(frame.origin.x, frame.origin.y+frame.size.height-25)
//                                                    toView:nil];
//    
//    NSEvent *event =  [NSEvent otherEventWithType: NSApplicationDefined
//                                         location: [searchField frame].origin
//                                    modifierFlags: 0
//                                        timestamp: 0
//                                     windowNumber: [[searchField window] windowNumber]
//                                          context: [[searchField window] graphicsContext]
//                                          subtype: NSApplicationDefined
//                                            data1: 0
//                                            data2: 0];
//    [NSMenu popUpContextMenu:cellMenu withEvent:event forView:searchField];
//    
//}
- (void)viewDidScroll:(NSNotification*)notification{
    NSInteger scrollOrigin = [[mediaPostsScroll contentView]bounds].origin.y+NSMaxY([mediaPostsScroll visibleRect]);
    //    NSInteger numberRowHeights = [collectionViewListAlbums numberOfItemsInSection:0];
    NSInteger boundsHeight = mediaPostsList.bounds.size.height;
    //    NSInteger frameHeight = playList.frame.size.height;
    if (scrollOrigin == boundsHeight+2 && postID) {
        [self loadMediaPosts:searchField.stringValue];
    }

}
- (IBAction)showInBrowser:(id)sender {
    NSInteger index = [mediaPostsList rowForView:[sender superview]];
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:mediaURLS[index]]];
}
- (IBAction)showMedia:(id)sender {
    NSInteger index = [mediaPostsList rowForView:[sender superview]];
    NSLog(@"CURRENT INDEX %li", index);
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    _sliderWindowContr = [story instantiateControllerWithIdentifier:@"PhotoController"];
    [_sliderWindowContr showWindow:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowPhotoSlider" object:nil userInfo:@{@"data":mediaURLS, @"current":[NSNumber numberWithInteger:index+1]}];
 
}
- (void)searchFieldDidStartSearching:(NSSearchField *)sender{
    postID = nil;
    [mediaURLS removeAllObjects];
    [postsData removeAllObjects];
   
    [self loadMediaPosts:searchField.stringValue];
    [self loadProfileInfo:searchField.stringValue];
    
    //username search https://www.instagram.com/web/search/topsearch/?query=name
    //logined user feed https://www.instagram.com/?__a=1
    //tag search https://www.instagram.com/explore/tags/alien/?__a=1 + start_cursor by max_id param
    //username by user_id https://www.instagram.com/query/?q=ig_user(3)
    //likes photo/video https://www.instagram.com/p/%post_is%/?__a=1
    //user info https://www.instagram.com/kevin/?__a=1
    //post info  https://www.instagram.com/p/BGBgSw0tpHQ/?__a=1
}
- (void)searchFieldDidEndSearching:(NSSearchField *)sender{
    
}
- (void)searchFieldMenu{
    
    NSMenuItem *item;
    
    item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Clear", @"Clear menu title")
                                      action:NULL keyEquivalent:@""];
    [item setTag:NSSearchFieldClearRecentsMenuItemTag];
    [cellMenu insertItem:item atIndex:0];
    
    item = [NSMenuItem separatorItem];
    [item setTag:NSSearchFieldRecentsTitleMenuItemTag];
    [cellMenu insertItem:item atIndex:1];
    
    item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Recent Searches", @"Recent Searches menu title")
                                      action:NULL keyEquivalent:@""];
    [item setTag:NSSearchFieldRecentsTitleMenuItemTag];
    [cellMenu insertItem:item atIndex:2];
    
    item = [[NSMenuItem alloc] initWithTitle:@"Recents"
                                      action:NULL keyEquivalent:@""];
    [item setTag:NSSearchFieldRecentsMenuItemTag];
    [cellMenu insertItem:item atIndex:3];
    [searchField setSearchMenuTemplate:cellMenu];
}
- (void)loadProfileInfo:(NSString*)username{
    NSString *profileIinfoHTML = [[NSString alloc]initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.instagram.com/%@", username]] encoding:NSUTF8StringEncoding error:nil];
    HTMLDocument *doc=[HTMLDocument documentWithString:profileIinfoHTML];
    NSArray *script = [doc nodesMatchingSelector:@"script"];
    NSInteger postsCount=0;
    for(HTMLElement *i in script){
        if([i.textContent containsString:@"sharedData"]){
            NSDictionary *ff = [NSJSONSerialization JSONObjectWithData:[[[i.textContent stringByReplacingOccurrencesOfString:@"window._sharedData = " withString:@""]stringByReplacingOccurrencesOfString:@";" withString:@""] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
//            NSLog(@"%@",ff[@"entry_data"][@"ProfilePage"][0][@"user"][@"profile_pic_url_hd"]);
            postsCount=[ff[@"entry_data"][@"ProfilePage"][0][@"user"][@"media"][@"count"] intValue];
//            NSLog(@"%li", postsCount);
            [mediaPostsList reloadData];
            totalCountTitle.title = [NSString stringWithFormat:@"%li", postsCount];
        }
    }
}
- (IBAction)copyMediaURLs:(id)sender {
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [pasteBoard setString:[[mediaURLS objectsAtIndexes:[mediaPostsList selectedRowIndexes]] componentsJoinedByString:@"\n"]   forType:NSStringPboardType];
}
- (IBAction)selectOnlyImages:(id)sender {
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    for(NSString *i in mediaURLS){
        if(![i containsString:@"mp4"]){
            [indexes addIndex:[mediaURLS indexOfObject:i]];
        }
    }
    [mediaPostsList selectRowIndexes:indexes byExtendingSelection:NO];
}
- (void)loadMediaPosts:(NSString*)username{
    [instaClient apiRequest:[NSString stringWithFormat:@"https://instagram.com/%@/media%@", username, postID ? [NSString stringWithFormat:@"?max_id=%@", postID]:@""]  completion:^(NSData *userInfoData) {
        if(userInfoData){
            NSDictionary *mediaResp = [NSJSONSerialization JSONObjectWithData:userInfoData options:0 error:nil];
            postID = [mediaResp[@"more_available"] intValue]?mediaResp[@"items"][[mediaResp[@"items"] count]-1][@"id"]:nil;
            //        NSLog(@"%@",mediaResp);
            for(NSDictionary *i in mediaResp[@"items"]){
                NSString *caption = ![i[@"caption"] isEqual:[NSNull null]] && ![i[@"caption"][@"text"] isEqual:[NSNull null]] ? i[@"caption"][@"text"] : @"";
                [postsData addObject:@{@"thumb":i[@"images"][@"thumbnail"][@"url"],@"caption":caption,@"date":[self formatDate:i[@"created_time"]]}];
                //
                [mediaURLS addObject:[i[@"type"] isEqual:@"video"]?i[@"videos"][@"standard_resolution"][@"url"]:i[@"images"][@"standard_resolution"][@"url"]];
                //            NSLog(@"%@", caption);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [mediaPostsList reloadData];
                loadedCountTitle.title = [NSString stringWithFormat:@"%li", [postsData count]];
            });
        }
    }];
}
- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row{
    MyTableRowView *rowView = [[MyTableRowView alloc]init];
    return rowView;
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [postsData count];
}
- (void)loadMediaPostsByTag:(NSString*)tag{
    [[instaClient.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.instagram.com/explore/tags/%@/?__a=1", tag]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *tagSearchResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        for(NSDictionary *i in tagSearchResp[@"tag"][@"media"][@"nodes"]){
            NSLog(@"%@", i[@"display_src"]);
        }
    }]resume];


}
- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    MediaPostsCustomCell *cell = (MediaPostsCustomCell*)[tableView makeViewWithIdentifier:@"MainCell" owner:self];
    cell.caption.stringValue = postsData[row][@"caption"];
    cell.date.stringValue = postsData[row][@"date"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSImage *postImage = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:postsData[row][@"thumb"]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.postImage.image = postImage;
        });
    });
    return cell;
}
 -(NSString *)formatDate:(NSString*)timestamp{
    NSString *date;
    NSDate *gotDate = [[NSDate alloc] initWithTimeIntervalSince1970: [timestamp intValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd.MM.yyyy"];

    date = [dateFormatter stringFromDate:gotDate];
    return date;;
}
@end
