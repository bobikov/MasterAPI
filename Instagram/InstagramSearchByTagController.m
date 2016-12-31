//
//  InstagramSearchByTagController.m
//  MasterAPI
//
//  Created by sim on 16.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "InstagramSearchByTagController.h"
#import "MediaPostsCustomCell.h"
@interface InstagramSearchByTagController ()<NSTableViewDelegate, NSTableViewDataSource, NSSearchFieldDelegate>

@end

@implementation InstagramSearchByTagController

- (void)viewDidLoad {
    [super viewDidLoad];
     instaClient = [[InstagramClient alloc]initWithTokensFromCoreData];
    postsList.delegate=self;
    postsList.dataSource=self;
    postsData = [[NSMutableArray alloc]init];
    mediaURLS = [[NSMutableArray alloc]init];
    searchField.delegate = self;
    [[postsListScroll contentView]setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(viewDidScroll:) name:NSViewBoundsDidChangeNotification object:nil];
    [self searchFieldMenu];

}
-(void)viewDidScroll:(NSNotification*)notificaion{
    NSInteger scrollOrigin = [[postsListScroll contentView]bounds].origin.y+NSMaxY([postsListScroll visibleRect]);
    //    NSInteger numberRowHeights = [collectionViewListAlbums numberOfItemsInSection:0];
    NSInteger boundsHeight = postsList.bounds.size.height;
    //    NSInteger frameHeight = playList.frame.size.height;
    if (scrollOrigin == boundsHeight+2 && endCursor) {
        [self loadMediaPostsByTag:searchField.stringValue];
    }
}
-(void)searchFieldDidStartSearching:(NSSearchField *)sender{
    [postsData removeAllObjects];
    [mediaURLS removeAllObjects];
    endCursor = nil;
    [self loadMediaPostsByTag:searchField.stringValue];
}
-(void)searchFieldDidEndSearching:(NSSearchField *)sender{
  
}
- (IBAction)copyMediaURLs:(id)sender {
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [pasteBoard setString:[[mediaURLS objectsAtIndexes:[postsList selectedRowIndexes]] componentsJoinedByString:@"\n"]   forType:NSStringPboardType];
    
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
-(void)loadMediaPostsByTag:(NSString*)tag{
    
   
    [[instaClient.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.instagram.com/explore/tags/%@/?__a=1%@", tag, endCursor ? [NSString stringWithFormat:@"&max_id=%@", endCursor] : @""]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data){
            
            NSDictionary *tagSearchResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int hasNextPage = [tagSearchResp[@"tag"][@"media"][@"page_info"][@"has_next_page"] intValue];
            NSLog(@"Has next page %i", hasNextPage);
            endCursor = hasNextPage ? tagSearchResp[@"tag"][@"media"][@"page_info"][@"end_cursor"] : nil;
            for(NSDictionary *i in tagSearchResp[@"tag"][@"media"][@"nodes"]){
                //            NSLog(@"%@", i[@"display_src"]);
                [mediaURLS addObject:i[@"display_src"]];
                NSString *caption  = i[@"caption"] && ![i[@"caption"] isEqual:[NSNull null]] &&  ![i[@"caption"] isEqual:nil] && ![i[@"caption"] isEqual:@""]? i[@"caption"]: @"";
//                NSString *caption  = @"";
                [postsData addObject:@{@"thumb":i[@"thumbnail_src"], @"caption":caption, @"date":[self formatDate:i[@"date"]]}];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                totalCountTitle.title = [NSString stringWithFormat:@"%i", [tagSearchResp[@"tag"][@"media"][@"count"] intValue]];
                loadedCountTitle.title = [NSString stringWithFormat:@"%li", [postsData count]];
                [postsList reloadData];
            });
        }
    }]resume];
}
-(NSString *)formatDate:(NSString*)timestamp{
    NSString *date;
    NSDate *gotDate = [[NSDate alloc] initWithTimeIntervalSince1970: [timestamp intValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
    
    date = [dateFormatter stringFromDate:gotDate];
    
    return date;;
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    
    return [postsData count];
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
@end
