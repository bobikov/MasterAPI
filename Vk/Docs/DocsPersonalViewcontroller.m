//
//  DocsPersonalViewcontroller.m
//  vkapp
//
//  Created by sim on 07.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "DocsPersonalViewcontroller.h"
#import "ShowDocWindowController.h"
#import "ShowDocViewController.h"
#import "DocsCustomTableCellViewPersonal.h"
#import "addDocsByOwnerController.h"
@interface DocsPersonalViewcontroller ()<NSSearchFieldDelegate, NSTableViewDelegate, NSTableViewDataSource, NSURLDownloadDelegate, NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate>

@end

@implementation DocsPersonalViewcontroller

- (void)viewDidLoad {
    [super viewDidLoad];
    _app = [[appInfo alloc]init];
    docsDataCopy=[[NSMutableArray alloc]init];
    docsTableView.delegate=self;
    docsTableView.dataSource=self;
    searchDocsBar.delegate=self;
    docsData = [[NSMutableArray alloc]init];
//    [self loadDocs:_app.person];
    manager = [NSFileManager defaultManager];
    loadForAttachments = _recivedData[@"loadDocsForAttachments"] ? YES : NO;
    userGroupsByAdminData = [[NSMutableArray alloc]init];

    [self loadUserGroupsByAdmin];
    owner = owner == nil ? _app.person : owner;
    _captchaHandler = [[VKCaptchaHandler alloc]init];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(editDocs:) name:@"VKEditDocs" object:nil];
    [self setControlButtonsStoppedState];
}
-(void)viewDidAppear{
     [self loadDocs];
}
-(void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"ShowDoc"]){
        //        ShowDocWindowController *controller = (ShowDocWindowController *)segue.destinationController;
        ShowDocViewController *controller = (ShowDocViewController *)segue.destinationController;
        NSView *parentCell = [sender superview];
        NSInteger row = [docsTableView rowForView:parentCell];
        //        CGRect rect=CGRectMake(0, y, 0, 0);
        dataForUserInfo = docsData[row];
        NSLog(@"%@", dataForUserInfo);
        controller.receivedData=dataForUserInfo;
    }else if([segue.identifier isEqualToString:@"addDocsByOwnerSegue"]){
        addDocsByOwnerController *contr = (addDocsByOwnerController *)segue.destinationController;
        selectedItems = [[NSMutableArray alloc]initWithArray:[docsData objectsAtIndexes:[docsTableView selectedRowIndexes]]];
        contr.receivedData=[[NSMutableArray alloc]initWithArray:selectedItems];
    }
}

- (IBAction)addToAttachments:(id)sender {
    NSView *parentCell = [sender superview];
    NSInteger row = [docsTableView rowForView:parentCell];
    NSLog(@"%@",  docsData[row]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addToAttachments" object:nil userInfo:@{@"type":@"doc", @"data":docsData[row]}];
    
}

-(void)editDocs:(NSNotification*)notification{
    __block void(^editDocsBlock)(NSInteger, BOOL, NSString*, NSString*);
    NSDictionary *data=notification.userInfo;
    NSInteger checkIndex = [notification.userInfo[@"indexed"] intValue];
    NSInteger checkOwnerID = [notification.userInfo[@"ownerID"] intValue];
    tags = [data[@"tags"] isEqual:@""] ? nil : data[@"tags"];
    __block NSInteger offsetEditDocsWithCaptcha=0;
    
    selectedItems = [[NSMutableArray alloc]initWithArray:[docsData objectsAtIndexes:[docsTableView selectedRowIndexes]]];
    NSLog(@"%@", selectedItems);
    NSLog(@"%@", data);
    editDocsBlock = ^void(NSInteger offset, BOOL captcha, NSString *captcha_sid, NSString *captcha_key){
        stopFlag=NO;
        for(NSDictionary *i in selectedItems){
            NSString *newTitle = [data[@"title"] isEqual:@""] ?  i[@"title"] : data[@"title"];
            newTitle = checkIndex ? [NSString stringWithFormat:@"%@_%li", newTitle, [selectedItems indexOfObject:i]] : newTitle;
            newTitle =  checkOwnerID ? [NSString stringWithFormat:@"%@_id%@", newTitle, owner] : newTitle;
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/docs.edit?owner_id=%@&doc_id=%@%@%@&access_token=%@&v=%@%@%@", i[@"owner_id"], i[@"id"], tags ? [NSString stringWithFormat:@"&tags=%@", tags] : @"", newTitle ? [NSString stringWithFormat:@"&title=%@", newTitle] : @"", _app.token, _app.version, captcha ? [NSString stringWithFormat:@"&captcha_sid=%@", captcha_sid ]:@"", captcha ? [NSString stringWithFormat:@"&captcha_key=%@", captcha_key] : @""]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if(data){
                    NSDictionary *editDocsResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSLog(@"%@", editDocsResp);
                    if(editDocsResp[@"error"]){
                        stopFlag=YES;
                        if([editDocsResp[@"error"][@"error_code"] intValue]==14){
                            dispatch_async(dispatch_get_main_queue(), ^{

                                NSInteger result = [[_captchaHandler handleCaptcha:editDocsResp[@"error"][@"captcha_img"] ]runModal];
                                
                                if(result == NSAlertFirstButtonReturn){
                                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                        
                                        
                                        editDocsBlock(offsetEditDocsWithCaptcha, 1, editDocsResp[@"error"][@"captcha_sid"], _captchaHandler.enterCode.stringValue);
                                        
                                    });
                                }
                            });
                            
                        }
                    }else{
                        offsetEditDocsWithCaptcha++;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            docsData[[docsData indexOfObject:i]][@"title"]=newTitle;
                            [docsTableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[docsData indexOfObject:i] ] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
                        });
                        NSLog(@"Doc successfully edited.");
                    }
                }
            }] resume];
            sleep(1);
            if(stopFlag){
                break;
            }
        }
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        editDocsBlock(0, 0, nil, nil);
    });
}

