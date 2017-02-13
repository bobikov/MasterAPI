//
//  FullUserInfoPopupViewController.m
//  vkapp
//
//  Created by sim on 02.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "FullUserInfoPopupViewController.h"
#import "ShowVideoViewController.h"
#import "ShowPhotoViewController.h"
#import "FriendsViewController.h"
#import "SubscribersViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface FullUserInfoPopupViewController ()

@end

@implementation FullUserInfoPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _app = [[appInfo alloc]init];
    profilePhoto.wantsLayer=YES;
    profilePhoto.layer.cornerRadius=8;
    profilePhoto.layer.masksToBounds=YES;
    _stringHighlighter = [[StringHighlighter alloc]init];
//    NSLog(@"%@",_receivedData);
    [self loadUserInfo];

    [relation setAllowsEditingTextAttributes: YES];
    [site setAllowsEditingTextAttributes: YES];
    [page setAllowsEditingTextAttributes:YES];
}
-(void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqual:@"ShowUserVideoFromFullInfoSegue"]){
        ShowVideoViewController *contr = (ShowVideoViewController *)segue.destinationController;
        contr.userDataFromFullUserInfo=_receivedData;
        contr.loadFromFullUserInfo=YES;
        contr.ownerId=_receivedData[@"id"];
    }
    else if([segue.identifier isEqual:@"ShowUserPhotoFromFullInfoSegue"]){
        ShowPhotoViewController *contr = (ShowPhotoViewController*)segue.destinationController;
        contr.userDataFromFullUserInfo=_receivedData;
        contr.loadFromFullUserInfo=YES;
        contr.ownerId=_receivedData[@"id"];
    }
    else if([segue.identifier isEqual:@"ShowFriendsFromFullUserInfoSegue"]){
        FriendsViewController *contr = (FriendsViewController *)segue.destinationController;
        contr.userDataFromFullUserInfo=_receivedData;
        contr.loadFromFullUserInfo=YES;
        contr.ownerId=_receivedData[@"id"];
    }
    else if([segue.identifier isEqual:@"ShowUserFollowersFromFullInfoSegue"]){
        
        SubscribersViewController *contr = (SubscribersViewController *)segue.destinationController;
        contr.userDataFromFullUserInfo=_receivedData;
        contr.loadFromFullUserInfo=YES;
        contr.ownerId=_receivedData[@"id"];
    
    }
}
-(void)loadUserInfo {
    NSString *vkURL=![_receivedData[@"relation_partner"] isEqual:@""] ? [NSString stringWithFormat:@"https://vk.com/id%@", _receivedData[@"relation_partner"][@"id"]] : @"";
    NSString *substringForHighlight= ![_receivedData[@"relation_partner"] isEqual:@""] ? [NSString stringWithFormat:@"%@ %@", _receivedData[@"relation_partner"][@"first_name"],_receivedData[@"relation_partner"][@"last_name"]] : @"";
//    NSString *substringForHighlight;
//    NSString *vkURL;
    NSString *fullStringForHighlight;

    [imageProgress startAnimation:self];
    imageProgress.hidden=NO;
    userIdField.stringValue =  [NSString stringWithFormat:@"%@",_receivedData[@"id"]];
    
    if(_receivedData[@"site"]!=nil){
        [site setFont:[NSFont systemFontOfSize:11 weight:NSFontWeightRegular]];
        [_stringHighlighter highlightStringWithURLs:[[_receivedData[@"site"]stringByReplacingOccurrencesOfString:@"(" withString:@" "]stringByReplacingOccurrencesOfString:@")" withString:@" "] Emails:YES fontSize:11 completion:^(NSMutableAttributedString *highlightedString) {
            site.attributedStringValue=highlightedString;
        }];
//        site.attributedStringValue = [_stringHighlighter highlightStringWithURLs:[[_receivedData[@"site"]stringByReplacingOccurrencesOfString:@"(" withString:@" "]stringByReplacingOccurrencesOfString:@")" withString:@" "] Emails:YES fontSize:11];
        
    }else{
        site.stringValue=_receivedData[@"site"];
    }
//   site.stringValue=_receivedData[@"site"];
  
    fullName.stringValue = _receivedData[@"full_name"];
    mobile.stringValue = [NSString stringWithFormat:@"%@", _receivedData[@"mobile"]];
//    about.stringValue = [NSString stringWithFormat:@"%@", _receivedData[@"about"]];
    [about setAllowsEditingTextAttributes:YES];
    [_stringHighlighter highlightStringWithURLs:_receivedData[@"about"] Emails:YES fontSize:11 completion:^(NSMutableAttributedString *highlightedString) {
        about.attributedStringValue=highlightedString;
    }];
    [about setFont:[NSFont systemFontOfSize:11 weight:NSFontWeightRegular]];
    books.stringValue = [NSString stringWithFormat:@"%@", _receivedData[@"books"]];
    Music.stringValue = [NSString stringWithFormat:@"%@", _receivedData[@"music"]];
    education.stringValue = [NSString stringWithFormat:@"%@", _receivedData[@"university_name"]];
    school.stringValue = [NSString stringWithFormat:@"%@", _receivedData[@"schools"]];
    quotes.stringValue = [NSString stringWithFormat:@"%@", _receivedData[@"quotes"]];
    city.stringValue =  _receivedData[@"city"];
    country.stringValue = _receivedData[@"country"];
    age.stringValue = [NSString stringWithFormat:@"%@", _receivedData[@"bdate"]];
    [_stringHighlighter highlightStringWithURLs:[NSString stringWithFormat:@"https://vk.com/%@", _receivedData[@"domain"]] Emails:YES fontSize:11 completion:^(NSMutableAttributedString *highlightedString) {
        page.attributedStringValue=highlightedString;
    }];
    [page setFont:[NSFont systemFontOfSize:11 weight:NSFontWeightRegular]];
    blacklisted.stringValue = [NSString stringWithFormat:@"%@", [_receivedData[@"blacklisted"] intValue]==1 ? @"You banned by this user." : [_receivedData[@"blacklisted_by_me"] intValue]==1 ? @"User banned by you." : @""];
    if([blacklisted.stringValue isEqual:@""]){
        blacklisted.hidden=YES;
    }else{
        blacklisted.hidden=NO;
    }
    if(_receivedData[@"relation"]){
        relation.hidden=NO;
        
        switch ([_receivedData[@"relation"] intValue]){
            case 0:
                relation.stringValue=@"not available";
                break;
            case 1:
                relation.stringValue=@"not maried";
                break;
            case 2:
                relation.stringValue=@"have a friend";
                break;
            case 3:
                if(_receivedData[@"relation_partner"] && ![_receivedData[@"relation_partner"] isEqual:@""]){
                    fullStringForHighlight = [NSString stringWithFormat:@"engaged with %@ %@", _receivedData[@"relation_partner"][@"first_name"],_receivedData[@"relation_partner"][@"last_name"]];
        
                    relation.attributedStringValue = [_stringHighlighter createLinkFromSubstring:fullStringForHighlight URL:vkURL subString:substringForHighlight];
                    [relation setFont:[NSFont systemFontOfSize:11 weight:NSFontWeightLight]];
                }else{
                    relation.stringValue=@"engaged";
                }
                break;
            case 4:
                if(_receivedData[@"relation_partner"] && ![_receivedData[@"relation_partner"] isEqual:@""]){
                    fullStringForHighlight = [NSString stringWithFormat:@"married on %@ %@", _receivedData[@"relation_partner"][@"first_name"],_receivedData[@"relation_partner"][@"last_name"]];
                    relation.attributedStringValue=[_stringHighlighter createLinkFromSubstring:fullStringForHighlight URL:vkURL subString:substringForHighlight];
                    [relation setFont:[NSFont systemFontOfSize:11 weight:NSFontWeightRegular]];
                }else{
                    relation.stringValue=@"married";
                }
                break;
            case 5:
                relation.stringValue=@"all complicated";
                break;
            case 6:
                relation.stringValue=@"in active search";
                break;
            case 7:
                if(_receivedData[@"relation_partner"] && ![_receivedData[@"relation_partner"] isEqual:@""]){

                    fullStringForHighlight = [NSString stringWithFormat:@"in love with %@ %@", _receivedData[@"relation_partner"][@"first_name"],_receivedData[@"relation_partner"][@"last_name"]];
                    
                    [relation setFont:[NSFont systemFontOfSize:11 weight:NSFontWeightRegular]];
                    
                    relation.attributedStringValue = [_stringHighlighter createLinkFromSubstring:fullStringForHighlight URL:vkURL subString:substringForHighlight];
                    
                }else{
                    relation.stringValue=@"in love";
                }
                break;
                
            default:
                relation.stringValue=@"not available";
                break;
        }
    }else{
        relation.hidden=YES;
    }
    if([_receivedData[@"last_seen"] isEqual:@""]){
        lastSeen.hidden=YES;
        lastSeenLabel.hidden=YES;
    }else{
        lastSeenLabel.hidden=NO;
        lastSeen.hidden=NO;
        lastSeen.stringValue=_receivedData[@"last_seen"];
    }
    [_receivedData[@"verified"] intValue]==1 ? [verified setImage:[NSImage imageNamed:@"verified_2.png"]] : nil;
//    NSLog(@"%@", _receivedData);

    [profilePhoto sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _receivedData[@"user_photo_big"]]] completed:^(NSImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        NSImageRep *rep = [[image representations] objectAtIndex:0];
        NSSize imageSize = NSMakeSize((CGFloat)rep.pixelsWide, (CGFloat)rep.pixelsHigh);
        image.size=imageSize;
         NSLog(@"%.0fx%.0f", image.size.width, image.size.height);
        [profilePhoto setImage:image];
        [imageProgress stopAnimation:self];
        imageProgress.hidden=YES;
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/users.get?user_id=%@&fields=counters&access_token=%@&v=%@", _receivedData[@"id"], _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(data){
                NSDictionary *getCountersResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                //        NSLog(@"%@", getFriendsResponse);
                dispatch_async(dispatch_get_main_queue(), ^{
                    friendsCount.stringValue = [NSString stringWithFormat:@"%@", getCountersResponse[@"response"][0][@"counters"][@"friends"]];
                    subscribersCount.stringValue = [NSString stringWithFormat:@"%@", getCountersResponse[@"response"][0][@"counters"][@"followers"]];
                    photosCount.stringValue = [NSString stringWithFormat:@"%@", getCountersResponse[@"response"][0][@"counters"][@"photos"]];
                    videosCount.stringValue = [NSString stringWithFormat:@"%@", getCountersResponse[@"response"][0][@"counters"][@"videos"]];
                    groupsCount.stringValue =  getCountersResponse[@"response"][0][@"counters"][@"groups"] ? [NSString stringWithFormat:@"%@", getCountersResponse[@"response"][0][@"counters"][@"groups"]] : @"not available" ;
                });
            }
        }]resume];
    });
    
}


@end
