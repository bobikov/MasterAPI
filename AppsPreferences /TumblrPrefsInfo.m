//
//  TumblrPrefsInfo.m
//  MasterAPI
//
//  Created by sim on 14.10.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "TumblrPrefsInfo.h"

@interface TumblrPrefsInfo ()

@end

@implementation TumblrPrefsInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ObserveReadyTumblrTokens:) name:@"ObserveReadyTumblrTokens" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetTumblrAccessToken:) name:@"GetTumblrAccessToken" object:nil];
    _tumblrRWD = [[TumblrRWData alloc]init];
    NSDictionary *appData = [_tumblrRWD readTumblrTokens];
    consumerKey.stringValue=appData[@"consumer_key"];
    consumerSecret.stringValue=appData[@"consumer_secret_key"];
    secretToken.stringValue=appData[@"secret_token"];
    token.stringValue=appData[@"token"];
//    NSLog(@"%@", appData);
    tumblrAuth = [[TumblrAuth alloc]init];
}
-(void)GetTumblrAccessToken:(NSNotification *)notification{
    [tumblrAuth requestAccessTokenAndSecretToken:notification.userInfo[@"verifier"]];
}

-(void)ObserveReadyTumblrTokens:(NSNotification *)notification{
    NSLog(@"%@", notification.userInfo);
    NSManagedObjectContext *moc = [[[NSApplication sharedApplication ] delegate] managedObjectContext];
    NSError *readError;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TumblrAppInfo"];
    [request setReturnsObjectsAsFaults:NO];
    NSError *saveError;
    NSArray *array = [moc executeFetchRequest:request error:&readError];
    if(array!=nil){
        if([array count] == 0){
            NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"TumblrAppInfo" inManagedObjectContext:moc];
            [object setValue:notification.userInfo[@"oauth_token"] forKey:@"token"];
            [object setValue:notification.userInfo[@"oauth_token_secret"] forKey:@"secret_token"];
            [object setValue:notification.userInfo[@"consumer_key"] forKey:@"consumer_key"];
            [object setValue:notification.userInfo[@"consumer_secret_key"] forKey:@"consumer_secret_key"];
            if(![moc save:&saveError]){
                NSLog(@"Save and insert tumblr tokens error");
            }else{
                NSLog(@"Saved new tumblr tokens");
            }
        }else{
            
            for(NSManagedObject *managedObject in array) {
                [managedObject setValue:notification.userInfo[@"oauth_token"] forKey:@"token"];
                [managedObject setValue:notification.userInfo[@"oauth_token_secret"] forKey:@"secret_token"];
                if(![moc save:&saveError]){
                    NSLog(@"Update tumblr tokens error");
                }else{
                    NSLog(@"Tokens updated");
                }
            }
            
        }
    }
    
    
    [request setResultType:NSDictionaryResultType];
    NSArray *array2 = [moc executeFetchRequest:request error:&readError];
    if(array2 != nil){
        NSLog(@"READ TUMBLR TOKENS RESULT %@", array2);
    }
}

@end
