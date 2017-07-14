//
//  VKLikesViewController.h
//  MasterAPI
//
//  Created by sim on 14/07/17.
//  Copyright © 2017 sim. All rights reserved.
//

#import "ViewController.h"
#import "appInfo.h"
@interface VKLikesViewController : ViewController{
    
    __weak IBOutlet NSButton *dismiss;
    __weak IBOutlet NSTableView *likedUsersList;
    
    NSMutableArray
        *usersListData,
        *usersIDs;
    NSString *city;
    NSString *status;
    NSString *bdate;
    NSString *online;
    NSString *firstName;
    NSString *lastName;
    NSString *fullName;
    NSString *countryName;
    NSString *last_seen;
    NSString *sex;
    NSString *books;
    NSString *site;
    NSString *mobilePhone;
    // NSString *phone;
    NSString *photoBig;
    NSString *photo;
    NSString *about;
    NSString *music;
    NSString *schools;
    NSString *education;
    NSString *quotes;
    NSString *deactivated;
    NSString *relation;
    NSString *domain;
    NSShadow *tshadow;
    int blacklisted;
    int blacklisted_by_me;

    appInfo *app;
    __weak IBOutlet NSProgressIndicator *progress;
}
typedef void(^OnGetUsersInfoComplete)(NSMutableArray *completion);
typedef void(^OnLikedListComplete)(NSMutableArray *completion);
-(void)getLikedUsers:(OnLikedListComplete)completion;
-(void)getUsersInfo:(OnGetUsersInfoComplete)completion;
@property(nonatomic)NSDictionary *receivedData;
@end
