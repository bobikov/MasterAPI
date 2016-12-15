//
//  PhotoCaptionView.h
//  MasterAPI
//
//  Created by sim on 02.11.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PhotoCaptionView : NSViewController{
    
    __weak IBOutlet NSTextField *caption;
}
@property(nonatomic,readwrite)NSString *captionText;
@property(nonatomic,readwrite)NSAttributedString *captionAttributedText;

@end
