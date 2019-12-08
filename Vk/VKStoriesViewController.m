//
//  VKStoriesViewController.m
//  MasterAPI
//
//  Created by sim on 10/06/18.
//  Copyright © 2018 sim. All rights reserved.
//

#import "VKStoriesViewController.h"

@interface VKStoriesViewController () <NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>


@end

@implementation VKStoriesViewController
//@synthesize cameraView;
- (void)viewDidLoad {
    [super viewDidLoad];
    _app = [[appInfo alloc]init];
    manager = [NSFileManager defaultManager];
    image_formats = @[@"jpg",@"png",@"jpeg",@"gif"];
    video_formats = @[@"mp4"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadVkStoryWithEffects:) name:@"UploadVKStoryPhotoWithEffects" object:nil];
    [self configCameraLayer];
    
    
}
-(void)uploadVkStoryWithEffects:(NSNotification*)obj{
    
}
- (void)viewDidAppear{
    cameraLayer = cameraView.layer;
    cameraLayer.backgroundColor = [[NSColor blackColor]CGColor];
    //    [self cameraCapture];
}
- (void)viewDidDisappear{
    if([session isRunning]){
        [session stopRunning];
        [assetWriterMyData finishWritingWithCompletionHandler:^{
            
        }];
    }
}
-(void)configCameraLayer{
    
    
    
}
-(void)configCameraSession{
    
}
- (void)cameraCapture{
    
    [self removeCapturedVideoFile];
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    NSMutableArray *mainDevices = [[NSMutableArray alloc] init];
    for (AVCaptureDevice *device in devices) {
        if([[device localizedName] containsString:@"iSight"]){
            [mainDevices addObject:device];
        }
    }
    NSLog(@"%@", mainDevices);
    session = [[AVCaptureSession alloc] init];
    
    //    [session beginConfiguration];
    
    NSError *error;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:mainDevices[0] error:&error];
    
    [session addInput:videoInput];
    
    AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc]init];
    dispatch_queue_t video_queue = dispatch_queue_create("VideoQueue", nil);
    [videoOutput setSampleBufferDelegate:self queue:video_queue];
    
    [videoOutput setAlwaysDiscardsLateVideoFrames:YES];
    videoOutput.videoSettings = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    
    //            output.videoSettings = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8Planar) };
    //    output.videoSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecH264,AVVideoCodecKey,nil];
    
    
    //    output.minFrameDuration = CMTimeMake(1, 15);
    [session addOutput:videoOutput];
    //            AVCaptureConnection* avConnection = [output connectionWithMediaType:AVMediaTypeVideo];
    //            avConnection.automaticallyAdjustsVideoMirroring=NO;
    //            [avConnection setVideoMirrored:YES];
    NSLog(@"Available video codecs: %@", [videoOutput availableVideoCodecTypes]);
    //    AVCaptureFileOutput *fileOutput = [[AVCaptureFileOutput alloc]init];
    
    
    
    
    audioOutput = [[AVCaptureAudioDataOutput alloc]init];
    dispatch_queue_t audio_queue = dispatch_queue_create("AudioQueue", nil);
    [audioOutput setSampleBufferDelegate:self queue:audio_queue];
    
    [session addOutput:audioOutput];
    
    preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    preview.connection.automaticallyAdjustsVideoMirroring=NO;
    preview.connection.videoMirrored=YES;
    
    
    
    
    assetWriterMyData = [[AVAssetWriter alloc] initWithURL:filePath fileType:AVFileTypeMPEG4 error:&error];
    
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:640], AVVideoWidthKey, [NSNumber numberWithInt:480], AVVideoHeightKey, AVVideoCodecH264, AVVideoCodecKey,nil];
    
    assetVideoWriterInput = [AVAssetWriterInput  assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
    assetVideoWriterInput.expectsMediaDataInRealTime = YES;
    
    pixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc]
                          initWithAssetWriterInput:assetVideoWriterInput sourcePixelBufferAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA],kCVPixelBufferPixelFormatTypeKey,
                                                                                                      nil]];
    
    
    
    AudioChannelLayout acl;
    bzero( &acl, sizeof(acl));
    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
    //    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    NSDictionary *audioOutputSettings = nil;
    //    audioOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
    //                                     [ NSNumber numberWithInt: kAudioFormatMPEG4AAC ], AVFormatIDKey,
    //                                     [ NSNumber numberWithInt: 1 ], AVNumberOfChannelsKey,
    //                                     [ NSNumber numberWithFloat: 44100.0 ], AVSampleRateKey,
    //                                     [ NSNumber numberWithInt: 64000 ], AVEncoderBitRateKey,
    //                                     [ NSData dataWithBytes: &acl length: sizeof( acl ) ], AVChannelLayoutKey,
    //                                     nil];
    //    audioOutputSettings = [ NSDictionary dictionaryWithObjectsAndKeys:
    //                           [ NSNumber numberWithInt: kAudioFormatAppleLossless ], AVFormatIDKey,
    //                           [ NSNumber numberWithInt: 16 ], AVEncoderBitDepthHintKey,
    //                           [ NSNumber numberWithFloat: 44100.0 ], AVSampleRateKey,
    //                           [ NSNumber numberWithInt: 1 ], AVNumberOfChannelsKey,
    //                           [ NSData dataWithBytes: &acl length: sizeof( acl ) ], AVChannelLayoutKey,
    //                           nil ];
    audioOutputSettings = @{
                            AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                            AVSampleRateKey: @(44100),
                            AVChannelLayoutKey: [NSData dataWithBytes:&acl length:sizeof(acl)],
                            };
    assetAudioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings: audioOutputSettings ];
    
    assetAudioWriterInput.expectsMediaDataInRealTime=YES;
    [assetWriterMyData addInput:assetVideoWriterInput];
    [assetWriterMyData addInput:assetAudioWriterInput];
    
    
    
    
    
    /* Asset writer with MPEG4 format*/
    
    //    imageBuffer = NULL;
    //    NSParameterAssert(assetWriterInput);
    //    NSParameterAssert([assetWriterMyData canAddInput:assetWriterInput]);
    
    
    //    preview.connection.videoOrientation=AVCaptureVideoOrientationLandscapeRight;
    
    //    CALayer *cameraLayer = cameraView.layer;
    //    cameraLayer.backgroundColor = [[NSColor blackColor]CGColor];
    //    cameraView.layer.mask=layer;
    //    cameraView.wantsLayer=YES;
    
    //    layer.masksToBounds=YES;
    //    AVCaptureFileOutput *fileOutput = [[AVCaptureFileOutput alloc]init];
    //    [fileOutput setDelegate:self];
    //     [fileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:@"/Users/hal/Desktop/cam_recording.mp4"] recordingDelegate:self];
    if(![[cameraLayer sublayers] containsObject:preview]){
        preview.frame = cameraLayer.bounds;
        [cameraLayer addSublayer:preview];
    }
    
    //    [layer insertSublayer:preview atIndex:0];
    [session setSessionPreset:AVCaptureSessionPreset640x480];
    frameNumber = 0;
    //    [session commitConfiguration];
    [assetWriterMyData startWriting];
    [assetWriterMyData startSessionAtSourceTime:kCMTimeZero];
    [session startRunning];
}
- (void)removeCapturedVideoFile{
    filePath = [manager URLForDirectory:NSDesktopDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    
    filePath = [filePath URLByAppendingPathComponent:@"recording.mp4"];
    
    if([manager fileExistsAtPath:[[filePath absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""] isDirectory:NO]){
        [manager removeItemAtPath:[[filePath absoluteString]stringByReplacingOccurrencesOfString:@"file://" withString:@""]  error:nil];
        NSLog(@"Capture file exists");
    }else{
        //        [manager createFileAtPath:[filePath absoluteString] contents:nil attributes:nil];
    }
    NSLog(@"%@", [filePath absoluteString]);
    
}
- (IBAction)stopCamera:(id)sender {
    if([session isRunning]){
        [session stopRunning];
        [assetWriterMyData finishWritingWithCompletionHandler:^{
            
        }];
    }else{
        [self cameraCapture];
        //        [session startRunning];
    }
}
- (NSArray*)getFilesForUpload{
    
    NSOpenPanel *rDialog = [NSOpenPanel openPanel];
    [rDialog setCanChooseFiles:YES];
    [rDialog setCanChooseDirectories:YES];
    [rDialog setAllowsMultipleSelection:YES];
    
    [rDialog setAllowedFileTypes: rfformat == file ? image_formats : video_formats];
    if ([rDialog runModal] == NSFileHandlingPanelOKButton){
        files = [rDialog URLs];
        for( NSURL *i in files){
            long size = [[manager attributesOfItemAtPath:i.path error:nil] fileSize];
            NSLog(@"%ld",size);
            if(size >= 10485760){
                
                fileSizeLimit = YES;
                break;
                
            }
        }
        if(fileSizeLimit){
            NSLog(@"File size more than 10mb is found.");
        }else{
            [self prepareForUpload];
        }
    }else{
        NSLog(@"Canceled selecting files for story");
    }
    
    return files;
}
- (void)convertGifToMp4{
    //    NSData *gif = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://i.imgur.com/xqG0QP3.gif"]];
    //    NSString *outputPath = [NSTemporaryDirectory() stringByAppendingString:@"output.mp4"];
    //
    //    GIFConverter *gifConverter = [[GIFConverter alloc] init];
    //    [gifConverter convertGIFToMP4:gif speed:1.0 size:CGSizeMake(200, 200) repeat:0 output:outputPath completion:^(NSError *error){
    //        if(!error)
    //            NSLog(@"Converted video!");
    //    }];
}
- (void)openPhotoEffectsWindow{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setImageDataWidthEffects:) name:@"UploadPhotoToAlbumWithEffects" object:nil];
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Sixth" bundle:nil];
    efvc = [story instantiateControllerWithIdentifier:@"PhotoEffectsView"];
    efvc.profilePhoto = NO;
    efvc.vkStory = YES;
    efvc.originalImageURLs = @[filePath];
    [self presentViewControllerAsModalWindow:efvc];
}
- (IBAction)upload:(id)sender {
    
    rfformat = sender == uploadPhoto ? file : video_file;
    files = [self getFilesForUpload];
}

