//
//  customViewCollectionItem.m
//  vkapp
//
//  Created by sim on 25.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "customViewCollectionItem.h"
#import "moveToAlbumViewController.h"
#import "URLsViewController.h"
#import "RemoveVideoAndPhotoItemsViewController.h"
@interface customViewCollectionItem ()<NSURLSessionDelegate, NSURLSessionDownloadDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate>

@end

@implementation customViewCollectionItem
@synthesize  backgroundSession;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createTrackingArea];
    
    self.view.wantsLayer=YES;
    self.view.layer.masksToBounds=YES;
    self.view.layer.cornerRadius=5;
    _downloadButton.hidden=YES;
    _app = [[appInfo alloc]init];
    manager = [NSFileManager defaultManager];
    _countInAlbum.wantsLayer=YES;
    _countInAlbum.layer.masksToBounds=YES;
    _countInAlbum.layer.cornerRadius=5;
    _countInAlbum.layer.opacity=.8;
    progress = 0.0;
    expectedBytes = 0.0;
     _removeItem.hidden=YES;
    _closeProgressOver.wantsLayer=YES;
    _closeProgressOver.layer.masksToBounds=YES;
    _closeProgressOver.layer.cornerRadius=19/2;
    _downloadAndUploadProgressLabel.wantsLayer=YES;
    _downloadAndUploadProgressLabel.layer.masksToBounds=YES;
    _downloadAndUploadProgressLabel.layer.cornerRadius=5;
    _downloadAndUploadStatusOver.wantsLayer=YES;
    _downloadAndUploadStatusOver.layer.masksToBounds=YES;
    _downloadAndUploadStatusOver.layer.cornerRadius=5;
    _uploadByURLsButton.hidden=YES;
    _uploadPhoto.hidden=YES;

}
- (IBAction)moveToAlbum:(id)sender {
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    moveToAlbumViewController *controller = [story instantiateControllerWithIdentifier:@"MoveToAlbumPopup"];
    controller.mediaType=@"photo";
    controller.photoId=self.representedObject[@"items"][@"id"];
    controller.selectedItems = [[NSMutableArray alloc] initWithArray:[[self.collectionView selectionIndexes] count]>0 ? [self.collectionView.content objectsAtIndexes:[self.collectionView selectionIndexes]] : @[self.representedObject]];
    controller.ownerId=self.representedObject[@"owner_id"];
    //    controller.publicOrOwnerOfAlbums =
    
    controller.albumIdToGetVideos = !self.representedObject[@"photo2"] ? self.representedObject[@"id"] : nil;
    controller.type =self.representedObject[@"photo2"] ? @"item" : @"album";
//    controller.countInAlbum = [selectedItems count];
    NSLog(@"%@", self.representedObject);
    
    [self presentViewControllerAsSheet:controller];
}

- (void)getStringWithURLs:(NSNotification*)notification{
    
    [self prepareURLsForUpload:notification.userInfo[@"urls_string"]];
//    NSLog(@"dddd");
     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"uploadPhotoURLs" object:nil];
}

- (void)setProgress{
//     self.downloadAndUploadProgress.maxValue=expectedBytes;
//    self.downloadAndUploadProgress.doubleValue=progress;
    NSIndexPath *indexPath =[NSIndexPath indexPathForItem:[self.collectionView.content indexOfObject:selectedObject] inSection:0];
    customViewCollectionItem *albumItem =  (customViewCollectionItem*)[self.collectionView itemAtIndexPath:indexPath];
    albumItem.downloadAndUploadProgressLabel.stringValue = [NSString stringWithFormat:@"%li/%lu",uploadCounter == 0 ? 0 : uploadCounter+1, [filesForUpload count] ];
}

- (void)prepareURLsForUpload:(NSString*)urlsString{
   filesForUpload = [self urlsFromString:urlsString];
    NSLog(@"%@", filesForUpload);
    if([filesForUpload count]>0){
        [self getUploadURL:albumToUploadTo completion:^(NSData *serverURL) {
            if(serverURL){
                NSDictionary *getServerResponse = [NSJSONSerialization JSONObjectWithData:serverURL options:0 error:nil];
                uploadURL = getServerResponse[@"response"][@"upload_url"];
                [self prepareForUpload];
            }else{
                NSLog(@"UPLOAD URL NOT RECEIVED");
            }
        }];
    }
}

