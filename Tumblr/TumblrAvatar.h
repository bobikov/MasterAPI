//
//  TumblrAvatar.h
//  MasterAPI
//
//  Created by sim on 08.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TumblrClient.h"
@interface TumblrAvatar : NSViewController{
    
    __weak IBOutlet NSImageView *tumblrAvatar;
}
@property(nonatomic)TumblrClient *tumblrClient;
@end
