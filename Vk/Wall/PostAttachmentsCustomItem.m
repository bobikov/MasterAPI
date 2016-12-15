//
//  PostAttachmentsCustomItem.m
//  MasterAPI
//
//  Created by sim on 26.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "PostAttachmentsCustomItem.h"

@interface PostAttachmentsCustomItem ()

@end

@implementation PostAttachmentsCustomItem

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    _indexPaths = [[NSMutableArray alloc]init];
}
- (IBAction)removeItem:(id)sender {
//    [_indexPaths addObject:[NSIndexPath indexPathForItem:[self.representedObject index] inSection:0]];
//    [self.collectionView deleteItemsAtIndexPaths:[NSSet setWithArray:_indexPaths]];
//    [self.collectionView reloadData];
//    [self.representedObject index];
//    NSLog(@"%@",self.collectionView.content);
//    NSInteger index = [self.collectionView.content indexOfObject:self.representedObject];
    
//    [[self.view animator] removeFromSuperview];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"removeItemFromAttachments" object:nil userInfo:@{@"data":self.representedObject}];
//    NSLog(@"%@", self.representedObject);
//    self.collectionView
}

@end
