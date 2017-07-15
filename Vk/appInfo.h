//
//  appInfo.h
//  vkapp
//
//  Created by sim on 20.04.16.
//  Copyright © 2016 sim. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "keyHandler.h"
#import <CoreData/CoreData.h>
#import <Cocoa/Cocoa.h>
#import "VKAPIClient.h"

NS_ASSUME_NONNULL_BEGIN
@interface appInfo : NSObject{
    
    NSMutableArray
        *usersListData,
        *usersIDs;
    
    NSString
        *city,
        *status,
        *bdate,
        *online,
        *firstName,
        *lastName,
        *fullName,
        *countryName,
        *last_seen,
        *sex,
        *books,
        *site,
        *mobilePhone,
        *phone,
        *photoBig,
        *photo,
        *about,
        *music,
        *schools,
        *education,
        *quotes,
        *deactivated,
        *relation,
        *domain,
        *verified;
    
    int
        blacklisted,
        blacklisted_by_me;
    
    NSInteger
        offsetLoadBanlist,
        offsetCounter,
        totalCountBanned,
        offsetLoadFaveUsers,
        totalFavesUsersCount;
    
}
@property (nonatomic, readwrite) NSString *person;
@property (nonatomic, readwrite) NSString *token;
@property (nonatomic, readwrite) NSString *version;
@property (nonatomic, readwrite) NSString *icon;
@property (nonatomic, readwrite) NSURLSession *session;
@property (nonatomic, readwrite) BOOL selected;
@property (nonatomic, readwrite) NSString *appId;
@property(nonatomic) VKAPIClient *client;
@property (nonatomic) keyHandler *keyHandle;


typedef void(^OnGetUsersInfoComplete)(NSMutableArray *usersFullObjectsInfo);
typedef void(^OnLikedListComplete)(NSMutableArray *users);
typedef void(^OnLikedUsersFullObjectsComplete)(NSMutableArray *fullObjectLikedPhotoUsers);
typedef void(^OnGetBannedUsersIDsComplete)(NSMutableArray *bannedUsers);
typedef void(^OnGetBannedUsersInfoComplete)(NSMutableArray *bannedUsersInfo, NSInteger offsetCounterResult, NSInteger totalBannedResult, NSInteger bannedUsersListCount, NSInteger offsetBanlistLoadResult);

typedef void(^OnGetFavoriteUsersIDsComplete)(NSMutableArray *favesUsersIDs);
typedef void(^OnGetFavoriteUsersInfoComplete)(NSMutableArray *favesUsersObjectsInfo, NSInteger offsetCounterResult, NSInteger totalFavesUsersResult, NSInteger offsefFavesUsersLoadResult, NSInteger favesUsersListCount);

-(void)getLikedPhotoUsersIDs:(nonnull id)data :(OnLikedListComplete)completion ;
-(void)getUsersInfo:(nonnull id)ids :(nullable id)filters :(OnGetUsersInfoComplete)completion;
-(void)getLikedPhotoUsersInfo:(nonnull id)likedUsersIDs :(OnLikedUsersFullObjectsComplete)completion;
- (void)getBannedUsersIDs:(NSInteger)offsetBannedUsersIDs :(OnGetBannedUsersIDsComplete)completion;
-(void)getBannedUsersInfo:(nullable id)filters :(BOOL)offset  :(OnGetBannedUsersInfoComplete)completion;

-(void)getFavoriteUsersIDs:(NSInteger)offsetFavoriteUsersIDs :(OnGetFavoriteUsersIDsComplete)completion;
-(void)getFavoriteUsersInfo:(nullable id)filters :(BOOL)offset :(OnGetFavoriteUsersInfoComplete)completion;


NS_ASSUME_NONNULL_END
@end
