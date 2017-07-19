//
//  VKLoginViewController.m
//  vkapp
//
//  Created by sim on 17.07.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "VKLoginViewController.h"
#import "AppDelegate.h"
@interface VKLoginViewController ()<WebFrameLoadDelegate>
typedef void(^OnCompleteGetAppInfo)(NSDictionary *appData);
- (void)getAppInfo:(OnCompleteGetAppInfo)completion;
@end

@implementation VKLoginViewController
@synthesize superWindowController;
- (void)viewDidLoad {
    [super viewDidLoad];
    _app = [[appInfo alloc]init];
    _keyHandle = [[keyHandler alloc]init];
    self.view.wantsLayer=YES;
    self.view.layer.masksToBounds=YES;
    moc = ((AppDelegate*)[[NSApplication sharedApplication]delegate]).managedObjectContext;
    
    [appList removeAllItems];
    superWindow = [NSApplication sharedApplication].keyWindow;
    self.view.layer.cornerRadius = 10.0;
    _WebView.frameLoadDelegate=self;
    [self loadPopupAppList];
    [self setAdvancedOptions];
    [self setAppVersion:5.67];
    //    params = urlencode({
    //        'client_id' : "5040349",
    //        'scope' : "wall, offline, status, messages, ads, groups, notes, photos, video, docs, friends, audio",
    //        'redirect_url' : "https://oauth.vk.com/blank.html",
    //        'response_type':"token",
    //        'v' : "5.50",
    //        'display':"wap"
    //    })
}
- (void)viewDidAppear{
//    self.view.window.titleVisibility=NSWindowTitleHidden;
//    self.view.window.titlebarAppearsTransparent = YES;
//    self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
//    self.view.window.movableByWindowBackground=NO;
   
        //        if([_keyHandle readAppInfo:nil]){
        //            NSStoryboard *story = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
        //
        //            superWindowController = [story instantiateControllerWithIdentifier:@"SuperWindow"];
        //
        //            [superWindowController showWindow:self];
        //            [self.view.window close];
        //        }
    
    //    [self.view.window setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantDark]];
}
- (IBAction)selectAdvancedOptions:(id)sender {
//    NSLog(@"%li", [appList indexOfSelectedItem]);
    if([advancedOptions indexOfSelectedItem] == 2){
        app_id=apps[[appList indexOfSelectedItem]][@"appId"];
        NSLog(@"%@", app_id);
        [self authorizeApp];
    }else if([advancedOptions indexOfSelectedItem] == 1){
        app_id = apps[[appList indexOfSelectedItem]][@"appId"];
        title = apps[[appList indexOfSelectedItem]][@"title"];
        if( [_keyHandle removeApp:app_id appName:title]){
             [self loadPopupAppList];
        };
       
    }
}
- (void)setAdvancedOptions{
    [advancedOptions removeItemAtIndex:1];
    [advancedOptions removeItemAtIndex:1];
    [advancedOptions addItemWithTitle:@"Remove app"];
    [advancedOptions addItemWithTitle:@"Reset token"];
}
- (void)loadPopupAppList{
    apps = [_keyHandle readApps];
    if(apps){
        NSLog(@"%@", apps);
        [appList removeAllItems];
        for(NSDictionary *i in apps){
            [appList addItemWithTitle:i[@"title"]];
            if([i[@"selected"] intValue]){
                [appList selectItemAtIndex:[apps indexOfObject:i]];
            }
        }
        if(![appList selectedItem]){
            for(NSDictionary *i in apps){
                if([i[@"appId"]isEqual:app_id]){
                    [appList selectItemAtIndex:[apps indexOfObject:i]];
                }
            }
        }
    }
}
- (IBAction)popupAppsSelect:(id)sender {
    [_keyHandle storeSelectedAppInfo:apps[[appList indexOfSelectedItem]]];
    NSLog(@"%@", [apps objectAtIndex:[appList indexOfSelectedItem]]);
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateVkAppInfo" object:nil];
}
- (IBAction)addApp:(id)sender {
    if(![appId.stringValue isEqual:@""]){
        app_id=appId.stringValue;
        [self authorizeApp];
       
    }else{
        NSLog(@"Enter app id");
    }
}
- (IBAction)backToVkInfo:(id)sender {
    
    [self backToVkInfo];
}
-(void)backToVkInfo{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"backToInfo" object:nil userInfo:@{@"name":@"vkontakte"}];
}
- (void)setAppVersion:(float)vers{
    version = [NSString stringWithFormat:@"%.2f", vers];
}
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame{
    NSString *fullQuery = [[NSURL URLWithString:[[sender mainFrameURL] stringByReplacingOccurrencesOfString:@"#" withString:@"?"]]query];
    NSArray *queryComponents= [fullQuery componentsSeparatedByString:@"&"];
   
    if(queryComponents){
        if([queryComponents[0] containsString:@"access_token"]){
            _WebView.hidden=YES;
             NSLog(@"%@", queryComponents);
            token = [queryComponents[0] stringByReplacingOccurrencesOfString:@"access_token=" withString:@""];
//            NSLog(@"token: %@  app_id:%@", token, app_id);
            NSDictionary *objectAppInfo = @{@"appId":app_id, @"token":token, @"version":version, @"id":user_id, @"selected": [[appList itemArray] count]>0 ? [apps[[appList indexOfSelectedItem]][@"appId"] isEqual:app_id] ? @YES:@NO:@NO, @"icon":icon, @"author_url":authorUrl, @"desc":desc, @"title":title, @"screenName":screenName};
            if([_keyHandle writeAppInfo:objectAppInfo]){
                [[NSNotificationCenter defaultCenter]postNotificationName:@"updateVkAppInfo" object:nil];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"backToInfo" object:nil userInfo:@{@"name":@"vkontakte"}];
                [self loadPopupAppList];
                [progressLoad stopAnimation:self];
                NSLog(@"App %@ authorized sucessfully", title);
            };
        }else{
            NSLog(@"Access token not found.");
        }
    }
}

