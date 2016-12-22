//
//  SmilesViewController.m
//  MasterAPI
//
//  Created by sim on 29.11.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "SmilesViewController.h"
#import "SmilesCollectionViewItem.h"
#import "SmilesHeaderView.h"
@interface SmilesViewController ()<NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout, NSCollectionViewElement>

@end

@implementation SmilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    SmilesCollectionView.delegate=self;
    SmilesCollectionView.dataSource=self;
   
    
//    smilesData = [[NSMutableArray alloc]initWithObjects:@"\U0001F600", @"\U0001F601", @"\U0001F602", @"\U0001F603", @"\U0001F604", @"\U0001F605", @"\U0001F606", @"\U0001F609", @"\U0001F60A", @"\U0001F60B", @"\U0001F60E", @"\U0001F60D", @"\U0001F618", @"\U0001F617", @"\U0001F619", @"\U0001F61A", @"\U0000263A", @"\U0001F642", @"\U0001F917", @"\U0001F914", @"\U0001F610", @"\U0001F611", @"\U0001F636", @"\U0001F644", @"\U0001F60F", @"\U0001F623", @"\U0001F625", @"\U0001F62E", @"\U0001F910", @"\U0001F62F", @"\U0001F62A", @"\U0001F62B", @"\U0001F634", @"\U0001F60C", @"\U0001F913", @"\U0001F61B", @"\U0001F61C", @"\U0001F61D", @"\U0001F612", @"\U0001F613", @"\U0001F614", @"\U0001F615", @"\U0001F643", @"\U0001F911", @"\U0001F632", @"\U0001F641", @"\U0001F616", @"\U0001F61E", @"\U0001F61F", @"\U0001F624", @"\U0001F622", @"\U0001F62D", @"\U0001F626", @"\U0001F627", @"\U0001F628", @"\U0001F629", @"\U0001F62C", @"\U0001F630", @"\U0001F631", @"\U0001F633", @"\U0001F635", @"\U0001F621", @"\U0001F620",@"\U0001F607",@"\U0001F637", @"\U0001F912", @"\U0001F915",@"\U0001F608", @"\U0001F47F", @"\U0001F479", @"\U0001F47A", @"\U0001F480", @"\U00002620", @"\U0001F47B", @"\U0001F47D", @"\U0001F47E", @"\U0001F916", @"\U0001F4A9",@"\U0001F63A", @"\U0001F638", @"\U0001F639", @"\U0001F63B", @"\U0001F63C", @"\U0001F63D", @"\U0001F640", @"\U0001F63F", @"\U0001F63E",@"\U0001F648", @"\U0001F649", @"\U0001F64A", @"\U0001F466", @"\U0001F466\U0001F3FB", @"\U0001F466\U0001F3FC", @"\U0001F466\U0001F3FD", @"\U0001F466\U0001F3FE", @"\U0001F466\U0001F3FF",  @"\U0001F467",@"\U0001F467\U0001F3FB", @"\U0001F467\U0001F3FC", @"\U0001F467\U0001F3FD", @"\U0001F467\U0001F3FE", @"\U0001F467\U0001F3FF", @"\U0001F468", @"\U0001F468\U0001F3FB", @"\U0001F468\U0001F3FC", @"\U0001F468\U0001F3FD", @"\U0001F468\U0001F3FE", @"\U0001F468\U0001F3FF", @"\U0001F469", @"\U0001F469\U0001F3FB",@"\U0001F466",@"\U0001F466\U0001F3FB", @"\U0001F466\U0001F3FC", @"\U0001F466\U0001F3FD", @"\U0001F466\U0001F3FE", @"\U0001F466\U0001F3FF", @"\U0001F467\U0001F3FB", @"\U0001F467\U0001F3FC", @"\U0001F467\U0001F3FD", @"\U0001F467\U0001F3FE", @"\U0001F467\U0001F3FF", @"\U0001F468\U0001F3FB", @"\U0001F468\U0001F3FC", @"\U0001F468\U0001F3FD", @"\U0001F468\U0001F3FE", @"\U0001F468\U0001F3FF", @"\U0001F469\U0001F3FB", @"\U0001F469\U0001F3FC", @"\U0001F469\U0001F3FD", @"\U0001F469\U0001F3FE", @"\U0001F469\U0001F3FF", @"\U0001F474\U0001F3FB", @"\U0001F474\U0001F3FC", @"\U0001F474\U0001F3FD", @"\U0001F474\U0001F3FE", @"\U0001F474\U0001F3FF", @"\U0001F475\U0001F3FB", @"\U0001F475\U0001F3FC", @"\U0001F475\U0001F3FD", @"\U0001F475\U0001F3FE", @"\U0001F475\U0001F3FF", @"\U0001F476\U0001F3FB", @"\U0001F476\U0001F3FC", @"\U0001F476\U0001F3FD", @"\U0001F476\U0001F3FE", @"\U0001F476\U0001F3FF", @"\U0001F47C", @"\U0001F47C\U0001F3FB", @"\U0001F47C\U0001F3FC", @"\U0001F47C\U0001F3FD", @"\U0001F47C\U0001F3FE", @"\U0001F47C\U0001F3FF",@"\U0001F468\U0000200D\U0001F393",@"\U0001F468\U0001F3FB\U0000200D\U0001F393",@"\U0001F468\U0001F3FC\U0000200D\U0001F393",@"\U0001F468\U0001F3FD\U0000200D\U0001F393",@"\U0001F468\U0001F3FE\U0000200D\U0001F393",@"\U0001F468\U0001F3FF\U0000200D\U0001F393",@"\U0001F469\U0000200D\U0001F393",@"\U0001F469\U0001F3FB\U0000200D\U0001F393", nil];
    sections = @[@"Emotions", @"People",@"Hearts"];
    smilesData = [[NSMutableArray alloc]initWithArray:@[
                                                        
  @{@"Emotions":@[@"\U0001F600", @"\U0001F601", @"\U0001F602", @"\U0001F603", @"\U0001F604", @"\U0001F605", @"\U0001F606", @"\U0001F609", @"\U0001F60A", @"\U0001F60B", @"\U0001F60E", @"\U0001F60D", @"\U0001F618", @"\U0001F617", @"\U0001F619", @"\U0001F61A",  @"\U0001F642", @"\U0001F917", @"\U0001F914", @"\U0001F610", @"\U0001F611", @"\U0001F636", @"\U0001F644", @"\U0001F60F", @"\U0001F623", @"\U0001F625", @"\U0001F62E", @"\U0001F910", @"\U0001F62F", @"\U0001F62A", @"\U0001F62B", @"\U0001F634", @"\U0001F60C", @"\U0001F913", @"\U0001F61B", @"\U0001F61C", @"\U0001F61D", @"\U0001F612", @"\U0001F613", @"\U0001F614", @"\U0001F615", @"\U0001F643", @"\U0001F911", @"\U0001F632", @"\U0001F641", @"\U0001F616", @"\U0001F61E", @"\U0001F61F", @"\U0001F624", @"\U0001F622", @"\U0001F62D", @"\U0001F626", @"\U0001F627", @"\U0001F628", @"\U0001F629", @"\U0001F62C", @"\U0001F630", @"\U0001F631", @"\U0001F633",@"\U0001F635", @"\U0001F621", @"\U0001F620",@"\U0001F607",@"\U0001F637", @"\U0001F912", @"\U0001F915",@"\U0001F608", @"\U0001F47F", @"\U0001F479", @"\U0001F47A", @"\U0001F480", @"\U00002620", @"\U0001F47B", @"\U0001F47D",@"\U0001F47E", @"\U0001F916", @"\U0001F4A9",@"\U0001F63A", @"\U0001F638", @"\U0001F639", @"\U0001F63B", @"\U0001F63C", @"\U0001F63D", @"\U0001F640", @"\U0001F63F", @"\U0001F63E",@"\U0001F648", @"\U0001F649", @"\U0001F64A"]},
  @{@"People":@[ @"\U0001F590",@"\U0001F590\U0001F3FB",@"\U0001F590\U0001F3FC",@"\U0001F590\U0001F3FD",@"\U0001F590\U0001F3FE",@"\U0001F590\U0001F3FF",@"\U0000270B",@"\U0000270B\U0001F3FB",@"\U0000270B\U0001F3FC",@"\U0000270B\U0001F3FD",@"\U0000270B\U0001F3FE",@"\U0000270B\U0001F3FF",@"\U0001F44C",@"\U0001F44C\U0001F3FB",@"\U0001F44C\U0001F3FC",@"\U0001F44C\U0001F3FD",@"\U0001F44C\U0001F3FE",@"\U0001F44C\U0001F3FF",@"\U0001F44D",@"\U0001F44D\U0001F3FB",@"\U0001F44D\U0001F3FC",@"\U0001F44D\U0001F3FD",@"\U0001F44B\U0001F3FC",@"\U0001F44B\U0001F3FD",@"\U0001F44B\U0001F3FE",@"\U0001F44B\U0001F3FF",@"\U0001F44F",@"\U0001F44F\U0001F3FB",@"\U0001F44F\U0001F3FC",@"\U0001F44F\U0001F3FD",@"\U0001F44F\U0001F3FE",@"\U0001F44F\U0001F3FF",@"\U0000270D",@"\U0000270D\U0001F3FB",@"\U0000270D\U0001F3FC",@"\U0000270D\U0001F3FD",@"\U0000270D\U0001F3FE",@"\U0000270D\U0001F3FF",@"\U0001F450",@"\U0001F450\U0001F3FB",@"\U0001F450\U0001F3FC",@"\U0001F450\U0001F3FD",@"\U0001F450\U0001F3FE",@"\U0001F450\U0001F3FF",@"\U0001F64C",@"\U0001F64C\U0001F3FB",@"\U0001F64C\U0001F3FC",@"\U0001F64C\U0001F3FD",@"\U0001F64C\U0001F3FE",@"\U0001F64C\U0001F3FF",@"\U0001F64F",@"\U0001F64F\U0001F3FB",@"\U0001F64F\U0001F3FC",@"\U0001F64F\U0001F3FD",@"\U0001F64F\U0001F3FE",@"\U0001F64F\U0001F3FF",@"\U0001F91D",@"\U0001F485",@"\U0001F485\U0001F3FB",@"\U0001F485\U0001F3FC",@"\U0001F485\U0001F3FD",@"\U0001F485\U0001F3FE",@"\U0000270C\U0001F3FB",@"\U0000270C\U0001F3FC",@"\U0000270C\U0001F3FD",@"\U0000270C\U0001F3FE",@"\U0000270C\U0001F3FF",@"\U0001F449\U0001F3FD",@"\U0001F449\U0001F3FE",@"\U0001F449\U0001F3FF",@"\U0001F446\U0001F3FB",@"\U0001F446\U0001F3FC",@"\U0001F446\U0001F3FD",@"\U0001F446\U0001F3FE",@"\U0001F446\U0001F3FF",@"\U0001F595",@"\U0001F595\U0001F3FB",@"\U0001F595\U0001F3FC",@"\U0001F595\U0001F3FD",@"\U0001F448",@"\U0001F448\U0001F3FB",@"\U0001F448\U0001F3FC",@"\U0001F448\U0001F3FD",@"\U0001F448\U0001F3FE",@"\U0001F448\U0001F3FF",@"\U0001F449",@"\U0001F449\U0001F3FB",@"\U0001F466", @"\U0001F466\U0001F3FB", @"\U0001F466\U0001F3FC", @"\U0001F466\U0001F3FD",@"\U0001F467",@"\U0001F467\U0001F3FB", @"\U0001F467\U0001F3FC", @"\U0001F467\U0001F3FD", @"\U0001F467\U0001F3FE", @"\U0001F467\U0001F3FF", @"\U0001F468", @"\U0001F468\U0001F3FB", @"\U0001F468\U0001F3FC", @"\U0001F468\U0001F3FD", @"\U0001F468\U0001F3FE", @"\U0001F468\U0001F3FF", @"\U0001F469", @"\U0001F469\U0001F3FB",@"\U0001F466",@"\U0001F466\U0001F3FB", @"\U0001F466\U0001F3FC", @"\U0001F466\U0001F3FD", @"\U0001F466\U0001F3FE", @"\U0001F466\U0001F3FF", @"\U0001F467\U0001F3FB", @"\U0001F467\U0001F3FC", @"\U0001F467\U0001F3FD", @"\U0001F467\U0001F3FE", @"\U0001F467\U0001F3FF", @"\U0001F468\U0001F3FB"]},
  @{@"Hearts":@[@"\U0001F48B",@"\U0001F498",@"\U00002764",@"\U0001F493",@"\U0001F494",@"\U0001F495",@"\U0001F496",@"\U0001F497",@"\U0001F499",@"\U0001F49A",@"\U0001F49B",@"\U0001F49C",@"\U0001F5A4",@"\U0001F49D",@"\U0001F49E",@"\U0001F49F",@"\U00002763",@"\U0001F48C",@"\U0001F4A4",@"\U0001F4A2"]}
  ]];
    SmilesCollectionView.content = smilesData;
    [SmilesCollectionView reloadData];
    

}
-(NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSString *nameOfSection = sections[section];
    
    return [smilesData[section][nameOfSection]count];
}
-(NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView{
    return [sections count];
}

-(NSView*)collectionView:(NSCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    SmilesHeaderView *view;
    if(kind==NSCollectionElementKindSectionHeader){
        view =(SmilesHeaderView*)[collectionView makeSupplementaryViewOfKind:NSCollectionElementKindSectionHeader withIdentifier:@"Header" forIndexPath:indexPath];
        view.textOfHeader.stringValue=sections[indexPath.section];
        return view;
    }
    return nil;
}
-(void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths{
    
//    NSLog(@"%@",[[collectionView itemAtIndexPath:[indexPaths allObjects][0]] representedObject]);
    NSIndexPath *indexPath=[indexPaths allObjects][0];
//    NSLog(@"%@", smilesData[indexPath.section][sections[indexPath.section]][indexPath.item]);
    if([_source isEqualToString:@"wall"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"InsertSmileWall" object:nil userInfo:@{@"smile":smilesData[indexPath.section][sections[indexPath.section]][indexPath.item]}];
    }else if([_source isEqualToString:@"dialogs"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"insertSmileDialogs" object:nil userInfo:@{@"smile":smilesData[indexPath.section][sections[indexPath.section]][indexPath.item]}];
        
    }else if([_source isEqualToString:@"message"]){
         [[NSNotificationCenter defaultCenter] postNotificationName:@"insertSmileMessage" object:nil userInfo:@{@"smile":smilesData[indexPath.section][sections[indexPath.section]][indexPath.item]}];
    }
     [collectionView deselectItemsAtIndexPaths:indexPaths];
}

-(NSCollectionViewItem*)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath{
   
    SmilesCollectionViewItem *item = [[SmilesCollectionViewItem alloc]init];
   
   
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.alignment=NSTextAlignmentCenter;
    NSString *sectionName = sections[indexPath.section];
    NSAttributedString *attrString = [[NSAttributedString alloc]initWithString:smilesData[indexPath.section][sectionName][indexPath.item] attributes:@{ NSFontAttributeName:[NSFont fontWithName:@"Helvetica" size:20]}];
    item = [collectionView makeItemWithIdentifier:@"SmilesCollectionViewItem" forIndexPath:indexPath];
    
    item.smileItem.font = [NSFont fontWithName:@"SS Symbolicons" size:20];
    item.smileItem.attributedStringValue = attrString;
    
    
    return item;
}
@end
