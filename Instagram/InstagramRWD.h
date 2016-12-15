//
//  InstagramRWD.h
//  MasterAPI
//
//  Created by sim on 04.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
@interface InstagramRWD : NSObject{
     NSManagedObjectContext *moc;
}
-(NSDictionary *)readInstagramTokens;
-(void)writeInstagramToken:(NSDictionary*)data;
-(BOOL)InstagramTokensEcxistsInCoreData;
-(void)removeAllInstagramAppInfo;
-(void)updateInstagramToken:(NSDictionary*)data;
//-(void)saveSubscriptions:(NSMutableArray*)data;
//-(void)removeAllSubscriptions;
//-(id)readSubscriptions;
@end
