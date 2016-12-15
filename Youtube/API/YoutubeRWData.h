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
-(void)removeAllYoutubeAppInfo;
-(void)updateYoutubeToken:(NSDictionary*)data;
-(void)saveSubscriptions:(NSMutableArray*)data;
-(void)removeAllSubscriptions;
-(id)readSubscriptions;
@end
