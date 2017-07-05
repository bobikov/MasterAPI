//
//  keyHandler.m
//  vkapp
//
//  Created by sim on 17.07.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "keyHandler.h"
#import "AppDelegate.h"
@implementation keyHandler
- (id)init{
    self = [super self];
    manager = [[NSFileManager alloc]init];
    moc = ((AppDelegate*)[[NSApplication sharedApplication]delegate]).managedObjectContext;
    return self;
}
-(id)removeApp:(NSString*)appId appName:(NSString*)appName{
    NSError *saveError;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VKAppInfo"];
    [request setReturnsObjectsAsFaults:NO];
    [request setPredicate:[NSPredicate predicateWithFormat:@"appId==%@ && title==%@", appId, appName]];
    NSArray *appsToRemove = [moc executeFetchRequest:request error:nil];
    if([appsToRemove lastObject]){
        for(NSManagedObject *object in appsToRemove){
            [moc deleteObject:object];
            if(![moc save:&saveError]){
                NSLog(@"Error remove app");
                return nil;
            }else{
                NSLog(@"App successfully removed");
                return @"App sucessfully removed";
                //            return @"App info saved";
            }
        }
    }
    return nil;
}
-(id)writeAppInfo:(NSDictionary *)newData{
     NSError *saveError;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VKAppInfo"];
    [request setReturnsObjectsAsFaults:NO];
    [request setPredicate:[NSPredicate predicateWithFormat:@"appId==%@", newData[@"appId"]]];
    NSArray *appSameAppId = [moc executeFetchRequest:request error:nil];
    if([appSameAppId lastObject]){
        for(NSManagedObject *object in appSameAppId){
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
        }
        
    }else{
        NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"VKAppInfo" inManagedObjectContext:moc];
       
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
    }

    return nil;
}
-(void)clearAppInfo{

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
-(void)updateAppInfo{
    
}
-(void)storeSelectedAppInfo:(NSDictionary*)app{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VKAppInfo"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"appId==%@", app[@"appId"]]];
    [request setReturnsObjectsAsFaults:NO];
    NSError *readError;
    NSArray *appsToSelect = [moc executeFetchRequest:request error:&readError];
    
    NSError *saveError;
    if(appsToSelect!=nil){
        [[appsToSelect objectAtIndex:0] setValue:@YES forKey:@"selected"];
        
        if(![moc save:&saveError]){
            NSLog(@"App %@ is not selected", app[@"title"]);
        }else{
            
            NSLog(@"App %@ is selected successfully", app[@"title"]);;
        }
        NSFetchRequest *request3 = [NSFetchRequest fetchRequestWithEntityName:@"VKAppInfo"];
        [request3 setReturnsObjectsAsFaults:NO];
        [request3 setPredicate:[NSPredicate predicateWithFormat:@"appId!=%@", app[@"appId"]]];
        NSError *readError3;
        NSError *saveError3;
        NSArray *appsToUnselect = [moc executeFetchRequest:request3 error:&readError3];
        for(NSManagedObject *managedObject in appsToUnselect){
            [managedObject setValue:@NO forKey:@"selected"];
            if(![moc save:&saveError3]){
                NSLog(@"Set selected to 0 error");
            }else{
                NSLog(@"Set selected to 0 sucessfull");
            }
        }
    }
}
-(NSArray*)readApps{

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VKAppInfo"];
    [request setReturnsObjectsAsFaults:NO];
    [request setResultType:NSDictionaryResultType];
    NSError *readError;
    NSArray *array = [moc executeFetchRequest:request error:&readError];

    return array;
}
-(id)readAppInfo:(id)appId{
    NSArray *array ;
    if(appId != nil){
        NSFetchRequest *request  = [NSFetchRequest fetchRequestWithEntityName:@"VKAppInfo"];
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        [request setReturnsObjectsAsFaults:NO];
        [request setResultType:NSDictionaryResultType];
        NSError *readError;
        array = [moc executeFetchRequest:request error:&readError];
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
    return array;
}
@end
