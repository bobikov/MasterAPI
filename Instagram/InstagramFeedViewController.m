//
//  InstagramFeedViewController.m
//  MasterAPI
//
//  Created by sim on 01.01.17.
//  Copyright © 2017 sim. All rights reserved.
//

#import "InstagramFeedViewController.h"
#import "MediaPostsCustomCell.h"
@interface InstagramFeedViewController ()<NSTableViewDelegate, NSTableViewDataSource, NSSearchFieldDelegate>

@end

@implementation InstagramFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    instaClient = [[InstagramClient alloc]initWithTokensFromCoreData];
    postsList.delegate=self;
    postsList.dataSource=self;
    postsData = [[NSMutableArray alloc]init];
    mediaURLS = [[NSMutableArray alloc]init];
    [[postsListScroll contentView]setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(viewDidScroll:) name:NSViewBoundsDidChangeNotification object:nil];
    cursor = nil;
    [self loadUserFeed];
}
-(void)viewDidScroll:(NSNotification*)notificaion{
    NSInteger scrollOrigin = [[postsListScroll contentView]bounds].origin.y+NSMaxY([postsListScroll visibleRect]);
    //    NSInteger numberRowHeights = [collectionViewListAlbums numberOfItemsInSection:0];
    NSInteger boundsHeight = postsList.bounds.size.height;
    //    NSInteger frameHeight = playList.frame.size.height;
    if (scrollOrigin == boundsHeight+2 && cursor) {
        [self loadUserFeed];
    }
}
-(void)loadUserFeed{
    NSLog(@"FEEED");
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.instagram.com/?__a=1%@", cursor ? [NSString stringWithFormat:@"&max_id=%@", cursor] : @""]]];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.instagram.com/query/"]];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:@{NSHTTPCookieName:@"sessionid", NSHTTPCookieValue:@"IGSC5d2d4d1feea6e8379d4f283aafb568085a93da1a74842f5528a70c1307229e67%3AiKKRqIvpxcelEFE6aTpoimSvNMjRdvWI%3A%7B%22_token%22%3A%224221647985%3AsSLkqoUVhZOaikE1HeDbyz7S6M42vEwG%3Ab3a97cdda99089f4e655fa8be38d136711acff8b788202ce577cbe4c83fc4f3a%22%2C%22_platform%22%3A4%2C%22_auth_user_id%22%3A4221647985%2C%22_auth_user_hash%22%3A%22%22%2C%22_token_ver%22%3A2%2C%22asns%22%3A%7B%2282.112.55.199%22%3A48642%2C%22time%22%3A1483210817%7D%2C%22last_refreshed%22%3A1483206782.6572375%2C%22_auth_user_backend%22%3A%22accounts.backends.CaseInsensitiveModelBackend%22%7D", NSHTTPCookieDomain:@"www.instagram.com", NSHTTPCookieExpires:@"01/04/2017 12:00 AM", NSHTTPCookiePath:@"/"}];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    [cookieStorage setCookie:cookie];
    [cookieStorage deleteCookie:cookie];
    [request setHTTPShouldHandleCookies:YES];
    
//    [request setHTTPBody:[@"q=ig_user(4221647985)%20%7B%20media.after(0%2C%20$count)%20%7B%0A%20%20count%2C%0A%20%20nodes%20%7B%0A%20%20%20%20caption%2C%0A%20%20%20%20code%2C%0A%20%20%20%20comments%20%7B%0A%20%20%20%20%20%20count%0A%20%20%20%20%7D%2C%0A%20%20%20%20date%2C%0A%20%20%20%20dimensions%20%7B%0A%20%20%20%20%20%20height%2C%0A%20%20%20%20%20%20width%0A%20%20%20%20%7D%2C%0A%20%20%20%20display_src%2C%0A%20%20%20%20id%2C%0A%20%20%20%20is_video%2C%0A%20%20%20%20likes%20%7B%0A%20%20%20%20%20%20count%0A%20%20%20%20%7D%2C%0A%20%20%20%20owner%20%7B%0A%20%20%20%20%20%20id%2C%0A%20%20%20%20%20%20username%2C%0A%20%20%20%20%20%20full_name%2C%0A%20%20%20%20%20%20profile_pic_url%0A%20%20%20%20%7D%2C%0A%20%20%20%20thumbnail_src%2C%0A%20%20%20%20video_views%0A%20%20%7D%2C%0A%20%20page_info%0A%7D%0A%20%7D" dataUsingEncoding:NSUTF8StringEncoding]];
//    [request setHTTPMethod:@"POST"];
    [[instaClient.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data){
            
            NSDictionary *tagSearchResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int hasNextPage = [tagSearchResp[@"feed"][@"media"][@"page_info"][@"has_next_page"] intValue];
            NSLog(@"Has next page %i", hasNextPage);
            NSLog(@"%@", cursor);
            NSLog(@"%@", tagSearchResp);
            cursor = hasNextPage ? tagSearchResp[@"feed"][@"media"][@"page_info"][@"end_cursor"] : nil;
            for(NSDictionary *i in tagSearchResp[@"feed"][@"media"][@"nodes"]){
                //            NSLog(@"%@", i[@"display_src"]);
                [mediaURLS addObject:i[@"display_src"]];
                NSString *caption  = i[@"caption"] && ![i[@"caption"] isEqual:[NSNull null]] &&  ![i[@"caption"] isEqual:nil] && ![i[@"caption"] isEqual:@""]? i[@"caption"]: @"";
                //                NSString *caption  = @"";
                [postsData addObject:@{@"thumb":i[@"display_src"], @"caption":caption, @"date":[self formatDate:i[@"date"]]}];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                totalCountTitle.title = [NSString stringWithFormat:@"%i", [tagSearchResp[@"feed"][@"media"][@"count"] intValue]];
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
