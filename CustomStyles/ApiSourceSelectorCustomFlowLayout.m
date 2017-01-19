//
//  ApiSourceSelectorCustomFlowLayout.m
//  MasterAPI
//
//  Created by sim on 19.01.17.
//  Copyright © 2017 sim. All rights reserved.
//

#import "ApiSourceSelectorCustomFlowLayout.h"

@implementation ApiSourceSelectorCustomFlowLayout
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *answer = [super layoutAttributesForElementsInRect:rect];

    for (int i = 0; i < [answer count]; ++i) {
        NSCollectionViewLayoutAttributes *currentLayoutAttributes;
        NSCollectionViewLayoutAttributes *prevLayoutAttributes;
         currentLayoutAttributes = answer[i];
        if(i==0){
              currentLayoutAttributes.frame = NSMakeRect(currentLayoutAttributes.frame.origin.x, 1 , self.collectionView.frame.size.width/5, self.collectionView.frame.size.height) ;
            continue;
        }
       
        prevLayoutAttributes = answer[i - 1];
        NSInteger maximumSpacing = 0;
        NSInteger origin = CGRectGetMaxX(prevLayoutAttributes.frame);
        
        if (origin + maximumSpacing + currentLayoutAttributes.frame.size.width < self.collectionView.frame.size.width) {
            currentLayoutAttributes.frame = NSMakeRect(origin + maximumSpacing-4, 1 ,self.collectionView.frame.size.width/5, currentLayoutAttributes.frame.size.height) ;
        }
    }
    return answer;
}
//- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
//    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
//    NSMutableArray *newAttributes = [NSMutableArray arrayWithCapacity:attributes.count];
//    for (NSCollectionViewLayoutAttributes *attribute in attributes) {
//        if ((attribute.frame.origin.x + attribute.frame.size.width <= self.collectionViewContentSize.width) &&
//            (attribute.frame.origin.y + attribute.frame.size.height <= self.collectionViewContentSize.height)) {
//            [newAttributes addObject:attribute];
//        }
//    }
//    return newAttributes;
//}
@end
