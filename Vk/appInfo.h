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
#import "VKCaptchaHandler.h"

NS_ASSUME_NONNULL_BEGIN
@interface appInfo : NSObject{
    
    NSMutableArray
        *usersListData,
        *usersIDs,
        *searchResults;
    
    NSString *desc;
    NSString *country;
    NSNumber *membersCount;
    NSNumber *startDate;
    NSNumber *finishDate;
    NSNumber *isAdmin;
    NSNumber *isClosed;
    NSNumber *isMember;
    NSString *type;
    NSString *screenName;
    

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
        *verified,
        *banInfo;
    
    int
        blacklisted,
        blacklisted_by_me;
    
    NSInteger
        offsetLoadBanlist,
        offsetCounter,
        totalCountBanned,
        offsetLoadFaveUsers,
        totalFavesUsersCount,
        searchOffsetCounter;
    
}

@property (nonatomic, readwrite) NSString *person;
@property (nonatomic, readwrite) NSString *token;
@property (nonatomic, readwrite) NSString *version;
@property (nonatomic, readwrite) NSString *icon;
@property (nonatomic, readwrite) NSURLSession *session;
@property (nonatomic, readwrite) BOOL selected;
@property (nonatomic, readwrite) NSString *appId;
@property (nonatomic) keyHandler *keyHandle;
@property (nonatomic, readwrite) VKCaptchaHandler *captchaHandler;

typedef void(^OnGetUsersInfoComplete)(NSMutableArray *usersFullObjectsInfo);
typedef void(^OnLikedListComplete)(NSMutableArray *users);
typedef void(^OnLikedUsersFullObjectsComplete)(NSMutableArray *fullObjectLikedPhotoUsers);
typedef void(^OnGetBannedUsersIDsComplete)(NSMutableArray *bannedUsers);
typedef void(^OnGetBannedUsersInfoComplete)(NSMutableArray *bannedUsersInfo, NSInteger offsetCounterResult, NSInteger totalBannedResult, NSInteger bannedUsersListCount, NSInteger offsetBanlistLoadResult);
typedef void(^OnGetFavoriteUsersIDsComplete)(NSMutableArray *favesUsersIDs);
typedef void(^OnGetFavoriteUsersInfoComplete)(NSMutableArray *favesUsersObjectsInfo, NSInteger offsetCounterResult, NSInteger totalFavesUsersResult, NSInteger offsefFavesUsersLoadResult, NSInteger favesUsersListCount);




- (void)getLikedPhotoUsersIDs:(nonnull id)data :(OnLikedListComplete)completion ;
- (void)getUsersInfo:(nonnull id)ids filters:(nullable id)filters :(OnGetUsersInfoComplete)completion;
- (void)getLikedPhotoUsersInfo:(nonnull id)likedUsersIDs :(OnLikedUsersFullObjectsComplete)completion;
- (void)getBannedUsersIDs:(NSInteger)offsetBannedUsersIDs :(OnGetBannedUsersIDsComplete)completion;
- (void)getBannedUsersInfo:(nullable id)filters :(BOOL)offset  :(OnGetBannedUsersInfoComplete)completion;
- (void)getFavoriteUsersIDs:(NSInteger)offsetFavoriteUsersIDs :(OnGetFavoriteUsersIDsComplete)completion;
- (void)getFavoriteUsersInfo:(nullable id)filters :(BOOL)offset data:(nullable id)data :(OnGetFavoriteUsersInfoComplete)completion;

- (void)searchGroups:(BOOL)offset queryString:(nonnull id)queryString :(void(^)(NSMutableArray *groups))completion;
- (void)getGroupById:(nonnull id)groupId :(void(^)(NSDictionary*groupInfoObject))completion;
- (void)searchPeople:(nullable id)searchById queryString:(nullable id)queryString offset:(BOOL)offset :(void (^)(NSMutableArray *people))completion;
- (void)addToSavedPhotos:(NSDictionary*)params captcha_sid:( NSString* _Nullable )captcha_sid captcha_key:(NSString* _Nullable)captcha_key captcha:(BOOL)captcha comletionHandler:(void(^)(NSDictionary *response))completion;


NS_ASSUME_NONNULL_END
@end
