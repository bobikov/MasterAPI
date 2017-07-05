//
//  DialogsViewController.h
//  vkapp
//
//  Created by sim on 25.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
#import "DialogsListCustomCellView.h"
#import "SelectedDialogCustomCellView.h"

@interface DialogsViewController : NSViewController{
    

    __weak IBOutlet NSImageView *logoMessagesOfDialog;
    __unsafe_unretained IBOutlet NSTextView *textOfNewMessage;
//    __weak IBOutlet NSButton *sendMessageButton;
    
    __weak IBOutlet NSButton *deleteDialogs;
    __weak IBOutlet NSButton *sendMessageButton;
    __weak IBOutlet NSTableView *dialogsList;
    __weak IBOutlet NSTableView *selectedDialog;
//    NSMutableArray *dialogsListData;
    NSMutableArray *dialogsMessageData;
    NSMutableArray *uids;
    NSMutableArray *userMessageHistoryData;
    NSString *receiverOfNewMessage;
    NSString *messageDate;
    NSIndexSet *indexs;
    int countReload;
    BOOL personFlag;
    BOOL removeDialog;
    NSInteger loadDialogsOffset;
    NSInteger offsetCounter;
//    __weak IBOutlet NSButton *deleteDialogs;
    __weak IBOutlet NSScrollView *dialogsListScrollView;
    __weak IBOutlet NSClipView *dialogsListClipView;
    NSMutableArray *bodies;
    NSMutableArray *fullNames;
    NSMutableArray *profileImages;
    NSMutableArray *userOnlineStatuses;
    NSMutableArray *unreadStatuses;
    NSMutableArray *userIdsForHistory;
    NSMutableArray *fromIds;
    NSMutableArray *dates;
    NSMutableArray *tempIds;
    __weak IBOutlet NSButton *countUnreadDialogs;
    __weak IBOutlet NSButton *countTotalDialogs;
    __weak IBOutlet NSButton *countLoadedDialogs;
    __weak IBOutlet NSProgressIndicator *progressSpin;
}
@property(nonatomic)appInfo *app;
@property(nonatomic, readwrite)NSMutableArray *dialogsListData;
@end
