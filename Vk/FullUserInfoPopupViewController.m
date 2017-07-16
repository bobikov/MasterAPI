//
//  FullUserInfoPopupViewController.m
//  vkapp
//
//  Created by sim on 02.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "FullUserInfoPopupViewController.h"
#import "ShowVideoViewController.h"
#import "ShowPhotoViewController.h"
#import "FriendsViewController.h"
#import "SubscribersViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <RBBAnimation/RBBSpringAnimation.h>
#import "FullInfoUserCustomTableCell.h"
@interface FullUserInfoPopupViewController ()<NSWindowDelegate, NSTableViewDelegate,NSTableViewDataSource>

@end

@implementation FullUserInfoPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _app = [[appInfo alloc]init];
    userInfoValuesList.delegate = self;
    userInfoValuesList.dataSource = self;
    
    profilePhoto.wantsLayer=YES;
    profilePhoto.layer.cornerRadius=6;
    profilePhoto.layer.masksToBounds=YES;
    userInfoData = [[NSMutableDictionary alloc]init];
    _stringHighlighter = [[StringHighlighter alloc]init];
    NSLog(@"%@",_receivedData);
    [self setViewLoadingState:YES];
    
    [self loadUserInfo];
    [self setBackground];

    self.view.wantsLayer=YES;
    self.view.layer.masksToBounds=YES;
    self.view.layer.cornerRadius=8;
    [userInfoValuesList setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
}
- (void)setToViewController{
    NSWindow *superWindow = [[NSApplication sharedApplication]mainWindow];
    NSRect popupRect = NSMakeRect(superWindow.frame.origin.x+(superWindow.frame.size.width-self.view.frame.size.width)/2,superWindow.frame.origin.y+(superWindow.frame.size.height-self.view.frame.size.height)/2, self.view.frame.size.width,self.view.frame.size.height);
    NSUInteger masks = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSUnifiedTitleAndToolbarWindowMask | NSTexturedBackgroundWindowMask;
    mainWindow = [[NSWindow alloc] initWithContentRect:popupRect styleMask:masks backing:NSBackingStoreBuffered defer:NO];
    _windowController = [[NSWindowController alloc]initWithWindow:mainWindow];
    mainWindow.titleVisibility=NSWindowTitleHidden;
    mainWindow.titlebarAppearsTransparent = YES;
    mainWindow.styleMask|=NSFullSizeContentViewWindowMask;
    mainWindow.movableByWindowBackground=NO;
    mainWindow.movable=NO;
    mainWindow.contentViewController=self;
//    RBBSpringAnimation *spring = [RBBSpringAnimation animationWithKeyPath:@"position.y"];
//    spring.fromValue = @(-100.0f);
//    spring.toValue = @(100.0f);
//    spring.velocity = 0;
//    spring.mass = 1;
//    spring.damping = 10;
//    spring.stiffness = 100;
//    spring.additive = YES;
//    spring.duration = [spring durationForEpsilon:0.01];
//    [mainWindow.contentView.layer addAnimation:spring  forKey:nil];
//    [mainWindow setAnimations:@{NSAnimationTriggerOrderIn:spring}];
//    NSArray *animations = @[spring];
//    NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations: animations];
//    [mainWindow setAnimationBehavior:NSWindowAnimationBehaviorDocumentWindow];
//    [mainWindow orderFront:[[NSApplication sharedApplication]mainWindow]];
//    [mainWindow orderOut:[[NSApplication sharedApplication]mainWindow]];
//    [mainWindow makeKeyAndOrderFront:[[NSApplication sharedApplication]mainWindow]];
    [_windowController showWindow:self];
    
}
- (void)setViewLoadingState:(BOOL)processLoading{
    if (processLoading){
        [imageProgress startAnimation:self];
        for(NSView *v in self.view.subviews){
            if(![v isKindOfClass:[NSProgressIndicator class]]){
                v.hidden=YES;
            }else{
                v.hidden=NO;
            }
        }
    }else{
        [imageProgress stopAnimation:self];
        for(NSView *v in self.view.subviews){
            if(![v isKindOfClass:[NSProgressIndicator class]]){
                v.hidden=NO;
            }else{
                v.hidden=YES;
            }
        }
    }
}
- (void)viewDidAppear{
//    self.view.window.titleVisibility=NSWindowTitleHidden;
//    self.view.window.titlebarAppearsTransparent = YES;
//    self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
//    self.view.window.movableByWindowBackground=YES;
    self.view.window.delegate = self;
    [self.view.window standardWindowButton:NSWindowMiniaturizeButton].hidden=YES;
    [self.view.window standardWindowButton:NSWindowZoomButton].hidden=YES;
    [self.view.window standardWindowButton:NSWindowCloseButton].hidden=YES;
    

}
- (void)windowDidResignKey:(NSNotification *)notification{
    NSLog(@"%@", notification.object);
    if(notification.object == self.view.window){
        [self.view.window performClose:self];
    }
}
- (void)setBackground{
    self.view.wantsLayer=YES;
    self.view.layer.masksToBounds=YES;
    self.view.layer.cornerRadius=3;
    self.view.layer.backgroundColor=[[NSColor whiteColor]CGColor];
    
}
- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqual:@"ShowUserVideoFromFullInfoSegue"]){
        ShowVideoViewController *contr = (ShowVideoViewController *)segue.destinationController;
        contr.userDataFromFullUserInfo=_receivedData;
        contr.loadFromFullUserInfo=YES;
        contr.ownerId=_receivedData[@"id"];
    }
    else if([segue.identifier isEqual:@"ShowUserPhotoFromFullInfoSegue"]){
        ShowPhotoViewController *contr = (ShowPhotoViewController*)segue.destinationController;
        contr.userDataFromFullUserInfo=_receivedData;
        contr.loadFromFullUserInfo=YES;
        contr.ownerId=_receivedData[@"id"];
    }
    else if([segue.identifier isEqual:@"ShowFriendsFromFullUserInfoSegue"]){
        FriendsViewController *contr = (FriendsViewController *)segue.destinationController;
        contr.userDataFromFullUserInfo=_receivedData;
        contr.loadFromFullUserInfo=YES;
        contr.ownerId=_receivedData[@"id"];
    }
    else if([segue.identifier isEqual:@"ShowUserFollowersFromFullInfoSegue"]){
        
        SubscribersViewController *contr = (SubscribersViewController *)segue.destinationController;
        contr.userDataFromFullUserInfo=_receivedData;
        contr.loadFromFullUserInfo=YES;
        contr.ownerId=_receivedData[@"id"];
    
    }
}
- (void)loadUserInfo {
    fieldNames = [NSMutableArray arrayWithArray:@[@"Page",@"UserID", @"Domain",@"Site",@"Email",@"Phone",@"Age",@"Country",@"City",@"Relations",@"University",@"Music",@"Books",@"Quotes",@"About"]];
    userInfoData = [[NSMutableDictionary alloc]init];
   
    NSString *vkURL=![_receivedData[@"relation_partner"] isEqual:@""] ? [NSString stringWithFormat:@"https://vk.com/id%@", _receivedData[@"relation_partner"][@"id"]] : @"";
    NSString *substringForHighlight= ![_receivedData[@"relation_partner"] isEqual:@""] ? [NSString stringWithFormat:@"%@ %@", _receivedData[@"relation_partner"][@"first_name"],_receivedData[@"relation_partner"][@"last_name"]] : @"";
//    NSString *substringForHighlight;
//    NSString *vkURL;
    NSString *fullStringForHighlight;
    userInfoData[@"UserID"] =  [NSString stringWithFormat:@"%@",_receivedData[@"id"]];
    userInfoData[@"Site"]=_receivedData[@"site"];
    fullName.stringValue = _receivedData[@"full_name"];
    userInfoData[@"Phone"] = [NSString stringWithFormat:@"%@", _receivedData[@"mobile"]];
    userInfoData[@"About"]=_receivedData[@"about"];
    userInfoData[@"Books"]=[NSString stringWithFormat:@"%@", _receivedData[@"books"]];
    userInfoData[@"Music"]=[NSString stringWithFormat:@"%@", _receivedData[@"music"]];
    userInfoData[@"University"]=[NSString stringWithFormat:@"%@", _receivedData[@"university_name"]];
//    school.stringValue = [NSString stringWithFormat:@"%@", _receivedData[@"schools"]];
    userInfoData[@"Quotes"] = [NSString stringWithFormat:@"%@", _receivedData[@"quotes"]];
    userInfoData[@"City"]=_receivedData[@"city"];
    userInfoData[@"Country"] = _receivedData[@"country"];
    userInfoData[@"Age"]=[NSString stringWithFormat:@"%@", _receivedData[@"bdate"]];
    userInfoData[@"Page"]=[NSString stringWithFormat:@"https://vk.com/%@", _receivedData[@"domain"]];
    blacklisted.stringValue = [NSString stringWithFormat:@"%@", [_receivedData[@"blacklisted"] intValue]==1 ? @"You banned by this user." : [_receivedData[@"blacklisted_by_me"] intValue]==1 ? @"User banned by you." : @""];
    userInfoData[@"Email"]=@"";
    userInfoData[@"Domain"]=@"";
    if([blacklisted.stringValue isEqual:@""]){
        blacklisted.hidden=YES;
    }else{
        blacklisted.hidden=NO;
    }
    if(_receivedData[@"relation"]){
        
        switch ([_receivedData[@"relation"] intValue]){
            case 0:
                userInfoData[@"Relations"]=@"not available";
                break;
            case 1:
                userInfoData[@"Relations"]=@"not married";
                break;
            case 2:
                userInfoData[@"Relations"]=@"have a friend";
                break;
            case 3:
                if(_receivedData[@"relation_partner"] && ![_receivedData[@"relation_partner"] isEqual:@""]){
                    fullStringForHighlight = [NSString stringWithFormat:@"engaged with %@ %@", _receivedData[@"relation_partner"][@"first_name"],_receivedData[@"relation_partner"][@"last_name"]];
        
                    userInfoData[@"Relations"] = [_stringHighlighter createLinkFromSubstring:fullStringForHighlight URL:vkURL subString:substringForHighlight];
        
                }else{
                   userInfoData[@"Relations"]=@"engaged";
                }
                break;
            case 4:
                if(_receivedData[@"relation_partner"] && ![_receivedData[@"relation_partner"] isEqual:@""]){
                    fullStringForHighlight = [NSString stringWithFormat:@"married on %@ %@", _receivedData[@"relation_partner"][@"first_name"],_receivedData[@"relation_partner"][@"last_name"]];
                    userInfoData[@"Relations"]=[_stringHighlighter createLinkFromSubstring:fullStringForHighlight URL:vkURL subString:substringForHighlight];

                }else{
                    userInfoData[@"Relations"]=@"married";
                }
                break;
            case 5:
                userInfoData[@"Relations"]=@"all complicated";
                break;
            case 6:
                userInfoData[@"Relations"]=@"in active search";
                break;
            case 7:
                if(_receivedData[@"relation_partner"] && ![_receivedData[@"relation_partner"] isEqual:@""]){

                    fullStringForHighlight = [NSString stringWithFormat:@"in love with %@ %@", _receivedData[@"relation_partner"][@"first_name"],_receivedData[@"relation_partner"][@"last_name"]];
                
                    
                    userInfoData[@"Relations"] = [_stringHighlighter createLinkFromSubstring:fullStringForHighlight URL:vkURL subString:substringForHighlight];
                    
                }else{
                    userInfoData[@"Relations"]=@"in love";
                }
                break;
                
            default:
                userInfoData[@"Relations"]=@"not available";
                break;
        }
    }
    else{
       
    }
    if([_receivedData[@"last_seen"] isEqual:@""]){
        lastSeen.hidden=YES;
        lastSeenLabel.hidden=YES;
    }else{
        lastSeenLabel.hidden=NO;
        lastSeen.hidden=NO;
        lastSeen.stringValue=_receivedData[@"last_seen"];
    }
    [_receivedData[@"verified"] intValue]==1 ? [verified setImage:[NSImage imageNamed:@"verified_2.png"]] : nil;
//    NSLog(@"%@", _receivedData);

    [profilePhoto sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _receivedData[@"user_photo_big"]]]  completed:^(NSImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        NSImageRep *rep = [[image representations] objectAtIndex:0];
        NSSize imageSize = NSMakeSize((CGFloat)rep.pixelsWide, (CGFloat)rep.pixelsHigh);
        image.size=imageSize;
         NSLog(@"%.0fx%.0f", image.size.width, image.size.height);
        [profilePhoto setImage:image];
       
        
        
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/users.get?user_id=%@&fields=counters&access_token=%@&v=%@", _receivedData[@"id"], _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(data){
                NSDictionary *getCountersResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                //        NSLog(@"%@", getFriendsResponse);
                dispatch_async(dispatch_get_main_queue(), ^{
                    friendsCount.stringValue = [NSString stringWithFormat:@"%@", getCountersResponse[@"response"][0][@"counters"][@"friends"]];
                    subscribersCount.stringValue = [NSString stringWithFormat:@"%@", getCountersResponse[@"response"][0][@"counters"][@"followers"]];
                    photosCount.stringValue = [NSString stringWithFormat:@"%@", getCountersResponse[@"response"][0][@"counters"][@"photos"]];
                    videosCount.stringValue = [NSString stringWithFormat:@"%@", getCountersResponse[@"response"][0][@"counters"][@"videos"]];
                    groupsCount.stringValue =  getCountersResponse[@"response"][0][@"counters"][@"groups"] ? [NSString stringWithFormat:@"%@", getCountersResponse[@"response"][0][@"counters"][@"groups"]] : @"not available" ;
                    [self setViewLoadingState:NO];
                });
            }
        }]resume];
    });
    for (NSString *key in [userInfoData allKeys]) {
        if ([userInfoData[key] isEqual:[NSNull null]]) {
            [userInfoData removeObjectForKey:key];
            [fieldNames removeObject:key];
        }
        else if([userInfoData[key] isEqual:@""])
        {
            [userInfoData removeObjectForKey:key];
            [fieldNames removeObject:key];
        }
        
        else if([userInfoData[key] isEqual:nil])
        {
            [userInfoData removeObjectForKey:key];
            [fieldNames removeObject:key];
        }
    }
     [userInfoValuesList reloadData];
    NSLog(@"%@",userInfoData);
    NSLog(@"%@", fieldNames);
}
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    FullInfoUserCustomTableCell *cell = [[FullInfoUserCustomTableCell alloc]init];
    cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
    NSFont *font = [NSFont systemFontOfSize:11 weight:NSFontWeightRegular];
    NSDictionary *attrsDictionary =
    [NSDictionary dictionaryWithObject:font
                                forKey:NSFontAttributeName];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",userInfoData[fieldNames[row]]] attributes:attrsDictionary];
    NSRect frame = NSMakeRect(0, 0, 210, MAXFLOAT);
    NSTextView *tv = [[NSTextView alloc] initWithFrame:frame];
    [[tv textStorage] setAttributedString:attrString];
    [tv sizeToFit];
    [cell setNeedsUpdateConstraints:YES];
    [cell updateConstraints];
    [cell setNeedsLayout:YES];
    double height;
    height = tv.frame.size.height+15;
    if([attrString length]<=100){
        return 20;
    }else{
        return height;
    }
}
-  (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    
    return [userInfoData count];
}
- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
    FullInfoUserCustomTableCell *cell = (FullInfoUserCustomTableCell*)[tableView makeViewWithIdentifier:@"MainCell" owner:self];
    [cell.valueField setAllowsEditingTextAttributes:YES];
    
    
    cell.fieldName.stringValue = [NSString stringWithFormat:@"%@:",fieldNames[row]];
    
    [_stringHighlighter highlightStringWithURLs:userInfoData[fieldNames[row]] Emails:YES fontSize:11 completion:^(NSMutableAttributedString *highlightedString) {
        cell.valueField.attributedStringValue = highlightedString;
    }];
    
    return cell;
    
    
    
}
@end
