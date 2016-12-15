//
//  groupsHandler.m
//  vkapp
//
//  Created by sim on 14.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "groupsHandler.h"

@implementation groupsHandler



- (id)init
{
    self = [super init];
    if (self) {
        manager = [[NSFileManager alloc]init];
    }
    return self;
}

-(id)writeToFile:(NSMutableArray *)newData{
    NSData *contents;
    NSMutableArray *dataToJson = [[NSMutableArray alloc]init];
    NSMutableArray *arrayOfJsonObjects = [[NSMutableArray alloc]init];
    arrayOfJsonObjects=newData;
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    
    NSString* basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSString *path = [basePath stringByAppendingPathComponent:@"groups_to_repost.json"];
    
    
    NSLog(@"%@", path);
    if( [manager fileExistsAtPath:path]){
        contents  = [manager contentsAtPath:path];
        dataToJson=[NSJSONSerialization JSONObjectWithData:contents options:NSJSONReadingMutableContainers  error:nil];
        
    }
    else{
        [manager createFileAtPath:path contents:nil attributes:nil];
    }
    if (dataToJson){

        [dataToJson addObject:newData];
        NSData *dataToFile = [NSJSONSerialization dataWithJSONObject:dataToJson options:NSJSONWritingPrettyPrinted error:nil];
        [dataToFile writeToFile:path atomically:YES];
        NSLog(@"Groups file updated sucessfully.");
        return @"Writed";
            
    }
    else{
        NSLog(@"Groups file fully empty");
    
        NSData *finalData  = [NSJSONSerialization dataWithJSONObject:newData options:0 error:nil];
        NSString *prettyStringOfArray;
        prettyStringOfArray = [[NSString alloc]initWithData:finalData encoding:NSUTF8StringEncoding];
//        NSLog(@"Pretty string %@", prettyStringOfArray);
        [prettyStringOfArray writeToFile:path  atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"Groups file updated sucessfully.");
        return @"Groups writed.";

    }

    return nil;
}

-(id)readFromFile{
    NSData *contents;
    NSMutableArray *dataToJson = [[NSMutableArray alloc] init];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    NSLog(@"Paths %@", paths);
    NSString* basePath = ([paths count] > 0) ? paths[0] : nil;
    
    NSString *pathRead = [basePath stringByAppendingPathComponent:@"groups_to_repost.json"];
    
//    NSLog(@"%@", pathRead);
    if( [manager fileExistsAtPath:pathRead]){
        contents  = [manager contentsAtPath:pathRead];
        dataToJson = [NSJSONSerialization JSONObjectWithData:contents options:NSJSONReadingMutableContainers  error:nil];
    }
    else{
        NSLog(@"Cant't read. Groups file not exists.");
        return nil;
    }
    if(dataToJson){
//       NSLog(@"Returned groups  %@", dataToJson);
        return dataToJson;
    }
    else{
        NSLog(@"Groups file is fully empty. Not readed.");
        return nil;
    }
    
    
//    return nil;
}
@end
