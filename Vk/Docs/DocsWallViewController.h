//
//  DocsWallViewController.h
//  vkapp
//
//  Created by sim on 07.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
@interface DocsWallViewController : NSViewController{
__weak IBOutlet NSButton *DownloadButton;
__weak IBOutlet NSTextField *publicIdField;
__weak IBOutlet NSTextField *countField;
__weak IBOutlet NSTextField *offsetField;
__weak IBOutlet NSButton *checkPDF;
__weak IBOutlet NSButton *checkZIP;
__weak IBOutlet NSButton *checkTXT;
__weak IBOutlet NSButton *checkDJVU;
__weak IBOutlet NSButton *checkGIF;
__weak IBOutlet NSTextField *progressLabel;
__weak IBOutlet NSProgressIndicator *progressBar;
__weak IBOutlet NSTextField *DownloadDirectory;

__weak IBOutlet NSButton *addToDocs;
__weak IBOutlet NSBox *radioBox;
NSString* fileName;
NSString *newDirectoryName;
NSInteger publicIdIntTemp;
NSString *publicIdFrom;
NSFileManager *manager;
__weak IBOutlet NSTextField *currentDownloadingFile;
__weak IBOutlet NSProgressIndicator *currentFileProgress;
NSURLSessionDownloadTask *downloadFile;
NSString *currentFileName;
BOOL next;
BOOL attachCountMoreThanOne;
dispatch_semaphore_t semaphore;
dispatch_semaphore_t semaphore2;
NSMutableArray *tempDocs;
BOOL downloading ;
NSInteger step2;
NSInteger step;
NSMutableArray *tempTypeDocs;
NSMutableArray *tempDates;
BOOL stopped;
NSMutableArray *fromIds;
NSMutableArray *dates;
}
@property (nonatomic) appInfo *app;
@property (nonatomic, strong)NSURLSession *backgroundSession;


@end
