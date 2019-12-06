//
//  PostAttachmentsCustomItem.h
//  MasterAPI
//
//  Created by sim on 26.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PostAttachmentsCustomItem : NSCollectionViewItem
@property (weak) IBOutlet NSImageView *previewItem;
@property (weak) IBOutlet NSTextField *titleItem;
@property(nonatomic)NSMutableArray *indexPaths;
@property (weak) IBOutlet NSButton *removeItem;
@end
