//
//  ProfilePhotoChangeViewController.m
//  vkapp
//
//  Created by sim on 23.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "ProfilePhotoChangeViewController.h"
#import "NSImage+Resizing.h"
#import "PhotoEffectsViewController.h"
@interface ProfilePhotoChangeViewController () <NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>

@end

@implementation ProfilePhotoChangeViewController
@synthesize backgroundSession;

- (void)viewDidLoad {
    [super viewDidLoad];
    _app = [[appInfo alloc]init];
    progressUploadBar.hidden=YES;
    [progressSpin startAnimation:self];
    intervalField.enabled=NO;
    filePathLabel.hidden=YES;
    userGroupsByAdminData = [[NSMutableArray alloc]init];
    currentPhoto.wantsLayer=YES;
    currentPhoto.layer.masksToBounds=YES;
    currentPhoto.layer.cornerRadius=4;
    [self loadGroupsByAdminPopup];
}
- (void)viewDidAppear{
    [self loadCurrentPhoto];
}
- (void)loadGroupsByAdminPopup{
    __block NSMenuItem *menuItem;
    __block NSMenu *menu1 = [[NSMenu alloc]init];
    [userGroupsByAdminPopup removeAllItems];
    [userGroupsByAdminData addObject:_app.person];
    viewControllerItem = [[ViewControllerMenuItem alloc]initWithNibName:@"ViewControllerMenuItem" bundle:nil];
    [viewControllerItem loadView];
    menuItem = [[NSMenuItem alloc]initWithTitle:@"Personal" action:nil keyEquivalent:@""];
    viewControllerItem.nameField.stringValue=@"Personal";
    [menuItem setView:[viewControllerItem view]];
    [menu1 addItem:menuItem];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.get?user_id=%@&filter=admin&extended=1&access_token=%@&v=%@", _app.person, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data) {
            NSDictionary *groupsGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            for(NSDictionary *i in groupsGetResponse[@"response"][@"items"]){
                [userGroupsByAdminData addObject:[NSString stringWithFormat:@"-%@",i[@"id"]]];
              
                dispatch_async(dispatch_get_main_queue(),^{
                    viewControllerItem = [[ViewControllerMenuItem alloc]initWithNibName:@"ViewControllerMenuItem" bundle:nil];
                    [viewControllerItem loadView];
                    menuItem = [[NSMenuItem alloc]initWithTitle:[NSString stringWithFormat:@"%@",i[@"name"]] action:nil keyEquivalent:@""];
                    NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:i[@"photo_50"]]];
                    viewControllerItem.photo.wantsLayer=YES;
                    viewControllerItem.photo.layer.masksToBounds=YES;
                    viewControllerItem.photo.layer.cornerRadius=39/2;
                    [viewControllerItem.photo setImageScaling:NSImageScaleProportionallyUpOrDown];
                   
                    image.size=NSMakeSize(30,30);
                    [menuItem setImage:image];
                    viewControllerItem.nameField.stringValue=[NSString stringWithFormat:@"%@", i[@"name"]];
                    [viewControllerItem.photo setImage:image];
                    [menu1 addItem:menuItem];
                 });
            }
            dispatch_async(dispatch_get_main_queue(),^{
                [userGroupsByAdminPopup setMenu:menu1];
            });
        }
    }]resume];
}
- (IBAction)loadByURLCheckAction:(id)sender {
    if(uploadByURLCheck.state){
        fieldWithURL.hidden=NO;
    }else{
        fieldWithURL.hidden=YES;
    }
}
- (void)loadCurrentPhoto{
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/users.get?user_ids=%@&fields=crop_photo&v=%@&access_token=%@", _app.person, _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data){
            NSDictionary *photoGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if(photoGetResponse[@"response"]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSImage *ownerPhoto = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:photoGetResponse[@"response"][0][@"crop_photo"][@"photo"][@"sizes"][3][@"url"]]];
                    ownerPhoto = [self prepareImageForProfile:ownerPhoto];

                    [currentPhoto setImage:ownerPhoto];
                    [progressSpin stopAnimation:self];
