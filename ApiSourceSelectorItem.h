//
//  ApiSourceSelectorItem.h
//  MasterAPI
//
//  Created by sim on 27.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ApiSourceSelectorItem : NSCollectionViewItem
@property (weak) IBOutlet NSTextField *sourceName;
@property(nonatomic)NSTrackingArea *trackingArea;
@end
