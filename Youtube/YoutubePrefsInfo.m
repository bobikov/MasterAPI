//
//  YoutubePrefsInfo.m
//  MasterAPI
//
//  Created by sim on 14.10.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "YoutubePrefsInfo.h"

@interface YoutubePrefsInfo ()

@end

@implementation YoutubePrefsInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ObserveReadyYoutubeTempToken:) name:@"ObserveReadyYoutubeTempToken" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetYoutubeAccessToken:) name:@"GetYoutubeAccessToken" object:nil];
    youtubeRWD = [[YoutubeRWData alloc]init];
   NSDictionary *appData = [youtubeRWD readYoutubeTokens];
    clientId.stringValue=appData[@"client_id"];
    accessToken.stringValue=appData[@"access_token"];
    clientSecret.stringValue=appData[@"client_secret"];
    refreshToken.stringValue=appData[@"refresh_token"];
    youtubeAuth = [[YoutubeAuth alloc]init];
//    NSLog(@"%@", appData);
}
-(void)GetYoutubeAccessToken:(NSNotification*)notification{
    [youtubeAuth requestAccessToken:notification.userInfo[@"code"]];
}
-(void)ObserveReadyYoutubeTempToken:(NSNotification*)notification{
    
    //    NSLog(@"%@", notification.userInfo);
    NSManagedObjectContext *moc = [[[NSApplication sharedApplication ] delegate] managedObjectContext];
    NSError *readError;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"YoutubeAppInfo"];
    [request setReturnsObjectsAsFaults:NO];
    NSError *saveError;
    NSArray *array = [moc executeFetchRequest:request error:&readError];
    if(array!=nil){
        if([array count] == 0){
            NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"YoutubeAppInfo" inManagedObjectContext:moc];
            [object setValue:notification.userInfo[@"access_token"] forKey:@"access_token"];
            [object setValue:notification.userInfo[@"refresh_token"] forKey:@"refresh_token"];
            [object setValue:notification.userInfo[@"client_id"] forKey:@"client_id"];
            [object setValue:notification.userInfo[@"client_secret"] forKey:@"client_secret"];
            [object setValue:notification.userInfo[@"token_type"] forKey:@"token_type"];
            if(![moc save:&saveError]){
                NSLog(@"Save and insert youtube tokens error");
            }else{
                NSLog(@"Saved new youtube tokens");
            }
        }else{
            
            for(NSManagedObject *managedObject in array) {
                [managedObject setValue:notification.userInfo[@"access_token"] forKey:@"access_token"];
                //                [managedObject setValue:notification.userInfo[@"client_"] forKey:@"secret_token"];
                if(![moc save:&saveError]){
                    NSLog(@"Update youtube tokens error");
                }else{
                    NSLog(@"Youtube tokens updated");
                }
            }
            
        }
    }
    
    
    [request setResultType:NSDictionaryResultType];
    NSArray *array2 = [moc executeFetchRequest:request error:&readError];
    if(array2 != nil){
        NSLog(@"READ YOUTUBE TOKENS RESULT %@", array2);
    }
    
}
@end
