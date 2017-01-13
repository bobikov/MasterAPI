//
//  createNewVideoAlbumController.m
//  vkapp
//
//  Created by sim on 06.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "createNewVideoAlbumController.h"

@interface createNewVideoAlbumController ()

@end

@implementation createNewVideoAlbumController

- (void)viewDidLoad {
    [super viewDidLoad];
    _app = [[appInfo alloc]init];
    self.view.wantsLayer=YES;
    self.view.layer.masksToBounds=YES;
    self.view.layer.backgroundColor=[[NSColor colorWithCalibratedRed:0.90 green:0.90 blue:0.90 alpha:0.0]CGColor];
    groupsByAdminSelectorData = [[NSMutableArray alloc]init];
    [groupsByAdminPopupSelector removeAllItems];
    [groupsByAdminPopupSelector addItemWithTitle:@"Personal"];
    [groupsByAdminSelectorData addObject:_app.person];
    [self loadGroupsByAdminPopup];
//    owner = _receivedDataForNewAlbum[@"owner"];
    _captchaHandle = [[VKCaptchaHandler alloc]init];
    _ownerInMainVideoController = [NSString stringWithFormat:@"%i", abs([_ownerInMainVideoController intValue])];
    newAlbumTitle.stringValue = _selectedAlbumNames ? _selectedAlbumNames : @"";
//    self.view.layer.
//    NSVisualEffectView* vibrantView = [[NSVisualEffectView alloc] initWithFrame:self.view.frame];
//    vibrantView.material=NSVisualEffectMaterialSidebar;
//    
//    vibrantView.blendingMode=NSVisualEffectBlendingModeBehindWindow;
//    
//    
//    //    vibrantView.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
//    //    vibrantView.wantsLayer=YES;
//    self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
//    [vibrantView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
//    
//    [self.view addSubview:vibrantView positioned:NSWindowBelow relativeTo:self.view];

}
-(void)loadGroupsByAdminPopup{
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.get?user_id=%@&filter=admin&extended=1&access_token=%@&v=%@", _app.person, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *groupsGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        for(NSDictionary *i in groupsGetResponse[@"response"][@"items"]){
            [groupsByAdminSelectorData addObject:[NSString stringWithFormat:@"-%@",i[@"id"]]];
            [groupsByAdminPopupSelector addItemWithTitle:i[@"name"]];
        }
    }]resume];
}
- (IBAction)selectPrivacy:(id)sender {
    
    
}
- (IBAction)selectGroupsByAdminPopup:(id)sender {
    NSInteger index = [groupsByAdminPopupSelector indexOfSelectedItem];
    owner = [NSString stringWithFormat:@"%i",abs([groupsByAdminSelectorData[index] intValue])];
}
-(void)setProgressStatus{
    progressBar.maxValue = [albumNames count];
    progressBar.doubleValue = albumNamesCounter;
}
- (IBAction)createAlbum:(id)sender {
    __block void (^createMultiAlbums)( BOOL, NSInteger, NSString *, NSString *);
    __block void (^createOneAlbum)( BOOL, NSString *, NSString *);
    __block NSString *privacy;
    __block NSString *url;
    owner = owner == nil ? _app.person : owner;
    if(radioAll.state==1){
        privacy = @"all";
    }
    if(radioFriends.state==1){
        privacy= @"friends";
    }
    if(radioNobody.state==1){
        privacy =@"nobody";
    }
    albumNamesCounter=0;
    createMultiAlbums = ^void(BOOL captcha, NSInteger offset, NSString *captcha_key, NSString *captcha_sid){
        stopFlag=NO;
        albumNames = [newAlbumTitle.stringValue componentsSeparatedByString:@","];
        albumNamesCounter = offset ? offset - 1  : albumNamesCounter;
        while (albumNamesCounter < [albumNames count]){
            albumName = [albumNames[albumNamesCounter] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
//           semaphore = dispatch_semaphore_create(0);
            if(!owner || [owner isEqual:_app.person]){
                url =[NSString stringWithFormat:@"https://api.vk.com/method/video.addAlbum?title=%@&privacy=%@&access_token=%@&v=%@%@",   albumName, privacy, _app.token, _app.version, captcha ?[NSString stringWithFormat:@"&captcha_sid=%@&captcha_key=%@", captcha_sid, captcha_key ] : @""];
            }else{
                url = [NSString stringWithFormat:@"https://api.vk.com/method/video.addAlbum?group_id=%@&title=%@&access_token=%@&upload_by_admins_only=0&description=test&v=%@%@", [NSString stringWithFormat:@"%i",abs([owner intValue])], albumName, _app.token, _app.version, captcha ?[NSString stringWithFormat:@"&captcha_sid=%@&captcha_key=%@", captcha_sid, captcha_key ] : @""];
            }
            [[_app.session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *createAlbumResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                 NSLog(@"%@", createAlbumResponse);
                if(createAlbumResponse[@"response"]){
                    albumNamesCounter++;
                    dispatch_async(dispatch_get_main_queue(),^{
                        [self setProgressStatus];
                    });
                    if (albumNamesCounter==[albumNames count]){
                        dispatch_async(dispatch_get_main_queue(),^{
                            [self dismissController:self];
                        });
                        dispatch_after(1, dispatch_get_main_queue(), ^(void){
                            [[NSNotificationCenter defaultCenter]postNotificationName:@"createVideoAlbumReload" object:nil userInfo:@{@"reload":[owner isEqual:_ownerInMainVideoController]?@1:@0}];
                        });
                    
                    }
                }else if(createAlbumResponse[@"error"]){
                    if([createAlbumResponse[@"error"][@"error_code"] intValue] == 14){
                        if(!stopFlag){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSInteger result = [[_captchaHandle handleCaptcha:createAlbumResponse[@"error"][@"captcha_img"]] runModal];
                                if(result == NSAlertFirstButtonReturn){
                                    stopFlag=YES;
                                    
                                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                        createMultiAlbums(YES, albumNamesCounter, _captchaHandle.enterCode.stringValue, createAlbumResponse[@"error"][@"captcha_sid"]);
                                    });
                                }
                            });
                        }
                    }
                }
            }]resume];
            sleep(1);
//            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//            dispatch_semaphore_signal(semaphore);
            if(stopFlag){
                break;
            }
        }
    };
    createOneAlbum = ^void(BOOL captcha, NSString *captcha_key, NSString *captcha_sid){
        NSString *titleAlbum = [NSString stringWithFormat:@"%@", newAlbumTitle.stringValue];
        titleAlbum = [titleAlbum stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        if(!owner || [owner isEqual:_app.person]){
            url =[NSString stringWithFormat:@"https://api.vk.com/method/video.addAlbum?title=%@&privacy=%@&access_token=%@&v=%@",   titleAlbum, privacy, _app.token, _app.version];
        }else{
            url = [NSString stringWithFormat:@"https://api.vk.com/method/video.addAlbum?group_id=%@&title=%@&access_token=%@&upload_by_admins_only=0&description=test&v=%@", owner,  titleAlbum, _app.token, _app.version];
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"createVideoAlbumReload" object:nil userInfo:@{@"reload":[owner isEqual:_app.person]?@1:@0}];
    };
    if(multiple.state){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            createMultiAlbums(NO, 0, @"", @"");
        });
    }else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            createOneAlbum(NO, @"", @"");
        });
    }
}

@end
