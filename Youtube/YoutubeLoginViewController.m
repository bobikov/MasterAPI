//
//  YoutubeLoginViewController.m
//  MasterAPI
//
//  Created by sim on 28/06/17.
//  Copyright © 2017 sim. All rights reserved.
//

#import "YoutubeLoginViewController.h"

@interface YoutubeLoginViewController ()

@end

@implementation YoutubeLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    RWData = [[YoutubeRWData alloc]init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ObserveReadyYoutubeTempToken:) name:@"ObserveReadyYoutubeTempToken" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetYoutubeAccessToken:) name:@"GetYoutubeAccessToken" object:nil];
    [self setFieldsEnabled];
    [self setButtonDest];
    
    
}
-(void)setButtonDest{
    if([RWData YoutubeTokensEcxistsInCoreData]){
        removeAndAddButton.title=@"Remove app";
        
        
    }else{
        removeAndAddButton.title = @"Add app";
    }
    
}
- (IBAction)backToPrefsInfo:(id)sender {
     [[NSNotificationCenter defaultCenter]postNotificationName:@"backToInfo" object:nil userInfo:@{@"name":@"youtube"}];
}
- (IBAction)removeAndAdd:(id)sender {
    if([RWData YoutubeTokensEcxistsInCoreData]){
        [progress startAnimation:self];
        [RWData removeAllYoutubeAppInfo:^(BOOL removeAppResult) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setButtonDest];
                [self setFieldsEnabled];
                [progress stopAnimation:self];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshYoutubeParamsInFields" object:nil];
            });
        }];
    }else{
        [self addApp];
    }
    
}
-(void)addApp{
    [progress startAnimation:self];
    youtubeAuth=[[YoutubeAuth alloc]initWithParams:clientId.stringValue client_secret:clientSecret.stringValue];
    [youtubeAuth requestTempToken];
}

- (IBAction)resetToken:(id)sender {
    
    
}
-(void)setFieldsEnabled{
    clientId.enabled=![RWData YoutubeTokensEcxistsInCoreData];
    clientSecret.enabled=![RWData YoutubeTokensEcxistsInCoreData];
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
    NSLog(@"%@", array);
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setFieldsEnabled];
            [self setButtonDest];
            [progress stopAnimation:self];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshYoutubeParamsInFields" object:nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"backToInfo" object:nil userInfo:@{@"name":@"youtube"}];
       
        });
    }
    
    
    [request setResultType:NSDictionaryResultType];
    NSArray *array2 = [moc executeFetchRequest:request error:&readError];
    if(array2 != nil){
        NSLog(@"READ YOUTUBE TOKENS RESULT %@", array2);
    }
    
}

@end