-(void)loadUserGroupsByAdmin{
    __block NSMenuItem *menuItem;
    __block NSMenu *menu1 = [[NSMenu alloc]init];
    [userGroupsByAdmin removeAllItems];
    [userGroupsByAdminData addObject:_app.person];
    viewControllerItem = [[ViewControllerMenuItem alloc]initWithNibName:@"ViewControllerMenuItem" bundle:nil];
    [viewControllerItem loadView];
    menuItem = [[NSMenuItem alloc]initWithTitle:@"Personal" action:nil keyEquivalent:@""];
    [menu1 addItem:menuItem];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.get?user_id=%@&filter=admin&extended=1&access_token=%@&v=%@", _app.person, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary *groupsGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            for(NSDictionary *i in groupsGetResponse[@"response"][@"items"]){
                [userGroupsByAdminData addObject:[NSString stringWithFormat:@"-%@",i[@"id"]]];
                viewControllerItem = [[ViewControllerMenuItem alloc]initWithNibName:@"ViewControllerMenuItem" bundle:nil];
                [viewControllerItem loadView];
                menuItem = [[NSMenuItem alloc]initWithTitle:[NSString stringWithFormat:@"%@",i[@"name"]] action:nil keyEquivalent:@""];
                NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:i[@"photo_50"]]];
                viewControllerItem.photo.wantsLayer=YES;
                viewControllerItem.photo.layer.masksToBounds=YES;
                viewControllerItem.photo.layer.cornerRadius=39/2;
                [viewControllerItem.photo setImageScaling:NSImageScaleProportionallyUpOrDown];
                image.size=NSMakeSize(30,30);
                [menuItem setImage:image];
                viewControllerItem.nameField.stringValue=[NSString stringWithFormat:@"%@", i[@"name"]];
                [viewControllerItem.photo setImage:image];
                [menuItem setView:[viewControllerItem view]];
                [menu1 addItem:menuItem];
               
                
                
            }
            dispatch_async(dispatch_get_main_queue(),^{
                [userGroupsByAdmin setMenu:menu1];
            });
        }]resume];
    });
}

- (IBAction)addMultipleDocs:(id)sender {
    __block NSInteger docCounter = 0;
    selectedItems = [[NSMutableArray alloc]initWithArray:[docsData objectsAtIndexes:[docsTableView selectedRowIndexes]]];
    downloadAndUploadProgressBar.maxValue = [selectedItems count];
    downloadAndUploadProgressBarLabel.stringValue=[NSString stringWithFormat:@"Add: %li / %li", docCounter, [selectedItems count]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for(NSDictionary *i in selectedItems) {
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/docs.add?owner_id=%@&doc_id=%@&access_token=%@&v=%@", i[@"owner_id"], i[@"id"], _app.token, _app.version]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *addDocResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSLog(@"%@", addDocResp);
                if(addDocResp[@"response"]){
                    docCounter++;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        downloadAndUploadProgressBarLabel.stringValue=[NSString stringWithFormat:@"Add: %li / %li", docCounter, [selectedItems count]];
                        downloadAndUploadProgressBar.doubleValue = docCounter;
                    });
                }
            }]resume];
            sleep(1);
        }
    });
  
    
}

