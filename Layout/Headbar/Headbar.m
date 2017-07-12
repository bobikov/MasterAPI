//
//  Headbar.m
//  vkapp
//
//  Created by sim on 02.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "Headbar.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TwitterClient.h"
#import "YoutubeClient.h"
#import "TumblrClient.h"
#import "InstagramClient.h"
#import <SYFlatButton/SYFlatButton.h>
#import <NSColor-HexString/NSColor+HexString.h>
#import <BOString/BOString.h>
@interface Headbar () <AVAudioPlayerDelegate>

@end

@implementation Headbar

- (void)viewDidLoad {
    [super viewDidLoad];
    protocol =[[APIClientsProtocol alloc]init];
    playlist = [[NSMutableDictionary alloc]init];
    appPhotoURLs = [[NSMutableDictionary alloc]init];
    _app = [[appInfo alloc]init];
    [self loadVKMainInfo];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setProfileImage:) name:@"loadProfileImage" object:nil];
    tasksButton.font=[NSFont fontWithName:@"Pe-icon-7-stroke" size:20];
    globalSearch.font=[NSFont fontWithName:@"Pe-icon-7-stroke" size:22];

    NSString *tasksS = @"\U0000E69D";
    NSString *searchS = @"\U0000E618";
    tasksButton.title = tasksS;
    globalSearch.title = searchS;
//    [self setButtonStyle:globalSearch];
    NSImage *image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:_app.icon]];
    [appIcon setImage:image];
    appIcon.wantsLayer=YES;
    appIcon.layer.cornerRadius=30/2;
    appIcon.layer.masksToBounds=TRUE;
    isPlaying = NO;
    //[self setFlatButtonStyle];
   
    NSAttributedString *ssA = [globalSearch.title bos_makeString:^(BOStringMaker *make) {
        make.baselineOffset(@10);
        make.ligature(@2);
    }];
    globalSearch.attributedTitle = ssA;
}
-(void)setFlatButtonStyle{
    NSLog(@"%@", self.view.subviews);
    for(NSArray *v in self.view.subviews){
        if([v isKindOfClass:[SYFlatButton class]]){
            SYFlatButton *button = (SYFlatButton *)v;
            [button setBezelStyle:NSRegularSquareBezelStyle];
            button.state=0;
            button.momentary = YES;
            button.cornerRadius = 4.0;
            button.borderWidth=1;
            button.backgroundNormalColor = [NSColor colorWithHexString:@"ecf0f1"];
            button.backgroundHighlightColor = [NSColor colorWithHexString:@"bdc3c7"];
            button.titleHighlightColor = [NSColor colorWithHexString:@"7f8c8d"];
            button.titleNormalColor = [NSColor colorWithHexString:@"95a5a6"];
            button.borderHighlightColor = [NSColor colorWithHexString:@"7f8c8d"];
            button.borderNormalColor = [NSColor colorWithHexString:@"95a5a6"];
        }
    }
}
- (void)viewWillAppear{
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeControl:) name:@"audioVolume" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(display:) name:@"PlayPause" object:nil];
}
- (IBAction)showTaskManager:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ShowTasksManager" object:nil];
}

