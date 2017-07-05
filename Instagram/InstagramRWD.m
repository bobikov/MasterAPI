//
//  InstagramRWD.m
//  MasterAPI
//
//  Created by sim on 04.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "InstagramRWD.h"
#import "AppDelegate.h"
@implementation InstagramRWD
-(id)init{
    self = [super self];
    moc = ((AppDelegate*)[[NSApplication sharedApplication] delegate]).managedObjectContext;
    return self;
}
-(void)writeInstagramToken:(NSDictionary*)data{
    NSManagedObject *object =[[NSManagedObject alloc]initWithEntity:[NSEntityDescription entityForName:@"InstagramAppinfo" inManagedObjectContext:moc] insertIntoManagedObjectContext:moc];
    NSError *saveError;
    [object setValue:data[@"client"][@"clientId"] forKey:@"client_id"];
    [object setValue:data[@"client"][@"clientSecret"] forKey:@"client_secret"];
    [object setValue:data[@"data"][@"access_token"] forKey:@"access_token"];
    [object setValue:data[@"data"][@"user"][@"bio"] forKey:@"bio"];
    [object setValue:data[@"data"][@"user"][@"username"] forKey:@"username"];
    [object setValue:data[@"data"][@"user"][@"website"] forKey:@"website"];
    [object setValue:data[@"data"][@"user"][@"id"] forKey:@"id"];
    [object setValue:data[@"data"][@"user"][@"profile_picture"] forKey:@"profile_picture"];
    [object setValue:data[@"data"][@"user"][@"full_name"] forKey:@"full_name"];
    [moc insertObject:object];
    if(![moc save:&saveError]){
        NSLog(@"Error save instagram new app info.");
    }else{
        NSLog(@"Instagram app info successfully saved.");
    }
//    access_token
//    bio
//    client_id
//    client_secret
//    full_name
//    id
//    profile_picture
//    username
//    website
}
-(NSDictionary *)readInstagramTokens{
    NSError *readError;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"InstagramAppinfo"];
    [request setReturnsObjectsAsFaults:NO];
    [request setResultType:NSDictionaryResultType];
    NSArray *array = [moc executeFetchRequest:request error:&readError];
    
    return array[0];
}
-(BOOL)InstagramTokensEcxistsInCoreData{
    NSError *readError;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"InstagramAppinfo"];
    [request setReturnsObjectsAsFaults:NO];
    NSArray *array = [moc executeFetchRequest:request error:&readError];
    if([array count]>0){
        return YES;
    }else{
        return NO;
    }
    return NO;
}
-(void)removeAllInstagramAppInfo{
    NSError *readError;
    NSError *saveError;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"InstagramAppinfo"];
    [request setReturnsObjectsAsFaults:NO];
    NSArray *array = [moc executeFetchRequest:request error:&readError];
    for(NSManagedObject *managedObject in array){
        [moc deleteObject:managedObject];
        if(![moc save:&saveError]){
            NSLog(@"Error delete  object in Instagram app info");
        }else{
            NSLog(@"Object delted in InstagramAppInfo");
        }
    }

}
-(void)updateInstagramToken:(NSDictionary*)data{
    
}
@end
