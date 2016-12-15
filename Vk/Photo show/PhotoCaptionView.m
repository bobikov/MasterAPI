//
//  PhotoCaptionView.m
//  MasterAPI
//
//  Created by sim on 02.11.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "PhotoCaptionView.h"

@interface PhotoCaptionView ()

@end

@implementation PhotoCaptionView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    if(_captionText){
        caption.stringValue=_captionText;
    }else{
    
        caption.attributedStringValue=_captionAttributedText;
    }
    [caption sizeToFit];
    
}

@end
