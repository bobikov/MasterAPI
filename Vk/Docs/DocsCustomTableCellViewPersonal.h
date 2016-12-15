//
//  DocsCustomTableCellViewPersonal.h
//  vkapp
//
//  Created by sim on 07.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DocsCustomTableCellViewPersonal : NSTableCellView{
   
}
@property (weak) IBOutlet NSTextField *docsTitle;
@property (weak) IBOutlet NSImageView *docsPhoto;
@property (weak) IBOutlet NSButton *showDoc;
@property (weak) IBOutlet NSButton *addToAttachments;


@end