//                    if(currentPhoto.frame.origin.y<15){
//                        wraper.frame = NSMakeRect(wraper.frame.origin.x, wraper.frame.origin.y, wraper.frame.size.width, wraper.frame.size.height+15-currentPhoto.frame.origin.y);
//                    }
                });
            }
            else{
                NSLog(@"Error load current photo: %@", photoGetResponse);
            }
        }
    }] resume];
}
- (NSImage*)prepareImageForProfile:(NSImage*)imageForProfile{
 
    NSImage *preparedImage = imageForProfile;
    NSImageRep *rep = [[preparedImage representations] objectAtIndex:0];
    NSSize realImageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
    realImageHeight = realImageSize.height;
    realImageWidth = realImageSize.width;
    double frameWidth = currentPhoto.frame.size.width;
    double frameHeight = currentPhoto.frame.size.height;
   
   
    NSLog(@"RealImageWidth: %f RealImageHeight: %f", realImageWidth, realImageHeight);
    NSLog(@"ImageFrameWidth: %f ImageFrameHeight: %f", frameWidth, frameHeight);
    preparedImage.size=realImageSize;
    if (realImageWidth>realImageHeight){
         double deltaSize =  realImageHeight/(realImageHeight/current_photo_frame_size_width) - currentPhoto.frame.size.height;
         double deltaHeight = realImageHeight/realImageHeight;
        preparedImage = [preparedImage cropImageToSize:NSMakeSize(realImageHeight, realImageHeight) fromPoint:NSMakePoint(realImageHeight*0.15, 0)];
        NSImageRep *rep = [[preparedImage representations] objectAtIndex:0];
        NSSize realImageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
        realImageHeight = realImageSize.height;
        realImageWidth = realImageSize.width;
//        double frameWidth = currentPhoto.frame.size.width;
//        double frameHeight = currentPhoto.frame.size.height;
        preparedImage = [self resizedImage:preparedImage toPixelDimensions:NSMakeSize(realImageHeight/(realImageHeight/current_photo_frame_size_width), current_photo_frame_size_height * deltaHeight)];
        dispatch_async(dispatch_get_main_queue(), ^{
            currentPhoto.frame=NSMakeRect(currentPhoto.frame.origin.x,  currentPhoto.frame.origin.y-deltaSize, realImageHeight/(realImageHeight/current_photo_frame_size_width), current_photo_frame_size_height * deltaHeight);
        });
    }else{
         double deltaSize =  realImageHeight/(realImageWidth/current_photo_frame_size_width) - currentPhoto.frame.size.height;
         double deltaHeight = realImageHeight/realImageWidth;
        NSLog(@"Delta height: %f", deltaHeight);
        preparedImage = [self resizedImage:preparedImage toPixelDimensions:NSMakeSize(realImageWidth/(realImageWidth/current_photo_frame_size_width), current_photo_frame_size_height * deltaHeight)];
        dispatch_async(dispatch_get_main_queue(), ^{
            currentPhoto.frame=NSMakeRect(currentPhoto.frame.origin.x,  currentPhoto.frame.origin.y-deltaSize, realImageWidth/(realImageWidth/current_photo_frame_size_width), current_photo_frame_size_height * deltaHeight);
            NSLog(@"%f",currentPhoto.frame.origin.y);
           
        });
    }
   
    return preparedImage;
   
}
- (NSImage *)resizedImage:(NSImage *)sourceImage toPixelDimensions:(NSSize)newSize
{
    if (! sourceImage.isValid) return nil;
    
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
                             initWithBitmapDataPlanes:NULL
                             pixelsWide:newSize.width
                             pixelsHigh:newSize.height
                             bitsPerSample:8
                             samplesPerPixel:4
                             hasAlpha:YES
                             isPlanar:NO
                             colorSpaceName:NSCalibratedRGBColorSpace
                             bytesPerRow:0
                             bitsPerPixel:0];
    rep.size = newSize;
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:rep]];
    [sourceImage drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
    [NSGraphicsContext restoreGraphicsState];
    
    NSImage *newImage = [[NSImage alloc] initWithSize:newSize];
    [newImage addRepresentation:rep];
    return newImage;
}
- (NSImage *)imageResize:(NSImage*)anImage newSize:(NSSize)newSize {
    NSImage *sourceImage = anImage;

    // Report an error if the source isn't a valid image
    if (![sourceImage isValid]){
        NSLog(@"Invalid Image");
    } else {
        NSImage *smallImage = [[NSImage alloc] initWithSize: newSize];
//        [smallImage lockFocus];
        [sourceImage setSize: newSize];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
        [sourceImage drawAtPoint:NSZeroPoint fromRect:CGRectMake(0, 0, newSize.width, newSize.height) operation:NSCompositeCopy fraction:1.0];
//        [smallImage unlockFocus];
        return smallImage;
    }
    return nil;
}
- (IBAction)checkRepeatAction:(id)sender {
    if(checkRepeat.state==1){
        intervalField.enabled=YES;
    }
    else{
        intervalField.enabled=NO;
    }
}
- (void)setDataWithPhotoEffects:(NSNotification*)obj{
    contents = [NSData dataWithData:obj.userInfo[@"photo"]];
    [self uploadPhoto:uploadByURLCheck.state ? fieldWithURL.stringValue : filePath];

}
- (IBAction)uploadFile:(id)sender {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UploadProfilePhotoWithEffects" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setDataWithPhotoEffects:) name:@"UploadProfilePhotoWithEffects" object:nil];
    uploadByURLCheck.state ? nil : [self selectPhotoDialog];
    if(filePath || uploadByURLCheck.state ){
        owner=[userGroupsByAdminData[[userGroupsByAdminPopup indexOfSelectedItem]] isEqual:_app.person] || userGroupsByAdminData[[userGroupsByAdminPopup indexOfSelectedItem]] == nil ? _app.person : userGroupsByAdminData[[userGroupsByAdminPopup indexOfSelectedItem]];
        [self getServerUrl:owner completion:^(NSData *data) {
            if(data){
                NSDictionary *getServerResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if(getServerResponse[@"response"]){
                    serverUrl = getServerResponse[@"response"][@"upload_url"];
                    NSLog(@"%@", getServerResponse);
                    if(serverUrl){
                        //        NSLog(@"%@", serverUrl);
//                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                            [self uploadPhoto:uploadByURLCheck.state ? fieldWithURL.stringValue : filePath];
//                        });
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self openPhotoEffectsWindow];
                        });
                    }
                }
            }
        }];
    }
}
- (IBAction)userGroupsByAdminSelect:(id)sender {
    [self loadCurrentPhotoUserGroupByAdmin:[NSString stringWithFormat:@"%i", abs([userGroupsByAdminData[[userGroupsByAdminPopup indexOfSelectedItem]] intValue ])]];
}
- (void)openPhotoEffectsWindow{
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Sixth" bundle:nil];
    PhotoEffectsViewController *contr = [story instantiateControllerWithIdentifier:@"PhotoEffectsView"];
    contr.profilePhoto=YES;
    contr.originalImageURLs = @[[NSURL URLWithString: uploadByURLCheck.state ? fieldWithURL.stringValue : filePath]];
    [self presentViewControllerAsModalWindow:contr];
    NSLog(@"%@", filePath);
}
- (void)loadCurrentPhotoUserGroupByAdmin:(NSString*)groupId{
    if([groupId isEqual:_app.person]){
        
        [self loadCurrentPhoto];
    }else{
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.getById?group_id=%@&access_token=%@&v=%@", groupId, _app.token, _app.version]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(data){
                NSDictionary *getGroupCurrentPhotoResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if(getGroupCurrentPhotoResp[@"response"]){
                    for(NSDictionary *i in getGroupCurrentPhotoResp[@"response"]){
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            NSImage *image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:i[@"photo_200"]?i[@"photo_200"]:i[@"photo_100"]?i[@"photo_100"]:i[@"photo_50"]]];
                            NSImageRep *rep = [[image representations] objectAtIndex:0];
                            NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
                            image.size=imageSize;
                            
                            NSLog(@"%f %f",imageSize.width, imageSize.height);
                            //                        image = [self imageResize:image newSize:NSMakeSize(imageSize.width, imageSize.height)];
                            dispatch_async(dispatch_get_main_queue(), ^{
//                                currentPhoto.frame=NSMakeRect(currentPhoto.frame.origin.x, currentPhoto.bounds.origin.y+60, imageSize.width, imageSize.height);
                                [currentPhoto setImage:image];
                            });
                        });
                    }
                }else{
                    NSLog(@"Error get current group photo %@", groupId);
                }
            }
        }]resume];
    }
 
}
- (IBAction)selectFile:(id)sender {
    [self selectPhotoDialog];
    if(filePath){
        owner=[userGroupsByAdminData[[userGroupsByAdminPopup indexOfSelectedItem]] isEqual:_app.person] || userGroupsByAdminData[[userGroupsByAdminPopup indexOfSelectedItem]] == nil ? _app.person : userGroupsByAdminData[[userGroupsByAdminPopup indexOfSelectedItem]];
//        [self getServerUrl:owner];
    }
}
- (NSString*)createRandomName{
    NSString *alphabetPlusDigits = @"0123456789abcdefghijklmopqrstuvwxyz";
    int length =  (int) [alphabetPlusDigits length];
    
    NSMutableString *nonceString = [[NSMutableString alloc]init];
    for(NSInteger i=0; i<17; i++){
        i++;
        [nonceString appendString:[NSString stringWithFormat:@"%C", [alphabetPlusDigits characterAtIndex:arc4random_uniform(length)]]];
        
    }
    return [nonceString stringByAppendingPathExtension:@"jpg"];
}
- (void)uploadPhoto:(NSString *)file{
    if(file){
        NSLog(@"%@", file);
        NSURLSessionConfiguration *backgroundConfigurationObject = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"myBackgroundSessionIdentifier2"];
        backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfigurationObject delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        NSString *filename = [self createRandomName];

        
        if(!contents){
            contents=[[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:file]];
        }

//        NSImage *image = [[NSImage alloc] initWithData:contents];
        if(contents){
            NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:contents];
            NSData *data1 = [imageRep representationUsingType:NSPNGFileType properties:nil];
            NSMutableURLRequest *request = [_app getMutableURLRequestWithMultipartData:[NSURL URLWithString:serverUrl] filename:filename bodyData:data1 fformat:@"file"];
            
            NSURLSessionDataTask *uploadTask;
            progressUploadBar.hidden=NO;
            uploadTask = [backgroundSession dataTaskWithRequest:request];
            [uploadTask resume];
            
            
            //        [[_app.session uploadTaskWithRequest:request fromData:body completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            //            NSDictionary *uploadPhotoResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            //            NSLog(@"%@", uploadPhotoResponse);
            //
            //            if(![uploadPhotoResponse[@"photo"] isEqual:@""]){
            //                [ self saveOwnerPhoto:uploadPhotoResponse[@"server"] :uploadPhotoResponse[@"hash"] :uploadPhotoResponse[@"photo"] ];
            //            }
            //        }]resume];
        }
    }
}
- (void)getServerUrl:(NSString *)ownerId completion:(OnComplete)completion{
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/photos.getOwnerPhotoUploadServer?owner_id=%@&v=%@&access_token=%@", ownerId, _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        completion(data);
    }] resume];
}
- (void)selectPhotoDialog{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setAllowedFileTypes:[NSArray arrayWithObjects:@"jpg", @"png",@"jpeg",@"gif", nil]];
    if ( [openDlg runModal] == NSFileHandlingPanelOKButton){
        NSArray* files = [openDlg URLs];
        filePath = [files[0] absoluteString] ;
    }else{
        filePath=nil;
    }
}
- (void)saveOwnerPhoto:(NSString*)servera :(NSString*)hasha :(NSString *)photoa{
    if(!contents){
        if(uploadByURLCheck.state){
            contents =  [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:fieldWithURL.stringValue ]];
        }else{
            contents = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:filePath]];
        }
    }
    NSImage *image = [[NSImage alloc] initWithData:contents];
    NSImageRep *rep = [[image representations] objectAtIndex:0];
    NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
    image.size=imageSize;
    image = [self prepareImageForProfile:image];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/photos.saveOwnerPhoto?server=%@&hash=%@&photo=%@&v=%@&access_token=%@", servera,hasha,photoa, _app.version, _app.token]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data){
            NSDictionary *savePhotoResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if(savePhotoResponse[@"response"]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [currentPhoto setImage:image];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"loadProfileImage" object:nil userInfo:@{@"url":uploadByURLCheck.state ? fieldWithURL.stringValue : filePath, @"source":@"vk"}];
                    if(removeOld.state==1){
                        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/wall.get?owner_id=%@&count=1&v=%@&access_token=%@", owner, _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                            NSDictionary *wallGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                            if(wallGetResponse[@"response"]){
                                [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/wall.delete?owner_id=%@&post_id=%@&v=%@&access_token=%@", owner, wallGetResponse[@"response"][@"items"][0][@"id"], _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                    
                                }]resume];
                                sleep(1);
                                [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/photos.get?owner_id=%@&album_id=profile&v=%@&access_token=%@", owner, _app.version, _app.token]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                    NSDictionary *photosGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                    if([photosGetResponse[@"response"][@"count"] intValue]>=2){
                                        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/photos.delete?owner_id=%@&photo_id=%@&v=%@&access_token=%@", owner, photosGetResponse[@"response"][@"items"][0][@"id"], _app.version, _app.token]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                            NSDictionary *photosDeleteResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                            NSLog(@"%@", photosDeleteResponse[@"response"]);
                                            
                                        }]resume];
                                    }
                                }]resume];
                            }
                        }]resume];
                    }
                    
                    
                });
                
                NSLog(@"SAVE PHOTO RESPONSE %@", savePhotoResponse);
            }else{
                NSLog(@"ERROR SAVE PHOTO %@", savePhotoResponse[@"error"]);
            }
        }
    }] resume];
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    completionHandler(NSURLSessionResponseAllow);
    
    progressUploadBar.doubleValue=0;
    progressUploadBar.hidden=YES;
    filePathLabel.hidden=YES;
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
   didReceiveData:(NSData *)data {
    
    NSDictionary *uplData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSLog(@" UPLOAD DATA %@", uplData);
    [backgroundSession finishTasksAndInvalidate];
    [self saveOwnerPhoto:uplData[@"server"] :uplData[@"hash"] :uplData[@"photo"]];
    
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    progressUploadBar.maxValue = totalBytesExpectedToSend;
    progressUploadBar.doubleValue = totalBytesSent;
    
}
@end
