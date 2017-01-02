//
//  ProfilePhotoChangeViewController.m
//  vkapp
//
//  Created by sim on 23.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "ProfilePhotoChangeViewController.h"

@interface ProfilePhotoChangeViewController () <NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>

@end

@implementation ProfilePhotoChangeViewController
@synthesize backgroundSession;
- (void)viewDidLoad {
    [super viewDidLoad];
    _app = [[appInfo alloc]init];
    progressUploadBar.hidden=YES;
    currentPhoto.wantsLayer=YES;
    currentPhoto.layer.masksToBounds=YES;
    currentPhoto.layer.cornerRadius=4;
    [progressSpin startAnimation:self];
    intervalField.enabled=NO;
    filePathLabel.hidden=YES;
    userGroupsByAdminData = [[NSMutableArray alloc]init];
    [self loadGroupsByAdminPopup];
}
-(void)loadGroupsByAdminPopup{
    __block NSMenuItem *menuItem;
    __block NSMenu *menu1 = [[NSMenu alloc]init];
    [userGroupsByAdminPopup removeAllItems];
    [userGroupsByAdminData addObject:_app.person];
    viewControllerItem = [[ViewControllerMenuItem alloc]initWithNibName:@"ViewControllerMenuItem" bundle:nil];
    [viewControllerItem loadView];
    menuItem = [[NSMenuItem alloc]initWithTitle:@"Personal" action:nil keyEquivalent:@""];
    [menu1 addItem:menuItem];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.get?user_id=%@&filter=admin&extended=1&access_token=%@&v=%@", _app.person, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *groupsGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        for(NSDictionary *i in groupsGetResponse[@"response"][@"items"]){
            [userGroupsByAdminData addObject:[NSString stringWithFormat:@"-%@",i[@"id"]]];
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
            [menuItem setView:[viewControllerItem view]];
            [menu1 addItem:menuItem];
        }
        dispatch_async(dispatch_get_main_queue(),^{
            [userGroupsByAdminPopup setMenu:menu1];
        });
    }]resume];
}

