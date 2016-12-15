//
//  LongPoll.h
//  vkapp
//
//  Created by sim on 28.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "appInfo.h"
@interface LongPoll : NSObject
@property(nonatomic) appInfo *app;
-(void)startLongPoll;
@end
