//
//  FaveVideoControllerViewItem.m
//  MasterAPI
//
//  Created by sim on 05/06/18.
//  Copyright © 2018 sim. All rights reserved.
//

#import "FaveVideoControllerViewItem.h"

@interface FaveVideoControllerViewItem ()

@end

@implementation FaveVideoControllerViewItem

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}
-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if(selected){
         self.view.layer.backgroundColor = [[NSColor blueColor]CGColor];
    }else{
        self.view.layer.backgroundColor = [[NSColor clearColor]CGColor];
    }
}

@end
