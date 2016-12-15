//
//  DocsWallViewController.m
//  vkapp
//
//  Created by sim on 07.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "DocsWallViewController.h"

@interface DocsWallViewController ()<NSURLSessionDataDelegate, NSURLSessionDownloadDelegate, NSURLSessionDelegate>

@end

@implementation DocsWallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    tempDocs = [[NSMutableArray alloc]init];
    tempDates = [[NSMutableArray alloc]init];
}
- (IBAction)chooseDirectoryAction:(id)sender {
    
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setPrompt:@"Select"];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    
    if ( [openDlg runModal] == NSModalResponseOK)
    {
        NSArray* files = [openDlg URLs];
        fileName = [files[0] absoluteString];
    }
    if(fileName){
        fileName = [fileName stringByRemovingPercentEncoding];
        DownloadDirectory.stringValue = fileName;
    }
}
- (IBAction)radioButtonsAction:(id)sender {
}
- (IBAction)stopDownload:(id)sender {
    stopped=YES;
    [downloadFile cancel];
    dispatch_semaphore_signal(semaphore);
    
}
- (IBAction)addToDocsAction:(id)sender {
    
    
}

- (IBAction)DownloadButAction:(id)sender {
    stopped=NO;
    NSURLSessionConfiguration *backgroundConfigurationObject = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"myBackgroundSessionIdentifier"];
    
    self.backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfigurationObject delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    tempTypeDocs = [[NSMutableArray alloc]init];
    void (^downloadDocs)() = ^{
        progressBar.maxValue=[countField.stringValue intValue];
        _app = [[appInfo alloc]init];
        
        if(![offsetField.stringValue isEqual: @""]){
            step = [offsetField.stringValue intValue];
        }else{
            step = 0;
        }
        
        __block BOOL stoppedAttachLoop=NO;
        __block NSString *url;
        
        
        if ([publicIdField.stringValue intValue]<0){
            publicIdIntTemp = abs([publicIdField.stringValue intValue]);
            NSString *publicIdPhotoFromPlus = [NSString stringWithFormat:@"%lu", publicIdIntTemp];
            publicIdFrom = publicIdPhotoFromPlus;
            url = @"https://api.vk.com/method/groups.getById?group_id=%@&access_token=%@&v=%@";
        }
        else{
            publicIdFrom = publicIdField.stringValue;
            url=@"https://api.vk.com/method/users.get?user_ids=%@&fields=nickname&access_token=%@&v=%@";
            
        }
        
        NSURLSessionDataTask *getNameOfAlbum=[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:url, publicIdFrom, _app.token, _app.version
                                                                                                 ]]completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *getNameResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSString *nameGet;
            
            if ([publicIdField.stringValue intValue]<0){
                nameGet = getNameResponse[@"response"][0][@"name"];
            }
            else{
                nameGet = [NSString stringWithFormat:@"%@ %@", getNameResponse[@"response"][0][@"first_name"], getNameResponse[@"response"][0][@"last_name"]];
            }
            newDirectoryName =[[NSString stringWithFormat:@"%@", nameGet] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
            
        }];
        
        [getNameOfAlbum resume];
        
        sleep(1);
        manager = [NSFileManager defaultManager];
        
        
        newDirectoryName = [newDirectoryName stringByRemovingPercentEncoding];
        [manager createDirectoryAtPath:[[fileName stringByReplacingOccurrencesOfString:@"file://" withString:@""] stringByAppendingPathComponent:newDirectoryName ] withIntermediateDirectories:YES attributes:nil
                                 error:nil];
        //        NSLog(@"%@", [fileName stringByReplacingOccurrencesOfString:@"file" withString:@""]  );
        
        NSLog(@"%@", [[fileName stringByReplacingOccurrencesOfString:@"file://" withString:@""] stringByAppendingPathComponent:[newDirectoryName stringByRemovingPercentEncoding]]);
        
        NSLog(@"Name of public %@", newDirectoryName);
        while (step<[countField.stringValue intValue]+1){
            if(!stopped){
                
                
                semaphore = dispatch_semaphore_create(0);
                NSURLSessionDataTask *getWall=[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/wall.get?owner_id=%@&count=%d&offset=%ld&v=%@&access_token=%@", publicIdField.stringValue, 1, step, _app.version, _app.token]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    NSDictionary *jsonData=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    for (NSDictionary *i in jsonData[@"response"][@"items"]){
                        if (i[@"attachments"] && !i[@"copy_history"] && !i[@"is_pinned"]){
                            for (NSDictionary *a in i[@"attachments"]){
                                if(!stoppedAttachLoop){
                                    [tempTypeDocs addObject:a[@"type"]];
                                }
                            }
                            NSLog(@"%@", tempTypeDocs);
                            if([tempTypeDocs containsObject:@"doc"]){
                                for (NSDictionary *a in i[@"attachments"]){
                                    if(!stoppedAttachLoop){
                                        
                                        
                                        if([a[@"type"] isEqual:@"doc"]){
                                            
                                            url= a[@"doc"][@"url"];
                                           if(checkPDF.state==1){
                                                if( [a[@"doc"][@"ext"] isEqual:@"pdf"] ){
                                                  
                                                      
                                                    [tempDocs addObject:@{@"url":url, @"title":a[@"doc"][@"title"], @"date":i[@"date"]}];
                                                    
                                                    if(![tempDocs containsObject:a[@"data"]]){
                                                        
                                                        [tempDates addObject:i[@"date"]];
                                                    }
                                                    if(next){
                                                         next=YES;
                                                    }
//                                                    else{
//                                                        if([tempDocs count]!=1){
//
//                                                        }
//                                                    }
                                                }
                                            }
                                            else if(checkGIF.state==1){
                                                if([a[@"doc"][@"ext"] isEqual:@"gif"] ){
                                                    if( [a[@"doc"][@"ext"] isEqual:@"gif"] ){
                                                        if(![tempDates containsObject:i[@"date"]]){
                                                            [tempDates addObject:i[@"date"]];
                                                            [tempDocs addObject:@{@"url":url, @"title":a[@"doc"][@"title"], @"date":i[@"date"]}];
                                                        }
                                                        else{
                                                            next=YES;
                                                        }
                                                        
                                                        
                                                        
                                                    }
                                                }
                                                
                                                
                                            }
                                            else if(checkDJVU.state==1){
                                                if([a[@"doc"][@"ext"] isEqual:@"djvu"] ){
                                                    if( [a[@"doc"][@"ext"] isEqual:@"djvu"] ){
                                                        if(![tempDates containsObject:i[@"date"]]){
                                                            [tempDates addObject:i[@"date"]];
                                                            [tempDocs addObject:@{@"url":url, @"title":a[@"doc"][@"title"], @"date":i[@"date"]}];
                                                        }
                                                        else{
                                                            next=YES;
                                                        }
                                                        
                                                        
                                                        
                                                    }
                                                }
                                                
                                                
                                            }
                                            else if(checkDJVU.state==0 && checkPDF.state==0 && checkZIP.state==0 && checkGIF.state==0){
                                                NSLog(@"Select one or more types of doc. Nothing selected.");
                                                
                                            }
                                            else{
                                                next=YES;
                                            }
                                            
                                        }
                                        else{
                                            if(!downloading){
                                                next=YES;
                                            }
                                        }
                                        
                                        
                                    }
                                }
                            }
                            else{
                        
                                [tempTypeDocs removeAllObjects];
                                dispatch_semaphore_signal(semaphore);
//                                                                    next=YES;
                                
                            }
                            if([tempDocs count]==1){
                                NSLog(@"%@", tempDocs[0][@"url"]);
                                downloadFile = [self.backgroundSession downloadTaskWithURL:[NSURL URLWithString:tempDocs[0][@"url"]]];
                                next=NO;
                                downloading=YES;
                                [downloadFile resume];
                                if(checkGIF.state==1){
                                    currentFileName = [NSString stringWithFormat:@"file%lu.gif", step];
                                }
                                else{
                                    currentFileName = tempDocs[0][@"title"];
                                }
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    currentDownloadingFile.stringValue = currentFileName;
                                    
                                });
                                [tempDocs removeAllObjects];
                                
                            }
                            else if([tempDocs count]>2){
                                
                                [self downloadAttachesBig];
                            }
                            
                            
                        }
                        
                        //                                        else{
                        //                    //                        if(next){
                        //                                                next=YES;
                        //                    //                        }
                        //                                        }
                        else{
                            dispatch_semaphore_signal(semaphore);
                        }
                    }
                    
                    if(next){
                        dispatch_semaphore_signal(semaphore);
                        next=NO;
                    }
                }];
                [getWall resume];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                dispatch_semaphore_signal(semaphore);
                sleep(1);
                step++;
                if(step<[countField.stringValue intValue]+1){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        progressLabel.stringValue = [NSString stringWithFormat:@"%lu/%i", step, [countField.stringValue intValue]];
                        progressBar.doubleValue = step;
                    });
                }
            }
            else{
                [self.backgroundSession invalidateAndCancel];
                break;
            }
        }
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(fileName){
            if(checkGIF.state==0 && checkPDF.state==0 && checkTXT.state==0 && checkZIP.state==0 && checkDJVU.state==0){
                NSLog(@"Select type of docs");
            }else{
                downloadDocs();
            }
        }
        else{
            NSLog(@"Select directory, please.");
        }
    });
}
-(void)downloadAttachesBig{
    //    dispatch_queue_t myCustomQueue;
    //    myCustomQueue = dispatch_queue_create("com.example.MyCustomQueue", NULL);
    step2 = 0;
    attachCountMoreThanOne=YES;
    NSLog(@"%lu", [tempDocs count]);
    NSLog(@"downloadAttaches call %@", tempDocs);
    
    downloadFile = [self.backgroundSession downloadTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", tempDocs[step2][@"url"]]]];
    
    next=NO;
    downloading=YES;
    if(checkGIF.state==1){
        currentFileName = [NSString stringWithFormat:@"file%lu_%lu.gif", step, step2];
    }
    else{
        currentFileName = tempDocs[0][@"title"];
    }
    currentFileName = tempDocs[step2][@"title"];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        currentDownloadingFile.stringValue = currentFileName;
    });
    [downloadFile resume];
    
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
    
    
    
    NSString *destinationURL = [[[fileName stringByReplacingOccurrencesOfString:@"file://" withString:@""]   stringByAppendingPathComponent:[newDirectoryName stringByRemovingPercentEncoding] ] stringByAppendingPathComponent:currentFileName];
    //    NSString *destinationURL = [documentDirectoryPath stringByAppendingPathComponent:@"file.pdf"];
    NSError *error = nil;
    //    NSLog(@"%@", destinationURL);
    //    [manager replaceItemAtURL:location withItemAtURL:[NSURL fileURLWithPath:destinationURL] backupItemName:nil options:NSFileManagerItemReplacementUsingNewMetadataOnly resultingItemURL:nil error:&error];
    [manager moveItemAtURL:location toURL:[NSURL fileURLWithPath:destinationURL]  error:&error];
    if(attachCountMoreThanOne){
        if(step2==[tempDocs count]-1){
            
            next=YES;
            downloading=NO;
            attachCountMoreThanOne=NO;
            stopped=YES;
            dispatch_semaphore_signal(semaphore);
            [tempDocs removeAllObjects];
            [tempDates removeAllObjects];
        }else{
            step2++;
            downloadFile = [self.backgroundSession downloadTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", tempDocs[step2][@"url"]]]];
            
            next=NO;
            downloading=YES;
            currentFileName = tempDocs[step2][@"title"];
            dispatch_async(dispatch_get_main_queue(), ^{
                currentDownloadingFile.stringValue = currentFileName;
            });
            [downloadFile resume];
        }
        
        
        
    }
    //    else{
    //        downloadFile = nil;
    //    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    currentFileProgress.maxValue = (double)totalBytesExpectedToWrite;
    currentFileProgress.doubleValue = (double)totalBytesWritten;
    if((double)totalBytesExpectedToWrite == (double)totalBytesWritten && !attachCountMoreThanOne){
        next=YES;
        downloading=NO;
        dispatch_semaphore_signal(semaphore);
    }
    else if((double)totalBytesExpectedToWrite == (double)totalBytesWritten && attachCountMoreThanOne){
        //        next=YES;
        //        downloading=NO;
        //        dispatch_semaphore_signal(semaphore2);
        //        attachCountMoreThanOne=NO;
    }
}

// 3
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    //    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"PDFDownloader" message:@"Download is resumed successfully" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    //    [alert show];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    
    downloadFile = nil;
    //    currentFileProgress.doubleValue=0;
    
}
@end
