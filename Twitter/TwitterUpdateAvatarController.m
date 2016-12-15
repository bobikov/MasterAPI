//
//  TwitterUpdateAvatarController.m
//  MasterAPI
//
//  Created by sim on 17.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "TwitterUpdateAvatarController.h"

@interface TwitterUpdateAvatarController ()

@end

@implementation TwitterUpdateAvatarController

- (void)viewDidLoad {
    [super viewDidLoad];
    twitterClient = [[TwitterClient alloc]initWithTokensFromCoreData];
  
}
-(void)viewWillAppear{
     NSLog(@"hello");
    if(!loaded){
        [self loadCurrentAvatar];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(uploadingProcess:) name:@"setValue" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setMaxValue:) name:@"setMaxValue" object:nil];

    }
}
-(void)setMaxValue:(NSNotification*)notification{
    maxBytes = [notification.userInfo[@"max"] intValue];
    progressUploadBar.maxValue = [notification.userInfo[@"max"] intValue];
}
-(void)uploadingProcess:(NSNotification*)notification{
    if([notification.userInfo[@"value"] intValue]==maxBytes){
        NSData *data = [[NSData alloc]initWithContentsOfFile:filePath];
        NSImage *image = [[NSImage alloc]initWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [avatarImage setImage:image];
        });

    }
    progressUploadBar.doubleValue = [notification.userInfo[@"value"] intValue];
}
-(void)loadCurrentAvatar{
    [twitterClient APIRequest:@"account" rmethod:@"verify_credentials.json" query:@{@"include_entities":@"true"} handler:^(NSData *data) {
        NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if(!resp[@"errors"]){
            
//
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSImage *image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:[resp[@"profile_image_url"] stringByReplacingOccurrencesOfString:@"_normal" withString:@""]]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [avatarImage setImage:image];
                    loaded=YES;
                });
            });
        }
        else{
            
        }
        NSLog(@"%@", resp);
    }];

}
-(void)selectFile{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Enable the selection of files in the dialog.
    [openDlg setCanChooseFiles:YES];
    
    // Enable the selection of directories in the dialog.
    [openDlg setCanChooseDirectories:YES];
    [openDlg setAllowedFileTypes:[NSArray arrayWithObjects:@"jpg", @"png",@"jpeg", @"gif", nil]];
    // Change "Open" dialog button to "Select"
    // c
//    NSString* fileName;
    //    [openDlg setAllowsMultipleSelection:NO];
    
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ( [openDlg runModal] == NSModalResponseOK)
    {
        // Get an array containing the full filenames of all
        // files and directories selected.
        NSArray* files = [openDlg URLs];
        
        // Loop through all the files and process them.
        //        for( int i = 0; i < [files count]; i++ )
        //        {
        filePath = files[0];
//        filePathLabel.hidden=NO;
        if(filePath){
             [self upload];
        }
        
        //            NSLog(@"file: %@", fileName);
        // Do something with the filename.
        //
        
        //        }
        
    }
  

}
-(void)upload{
    [twitterClient APIRequest:@"account" rmethod:@"update_profile_image.json" query:@{@"image":filePath} handler:^(NSData *data) {
        if(data){
            NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@", resp);
            if(resp[@"id"]){
                //            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *data = [[NSData alloc]initWithContentsOfFile:filePath];
                NSImage *image = [[NSImage alloc]initWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [avatarImage setImage:image];
                });
                //            });
                
                
            }
        }
        //        NSString *rr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        //        NSLog(@"%@", rr);
    }];
}
- (IBAction)uploadPhoto:(id)sender {

    [self selectFile];

}

@end
