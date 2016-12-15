//
//  AudioAlbumRemoveViewController.m
//  vkapp
//
//  Created by sim on 19.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "AudioAlbumRemoveViewController.h"

@interface AudioAlbumRemoveViewController ()<NSTableViewDataSource, NSTableViewDelegate>

@end

@implementation AudioAlbumRemoveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    _app = [[appInfo alloc]init];
    albumsListData = [[NSMutableArray alloc]init];
}
-(void)viewDidAppear{
    
    [self loadAlbums:_app.person];
}
-(void)loadAlbums:(id)public{
    albumsList.delegate = self;
    albumsList.dataSource = self;
    [progressSpin startAnimation:self];
    __block int step = 0;
    
    [albumsListData removeAllObjects];
    
    
    void (^loadAlbums)()=^{
        __block NSString *totalAlbums;
        NSURLSessionDataTask *getAlbums1 = [_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.getAlbums?owner_id=%@&v=%@&access_token=%@&count=5", public, _app.version, _app.token]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *jsonData1 = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            totalAlbums=[NSString stringWithFormat:@"%@", jsonData1[@"response"][@"count"]];
            if([totalAlbums intValue]!=0){
                while (step < [totalAlbums intValue]){
                    NSURLSessionDataTask *getAlbums = [_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.getAlbums?owner_id=%@&v=%@&access_token=%@&count=100&offset=%d", public, _app.version, _app.token, step]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        for (NSDictionary *i in jsonData[@"response"][@"items"]){
                            
                            [albumsListData addObject:@{@"id": i[@"id"], @"title":i[@"title"]}];
                            
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [albumsList reloadData];
                            
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
                    [albumsList reloadData];
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
- (IBAction)removeAction:(id)sender {
    __block BOOL stopped;
    __block NSString *url;
    __block NSIndexSet *selectedRows = [albumsList selectedRowIndexes];
    __block NSMutableArray *selectedAlbums = [[NSMutableArray alloc]init];
    __block void (^removeBlock)(BOOL captcha, NSString *captchaSid, NSString *captchaKey);
    removeBlock = ^void(BOOL captcha, NSString *captchaSid, NSString *captchaKey){
    for(NSInteger i=[selectedRows firstIndex]; i!=NSNotFound; i=[selectedRows indexGreaterThanIndex:i]){
        [selectedAlbums addObject:albumsListData[i][@"id"]];
        
    }
    NSLog(@"%@", selectedAlbums);
   
        stopped=NO;

        for (NSInteger i = [selectedRows firstIndex]; i != NSNotFound; i = [selectedRows indexGreaterThanIndex: i]){
            
            if(!stopped){
                if (captcha){
                    url = [NSString stringWithFormat:@"https://api.vk.com/method/video.editAlbum?owner_id=%@&album_id=%@&v=%@&access_token=%@&captcha_sid=%@&captcha_key=%@", _app.person, albumsListData[i][@"id"], _app.version, _app.token, captchaSid, captchaKey];
                }
                else{
                    url = [NSString stringWithFormat:@"https://api.vk.com/method/audio.deleteAlbum?owner_id=%@&album_id=%@&v=%@&access_token=%@", _app.person, albumsListData[i][@"id"], _app.version, _app.token];
                }
                [[_app.session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [albumsList deselectRow:i];
                    });
                    
                    if(error){
                        NSLog(@"Connection error");
                        return;
                    }
                    else{
                        
                        NSDictionary *removeAlbumsResponse=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        if(removeAlbumsResponse[@"error"]){
                             NSLog(@"%@:%@", removeAlbumsResponse[@"error"][@"error_code"], removeAlbumsResponse[@"error"][@"error_msg"]);
                            if([removeAlbumsResponse[@"error"][@"error_code"] intValue]==14){
                                stopped=YES;
                               
                                NSImage *img=[[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", removeAlbumsResponse[@"error"][@"captcha_img"]]]];
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
                                    
                                    capAlert.messageText=@"Captcha";
                                    NSInteger result = [capAlert runModal];
                                    if (result == NSAlertFirstButtonReturn){
                                        NSLog(@"%@", enterCode.stringValue);
                                        NSLog(@"%@", removeAlbumsResponse[@"error"][@"captcha_sid"]);
                                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                            removeBlock(YES, removeAlbumsResponse[@"error"][@"captcha_sid"], enterCode.stringValue);
                                        });
                                    }
                                    if (result == NSAlertSecondButtonReturn){
                                        
                                    }
                                });
                            }
                            else{
                                NSLog(@"%@", removeAlbumsResponse[@"error"]);
                            }
                        }
                        else if(removeAlbumsResponse[@"response"]){
                            NSLog(@"Album %@ removed", albumsListData[i][@"title"]);
                        }
                    }
                    
//                    NSLog(@"%lu", i);
                }] resume];
                sleep(1);
                
            }
            else{
                break;
            }
            
        }
        //        dispatch_async(dispatch_get_main_queue(), ^{
        if(!stopped && [selectedRows count]>0){
            [self loadAlbums:_app.person];
        }
        
        
        //        });
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        removeBlock(NO, @"", @"");
    });
}
-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    
    
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if([albumsListData count]>0){
        return [albumsListData count];
    }
    
    return 0;
}
-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
    if([albumsListData count]>0){
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
        [cell.textField setStringValue:[albumsListData[row][@"title"] stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"]];
        return cell;
    }
    
    return nil;
}
@end