- (IBAction)userGroupsByAdminSelect:(id)sender {
    owner = userGroupsByAdminData[[userGroupsByAdmin indexOfSelectedItem]];
    [self loadDocs];
}


//search docs
-(void)localDocsSearch{
    docsDataCopy=[[NSMutableArray alloc] initWithArray:docsData];
    [progressSpin startAnimation:self];
    [docsData removeAllObjects];
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:searchDocsBar.stringValue options:NSRegularExpressionCaseInsensitive error:nil];
    
    for(NSDictionary *i in docsDataCopy){
        NSInteger matches = [regExp numberOfMatchesInString:i[@"title"] options:0 range:NSMakeRange(0, [i[@"title"] length])];
        if(matches > 0){
            [docsData addObject:i];
        }
        
    }
    [docsTableView reloadData];
    [progressSpin stopAnimation:self];
}

-(void)globalDocsSearch{
    docsDataCopy=[[NSMutableArray alloc] initWithArray:docsData];
    [progressSpin startAnimation:self];
    [docsData removeAllObjects];
    NSString *searchString = [searchDocsBar.stringValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/docs.search?q=%@&access_token=%@&v=%@", searchString, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data){
            
            NSDictionary *searchDocsResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if(searchDocsResp[@"error"]){
                NSLog(@"%@", searchDocsResp[@"error"]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [progressSpin stopAnimation:self];
                });
                
            }else{
                NSString *video;
                NSString *photo;
                NSString *title;
                NSString *ownerId;
                NSString *docId;
                NSString *docUrl;
                for(NSDictionary *i in searchDocsResp[@"response"][@"items"]){
                    
                    title=i[@"title"];
                    docId=i[@"id"];
                    ownerId=i[@"owner_id"];
                    docUrl=i[@"url"];
                    
                    video = i[@"preview"][@"video"] ? i[@"preview"][@"video"][@"src"] : @"";
                    
                    for(NSDictionary *a in i[@"preview"][@"photo"][@"sizes"]){
                        if([a[@"width"] intValue] == 100){
                            photo=a[@"src"];
                            
                            [docsData addObject:@{@"title":title, @"photo":photo, @"video":video, @"owner_id":ownerId, @"id":docId,@"url":docUrl}];
                        }
                    }
                    
                    
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    //                    NSLog(@"%@", docsData);
                    [docsTableView reloadData];
                    [progressSpin stopAnimation:self];
                });
            }
        }
    }]resume];
}

-(void)searchFieldDidStartSearching:(NSSearchField *)sender{
    if(globalCheck.state){
        [self globalDocsSearch];
    }
    else{
        [self localDocsSearch];
    }
}

-(void)searchFieldDidEndSearching:(NSSearchField *)sender{
    docsData = docsDataCopy;
    [docsTableView reloadData];
}
//end search docs

//Download docs process
- (IBAction)downloadDocs:(id)sender {
    [self chooseDirectoryToDownloadTo];
}

- (IBAction)showDocsByOwner:(id)sender {
    
    if(![publicIdField.stringValue isEqual:@""]){
        owner = publicIdField.stringValue;
        [self loadDocs];
        
    }else{
        NSLog(@"Enter owner id");
    }
}

