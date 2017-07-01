//
//  MainViewController.h
//  vkapp
//
//  Created by sim on 19.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FavoritesTabController.h"
@interface MainViewController : NSViewController{
    NSViewController *currentController;
    NSViewController *twitterCurrentController;
    NSViewController *youtubeCurrentController;
    NSViewController *tumblrCurrentcontroller;
    NSViewController *vkCurrentController;
    NSViewController *instaCurrentController;
     
    
}
@property (nonatomic, retain) NSViewController *friendsView;
@property (nonatomic, retain) NSViewController *photoCopyView;
@property (nonatomic, retain) NSViewController *welcomeView;
@property (nonatomic, retain) NSViewController *videoCopyView;
@property (nonatomic, retain) NSTabViewController *wallPostView;
@property (nonatomic, retain) NSViewController *privacyPhotoAlbumsView;
@property (nonatomic, readwrite) NSViewController *changeStatusView;
@property (nonatomic, readwrite) NSViewController *dialogsView;
@property (nonatomic, readwrite) NSViewController *subscribersView;
@property (nonatomic, readwrite) NSViewController *videoPrivacyView;
@property (nonatomic, readwrite) NSViewController *audioCopyView;
@property (nonatomic, readwrite) NSViewController *audioMoveView;
@property (nonatomic, readonly) NSViewController *audioRemoveView;
@property (nonatomic, readonly) NSViewController *profilePhotoChangeView;
@property (nonatomic, readonly) NSViewController *ShowVideoView;
@property (nonatomic, readonly) NSViewController *ShowPhotoView;
@property (nonatomic, readonly) NSViewController *BanlistView;
@property (nonatomic, readonly) NSViewController *GroupsView;
@property (nonatomic, readonly) NSTabViewController *DocsView;
@property (nonatomic, readonly) NSViewController *GroupInvitesView;
@property (nonatomic, readwrite) NSViewController *OutRequestsView;
@property (nonatomic) NSViewController *WallRemovePostsView;
@property (nonatomic) FavoritesTabController *FavesTabView;
@property (nonatomic) NSViewController *TumblrAvatar;
@property (nonatomic) NSViewController *TumblrFollowing;
@property (nonatomic) NSViewController *TumblrFollowers;
@property (nonatomic) NSViewController *TumblrPosts;
@property (nonatomic) NSViewController *TwitterFriends;
@property(nonatomic) NSViewController *YoutubeSubscriptions;
@property(nonatomic) NSViewController *YoutubeVideos;
@property(nonatomic) NSTabViewController *TwitterProfile;
@property(nonatomic)NSViewController *InstagramFollowsView;
@property(nonatomic)NSViewController *InstagramMediaPosts;
@property(nonatomic)NSViewController *InstagramSearchByTagView;
@property(nonatomic)NSViewController *InstagramFeedView;
@property(nonatomic)NSViewController *TasksView;
@property(nonatomic)NSViewController *searchView;
//-(id)showCurrentController;
@end
