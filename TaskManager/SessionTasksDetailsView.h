//
//  SessionTasksDetailsView.h
//  MasterAPI
//
//  Created by sim on 24.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SessionTasksDetailsView : NSViewController{
    
    __weak IBOutlet NSTableView *postsList;
    NSMutableArray *postsData;
    NSInteger indexURL;
}
@property(nonatomic,readwrite)NSDictionary *receivedData;


@end
