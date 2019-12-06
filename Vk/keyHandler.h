//
//  keyHandler.h
//  vkapp
//
//  Created by sim on 17.07.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Cocoa/Cocoa.h>
@interface keyHandler : NSObject{
    NSFileManager *manager;
    NSManagedObjectContext *moc;
}
-(id)writeAppInfo:(NSDictionary *)newData;
-(id)readAppInfo:(id)publicId;
-(void)clearAppInfo;
-(BOOL)VKTokensEcxistsInCoreData;
-(NSArray*)readApps;
-(void)storeSelectedAppInfo:(NSDictionary*)app;
-(id)removeApp:(NSString*)appId appName:(NSString*)appName;
@end
