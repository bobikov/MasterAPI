//
//  TwitterUpdateAvatarController.h
//  MasterAPI
//
//  Created by sim on 17.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TwitterClient.h"
@interface TwitterUpdateAvatarController : NSViewController{
    
    __weak IBOutlet NSTextField *filePathLabel;
    __weak IBOutlet NSImageView *avatarImage;
    __weak IBOutlet NSProgressIndicator *progressUploadBar;
    NSString *filePath;
    BOOL loaded;
    TwitterClient *twitterClient;
    NSInteger maxBytes;
}
//@property (weak) IBOutlet NSProgressIndicator *progressUploadBar;

//@property(nonatomic, readwrite)TwitterClient *twitterClient;
@end
