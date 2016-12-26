//
//  SessionTasksDetailsView.m
//  MasterAPI
//
//  Created by sim on 24.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "SessionTasksDetailsView.h"
#import "PostAttachmentsCustomItem.h"
#import "SessionTasksDetailsCellView.h"
@interface SessionTasksDetailsView ()<NSTableViewDataSource,NSTableViewDelegate,NSCollectionViewDelegate,NSCollectionViewDataSource>

@end

@implementation SessionTasksDetailsView

- (void)viewDidLoad {
    [super viewDidLoad];
    postsList.delegate=self;
    postsList.dataSource=self;
    postsData = [[NSMutableArray alloc]init];
    postsData = _receivedData[@"data"];
    [postsList reloadData];
    indexURL=0;
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [[NSColor whiteColor]CGColor];
//    NSLog(@"%@", _receivedData);
    sumWidthLabels=0;
    
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [postsData count];
}
-(void)loadPosts{
    
}
-(NSString*)convertDateToString:(NSDate*)date{
    NSString *stringDate;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //uncomment to get the time only
    //[formatter setDateFormat:@"hh:mm a"];
    [formatter setDateFormat:@"MM.dd.yyyy, HH:mm:SS"];
    //    [formatter setDateStyle:NSDateFormatterMediumStyle];
    stringDate = [formatter stringFromDate:date];
    return stringDate;
}
-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    SessionTasksDetailsCellView *cell = (SessionTasksDetailsCellView*)[tableView makeViewWithIdentifier:@"MainCell" owner:self];
    cell.postAttachments.delegate=self;
    cell.postAttachments.dataSource=self;
    cell.postDate.stringValue = [self convertDateToString:postsData[row][@"date"]];
    cell.postText.stringValue = postsData[row][@"message"];
    cell.postAttachments.content = postsData[row][@"attach_urls"];
    for(NSString *i in [postsData[row][@"postSources"] allKeys]){
        if([postsData[row][@"postSources"][i] intValue]){
            NSDictionary *attributes = @{NSFontAttributeName: [NSFont systemFontOfSize:12], NSForegroundColorAttributeName:[NSColor whiteColor]};
            CGRect rect = [i boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                          options:NSStringDrawingTruncatesLastVisibleLine
                                       attributes:attributes
                                          context:nil];
            
            NSTextField *label = [[NSTextField alloc]initWithFrame:NSMakeRect(sumWidthLabels, cell.frame.size.height-rect.size.height, rect.size.width+5, rect.size.height)];
            label.font = [NSFont systemFontOfSize:12];
            label.editable=NO;
            label.bordered=NO;
            label.attributedStringValue=[[NSAttributedString alloc]initWithString:i attributes:attributes];
            label.drawsBackground=YES;
            label.wantsLayer=YES;
            label.layer.masksToBounds=YES;
            label.layer.cornerRadius=5;
            label.backgroundColor = [NSColor grayColor];
            sumWidthLabels+=rect.size.width+8;
            [cell addSubview:label];
        }
    }
    sumWidthLabels=0;
   
    return cell;
}
-(NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return [collectionView.content count];
}
-(NSCollectionViewItem*)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath{
    PostAttachmentsCustomItem *item = (PostAttachmentsCustomItem*)[collectionView makeItemWithIdentifier:@"PostAttachmentsCustomItem" forIndexPath:indexPath];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSImage *image = [[NSImage alloc]init];
//            NSString *ph = i[@"data"][@"items"][@"photo"] ? i[@"items"][@"photo"] : i[@"data"][@"photo"]?i[@"data"][@"photo"]:i[@"data"][@"cover"];
            NSString *ph = collectionView.content[indexPath.item][@"data"][@"items"][@"photo"] ;
            image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:ph]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [item.previewItem setImage:image];
            });
            
        });
    return item;
}
@end