-(void)chooseDirectoryToDownloadTo{
    NSOpenPanel *saveDlg = [NSOpenPanel openPanel];
    [saveDlg setCanCreateDirectories:YES];
    [saveDlg setPrompt:@"Select"];
    [saveDlg setCanChooseFiles:NO];
    [saveDlg setCanChooseDirectories:YES];
    if([saveDlg runModal] == NSFileHandlingPanelOKButton){
        filePath = [[[saveDlg URL] absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
//        NSLog(@"%@", filePath);
        [self prepareDownloadDocs];
    }
}

-(void)prepareDownloadDocs{
    NSURLSessionConfiguration *backgroundConfigurationObject = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"DownloadDocsSession"];
    _backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfigurationObject delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    counterDownloader=0;
    NSIndexSet *rows = [docsTableView selectedRowIndexes];
    selectedItems =[[NSMutableArray alloc] initWithArray: [docsData objectsAtIndexes:rows]];
    NSLog(@"%@", selectedItems);
    selectedCount = [selectedItems count];
    
     downloadAndUploadProgressBarLabel.stringValue=[NSString stringWithFormat:@"Download: %li / %li", counterDownloader, [selectedItems count]];
//    downloadAndUploadProgressBar.maxValue=selectedCount;

    [self startDownloadDocs];

}

-(void)startDownloadDocs{
    [self setControlButtonsDownloadState];
    docFileName = [[[selectedItems[counterDownloader][@"photo"] lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:selectedItems[counterDownloader][@"ext"]];
    downloadFile = [_backgroundSession downloadTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", selectedItems[counterDownloader][@"url"]]]];
    [downloadFile resume];
}
//end download docs process


//Upload docs process
- (IBAction)uploadAction:(id)sender {
    
    [self chooseDirectoryToUpload];
}

-(void)chooseDirectoryToUpload{
    
    NSOpenPanel* openDlgUpload = [NSOpenPanel openPanel];
    [openDlgUpload setPrompt:@"Select"];
    [openDlgUpload setCanChooseFiles:YES];
    [openDlgUpload setCanChooseDirectories:YES];
    [openDlgUpload setAllowsMultipleSelection:YES];
    [openDlgUpload setAllowedFileTypes:[NSArray arrayWithObjects:@"jpg",@"png",@"gif", nil]];
   
    if ( [openDlgUpload runModal] == NSModalResponseOK)
    {
        filesForUpload = [openDlgUpload URLs];

    }

    if([filesForUpload count]>0){
        [self getUploadUrl:^(NSData *data) {
            if(data){
                NSDictionary *getServerResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                uploadURL = getServerResponse[@"response"][@"upload_url"];
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    [self uploadPersonalDocs:files :uploadURL];
                    [self prepareForUpload];
//                });
            }else{
                NSLog(@"UPLOAD URL NOT RECEIVED");
            }
        }];
    }

    
}

-(void)prepareForUpload{
    NSURLSessionConfiguration *backgroundConfigurationObject = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"UploadDocsSession"];
   _backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfigurationObject delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    uploadCounter=0;
    dispatch_async(dispatch_get_main_queue(), ^{
        downloadAndUploadProgressBar.maxValue=[filesForUpload count];
        downloadAndUploadProgressBarLabel.stringValue = [NSString stringWithFormat:@"%li/%lu", uploadCounter, [filesForUpload count] ];
        [self uploadPersonalDocs];
    });

}

-(void)uploadPersonalDocs{
    [self setControlButtonsUploadingDocsState];
    
    fileName = [filesForUpload[uploadCounter] lastPathComponent];
    NSData *contents = [[NSData alloc]initWithContentsOfFile:filesForUpload[uploadCounter]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:uploadURL]];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:contents];
    NSData *data1 = [imageRep representationUsingType:NSGIFFileType properties:@{NSImageFrameCount:@320}];
    
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    NSString *kStringBoundary = @"*******";
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",kStringBoundary] forHTTPHeaderField:@"Content-Type"];
    NSString *beginLine = [NSString stringWithFormat:@"\r\n--%@\r\n", kStringBoundary];
    NSMutableData *body = [NSMutableData data];
    [body appendData:[beginLine dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\";  filename=\"%@\"\r\n",fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Length: %d\r\n\r\n",(int)[data1 length]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:contents];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", kStringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    //
    NSURLSessionDataTask *uploadTask = [_backgroundSession dataTaskWithRequest:request];
    [uploadTask resume];

    
}

-(void)getUploadUrl:(OnComplete)completion{
    NSString *baseURL;
    baseURL = [NSString stringWithFormat:@"https://api.vk.com/method/docs.getUploadServer?%@v=%@&access_token=%@", [owner isEqualToString:_app.person] ? @"" : [NSString stringWithFormat:@"group_id=%i&", abs([owner intValue])], _app.version, _app.token];
    
    
    [[_app.session dataTaskWithURL:[NSURL URLWithString:baseURL]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        completion(data);

    }] resume];
    
}
//end upload docs process


- (IBAction)stopDownloadOrUpload:(id)sender {
    [self setControlButtonsStoppedState];
    [_backgroundSession invalidateAndCancel];
}


- (IBAction)deleteDocs:(id)sender {
    [self setControlButtonsDeleteState];
    __block NSInteger docCounter = 0;
    selectedItems = [[NSMutableArray alloc]initWithArray:[docsData objectsAtIndexes:[docsTableView selectedRowIndexes]]];
    downloadAndUploadProgressBar.maxValue = [selectedItems count];
    downloadAndUploadProgressBarLabel.stringValue=[NSString stringWithFormat:@"Delete: %li / %li", docCounter, [selectedItems count]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for(NSDictionary *i in selectedItems) {
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/docs.delete?owner_id=%@&doc_id=%@&access_token=%@&v=%@", i[@"owner_id"], i[@"id"], _app.token, _app.version]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *deleteDocResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSLog(@"%@", deleteDocResp);
                if(deleteDocResp[@"response"]){
                    docCounter++;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        downloadAndUploadProgressBarLabel.stringValue=[NSString stringWithFormat:@"Delete: %li / %li", docCounter, [selectedItems count]];
                        downloadAndUploadProgressBar.doubleValue = docCounter;

                    });
                }
            }]resume];
            sleep(1);
        }
        [self loadDocs];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setControlButtonsStoppedState];
        });
    });
  
}


