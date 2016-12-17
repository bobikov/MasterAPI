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
   
    cellMenu = [[NSMenu alloc] initWithTitle:NSLocalizedString(@"Search Menu", @"Search Menu title")];
     [self searchFieldMenu];
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
-(void)viewDidScroll:(NSNotification*)notification{
    NSInteger scrollOrigin = [[mediaPostsScroll contentView]bounds].origin.y+NSMaxY([mediaPostsScroll visibleRect]);
    //    NSInteger numberRowHeights = [collectionViewListAlbums numberOfItemsInSection:0];
    NSInteger boundsHeight = mediaPostsList.bounds.size.height;
    //    NSInteger frameHeight = playList.frame.size.height;
    if (scrollOrigin == boundsHeight+2 && postID) {
        [self loadMediaPosts:searchField.stringValue];
    }

}
- (IBAction)showMedia:(id)sender {
    
}
-(void)searchFieldDidStartSearching:(NSSearchField *)sender{
    postID = nil;
    [mediaURLS removeAllObjects];
    [postsData removeAllObjects];
    [self loadMediaPosts:searchField.stringValue];
    [self loadProfileInfo:searchField.stringValue];
//    [self loadMediaPostsByTag:searchField.stringValue];
}
-(void)searchFieldDidEndSearching:(NSSearchField *)sender{
    
}
-(void)searchFieldMenu{
    
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
-(void)loadProfileInfo:(NSString*)username{
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
-(void)loadMediaPosts:(NSString*)username{
    [[instaClient.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://instagram.com/%@/media%@", username, postID ? [NSString stringWithFormat:@"?max_id=%@", postID]:@""]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *mediaResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
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
    }]resume];
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [postsData count];
}
-(void)loadMediaPostsByTag:(NSString*)tag{
    NSString *pageHTML = [[NSString alloc]initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.instagram.com/explore/tags/%@", tag]] encoding:NSUTF8StringEncoding error:nil];
//    NSLog(@"%@",pageHTML);
    HTMLDocument *doc=[HTMLDocument documentWithString:pageHTML];
    NSArray *cursorLinkTag = [doc nodesMatchingSelector:@"#react-root"];
    HTMLElement *cursorHref = cursorLinkTag[0];
    NSLog(@"%@",cursorHref);
//    _oidfu

}
-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
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
