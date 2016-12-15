//
//  SmilesCollectionViewItem.h
//  MasterAPI
//
//  Created by sim on 29.11.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SmilesCollectionViewItem : NSCollectionViewItem
@property (weak) IBOutlet NSTextField *smileItem;


@property(nonatomic)NSTrackingArea *trackingArea;
@end
