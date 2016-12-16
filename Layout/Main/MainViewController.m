//
//  MainViewController.m
//  vkapp
//
//  Created by sim on 19.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "MainViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface MainViewController ()

@end

@implementation MainViewController
@synthesize friendsView, photoCopyView, welcomeView, videoCopyView, wallPostView, privacyPhotoAlbumsView, changeStatusView, dialogsView, subscribersView, videoPrivacyView, audioCopyView, audioMoveView, audioRemoveView, profilePhotoChangeView,ShowVideoView, ShowPhotoView, BanlistView, DocsView, GroupsView, GroupInvitesView, OutRequestsView, WallRemovePostsView,FavesTabView, TumblrAvatar, TumblrFollowing, TumblrFollowers, TumblrPosts, TwitterFriends, YoutubeSubscriptions, YoutubeVideos, TwitterProfile, InstagramFollowsView,InstagramMediaPosts,TasksView;
- (void)viewDidLoad {
    [super viewDidLoad];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RemoveMainController:) name:@"RemoveMainController" object:nil];
    
    NSStoryboard *story =[NSStoryboard storyboardWithName:@"Main" bundle:nil];
    NSStoryboard *story2 =[NSStoryboard storyboardWithName:@"Second" bundle:nil];
    NSStoryboard *story3 =[NSStoryboard storyboardWithName:@"Third" bundle:nil];
    NSStoryboard *story4 =[NSStoryboard storyboardWithName:@"Fourth" bundle:nil];
    NSStoryboard *story5 =[NSStoryboard storyboardWithName:@"Fifth" bundle:nil];
    
    friendsView = [story instantiateControllerWithIdentifier:@"Friends"];
    photoCopyView = [story instantiateControllerWithIdentifier:@"PhotoCopy"];
    welcomeView = [story instantiateControllerWithIdentifier:@"Welcome"];
    videoCopyView = [story instantiateControllerWithIdentifier:@"VideoCopy"];
    wallPostView = [story instantiateControllerWithIdentifier:@"WallPost"];
    privacyPhotoAlbumsView = [story instantiateControllerWithIdentifier:@"PrivacyPhotoAlbums"];
    changeStatusView = [story instantiateControllerWithIdentifier:@"StatusChange"];
    dialogsView = [story instantiateControllerWithIdentifier:@"DialogsView"];
    subscribersView = [story instantiateControllerWithIdentifier:@"SubscribersView"];
    videoPrivacyView = [ story instantiateControllerWithIdentifier:@"VideoPrivacy"];
    audioCopyView = [ story3 instantiateControllerWithIdentifier:@"AudioCopy"];
    audioMoveView = [ story3 instantiateControllerWithIdentifier:@"AudioMove"];
  
    profilePhotoChangeView = [story4 instantiateControllerWithIdentifier:@"ProfilePhoto"];
    ShowVideoView = [story instantiateControllerWithIdentifier:@"ShowVideo"];
    ShowPhotoView = [story instantiateControllerWithIdentifier:@"ShowPhoto"];
    BanlistView = [story instantiateControllerWithIdentifier:@"BanlistView"];
    DocsView = [story3 instantiateControllerWithIdentifier:@"DocsTabController"];
    GroupsView = [story instantiateControllerWithIdentifier:@"SuperGroupsController"];
    GroupInvitesView = [story instantiateControllerWithIdentifier:@"GroupInvitesController"];
    OutRequestsView = [story instantiateControllerWithIdentifier:@"OutRequests"];
    WallRemovePostsView = [story instantiateControllerWithIdentifier:@"WallPostRemoveController"];
    FavesTabView = [story2 instantiateControllerWithIdentifier:@"FavoritesTabController"];
    TumblrAvatar = [story2 instantiateControllerWithIdentifier:@"TumblrAvatar"];
    TumblrFollowing = [story2 instantiateControllerWithIdentifier:@"TumblrFollowing"];
    TumblrFollowers = [story2 instantiateControllerWithIdentifier:@"TumblrFollowers"];
    TumblrPosts = [story2 instantiateControllerWithIdentifier:@"TumblrPosts"];
    TwitterFriends = [story2 instantiateControllerWithIdentifier:@"TwitterFriends"];
    YoutubeSubscriptions = [story2 instantiateControllerWithIdentifier:@"YoutubeSubscriptions"];
    YoutubeVideos = [story2 instantiateControllerWithIdentifier:@"YoutubeVideos"];
    TwitterProfile = [story2 instantiateControllerWithIdentifier:@"TwitterProfile"];
    InstagramFollowsView = [story4 instantiateControllerWithIdentifier:@"InstagramFollows"];
    InstagramMediaPosts = [story4 instantiateControllerWithIdentifier:@"InstagramMediaPosts"];
    TasksView = [story5 instantiateControllerWithIdentifier:@"TasksView"];