-(void)viewDidAppear{
    
    [self loadCurrentPhoto];
}
- (IBAction)loadByURLCheckAction:(id)sender {
    if(uploadByURLCheck.state){
        fieldWithURL.hidden=NO;
    }else{
        fieldWithURL.hidden=YES;
    }
}
-(void)loadCurrentPhoto{
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/users.get?user_ids=%@&fields=crop_photo&v=%@&access_token=%@", _app.person, _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data){
            NSDictionary *photoGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if(photoGetResponse[@"response"]){
                NSImage *photoI = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:photoGetResponse[@"response"][0][@"crop_photo"][@"photo"][@"photo_604"]]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //                currentPhoto.frame = NSMakeRect([photoGetResponse[@"response"][0][@"crop_photo"][@"photo"][@"width"] intValue], [photoGetResponse[@"response"][0][@"crop_photo"][@"photo"][@"heigth"] intValue], 0,0);
                    [currentPhoto setImage:photoI];
                    [progressSpin stopAnimation:self];
                });
                
            }
        }
    }] resume];
}
- (IBAction)checkRepeatAction:(id)sender {
    if(checkRepeat.state==1){
        intervalField.enabled=YES;
    }
    else{
        intervalField.enabled=NO;
    }
}
- (IBAction)uploadFile:(id)sender {
    
    uploadByURLCheck.state ? nil : [self selectedPhoto];
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
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            [self uploadPhoto:uploadByURLCheck.state ? fieldWithURL.stringValue : filePath];
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
-(void)loadCurrentPhotoUserGroupByAdmin:(NSString*)groupId{
    if([groupId isEqual:_app.person]){
        [self loadCurrentPhoto];
    }else{
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.getById?group_id=%@&access_token=%@&v=%@", groupId, _app.token, _app.version]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary *getGroupCurrentPhotoResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if(getGroupCurrentPhotoResp[@"response"]){
                for(NSDictionary *i in getGroupCurrentPhotoResp[@"response"]){
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        NSImage *image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:i[@"photo_200"]?i[@"photo_200"]:i[@"photo_100"]?i[@"photo_100"]:i[@"photo_50"]]];
                        NSImageRep *rep = [[image representations] objectAtIndex:0];
                        NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
                        image.size=imageSize;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [currentPhoto setImage:image];
                        });
                    });
                }
            }else{
                NSLog(@"Error get current group photo %@", groupId);
            }
        }]resume];
    }
 
}
- (IBAction)selectFile:(id)sender {
    [self selectedPhoto];
    if(filePath){
        owner=[userGroupsByAdminData[[userGroupsByAdminPopup indexOfSelectedItem]] isEqual:_app.person] || userGroupsByAdminData[[userGroupsByAdminPopup indexOfSelectedItem]] == nil ? _app.person : userGroupsByAdminData[[userGroupsByAdminPopup indexOfSelectedItem]];
//        [self getServerUrl:owner];
    }
}
-(NSString*)createRandomName{
    NSString *alphabetPlusDigits = @"0123456789abcdefghijklmopqrstuvwxyz";
    int length =  (int) [alphabetPlusDigits length];
    
    NSMutableString *nonceString = [[NSMutableString alloc]init];
    for(NSInteger i=0; i<17; i++){
        i++;
        [nonceString appendString:[NSString stringWithFormat:@"%C", [alphabetPlusDigits characterAtIndex:arc4random_uniform(length)]]];
        
    }
    return [nonceString stringByAppendingPathExtension:@"jpg"];
}
-(void)uploadPhoto:(NSString *)file{
    if(file){
        NSLog(@"%@", file);
        NSURLSessionConfiguration *backgroundConfigurationObject = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"myBackgroundSessionIdentifier2"];
        backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfigurationObject delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        NSString *filename = [self createRandomName];

        NSData *contents;
     
        contents=[[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:file]];

//        NSImage *image = [[NSImage alloc] initWithData:contents];
        if(contents){
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:serverUrl]];
            NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:contents];
            NSData *data1 = [imageRep representationUsingType:NSPNGFileType properties:nil];
            
            [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
            
            [request setTimeoutInterval:30];
            [request setHTTPMethod:@"POST"];
            
            NSString *kStringBoundary = @"*******";
            [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",kStringBoundary] forHTTPHeaderField:@"Content-Type"];
            NSString *beginLine = [NSString stringWithFormat:@"\r\n--%@\r\n", kStringBoundary];
            NSMutableData *body = [NSMutableData data];
            [body appendData:[beginLine dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n",filename] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Length: %d\r\n\r\n",(int)[data1 length]] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:data1];
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", kStringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [request setHTTPBody:body];
            
            
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
-(void)getServerUrl:(NSString *)ownerId completion:(OnComplete)completion{
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/photos.getOwnerPhotoUploadServer?owner_id=%@&v=%@&access_token=%@", ownerId, _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        completion(data);
       

    }] resume];

}

-(void)selectedPhoto{
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
-(void)saveOwnerPhoto:(NSString*)servera :(NSString*)hasha :(NSString *)photoa{
    NSData *contents;
    if(uploadByURLCheck.state){
        contents =  [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:fieldWithURL.stringValue ]];
    }else{
        contents = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:filePath]];
    }
    NSImage *image = [[NSImage alloc] initWithData:contents];
    NSImageRep *rep = [[image representations] objectAtIndex:0];
    NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
    image.size=imageSize;
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/photos.saveOwnerPhoto?server=%@&hash=%@&photo=%@&v=%@&access_token=%@", servera,hasha,photoa, _app.version, _app.token]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data){
            NSDictionary *savePhotoResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if(savePhotoResponse[@"response"]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [currentPhoto setImage:image];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"loadProfileImage" object:nil userInfo:@{@"url":uploadByURLCheck.state ? fieldWithURL.stringValue : filePath}];
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
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
   didReceiveData:(NSData *)data {
    
    NSDictionary *uplData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSLog(@" UPLOAD DATA %@", uplData);
    [backgroundSession finishTasksAndInvalidate];
    [self saveOwnerPhoto:uplData[@"server"] :uplData[@"hash"] :uplData[@"photo"]];
    
}
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    progressUploadBar.maxValue = totalBytesExpectedToSend;
    progressUploadBar.doubleValue = totalBytesSent;
    
}
@end
