//
//  VKStoriesViewController.h
//  MasterAPI
//
//  Created by sim on 10/06/18.
//  Copyright © 2018 sim. All rights reserved.
//
//
typedef enum {
    file=1,
    video_file
} RequestFileFormat;
#import <Cocoa/Cocoa.h>
#import "appInfo.h"
@interface VKStoriesViewController : NSViewController{
    NSFileManager *manager;
    
    __weak IBOutlet NSButton *uploadPhoto;
    RequestFileFormat rfformat;
    __weak IBOutlet NSButton *uploadVideo;
    __weak IBOutlet NSProgressIndicator *uploadProgress;
    NSData *contents;
    NSInteger uploadCounter;
    NSString *fileName, *extension, *url, *upload_url;
    NSURLSession *backgroundSession;
    NSArray *image_formats, *video_formats, *files;
    
    
}
@property appInfo *app;
@end