- (IBAction)showDocInWindow:(id)sender {
//    NSView *parentCell = [sender superview];
//    NSInteger row = [docsTableView rowForView:parentCell];
//    //        CGRect rect=CGRectMake(0, y, 0, 0);
//    dataForUserInfo = docsData[row];
//    NSLog(@"%@", sender);
//    _showDocController = [self.storyboard instantiateControllerWithIdentifier:@"ShowDocWindowController"];
//    
//    [_showDocController showWindow:self];
//    NSLog(@"fffff");
}




-(void)loadDocs{
    [docsData removeAllObjects];
    [progressSpin startAnimation:self];
    owner = owner == nil ? _app.person : owner;
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/docs.get?owner_id=%@&access_token=%@&v=%@", owner == nil ? owner=_app.person : owner, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data){
            NSDictionary *docsGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if(docsGetResponse[@"error"]){
                NSLog(@"%@", docsGetResponse[@"error"]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [progressSpin stopAnimation:self];
                });
                
            }else{
                NSString *title;
                NSString *photo;
                NSString *video;
                NSString *ownerId;
                NSString *docId;
                NSString *docUrl;
                NSString *ext;
                for(NSDictionary *i in docsGetResponse[@"response"][@"items"]){
                    title=i[@"title"];
                    docId=i[@"id"];
                    ownerId=i[@"owner_id"];
                    docUrl=i[@"url"];
                    photo=docUrl;
                    ext = i[@"ext"];
                    //if(i[@"preview"][@"photo"][@"sizes"]){
                    if(i[@"preview"][@"video"]){
                        video = i[@"preview"][@"video"][@"src"];
                    }else{
                        video = @"";
                    }
                    for(NSDictionary *a in i[@"preview"][@"photo"][@"sizes"]){
                        if([a[@"width"] intValue] ==100){
                            photo=a[@"src"];
                            NSMutableDictionary *object = [[NSMutableDictionary alloc]initWithObjects:@[title,photo,video,ownerId,docId,docUrl,ext] forKeys:@[@"title", @"photo", @"video", @"owner_id",@"id", @"url", @"ext"]];
                            [docsData addObject:object];
//                            [docsData addObject:@{@"title":title, @"photo":photo, @"video":video, @"owner_id":ownerId, @"id":docId, @"url":docUrl, @"ext":ext}];
                        }
                        
                    }
                    //                }
                    
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    //                _arrayController.content = docsData;
                    
                    [docsTableView reloadData];
                    [progressSpin stopAnimation:self];
                });
            }
        }
    }]resume];
}





-(void)setControlButtonsDeleteState{
    uploadButton.enabled=NO;
    downloadButton.enabled=NO;
    stopButton.enabled=YES;
    deleteButton.enabled=NO;
    editButton.enabled=NO;
}

-(void)setControlButtonsUploadingDocsState{
    uploadButton.enabled=NO;
    downloadButton.enabled=NO;
    stopButton.enabled=YES;
    deleteButton.enabled=NO;
    editButton.hidden=YES;
}

-(void)setControlButtonsStoppedState{
    busy = NO;
    if([[docsTableView selectedRowIndexes]count]>0){
        uploadButton.enabled=YES;
        editButton.enabled=YES;
        downloadButton.enabled=YES;
        stopButton.enabled=NO;
        deleteButton.enabled=YES;
        
    }else{
        uploadButton.enabled=YES;
        editButton.enabled=NO;
        downloadButton.enabled=NO;
        stopButton.enabled=NO;
        deleteButton.enabled=NO;
    }
}

-(void)setControlButtonsDownloadState{
    busy = YES;
    uploadButton.enabled=NO;
    downloadButton.enabled=NO;
    deleteButton.enabled=NO;
    stopButton.enabled=YES;
}





