//
//  TumblrRWData.h
//  MasterAPI
//
//  Created by sim on 09.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
@interface TumblrRWData : NSObject{
    NSManagedObjectContext *moc;
}
-(NSDictionary *)readTumblrTokens;
-(BOOL)TumblrTokensEcxistsInCoreData;
typedef void(^OnCompleteRemoveTumblrApp)(BOOL resultRemoveApp);
-(void)removeAllTumblrAppInfo:(OnCompleteRemoveTumblrApp)completion;
-(void)writeTokens:(NSDictionary*)data;
@end
