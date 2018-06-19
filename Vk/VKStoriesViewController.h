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
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/CALayer.h>
 static int64_t frameNumber;
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
    AVCaptureSession *session;
    AVCaptureVideoPreviewLayer *preview;
    CALayer *cameraLayer;
    NSURLSessionConfiguration *backgroundConfigurationObject;
    BOOL fileSizeLimit;
    
    AVAssetWriterInputPixelBufferAdaptor *pixelBufferAdaptor ;
    AVAssetWriterInput *assetVideoWriterInput;
    AVAssetWriterInput *assetAudioWriterInput;
    AVAssetWriter *assetWriterMyData;
    AVCaptureAudioDataOutput *audioOutput;
    CVImageBufferRef imageBuffer;
    __weak IBOutlet NSView *cameraView;
    BOOL sessionCreated;
    
    NSURL *filePath;
   

}
//@property (weak) IBOutlet NSView *cameraView;
@property appInfo *app;
@end