//    secCon = [story instantiateControllerWithIdentifier:@"secondController"];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showTasksManager:) name:@"ShowTasksManager" object:nil];

    
    [self displayContentController:welcomeView];
    currentController = welcomeView;
}
-(void)showTasksManager:(NSNotification*)notification{
   [self switchControllers:TasksView];
}
-(void)viewDidAppear{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(display:) name:@"show friends" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(display:) name:@"copy photo" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(display:) name:@"welcome" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(display:) name:@"copy video" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(display:) name:@"post wall" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(display:) name:@"privacy photo albums" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(display:) name:@"change status" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(display:) name:@"show dialogs" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(display:) name:@"show subscribers" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(display:) name:@"privacy video albums" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(display:) name:@"copy audio" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(display:) name:@"show audio" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(display:) name:@"profile photo change" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(display:) name:@"show video" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(display:) name:@"show photo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(display:) name:@"show banned" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(display:) name:@"show docs" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(display:) name:@"show groups" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(display:) name:@"show group invites" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(display:) name:@"show friends outs" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(display:) name:@"wall posts remove" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(display:) name:@"show favorites" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(display:) name:@"show avatar" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(display:) name:@"show following" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(display:) name:@"show followers" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(display:) name:@"show posts" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(display:) name:@"show twitter friends" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(display:) name:@"show subscriptions" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(display:) name:@"show youtube videos" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(display:) name:@"show twitter profile" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(display:) name:@"show follows" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SelectVKApi" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SelectTumblrApi" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SelectTwitterApi" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SelectYoutubeApi" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SelectInstagramApi" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SelectTumblrApi:) name:@"SelectTumblrApi" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SelectVKApi:) name:@"SelectVKApi" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SelectTwitterApi:) name:@"SelectTwitterApi" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SelectYoutubeApi:) name:@"SelectYoutubeApi" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SelectInstagramApi:) name:@"SelectInstagramApi" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCurrentController:) name:@"showCurrentMainController" object:nil];
}
-(void)RemoveMainController:(NSNotification*)notification{
    if ([self.childViewControllers count]>0){
        
        [self removeChildViewControllerAtIndex:0];
        [currentController removeFromParentViewController];
        [currentController.view removeFromSuperview];
        
    }
}
//-(id)showCurrentController{
////    NSLog(@"%li", [self.childViewControllers count]);
//    return self.childViewControllers;
//}
-(void)switchControllers:(NSViewController*)controller{
    NSLog(@"Switch");
//    [self removeChildViewControllerAtIndex:0];
//    [coolCon removeFromParentViewController];
//    [coolCon.view removeFromSuperview];
    if ([self.childViewControllers count]>0){
        
        
        [self removeChildViewControllerAtIndex:0];
        [currentController removeFromParentViewController];
        [currentController.view removeFromSuperview];
       
        
    }
    else{
        
        
    }
    currentController = controller;
    [self displayContentController:controller];
}

