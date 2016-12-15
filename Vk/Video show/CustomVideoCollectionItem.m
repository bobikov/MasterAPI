//
//  CustomVideoCollectionItem.m
//  vkapp
//
//  Created by sim on 26.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "CustomVideoCollectionItem.h"
#import "moveToAlbumViewController.h"
#import "CustomAnimator.h"

@interface CustomVideoCollectionItem ()

@end

@implementation CustomVideoCollectionItem

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self createTrackingArea];
    self.view.wantsLayer=YES;
    self.view.layer.masksToBounds=YES;
      self.view.layer.cornerRadius=5;
    _removeItem.hidden=YES;
    _moveToAlbum.hidden=YES;
    _app = [[appInfo alloc]init];
//    _countLabel.hidden=YES;
    _countLabel.wantsLayer=YES;
    _countLabel.layer.masksToBounds=YES;
    _countLabel.layer.cornerRadius=5;
    _countLabel.layer.opacity=.8;
//    _countLabel.layer.backgroundColor=[[NSColor clearColor] CGColor];
//    if(self.representedObject[@"count"]){
//        NSAttributedString *countAttrString = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@", self.representedObject[@"count"] ]attributes:@{NSForegroundColorAttributeName:[NSColor whiteColor]}];
//        _countLabel.attributedStringValue=countAttrString;
//        _countLabel.hidden=NO;
//    }
//    self.view.layer.cornerRadius=20;
}
- (IBAction)attachAlbum:(id)sender {
//    NSLog(@"%@",self.representedObject);
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"addToAttachments" object:nil userInfo:@{@"type":@"album", @"data":self.representedObject}];
}


//-(BOOL)isSelected{
//    [self updateColor];
//    [self setSelected:self.isSelected];
//    if([self isSelected]){
//        NSLog(@"selected");
//        
//    }else{
//        NSLog(@"not selected");
//    }
//    return self.isSelected;
//}
//
//-(void)updateColor{
//    if (self.selected){
//        if(self.highlightState==0){
//            self.view.layer.backgroundColor=[[NSColor greenColor] CGColor];
//        }
//        else if(self.highlightState==1){
//            self.view.layer.backgroundColor=[[NSColor blueColor] CGColor];
//        }
//        else if(self.highlightState==2){
//            self.view.layer.backgroundColor=[[NSColor whiteColor] CGColor];
//        }
//    }else{
//         self.view.layer.backgroundColor=[[NSColor whiteColor] CGColor];
//    }
//}
-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.alignment=NSTextAlignmentCenter;
    if(selected){
//        if(self.highlightState==0){
//            self.view.layer.backgroundColor=[[NSColor whiteColor] CGColor];
//        }
//        else if(self.highlightState==1){
//            self.view.layer.backgroundColor=[[NSColor blueColor] CGColor];
       
        NSAttributedString *attrTitle = [[NSAttributedString alloc]initWithString:_textLabel.stringValue attributes:@{NSForegroundColorAttributeName:[NSColor whiteColor], NSParagraphStyleAttributeName:paragraphStyle}];
        
        _textLabel.attributedStringValue=attrTitle;
        self.view.layer.backgroundColor = [[NSColor blueColor]CGColor];
//            self.view.layer.backgroundColor=[[NSColor colorWithCalibratedRed:0.30 green:0.70 blue:0.90 alpha:0.8]CGColor];
//            self.view.layer.borderColor=[[NSColor colorWithCalibratedRed:0.10 green:0.60 blue:0.90 alpha:1.0]CGColor];
//            self.view.layer.borderWidth=2;
//        }
//        else if(self.highlightState==2){
//            self.view.layer.backgroundColor=[[NSColor redColor] CGColor];
//        }
    }
    else{
        NSAttributedString *attrTitle = [[NSAttributedString alloc]initWithString:_textLabel.stringValue attributes:@{NSForegroundColorAttributeName:[NSColor blackColor],NSParagraphStyleAttributeName:paragraphStyle}];
        _textLabel.attributedStringValue=attrTitle;
         self.view.layer.backgroundColor=[[NSColor clearColor] CGColor];
        self.view.layer.borderColor=[[NSColor clearColor]CGColor];
        self.view.layer.borderWidth=0;
    }
}
- (void)createTrackingArea
{
    _trackingArea = [[NSTrackingArea alloc] initWithRect:self.view.bounds options:NSTrackingMouseEnteredAndExited|NSTrackingActiveInActiveApp owner:self userInfo:nil];
    [self.view addTrackingArea:_trackingArea];
    
    NSPoint mouseLocation = [self.view.window mouseLocationOutsideOfEventStream];
    mouseLocation = [self.view convertPoint: mouseLocation
                                   fromView: nil];
    
//    if (NSPointInRect(mouseLocation, self.view.bounds))
//    {
//        [self mouseEntered: nil];
//    }
//    else
//    {
//        [self mouseExited: nil];
//    }
}

