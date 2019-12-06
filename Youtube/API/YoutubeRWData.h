//
//  YoutubeRWData.h
//  MasterAPI
//
//  Created by sim on 12.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
@interface YoutubeRWData : NSObject{
    NSManagedObjectContext *moc;
}
-(NSDictionary *)readYoutubeTokens;
-(BOOL)YoutubeTokensEcxistsInCoreData;
typedef void(^OnCompleteRemove)(BOOL removeAppResult);
-(void)removeAllYoutubeAppInfo:(OnCompleteRemove)completion;
-(void)updateYoutubeToken:(NSDictionary*)data;
-(void)saveSubscriptions:(NSMutableArray*)data;
-(void)removeAllSubscriptions;
-(id)readSubscriptions;
@end
