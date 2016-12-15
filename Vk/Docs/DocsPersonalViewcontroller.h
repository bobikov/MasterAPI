//
//  DocsPersonalViewcontroller.h
//  vkapp
//
//  Created by sim on 07.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import"appInfo.h"
#import "VKCaptchaHandler.h"
#import "ViewControllerMenuItem.h"
@interface DocsPersonalViewcontroller : NSViewController{
     NSMutableArray *docsData;
     NSMutableArray *docsDataCopy;
    __weak IBOutlet NSTextField *publicIdField;
    __weak IBOutlet NSTextField *countField;
    __weak IBOutlet NSTextField *offsetField;
    __weak IBOutlet NSButton *checkPDF;
    __weak IBOutlet NSButton *checkZIP;
    __weak IBOutlet NSButton *checkTXT;
    __weak IBOutlet NSButton *checkDJVU;
    __weak IBOutlet NSButton *checkGIF;
    __weak IBOutlet NSButton *DownloadButton;
    __weak IBOutlet NSButton *uploadButton;
    __weak IBOutlet NSScrollView *docsScrollView;
    __weak IBOutlet NSClipView *docsClipView;
    __weak IBOutlet NSTableView *docsTableView;
    __weak IBOutlet NSProgressIndicator *progressSpin;
    __weak IBOutlet NSProgressIndicator *downloadAndUploadProgressBar;
    NSDictionary *dataForUserInfo ;
    __weak IBOutlet NSSearchField *searchDocsBar;
    BOOL loadForAttachments;
    NSString *uploadURL;
     dispatch_semaphore_t semaphore2;
    dispatch_semaphore_t downloadSemaphore;
    NSString *filePath;
    NSURLSessionDownloadTask *downloadFile;
    NSString *docFileName;
    NSFileManager *manager;
    NSInteger selectedCount;
    NSInteger counterDownloader;
    BOOL next;
    NSMutableArray *selectedItems;
    NSString *owner;
    __weak IBOutlet NSPopUpButton *userGroupsByAdmin;
    NSMutableArray *userGroupsByAdminData;
    __weak IBOutlet NSTextField *downloadAndUploadProgressBarLabel;
    __weak IBOutlet NSTextField *tagsField;
    NSString *tags;
    __weak IBOutlet NSButton *stopButton;
    __weak IBOutlet NSButton *addMultipleDocsBut;
    NSInteger uploadCounter;
     NSArray* filesForUpload;
    NSString *fileName;
    __weak IBOutlet NSButton *globalCheck;
    BOOL stopFlag;
    __weak IBOutlet NSButton *editButton;
    __weak IBOutlet NSButton *downloadButton;
    ViewControllerMenuItem *viewControllerItem;
    __weak IBOutlet NSButton *deleteButton;
}

@property(nonatomic)appInfo *app;
typedef void(^OnComplete)(NSData *data);
-(void)getUploadUrl:(OnComplete)completion;
@property(nonatomic, strong) NSWindowController *showDocController;
@property(nonatomic,readwrite) NSDictionary *recivedData;
@property (nonatomic, strong)NSURLSession *backgroundSession;
@property(nonatomic)VKCaptchaHandler *captchaHandler;
@end
