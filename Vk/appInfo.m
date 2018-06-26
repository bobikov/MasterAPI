//
//  appInfo.m
//  vkapp
//
//  Created by sim on 20.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "appInfo.h"

@implementation appInfo
@synthesize session,version,token,icon,person,appId;

- (id)init{
    
    self = [super self];
    _keyHandle = [[keyHandler alloc]init];
//    if([_keyHandle readAppInfo:nil]){
        NSDictionary *object = [[_keyHandle readAppInfo:nil]copy];
//        NSLog(@"%@", object);
        person = object[@"id"];
        appId = object[@"appId"];
        token = object[@"token"];
        version = object[@"version"];
//        _selected = [object[@"selected"] boolValue];
        offsetCounter = 0;
        icon = object[@"icon"];
        session=[NSURLSession  sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _captchaHandler = [[VKCaptchaHandler alloc]init];
        usersListData = [[NSMutableArray alloc]init];
        searchResults = [[NSMutableArray alloc]init];
    return self;
//    }
//    return nil;
}
- (void)addToSavedPhotos:(NSDictionary*)params captcha_sid:(NSString *)captcha_sid captcha_key:(NSString *)captcha_key captcha:(BOOL)captcha comletionHandler:(nonnull void (^)(NSDictionary * _Nonnull))completion{
        NSString *url;
        if(captcha){
            url = [NSString stringWithFormat:@"https://api.vk.com/method/photos.copy?owner_id=%@&photo_id=%@&access_token=%@&v=%@&captcha_sid=%@&captcha_key=%@", params[@"owner_id"],params[@"photo_id"], token, version, captcha_sid, captcha_key];
        }
        else{
            url = [NSString stringWithFormat:@"https://api.vk.com/method/photos.copy?owner_id=%@&photo_id=%@&access_token=%@&v=%@", params[@"owner_id"],params[@"photo_id"], token, version];
        }
        [[session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary *addToSavedPhotoResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            NSLog(@"%@", addToSavedPhotoResponse);
            completion(addToSavedPhotoResponse);
        }]resume];
}

