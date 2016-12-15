//
//  CreateNewAlbumController.m
//  vkapp
//
//  Created by sim on 03.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "CreateNewAlbumController.h"

@interface CreateNewAlbumController ()

@end

@implementation CreateNewAlbumController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.view.wantsLayer=YES;
    self.view.layer.masksToBounds=YES;

    self.view.layer.backgroundColor=[[NSColor colorWithCalibratedRed:0.90 green:0.90 blue:0.90 alpha:0.0]CGColor];
    _app = [[appInfo alloc]init];
    NSLog(@"%@", _receivedDataForNewAlbum);
}
- (IBAction)createAlbumButtonAction:(id)sender {
    [self createAlbum];
}
- (IBAction)radioButtonsAction:(id)sender {
    
    
}

-(void)createAlbum{
    NSString *privacy;
    __block NSString *url;
    if(radioAll.state==1){
        privacy = @"all";
    }
    if(radioFriends.state==1){
        privacy= @"friends";
    }
    if(radioNobody.state==1){
        privacy =@"nobody";
    }
  
    NSString *titleAlbum = [NSString stringWithFormat:@"%@", newAlbumTitleField.stringValue];
    titleAlbum = [titleAlbum stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];

    if(![newAlbumTitleField.stringValue isEqual:@""]){
        if(_receivedDataForNewAlbum==nil || [_receivedDataForNewAlbum[@"owner"] isEqual:_app.person]){
            url =[NSString stringWithFormat:@"https://api.vk.com/method/photos.createAlbum?title=%@&privacy_view=%@&access_token=%@&v=%@",   titleAlbum, privacy, _app.token, _app.version];
        }else{
            url = [NSString stringWithFormat:@"https://api.vk.com/method/photos.createAlbum?group_id=%@&title=%@&access_token=%@&upload_by_admins_only=0&description=test&v=%@", [_receivedDataForNewAlbum[@"owner"] stringByReplacingOccurrencesOfString:@"-" withString:@""],  titleAlbum, _app.token, _app.version];
        }
        [[_app.session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(data){
                NSDictionary *createAlbumResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                NSLog(@"%@", createAlbumResponse);
                [[NSNotificationCenter defaultCenter]postNotificationName:@"createAlbumReload" object:nil];
            }
        }]resume];
    }else{
        NSLog(@"Enter title please.");
    }
}
@end
