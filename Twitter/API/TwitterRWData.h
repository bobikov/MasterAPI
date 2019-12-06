//
//  TwitterRWData.h
//  MasterAPI
//
//  Created by sim on 11.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
@interface TwitterRWData : NSObject{
    NSManagedObjectContext *moc;
}
-(NSDictionary *)readTwitterTokens;
-(BOOL)TwitterTokensEcxistsInCoreData;
typedef void(^OnCompleteRemoveApp)(BOOL resultRemoveApp);
-(void)removeAllTwitterAppInfo:(OnCompleteRemoveApp)completion;
-(void)writeTokens:(NSDictionary*)data;
@end
