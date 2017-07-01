//
//  WallPostViewController.h
//  vkapp
//
//  Created by sim on 20.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
#import "VKCaptchaHandler.h"
#import "TwitterClient.h"
#import "PostAttachmentsCustomItem.h"
#import "TumblrClient.h"
@interface WallPostViewController : NSViewController{
    
    __weak IBOutlet NSButton *repeat;
    __weak IBOutlet NSTextField *afterPost;
    __weak IBOutlet NSTextField *publicId;
    __unsafe_unretained IBOutlet NSTextView *textView;
    __weak IBOutlet NSButton *makePost;
    __weak IBOutlet NSButton *stop;
    __weak IBOutlet NSTableView *recentGroups;
    __weak IBOutlet NSTableView *listOfMessages;
    __weak IBOutlet NSProgressIndicator *progressSpin;
    __weak IBOutlet NSBox *radioBox;
    __weak IBOutlet NSButton *postRadio;
    __weak IBOutlet NSButton *commentRadio;
    __weak IBOutlet NSPopUpButton *groupsList;
    __weak IBOutlet NSButton *PostVK;
    __weak IBOutlet NSButton *PostTwitter;
    __weak IBOutlet NSButton *postTumblr;
    __weak IBOutlet NSTextField *cautionLabel;
    __weak IBOutlet NSImageView *cautionImage;
    __weak IBOutlet NSTextField *charCount;
    __weak IBOutlet NSCollectionView *attachmentsCollectionView;
    __weak IBOutlet NSTextField *attachmentsCountLabel;
    __weak IBOutlet NSTextField *afterPostIdField;
    __weak IBOutlet NSButton *fromGroup;
    __weak IBOutlet NSButton *newSessionStartBut;
    __weak IBOutlet NSTextField *startedSessionStatusLabel;
    __weak IBOutlet NSButton *startedSessionCloseBut;
    __weak IBOutlet NSTextField *newSessionNameField;
    __weak IBOutlet NSButton *addPostToQueueBut;
    __weak IBOutlet NSDatePicker *publishingDateForPost;
    __weak IBOutlet NSButton *savePostsSessionBut;
    __weak IBOutlet NSBox *sessionWrapper;
    
    __weak IBOutlet NSSegmentedControl *ownersSelectorSegment;
    __weak IBOutlet NSTableView *preparedListToPost;
    
    
    int
        countPhotoInAttachments,
        countDocsInAttachments,
        countVideoInAttachments,
        ownersCounter;
    
    NSArray *dataAttachmentsFinalArray;
    
    NSMutableArray
        *groupsData,
        *groupsToPost,
        *messagesToPost,
        *preparedAttachmentsString,
        *attachmentsDataScheduled,
        *attachmentsData,
        *indexPaths,
        *queuePostsInSession,
        *preparedOwnersList;
    NSString
        *groupDescription,
        *groupDeactivated,
        *groupName,
        *groupAvatar,
        *mediaAttachmentType,
        *attachmentsPostVKStringScheduled,
        *attachmentsPostVKString,
        *message,
        *currentPostsSessionName,
        *owner,
        *alphabet;
    
    NSInteger
        postAfter,
        selectedObject,
        repeatState;
    
    NSMutableString *guId;
    NSMutableDictionary *postTargetSourceSelector;
    NSManagedObjectContext *moc;
    
    BOOL
        stopFlag,
        reverse,
        captchaOpened;
}
@property(nonatomic)appInfo *app;
@property(nonatomic)VKCaptchaHandler *captchaHandler;
@property(nonatomic)TwitterClient *twitterClient;
@property(nonatomic)TumblrClient *tumblrClient;
typedef void(^OnComplete)(NSData *data);
-(void)getGroupInfo:(OnComplete)completion;
@end