- (IBAction)removeItem:(id)sender {
    NSString *baseURL;
    NSLog(@"%@", self.representedObject);
    if(self.representedObject[@"photo2"]){
         NSLog(@"%@",self.representedObject[@"owner_id"] );
        if([[NSString stringWithFormat:@"%@", self.representedObject[@"albumOwner"]] isEqual:_app.person]){
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/video.delete?owner_id=%@&target_id=%@&video_id=%@&access_token=%@&v=%@", self.representedObject[@"owner_id"],_app.person, self.representedObject[@"id"], _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *photoDeleteResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSLog(@"%@", photoDeleteResponse);
            
                  [[NSNotificationCenter defaultCenter]postNotificationName:@"removeObjectVideo" object:nil userInfo:@{@"index":[NSNumber numberWithInteger:[self.collectionView.content indexOfObject:self.representedObject]]}];
              
            }] resume];

        }
        else{
            if([[NSString stringWithFormat:@"%@", self.representedObject[@"owner_id"]] isEqualToString:[NSString stringWithFormat:@"%@", self.representedObject[@"albumOwner"]]]){
                [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/video.delete?owner_id=%@&target_id=%@&video_id=%@&access_token=%@&v=%@", self.representedObject[@"owner_id"],self.representedObject[@"albumOwner"], self.representedObject[@"id"], _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    NSDictionary *photoDeleteResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSLog(@"%@", photoDeleteResponse);
                   
                     [[NSNotificationCenter defaultCenter]postNotificationName:@"removeObjectVideo" object:nil userInfo:@{@"index":[NSNumber numberWithInteger:[self.collectionView.content indexOfObject:self.representedObject]]}];
                 
                }] resume];
            }
            else{
                [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/video.removeFromAlbum?owner_id=%@&album_id=%@&target_id=%@&video_id=%@&access_token=%@&v=%@", self.representedObject[@"owner_id"], [NSString stringWithFormat:@"%@", self.representedObject[@"albumId"]], [NSString stringWithFormat:@"%@", self.representedObject[@"albumOwner"]], self.representedObject[@"id"], _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    NSDictionary *photoDeleteResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSLog(@"%@", photoDeleteResponse);
                    
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"removeObjectVideo" object:nil userInfo:@{@"index":[NSNumber numberWithInteger:[self.collectionView.content indexOfObject:self.representedObject]]}];
                    
                }] resume];
            }
  
        }
    }
    else if(self.representedObject[@"cover"]){
        if(![[NSString stringWithFormat:@"%@", self.representedObject[@"owner_id"]] isEqual:_app.person]){
            baseURL =[NSString stringWithFormat:@"https://api.vk.com/method/video.deleteAlbum?group_id=%i&album_id=%@&access_token=%@&v=%@", abs([self.representedObject[@"owner_id"] intValue]), self.representedObject[@"id"], _app.token, _app.version];
            
        }else{
            baseURL = [NSString stringWithFormat:@"https://api.vk.com/method/video.deleteAlbum?owner_id=%@&album_id=%@&access_token=%@&v=%@",_app.person, self.representedObject[@"id"], _app.token, _app.version];
        }
       
        [[_app.session dataTaskWithURL:[NSURL URLWithString:baseURL]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary *photoDeleteResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@", photoDeleteResponse);
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"removeVideoAlbum" object:nil userInfo:@{@"object":self.representedObject}];
            
        }] resume];

    }
}
- (IBAction)moveToAlbum:(id)sender {
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    moveToAlbumViewController *controller = [story instantiateControllerWithIdentifier:@"MoveVideoPopup"];
//    controller.videoId=self.representedObject[@"id"];
    controller.selectedVideos = [[NSMutableArray alloc] initWithArray:[[self.collectionView selectionIndexes] count]>0 ? [self.collectionView.content objectsAtIndexes:[self.collectionView selectionIndexes]] : @[self.representedObject]];
    controller.ownerId=self.representedObject[@"owner_id"];
//    controller.publicOrOwnerOfAlbums =
  
    controller.albumIdToGetVideos = !self.representedObject[@"photo2"] ? self.representedObject[@"id"] : nil;
    controller.type =self.representedObject[@"photo2"] ? @"video" : @"album";
    controller.countInAlbum = self.representedObject[@"count"];
    NSLog(@"%@", self.representedObject);
    
    [self presentViewControllerAsSheet:controller];
    
}
- (void)mouseEntered:(NSEvent *)theEvent{
    
    [[NSCursor pointingHandCursor]set];
//    self.view.layer.backgroundColor=[[NSColor colorWithCalibratedRed:0.80 green:0.80 blue:0.80 alpha:0.3]CGColor];
//    self.view.layer.borderColor=[[NSColor colorWithCalibratedRed:0.80 green:0.80 blue:0.80 alpha:0.8]CGColor];
//    self.view.layer.borderWidth=1;
    _removeItem.hidden=NO;
    _moveToAlbum.hidden=NO;
//    if(self.representedObject[@"count"]){
//        NSAttributedString *countAttrString = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@", self.representedObject[@"count"] ]attributes:@{NSForegroundColorAttributeName:[NSColor whiteColor]}];
//        _countLabel.attributedStringValue=countAttrString;
//        _countLabel.hidden=NO;
//    }
}

