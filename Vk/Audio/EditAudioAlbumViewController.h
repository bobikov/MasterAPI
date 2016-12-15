//
//  EditAudioAlbumViewController.h
//  MasterAPI
//
//  Created by sim on 14.11.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EditAudioAlbumViewController : NSViewController{
    
    __weak IBOutlet NSButton *save;
    __weak IBOutlet NSTextField *albumName;
}
@property(nonatomic,readwrite)NSDictionary *receivedData;
@end
