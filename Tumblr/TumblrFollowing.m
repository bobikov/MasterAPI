//
//  TumblrFollowing.m
//  MasterAPI
//
//  Created by sim on 09.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "TumblrFollowing.h"
#import "followingCustomCell.h"
@interface TumblrFollowing ()<NSTableViewDelegate, NSTableViewDataSource>

@end

@implementation TumblrFollowing

- (void)viewDidLoad {
    [super viewDidLoad];
    followingList.dataSource=self;
    followingList.delegate=self;
    _tumblrClient = [[TumblrClient alloc] initWithTokensFromCoreData];
    followingData = [[NSMutableArray alloc]init];
    offsetCounter = 0;
    [[followingListScroll contentView]setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(viewDidScroll:) name:NSViewBoundsDidChangeNotification object:nil];
    [self loadFollowing:NO];
 
}
-(void)viewDidScroll:(NSNotification *)notification{
    if([notification.object isEqual:followingListClip]){
        NSInteger scrollOrigin = [[followingListScroll contentView]bounds].origin.y+NSMaxY([followingListScroll visibleRect]);
        //    NSInteger numberRowHeights = [subscribersList numberOfRows] * [subscribersList rowHeight];
        NSInteger boundsHeight = followingList.bounds.size.height;
        //    NSInteger frameHeight = subscribersList.frame.size.height;
        if (scrollOrigin == boundsHeight+2) {
            //Refresh here
            //         NSLog(@"The end of table");
//            if([[_youtubeRWData readSubscriptions] count] == 0 && pageToken!=nil){
                [self loadFollowing:YES];
//            }
        }
        //        NSLog(@"%ld", scrollOrigin);
        //        NSLog(@"%ld", boundsHeight);
        //    NSLog(@"%fld", frameHeight-300);
        //
    }
}
- (IBAction)showPostsByAccount:(id)sender {
    NSView *parentCell = [sender superview];
    NSInteger row = [followingList rowForView:parentCell];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadPostsByAccount" object:nil userInfo:followingData[row]];
}
-(void)loadFollowing:(BOOL)makeOffset{
    [progressLoad startAnimation:self];
    NSDictionary *queryParams;
    if(makeOffset){
        followingOffset=followingOffset+20;
        queryParams =@{@"limit":@20, @"offset":[NSNumber numberWithInt:followingOffset]};
    }else{
        queryParams =@{@"limit":@20};
        [followingData removeAllObjects];
    }
    [_tumblrClient APIRequest:@"user" rmethod:@"following" query:queryParams handler:^(NSData *data){
        if(data){
            NSDictionary *followingResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            //NSLog(@"%@", followingResponse);
            if(!followingResponse[@"errors"]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    totalCount.title = [NSString stringWithFormat:@"%@", followingResponse[@"response"][@"total_blogs"]];
                });
                for(NSDictionary *i in followingResponse[@"response"][@"blogs"]){
                    NSURL *url = [NSURL URLWithString:i[@"url"]];
                    //            NSLog(@"%@", i);
                    NSString *desc = i[@"description"] && i[@"description"]!=nil ? i[@"description"] : @"";
                    
                    [followingData addObject:@{@"title":i[@"title"], @"desc":desc, @"url":url.host, @"updated":[self getUpdatedDate:i[@"updated"]]}];
                    offsetCounter++;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    loadedCount.title = [NSString stringWithFormat:@"%i", offsetCounter];
                    [progressLoad stopAnimation:self];
                    [followingList reloadData];
                });
            }
        }
    }];
}
-(NSString*)getUpdatedDate:(NSString*)dateInSeconds{
    NSDate *gotDate = [NSDate dateWithTimeIntervalSince1970:[dateInSeconds intValue]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"dd.MM.yyyy hh:mm"];
    
    NSString *date = [formatter stringFromDate:gotDate];
    return date;
}
- (IBAction)openTumblrProfileInBrowser:(id)sender {
    
    NSView *parentCell = [sender superview];
    NSInteger row = [followingList rowForView:parentCell];
    NSLog(@"%@", followingData[row][@"url"]);
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@",followingData[row][@"url"]]]];
    
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    
    return [followingData count];
}

-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    followingCustomCell *cell = [[followingCustomCell alloc]init];
 
    cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
    cell.ftitle.stringValue = followingData[row][@"title"];
    NSString *description = [NSString stringWithFormat:@"<html><head><style>h2,h1,h3,p,a{font-size:12;text-decoration:none;color:black}</style></head><body><span style='font-family:Helvetica;font-size:11'>%@</span></body></html>",followingData[row][@"desc"]];
    NSAttributedString *htmlDesc = [[NSAttributedString alloc] initWithData:[description dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}  documentAttributes:nil  error:nil] ;

    cell.desc.attributedStringValue = htmlDesc;
    cell.updated.stringValue = followingData[row][@"updated"];
    cell.avatar.wantsLayer=YES;
    cell.name.stringValue = followingData[row][@"url"];
    cell.avatar.layer.masksToBounds=YES;
    cell.avatar.layer.cornerRadius=64/2;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *avurl = [NSString stringWithFormat:@"https://api.tumblr.com/v2/blog/%@/avatar",followingData[row][@"url"]];
//        NSLog(@"%@", avurl);
        NSImage *image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:avurl]];
        image.size = NSMakeSize(64, 64);
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.avatar setImage:image];
        });
    });
    return cell;
}
@end