- (void)prepareForUpload{
    backgroundConfigurationObject = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"myBackgroundSessionIdentifier1"];
    backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfigurationObject delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    
    uploadCounter = 0;
    if(!files){
        NSLog(@"Files have not got");
    }else{
        NSLog(@"Files to prepare: %@", files);
        if(rfformat == file){
            url = @"https://api.vk.com/method/stories.getPhotoUploadServer";
        }else{
            url = @"https://api.vk.com/method/stories.getVideoUploadServer";
        }
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?add_to_news=1&access_token=%@&v=%@", url, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary *obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if(data){
                if(obj[@"response"]){
                    upload_url= obj[@"response"][@"upload_url"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self startUpload];
                    });
                    
                }else{
                    
                }
                
                
            }
            //            NSLog(@"%@", obj);
        }]resume];
    }
    
}
- (void)startUpload{
    fileName = [files[uploadCounter] lastPathComponent];
    extension = [fileName pathExtension];
    contents = [NSData dataWithContentsOfFile:files[uploadCounter]];
    NSLog(@"Upload url: %@", upload_url);
    NSLog(@"Extension: %@", extension);
    NSLog(@"Filename: %@", fileName);
    NSLog(@"Rfformat: %u", rfformat);
    NSLog(@"URL: %@", url );
    
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:contents];
//    NSData *data1 = rfformat == file ? [imageRep representationUsingType:[extension isEqual: @"jpg"] || [extension isEqual: @"png"] || [extension isEqual: @"gif"] ? NSJPEGFileType : NSJPEGFileType properties:nil] : contents;
    NSData *data1 = rfformat == file ? [imageRep representationUsingType:[@[@"gif", @"jpg", @"png"] containsObject: extension] ? NSBitmapImageFileTypeJPEG : NSBitmapImageFileTypeJPEG properties:nil] : contents;
    NSLog(@"%@", extension);
