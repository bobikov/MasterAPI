//
//  TumblrRWData.m
//  MasterAPI
//
//  Created by sim on 09.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "TumblrRWData.h"

@implementation TumblrRWData


-(NSDictionary *)readTumblrTokens{
    NSManagedObjectContext *moc = [[[NSApplication sharedApplication ] delegate] managedObjectContext];
    NSError *readError;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TumblrAppInfo"];
    [request setReturnsObjectsAsFaults:NO];
    [request setResultType:NSDictionaryResultType];
    NSArray *array = [moc executeFetchRequest:request error:&readError];
    
    return array[0];
}

-(BOOL)TumblrTokensEcxistsInCoreData{
    NSManagedObjectContext *moc = [[[NSApplication sharedApplication ] delegate] managedObjectContext];
    NSError *readError;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TumblrAppInfo"];
    [request setReturnsObjectsAsFaults:NO];
    NSArray *array = [moc executeFetchRequest:request error:&readError];
    if([array count]>0){
        return YES;
    }else{
        return NO;
    }
    return NO;
}
-(void)removeAllTumblrAppInfo{
    NSManagedObjectContext *moc = [[[NSApplication sharedApplication ] delegate] managedObjectContext];
    NSError *readError;
    NSError *saveError;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TumblrAppInfo"];
    [request setReturnsObjectsAsFaults:NO];
    NSArray *array = [moc executeFetchRequest:request error:&readError];
    for(NSManagedObject *managedObject in array){
        [moc deleteObject:managedObject];
        if(![moc save:&saveError]){
            NSLog(@"Error delete tumblr object in tumblrAppInfo");
        }else{
            NSLog(@"Object delted in tumblrAppInfo");
        }
    }
}
@end
