//
//  FavePhotoCollectionViewItem.m
//  MasterAPI
//
//  Created by sim on 10/06/18.
//  Copyright © 2018 sim. All rights reserved.
//

#import "FavePhotoCollectionViewItem.h"

@interface FavePhotoCollectionViewItem ()

@end

@implementation FavePhotoCollectionViewItem

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