//    NSData *data1 = rfformat == file ? [imageRep representationUsingType:[extension isEqual: @"jpg"]  ? NSJPEGFileType : [extension isEqual: @"png"] ? NSJPEGFileType : [extension isEqual: @"gif"] ? NSGIFFileType : NSJPEGFileType properties:nil] : contents;
    NSMutableURLRequest *request = [_app getMutableURLRequestWithMultipartData:[NSURL URLWithString:upload_url] filename:fileName bodyData:data1 fformat:rfformat == file ? @"file" : @"video_file"];
    
    NSURLSessionDataTask *uploadTask = [backgroundSession dataTaskWithRequest:request];
    uploadProgress.hidden=NO;
    [uploadTask resume];
}
- (void)getStories{
    
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    completionHandler(NSURLSessionResponseAllow);
    
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    
    if(data){
        NSDictionary *uploadPhotoResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"%@", uploadPhotoResponse);
        uploadCounter++;
        if(uploadPhotoResponse[@"response"]){
            if([files count]==uploadCounter){
                [backgroundSession finishTasksAndInvalidate];
                dispatch_async(dispatch_get_main_queue(), ^{
                    uploadProgress.hidden=YES;
                    NSLog(@"All the stories have uploaded");
                });
                
            }else{
                [self startUpload];
            }
            NSLog(@"Story is uploaded successfully");
        }else{
            [backgroundSession invalidateAndCancel];
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    
    uploadProgress.maxValue = totalBytesExpectedToSend;
    uploadProgress.doubleValue = totalBytesSent;
    
}
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    imageBuffer = NULL;
    //    UIImage *image = imageFromSampleBuffer(sampleBuffer);
    imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    //    CMSampleBufferRef *audioBuffer = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer,nil, &audioBufferList,UInt(sizeof(audioBufferList.dynamicType)),nil,nil,UInt32(kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment),&buffer);
    //    CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    //    NSLog(@"%@", imageBuffer);
    // a very dense way to keep track of the time at which this frame
    // occurs relative to the output stream, but it's just an example!
    
    if(assetVideoWriterInput.readyForMoreMediaData){
        [pixelBufferAdaptor appendPixelBuffer:imageBuffer
                         withPresentationTime:CMTimeMake(frameNumber, 9)];
        frameNumber++;
    }else{
        NSLog(@"Video input nor ready to write");
    }
    //    if(captureOutput == audioOutput){
    if([assetAudioWriterInput isReadyForMoreMediaData]){
        [assetAudioWriterInput appendSampleBuffer:sampleBuffer];
    }else{
        NSLog(@"Audio input not ready to write");
    }
    
    //    }
    NSLog(@"Warning: writer status is %ld", assetWriterMyData.status);
}

- (void) captureAudio:(CMSampleBufferRef)sampleBuffer
{
    
}

@end
