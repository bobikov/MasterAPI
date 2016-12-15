//
//  VKLoginViewController.m
//  vkapp
//
//  Created by sim on 17.07.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "VKLoginViewController.h"

@interface VKLoginViewController ()<WebFrameLoadDelegate>

@end

@implementation VKLoginViewController
@synthesize superWindowController;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.view.wantsLayer=YES;
    self.view.layer.masksToBounds=YES;
    _app = [[appInfo alloc]init];
    [appList removeAllItems];
//    self.view.layer.backgroundColor=[[NSColor whiteColor]CGColor];
     superWindow = [NSApplication sharedApplication].keyWindow;
//    [superWindow setStyleMask:NSBorderlessWindowMask];
//    [superWindow setMovableByWindowBackground:TRUE];
     self.view.layer.cornerRadius = 10.0;
    _WebView.frameLoadDelegate=self;
    [self loadPopupAppList];
     _keyHandle = [[keyHandler alloc]init];
    
//    params = urlencode({
//        'client_id' : "5040349",
//        'scope' : "wall, offline, status, messages, ads, groups, notes, photos, video, docs, friends, audio",
//        'redirect_url' : "https://oauth.vk.com/blank.html",
//        'response_type':"token",
//        'v' : "5.50",
//        'display':"wap"
//    })
    

}

