//
//  EditVideoPhotoAlbumViewController.m
//  MasterAPI
//
//  Created by sim on 04.02.17.
//  Copyright © 2017 sim. All rights reserved.
//

#import "EditVideoPhotoAlbumViewController.h"

@interface EditVideoPhotoAlbumViewController ()

@end

@implementation EditVideoPhotoAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    app = [[appInfo alloc]init];
    [self setCurrentTitleAndDesc];
    
    
}
- (void)setCurrentTitleAndDesc{
    if(_receivedData){
        titleField.stringValue=_receivedData[@"title"];
        descField.stringValue=_receivedData[@"desc"];
    }
}
- (IBAction)saveAction:(id)sender {
    NSString *newTitle = [titleField.stringValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString *newDesc = [descField.stringValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    if([_mediaType isEqual:@"photo"]){
        [[app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/photos.editAlbum?owner_id=%@&album_id=%@&title=%@&description=%@&access_token=%@&v=%@", _receivedData[@"owner"],_receivedData[@"id"],newTitle,newDesc,app.token, app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(data){
                NSDictionary *editAlbumResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSLog(@"%@", editAlbumResp);
                if(editAlbumResp[@"response"]){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self dismissController:self];
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"editPhotoAblumReload" object:nil userInfo:@{@"title":titleField.stringValue, @"desc":descField.stringValue}];
                    });
                }else{
                    NSLog(@"%@", editAlbumResp[@"error"]);
                }
            }
            
        }]resume];
    }else if([_mediaType isEqual:@"video"]){
        [[app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/video.editAlbum?%@album_id=%@&title=%@&access_token=%@&v=%@", [_receivedData[@"owner_id"]intValue]<0?[NSString stringWithFormat:@"group_id=%i&", abs([_receivedData[@"owner_id"] intValue])]:@"",_receivedData[@"id"],newTitle,app.token, app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(data){
                NSDictionary *editAlbumResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSLog(@"%@", editAlbumResp);
                if(editAlbumResp[@"response"]){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self dismissController:self];
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"editVideoAblumReload" object:nil userInfo:@{@"title":titleField.stringValue, @"desc":descField.stringValue}];
                    });
                }else{
                    NSLog(@"%@", editAlbumResp[@"error"]);
                }
            }
            
        }]resume];
    }
    
}

@end
