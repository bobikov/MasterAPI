//
//  PhotoSliderViewController.m
//  vkapp
//
//  Created by sim on 04.06.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "PhotoSliderViewController.h"

@interface PhotoSliderViewController ()

@end

@implementation PhotoSliderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    _app = [[appInfo alloc]init];
    data = [[NSMutableArray alloc]init];
    
//    NSLog(@"Photo Slider here");
    
 
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(resizingView:) name:NSWindowDidResizeNotification object:nil];
    
    
    
    
}
-(void)viewDidLayout{
    [self updatePhotoCaptionButTrackingArea];
}
-(void)resizingView:(NSNotification*)notification{
    [self updatePhotoCaptionButTrackingArea];
}
-(void)updatePhotoCaptionButTrackingArea{
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
-(void)mouseEntered:(NSEvent *)theEvent{
    
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
-(void)mouseExited:(NSEvent *)theEvent{
//    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
//    PhotoCaptionView *contr = [story instantiateControllerWithIdentifier:@"PhotoCaption"];
//    contr.captionText=data[currentIndex][@"items"][@"caption"];
//    [self removeChildViewControllerAtIndex:0];
    
    [self performSelector:@selector(dismissPopoverCaption) withObject:nil afterDelay:1];
    
}
-(void)dismissPopoverCaption{
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
-(void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
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
}
 

-(void)viewDidAppear{
//    self.view.wantsLayer = YES;
//    self.view.layer.backgroundColor=[[NSColor colorWithCalibratedRed:0.90 green:0.90 blue:0.90 alpha:0.0]CGColor];
//    self.view.layer.opacity=0.0;
    
    _app = [[appInfo alloc]init];
    self.view.window.titleVisibility=NSWindowTitleVisible;
    self.view.window.titlebarAppearsTransparent = YES;
    
    
    self.view.window.movableByWindowBackground=YES;
    self.view.window.level = NSFloatingWindowLevel;
    NSVisualEffectView* vibrantView = [[NSVisualEffectView alloc] initWithFrame:self.view.frame];
    vibrantView.material=NSVisualEffectMaterialLight;
    
    vibrantView.blendingMode=NSVisualEffectBlendingModeBehindWindow;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(ShowSlider:) name:@"ShowPhotoSlider" object:nil];
//    vibrantView.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
//    vibrantView.wantsLayer=YES;
    self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
    [vibrantView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

    [self.view addSubview:vibrantView positioned:NSWindowBelow relativeTo:self.view];




}
- (IBAction)prevPhotoAction:(id)sender {

    if(currentIndex==0){
        currentIndex=[data count]-1;
    }
    else{
        currentIndex=currentIndex-1;
    }
   
    
    [progressSpin startAnimation:self];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSImage *currentPhoto = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:data[currentIndex][@"items"][@"photoBig"] ? data[currentIndex][@"items"][@"photoBig"] : data[currentIndex][@"photo"][@"original"]]];
        NSImageRep *rep = [[currentPhoto representations] objectAtIndex:0];
        NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
        currentPhoto.size=imageSize;
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateViewConstraints];
            [progressSpin stopAnimation:self];
            [photoView setImage:currentPhoto];
        });
    });
}
- (IBAction)nextPhotoAction:(id)sender {
//    [self.view removeTrackingArea:photoCaptionTrackingArea];
//    [self createTrackingArea];
    if(currentIndex==[data count]-1){
        currentIndex=0;
    }else{
        currentIndex=currentIndex+1;
    }
    [progressSpin startAnimation:self];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSImage *currentPhoto = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:data[currentIndex][@"items"][@"photoBig"] ? data[currentIndex][@"items"][@"photoBig"] : data[currentIndex][@"photo"][@"original"]]];
        NSImageRep *rep = [[currentPhoto representations] objectAtIndex:0];
        NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
        currentPhoto.size=imageSize;
    
        
        dispatch_async(dispatch_get_main_queue(), ^{
         
            
            [progressSpin stopAnimation:self];
            [photoView setImage:currentPhoto];
        });
    });
  
    
   
    
    
}
-(void)ShowSlider:(NSNotification *)notification{
//    NSLog(@"%@", notification.userInfo[@"data"]);
//    [self.view removeTrackingArea:photoCaptionTrackingArea];
//    [self createTrackingArea];
    data = [[NSMutableArray alloc]initWithArray:notification.userInfo[@"data"]];
    currentIndex = [notification.userInfo[@"current"] intValue]-1;
    NSLog(@"%lu", currentIndex);

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSImage *currentPhoto = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:data[currentIndex][@"items"]? data[currentIndex][@"items"][@"photoBig"] : data[currentIndex][@"photo"][@"original"]]];
        NSImageRep *rep = [[currentPhoto representations] objectAtIndex:0];
        NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
        currentPhoto.size=imageSize;
        
    
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
    
            [photoView setImage:currentPhoto];
       
        });
    });
    self.view.window.title =data[0][@"title"] && ![data[0][@"title"] isEqual:@""] ? data[0][@"title"] : @"";
//    self.view.window.title =@"DDD";
//    NSLog(@"%@", data);
}
@end
