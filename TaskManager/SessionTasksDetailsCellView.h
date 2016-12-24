//
//  SessionTasksDetailsCellView.h
//  MasterAPI
//
//  Created by sim on 24.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SessionTasksDetailsCellView : NSTableCellView
@property (weak) IBOutlet NSTextField *postText;
@property (weak) IBOutlet NSCollectionView *postAttachments;


@end
