//
//  TumblrPosts.m
//  MasterAPI
//
//  Created by sim on 09.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "TumblrPosts.h"

#import "TumblrPostCell.h"
@interface TumblrPosts ()<NSTableViewDelegate, NSTableViewDataSource, NSSearchFieldDelegate, NSURLDownloadDelegate, NSURLSessionTaskDelegate>

@end

@implementation TumblrPosts

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    manager = [[NSFileManager alloc]init];
    PostsList.delegate=self;
    PostsList.dataSource=self;
    searchByTagBar.delegate=self;
    altSizeImages = [[NSMutableArray alloc]init];
    indexCurrentPhoto=0;
    _tumblrClient = [[TumblrClient alloc]initWithTokensFromCoreData];
    [[postsListScroll contentView]setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(viewDidScroll:) name:NSViewBoundsDidChangeNotification object:nil];
    postsData = [[NSMutableArray alloc]init];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadPostsByAccount:) name:@"loadPostsByAccount" object:nil];
    
}
-(void)loadPostsByAccount:(NSNotification*)notification{
    NSLog(@"%@", notification.userInfo);
    ownerBlog = notification.userInfo[@"url"];
    [self loadPosts:NO];
    
    
}
- (IBAction)downloadSelectedFile:(id)sender {
    NSView *parentView = [sender superview];
    NSInteger row = [PostsList rowForView:parentView];
    progressDownloadBar.maxValue=1;
    
    [self selectDirectoryToDownload:[postsData[row][@"photo"][@"original"] lastPathComponent] :postsData[row][@"photo"][@"original"]];
    
}
-(void)selectDirectoryToDownload:(id)nameOfFile :(id)urlToDownloadFile{
    
        fileName = nameOfFile;
        NSSavePanel* openDlg = [NSSavePanel savePanel];

        [openDlg setNameFieldStringValue:fileName];
    
        if ( [openDlg runModal] == NSFileHandlingPanelOKButton)
        {
            
            
            selectedDirectoryPath = [[openDlg URL] absoluteString];
            selectedDirectoryPath = [selectedDirectoryPath stringByDeletingLastPathComponent];
            NSLog(@"%@", [selectedDirectoryPath stringByDeletingLastPathComponent] );
            if(selectedDirectoryPath){
                NSLog(@"%@", selectedDirectoryPath );
                
                NSURLSessionConfiguration *backgroundConfigurationObject = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"myBackgroundSessionIdentifier1"];
                _backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfigurationObject delegate:self delegateQueue:[NSOperationQueue mainQueue]];
                NSURLSessionDownloadTask *downloadTask = [_backgroundSession downloadTaskWithURL:[NSURL URLWithString:urlToDownloadFile]];
                [downloadTask resume];
            }
        }
}

