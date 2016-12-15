//
//  groupsHandler.h
//  vkapp
//
//  Created by sim on 14.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface groupsHandler : NSObject{
    NSFileManager *manager;
}
-(id)writeToFile:(NSMutableArray *)newData;
-(id)readFromFile;
@end