- (void)volumeControl:(NSNotification *)notification{
    double vol = [notification.userInfo[@"volume"] doubleValue];
    [_player setVolume:vol];
//    NSLog(@"%f", [_player volume]);
//    NSLog(@"%f", vol);
}
- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"VolumeAudioSegue"]){
        VolumeView *controller = (VolumeView *)segue.destinationController;
        NSDictionary *dataVolumeToController = @{@"c_volume":@([_player volume])};
        controller.recivedDataForVolume=dataVolumeToController;
    }
}
- (IBAction)progressAction:(id)sender {
    [_player seekToTime:CMTimeMake(round(audioProgress.doubleValue), 10000)] ;
}
- (IBAction)playing:(id)sender {
    if(isPlaying){
        [self PlayControl:nil :YES :NO];
    }
    else{
        [self PlayControl:nil :NO :NO];
    }
   
}
- (IBAction)prevTrack:(id)sender {
    NSString *newCurrentRow = [NSString stringWithFormat:@"%d", [playlist[@"currentRow"] intValue]-1];
    [playlist setObject:newCurrentRow forKey:@"currentRow"];
    
    NSLog(@"%@", playlist[@"currentRow"]);
    [self PlayControl:playlist[@"playlist"][[newCurrentRow intValue]] :NO :YES];
}
- (IBAction)nextTrack:(id)sender {
    NSString *newCurrentRow = [NSString stringWithFormat:@"%d", [playlist[@"currentRow"] intValue]+1];
    [playlist setObject:newCurrentRow forKey:@"currentRow"];

    NSLog(@"%@", playlist[@"currentRow"]);
    [self PlayControl:playlist[@"playlist"][[newCurrentRow intValue]] :NO :YES];
}
- (void)display:(NSNotification *)notification{
    NSInteger row = [notification.userInfo[@"row"] intValue];
    [self PlayControl:notification.userInfo[@"playlist"][row] :NO :NO];
    [playlist setObject:notification.userInfo[@"row"] forKey:@"currentRow"];
    [playlist setObject:notification.userInfo[@"playlist"] forKey:@"playlist"];
  
}
- (void)updateTime:(NSTimer *)timer {
    NSInteger elapsedTimeSeconds;
    NSInteger elapsedTimeMinutes;
    NSInteger elapsedTimeHours;
//    NSString *roundedTimer;
    audioProgress.doubleValue = CMTimeGetSeconds([_player currentTime]);
    
    elapsedTime = [NSString stringWithFormat:@"%.0f", round([elapsedTime intValue])-1];
//    NSArray *timeGetComponents = [roundedTimer componentsSeparatedByString:@","];
    elapsedTimeSeconds = [elapsedTime intValue] % 60;
    elapsedTimeMinutes = ([elapsedTime intValue] / 60) % 60;
    elapsedTimeHours = (([elapsedTime intValue] / 60) / 60) % 60;
    if(elapsedTimeSeconds<10){
        audioTimer.stringValue = [NSString stringWithFormat:@"-%@%@:0%ld", elapsedTimeHours > 0 ? [NSString stringWithFormat:@"%ld:", elapsedTimeHours]: @"", elapsedTimeMinutes < 10 ? [NSString stringWithFormat:@"0%ld", elapsedTimeMinutes] :[NSString stringWithFormat:@"%ld", elapsedTimeMinutes] , elapsedTimeSeconds];
    }
    else{
        audioTimer.stringValue = [NSString stringWithFormat:@"-%@%@:%ld",elapsedTimeHours > 0 ? [NSString stringWithFormat:@"%ld:", elapsedTimeHours]: @"" , elapsedTimeMinutes < 10 ? [NSString stringWithFormat:@"0%ld", elapsedTimeMinutes] :[NSString stringWithFormat:@"%ld", elapsedTimeMinutes], elapsedTimeSeconds];
    }
// audioTimer.stringValue = [NSString stringWithFormat:@"%@", roundedTimer];
//    NSLog(@"%f", round(CMTimeGetSeconds([_player currentTime])));
    if(round(CMTimeGetSeconds([_player currentTime])) == [currentDuration intValue]){
        [playTimer invalidate];
        [playImageButton setImage:[NSImage imageNamed:@"play.png"]];
        isPlaying=NO;
    }
}