- (void) displayContentController:(NSViewController *)content {
//    CATransition *transition = [CATransition animation];
//    transition.duration = 0.25;
//    transition.removedOnCompletion=YES;
//    transition.fillMode=kCAFillModeBoth;
//    transition.type = kCATransitionReveal;
//    transition.subtype = kCATransitionFromTop;
////    transition.delegate=self;
//
//    [content.view.layer addAnimation:transition forKey:nil];
    [self addChildViewController:content];
    content.view.frame = self.view.bounds;
    NSView *view = content.view;
   
    content.view.translatesAutoresizingMaskIntoConstraints = NO;
//        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[view]-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:NSDictionaryOfVariableBindings(view)]];
    
   
    [self.view addSubview:content.view];
   
//    [[self.view animator]addSubview:content.view];
  
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[view]-0-|" options:NSLayoutFormatAlignAllTrailing metrics:nil views:NSDictionaryOfVariableBindings(view)]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-[view(==%f)]-|",content.view.frame.size.height] options:NSLayoutFormatAlignAllTrailing metrics:nil views:NSDictionaryOfVariableBindings(view)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|" options:NSLayoutFormatAlignAllTrailing metrics:nil views:NSDictionaryOfVariableBindings(view)]];
   
    
    
}
-(void)SelectYoutubeApi:(NSNotification*)notification{
    
    youtubeCurrentController ?  [self switchControllers:youtubeCurrentController] : [self switchControllers:YoutubeSubscriptions];
}
-(void)SelectTumblrApi:(NSNotification*)notification{
    
    tumblrCurrentcontroller ?  [self switchControllers:tumblrCurrentcontroller] : [self switchControllers:TumblrFollowing];
}
-(void)SelectTwitterApi:(NSNotification*)notification{
    twitterCurrentController ?  [self switchControllers:twitterCurrentController] : [self switchControllers:TwitterFriends];
}
-(void)SelectVKApi:(NSNotification*)notification{
    vkCurrentController ?  [self switchControllers:vkCurrentController] : [self switchControllers:profilePhotoChangeView];
}
-(void)SelectInstagramApi:(NSNotification*)notification{
    instaCurrentController ? [self switchControllers:instaCurrentController] : [ self switchControllers:InstagramMediaPosts];
}
-(void)display:(NSNotification *)notification{
//    NSLog(@"%@", notification.name);

    if ([notification.name  isEqual: @"copy photo"]){
        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :photoCopyView ];
        [self switchControllers:photoCopyView];
    }
    else if ([notification.name  isEqual: @"show friends"]){
        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :friendsView ];
        [self switchControllers:friendsView];
    }
    else if ([notification.name  isEqual: @"copy video"]){
        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :videoCopyView];
        [self switchControllers:videoCopyView];
    }
    else if ([notification.name  isEqual: @"post wall"]){
        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :wallPostView];
        [self switchControllers:wallPostView];
    }
    else if ([notification.name  isEqual: @"privacy photo albums"]){
        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :privacyPhotoAlbumsView];
        [self switchControllers:privacyPhotoAlbumsView];
    }
    else if([notification.name isEqual: @"change status"]){
        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :changeStatusView];
        [self switchControllers:changeStatusView];
    }
    else if ([notification.name isEqual:@"show dialogs"]){
        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :dialogsView];
        [self switchControllers:dialogsView];
    }
    else if ([notification.name isEqual:@"show subscribers"]){
        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :subscribersView];
        [self switchControllers:subscribersView];
    }
    else if ([notification.name isEqual:@"privacy video albums"]){
        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :videoPrivacyView];
        [self switchControllers:videoPrivacyView];
    }
    else if ([notification.name isEqual:@"copy audio"]){
        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :audioCopyView];
        [self switchControllers:audioCopyView];
    }
    else if ([notification.name isEqual:@"show audio"]){
        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :audioMoveView];
        [self switchControllers:audioMoveView];
    }

    else if ([notification.name isEqual:@"profile photo change"]){
        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :profilePhotoChangeView];
        [self switchControllers:profilePhotoChangeView];
    }
    else if ([notification.name isEqual:@"show video"]){
        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :ShowVideoView];
        [self switchControllers:ShowVideoView];
    }
    else if ([notification.name isEqual:@"show photo"]){
        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :ShowPhotoView];
        [self switchControllers:ShowPhotoView];
    }
    else if ([notification.name isEqual:@"show banned"]){
        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :BanlistView];
        [self switchControllers:BanlistView];
    }
    else if ([notification.name isEqual:@"show docs"]){
        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :DocsView];
        [self switchControllers:DocsView];
    }
    else if ([notification.name isEqual:@"show groups"]){
        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :GroupsView];
        [self switchControllers:GroupsView];
    }
    else if ([notification.name isEqual:@"show group invites"]){
        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :GroupInvitesView];
        [self switchControllers:GroupInvitesView];
    }
    else if ([notification.name isEqual:@"show friends outs"]){
        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :OutRequestsView];
        [self switchControllers:OutRequestsView];
    }
    else if ([notification.name isEqual:@"wall posts remove"]){
        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :WallRemovePostsView];
        [self switchControllers:WallRemovePostsView];
    }
    else if ([notification.name isEqual:@"show favorites"]){
         [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :FavesTabView];
        [self switchControllers:FavesTabView];
    }
    else if ([notification.name isEqual:@"show avatar"]){
        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :TumblrAvatar];
        [self switchControllers:TumblrAvatar];
    }
    else if ([notification.name isEqual:@"show following"]){
         [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :TumblrFollowing];
        [self switchControllers:TumblrFollowing];
    }
    else if ([notification.name isEqual:@"show followers"]){
        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :TumblrFollowers];
        [self switchControllers:TumblrFollowers];
    }
    else if ([notification.name isEqual:@"show posts"]){
        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :TumblrPosts];
        [self switchControllers:TumblrPosts];
    }
    else if ([notification.name isEqual:@"show twitter friends"]){
        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :TwitterFriends];
        [self switchControllers:TwitterFriends];
    }
    else if ([notification.name isEqual:@"show subscriptions"]){
        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :YoutubeSubscriptions];
        [self switchControllers:YoutubeSubscriptions];
    }
    else if ([notification.name isEqual:@"show youtube videos"]){
        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :YoutubeVideos];
        [self switchControllers:YoutubeVideos];
    }
    else if ([notification.name isEqual:@"show twitter profile"]){
        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :TwitterProfile];
        [self switchControllers:TwitterProfile];
    }
    else if ([notification.name isEqual:@"show media"]){
        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :InstagramMediaPosts];
        [self switchControllers:InstagramMediaPosts];
    }
    
}
-(void)setCurrentSelectedMain:(id)name :(NSViewController*)controller{
    if([name isEqual:@"youtube"]){
        youtubeCurrentController = controller;
    }
    else if([name isEqual:@"twitter"]){
        twitterCurrentController = controller;
    }
    else if([name isEqual:@"tumblr"]){
        tumblrCurrentcontroller = controller;
    }
    else if([name isEqual:@"vk"]){
        vkCurrentController = controller;
    }
    else if([name isEqual:@"instagram"]){
        instaCurrentController = controller;
    }
}
@end
