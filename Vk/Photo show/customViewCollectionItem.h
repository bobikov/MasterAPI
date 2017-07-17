//
//  customViewCollectionItem.h
//  vkapp
//
//  Created by sim on 25.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"

@interface customViewCollectionItem : NSCollectionViewItem{
    NSURLSessionDownloadTask *downloadFile;
    BOOL downloading;
    BOOL next;
    NSString *fileName;
    NSString *currentFileName;
    NSString *newDirectoryName;
    NSFileManager *manager;
    dispatch_semaphore_t semaphore;
    NSString *uploadURL;
    NSString *hash;
    NSString *server;
    NSString *photoList;
    NSString *baseURL;
    dispatch_semaphore_t semaphore2;
    NSString *selectedDirectoryPath;
    NSInteger uploadCounter;
    NSInteger downloadCounter;
    NSURL *uploadUrl;
    NSArray* filesForUpload;
    NSString *filename;
    NSString *albumToUploadTo;
    NSString *ownerId;
    NSMutableDictionary *selectedObject;
    customViewCollectionItem *item;
    double progress;
    double expectedBytes;
    BOOL proccessGoing;
    NSMenu *theDropdownContextMenu;
    NSInteger overAlbumId;
    NSData *contents;
}
@property (weak) IBOutlet NSButton *uploadByURLsButton;
@property (weak) IBOutlet NSImageView *albumsCover;
@property (weak) IBOutlet NSButton *downloadButton;
@property (weak) IBOutlet NSButton *uploadPhoto;
@property (weak) IBOutlet NSButton *removeItem;
@property (weak) IBOutlet NSTextField *countInAlbum;

@property (weak) IBOutlet NSProgressIndicator *downloadAndUploadProgress;
@property (weak) IBOutlet NSTextField *downloadAndUploadProgressLabel;
@property (weak) IBOutlet NSBox *downloadAndUploadStatusOver;
@property (weak) IBOutlet NSButton *closeProgressOver;
@property (weak) IBOutlet NSTextField *textLabel;
@property(nonatomic)NSTrackingArea *trackingArea;
@property (nonatomic) appInfo *app;
@property (nonatomic, strong)NSURLSession *backgroundSession;
@property (weak) IBOutlet NSButton *moveToAlbumBut;
@property(nonatomic,readwrite)NSProgressIndicator *indicator;
@property(nonatomic,readwrite)NSMutableArray *userGroupsByAdmin;
@property (weak) IBOutlet NSButton *attachAlbum;
-(void)addProgressView;
-(void)setProgress;

@end
