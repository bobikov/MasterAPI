//
//  VKLikesViewController.m
//  MasterAPI
//
//  Created by sim on 14/07/17.
//  Copyright © 2017 sim. All rights reserved.
//

#import "VKLikesViewController.h"
#import "VKLikesCellTableView.h"
#import <UIImageView+WebCache.h>
@interface VKLikesViewController ()<NSTableViewDelegate,NSTableViewDataSource>

@end

@implementation VKLikesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    app = [[appInfo alloc]init];
    likedUsersList.delegate=self;
    likedUsersList.dataSource=self;
    usersListData = [[NSMutableArray alloc]init];
    dismiss.font=[NSFont fontWithName:@"Pe-icon-7-stroke" size:30];
    dismiss.title=@"\U0000E680";
    NSLog(@"%@", _receivedData);
    [self loadLikedUsers];
    
}
-(void)loadLikedUsers{
    [self getUsersInfo:^(NSMutableArray *completion) {
        
    }];
}
-(void)getUsersInfo:(OnGetUsersInfoComplete)completion{
        [self getLikedUsers:^(NSMutableArray *completion) {
            if([completion count]){
                NSLog(@"%@", completion);
                [[app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/users.get?user_ids=%@&fields=city,domain,photo_50,photo_100,photo_200_orig,photo_200,status,last_seen,bdate,online,country,sex,about,books,contacts,site,music,schools,education,quotes,blacklisted,blacklisted_by_me,relation&v=%@&access_token=%@", [completion componentsJoinedByString:@","], app.version, app.token]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    NSDictionary *userGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    for(NSDictionary *a in userGetResponse[@"response"]){
                        firstName = a[@"first_name"];
                        lastName=a[@"last_name"];
                        fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                        city = a[@"city"] && a[@"city"][@"title"]!=nil ? a[@"city"][@"title"] : @"";
                        status = a[@"status"] && a[@"status"]!=nil ? a[@"status"] : @"";
                        blacklisted = a[@"blacklisted"] && a[@"blacklisted"]!=nil?  [a[@"blacklisted"] intValue] : 0;
                        blacklisted_by_me = a[@"blacklisted_by_me"] && a[@"blacklisted_by_me"]!=nil ?  [a[@"blacklisted_by_me"] intValue] : 0;
                        domain = a[@"domain"] && a[@"domain"]!=nil ? a[@"domain"] : @"";
                        if(a[@"bdate"] && a[@"bdate"] && a[@"bdate"]!=nil){
                            bdate=a[@"bdate"];
                            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                            NSString *templateLateTime2= @"yyyy";
                            NSString *templateLateTime1= @"d.M.yyyy";
                            //                            NSString *todayTemplate =@"d",
                            [formatter setLocale:[[NSLocale alloc ] initWithLocaleIdentifier:@"ru"]];
                            [formatter setDateFormat:templateLateTime1];
                            NSDate *date = [formatter dateFromString:bdate];
                            [formatter setDateFormat:templateLateTime2];
                            if(![bdate isEqual:@""]){
                                bdate = [NSString stringWithFormat:@"%d лет", 2016 - [[formatter stringFromDate:date] intValue]];
                            }
                            if([bdate isEqual:@"2016 лет" ]){
                                bdate=@"";
                            }
                        }
                        else{
                            bdate=@"";
                        }
                        online = [NSString stringWithFormat:@"%@", a[@"online"]];
                        if(a[@"last_seen"] && a[@"last_seen"]!=nil){
                            double timestamp = [a[@"last_seen"][@"time"] intValue];
                            NSDate *gotDate = [[NSDate alloc] initWithTimeIntervalSince1970: timestamp];
                            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                            NSString *templateLateTime= @"dd.MM.yy HH:mm";
                            //                            NSString *todayTemplate =@"d",
                            [formatter setLocale:[[NSLocale alloc ] initWithLocaleIdentifier:@"ru"]];
                            [formatter setDateFormat:templateLateTime];
                            last_seen = [NSString stringWithFormat:@"%@", [formatter stringFromDate:gotDate]];
                            
                        }
                        else{
                            last_seen = @"";
                        }
                        if([online intValue] == 1){
                            last_seen=@"";
                        }
                        countryName = a[@"country"] && a[@"country"]!=nil ? a[@"country"][@"title"] : @"";
                        site = a[@"site"] && a[@"site"]!=nil ? a[@"site"] :  @"";
                        photoBig = a[@"photo_200"] ? a[@"photo_200"] : a[@"photo_200_orig"] ? a[@"photo_200_orig"] : a[@"photo_100"];
                        photo = a[@"photo_100"];
                        mobilePhone = a[@"mobile_phone"] && a[@"mobile_phone"]!=nil ? a[@"mobile_phone"] : @"";
                        sex = a[@"sex"] && [a[@"sex"] intValue]==1 ? @"W" :[a[@"sex"] intValue]==2 ?  @"M" : [a[@"sex"] intValue]==0 ? @"n/a" : @"";
                        books = a[@"books"] && a[@"books"]!=nil ? a[@"books"] : @"";
                        about = a[@"about"] && a[@"about"]!=nil ? a[@"about"] : @"";
                        music = a[@"music"] && a[@"music"]!=nil ? a[@"music"] : @"";
                        education = a[@"university_name"] && a[@"university_name"]!=nil ? a[@"university_name"] : @"";
                        schools = a[@"schools"] && a[@"schools"]!=nil &&  [a[@"schools"] count] > 0  ? a[@"schools"][0][@"name"] : @"";
                        quotes = a[@"quotes"] && a[@"quotes"]!=nil ? a[@"quotes"] : @"";
                        relation = a[@"relation"] && a[@"relation"]!=nil ? a[@"relation"] : @"";
                        deactivated = a[@"deactivated"] ? a[@"deactivated"] : @"";
                         NSDictionary *object = @{@"id":a[@"id"], @"full_name":fullName, @"city":city, @"status":status, @"user_photo":photo, @"bdate":bdate,@"country":countryName,  @"online":online, @"user_photo_big":photoBig,  @"last_seen":last_seen, @"timestamp":a[@"last_seen"][@"time"] && a[@"last_seen"][@"time"]!=nil?a[@"last_seen"][@"time"]:@"", @"books":books, @"site":site, @"about":about, @"mobile":mobilePhone, @"music":music, @"schools":schools, @"university_name":education, @"quotes":quotes, @"deactivated":deactivated,@"blacklisted":[NSNumber numberWithInt:blacklisted],@"blacklisted_by_me":[NSNumber numberWithInt:blacklisted_by_me], @"sex":sex, @"relation":relation, @"domain":domain};
                        [usersListData addObject:object];
                    }
                    dispatch_async(dispatch_get_main_queue(),^{
                        [likedUsersList reloadData];
                    });
                }]resume];
            }
        }];
}
-(void)getLikedUsers:(OnLikedListComplete)completion{
    [[app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/likes.getList?owner_id=%@&type=photo&item_id=%@&access_token=%@&v=%@", _receivedData[@"owner"], _receivedData[@"id"], app.token, app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data){
            NSDictionary *getLikedUsersResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if(getLikedUsersResp[@"error"]){
                NSLog(@"%@:%@", getLikedUsersResp[@"error"][@"error_code"], getLikedUsersResp[@"error"][@"error_msg"]);
            }
            else{
                usersIDs = [[NSMutableArray alloc]initWithArray:getLikedUsersResp[@"response"][@"items"]];
                completion(usersIDs);
            }
        }
    }]resume];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if([usersListData count]){
        return [usersListData count];
    }
    return 0;
}
-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    VKLikesCellTableView *cell = (VKLikesCellTableView*)[tableView makeViewWithIdentifier:@"MainCell" owner:self];
    [cell.photo sd_setImageWithURL:[NSURL URLWithString:usersListData[row][@"user_photo"]] placeholderImage:nil options:SDWebImageRefreshCached completed:^(NSImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        cell.photo.image = image;
    }];
    cell.photo.wantsLayer=YES;
    cell.photo.layer.masksToBounds=YES;
    cell.photo.layer.cornerRadius=50/2;
    cell.fullName.stringValue = usersListData[row][@"full_name"];
    
    
    return cell;
}
@end
