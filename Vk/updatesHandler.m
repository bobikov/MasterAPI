//
//  updatesHandler.m
//  vkapp
//
//  Created by sim on 14.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "updatesHandler.h"

@implementation updatesHandler
- (id)init
{
    self = [super init];
    if (self) {
        manager = [[NSFileManager alloc]init];
    }
    return self;
}
-(id)writeToFile:(id)type source:(NSString *)source  newDataToFile:(NSDictionary *)newData{
    NSData *contents;
    NSMutableArray *dataToJson = [[NSMutableArray alloc]init];
    NSMutableArray *tempData = [[NSMutableArray alloc]init];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    NSString* basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *fileName;
    
    if([type isEqualToString:@"photo"]){
       fileName = @"updatePhotoData.json";
        
    }
    NSString *path =  [basePath stringByAppendingPathComponent:[@"updates" stringByAppendingPathComponent:[source stringByAppendingPathComponent:fileName]]];
    if( [manager fileExistsAtPath:path]){
        contents  = [manager contentsAtPath:path];
        dataToJson=[NSJSONSerialization JSONObjectWithData:contents options:NSJSONReadingMutableContainers  error:nil];
      
    }
    else{
        [manager createFileAtPath:path contents:nil attributes:nil];
    }
    if (dataToJson){
        
        for(NSDictionary *i in dataToJson){
            [tempData addObject:i[@"id"]];
        }
        
        if(![tempData containsObject:newData[@"id"]]){
            
            [dataToJson addObject:newData];
            NSData *dataToFile = [NSJSONSerialization dataWithJSONObject:dataToJson options:NSJSONWritingPrettyPrinted error:nil];
            [dataToFile writeToFile:path atomically:YES];
            NSLog(@"Updated sucessfully.");
            return @"Writed";
        }
        else{
            for(NSMutableDictionary *i in dataToJson){
                if( [i[@"id"] isEqual:newData[@"id"]]){
                    i[@"date"] = newData[@"date"];
                }
                
            }
//            NSLog(@"New data %@", tempData);
            NSData *dataToFile = [NSJSONSerialization dataWithJSONObject:dataToJson options:NSJSONWritingPrettyPrinted error:nil];
            [dataToFile writeToFile:path atomically:YES];
            NSLog(@"Public with this name found. Updated.");
            return @"Writed";
        }
        
    }
    else{
        NSLog(@"Updates photo file is fully empty. Not writed.");
        NSMutableArray *arrayOfJsonObjects = [NSMutableArray arrayWithObjects:newData, nil];
        NSData *finalData  = [NSJSONSerialization dataWithJSONObject:arrayOfJsonObjects options:NSJSONWritingPrettyPrinted error:nil];
        NSString *prettyStringOfArray;
        prettyStringOfArray = [[NSString alloc]initWithData:finalData encoding:NSUTF8StringEncoding];
        [prettyStringOfArray writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"Updated sucessfully.");
        return @"Writed";
    }
    return nil;
}

-(id)readFromFile:(id)type source:(NSString *)source publicId:(id)publicId{
    NSData *contents;
    NSString *foundDate;
    NSMutableArray *dataToJson = [[NSMutableArray alloc]init];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    NSString* basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
     NSString *fileName;
    if([type isEqualToString:@"photo"]){
        fileName = @"updatePhotoData.json";
        
    }
    NSString *path =  [basePath stringByAppendingPathComponent:[@"updates" stringByAppendingPathComponent: [source stringByAppendingPathComponent: fileName]]];
    if( [manager fileExistsAtPath:path]){
        contents  = [manager contentsAtPath:path];
        dataToJson=[NSJSONSerialization JSONObjectWithData:contents options:NSJSONReadingMutableContainers  error:nil];
    }
    else{
        return @"Cant't read. Updates photo file not exists.";
    }
    if(dataToJson){
        for(NSDictionary *i in dataToJson){

            if (i[@"id"] == [NSString stringWithFormat:@"%@",publicId]){
                foundDate =  i[@"date"];
            }
          
        }
        if(foundDate){
            NSLog(@"Returned update date %@", foundDate);
            return foundDate;
        }
    }
    else{
         NSLog(@"Updates photo file is fully empty. Not readed.");
    }
    
    
    return nil;
}
@end