-(void)searchFieldDidStartSearching:(NSSearchField *)sender{
    searchByTagMode = YES;
    postsDataCopy = [[NSMutableArray alloc]initWithArray:postsData];
    [postsData removeAllObjects];
    [self loadSearchByTagResults:NO];
}
-(void)searchFieldDidEndSearching:(NSSearchField *)sender{
    searchByTagMode = NO;
    postsData = postsDataCopy ;
    [PostsList reloadData];
}
- (IBAction)showPhotoSlider:(id)sender {
    
    NSView *parentView = [sender superview];
    NSInteger row = [PostsList rowForView:parentView];
    NSLog(@"%@",postsData[row]);
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    _myWindowContr = [story instantiateControllerWithIdentifier:@"PhotoController"];
    
    [_myWindowContr showWindow:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowPhotoSlider" object:nil userInfo:@{@"data" :postsData, @"current":postsData[row][@"current"]}];
}
-(void)loadSearchByTagResults:(BOOL)makeOffset{
    if(makeOffset){
        offsetLoadPosts = offsetLoadPosts + 20;
    }else{
        offsetLoadPosts = 0;
        [postsData removeAllObjects];
    }
    
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSString *timestamp =  [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]*1000];
    NSString *querySearchString = [searchByTagBar.stringValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    [_tumblrClient APIRequest:nil rmethod:@"tagged" query:@{@"tag":querySearchString, @"limit":@20, @"before":timestamp} handler:^(NSData *data) {
        NSDictionary *taggedSearchResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//        NSLog(@"%@", taggedSearchResp);
        for(NSDictionary *i in taggedSearchResp[@"response"]){
            if([i[@"type"] isEqual:@"photo"]){
                for(NSDictionary *a in i[@"photos"]){
                    [altSizeImages removeAllObjects];
                    
                    //                    [postsData addObject:@{@"photo":a[@"photos"][0][@"alt_sizes"][0]}];
                    for(NSDictionary *f in a[@"alt_sizes"]){
                        //                        if([f[@"height"] intValue]<300 && [f[@"height"] intValue] >250 ){
                        [altSizeImages addObject:@{@"url":f[@"url"], @"height":f[@"height"], @"width":f[@"width"]}];
                        //                        }
                    }
                    
                }
                [postsData addObject:@{@"photo":@{@"url":altSizeImages[2][@"url"], @"height":altSizeImages[2][@"height"],@"width":altSizeImages[2][@"width"]}}];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [PostsList reloadData];
        });

    }];
}
-(void)viewDidScroll:(NSNotification*)notification{
    if(notification.object == postsListClip){
        NSInteger scrollOrigin = [[postsListScroll contentView]bounds].origin.y+NSMaxY([postsListScroll visibleRect]);
        //    NSInteger numberRowHeights = [subscribersList numberOfRows] * [subscribersList rowHeight];
        NSInteger boundsHeight = PostsList.bounds.size.height;
        //    NSInteger frameHeight = subscribersList.frame.size.height;
        if (scrollOrigin == boundsHeight+2) {
            //Refresh here
            //         NSLog(@"The end of table");
            //            if([[_youtubeRWData readSubscriptions] count] == 0 && pageToken!=nil){
            if(searchByTagMode){
//                [self loadSearchByTagResults:YES];
            }else{
                [self loadPosts:YES];
            }
            //            }
        }
    }
}
- (IBAction)showPosts:(id)sender {
    ownerBlog =ownerField.stringValue;
    [self loadPosts:NO];
}
- (IBAction)download:(id)sender {
    NSString *limit=countField.stringValue;
    NSString *owner=[NSString stringWithFormat:@"blog/%@",ownerField.stringValue];
    __block NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    NSLog(@"%@", paths);
    __block int counter=0;
    __block NSString *basePath;
    
       __block NSMutableArray *links = [[NSMutableArray alloc]init];
    [_tumblrClient APIRequest:owner rmethod:@"posts/photo" query:@{@"limit":limit} handler:^(NSData *data) {
        NSDictionary *postsResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//        NSString *rrresp = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
//        NSLog(@"%@", rrresp);
        for(NSDictionary *i in postsResponse[@"response"][@"posts"]){
            
            for(NSDictionary *a in i[@"photos"]){
                [links addObject:a[@"original_size"][@"url"]];
               
            }
        }
        basePath = [paths[0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", ownerField.stringValue]];
        [manager createDirectoryAtPath:basePath withIntermediateDirectories:0 attributes:0 error:nil];
        progressDownloadBar.maxValue=[links count];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            for(NSString *i in links){
                semaphore =  dispatch_semaphore_create(0);
                [[_tumblrClient.TSession downloadTaskWithURL:[NSURL URLWithString:i] completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    //                    NSData *photo = [[NSData alloc]initWithData:data];
                    NSString *path = [NSString stringWithFormat:@"%@/photo_%i.png", basePath, counter];
                    NSLog(@"%@", path);
                    NSLog(@"%@", i);
                    if([manager moveItemAtURL:location toURL:[NSURL fileURLWithPath:path] error:nil]){
                        dispatch_semaphore_signal(semaphore);
                        NSLog(@"Saved");
                    }else{
                        NSLog(@"Not saved");
                    };
                    
                }]resume];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                dispatch_semaphore_signal(semaphore);
                counter++;
                dispatch_async(dispatch_get_main_queue(), ^{
                    progressDownloadBar.doubleValue = counter;
                });
                
            }
            
        });
        
    }];
}
-(void)loadPosts:(BOOL)makeOffset{
    
//    NSString *limit=countField.stringValue;
    NSString *owner=[NSString stringWithFormat:@"blog/%@",ownerBlog];
    
    if(makeOffset){
        offsetLoadPosts = offsetLoadPosts + 20;
        
    }else{
        offsetLoadPosts = 1;
        indexCurrentPhoto=0;
        [postsData removeAllObjects];
    }
    if(owner){
        [_tumblrClient APIRequest:owner rmethod:@"posts/photo" query:@{@"limit":@20, @"offset":[NSNumber numberWithInt:offsetLoadPosts]} handler:^(NSData *data) {
            NSDictionary *postsResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            //        NSString *rrresp = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
//                        NSLog(@"%@", postsResponse);
            for(NSDictionary *i in postsResponse[@"response"][@"posts"]){
                NSString *url;
//                NSString *height;
//                NSString *width;
                NSString *original;
                NSString *caption;
                caption = i[@"caption"] && i[@"caption"]!=nil?i[@"caption"]:@"";
           
           
               
                
                for(NSDictionary *a in i[@"photos"]){
                    original = a[@"original_size"][@"url"];
                    [altSizeImages removeAllObjects];
                    //                    [postsData addObject:@{@"photo":a[@"photos"][0][@"alt_sizes"][0]}];
                    for(NSDictionary *f in a[@"alt_sizes"]){
//                        if([f[@"height"] intValue]<300 && [f[@"height"] intValue] >250 ){
                        [altSizeImages addObject:@{@"url":f[@"url"], @"height":f[@"height"], @"width":f[@"width"]}];
//                        }
                        
                        
                        
                    }
                    
                }
                indexCurrentPhoto++;
                url = [altSizeImages count]>=5 ? altSizeImages[4][@"url"] : [altSizeImages count]>=4 ? altSizeImages[3][@"url"] : [altSizeImages count]>=3 ? altSizeImages[2][@"url"] : [altSizeImages count]>=2 ? altSizeImages[1][@"url"] : @"";
                [postsData addObject:@{@"current":[NSNumber numberWithInt:indexCurrentPhoto], @"photo":@{@"url":url, @"caption":caption, @"original":altSizeImages[1][@"url"]}}];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [PostsList reloadData];
            });
        }];
    };
}
//-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
//    TumblrPostCell *cell = [[TumblrPostCell alloc]init];
////    NSSize imageSize;
////    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//    
////        NSImage *image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:postsData[row][@"photo"]]];
////        //    CGSize layoutSize =  [cell layout:NSLayoutPriorityFittingSizeCompression];
////        NSImageRep *rep = [[image representations] objectAtIndex:0];
////        imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
////        image.size=imageSize;
//
////    cell.postPhoto.frame=NSMakeRect(0, 0, rep.pixelsWide, rep.pixelsHigh);
//        
////     });
////    NSLog(@"%@", postsData[row][@"photo"][@"height"]);
//     return [postsData[row][@"photo"][@"height"] intValue];
//    
//}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [postsData count];
}
-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    TumblrPostCell *cell = [[TumblrPostCell alloc]init];
    cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
    NSString *caption = [NSString stringWithFormat:@"<html><head><style>h2,h1,h3,p,a{font-size:12;text-decoration:none;color:black}</style></head><body><span style='font-family:Helvetica;font-size:12'>%@</span></body></html>",postsData[row][@"photo"][@"caption"]];
     NSAttributedString *htmlCaption = [[NSAttributedString alloc] initWithData:[caption dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}  documentAttributes:nil  error:nil] ;
     cell.caption.attributedStringValue=htmlCaption;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSBitmapImageRep *repr = [[NSBitmapImageRep alloc]initWithData:[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:postsData[row][@"photo"][@"url"]]]];
