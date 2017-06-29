//
//  YoutubeRWData.m
//  MasterAPI
//
//  Created by sim on 12.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "YoutubeRWData.h"

@implementation YoutubeRWData
-(id)init{
    self = [super self];
     moc = [[[NSApplication sharedApplication ] delegate] managedObjectContext];
    return self;
    
}
-(NSDictionary *)readYoutubeTokens{
   
    NSError *readError;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"YoutubeAppInfo"];
    [request setReturnsObjectsAsFaults:NO];
    [request setResultType:NSDictionaryResultType];
    NSArray *array = [moc executeFetchRequest:request error:&readError];
    
    return [array count] ? array[0] : @{};
}

-(BOOL)YoutubeTokensEcxistsInCoreData{
   
    NSError *readError;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"YoutubeAppInfo"];
    [request setReturnsObjectsAsFaults:NO];
    NSArray *array = [moc executeFetchRequest:request error:&readError];
    if([array count]>0){
        return YES;
    }else{
        return NO;
    }
    return NO;
}
-(void)removeAllYoutubeAppInfo:(OnCompleteRemove)completion{

    NSError *readError;
    NSError *saveError;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"YoutubeAppInfo"];
    [request setReturnsObjectsAsFaults:NO];
    NSArray *array = [moc executeFetchRequest:request error:&readError];
    for(NSManagedObject *managedObject in array){
        [moc deleteObject:managedObject];
        if(![moc save:&saveError]){
            NSLog(@"Error delete  object in YoutubeAppInfo");
            completion(0);
        }else{
            NSLog(@"Object delted in YoutubeAppInfo");
            completion(1);
        }
    }
}
-(void)updateYoutubeToken:(NSDictionary*)data{
  
    NSError *readError;
    NSError *saveError;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"YoutubeAppInfo"];
    [request setReturnsObjectsAsFaults:NO];
    NSArray *array = [moc executeFetchRequest:request error:&readError];
    
    if(array!=nil){
        for(NSManagedObjectContext *object in array){
            [object setValue:data[@"access_token"] forKey:@"access_token"];
            [object setValue:data[@"token_type"] forKey:@"token_type"];
            if(![moc save:&saveError]){
                NSLog(@"Error save refresh token core data.");
            }else{
                NSLog(@"Token refresh successfully done.");
            }
        }
    }
}
-(void)saveSubscriptions:(NSMutableArray*)data{
     NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    NSError *saveError;
    temporaryContext.parentContext=moc;
   
    for(NSDictionary *i in data){
        NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"YoutubeSubscriptions" inManagedObjectContext:temporaryContext];
        [object setValue:i[@"publishedAt"] forKey:@"publishedAt"];
        [object setValue:i[@"title"] forKey:@"title"];
        [object setValue:i[@"desc"] forKey:@"desc"];
        [object setValue:i[@"channelId"] forKey:@"channelId"];
        [object setValue:i[@"id"] forKey:@"id"];
        [object setValue:i[@"thumb_def"] forKey:@"thumb_def"];
        [object setValue:i[@"thumb_med"] forKey:@"thumb_med"];
        [object setValue:i[@"thumb_high"] forKey:@"thumb_high"];
        if(![temporaryContext save:&saveError]){
            NSLog(@"Save error");
        }else{
            NSLog(@"Saved");
        }
    }
}
-(void)removeAllSubscriptions{
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];

    NSError *readError;
    NSError *saveError;
    temporaryContext.parentContext=moc;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"YoutubeSubscriptions"];
    [request setEntity:[NSEntityDescription entityForName:@"YoutubeSubscriptions" inManagedObjectContext:temporaryContext]];
    [request setReturnsObjectsAsFaults:NO];
    NSArray *array = [temporaryContext executeFetchRequest:request error:&readError];
    for(NSManagedObject *object in array){
        [temporaryContext deleteObject:object];
        if(![temporaryContext save:&saveError]){
            NSLog(@"Error remove");
        }else{
            NSLog(@"Removed successfully");
        }
    }

}
-(id)readSubscriptions{
     NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"YoutubeSubscriptions"];
    NSError *readError;
    temporaryContext.parentContext=moc;
    [request setEntity:[NSEntityDescription entityForName:@"YoutubeSubscriptions" inManagedObjectContext:temporaryContext]];
    [request setReturnsObjectsAsFaults:NO];
    [request setResultType:NSDictionaryResultType];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    NSArray *array = [temporaryContext executeFetchRequest:request error:&readError];
    if(array!=nil){
        return array;
    }
    
    return nil;
}
@end
