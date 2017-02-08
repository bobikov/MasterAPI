//
//  AppsPreferencesController.m
//  MasterAPI
//
//  Created by sim on 14.10.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "AppsPreferencesController.h"

@interface AppsPreferencesController ()<NSTableViewDelegate, NSTableViewDataSource>

@end

@implementation AppsPreferencesController

- (void)viewDidLoad {
    [super viewDidLoad];
    appsList.delegate=self;
    appsList.dataSource=self;
    appsData = @[@"Vkontakte",@"Youtube", @"Twitter", @"Tumblr", @"Instagram"];
    [appsList reloadData];
   
    
}
- (void)viewDidAppear{
    self.view.window.titleVisibility=NSWindowTitleHidden;
    self.view.window.titlebarAppearsTransparent = YES;
    
    self.view.window.movableByWindowBackground=NO;
//     self.preferredContentSize=self.view.frame.size;
    NSVisualEffectView* vibrantView = [[NSVisualEffectView alloc] initWithFrame:wrapSideMenu.frame];
    vibrantView.material=NSVisualEffectMaterialSidebar;
    
    vibrantView.blendingMode=NSVisualEffectBlendingModeBehindWindow;
    
    
    //    vibrantView.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
    //    vibrantView.wantsLayer=YES;
    self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
    [vibrantView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self.view.window standardWindowButton:NSWindowMiniaturizeButton].hidden=YES;
    [self.view.window standardWindowButton:NSWindowZoomButton].hidden=YES;
    [self.view addSubview:vibrantView positioned:NSWindowBelow relativeTo:self.view];
     [appsList selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:YES];
    
}
-(void)viewWillAppear{
     [self.view.window setMinSize:self.view.window.frame.size];
    [self.view.window setMaxSize:self.view.window.frame.size];
   
//    [self setPreferredContentSize:self.view.window.frame.size];
   
}
-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSInteger row = [appsList selectedRow];
    NSString *item = appsData[row];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AppsPrefsSelect" object:nil userInfo:@{@"item":item}];
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [appsData count];

}
-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSTableCellView *cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
    cell.textField.stringValue=appsData[row];
    return cell;
}
@end