-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [docsData count];
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    if([[docsTableView selectedRowIndexes]count]>0 && !busy){
        editButton.enabled=YES;
        downloadButton.enabled=YES;
        deleteButton.enabled=YES;
    }else{
        editButton.enabled=NO;
        downloadButton.enabled=NO;
        deleteButton.enabled=NO;
    }
}

-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if([docsData count]>0){
        DocsCustomTableCellViewPersonal *cell = [[DocsCustomTableCellViewPersonal alloc]init];
        cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
        cell.docsTitle.stringValue = docsData[row][@"title"];
        if(loadForAttachments){
            cell.addToAttachments.hidden=NO;
        }else{
            cell.addToAttachments.hidden=YES;
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", docsData[row][@"photo"]]]];
            NSImageRep *rep = [[image representations] objectAtIndex:0];
            NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
            image.size=imageSize;
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell.docsPhoto setImage:image];
            });
        });
        return cell;
    }
    return nil;
}






-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    NSDictionary *uploadDocResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSLog(@"%@", uploadDocResponse);
    
    NSString *saveURL;
//    NSString *ownerId = [NSString stringWithFormat:@"%@", self.representedObject[@"owner"]];
    owner = owner == nil ? _app.person : owner;
    NSString *uploadedFile = [uploadDocResponse[@"file"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    tags = [tagsField.stringValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];;
    if(owner && [owner isEqual:_app.person]){
        saveURL = [NSString stringWithFormat:@"https://api.vk.com/method/docs.save?file=%@%@&access_token=%@&v=%@",  uploadedFile, tags ? [NSString stringWithFormat:@"&tags=%@", tags] : @"", _app.token, _app.version];
    }
    else{
        saveURL = [NSString stringWithFormat:@"https://api.vk.com/method/docs.save?group_id=%@&file=%@%@&access_token=%@&v=%@",  owner, uploadedFile, tags ? [NSString stringWithFormat:@"&tags=%@", tags] : @"", _app.token, _app.version];
    }
    [[_app.session dataTaskWithURL:[NSURL URLWithString:saveURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *saveDocResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"%@", saveDocResponse);
        if(saveDocResponse[@"error"]){
            NSLog(@"%@", saveDocResponse[@"error"]);
        }
        else{
            if(uploadCounter+1==[filesForUpload count]){
                [_backgroundSession finishTasksAndInvalidate];
                busy = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                
                    downloadAndUploadProgressBarLabel.stringValue = [NSString stringWithFormat:@"%li/%lu", uploadCounter+1, [filesForUpload count] ];
                    [self setControlButtonsStoppedState];
                    
                });
                [self loadDocs];
            }else{
                uploadCounter++;
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    downloadAndUploadProgressBarLabel.stringValue = [NSString stringWithFormat:@"%li/%lu", uploadCounter, [filesForUpload count] ];
                    
                });
                [self uploadPersonalDocs];
            }
        }
    }]resume];


    
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    downloadAndUploadProgressBar.maxValue=totalBytesExpectedToSend;
    downloadAndUploadProgressBar.doubleValue=totalBytesSent;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    NSString *destinationURL = [filePath stringByAppendingPathComponent:docFileName];
    NSError *error = nil;
    [manager moveItemAtURL:location toURL:[NSURL fileURLWithPath:destinationURL]  error:&error];
    dispatch_async(dispatch_get_main_queue(), ^{
//        downloadAndUploadProgressBar.doubleValue=counterDownloader;
         downloadAndUploadProgressBarLabel.stringValue=[NSString stringWithFormat:@"Download: %li / %li", counterDownloader, [selectedItems count]];
    });
    if(selectedCount ==  counterDownloader+1){
        busy=NO;
        [self setControlButtonsStoppedState];
        [_backgroundSession finishTasksAndInvalidate];
        dispatch_async(dispatch_get_main_queue(), ^{
             downloadAndUploadProgressBarLabel.stringValue=[NSString stringWithFormat:@"Download: %li / %li", counterDownloader+1, [selectedItems count]];
            downloadAndUploadProgressBar.doubleValue=counterDownloader+1;
          
        });
    }else{
        counterDownloader++;
        [self startDownloadDocs];
    }
    NSLog(@"%@", destinationURL);
  
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    downloadAndUploadProgressBar.maxValue=totalBytesExpectedToWrite;
    downloadAndUploadProgressBar.doubleValue=totalBytesWritten;
}

@end
