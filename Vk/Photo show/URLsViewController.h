//
//  URLsViewController.h
//  MasterAPI
//
//  Created by sim on 07.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface URLsViewController : NSViewController{
    
    __weak IBOutlet NSTextField *fieldWithURLsString;
    __weak IBOutlet NSButton *acceptURLs;
}
@property(nonatomic,readwrite)NSString  *mediaType;
@end
