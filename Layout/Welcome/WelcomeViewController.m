//
//  WelcomeViewController.m
//  vkapp
//
//  Created by sim on 20.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    segment.wantsLayer=YES;
//    segment.layer.masksToBounds=YES;
//
//    [segment.layer setBackgroundColor:(__bridge CGColorRef _Nullable)([NSColor clearColor])];
    _app = [[appInfo alloc]init];
    counterd =444;
   
}
-(void)viewDidAppear{
//    [self longPollMessages];
}

- (IBAction)radioAction:(id)sender {
    NSLog(@"%@", radio);
}




-(void)playMessageReceiveSound {
//    NSFileManager *manager = [[NSFileManager alloc]init];
    NSBundle* mainBundle;
    mainBundle = [NSBundle mainBundle];
//    NSString *soundFilePath = [NSString stringWithFormat:@"%@.mp3", @"BEEP"];
    NSURL *soundFileURL = [NSURL fileURLWithPath:[mainBundle pathForResource:@"WOO" ofType:@"mp3"]];
    
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL
                                                     error:nil];
    _player.numberOfLoops = 0;
    
    [_player play];
}
-(void)longPollMessages{
    __block void (^startLong)();
    __block void(^getServerParams)();
//    __block BOOL stopped=NO;
    getServerParams = ^(){
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/messages.getLongPollServer?need_pts=1&use_ssl=1&v=%@&access_token=%@", _app.version, _app.token]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(data){
                if(error){
                    NSLog(@"dataTaskWithUrl error: %@", error);
                    return;
                }
                else{
                    
                    
                }
                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                    
                    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                    
                    if (statusCode != 200) {
                        NSLog(@"dataTaskWithRequest HTTP status code: %lu", statusCode);
                        return;
                    }
                    else{
                        
                        
                    }
                    
                    
                }
                NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if(jsonData[@"error"]){
                    NSLog(@"%@", jsonData[@"error"][@"error_msg"]);
                }
                else{
                    NSLog(@"%@", jsonData);
                    serverTs = [NSString stringWithFormat:@"%@", jsonData[@"response"][@"ts"]];
                    serverBaseUrl = [NSString stringWithFormat:@"%@", jsonData[@"response"][@"server"]];
                    serverKey = [NSString stringWithFormat:@"%@", jsonData[@"response"][@"key"]];
                    //            NSString *pts = [NSString stringWithFormat:@"%@", jsonData[@"response"][@"pts"]];
                    serverUrl= [NSString stringWithFormat:@"http://%@?act=a_check&key=%@&ts=%@&wait=25&mode=2", serverBaseUrl, serverKey, serverTs];
                }
            }
        }] resume];
        
    };
    getServerParams();
    sleep(1);
    startLong = ^void (){
        __block NSString *fromId;
        __block NSString *messageId;
        __block BOOL stopped;
        stopped=NO;
        if(serverKey && serverTs && serverUrl && serverBaseUrl){
//        __block NSString *myTextForMessage = @"Write me later bird.";
            
            NSURLSessionDataTask *superLong =[ _app.session dataTaskWithURL:[NSURL URLWithString:serverUrl]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
                if(error){
                    NSLog(@"dataTaskWithUrl error: %@", error);
                    stopped=YES;
                    return;
                }
                
                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                    
                    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                    
                    if (statusCode != 200) {
                        NSLog(@"dataTaskWithRequest HTTP status code: %lu", statusCode);
//                        stopped=YES;
                        return;
                    }
                    else{
                       
                        
                    }
                }
                
                NSDictionary *serverData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (serverData[@"error"]){
                    NSLog(@"%@", serverData[@"error"][@"error_msg"]);
                }
                else if(serverData[@"failed"]){
                    if([serverData[@"failed"] intValue] == 1){
                        stopped = YES;
                         NSLog(@"%@", serverData[@"failed"]);
                        getServerParams();
                        sleep(1);
                        stopped=NO;
                        startLong();
                       
                    }
                    //
                }
                for (NSArray *i in serverData[@"updates"]){
                    NSString *updatesData = [NSString stringWithFormat:@"%@", i[0]];
                    if([updatesData isEqualToString:@"4"] ){
                        double timestamp = [i[4] intValue];
                        NSString *messageDate;
                        NSTimeInterval myDateTodayInterval = [[NSDate date] timeIntervalSince1970];
                        NSDate *messageDateFromInterval = [[NSDate alloc]initWithTimeIntervalSince1970:timestamp];
                        NSDate *myDateTodayFromTimestamp = [[NSDate alloc] initWithTimeIntervalSince1970: myDateTodayInterval];
                        NSString *myTodayDateString;
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        NSString *template= @"mm:ss";
                        [formatter setLocale:[[NSLocale alloc ] initWithLocaleIdentifier:@"ru"]];
                        [formatter setDateFormat:template];
                        messageDate = [NSString stringWithFormat:@"%@", [formatter stringFromDate:messageDateFromInterval]];
                        myTodayDateString = [NSString stringWithFormat:@"%@",  [formatter stringFromDate:myDateTodayFromTimestamp]];
                        if ([messageDate isEqualToString:myTodayDateString]){
//                            NSString *receivedMessage = [NSString stringWithFormat:@"%@", i[6]];
                          
                            messageId = i[1];
                            fromId = i[3];
                            NSLog(@"Message from: %@", fromId);
                            NSLog(@"Text of message:%@\n", i[6]);
                            NSDictionary *userDataToReloadDialog = @{@"user_id":fromId, @"message":i[6]};
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadDialog" object:self userInfo:userDataToReloadDialog];
                            
//                            [self playMessageReceiveSound];
                            //                                    NSString *myTextForMessage = [NSString stringWithFormat:@"sos%isos%isos%isos", counterd, counterd, counterd  ];
                            //                                    NSString *messageRe = [myTextForMessage stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
                            //                            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/messages.send?user_id=%@&message=%@&v=%@&access_token=%@", fromId, messageRe, _app.version, _app.token ]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                            //                                NSDictionary *messageSendResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                            //                                NSLog(@"%@", messageSendResponse);
                            //
                            //                            }] resume];
//                            counterd++;
                            serverTs = serverData[@"ts"];
                            sleep(1);
                            
                            
                            
                            
                        }
                        else{
                            //                            NSLog(@"%@", serverData[@"updates"]);
                        }
                    }
                    else{
                        serverTs = serverData[@"ts"];
                    }
                }
                if(!stopped){
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
                        startLong();
                        
                    });
//                    sleep(5);
                    
                }
               
                
               

            }];
            [superLong resume];
        }
        else{
//             NSLog(@"%@ %@ %@ %@", serverKey, serverTs, serverUrl, serverBaseUrl);
            NSLog(@"Server params for long poll not recieved");
            if(!stopped){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                startLong();
                
            });

            }
        }
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
            startLong();
        
    });

    

}
@end