-(void)loadPopupAppList{
    NSManagedObjectContext *moc = [[[NSApplication sharedApplication]delegate] managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VKAppInfo"];
    [request setReturnsObjectsAsFaults:NO];
    [request setResultType:NSDictionaryResultType];
    NSError *readError;
    NSArray *array = [moc executeFetchRequest:request error:&readError];
//    NSLog(@"%@", array);
    if(array!=nil){
        apps = array;
        for(NSDictionary *i in apps){
            [appList addItemWithTitle:i[@"title"]];
        }
      
    }
    
}
- (IBAction)popupAppsSelect:(id)sender {
    
    NSLog(@"%@", [apps objectAtIndex:[appList indexOfSelectedItem]]);

}
- (IBAction)addApp:(id)sender {
    
    [self getAppInfo];
}
-(void)viewDidAppear{
    self.view.window.titleVisibility=NSWindowTitleVisible;
    self.view.window.titlebarAppearsTransparent = YES;
    self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
    self.view.window.movableByWindowBackground=YES;
    if(rememberApp.state==1){
//        if([_keyHandle readAppInfo:nil]){
//            NSStoryboard *story = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
//            
//            superWindowController = [story instantiateControllerWithIdentifier:@"SuperWindow"];
//            
//            [superWindowController showWindow:self];
//            [self.view.window close];
//        }
    }
//    [self.view.window setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantDark]];
}
-(void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame{
    NSString *fullQuery = [[NSURL URLWithString:[[sender mainFrameURL] stringByReplacingOccurrencesOfString:@"#" withString:@"?"]]query];
    NSArray *queryComponents= [fullQuery componentsSeparatedByString:@"&"];
    NSLog(@"%@", queryComponents);
    if([queryComponents[0] containsString:@"access_token"]){
        token = [queryComponents[0] stringByReplacingOccurrencesOfString:@"access_token=" withString:@""];
         NSLog(@"%@ %@", token, app_id);
        
        [_keyHandle writeAppInfo:@{@"appId":app_id, @"token":token, @"version":version, @"id":user_id, @"selected":@NO, @"icon":icon, @"author_url":authorUrl, @"desc":desc, @"title":title, @"screenName":screenName}];
        if([_keyHandle readAppInfo:app_id]){
            
 
            [self loadPopupAppList];
            [progressLoad stopAnimation:self];
        }
    }else{
        NSLog(@"Access token not found.");
    }
   
}
-(void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame{
//     NSLog(@"%@",@"dsfsdf");
}
-(void)getAppInfo{
//    NSLog(@"23424");
//      NSLog(@"%@", [NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/apps.get?app_id=%@&extended=1&v=5.53",appId.stringValue]]);
    [progressLoad startAnimation:self];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/apps.get?app_id=%@&extended=1&v=5.57",appId.stringValue]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *getAppResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"%@", getAppResp[@"response"]);
        for(NSDictionary *i in getAppResp[@"response"][@"items"]){
            authorUrl = i[@"author_url"];
            title = i[@"title"];
            desc = i[@"description"];
            user_id = [NSString stringWithFormat:@"%@", i[@"author_id"]];
            screenName = i[@"screen_name"];
            icon = i[@"icon_150"];
            app_id = [NSString stringWithFormat:@"%@",i[@"id"]];
            NSLog(@"%@ %@ %@ %@ %@ %@ %@", authorUrl, title, desc, user_id, screenName, icon, app_id);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [progressLoad stopAnimation:self];
//            });
            
        }
    }]resume];
    sleep(1);
//    [progressLoad startAnimation:self];
    if(![appId.stringValue isEqual:@""] ){
        _WebView.hidden=YES;
         version = [NSString stringWithFormat:@"%.2f", 5.57];
        url = [NSString stringWithFormat:@"https://oauth.vk.com/authorize?client_id=%@&scope=wall,offline,status,messages,ads,groups,notes,photos,video,docs,friends,audio&redirect_url=%@&response_type=token&v=%@&display=wap", appId.stringValue, @"https://oauth.vk.com/blank.html", version];
        [[_WebView mainFrame]loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        
       
        
        currentURL = [_WebView stringByEvaluatingJavaScriptFromString:@"window.location"];
    }else{
        NSLog(@"Enter app id, please.");
    }

}
- (IBAction)loginAction:(id)sender {

    NSManagedObjectContext *moc = [[[NSApplication sharedApplication]delegate] managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VKAppInfo"];
    [request setReturnsObjectsAsFaults:NO];
    NSError *readError;
    NSArray *array = [moc executeFetchRequest:request error:&readError];
    NSError *saveError;
    if(array!=nil){
//        for(NSManagedObject *managedObject in array){
//            [managedObject setValue:@NO forKey:@"selected"];
//            if(![moc save:&saveError]){
//                NSLog(@"Error update vkappinfo");
//            }else{
//                NSLog(@"Saved");
//            }
//        }
//        for(NSManagedObject *managedObject in array){
//            [managedObject setValue:@NO forKey:@"selected"];
//            if(![moc save:&saveError]){
//                NSLog(@"Error update vkappinfo");
//            }else{
//                NSLog(@"Saved");
//            }
//        }
        [[array objectAtIndex:[appList indexOfSelectedItem]] setValue:@YES forKey:@"selected"];
        
        if(![moc save:&saveError]){
            NSLog(@"Error update vkappinfo");
        }else{
            
            NSLog(@"Saved");
        }
        NSFetchRequest *request3 = [NSFetchRequest fetchRequestWithEntityName:@"VKAppInfo"];
        [request3 setReturnsObjectsAsFaults:NO];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"appId!=%@", [apps objectAtIndex:[appList indexOfSelectedItem]][@"appId"]];
        [request3 setPredicate:predicate];
        NSError *readError3;
        NSError *saveError3;
        NSArray *array3 = [moc executeFetchRequest:request3 error:&readError3];
        for(NSManagedObject *managedObject in array3){
            [managedObject setValue:@NO forKey:@"selected"];
            if(![moc save:&saveError3]){
                NSLog(@"Set selected to 0 error");
            }else{
                NSLog(@"Set selected to 1 sucessfull");
            }
        }
        
        
    }
    NSFetchRequest *request2 = [NSFetchRequest fetchRequestWithEntityName:@"VKAppInfo"];
    [request2 setReturnsObjectsAsFaults:NO];
    [request2 setResultType:NSDictionaryResultType];
//    NSError *readError2;
    NSArray *array2 = [moc executeFetchRequest:request2 error:&readError];
    if(array2!=nil){
//        NSLog(@"%@", array2);
    
    }
    if([_keyHandle readAppInfo:nil]){
        NSStoryboard *story = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
        
        superWindowController = [story instantiateControllerWithIdentifier:@"SuperWindow"];
        
        [superWindowController showWindow:self];
        [self.view.window close];
    }
//    [_keyHandle readAppInfo:nil];
}

@end
