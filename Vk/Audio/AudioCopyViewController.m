//
//  AudioViewController.m
//  vkapp
//
//  Created by sim on 15.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "AudioCopyViewController.h"

@interface AudioCopyViewController ()<NSTableViewDataSource, NSTableViewDelegate>

@end

@implementation AudioCopyViewController
@synthesize arrayController, arrayController2;
- (void)viewDidLoad {
    [super viewDidLoad];
    _app = [[appInfo alloc]init];
    audioListData1 = [[NSMutableArray alloc]init];
    audioListData2 = [[NSMutableArray alloc]init];
    
    [progressSpin startAnimation:self];
//    [self loadAudioAlbums:@"copy" publicId:_app.person];
    
}

-(void)viewDidAppear{
    [self loadAudioAlbums:@"copy" publicId:_app.person];
    
}

- (IBAction)showAlbumsFromAction:(id)sender {
    if(![publicId isEqual:@""]){
        [progressSpin startAnimation:self];
        [self loadAudioAlbums:@"copy" publicId:[NSString stringWithFormat:@"%@", publicId.stringValue]];
        
    }
    else{
        NSLog(@"Public Id field is empty");
    }
}

- (IBAction)copyAction:(id)sender {
    NSMutableArray *ids=[[NSMutableArray alloc]init];
    NSString *selectedAlbumId = albumFromId.stringValue;
    NSString *selectedPublicId = publicId.stringValue;
    __block NSString *countOfTracks;
   
    NSRegularExpression *regex=[NSRegularExpression regularExpressionWithPattern:@"[\\W0-9]" options:0 error:nil];
    albumToCopyTo=albumToId.stringValue;
    albumToCopyFrom=albumFromId.stringValue;
    __block void (^copyFromWall)(NSString *source, id targetAlbum, BOOL captcha,NSInteger offset, NSString *captcha_sid, NSString *captcha_key);
//    __block void (^copyFromAlbum)(NSString *source, id targetAlbum, BOOL captcha, NSInteger offset, NSString *captcha_sid, NSString *captcha_key);
    __block void (^copyFromAudiobox)(NSString *source, id targetAlbum, BOOL captcha, NSInteger offset, NSString *captcha_sid, NSString *captcha_key);
//    __block updatesHandler *handleUpdate = [[updatesHandler alloc]init];
    //    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    copyFromWall = ^(NSString *source, id targetAlbum, BOOL captcha, NSInteger offset, NSString *captcha_sid, NSString *captcha_key){
        
        stopped=NO;
//        __block NSInteger step=0;
//        __block NSString *audioIdToCopy;
//        __block NSString *newAlbumName;
//        __block BOOL stoppedAttachLoop=NO;
//        __block BOOL captchaOpened=NO;
        
        
        
        
        
        
        
        
    };
    copyFromAudiobox = ^(NSString *source, id targetAlbum, BOOL captcha,  NSInteger offset, NSString *captcha_sid, NSString *captcha_key){
       __block NSString *urlAudioAdd;
        stopped=NO;
        __block NSInteger step=0;
//        __block NSString *audioIdToCopy;
//        __block NSString *newAlbumName;
//        __block BOOL stoppedAttachLoop=NO;
        __block BOOL captchaOpened=NO;
        __block BOOL captcha_state;
//         __block bool nextLoop=NO;
        if (offset>0)
            step = offset;
        if (captcha){
            captcha_state = captcha;
        }
        else{
            captcha_state = NO;
        }
        NSString *countVar = count.stringValue;
        progress.maxValue=(float)[countVar intValue];
        
        NSLog(@"Offset: %lu captcha_sid: %@\ncaptcha_key:%@", step, captcha_sid, captcha_key);

        while (step<[count.stringValue intValue]){
            if(!stopped){
                
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                NSURLSessionDataTask *getAudio=[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.get?owner_id=%@&count=%d&offset=%ld&v=%@&access_token=%@", selectedPublicId, 1, step, _app.version, _app.token]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    if(error){
                        NSLog(@"Add audio error. %@", error);
                        return;
                    }
                    NSDictionary *audioGetData=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    for (NSDictionary *i in audioGetData[@"response"][@"items"]){
//                        if(updateDate){
//                            
//                            if([updateDate isEqualToString: [NSString stringWithFormat:@"%@", i[@"date"]]] ){
//                                NSLog(@"Stopped by update date.");
//                                stopped=YES;
//                                break;
//                            }
                        
                        if(!stopped){
                            if(captcha){
                                urlAudioAdd = [NSString stringWithFormat:@"https://api.vk.com/method/audio.add?owner_id=%@&audio_id=%@&access_token=%@&v=%@&captcha_sid=%@&captcha_key=%@", i[@"owner_id"], i[@"id"], _app.token, _app.version, captcha_sid, captcha_key];
                            }
                            else{
                                urlAudioAdd = [NSString stringWithFormat:@"https://api.vk.com/method/audio.add?owner_id=%@&audio_id=%@&access_token=%@&v=%@", i[@"owner_id"], i[@"id"], _app.token, _app.version];
                            }
                            
                            NSURLSessionDataTask *addAudio = [_app.session dataTaskWithURL:[NSURL URLWithString:urlAudioAdd] completionHandler:^(NSData  *data, NSURLResponse *response, NSError *error) {
                                NSDictionary *addAudioResponse=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                                audioIdToCopy = addAudioResponse[@"response"];
                                if(error){
                                    stopped=YES;
                                    NSLog(@"Audio add process interrupted. Bad Connection");
                                    return;
                                }
                                if(addAudioResponse[@"response"]){
                                    NSLog(@"Audio: %@ - %@ sucessfully added.", i[@"artist"], i[@"title"]);
                                }
                                if (addAudioResponse[@"error"]){
                                    if([addAudioResponse[@"error"][@"error_code"] intValue] == 14){
                                        stopped=YES;
                                        __block NSString *captchaKey;
                                        if(!captchaOpened){
                                            
                                            
                                            captchaOpened=YES;
                                            NSImage *img=[[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", addAudioResponse[@"error"][@"captcha_img"] ]]];
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                
                                                NSView *mainView=[[NSView alloc]initWithFrame:NSMakeRect(0, 0, 300, 100)];
                                                NSImageView *image = [[NSImageView alloc] initWithFrame:NSMakeRect(0,50,200,50)];
                                                NSTextField *enterCode = [[NSTextField alloc]initWithFrame:NSMakeRect(0,0, 200, 30)];
                                                [enterCode setFont:[NSFont fontWithName:@"Helvetica" size:16]];
                                                enterCode.alignment=NSTextAlignmentCenter;
                                                
                                                [mainView addSubview:image];
                                                [mainView addSubview:enterCode];
                                                [image setImage: img];
                                                NSAlert *capAlert = [[NSAlert alloc]init];
                                                capAlert.accessoryView=mainView;
                                                [capAlert addButtonWithTitle:@"Send"];
                                                [capAlert addButtonWithTitle:@"Cancel"];
                                                
                                                capAlert.messageText=@"Photo edit captcha";
                                                NSInteger result = [capAlert runModal];
                                                if (result == NSAlertFirstButtonReturn){
                                                    captchaKey=enterCode.stringValue;
                                                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                        copyFromAudiobox(source, targetAlbum, YES, step, addAudioResponse[@"error"][@"captcha_sid"], captchaKey);
                                                        captchaOpened=NO;
                                                    });
                                                }
                                                if (result == NSAlertSecondButtonReturn){
                                                    
                                                }
                                            });
                                        }
                                        NSLog(@"%@ %@", addAudioResponse[@"error"][@"error_code"], addAudioResponse[@"error"][@"error_msg"]);
                                    }
                                }
                            
                                else{
                                    
                                    if (addAudioResponse[@"response"] != nil){
                                        NSURLSessionDataTask *moveAudio = [_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.moveToAlbum?owner_id=%@&album_id=%@&audio_ids=%@&v=%@&access_token=%@", _app.person, targetAlbum,  addAudioResponse[@"response"], _app.version, _app.token]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                            if(error){
                                                NSLog(@"Move audio interrrupted. Bad Connection");
                                                return;
                                            }
                                            NSDictionary *moveAudioResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                            if(moveAudioResponse[@"error"]){
                                                NSLog(@"Move audio error. Stopped. %@", moveAudioResponse[@"error"]);
                                                stopped=YES;
                                            }
                                            else{
                                                NSLog(@"Audio sucessfully moved:%@", moveAudioResponse[@"response"]);
                                            }
                                        }];
                                        
                                        [moveAudio resume];
                                        sleep(1);
                                    }
                                    else{
                                        stopped=YES;
                                        NSLog(@"Audio Id is unknown. Stopped.");
                                    }
                                }

                            }];
                            [addAudio resume];
                            sleep(1);
                        }
                    }
                    dispatch_semaphore_signal(semaphore);
                }];
                [getAudio resume];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                dispatch_semaphore_signal(semaphore);
                step++;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(!stopped){
                        progress.doubleValue=(float) step;
                        progressLabel.stringValue = [NSString stringWithFormat:@"%ld / %@", step, count.stringValue];
                    }
                });
                
            }
            else{
                break;
            }
        }

    
    };
    void (^createAlbum)(NSString *)=^(NSString *title){
        
       [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.addAlbum?owner_id=%@&title=%@&v=%@&access_token=%@", _app.person, title, _app.version, _app.token]]completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            targetAudioAlbumId = jsonData[@"response"][@"album_id"];
           
       }] resume];
        sleep(1);
        NSLog(@"Target album id: %@", targetAudioAlbumId);
    };
    
    NSURLSessionDataTask *publicName = [_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.getById?group_id=%d&fields=description&v=%@&access_token=%@", abs([selectedPublicId intValue]), _app.version, _app.token]]completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        audioTitleNewAlbum = jsonData[@"response"][0][@"name"];
        title2 = [regex stringByReplacingMatchesInString:audioTitleNewAlbum options:0 range:NSMakeRange(0, [audioTitleNewAlbum length]) withTemplate:@""];
    }];
    [publicName resume];
    sleep(1);
    for (NSDictionary *i in audioListData1){

        title1 = [regex stringByReplacingMatchesInString:i[@"title"] options:0 range:NSMakeRange(0, [i[@"title"] length]) withTemplate:@""];
        if([title1 isEqualToString: title2]){
            [ids addObject:@{@"id":i[@"id"], @"title":i[@"title"]}];
        }
 
    }
    
    if([ids count]>0){
        for(NSDictionary *i in ids){
                [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.get?owner_id=%@&album_id=%@&v=%@&access_token=%@", _app.person, i[@"id"], _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    NSDictionary *getCount = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    countOfTracks = getCount[@"response"][@"count"];
                    if([countOfTracks intValue] < 1000){
                        targetAudioAlbumId =  i[@"id"];
                    }
                }]resume];
        }
    }
    else{
        targetAudioAlbumId = nil;
    }
    sleep(1);
    if(targetAudioAlbumId){

        NSLog(@"Album found. Ablum not created. Now target album id: %@", targetAudioAlbumId );
        if([selectedAlbumId  isEqual: @"wall"]){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
               copyFromWall(@"wall", targetAudioAlbumId, NO, 0, @"", @"");
            });
            
        }
        else if ([selectedAlbumId isEqual: @"audiobox"]){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                copyFromAudiobox(@"audiobox", targetAudioAlbumId, NO, 0, @"", @"");
            });
        }

    }
    else{
        NSInteger numberAlbum;
        if([ids count]>0){
            numberAlbum = [ids count]+1;
        }
        else{
            numberAlbum = 1;
        }
        audioTitleNewAlbum =  [[NSString stringWithFormat:@"%@ %lu", audioTitleNewAlbum, numberAlbum] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        createAlbum(audioTitleNewAlbum);
        NSLog(@"Album not found. Ablum created. Now target album id: %@", targetAudioAlbumId );
        if([selectedAlbumId  isEqual: @"wall"]){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                copyFromWall(@"wall", targetAudioAlbumId, NO, 0, @"", @"");
            });
        }
        else if ([selectedAlbumId isEqual: @"audiobox"]){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
               copyFromAudiobox(@"audiobox", targetAudioAlbumId, NO, 0, @"", @"");
            });
        }
    }
    [self loadAudioAlbums:@"copy" publicId:_app.person];
    
    
    
    
}

