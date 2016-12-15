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
    NSMutableArray *groupsToPost;
    NSMutableArray *messagesToPost;
    __weak IBOutlet NSTableView *listOfMessages;
    __weak IBOutlet NSProgressIndicator *progressSpin;
    __weak IBOutlet NSBox *radioBox;
    __weak IBOutlet NSButton *postRadio;
    __weak IBOutlet NSButton *commentRadio;
    __weak IBOutlet NSPopUpButton *groupsList;
    NSMutableArray *groupsData;
    NSString *groupAvatar;
    NSString *groupDescription;
    NSString *groupDeactivated;
    NSString *groupName;
    BOOL stopFlag;
    NSInteger selectedObject;
    BOOL captchaOpened;
    __weak IBOutlet NSButton *PostVK;
    __weak IBOutlet NSButton *PostTwitter;
    __weak IBOutlet NSButton *postTumblr;
    __weak IBOutlet NSTextField *cautionLabel;
    __weak IBOutlet NSImageView *cautionImage;
    __weak IBOutlet NSTextField *charCount;
    __weak IBOutlet NSCollectionView *attachmentsCollectionView;
    NSMutableArray *attachmentsData;
    NSArray *dataAttachmentsFinalArray;
    NSString *attachmentsPostVKString;
    NSMutableArray *preparedAttachmentsString;
    NSString *mediaAttachmentType;
    __weak IBOutlet NSTextField *attachmentsCountLabel;
    int countPhotoInAttachments;
    int countVideoInAttachments;
    int countDocsInAttachments;
    NSMutableArray *indexPaths;
    __weak IBOutlet NSTextField *afterPostIdField;
    
    NSString *message;
    __weak IBOutlet NSButton *fromGroup;
    BOOL reverse;
}
@property(nonatomic)appInfo *app;
@property(nonatomic)VKCaptchaHandler *captchaHandler;
@property(nonatomic)TwitterClient *twitterClient;
@property(nonatomic)TumblrClient *tumblrClient;
typedef void(^OnComplete)(NSData *data);
-(void)getGroupInfo:(OnComplete)completion;
@end
