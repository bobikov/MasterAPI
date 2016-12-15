//
//  keyHandler.m
//  vkapp
//
//  Created by sim on 17.07.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "keyHandler.h"

@implementation keyHandler
- (id)init
{
    self = [super init];
    if (self) {
        manager = [[NSFileManager alloc]init];
    }
    return self;
}
-(id)writeAppInfo:(NSDictionary *)newData{
  
    NSManagedObjectContext *moc = [[[NSApplication sharedApplication] delegate] managedObjectContext];
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"VKAppInfo" inManagedObjectContext:moc];
    NSError *saveError;
    [object setValue:newData[@"appId"] forKey:@"appId"];
    [object setValue:newData[@"id"] forKey:@"id"];
    [object setValue:newData[@"version"] forKey:@"version"];
    [object setValue:newData[@"token"] forKey:@"token"];
    [object setValue:newData[@"selected"] forKey:@"selected"];
    [object setValue:newData[@"title"] forKey:@"title"];
    [object setValue:newData[@"author_url"] forKey:@"author_url"];
    [object setValue:newData[@"desc"] forKey:@"desc"];
    [object setValue:newData[@"icon"] forKey:@"icon"];
    [object setValue:newData[@"screenName"] forKey:@"screenName"];
    if(![moc save:&saveError]){
        NSLog(@"Error");
        return nil;
    }else{
        NSLog(@"App info saved");
        return @"App info saved";
    }
    return nil;
}
-(void)clearAppInfo{
    NSManagedObjectContext *moc = [[[NSApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request  = [NSFetchRequest fetchRequestWithEntityName:@"VKAppInfo"];
    [request setReturnsObjectsAsFaults:NO];
    NSError *readError;
    NSArray *array = [moc executeFetchRequest:request error:&readError];
    NSError *saveError;
    for(NSManagedObject *managedObject in array){
        [moc deleteObject:managedObject];
        if(![moc save:&saveError]){
            NSLog(@"Error delete object");
        }else{
            NSLog(@"Object deleted");
        }
    }
    NSLog(@"AppInfo cleaned");
}
-(BOOL)VKTokensEcxistsInCoreData{
    NSManagedObjectContext *moc = [[[NSApplication sharedApplication ] delegate] managedObjectContext];
    NSError *readError;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VKAppInfo"];
    [request setReturnsObjectsAsFaults:NO];
    NSArray *array = [moc executeFetchRequest:request error:&readError];
    if([array count]>0){
        return YES;
    }else{
        return NO;
    }
    return NO;
}
-(id)readAppInfo:(id)appId{
    NSManagedObjectContext *moc = [[[NSApplication sharedApplication] delegate] managedObjectContext];
    if(appId != nil){
        NSFetchRequest *request  = [NSFetchRequest fetchRequestWithEntityName:@"VKAppInfo"];
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        [request setReturnsObjectsAsFaults:NO];
        [request setResultType:NSDictionaryResultType];
        NSError *readError;
        NSArray *array = [moc executeFetchRequest:request error:&readError];
        if(array != nil){
            for(NSDictionary *i in array){
                [tempArray addObject:i[@"appId"]];
            }
            if([tempArray containsObject:appId]){
                
                return array;
            }
            
        }
    }
    else{
        NSFetchRequest *request  = [NSFetchRequest fetchRequestWithEntityName:@"VKAppInfo"];
        [request setReturnsObjectsAsFaults:NO];
        [request setResultType:NSDictionaryResultType];
        NSError *readError;
        NSArray *array = [moc executeFetchRequest:request error:&readError];
        NSDictionary *selectedApp;
        if([array count]>0 && array!=nil){
            for(NSDictionary *i in array){
                if([i[@"selected"]  isEqual: @1]){
                    selectedApp = i;
                }
            }
//            NSLog(@"Selected app %@", selectedApp);
            return selectedApp;
        }
    }
    NSLog(@"Something read wrong appinfogread");
    return nil;
}
@end