- (void)getAppInfo:(OnCompleteGetAppInfo)completion{
    [progressLoad startAnimation:self];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/apps.get?app_id=%@&extended=1&v=%@",app_id, version]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data){
            NSDictionary *getAppResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@", getAppResp);
            if(getAppResp[@"response"] && [getAppResp[@"response"][@"items"] lastObject]){
                completion(getAppResp[@"response"][@"items"][0]);
            }
        }
    }]resume];

//    [progressLoad startAnimation:self];


}
- (void)authorizeApp{
    [self getAppInfo:^(NSDictionary *appData) {
        if(appData){
            authorUrl = appData[@"author_url"];
            title = appData[@"title"];
            desc = appData[@"description"]!=[NSNull null] && ![appData[@"description"] isEqualToString:@""] ? appData[@"description"] : @"";
            user_id = [NSString stringWithFormat:@"%@", appData[@"author_id"]];
            screenName = appData[@"screen_name"];
            icon = appData[@"icon_150"];
            app_id = [NSString stringWithFormat:@"%@",appData[@"id"]];
            NSLog(@"%@ %@ %@ %@ %@ %@ %@", authorUrl, title, desc, user_id, screenName, icon, app_id);
        
            dispatch_async(dispatch_get_main_queue(),^{
                _WebView.hidden=YES;
                url = [NSString stringWithFormat:@"https://oauth.vk.com/authorize?client_id=%@&scope=wall,offline,status,messages,ads,groups,notes,photos,video,docs,friends,audio&redirect_url=%@&response_type=token&v=%@&display=wap", app_id, @"https://oauth.vk.com/blank.html", version];
                NSLog(@"%@", url);
                [[_WebView mainFrame]loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
                currentURL = [_WebView stringByEvaluatingJavaScriptFromString:@"window.location"];
                _WebView.hidden=NO;
            });
        }
    }];
}
- (IBAction)loginAction:(id)sender {

//    NSFetchRequest *request2 = [NSFetchRequest fetchRequestWithEntityName:@"VKAppInfo"];
//    [request2 setReturnsObjectsAsFaults:NO];
//    [request2 setResultType:NSDictionaryResultType];
//
//    NSArray *array2 = [moc executeFetchRequest:request2 error:&readError];
//    if(array2!=nil){
//
//    
//    }
    if(!self.view.superview){
        NSStoryboard *story = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
        
        superWindowController = [story instantiateControllerWithIdentifier:@"SuperWindow"];
        
        [superWindowController showWindow:self];
        [self.view.window close];
    }else{
        [self backToVkInfo];
    }
 
    
//    [_keyHandle readAppInfo:nil];
}

@end
