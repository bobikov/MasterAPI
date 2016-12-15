//
//  DownloadUploadMainViewController.h
//  MasterAPI
//
//  Created by sim on 02.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DownloadUploadMainViewController : NSViewController{
    
    __weak IBOutlet NSProgressIndicator *progressBar;
}
@property(nonatomic,readwrite)NSDictionary *receivedData;
@end
