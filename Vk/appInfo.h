//
//  appInfo.h
//  vkapp
//
//  Created by sim on 20.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "keyHandler.h"
#import <CoreData/CoreData.h>
#import <Cocoa/Cocoa.h>
@interface appInfo : NSObject{
    
}
@property (nonatomic, readwrite) NSString *person;
@property (nonatomic, readwrite) NSString *token;
@property (nonatomic, readwrite) NSString *version;
@property (nonatomic, readwrite) NSString *icon;
@property (nonatomic, readwrite) NSURLSession *session;
@property (nonatomic, readwrite) BOOL selected;
@property (nonatomic, readwrite) NSString *appId;

@property (nonatomic) keyHandler *keyHandle;
@end
