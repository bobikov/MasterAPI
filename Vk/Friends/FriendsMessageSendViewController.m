//
//  FriendsMessageSendViewController.m
//  vkapp
//
//  Created by sim on 24.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "FriendsMessageSendViewController.h"
#import "SmilesViewController.h"
@interface FriendsMessageSendViewController ()

@end

@implementation FriendsMessageSendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
//     receiverLabel.stringValue = _textForReceiverLabel;
    receiverLabel.stringValue = _recivedDataForMessage[@"first_name"]?[NSString stringWithFormat:@"%@ %@", _recivedDataForMessage[@"first_name"], _recivedDataForMessage[@"last_name"]]:_recivedDataForMessage[@"full_name"];
    photo.wantsLayer=YES;
    photo.layer.masksToBounds=YES;
    photo.layer.cornerRadius=80/2;
    NSImage *image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", _recivedDataForMessage[@"user_photo"]]]];
    NSImageRep *rep = [[image representations] objectAtIndex:0];
    NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
    image.size=imageSize;
    [photo setImage:image];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(insertSmile:) name:@"insertSmileMessage" object:nil];
    
    
}
-(void)insertSmile:(NSNotification*)notification{
    messageText.string = [NSString stringWithFormat:@"%@%@", messageText.string, notification.userInfo[@"smile"]];
}
-(void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"SmilesViewSegue"]){
        SmilesViewController *contr = (SmilesViewController*)segue.destinationController;
        contr.source=@"message";
    }
}
- (IBAction)cancelActions:(id)sender {
    [self dismissController:self];
}
-(void)viewDidAppear{
    NSVisualEffectView* vibrantView = [[NSVisualEffectView alloc] initWithFrame:self.view.frame];
    vibrantView.material=NSVisualEffectMaterialSidebar;
    
    vibrantView.blendingMode=NSVisualEffectBlendingModeBehindWindow;
    
    
    //    vibrantView.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
    //    vibrantView.wantsLayer=YES;
    self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
    [vibrantView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    [self.view addSubview:vibrantView positioned:NSWindowBelow relativeTo:self.view];
}
-(void)setReceiverText{

    
}

@end