//        [repr setProperty:NSImageLoopCount withValue:@1];
//        NSData *data1 = [repr representationUsingType:NSGIFFileType properties:@{NSImageLoopCount:@1}];
//        NSImage *image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:postsData[row][@"photo"][@"url"]]];
//
        NSData *datao = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:postsData[row][@"photo"][@"url"]]];
//        NSImageRep *rep = [[image representations] objectAtIndex:0];
       NSImage *image = [[NSImage alloc]initWithData:datao];
//        NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
//            [image setSize:imageSize];
//
            
//            cell.postPhoto.wantsLayer=YES;
//            cell.postPhoto.layer.masksToBounds=YES;
            
//            [cell.postPhoto setAnimates:YES];
//            [cell.postPhoto cacheDisplayInRect:NSMakeRect(0, 0, 300, 300) toBitmapImageRep:repr];
//            cell.postPhoto.canDrawSubviewsIntoLayer = YES;
//            [cell.postPhoto setImageScaling:NSImageScaleProportionallyUpOrDown];
//            [image setCacheMode:NSImageCacheAlways];
            
            [cell.postPhoto setImage:image];
           
            
        });
    });
    
    return cell;
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
    
    NSString *destinationURL;

    destinationURL = [[selectedDirectoryPath  stringByReplacingOccurrencesOfString:@"file:" withString:@"" ] stringByAppendingPathComponent:fileName];

    NSLog(@"%@", selectedDirectoryPath);
    NSLog(@"%@", fileName);
    NSLog(@"%@", destinationURL);
    NSError *error = nil;
    //    NSLog(@"%@", destinationURL);
    //    [manager replaceItemAtURL:location withItemAtURL:[NSURL fileURLWithPath:destinationURL] backupItemName:nil options:NSFileManagerItemReplacementUsingNewMetadataOnly resultingItemURL:nil error:&error];
    [manager moveItemAtURL:location toURL:[NSURL fileURLWithPath:destinationURL]  error:&error];
//    next=YES;
//    downloading=NO;
 
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.backgroundSession finishTasksAndInvalidate];
        progressDownloadBar.doubleValue=1;
//        _downloadAndUploadProgress.doubleValue=1;
//            _downloadAndUploadProgressLabel.stringValue = [NSString stringWithFormat:@"%i/%i", 1, 1];
    });
        
    
}
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
//    progressDownloadBar.maxValue=totalBytesExpectedToSend;
//    progressDownloadBar.doubleValue=totalBytesSent;
    
    
}
@end