-(void)loadAudioAlbums:(NSString *)source publicId:(NSString *)public{
    
    __block int step = 0;
    if (![public isEqual:_app.person]){
        
        [audioListData2 removeAllObjects];
        [audioListData2 addObject:@{@"title":@"audiobox",@"id":@"audiobox"}];
        [audioListData2 addObject:@{@"title":@"wall", @"id":@"wall"}];
          NSLog(@"%@", audioListData2);
    }
    else{
        [audioListData1 removeAllObjects];
        
    }
    void (^loadAlbums)()=^{
        __block NSString *title;
        __block NSString *albumId;
        __block NSString *totalAlbums;
        NSURLSessionDataTask *getAlbums1 = [_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.getAlbums?owner_id=%@&v=%@&access_token=%@&count=5", public, _app.version, _app.token]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *jsonData1 = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            totalAlbums=[NSString stringWithFormat:@"%@", jsonData1[@"response"][@"count"]];
            if([totalAlbums intValue]!=0){
                while (step < [totalAlbums intValue]){
                    
                    NSURLSessionDataTask *getAlbums = [_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.getAlbums?owner_id=%@&v=%@&access_token=%@&count=100&offset=%d", public, _app.version, _app.token, step]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        for (NSDictionary *i in jsonData[@"response"][@"items"]){
                            title = i[@"title"];
                            title = [title stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
                            albumId = [NSString stringWithFormat:@"%@", i[@"id"]];
                            
                                if(public == _app.person){
                                    [audioListData1 addObject:@{@"id": albumId, @"title":title}];
                                }
                                else{
                                    [audioListData2 addObject:@{@"id": albumId,  @"title":title}];
                                }
                           
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([source  isEqual: @"copy"] && ![public isEqual:_app.person]){
                              
                                arrayController2.content=audioListData2;
                                [fromTableView reloadData];
                            }
                            if([source isEqual:@"copy"] && [public isEqual:_app.person]){
                                 arrayController.content=audioListData1;
                                [toTableView reloadData];
                            }
                            
                        });
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [progressSpin stopAnimation:self];
                        });
                    }];
                    [getAlbums resume];
                    step+=100;
                    usleep(500000);
                    
                }
                
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([source  isEqual: @"copy"] && ![public isEqual:_app.person] ){
                        arrayController2.content=audioListData2;
                        [fromTableView reloadData];
                    }
                    if([source isEqual:@"copy"] && [public isEqual:_app.person]){
                        arrayController.content=audioListData1;
                        [toTableView reloadData];
                    }
                });
                dispatch_async(dispatch_get_main_queue(), ^{
                    [progressSpin stopAnimation:self];
                });
            }
        }];
        [getAlbums1 resume];
        
    };
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        loadAlbums();
    });
}


@end
