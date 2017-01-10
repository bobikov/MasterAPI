//
//  FriendsViewController.h
//  vkapp
//
//  Created by sim on 19.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
#import"FriendsCustomCellView.h"
#import "StringHighlighter.h"

@interface FriendsViewController : NSViewController{

    __weak IBOutlet NSSearchField *searchBar;
    __weak IBOutlet NSTableView *FriendsTableView;
//    NSMutableArray *FriendsData;
    NSImageView *profileImage;
    NSDictionary *receiverDataForMessage;
    __weak IBOutlet NSButton *FriendsCountInline;
    __weak IBOutlet NSButton *FriendsFilterOffline;
    __weak IBOutlet NSButton *womenFilter;
    __weak IBOutlet NSButton *menFilter;
    __weak IBOutlet NSButton *FriendsFilterOnline;
    __weak IBOutlet NSButton *FriendsFilterActive;
    __weak IBOutlet NSProgressIndicator *progressSpin;
    __weak IBOutlet NSButton *addToBlackList;
    __weak IBOutlet NSButton *mainSendMessage;
    __weak IBOutlet NSButton *deleteFromFriends;
    BOOL cleanTableFlag;
    NSMutableArray *FriendsData;
     NSMutableArray *FriendsDataCopy;
    NSMutableArray *selectedUsers;
    __weak IBOutlet NSPopUpButton *friendsListPopup;
   
    __weak IBOutlet NSButton *friendsTotalCount;
  
    __weak IBOutlet NSButton *friendsStatBut;
    NSMutableArray *friendsListPopupData;
    __weak IBOutlet NSScrollView *scrollView;
    __weak IBOutlet NSTextField *cityField;
    NSMutableDictionary *cachedImage;
    NSMutableDictionary *cachedStatus;
}

@property(nonatomic)appInfo *app;
//@property(nonatomic)FriendsCustomCellView *myCell;
@property (strong) IBOutlet NSArrayController *arrayController;
@property(nonatomic,readwrite)BOOL loadFromFullUserInfo;
@property(nonatomic,readwrite)BOOL loadFromWallPost;
@property(nonatomic,readwrite)NSDictionary *userDataFromFullUserInfo;
@property(nonatomic,readwrite)NSString *ownerId;
@property(nonatomic)StringHighlighter *stringHighlighter;
@end
