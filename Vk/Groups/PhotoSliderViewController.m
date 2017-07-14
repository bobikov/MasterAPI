//
//  PhotoSliderViewController.m
//  vkapp
//
//  Created by sim on 04.06.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "PhotoSliderViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "VKLikesViewController.h"
@interface PhotoSliderViewController ()

@end

@implementation PhotoSliderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    _app = [[appInfo alloc]init];
    data = [[NSMutableArray alloc]init];
    superWindow = [[NSApplication sharedApplication]mainWindow];
    nextPhoto.font=[NSFont fontWithName:@"Pe-icon-7-stroke" size:48];
    prevPhoto.font=[NSFont fontWithName:@"Pe-icon-7-stroke" size:48];
    NSString *prevS = @"\U0000E687";
    NSString *nextS = @"\U0000E685";
    nextPhoto.title=nextS;
    prevPhoto.title=prevS;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ShowSlider:) name:@"ShowPhotoSlider" object:nil];
    NSLog(@"%@", superWindow);
    
//    NSLog(@"Photo Slider here");
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(resizingView:) name:NSWindowDidResizeNotification object:nil];
}

- (void)keyDown:(NSEvent *)event{
//    NSLog(@"%d", event.keyCode);
//    NSLog(@"%d", NSRightArrowFunctionKey);
    NSString*   const   character   =   [event charactersIgnoringModifiers];
    unichar     const   code        =   [character characterAtIndex:0];
    switch (code){
        case NSRightArrowFunctionKey:
            NSLog(@"right");
            [self switchSlide:YES prev:NO];
            break;
        case NSLeftArrowFunctionKey:
            NSLog(@"left");
            [self switchSlide:NO prev:YES];
            break;
    }
}
- (void)viewDidAppear{
    //self.view.layer.backgroundColor=[[NSColor colorWithCalibratedRed:0.90 green:0.90 blue:0.90 alpha:0.0]CGColor];
    //self.view.layer.opacity=0.0;
    [self.view.window makeFirstResponder:self];
    self.view.window.titleVisibility=NSWindowTitleVisible;
    self.view.window.titlebarAppearsTransparent = YES;
    self.view.window.movableByWindowBackground=YES;
    self.view.window.level = NSFloatingWindowLevel;
    NSVisualEffectView* vibrantView = [[NSVisualEffectView alloc] initWithFrame:self.view.frame];
    vibrantView.material=NSVisualEffectMaterialLight;
    vibrantView.blendingMode=NSVisualEffectBlendingModeBehindWindow;
    
    //vibrantView.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
    //vibrantView.wantsLayer=YES;
    self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
    [vibrantView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self.view addSubview:vibrantView positioned:NSWindowBelow relativeTo:self.view];
}
- (void)viewDidLayout{
    [self updatePhotoCaptionButTrackingArea];
}
- (void)resizingView:(NSNotification*)notification{
    [self updatePhotoCaptionButTrackingArea];
}
- (void)updatePhotoCaptionButTrackingArea{
    [self.view removeTrackingArea:photoCaptionTrackingArea];
    [self createTrackingArea];
}
- (void)createTrackingArea{
    photoCaptionTrackingArea = [[NSTrackingArea alloc] initWithRect:showCaptionBut.frame options:NSTrackingMouseEnteredAndExited|NSTrackingActiveInActiveApp owner:self userInfo:nil];
    [self.view addTrackingArea:photoCaptionTrackingArea];
    NSPoint mouseLocation = [self.view.window mouseLocationOutsideOfEventStream];
    mouseLocation = [self.view convertPoint: mouseLocation
                                   fromView: nil];
//    if (NSPointInRect(mouseLocation, showCaptionBut.frame))
//    {
//        [self mouseEntered: nil];
//    }
//    else
//    {
//        [self mouseExited: nil];
//    }
}
- (void)mouseEntered:(NSEvent *)theEvent{
    
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    photoCaptionPopoverView = [story instantiateControllerWithIdentifier:@"PhotoCaption"];
   
    if(data[currentIndex][@"items"][@"caption"]){
        photoCaptionPopoverView.captionText=data[currentIndex][@"items"][@"caption"];
    }else{
        NSString *captionText = [NSString stringWithFormat:@"<html><head><style>h2,h1,h3,p,a{font-size:12;text-decoration:none;color:black}</style></head><body><span style='font-family:Helvetica;font-size:12'>%@</span></body></html>",data[currentIndex][@"photo"][@"caption"]];
        NSAttributedString *htmlCaption = [[NSAttributedString alloc] initWithData:[captionText dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}  documentAttributes:nil  error:nil] ;
        photoCaptionPopoverView.captionAttributedText=[[NSAttributedString alloc]initWithAttributedString:htmlCaption];
    }
    
    [self presentViewController:photoCaptionPopoverView asPopoverRelativeToRect:showCaptionBut.frame ofView:self.view preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorTransient];
    
}
- (void)mouseExited:(NSEvent *)theEvent{
//    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
//    PhotoCaptionView *contr = [story instantiateControllerWithIdentifier:@"PhotoCaption"];
//    contr.captionText=data[currentIndex][@"items"][@"caption"];
//    [self removeChildViewControllerAtIndex:0];
    
    [self performSelector:@selector(dismissPopoverCaption) withObject:nil afterDelay:1];
    
}
- (void)dismissPopoverCaption{
//    photoCaptionTrackingArea2 = [[NSTrackingArea alloc] initWithRect:photoCaptionPopoverView.view.frame options:NSTrackingMouseEnteredAndExited|NSTrackingActiveInActiveApp owner:self userInfo:nil];
//    [self.view addTrackingArea:photoCaptionTrackingArea2];
    NSPoint mouseLocation = [self.view.window mouseLocationOutsideOfEventStream];
    mouseLocation = [self.view convertPoint: mouseLocation
                                   fromView:nil];
    if (NSPointInRect(mouseLocation, self.view.frame)){
        
    }else{
        [photoCaptionPopoverView dismissController:photoCaptionPopoverView];
    }
}
- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqual:@"PhotoCaptionSegue"]){
        PhotoCaptionView *contr = (PhotoCaptionView *)segue.destinationController;
        if(data[currentIndex][@"items"][@"caption"]){
            contr.captionText=data[currentIndex][@"items"][@"caption"];
        }else{
            NSString *captionText = [NSString stringWithFormat:@"<html><head><style>h2,h1,h3,p,a{font-size:12;text-decoration:none;color:black}</style></head><body><span style='font-family:Helvetica;font-size:12'>%@</span></body></html>",data[currentIndex][@"photo"][@"caption"]];
            NSAttributedString *htmlCaption = [[NSAttributedString alloc] initWithData:[captionText dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}  documentAttributes:nil  error:nil] ;
            contr.captionAttributedText=[[NSAttributedString alloc]initWithAttributedString:htmlCaption];
        }
    }
    else if([segue.identifier isEqual:@"VKLikedUsersPhotoSegue"]){
        VKLikesViewController *contr =(VKLikesViewController*)segue.destinationController;
        contr.receivedData = @{@"owner":data[currentIndex][@"owner_id"],@"id":data[currentIndex][@"items"][@"id"]};
    }
}
- (IBAction)prevPhotoAction:(id)sender {
    [progressSpin startAnimation:self];
    [self switchSlide:NO prev:YES];
}
- (IBAction)nextPhotoAction:(id)sender {
    [progressSpin startAnimation:self];
    [self switchSlide:YES prev:NO];
}
- (void)ShowSlider:(NSNotification *)notification{
    data = [[NSMutableArray alloc]initWithArray:notification.userInfo[@"data"]];
    currentIndex = [notification.userInfo[@"current"] intValue]-1;
    [self switchSlide:NO prev:NO];
}
- (void)switchSlide:(BOOL)next prev:(BOOL)prev{
    if(next && !prev){
        if(currentIndex==[data count]-1){
            currentIndex=0;
        }else{
            currentIndex=currentIndex+1;
        }
    }
    else if(!next && prev){
        if(currentIndex==0){
            currentIndex=[data count]-1;
        }
        else{
            currentIndex=currentIndex-1;
        }
    }
    NSLog(@"%lu", currentIndex);
    progressSpin.minValue=0;
    progressSpin.doubleValue=0;
    [photoView sd_setImageWithURL:[NSURL URLWithString:data[currentIndex][@"items"]? data[currentIndex][@"items"][@"photoBig"] : data[currentIndex][@"photo"][@"original"]] placeholderImage:nil options:SDWebImageRefreshCached progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        progressSpin.maxValue=expectedSize;
        dispatch_async(dispatch_get_main_queue(), ^{
            progressSpin.doubleValue=receivedSize;
        });
    }  completed:^(NSImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        NSImageRep *rep = [[image representations] objectAtIndex:0];
        NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
        image.size=imageSize;
        NSLog(@"%li %li", rep.pixelsHigh, rep.pixelsWide);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSRect popupRect = NSMakeRect(superWindow.frame.origin.x, superWindow.frame.origin.y+superWindow.frame.size.height-imageSize.height+4*2, imageSize.width+40,imageSize.height+40);
            [progressSpin stopAnimation:self];
            [photoView setImage:image];
//            float orx = superWindow.frame.origin.x+(superWindow.frame.size.width-self.view.window.frame.size.width)/2;
//            float ory = superWindow.frame.origin.y+(superWindow.frame.size.height-self.view.window.frame.size.height)/2;
            [self.view.window.windowController.window setFrame:popupRect display:YES animate:YES];
            NSLog(@"%f, %f", superWindow.frame.origin.x,superWindow.frame.origin.y);
            if([data[currentIndex][@"items"][@"userLikes"] intValue]){
                userLikeBut.iconHex=@"f004";
            }else{
                userLikeBut.iconHex=@"f08a";
            }
        });
    }];
    likesCount.title = data[currentIndex][@"items"][@"likesCount"];
    self.view.window.title = [NSString stringWithFormat:@"%li/%li %@ ",  currentIndex+1, [data count], data[0][@"title"] && ![data[0][@"title"] isEqual:@""] ? data[0][@"title"] : @""];
}
- (IBAction)leaveLike:(id)sender {
    NSLog(@"%@", data[currentIndex]);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if([data[currentIndex][@"items"][@"userLikes"] intValue]){
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/likes.delete?owner_id=%@&type=photo&item_id=%@&access_token=%@&v=%@",  data[currentIndex][@"owner_id"],data[currentIndex][@"items"][@"id"],_app.token, _app.version]]completionHandler:^(NSData * _Nullable dataObj, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if(dataObj){
                    NSDictionary *likePhotoDeleteResp = [NSJSONSerialization JSONObjectWithData:dataObj options:0 error:nil];
                    if(likePhotoDeleteResp[@"error"]){
                        NSLog(@"%@:%@", likePhotoDeleteResp[@"error"][@"error_code"], likePhotoDeleteResp[@"error"][@"error_msg"]);
                    }else{
                        NSLog(@"%@", likePhotoDeleteResp);
                        dispatch_async(dispatch_get_main_queue(),^{
                            data[currentIndex][@"items"][@"likesCount"] = [NSString stringWithFormat:@"%i", [data[currentIndex][@"items"][@"likesCount"] intValue]-1];
                            NSLog(@"%@", data[currentIndex] );
                            likesCount.title = data[currentIndex][@"items"][@"likesCount"];
                            userLikeBut.iconHex=@"f08a";
                            data[currentIndex][@"items"][@"userLikes"]=@0;
                        });
                    }
                }
            }]resume];
        }
        else{
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/likes.add?owner_id=%@&type=photo&item_id=%@&access_token=%@&v=%@",  data[currentIndex][@"owner_id"],data[currentIndex][@"items"][@"id"],_app.token, _app.version]]completionHandler:^(NSData * _Nullable dataObj, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if(dataObj){
                    NSDictionary *likePhotoResp = [NSJSONSerialization JSONObjectWithData:dataObj options:0 error:nil];
                    if(likePhotoResp[@"error"]){
                        NSLog(@"%@:%@", likePhotoResp[@"error"][@"error_code"], likePhotoResp[@"error"][@"error_msg"]);
                    }else{
                        NSLog(@"%@", likePhotoResp);
                        dispatch_async(dispatch_get_main_queue(),^{
                            data[currentIndex][@"items"][@"likesCount"] = [NSString stringWithFormat:@"%i", [data[currentIndex][@"items"][@"likesCount"] intValue]+1];
                            NSLog(@"%@", data[currentIndex] );
                            likesCount.title = data[currentIndex][@"items"][@"likesCount"];
                            userLikeBut.iconHex=@"f004";
                            data[currentIndex][@"items"][@"userLikes"]=@1;
                        });
                    }
                }
            }]resume];
        }
    });
}
@end