- (void)PlayControl:(id)contentData :(BOOL)pause :(BOOL)switchTrack{
    NSString *url;
    NSString *duration;
    if(!isPlaying && !switchTrack && !pause){
        isPlaying=YES;
        
        [playImageButton setImage:[NSImage imageNamed:@"pause.png"]];
//        NSLog(@"Now playing:%@-%@", contentData[@"artist"], contentData[@"title"]);
      
        [playImageButton setImage:[NSImage imageNamed:@"pause.png"]];
        NSError *error;
//        NSString *url = [@"https://vk.com/c613120/u8401236/audios/dfaf841802c9.mp3" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        
        if(contentData == nil){
            
            url = currentUrl;
            duration = currentDuration;
        }
        else{
            currentUrl = contentData[@"url"];
            duration = [NSString stringWithFormat:@"%f", [contentData[@"duration"] intValue]-1.5 ];
            currentDuration = duration;
            url = contentData[@"url"];
            nameOfCurrentPlaying = [NSString stringWithFormat:@"%@ - %@", contentData[@"artist"], contentData[@"title"]];
            nameOfCurrentTrack.stringValue = nameOfCurrentPlaying;
        }

        _player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:url]];
      
        audioProgress.maxValue = [duration intValue];
        
        if (_player == nil){
            NSLog(@"%@", [error description]);
        }
        else{
//            NSLog(@"Play here");
            [_player play];
//          scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:)
            NSLog(@"%f", _player.rate);
            elapsedTime = [NSString stringWithFormat:@"%d",[currentDuration intValue]];
            
            if (_player.rate != 0 && _player.error == nil) {
                 NSLog(@"%f", _player.rate);
               playTimer =  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
            }
            
            
        }
    }
    else if(isPlaying && !switchTrack && pause){
        isPlaying=NO;
        [playTimer invalidate];
        [playImageButton setImage:[NSImage imageNamed:@"play.png"]];
        [_player pause];
        [_player.currentItem cancelPendingSeeks];
        [_player.currentItem.asset cancelLoading];
//        elapsedTime = [NSString stringWithFormat:@"%d",[currentDuration intValue]];
    }
    else if(switchTrack && (isPlaying || !isPlaying)){
        [_player pause];
        currentUrl = contentData[@"url"];
        isPlaying=YES;
        duration = [NSString stringWithFormat:@"%f", round([contentData[@"duration"] intValue]-1.5) ];
        currentDuration = duration;
        url = contentData[@"url"];
        nameOfCurrentPlaying = [NSString stringWithFormat:@"%@ - %@", contentData[@"artist"], contentData[@"title"]];
        nameOfCurrentTrack.stringValue = nameOfCurrentPlaying;
        _player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:url]];
         [playTimer invalidate];
        audioProgress.maxValue = [duration intValue];
        [_player play];
        playTimer =  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
        [playImageButton setImage:[NSImage imageNamed:@"pause.png"]];
        elapsedTime = [NSString stringWithFormat:@"%.2f", round([currentDuration intValue])];
//        [_player play];
    }
    else if(!switchTrack && isPlaying){
        [_player pause];
        currentUrl = contentData[@"url"];
        isPlaying=YES;
        duration = [NSString stringWithFormat:@"%f", round([contentData[@"duration"] intValue]-1.5) ];
        currentDuration = duration;
        url = contentData[@"url"];
        nameOfCurrentPlaying = [NSString stringWithFormat:@"%@ - %@", contentData[@"artist"], contentData[@"title"]];
        nameOfCurrentTrack.stringValue = nameOfCurrentPlaying;
        _player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:url]];
        [playTimer invalidate];
        audioProgress.maxValue = [duration intValue];
        [_player play];
        playTimer =  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
        [playImageButton setImage:[NSImage imageNamed:@"pause.png"]];
        elapsedTime = [NSString stringWithFormat:@"%.2f", round([currentDuration intValue])];
    }
    audioTimer.stringValue = [NSString stringWithFormat:@"%.2f", round([duration intValue])];
    [_player setVolume:0.2];
    
}
- (void)setButtonStyle:(id)button{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSCenterTextAlignment];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];
    NSAttributedString *attrString = [[NSAttributedString alloc]initWithString:[button title] attributes:attrsDictionary];
    [button setAttributedTitle:attrString];
}
-(void)loadInstagramInfo{
    if(appPhotoURLs[@"instagram"]){
        [mainProfilePhoto sd_setImageWithURL:appPhotoURLs[@"instagram"][@"photo"] placeholderImage:nil options:SDWebImageRefreshCached];
        mainProfilePhoto.toolTip=appPhotoURLs[@"instagram"][@"name"];
    }else{
        InstagramClient *client = [[InstagramClient alloc]init];
        [client getUserInfo:^(NSData *userInfoData) {
            NSDictionary *userDataResp = [NSJSONSerialization JSONObjectWithData:userInfoData options:0 error:nil];
            appPhotoURLs[@"instagram"] = @{@"photo":[NSURL URLWithString:userDataResp[@"user"][@"profile_pic_url"]], @"name":userDataResp[@"user"][@"username"]};
            [mainProfilePhoto sd_setImageWithURL:appPhotoURLs[@"instagram"][@"photo"] placeholderImage:nil options:SDWebImageRefreshCached];
            mainProfilePhoto.toolTip=appPhotoURLs[@"instagram"][@"name"];
            NSLog(@"%@",userDataResp);
        }];
    }
}
- (void)loadTwitterInfo{
    if(appPhotoURLs[@"twitter"]){
        [mainProfilePhoto sd_setImageWithURL:appPhotoURLs[@"twitter"][@"photo"] placeholderImage:nil options:SDWebImageRefreshCached];
        mainProfilePhoto.toolTip=appPhotoURLs[@"twitter"][@"name"];
    }else{
        TwitterClient *client = [[TwitterClient alloc]initWithTokensFromCoreData];
        [client APIRequest:@"account" rmethod:@"verify_credentials.json" query:@{} handler:^(NSData *data) {
            if(data){
                
                NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSLog(@"%@", resp);
                if(!resp[@"errors"]){
                    appPhotoURLs[@"twitter"] = @{@"photo":[NSURL URLWithString:resp[@"profile_image_url"] ], @"name":resp[@"name"]};
                    [mainProfilePhoto sd_setImageWithURL:appPhotoURLs[@"twitter"][@"photo"] placeholderImage:nil options:SDWebImageRefreshCached];
                    mainProfilePhoto.toolTip = appPhotoURLs[@"twitter"][@"name"];
                }
         
            }
        }];
    }
}
- (IBAction)searchAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"global search" object:self userInfo:@{@"currentSelectorName":@"vk"}];
}

