//
//  TumblrRWData.h
//  MasterAPI
//
//  Created by sim on 09.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
@interface TumblrRWData : NSObject
-(NSDictionary *)readTumblrTokens;
-(BOOL)TumblrTokensEcxistsInCoreData;
@end
