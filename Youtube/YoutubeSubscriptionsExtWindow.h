//
//  YoutubeSubscriptionsExtWindow.h
//  MasterAPI
//
//  Created by sim on 14.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface YoutubeSubscriptionsExtWindow : NSViewController{
    
    __weak IBOutlet NSTableView *subscriptionsList;
    NSMutableArray *subscriptionsData;
}

@end