- (void)getUsersInfo:(nonnull id)ids filters:(nullable id)filters  :(OnGetUsersInfoComplete)completion {
    
    
    [[session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/users.get?user_ids=%@&fields=city,domain,photo_50,photo_100,photo_200_orig,photo_200,status,last_seen,bdate,online,country,sex,about,books,contacts,site,music,schools,education,quotes,blacklisted,verified,blacklisted_by_me,relation&v=%@&access_token=%@", [ids componentsJoinedByString:@","], version, token]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *userGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        

        if(userGetResponse[@"error"]){
            NSLog(@"%@:%@", userGetResponse[@"error"][@"error_code"], userGetResponse[@"error_msg"]);
        }
        else{
            
            for(NSDictionary *a in userGetResponse[@"response"]){
                
                NSMutableDictionary *object = [self unpackUsersInfo:a];
                
               
                if(filters == nil){
                    
                    [usersListData addObject:object];
                }
                else{
//
                    if([filters[@"online"] intValue]==1 && [filters[@"offline"] intValue] ==1 && [filters[@"active"] intValue] == 1){
                      
                        if (!a[@"deactivated"]){
                           
                            if([filters[@"women"] intValue]==1 && [filters[@"men"] intValue]==1){
                                if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] == 2 || ![a[@"sex"] intValue]){
                                    if(filters[@"blacklist"]){
                                        if([filters[@"blacklist"] intValue]==1){
                                            if(blacklisted){
                                                NSLog(@"BLACKLISTED");
                                                offsetCounter++;
                                                [usersListData addObject:object];
                                            }
                                        }else{
                                            if(!blacklisted){
                                                offsetCounter++;
                                                [usersListData addObject:object];
                                            }
                                        }
                                    }else{
                                        if(blacklisted || !blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }
                                }
                            }
                            else if([filters[@"women"] intValue]==1 && [filters[@"men"] intValue]==0){
                                if([a[@"sex"] intValue]==1){
                                    if(filters[@"blacklist"]  && [filters[@"blacklist"] intValue]==1){
                                        if(blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }else{
                                        if(!blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }
                                }
                            }
                            else if([filters[@"women"] intValue]==0 && [filters[@"men"] intValue]==1){
                                if([a[@"sex"] intValue]==2){
                                    if(filters[@"blacklist"]  && [filters[@"blacklist"] intValue]==1){
                                        if(blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }else{
                                        if(!blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }
                                }
                                
                            }
                            else if([filters[@"women"] intValue]==0 && [filters[@"men"] intValue]==0){
                                if([a[@"sex"] intValue]==0){
                                    if(filters[@"blacklist"]  && [filters[@"blacklist"] intValue]==1){
                                        if(blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }else{
                                        if(!blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else if([filters[@"online"] intValue]==0 && [filters[@"offline"] intValue] ==1 && [filters[@"active"] intValue] == 1 ) {
                        
                        
                        if (![online  isEqual: @"1"]){
                            if([filters[@"women"] intValue]==1 && [filters[@"men"] intValue]==1 ){
                                if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] == 2 || ![a[@"sex"] intValue]){
                                    if(filters[@"blacklist"]  && [filters[@"blacklist"] intValue]==1){
                                        if(blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }else{
                                        if(!blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }                                }
                            }
                            else if([filters[@"women"] intValue]==1 && [filters[@"men"] intValue]==0){
                                if([a[@"sex"] intValue]==1){
                                    if(filters[@"blacklist"]  && [filters[@"blacklist"] intValue]==1){
                                        if(blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }else{
                                        if(!blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }
                                }
                            }
                            else if([filters[@"women"] intValue]==0 && [filters[@"men"] intValue]==1){
                                if([a[@"sex"] intValue]==2){
                                    if(filters[@"blacklist"]  && [filters[@"blacklist"] intValue]==1){
                                        if(blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }else{
                                        if(!blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }
                                }
                                
                            }
                            else if([filters[@"women"] intValue]==0 && [filters[@"men"] intValue]==0){
                                if([a[@"sex"] intValue]==0){
                                    if(filters[@"blacklist"]  && [filters[@"blacklist"] intValue]==1){
                                        if(blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }else{
                                        if(!blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                    else if([filters[@"online"] intValue]==1 && [filters[@"offline"] intValue] ==0 && [filters[@"active"] intValue] == 1) {
                        
                        if ([online  isEqual: @"1"]){
                            if([filters[@"women"] intValue]==1 && [filters[@"men"] intValue]==1){
                                if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] == 2 || ![a[@"sex"] intValue]){
                                    if(filters[@"blacklist"]  && [filters[@"blacklist"] intValue]==1){
                                        if(blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }else{
                                        if(!blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }
                                }
                            }
                            else if([filters[@"women"] intValue]==1 && [filters[@"men"] intValue]==0){
                                if([a[@"sex"] intValue]==1){
                                    if(filters[@"blacklist"]  && [filters[@"blacklist"] intValue]==1){
                                        if(blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }else{
                                        if(!blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }
                                }
                            }
                            else if([filters[@"women"] intValue]==0 && [filters[@"men"] intValue]==1){
                                if([a[@"sex"] intValue]==2){
                                    if(filters[@"blacklist"]  && [filters[@"blacklist"] intValue]==1){
                                        if(blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }else{
                                        if(!blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }
                                }
                                
                            }
                            else if([filters[@"women"] intValue]==0 && [filters[@"men"] intValue]==0){
                                if([a[@"sex"] intValue]==0){
                                    if(filters[@"blacklist"]  && [filters[@"blacklist"] intValue]==1){
                                        if(blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }else{
                                        if(!blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                    else if([filters[@"online"] intValue]==0 && [filters[@"offline"] intValue] == 1 && [filters[@"active"] intValue] == 0) {
                        
                        if (a[@"deactivated"]){
                            if([filters[@"women"] intValue]==1 && [filters[@"men"] intValue]==1){
                                if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] == 2 || ![a[@"sex"] intValue]){
                                    if(filters[@"blacklist"]  && [filters[@"blacklist"] intValue]==1){
                                        if(blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }else{
                                        if(!blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }
                                }
                            }
                            else if([filters[@"women"] intValue]==1 && [filters[@"men"] intValue]==0){
                                if([a[@"sex"] intValue]==1){
                                    if(filters[@"blacklist"]  && [filters[@"blacklist"] intValue]==1){
                                        if(blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }else{
                                        if(!blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }
                                }
                            }
                            else if([filters[@"women"] intValue]==0 && [filters[@"men"] intValue]==1){
                                if([a[@"sex"] intValue]==2){
                                    if(filters[@"blacklist"]  && [filters[@"blacklist"] intValue]==1){
                                        if(blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }else{
                                        if(!blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }
                                }
                                
                            }
                            else if([filters[@"women"] intValue]==0 && [filters[@"men"] intValue]==0){
                                if([a[@"sex"] intValue]==0){
                                    if(filters[@"blacklist"]  && [filters[@"blacklist"] intValue]==1){
                                        if(blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }else{
                                        if(!blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }
                                }
                                
                            }
                            
                        }
                    }
                    else if([filters[@"online"] intValue]==1 && [filters[@"offline"] intValue] == 1 && [filters[@"active"] intValue] == 0) {
                        
                        if (a[@"deactivated"] && ([online intValue]==1 || [online intValue]==0)){
                            if([filters[@"women"] intValue]==1 && [filters[@"men"] intValue]==1 ){
                                if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] == 2 || ![a[@"sex"] intValue]){
                                    if(filters[@"blacklist"]  && [filters[@"blacklist"] intValue]==1){
                                        if(blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }else{
                                        if(!blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }
                                }
                            }
                            else if([filters[@"women"] intValue]==1 && [filters[@"men"] intValue]==0){
                                if([a[@"sex"] intValue]==1){
                                    if(filters[@"blacklist"]  && [filters[@"blacklist"] intValue]==1){
                                        if(blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }else{
                                        if(!blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }
                                }
                            }
                            else if([filters[@"women"] intValue]==0 && [filters[@"men"] intValue]==1){
                                if([a[@"sex"] intValue]==2){
                                    if(filters[@"blacklist"]  && [filters[@"blacklist"] intValue]==1){
                                        if(blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }else{
                                        if(!blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }
                                }
                                
                            }
                            else if([filters[@"women"] intValue]==0 && [filters[@"men"] intValue]==0){
                                if([a[@"sex"] intValue]==0){
                                    if(filters[@"blacklist"]  && [filters[@"blacklist"] intValue]==1){
                                        if(blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }else{
                                        if(!blacklisted){
                                            offsetCounter++;
                                            [usersListData addObject:object];
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        completion(usersListData);
    }]resume];
}
- (void)getLikedPhotoUsersIDs:(nonnull id)data :(OnLikedListComplete)completion {
    [[session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/likes.getList?owner_id=%@&type=photo&item_id=%@&count=1000&access_token=%@&v=%@", data[@"owner"], data[@"id"], token, version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
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
- (void)getLikedPhotoUsersInfo:(id)likedUsersIDs :(OnLikedUsersFullObjectsComplete)completion{
    [self getLikedPhotoUsersIDs:likedUsersIDs :^(NSMutableArray *users) {
        if([users count]){
//            NSLog(@"%@", users);
            [self getUsersInfo:users filters:nil :^(NSMutableArray * _Nonnull usersFullObjectsInfo) {
                completion(usersFullObjectsInfo);
            }];
        }
    }];
}
- (void)getBannedUsersIDs:(NSInteger)offsetBannedUsersIDs :(OnGetBannedUsersIDsComplete)completion{
    __block void (^getBannedUsersBlock)();
    getBannedUsersBlock = ^void(){
        [[session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/account.getBanned?count=200&offset=%lu&v=%@&access_token=%@", offsetBannedUsersIDs, version, token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(data){
                NSDictionary *getBannedResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if(getBannedResponse[@"error"]){
                    NSLog(@"%@:%@", getBannedResponse[@"error"][@"error_code"], getBannedResponse[@"error"][@"error_msg"]);
                    
                    dispatch_after(10, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        //                        if (!loading)
                        NSLog(@"Trying send get banned users info request  again.");
                        getBannedUsersBlock(offsetBannedUsersIDs);
                    });
                }else{
                    totalCountBanned = [getBannedResponse[@"response"][@"count"] intValue];
                    NSLog(@"TOTAL BANNED %li",totalCountBanned);
                    
                    NSMutableArray *userIDs = [[NSMutableArray alloc]init];
                    for(NSDictionary *i in getBannedResponse[@"response"][@"items"]){
                        [userIDs addObject:i[@"id"]];
                        
                    }
                    completion(userIDs);
                }
            }
        }]resume];
    };
    getBannedUsersBlock(offsetBannedUsersIDs);
}
- (void)getBannedUsersInfo:(nullable id)filters :(BOOL)offset :(OnGetBannedUsersInfoComplete)completion {
    if(offset){
        offsetLoadBanlist=offsetLoadBanlist+200;
    }else{
        [usersListData removeAllObjects];

        offsetLoadBanlist=0;
        offsetCounter=0;
    }
    [self getBannedUsersIDs:offsetLoadBanlist :^(NSMutableArray * _Nonnull bannedUsers) {
        [self getUsersInfo:bannedUsers filters:filters :^(NSMutableArray * _Nonnull usersFullObjectsInfo) {
            completion(usersFullObjectsInfo, offsetCounter, totalCountBanned, [usersListData count], offsetLoadBanlist);
        }];
    
    }];
}
- (void)getFavoriteUsersIDs:(NSInteger)offsetFavoriteUsersIDs :(OnGetFavoriteUsersIDsComplete)completion{
    __block void (^getFavesUsersBlock)();
    getFavesUsersBlock = ^void(){
        [[session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/fave.getUsers?count=50&offset=%li&v=%@&access_token=%@", offsetLoadFaveUsers, version, token]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(data){
                NSDictionary *getFavesUsersResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if(getFavesUsersResponse[@"error"]){
                    NSLog(@"%@:%@", getFavesUsersResponse[@"error"][@"error_code"], getFavesUsersResponse[@"error"][@"error_msg"]);
                    NSLog(@"Trying send get faves users info request  again.");
                    dispatch_after(3, dispatch_get_main_queue(), ^{
                        
                        getFavesUsersBlock();
                        
                    });
                    
                }else{
                    totalFavesUsersCount = [getFavesUsersResponse[@"response"][@"count"] intValue];
                    usersIDs = [[NSMutableArray alloc]init];
                 
                    for(NSDictionary *i in getFavesUsersResponse[@"response"][@"items"]){
                        [usersIDs addObject:i[@"id"]];
                    }
                    
                    completion(usersIDs);
                }
            }
        }]resume];
    };
    getFavesUsersBlock();

}
- (void)getFavoriteUsersInfo:(id)filters :(BOOL)offset data:(nullable id)data :(nonnull OnGetFavoriteUsersInfoComplete)completion{
    if(offset){
        offsetLoadFaveUsers=offsetLoadFaveUsers+50;
    }else{
        //            [favesUsersList scrollToBeginningOfDocument:self];
        [usersListData removeAllObjects];
        //            [favesUsersList reloadData];
        offsetLoadFaveUsers=0;
        offsetCounter=0;
    }
    if(data == nil){
        [self getFavoriteUsersIDs:offsetLoadFaveUsers :^(NSMutableArray * _Nonnull favesUsersIDs) {
            if(favesUsersIDs){
                //            NSLog(@"%@", favesUsersIDs);
                [self getUsersInfo:favesUsersIDs filters:filters :^(NSMutableArray * _Nonnull usersFullObjectsInfo) {
                    completion(usersFullObjectsInfo, offsetCounter, totalFavesUsersCount, offsetLoadFaveUsers, [usersListData count]);
                }];
            }
        }];
    }else{
        totalFavesUsersCount = [data count];
        [self getUsersInfo:data filters:filters :^(NSMutableArray * _Nonnull usersFullObjectsInfo) {
            completion(usersFullObjectsInfo, offsetCounter, totalFavesUsersCount, offsetLoadFaveUsers, [usersListData count]);
        }];
    }
}
- (void)searchPeople:(nullable id)searchById queryString:(nullable id)queryString offset:(BOOL)offset :(void (^)(NSMutableArray * _Nonnull))completion{
    if(searchById == nil){
        if(offset){
            searchOffsetCounter = searchOffsetCounter + 100;
        }else{
            searchOffsetCounter = 0;
            [searchResults removeAllObjects];
        
        }
        [[session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/users.search?q=%@&sort=0&count=100&offset=%li&fields=city,domain,photo_100,photo_200_orig,photo_200,status,last_seen,bdate,online,country,sex,about,books,contacts,site,music,schools,education,quotes,blacklisted,blacklisted_by_me,relation,counters,verified&v=%@&access_token=%@", queryString, searchOffsetCounter, version, token]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if(data){
                    NSDictionary *searchPeopleResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                    NSLog(@"%@", searchPeopleResp);
                    if(searchPeopleResp[@"error"]){
                        NSLog(@"%@:%@", searchPeopleResp[@"error"][@"error_code"], searchPeopleResp[@"error"][@"error_msg"]);
                    }else{
                        for(NSDictionary *a in searchPeopleResp[@"response"][@"items"]){
                            NSMutableDictionary *object = [self unpackUsersInfo:a];
                            [searchResults addObject:object];
                        }
                        completion(searchResults);
                    }
                }
            }
        ]resume];
        
    }else{
        [self getUsersInfo:searchById filters:nil :^(NSMutableArray * _Nonnull usersFullObjectsInfo) {
            completion(usersFullObjectsInfo);
            
        }];
    }
    
}
- (void)searchGroups:(BOOL)offset queryString:(id)queryString :(void (^)(NSMutableArray * _Nonnull))completion{
    if(offset){
        searchOffsetCounter = searchOffsetCounter + 100;
    }else{
        searchOffsetCounter = 0;
        [searchResults removeAllObjects];

    }
    [[session dataTaskWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"https://api.vk.com/method/groups.search?q=%@&sort=0&count=100&offset=%li&v=%@&access_token=%@", queryString, searchOffsetCounter, version, token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data){
             NSDictionary *searchResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if(searchResponse[@"error"]){
                NSLog(@"%@:%@", searchResponse[@"error"][@"error_code"], searchResponse[@"error"][@"error_msg"]);
            }else{
                
                for (NSDictionary *i in searchResponse[@"response"][@"items"]){
                    NSMutableDictionary *object = [self unpackGroupInfo:i];
                    [searchResults addObject:object];
                }
                completion(searchResults);
            }
        }
    }]resume];
}
- (void)getGroupById:(id)groupId :(void (^)(NSDictionary * _Nonnull))completion{
    [[session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.getById?group_id=%@&fields=description,city,country,members_count,status,site,start_date,finish_date,ban_info&access_token=%@&v=%@", groupId, token, version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(data){
                NSDictionary *groupByIdInfoResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                completion([self unpackFullGroupInfo:groupByIdInfoResp[@"response"][0]]);
            }
        }
    ]resume];
}


- (NSMutableDictionary*)unpackUsersInfo:(NSDictionary *)a{
        firstName = a[@"first_name"];
        lastName=a[@"last_name"];
        fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        city = a[@"city"] && a[@"city"][@"title"]!=nil ? a[@"city"][@"title"] : @"";
        status = a[@"status"] && a[@"status"]!=nil ? a[@"status"] : @"";
        blacklisted = a[@"blacklisted"] && a[@"blacklisted"]!=nil ?  [a[@"blacklisted"] intValue] : 0;
        blacklisted_by_me = a[@"blacklisted_by_me"] && a[@"blacklisted_by_me"]!=nil ?  [a[@"blacklisted_by_me"] intValue] : 0;
        domain = a[@"domain"] && a[@"domain"]!=nil ? a[@"domain"] : @"";
        if(a[@"bdate"] && a[@"bdate"] && a[@"bdate"]!=nil){
            bdate=a[@"bdate"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            NSString *templateLateTime2= @"yyyy";
            NSString *templateLateTime1= @"d.M.yyyy";
            //NSString *todayTemplate =@"d",
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
        verified = a[@"verified"] && a[@"verified"]!=nil ? a[@"verified"] : @"";
        
        NSMutableDictionary *object = [NSMutableDictionary dictionaryWithDictionary:@{@"id":a[@"id"], @"full_name":fullName, @"city":city, @"status":status, @"user_photo":photo, @"bdate":bdate,@"country":countryName,  @"online":online, @"user_photo_big":photoBig,  @"last_seen":last_seen, @"timestamp":a[@"last_seen"][@"time"] && a[@"last_seen"][@"time"]!=nil?a[@"last_seen"][@"time"]:@"", @"books":books, @"site":site, @"about":about, @"mobile":mobilePhone, @"music":music, @"schools":schools, @"university_name":education, @"quotes":quotes, @"deactivated":deactivated,@"blacklisted":[NSNumber numberWithInt:blacklisted],@"blacklisted_by_me":[NSNumber numberWithInt:blacklisted_by_me], @"sex":sex, @"relation":relation, @"domain":domain,@"verified":verified}];
    
    return object;
}
- (NSMutableDictionary*)unpackGroupInfo:(NSDictionary*)i{
    online= i[@"online"];
    desc = i[@"description"] && i[@"description"] != nil ? i[@"description"] : @"";
    photo = i[@"photo_200"] ? i[@"photo_200"] : i[@"photo_100"] ?  i[@"photo_100"] : i[@"photo_50"];
    deactivated = i[@"deactivated"] ? i[@"deactivated"] : @"";
    membersCount = i[@"members_count"] && i[@"members_count"] != nil ? i[@"members_count"] : @0;
    status = i[@"status"] && i[@"status"]  != nil ? i[@"status"] : @"";
    startDate = i[@"start_date"] && i[@"start_date"]!=nil ? i[@"start_date"] : @0;
    finishDate = i[@"finish_date"] && i[@"finish_date"]!=nil ? i[@"finish_date"]  : @0;
    isClosed =  [i[@"is_closed"] intValue] == 0 ? @NO : @YES;
    isAdmin =  [i[@"is_admin"] intValue]==0 ? @NO : @YES;
    isMember =  [i[@"is_member"] intValue]==0 ? @NO : @YES;
    site = i[@"site"] && i[@"site"] != nil ? i[@"site"] : @"";
    country = i[@"country"] && i[@"country"][@"title"] != nil ? i[@"country"][@"title"] : @"";
    type = i[@"type"] && i[@"type"] != nil ? i[@"type"] : @"";
    screenName = i[@"screen_name"] && i[@"screen_name"] != nil ? i[@"screen_name"] : @"";
    city = i[@"city"] && i[@"city"][@"title"]!=nil ? i[@"city"][@"title"] : @"";
    
    NSMutableDictionary *object = [NSMutableDictionary dictionaryWithDictionary:@{@"name":i[@"name"], @"id":[NSString stringWithFormat:@"%@",i[@"id"]], @"deactivated":deactivated, @"desc":desc, @"photo":photo, @"members_count":membersCount, @"status":status, @"site":site, @"start_date":startDate, @"country":country, @"city":city, @"type":type, @"screen_name":screenName, @"is_member":isMember, @"finish_date":finishDate}];
    
    return object;
}
- (NSMutableDictionary*)unpackFullGroupInfo:(NSDictionary*)i{
    
        desc = i[@"description"] && i[@"description"] != nil ? i[@"description"] : @"";
        photo = i[@"photo_200"] ? i[@"photo_200"] : i[@"photo_100"] ?  i[@"photo_100"] : i[@"photo_50"];
        deactivated = i[@"deactivated"] ? i[@"deactivated"] : @"";
        membersCount = i[@"members_count"] && i[@"members_count"] != nil ? i[@"members_count"] : @0;
        status = i[@"status"] && i[@"status"]  != nil ? i[@"status"] : @"";
        startDate = i[@"start_date"] && i[@"start_date"]!=nil ? i[@"start_date"] : @0;
        finishDate = i[@"finish_date"] && i[@"finish_date"]!=nil ? i[@"finish_date"]  : @0;
        isClosed =  [i[@"is_closed"] intValue] == 0 ? @NO : @YES;
        isAdmin =  [i[@"is_admin"] intValue]==0 ? @NO : @YES;
        isMember =  [i[@"is_member"] intValue]==0 ? @NO : @YES;
        site = i[@"site"] && i[@"site"] != nil ? i[@"site"] : @"";
        country = i[@"country"] && i[@"country"][@"title"] != nil ? i[@"country"][@"title"] : @"";
        type = i[@"type"] && i[@"type"] != nil ? i[@"type"] : @"";
        screenName = i[@"screen_name"] && i[@"screen_name"] != nil ? i[@"screen_name"] : @"";
        banInfo = i[@"ban_info"] && i[@"ban_info"]!=nil ? i[@"ban_info"] : @"";
        city = i[@"city"] && i[@"city"][@"title"]!=nil ? i[@"city"][@"title"] : @"";
        
        
       NSMutableDictionary *object = [NSMutableDictionary dictionaryWithDictionary:@{@"name":i[@"name"], @"id":[NSString stringWithFormat:@"%@",i[@"id"]], @"deactivated":deactivated, @"desc":desc, @"photo":photo, @"members_count":membersCount, @"status":status, @"site":site, @"start_date":startDate, @"country":country, @"city":city, @"type":type, @"screen_name":screenName, @"is_member":isMember, @"finish_date":finishDate, @"ban_info":banInfo}];
        
    return object;

}




@end