- (void)mouseExited:(NSEvent *)theEvent{
    [[NSCursor currentCursor]set];
//    self.view.layer.backgroundColor=[[NSColor colorWithCalibratedRed:0.80 green:0.80 blue:0.80 alpha:0.0]CGColor];
//    self.view.layer.borderWidth=0;
    _removeItem.hidden=YES;
    _moveToAlbum.hidden=YES;
//    _countLabel.hidden=YES;
 
}
-(void)rightMouseDown:(NSEvent *)theEvent
{
 
   
    NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
    [theMenu insertItemWithTitle:@"Show album names" action:@selector(showAlbumNames) keyEquivalent:@"" atIndex:0];
    [theMenu insertItemWithTitle:@"Move item to the end" action:@selector(MoveItemToTheEnd) keyEquivalent:@"" atIndex:1];
    [theMenu insertItemWithTitle:@"Move item to the beginning" action:@selector(MoveItemToTheBeginning) keyEquivalent:@"" atIndex:2];
    
    
    [NSMenu popUpContextMenu:theMenu withEvent:theEvent forView:self.view];
    
    return [super rightMouseDown:theEvent];
    
}
-(void)showAlbumNames{
//    id animator = [[CustomAnimator alloc] init];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowNamesController" object:nil];
    
   
    
}
-(void)MoveItemToTheEnd{
    NSCollectionView* parent = self.collectionView;
    NSLog(@"Selected object %@", self.representedObject);
     NSLog(@"Last object %@", [[parent content]lastObject]);
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/video.reorderAlbums?owner_id=%@&album_id=%@&after=%@&access_token=%@&v=%@", self.representedObject[@"owner_id"],self.representedObject[@"id"],  [[parent content]lastObject][@"id"], _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *videoReorderAlbumsResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"%@", videoReorderAlbumsResp);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [ parent moveItemAtIndexPath:[NSIndexPath indexPathForItem:[[parent content] indexOfObject:self.representedObject] inSection:0] toIndexPath:[NSIndexPath indexPathForItem:[[parent content] indexOfObject:[[parent content]lastObject ]]inSection:0]];
        });
        
    }] resume];
}

-(void)MoveItemToTheBeginning{
    NSCollectionView* parent = self.collectionView;
//    NSLog(@"Selected object %@", self.representedObject);
//    NSLog(@"Last object %@", [[parent content]firstObject]);
//     NSLog(@"Index of self %li", [[parent content] indexOfObject:self.representedObject]);
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/video.reorderAlbums?owner_id=%@&album_id=%@&before=%@&access_token=%@&v=%@", self.representedObject[@"owner_id"],self.representedObject[@"id"],  [parent content][2][@"id"], _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *videoReorderAlbumsResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"%@", videoReorderAlbumsResp);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
//            [parent reloadData];
//            id object = [self.representedObject copy];
            [ parent moveItemAtIndexPath:[NSIndexPath indexPathForItem:[[parent content] indexOfObject:self.representedObject] inSection:0] toIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]];
            
//            NSMutableArray *aa = [[NSMutableArray alloc]initWithArray:[[parent content]copy]];
//            [aa removeObjectAtIndex:[[parent content] indexOfObject:object]];
//            [aa insertObject:object atIndex:2];
//            [parent setContent: aa];
//            [parent reloadData];
//            [parent moveItemAtIndexPath:[NSIndexPath indexPathForItem:self inSection:0] toIndexPath:[NSIndexPath indexPathForItem:[parent itemAtIndex:[[parent content]count] ] inSection:0]];
           
        });
        
    }] resume];
}
@end