- (void)loadVKMainInfo{
    if(appPhotoURLs[@"vk"]){
        
        NSLog(@"%@",appPhotoURLs[@"vk"] );
        if(appPhotoURLs[@"vk"][@"photo"]){
            [mainProfilePhoto sd_setImageWithURL:appPhotoURLs[@"vk"][@"photo"] placeholderImage:nil options:SDWebImageRefreshCached];
        }
        if(appPhotoURLs[@"vk"][@"name"]){
     
            mainProfilePhoto.toolTip=appPhotoURLs[@"vk"][@"name"];
        }
    }else{
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/users.get?user_ids=%@&fields=photo_100,nickname&v=%@&access_token=%@", _app.person, _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
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
            NSString *resStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSDictionary *mainUserInfoResponse = [NSJSONSerialization JSONObjectWithData:[resStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                appPhotoURLs[@"vk"]=@{@"photo":[NSURL URLWithString:[NSString stringWithFormat:@"%@", mainUserInfoResponse[@"response"][0][@"photo_100"]]],@"name":[NSString stringWithFormat:@"%@ %@", mainUserInfoResponse[@"response"][0][@"first_name"], mainUserInfoResponse[@"response"][0][@"last_name"]]};
            
                
                NSImage *image = [[NSImage alloc]initWithContentsOfURL: appPhotoURLs[@"vk"][@"photo"]];
                //NSSize imSize=NSMakeSize(66, 66);
                //image.size=imSize;
                NSImageRep *rep = [[image representations] objectAtIndex:0];
                NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
                image.size=imageSize;
                [mainProfilePhoto setImageScaling:NSImageScaleProportionallyUpOrDown];
                [mainProfilePhoto setImage:image];
                dispatch_async(dispatch_get_main_queue(), ^{
                    mainProfilePhoto.wantsLayer=YES;
                    mainProfilePhoto.layer.cornerRadius=30/2;
                    mainProfilePhoto.layer.masksToBounds=TRUE;
                    [mainProfilePhoto setImage:image];
                });
                
            });
        }] resume];
    }
}
- (IBAction)makePost:(id)sender {
      [[NSNotificationCenter defaultCenter] postNotificationName:@"post wall" object:self userInfo:@{@"currentSelectorName":@"vk"}];
}
- (void)loadTumblInfo{
    TumblrClient *client = [[TumblrClient alloc]initWithTokensFromCoreData];
//    NSImage *image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:@"https://api.tumblr.com/v2/blog/hfdui2134.tumblr.com/avatar/512"]];
    [mainProfilePhoto sd_setImageWithURL:[NSURL URLWithString:@"https://api.tumblr.com/v2/blog/hfdui2134.tumblr.com/avatar/512"] placeholderImage:nil options:SDWebImageRefreshCached];
    mainProfilePhoto.toolTip = @"hfdui2134";
}
- (void)loadYoutubeMainInfo{
    YoutubeClient *client = [[YoutubeClient alloc]initWithTokensFromCoreData];
    
    if(appPhotoURLs[@"youtube"]){
        NSLog(@"%@",appPhotoURLs[@"youtube"]);
        if(appPhotoURLs[@"youtube"][@"photo"]){
            [mainProfilePhoto sd_setImageWithURL:appPhotoURLs[@"youtube"][@"photo"] placeholderImage:nil options:SDWebImageRefreshCached];
        }
        if(appPhotoURLs[@"youtube"][@"name"]){
             mainProfilePhoto.toolTip=appPhotoURLs[@"youtube"][@"name"];
        }
    }else{
        [client APIRequest:@"channels" query:@{@"part":@"snippet", @"mine":@"true", @"maxResults":@50} handler:^(NSData *data) {
            if(data){
                NSString *resStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                
                NSDictionary *channelsResp  = [NSJSONSerialization JSONObjectWithData:[resStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                NSLog(@"%@", channelsResp);
                if(!channelsResp[@"error"]){
                    dispatch_async(dispatch_get_main_queue(),^{
                        //NSImage *image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:channelsResp[@"items"][0][@"snippet"][@"thumbnails"][@"default"][@"url"]]];
                        //mainProfilePhoto.image = image;
                        appPhotoURLs[@"youtube"] = @{@"photo":[NSURL URLWithString:channelsResp[@"items"][0][@"snippet"][@"thumbnails"][@"default"][@"url"] ], @"name":channelsResp[@"items"][0][@"snippet"][@"title"] };
      
                        [mainProfilePhoto sd_setImageWithURL:appPhotoURLs[@"youtube"][@"photo"] placeholderImage:nil options:SDWebImageRefreshCached];
                        
                        mainProfilePhoto.toolTip=appPhotoURLs[@"youtube"][@"title"];
                    });
                }
            }
            
        }];
    }
}
- (void)setProfileImage:(NSNotification *)obj{
//    NSData *contents = [[NSData alloc]initWithContentsOfFile:notification.userInfo[@"url"]];
//    NSImage *image = [[NSImage alloc] initWithData:contents];
////    image.size=NSMakeSize(66, 66);
//    NSImageRep *rep = [[image representations] objectAtIndex:0];
//    NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
//    image.size=imageSize;
//    [mainProfilePhoto setImageScaling:NSImageScaleProportionallyUpOrDown];
//
//    mainProfilePhoto.wantsLayer=YES;
//    mainProfilePhoto.layer.cornerRadius=30/2;
//    mainProfilePhoto.layer.masksToBounds=TRUE;
//    [mainProfilePhoto setImage:image];
//    NSLog(@"IMAGE FROM %@", notification.userInfo[@"url"]);
    
    if([obj.userInfo[@"source"] isEqual:@"vk"]){
        [self loadVKMainInfo];
        //NSLog(@"%@", appPhotoURLs[@"vk"]);
    }
    else if([obj.userInfo[@"source"] isEqual:@"youtube"]){
        
        [self loadYoutubeMainInfo];
        //NSLog(@"%@", appPhotoURLs[@"youtube"]);
    }
    else if([obj.userInfo[@"source"] isEqual:@"twitter"]){
        
        [self loadTwitterInfo];
        //NSLog(@"%@", appPhotoURLs[@"youtube"]);
    }
    else if([obj.userInfo[@"source"] isEqual:@"tumblr"]){
        
        [self loadTumblInfo];
        //NSLog(@"%@", appPhotoURLs[@"youtube"]);
    }
    else if([obj.userInfo[@"source"] isEqual:@"instagram"]){
        
        [self loadInstagramInfo];
        //NSLog(@"%@", appPhotoURLs[@"youtube"]);
    }
}
@end
