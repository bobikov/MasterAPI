//
//  updatesHandler.h
//  vkapp
//
//  Created by sim on 14.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface updatesHandler : NSObject{
    NSFileManager *manager;
}
-(id)writeToFile:(id)type source:(NSString *)source newDataToFile:(NSDictionary *)newData;
-(id)readFromFile:(id)type source:(NSString *)source publicId:(id)publicId;
@end
