//
//  VKStoriesViewController.m
//  MasterAPI
//
//  Created by sim on 10/06/18.
//  Copyright © 2018 sim. All rights reserved.
//

#import "VKStoriesViewController.h"

@interface VKStoriesViewController () <NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>


@end

@implementation VKStoriesViewController
//@synthesize cameraView;
- (void)viewDidLoad {
    [super viewDidLoad];
    _app = [[appInfo alloc]init];
    manager = [NSFileManager defaultManager];
    image_formats = @[@"jpg",@"png",@"jpeg",@"gif"];
    video_formats = @[@"mp4"];
    
    [self configCameraLayer];
    
  
}
- (void)viewDidAppear{
    [self cameraCapture];
}
-(void)configCameraLayer{
   
   
    
}
-(void)configCameraSession{
    
}
- (void)cameraCapture{
    
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    NSMutableArray *mainDevices = [[NSMutableArray alloc] init];
    for (AVCaptureDevice *device in devices) {
        if([[device localizedName] containsString:@"iSight"]){
            [mainDevices addObject:device];
        }
    }
  
    session = [[AVCaptureSession alloc] init];
    
    
//    [session beginConfiguration];
    
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:devices[0] error:&error];
     [session addInput:input];
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc]init];
    [output setAlwaysDiscardsLateVideoFrames:YES];
    
    output.videoSettings = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };
    output.videoSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    
       NSLog(@"%@", mainDevices);
    
//    output.minFrameDuration = CMTimeMake(1, 15);
   
    [session addOutput:output];
    
//    dispatch_queue_t queue = dispatch_queue_create("MyQueue", nil);
//    [output setSampleBufferDelegate:self queue:queue];
    preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [preview setVideoGravity:AVLayerVideoGravityResizeAspect];
//    preview.connection.videoOrientation=AVCaptureVideoOrientationLandscapeRight;
    
    CALayer *layer = cameraView.layer;
//    cameraView.layer.mask=layer;
//    cameraView.wantsLayer=YES;
  
//    layer.masksToBounds=YES;

    preview.frame = layer.bounds;
    [layer addSublayer:preview];
//    [layer insertSublayer:preview atIndex:0];
    [session setSessionPreset:AVCaptureSessionPreset640x480];
//    [session commitConfiguration];
    [session startRunning];
}
- (IBAction)stopCamera:(id)sender {
    if([session isRunning]){
        [session stopRunning];
    }else{
        [session startRunning];
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
        
        [self prepareForUpload];
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
- (IBAction)upload:(id)sender {
    
    rfformat = sender == uploadPhoto ? file : video_file;
    files = [self getFilesForUpload];
}

- (void)prepareForUpload{
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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:upload_url]];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:contents];
    NSData *data1 = rfformat == file ? [imageRep representationUsingType:[extension isEqual: @"jpg"] || [extension isEqual: @"png"] ? NSJPEGFileType : [extension isEqual: @"gif"] ? NSGIFFileType : NSJPEGFileType properties:nil] : contents;
    
    //    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
//    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
//    [request setHTTPShouldHandleCookies:NO];
//    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    NSString *kStringBoundary = @"*******";
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",kStringBoundary] forHTTPHeaderField:@"Content-Type"];
    NSString *beginLine = [NSString stringWithFormat:@"\r\n--%@\r\n", kStringBoundary];
    NSMutableData *body = [NSMutableData data];
    
    [body appendData:[beginLine dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\";  filename=\"%@\"\r\n", rfformat == file ? @"file" : @"video_file", fileName] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[@"Content-Type: image/gif\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Length: %d\r\n\r\n",(int)[data1 length]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:data1];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", kStringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    NSURLSessionConfiguration *backgroundConfigurationObject = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"myBackgroundSessionIdentifier1"];
     backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfigurationObject delegate:self delegateQueue:[NSOperationQueue mainQueue]];
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
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
//    UIImage *image = imageFromSampleBuffer(sampleBuffer);
}

@end
