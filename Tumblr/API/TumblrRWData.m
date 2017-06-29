//
//  TumblrRWData.m
//  MasterAPI
//
//  Created by sim on 09.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "TumblrRWData.h"

@implementation TumblrRWData

-(id)init{
    self = [super self];
    moc = [[[NSApplication sharedApplication ] delegate] managedObjectContext];
    return self;
}
-(NSDictionary *)readTumblrTokens{
  
    NSError *readError;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TumblrAppInfo"];
    [request setReturnsObjectsAsFaults:NO];
    [request setResultType:NSDictionaryResultType];
    NSArray *array = [moc executeFetchRequest:request error:&readError];
    
    return [array count] ? array[0] : @{};
}

-(BOOL)TumblrTokensEcxistsInCoreData{
    
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
-(void)removeAllTumblrAppInfo:(OnCompleteRemoveTumblrApp)completion{

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
-(void)writeTokens:(NSDictionary*)data{
    NSError *readError;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TumblrAppInfo"];
    [request setReturnsObjectsAsFaults:NO];
    NSError *saveError;
    NSArray *array = [moc executeFetchRequest:request error:&readError];
    if(array!=nil){
        if([array count] == 0){
            NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"TumblrAppInfo" inManagedObjectContext:moc];
            [object setValue:data[@"oauth_token"] forKey:@"token"];
            [object setValue:data[@"oauth_token_secret"] forKey:@"secret_token"];
            [object setValue:data[@"consumer_key"] forKey:@"consumer_key"];
            [object setValue:data[@"consumer_secret_key"] forKey:@"consumer_secret_key"];
            if(![moc save:&saveError]){
                NSLog(@"Save and insert tumblr tokens error");
            }else{
                NSLog(@"Saved new tumblr tokens");
            }
        }else{
            
            for(NSManagedObject *managedObject in array) {
                [managedObject setValue:data[@"consumer_key"] forKey:@"consumer_key"];
                [managedObject setValue:data[@"consumer_secret_key"] forKey:@"consumer_secret_key"];
                [managedObject setValue:data[@"oauth_token"] forKey:@"token"];
                [managedObject setValue:data[@"oauth_token_secret"] forKey:@"secret_token"];
                if(![moc save:&saveError]){
                    NSLog(@"Update twitter tokens error");
                }else{
                    NSLog(@"Tokens twitter updated");
                }
            }
            
        }
    }
    [request setResultType:NSDictionaryResultType];
    NSArray *array2 = [moc executeFetchRequest:request error:&readError];
    if(array2 != nil){
        NSLog(@"READ TUMBLR TOKENS RESULT %@", array2);
    }
    
}

@end