- (NSMutableArray*)urlsFromString:(NSString*)fullString{
    NSMutableArray *urls = [[NSMutableArray alloc]init];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?i)\\b((?:https?|ftp:(?:/{1,3}|[a-z0-9%])|www\\d{0,3}[.]|[\\w0-9.\\-]+[.][\\w]{2,4}/)(?:[^|\\U00000410-\\U0000044F\\U00002700-\\U000027BF\\U0001F300-\\U0001F5FF\\U0001F910-\\U0001F9C0\\U00002070-\\U0000209C\\s()<>]+|\\(([^|\\s()<>]+|(\\([^|\\U00000410-\\U0000044F\\U00002700-\\U000027BF\\U0001F300-\\U0001F5FF\\U0001F910-\\U0001F9C0\\U00002070-\\U0000209C\\s()<>]+\\)))*\\))+(?:\\(([^|\\U00000410-\\U0000044F\\U00002700-\\U000027BF\\U0001F300-\\U0001F5FF\\U0001F910-\\U0001F9C0\\U00002070-\\U0000209C\\s()<>]+|(\\([^|\\s()<>]+\\)))*\\)|[^|\\U00000410-\\U0000044F\\U00002700-\\U000027BF\\U0001F300-\\U0001F5FF\\U0001F910-\\U0001F9C0\\U00002070-\\U0000209C\\s`!()\\[\\]{};:'\".,<>?«»“”‘’]))" options:NSRegularExpressionCaseInsensitive error:nil];
    //    NSUInteger numberOfMatches = [regex numberOfMatchesInString:fullString options:0 range:NSMakeRange(0, [_receivedData[@"site"] length])];
    NSArray *matches = [regex matchesInString:fullString options:0 range:NSMakeRange(0, [fullString length])];
//            NSLog(@"%li", [matches count]);
    //        NSLog(@"Found %li",numberOfMatches);
//    NSRange foundRange = [string.mutableString rangeOfString:[fullString substringWithRange:match.range]  options:NSCaseInsensitiveSearch];
//    if (foundRange.location != NSNotFound) {
        for (NSTextCheckingResult *match in matches){
            [urls addObject:[fullString substringWithRange:match.range]];
            
        }
//    }
    return urls;
}

- (NSString*)createRandomName{
    NSString *alphabetPlusDigits = @"0123456789abcdefghijklmopqrstuvwxyz";
    int length =  (int) [alphabetPlusDigits length];
    
    NSMutableString *nonceString = [[NSMutableString alloc]init];
    for(NSInteger i=0; i<17; i++){
        i++;
        [nonceString appendString:[NSString stringWithFormat:@"%C", [alphabetPlusDigits characterAtIndex:arc4random_uniform(length)]]];
        
    }
    return [nonceString stringByAppendingPathExtension:@"jpg"];
}

- (IBAction)uploadButtonAction:(id)sender {
//    [self removeDownloadAndUploadStatuOver];
    selectedObject = [[NSMutableDictionary alloc]init];
    selectedObject = self.representedObject;
    albumToUploadTo = selectedObject[@"id"] ;
    ownerId = [NSString stringWithFormat:@"%@",self.representedObject[@"owner"] ];
    [self setProgress];
    [self chooseDirectoryToUpload];

}

- (IBAction)uploadByURLsAction:(id)sender {
//   [self removeDownloadAndUploadStatuOver];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getStringWithURLs:) name:@"uploadPhotoURLs" object:nil];
    selectedObject = [[NSMutableDictionary alloc]init];
    selectedObject = self.representedObject;
    albumToUploadTo = selectedObject[@"id"];
    
    ownerId = [NSString stringWithFormat:@"%@",self.representedObject[@"owner"] ];
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Fourth" bundle:nil];
    URLsViewController *contr = [story instantiateControllerWithIdentifier:@"UploadURLsViewController"];
    contr.mediaType=@"photo";
    [self presentViewControllerAsModalWindow:contr];
    [self setProgress];

  
}

- (void)removeDownloadAndUploadStatuOver{
    if(selectedObject){
        NSIndexPath *indexPath =[NSIndexPath indexPathForItem:[self.collectionView.content indexOfObject:selectedObject] inSection:0];
        customViewCollectionItem *albumItem =  (customViewCollectionItem*)[self.collectionView itemAtIndexPath:indexPath];
        selectedObject[@"busy"]=@0;
//        albumItem.downloadAndUploadStatusOver.hidden=YES;
        [self.collectionView reloadItemsAtIndexPaths:[NSSet setWithObject:indexPath]];
    }
}

- (void)addProgressView{
    _indicator = [[ NSProgressIndicator alloc]initWithFrame:NSMakeRect(0, 0, 100, 10)];
    [_indicator setStyle:NSProgressIndicatorBarStyle];
    _indicator.indeterminate=NO;
    [self.view addSubview:_indicator];
       self.representedObject[@"state"]=@1;
    NSIndexPath *indexPath =[NSIndexPath indexPathForItem:[self.collectionView.content indexOfObject:self.representedObject] inSection:0];
    [self.collectionView reloadItemsAtIndexPaths:[NSSet setWithObject:indexPath]];
 
}

- (IBAction)removeItem:(id)sender {
    
    //    NSLog(@"%@", colV);
    NSLog(@"%@", self.representedObject);
    if(self.representedObject[@"items"][@"photoBig"]){
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/photos.delete?owner_id=%@&photo_id=%@&access_token=%@&v=%@", self.representedObject[@"owner_id"], self.representedObject[@"items"][@"id"], _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary *photoDeleteResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@", photoDeleteResponse);
            //            NSCollectionView *colV = [[sender superview]superview];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"removeObjectPhoto" object:nil userInfo:@{@"index":[NSNumber numberWithInteger:[self.collectionView.content indexOfObject:self.representedObject]]}];
            //            [colV reloadData];
        }] resume];
    }
    else{
        NSLog(@"%@", self.representedObject[@"owner"]);
        if(![[NSString stringWithFormat:@"%@", self.representedObject[@"owner"]] isEqual:_app.person]){
            baseURL =[NSString stringWithFormat:@"https://api.vk.com/method/photos.deleteAlbum?group_id=%i&album_id=%@&access_token=%@&v=%@", abs([self.representedObject[@"owner"] intValue]), self.representedObject[@"id"], _app.token, _app.version];
            
        }else{
            baseURL = [NSString stringWithFormat:@"https://api.vk.com/method/photos.deleteAlbum?owner_id=%@&album_id=%@&access_token=%@&v=%@",_app.person, self.representedObject[@"id"], _app.token, _app.version];
        }
        [[_app.session dataTaskWithURL:[NSURL URLWithString:baseURL]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary *photoDeleteResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@", photoDeleteResponse);
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"removePhotoAlbum" object:nil userInfo:@{@"index":[NSNumber numberWithInteger:[self.collectionView.content indexOfObject:self.representedObject]]}];
            
        }] resume];
        //        NSLog(@"%@", self.representedObject);
    }
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.alignment=NSTextAlignmentCenter;
    if(selected){
        //        if(self.highlightState==0){
        //            self.view.layer.backgroundColor=[[NSColor whiteColor] CGColor];
        //        }
        //        else if(self.highlightState==1){
        //            self.view.layer.backgroundColor=[[NSColor blueColor] CGColor];
        if(!self.representedObject[@"items"][@"photoBig"]){
            NSAttributedString *attrTitle = [[NSAttributedString alloc]initWithString:_textLabel.stringValue attributes:@{NSForegroundColorAttributeName:[NSColor whiteColor], NSParagraphStyleAttributeName:paragraphStyle}];
            
            _textLabel.attributedStringValue=attrTitle;
        }else{
            _textLabel.stringValue=@"";
        }
//        self.view.layer.backgroundColor=[[NSColor colorWithCalibratedRed:0.30 green:0.70 blue:0.90 alpha:0.8]CGColor];
        self.view.layer.backgroundColor=[[NSColor blueColor]CGColor];
        self.view.layer.borderColor=[[NSColor colorWithCalibratedRed:0.10 green:0.60 blue:0.90 alpha:1.0]CGColor];
        self.view.layer.borderWidth=1;
        //        }
        //        else if(self.highlightState==2){
        //            self.view.layer.backgroundColor=[[NSColor redColor] CGColor];
        //        }
    }
    else{
        if(!self.representedObject[@"items"][@"photoBig"]){
            NSAttributedString *attrTitle = [[NSAttributedString alloc]initWithString:_textLabel.stringValue attributes:@{NSForegroundColorAttributeName:[NSColor blackColor],NSParagraphStyleAttributeName:paragraphStyle}];
            _textLabel.attributedStringValue=attrTitle;
        }else{
            _textLabel.stringValue = @"";
        }
            self.view.layer.backgroundColor=[[NSColor clearColor] CGColor];
            self.view.layer.borderColor=[[NSColor clearColor]CGColor];
            self.view.layer.borderWidth=0;
      
    }
}

- (IBAction)attachAlbum:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addToAttachments" object:nil userInfo:@{@"type":@"album", @"data":[self representedObject]}];
    NSLog(@"%@", self.representedObject);
}

-(void)createTrackingArea{
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

- (void)mouseEntered:(NSEvent *)theEvent{
  
//    [[NSCursor pointingHandCursor]set];
    //    self.view.layer.backgroundColor=[[NSColor colorWithCalibratedRed:0.80 green:0.80 blue:0.80 alpha:0.3]CGColor];
    //    self.view.layer.borderColor=[[NSColor colorWithCalibratedRed:0.80 green:0.80 blue:0.80 alpha:0.8]CGColor];
    //     self.view.layer.borderWidth=1;
    if(self.collectionView.isSelectable){
        _moveToAlbumBut.hidden = self.representedObject[@"items"][@"photoBig"] ? NO : YES;
        _textLabel.hidden = self.representedObject[@"items"][@"photoBig"] ? YES : NO;
        
        if( [self.representedObject[@"owner"] intValue]!= [_app.person intValue] && ![self.representedObject[@"user_groups"] containsObject:[NSString stringWithFormat:@"%@", self.representedObject[@"owner"]]]){
            _downloadButton.hidden=NO;
            _uploadPhoto.hidden=YES;
            _removeItem.hidden=YES;
            _uploadByURLsButton.hidden=YES;
        }else{
            _downloadButton.hidden=NO;
            _uploadPhoto.hidden=NO;
            _removeItem.hidden=NO;
            _uploadByURLsButton.hidden=NO;
        }
        if(self.representedObject[@"items"][@"photoBig"]){
            _removeItem.hidden=NO;
        }
        else{
            overAlbumId = [self.representedObject[@"id"] intValue];
            NSLog(@"%li", overAlbumId);
            if(overAlbumId==-7 || overAlbumId==-6 || overAlbumId==-15){
                _uploadPhoto.hidden=YES;
                _removeItem.hidden=YES;
                _uploadByURLsButton.hidden=YES;
            }
        }
        
        
    }else{
        _downloadButton.hidden=YES;
        _uploadPhoto.hidden=YES;
        _removeItem.hidden=YES;
        _uploadByURLsButton.hidden=YES;
    }
 
    
}
- (void)mouseExited:(NSEvent *)theEvent{
    
    //  [[NSCursor currentCursor]set];
    //   self.view.layer.backgroundColor=[[NSColor whiteColor]CGColor];
    //     self.view.layer.borderWidth=0;
    _downloadButton.hidden=YES;
    _uploadPhoto.hidden=YES;
    _removeItem.hidden=YES;
    _moveToAlbumBut.hidden =  YES;
    _textLabel.hidden = self.representedObject[@"items"][@"photoBig"] ? YES : NO;
    _uploadByURLsButton.hidden=YES;
}
- (void)rightMouseDown:(NSEvent *)theEvent{
    theDropdownContextMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
    NSMenuItem *removeItemsItem = [[NSMenuItem alloc]initWithTitle:@"Remove items" action:@selector(removeItems) keyEquivalent:@""];
    [theDropdownContextMenu setAutoenablesItems:NO];
    
    [theDropdownContextMenu insertItem:removeItemsItem atIndex:0];
    [removeItemsItem setEnabled:[[self.collectionView selectionIndexes]count]];
//    [theDropdownContextMenu insertItemWithTitle:@"Show album names" action:@selector(showAlbumNames) keyEquivalent:@"" atIndex:1];
//    [theDropdownContextMenu insertItemWithTitle:@"Move item to the end" action:@selector(MoveItemToTheEnd) keyEquivalent:@"" atIndex:2];
//    [theDropdownContextMenu insertItemWithTitle:@"Move item to the beginning" action:@selector(MoveItemToTheBeginning) keyEquivalent:@"" atIndex:2];
    
    [NSMenu popUpContextMenu:theDropdownContextMenu withEvent:theEvent forView:self.view];
    
    return [super rightMouseDown:theEvent];
}

-(void)removeItems{
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Fifth" bundle:nil];
    RemoveVideoAndPhotoItemsViewController *contr = [story instantiateControllerWithIdentifier:@"RemoveVideoAndPhotoItemsViewController"];
    contr.mediaType=@"photo";
    contr.itemType=@"album";
    contr.receivedData = [self.collectionView.content objectsAtIndexes:[self.collectionView selectionIndexes]];
    
    [self presentViewControllerAsSheet:contr];
}
- (IBAction)closeProgressOver:(id)sender {
     [self.collectionView setSelectable:YES];
    _downloadAndUploadStatusOver.hidden=YES;
    _albumsCover.layer.opacity=1;
    self.representedObject[@"busy"]=@0;
    NSIndexPath *indexPath =[NSIndexPath indexPathForItem:[self.collectionView.content indexOfObject:self.representedObject] inSection:0];
//    [backgroundSession invalidateAndCancel];
   
    [self.collectionView reloadItemsAtIndexPaths:[NSSet setWithObject:indexPath]];
    
}

- (IBAction)downloadButtonAction:(id)sender{
    selectedObject = [[NSMutableDictionary alloc]init];
    selectedObject = self.representedObject;
    selectedObject[@"busy"]=@1;
    NSLog(@"%@", selectedObject);
    if(self.representedObject[@"items"][@"photoBig"]){
        [self chooseDirectory];
    }
    else{
        [self chooseDirectoryForAlbumDownload:selectedObject[@"title"] :selectedObject[@"id"] :_app.person :self.representedObject[@"size"]];
    }
}

- (void)getUploadURL:(id)album_id completion:(OnComplete)completion{
//   ownerId=[NSString stringWithFormat:@"%@",self.representedObject[@"owner"] ];
//    NSLog(@"%@", self.representedObject);
    if(ownerId && [ownerId isEqual:_app.person]){
        baseURL = [NSString stringWithFormat:@"https://api.vk.com/method/photos.getUploadServer?album_id=%@&v=%@&access_token=%@",album_id, _app.version, _app.token];
    }else{
        baseURL = [NSString stringWithFormat:@"https://api.vk.com/method/photos.getUploadServer?group_id=%i&album_id=%@&v=%@&access_token=%@", abs([ownerId intValue]), album_id, _app.version, _app.token];
    }
    
    [[_app.session dataTaskWithURL:[NSURL URLWithString:baseURL]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSDictionary *getServerResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//        if(getServerResponse[@"response"]){
//            uploadURL = getServerResponse[@"response"][@"upload_url"];
            completion(data);
//        }else{
//            NSLog(@"%@",getServerResponse );
//        }
        
    }] resume];
    
}

- (void)chooseDirectoryToUpload{
    
    NSOpenPanel* openDlgUpload = [NSOpenPanel openPanel];
    [openDlgUpload setPrompt:@"Select"];
    [openDlgUpload setCanChooseFiles:YES];
    [openDlgUpload setCanChooseDirectories:YES];
    [openDlgUpload setAllowsMultipleSelection:YES];
    [openDlgUpload setAllowedFileTypes:@[@"jpg",@"png",@"jpeg",@"gif"]];
    
    if ( [openDlgUpload runModal] == NSFileHandlingPanelOKButton)
    {
        filesForUpload = [openDlgUpload URLs];
        
        if([filesForUpload count]>0){
            [self getUploadURL:albumToUploadTo completion:^(NSData *serverURL) {
                if(serverURL){
                    NSDictionary *getServerResponse = [NSJSONSerialization JSONObjectWithData:serverURL options:0 error:nil];
                    uploadURL = getServerResponse[@"response"][@"upload_url"];
                     [self prepareForUpload];
                }else{
                    NSLog(@"UPLOAD URL NOT RECEIVED");
                }
            }];
        }
    }

    
}
- (void)chooseDirectoryForAlbumDownload:(id)title :(id)albumId :(id)owner :(id)size{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setPrompt:@"Select"];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanCreateDirectories:YES];
    if ( [openDlg runModal] == NSFileHandlingPanelOKButton){
        selectedDirectoryPath = [[openDlg URLs][0] absoluteString];
        if(selectedDirectoryPath){
           
         
            NSURLSessionConfiguration *backgroundConfigurationObject = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"myBackgroundSessionIdentifier1"];
            backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfigurationObject delegate:self delegateQueue:[NSOperationQueue mainQueue]];
            newDirectoryName = title;
            newDirectoryName = [newDirectoryName stringByRemovingPercentEncoding];
             selectedDirectoryPath = [[[selectedDirectoryPath stringByReplacingOccurrencesOfString:@"file://" withString:@""] stringByAppendingPathComponent:newDirectoryName ] stringByRemovingPercentEncoding];
            [manager createDirectoryAtPath:selectedDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
           
            BOOL isDir = NO;
           
             NSLog(@"%@",selectedDirectoryPath );
            if([manager fileExistsAtPath:selectedDirectoryPath isDirectory:&isDir]){
             
                NSIndexPath *indexPath =[NSIndexPath indexPathForItem:[self.collectionView.content indexOfObject:selectedObject] inSection:0];
                customViewCollectionItem *albumItem =  (customViewCollectionItem*)[self.collectionView itemAtIndexPath:indexPath];
                albumItem.albumsCover.layer.opacity=0.4;
                albumItem.downloadAndUploadStatusOver.hidden=NO;
                [self downloadAlbum:self.representedObject[@"id"] :_app.person :self.representedObject[@"size"]];
            }
        }
    }
    
}
- (void)chooseDirectory{
    
    NSSavePanel* openDlg = [NSSavePanel savePanel];
    [openDlg setNameFieldStringValue:[self.representedObject[@"items"][@"photoBig"] lastPathComponent]];
    [openDlg setCanCreateDirectories:YES];
    if ( [openDlg runModal] == NSFileHandlingPanelOKButton)
    {
        fileName = openDlg.nameFieldStringValue;
        currentFileName = fileName;
        selectedDirectoryPath = [[openDlg URL] absoluteString];
        selectedDirectoryPath = [selectedDirectoryPath stringByDeletingLastPathComponent];
        if(fileName){
            
            NSURLSessionConfiguration *backgroundConfigurationObject = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"myBackgroundSessionIdentifier"];
            backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfigurationObject delegate:self delegateQueue:[NSOperationQueue mainQueue]];
            selectedDirectoryPath = [selectedDirectoryPath stringByReplacingOccurrencesOfString:@"file:" withString:@""];
            
            _albumsCover.layer.opacity=0.4;
            _downloadAndUploadStatusOver.hidden=NO;
            [self downloadPhoto];
        }
        
    }
}

- (void)prepareForUpload{
    NSURLSessionConfiguration *backgroundConfigurationObject = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"UploadToAlbumSession"];
    backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfigurationObject delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    uploadCounter=0;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath =[NSIndexPath indexPathForItem:[self.collectionView.content indexOfObject:selectedObject] inSection:0];
        customViewCollectionItem *albumItem =  (customViewCollectionItem*)[self.collectionView itemAtIndexPath:indexPath];
        albumItem.representedObject[@"busy"]=@1;
            albumItem.downloadAndUploadProgress.maxValue=[filesForUpload count];
            albumItem.downloadAndUploadProgressLabel.stringValue = [NSString stringWithFormat:@"%li/%lu", uploadCounter, [filesForUpload count] ];
         [self.collectionView reloadItemsAtIndexPaths:[NSSet setWithObject:indexPath]];
        
        [self uploadToAlbum];
    });
}
- (void)uploadToAlbum{

//    fileName = [filesForUpload[uploadCounter] lastPathComponent];
    fileName = [self createRandomName];
        NSLog(@"%@", filesForUpload[uploadCounter]);
        NSLog(@"%@", fileName);
        NSLog(@"%@", uploadURL);
    
  
//        NSLog(@"%@", url);
    //    NSURLSessionUploadTask *uploadPhotoTask = [backgroundSession uploadTaskWithRequest:[NSURLRequest requestWithURL:url] fromFile:files[0]];
    //    [uploadPhotoTask resume];
    //    void (^uploadBlock)(NSString *file)=^(NSString *file){
    //
    //        NSBundle *mainBundle = [NSBundle mainBundle];
    //        NSString *filename = [file lastPathComponent];
//    NSData *contents = [[NSData alloc]initWithContentsOfFile:filesForUpload[uploadCounter]];
    NSLog(@"%li", uploadCounter);
   
    NSLog(@"%@", filesForUpload[uploadCounter]);
    NSData *contents;
    if([[NSString stringWithFormat:@"%@", filesForUpload[uploadCounter]] containsString:@"http"]){
        contents = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:filesForUpload[uploadCounter]]];
    }else{
        contents =[[NSData alloc]initWithContentsOfFile:filesForUpload[uploadCounter]];
    }
//    NSLog(@"%@", contents);
//    NSImage *image = [[NSImage alloc] initWithData:contents];
    if(contents){
       
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:uploadURL]];
        NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:contents];
        NSData *data1 = [imageRep representationUsingType:NSJPEGFileType properties:nil];
        
        //    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        [request setHTTPShouldHandleCookies:NO];
        [request setTimeoutInterval:30];
        [request setHTTPMethod:@"POST"];
        
        NSString *kStringBoundary = @"*******";
        [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",kStringBoundary] forHTTPHeaderField:@"Content-Type"];
        NSString *beginLine = [NSString stringWithFormat:@"\r\n--%@\r\n", kStringBoundary];
        NSMutableData *body = [NSMutableData data];
        
        [body appendData:[beginLine dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\";  filename=\"%@\"\r\n",fileName] dataUsingEncoding:NSUTF8StringEncoding]];
        //    [body appendData:[@"Content-Type: image/jpg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Length: %d\r\n\r\n",(int)[data1 length]] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:data1];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", kStringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:body];
        
        NSURLSessionDataTask *uploadTask = [backgroundSession dataTaskWithRequest:request];
        
        [uploadTask resume];
        [self.collectionView setSelectable:NO];
    }
    //        [[_app.session uploadTaskWithRequest:request fromData:body completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    //
    //
    //
    //        }]resume];
    //    sleep(3);
    //    };
    //    for(NSString *i in files){
    //        semaphore2 = dispatch_semaphore_create(0);
    ////        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //            uploadBlock(i);
    ////        });
    //
    //        dispatch_semaphore_wait(semaphore2, DISPATCH_TIME_FOREVER);
    //        dispatch_semaphore_signal(semaphore2);
    //        counter++;
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            _downloadAndUploadProgressLabel.stringValue = [NSString stringWithFormat:@"%lu/%lu", counter, [files count] ];
    //            _downloadAndUploadProgress.doubleValue=counter;
    //        });
    //
    //    }
}

- (void)downloadPhoto{
    _downloadAndUploadProgress.maxValue=1;
    void (^downloadPhotoBlock)() = ^{
        currentFileName =  fileName;
        downloadFile= [backgroundSession downloadTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", self.representedObject[@"items"][@"photoBig"]]]];
        downloading=YES;
        [downloadFile resume];
    };
    downloadPhotoBlock();
}
- (void)downloadAlbum:(id)albumId :(id)owner :(id)size{
    _downloadAndUploadProgress.maxValue=[size intValue];
    
    //    NSLog(@"%@ %@ %@", albumId, owner, size);
    void (^downloadAlbumBlock)() = ^{
        __block NSString *url;
        __block NSInteger step=0;
        
        while (step<[size intValue]){
            semaphore = dispatch_semaphore_create(0);
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/photos.get?owner_id=%@&album_id=%@&v=%@&access_token=%@&count=1&offset=%lu",self.representedObject[@"owner"], self.representedObject[@"id"], _app.version, _app.token, step]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *getAlbumResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                for(NSDictionary *i in getAlbumResponse[@"response"][@"items"]){
                    NSString *photoURL;
                    if(i[@"photo_1280"]){
                        photoURL = i[@"photo_1280"];
                    }
                    else{
                        photoURL = i[@"photo_807"] ?  i[@"photo_807"] : i[@"photo_604"] ;
                    }
                    
                    url = photoURL;
                    currentFileName = [url lastPathComponent];
                    downloadFile = [backgroundSession downloadTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", url]]];
                    next=NO;
                    downloading=YES;
                    [downloadFile resume];
                    //                    dispatch_async(dispatch_get_main_queue(), ^{
                    //                        _downloadAndUploadProgressLabel.stringValue = a[@"doc"][@"title"];
                    //                    });
                    //                     currentFileName = [NSString stringWithFormat:@"file%lu.png", step];
                }
                if(next){
                    dispatch_semaphore_signal(semaphore);
                    next=NO;
                }
                //                NSLog(@"%@", getAlbumResponse[@"response"][@"items"]);
            }] resume];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            dispatch_semaphore_signal(semaphore);
            sleep(1);
            step++;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *indexPath =[NSIndexPath indexPathForItem:[self.collectionView.content indexOfObject:selectedObject] inSection:0];
                customViewCollectionItem *albumItem =  (customViewCollectionItem*)[self.collectionView itemAtIndexPath:indexPath];
                albumItem.downloadAndUploadProgressLabel.stringValue = [NSString stringWithFormat:@"%lu/%i", step, [size intValue]];
                albumItem.downloadAndUploadProgress.doubleValue = step;
            });
            
        }
        [self.backgroundSession finishTasksAndInvalidate];
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(selectedDirectoryPath){
            downloadAlbumBlock();
        }
        else{
            NSLog(@"Select directory, please.");
            
        }
    });
    
}






-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
    
    NSString *destinationURL;
    if(!self.representedObject[@"items"][@"photoBig"]){
        destinationURL = [selectedDirectoryPath stringByAppendingPathComponent:currentFileName];
        //    NSString *destinationURL = [documentDirectoryPath stringByAppendingPathComponent:@"file.pdf"];
    }else{
        destinationURL = [selectedDirectoryPath  stringByAppendingPathComponent:currentFileName];
    }
    NSLog(@"%@", newDirectoryName);
    NSLog(@"%@", currentFileName);
    NSLog(@"%@", destinationURL);
    NSError *error = nil;
    //    NSLog(@"%@", destinationURL);
    //    [manager replaceItemAtURL:location withItemAtURL:[NSURL fileURLWithPath:destinationURL] backupItemName:nil options:NSFileManagerItemReplacementUsingNewMetadataOnly resultingItemURL:nil error:&error];
    [manager moveItemAtURL:location toURL:[NSURL fileURLWithPath:destinationURL]  error:&error];
    next=YES;
    downloading=NO;
    if(!self.representedObject[@"items"][@"photoBig"]){
        dispatch_semaphore_signal(semaphore);
    }else{
        [self.backgroundSession finishTasksAndInvalidate];
        [self.backgroundSession invalidateAndCancel];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _downloadAndUploadProgress.doubleValue=1;
            _downloadAndUploadProgressLabel.stringValue = [NSString stringWithFormat:@"%i/%i", 1, 1];
        });
        
    }
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    completionHandler(NSURLSessionResponseAllow);
    
//    progressUploadBar.doubleValue=0;
//    progressUploadBar.hidden=YES;
//    filePathLabel.hidden=YES;
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    NSDictionary *uploadPhotoResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//      NSLog(@"%@", uploadPhotoResponse);
        if(![uploadPhotoResponse[@"photos_list"] isEqual:@"[]"]){
            
            ownerId = [NSString stringWithFormat:@"%@", self.representedObject[@"owner"]];
            server =uploadPhotoResponse[@"server"];
            hash = uploadPhotoResponse[@"hash"];
            photoList =[uploadPhotoResponse[@"photos_list"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
            if(ownerId && [ownerId isEqual:_app.person]){
                baseURL = [NSString stringWithFormat:@"https://api.vk.com/method/photos.save?album_id=%@&server=%@&hash=%@&photos_list=%@&access_token=%@&v=%@", albumToUploadTo, server, hash, photoList, _app.token, _app.version];
            }else{
                baseURL = [NSString stringWithFormat:@"https://api.vk.com/method/photos.save?group_id=%i&album_id=%@&server=%@&hash=%@&photos_list=%@&access_token=%@&v=%@",abs([ownerId intValue]) , albumToUploadTo, server, hash, photoList, _app.token, _app.version];
            }
            [[_app.session dataTaskWithURL:[NSURL URLWithString:baseURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                //
                NSDictionary *savePhotoResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if(savePhotoResponse[@"error"]){
                    NSLog(@"%@", savePhotoResponse[@"error"]);
                
                }
                else{
                    if(uploadCounter+1==[filesForUpload count]){
                        
                        [backgroundSession finishTasksAndInvalidate];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSIndexPath *indexPath =[NSIndexPath indexPathForItem:[self.collectionView.content indexOfObject:selectedObject] inSection:0];
                            customViewCollectionItem *albumItem =  (customViewCollectionItem*)[self.collectionView itemAtIndexPath:indexPath];
                        
                            albumItem.downloadAndUploadProgressLabel.stringValue = [NSString stringWithFormat:@"%li/%lu",uploadCounter+1, [filesForUpload count] ];
                            
                            NSLog(@"All files successfully uploaded in to album");
                           
                        });
                       
                    }else{
                        uploadCounter++;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSIndexPath *indexPath =[NSIndexPath indexPathForItem:[self.collectionView.content indexOfObject:selectedObject] inSection:0];
                            customViewCollectionItem *albumItem =  (customViewCollectionItem*)[self.collectionView itemAtIndexPath:indexPath];
                            
                            albumItem.downloadAndUploadProgressLabel.stringValue = [NSString stringWithFormat:@"%li/%lu",uploadCounter, [filesForUpload count] ];
                        });
                        [self uploadToAlbum];
                    }
//                    NSLog(@"%@", savePhotoResponse);
                }
            }]resume];
        }else{
            if(uploadCounter+1<[filesForUpload count]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    uploadCounter++;
                    NSIndexPath *indexPath =[NSIndexPath indexPathForItem:[self.collectionView.content indexOfObject:selectedObject] inSection:0];
                    customViewCollectionItem *albumItem =  (customViewCollectionItem*)[self.collectionView itemAtIndexPath:indexPath];
                    
                    albumItem.downloadAndUploadProgressLabel.stringValue = [NSString stringWithFormat:@"%li/%lu",uploadCounter, [filesForUpload count] ];
                });
                [self uploadToAlbum];
            }
        }
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    NSIndexPath *indexPath =[NSIndexPath indexPathForItem:[self.collectionView.content indexOfObject:selectedObject] inSection:0];
    customViewCollectionItem *albumItem =  (customViewCollectionItem*)[self.collectionView itemAtIndexPath:indexPath];
    if(!albumItem.downloadAndUploadStatusOver.hidden){
        albumItem.downloadAndUploadProgress.maxValue= totalBytesExpectedToSend;
        albumItem.downloadAndUploadProgress.doubleValue = totalBytesSent;
        
    }
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    //    _downloadAndUploadProgress.maxValue = (double)totalBytesExpectedToWrite;
    //    _downloadAndUploadProgress.doubleValue = (double)totalBytesWritten;
    if((double)totalBytesExpectedToWrite == (double)totalBytesWritten){
        
    }
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    //    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"PDFDownloader" message:@"Download is resumed successfully" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    //    [alert show];
}


@end
