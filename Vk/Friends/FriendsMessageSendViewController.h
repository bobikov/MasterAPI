//
//  FriendsMessageSendViewController.h
//  vkapp
//
//  Created by sim on 24.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FriendsMessageSendViewController : NSViewController{
    
    __unsafe_unretained IBOutlet NSTextView *messageText;
    __weak IBOutlet NSImageView *photo;
 
    __weak IBOutlet NSTextField *receiverLabel;
    __weak IBOutlet NSButton *cancel;
}
@property (nonatomic, readwrite)NSString *textForReceiverLabel;
@property (nonatomic,readwrite) NSDictionary *recivedDataForMessage;

-(void)setReceiverText;
@end
