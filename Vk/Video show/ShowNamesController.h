//
//  ShowVideoAlbumNamesController.h
//  MasterAPI
//
//  Created by sim on 11.11.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ShowNamesController : NSViewController{
    
    __weak IBOutlet NSTableView *namesList;
    NSString *filePath;
    NSString *fileName;
    NSString *fullPath;
    NSMutableArray *CSVArray;
    NSString *CSVString;
}
@property(nonatomic,readwrite)NSMutableArray *receivedData;
@property(nonatomic)NSFileManager *manager;
@end
