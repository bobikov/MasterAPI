//
//  SmilesViewController.h
//  MasterAPI
//
//  Created by sim on 29.11.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SmilesViewController : NSViewController{
    
    __weak IBOutlet NSCollectionView *SmilesCollectionView;
    NSMutableArray *smilesData;
}
@property(nonatomic,readwrite)NSString *source;
@end
