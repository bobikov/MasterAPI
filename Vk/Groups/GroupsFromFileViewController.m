//
//  GroupsFromFileViewController.m
//  vkapp
//
//  Created by sim on 16.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "GroupsFromFileViewController.h"
#import "MainViewController.h"
#import "AppDelegate.h"
@interface GroupsFromFileViewController ()<NSTableViewDelegate, NSTableViewDataSource, NSSearchFieldDelegate>

@end

@implementation GroupsFromFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    membershipGroupsList.delegate=self;
    membershipGroupsList.dataSource=self;
    searchBar.delegate=self;
    _groupsHandle = [[groupsHandler alloc]init];
    membershipGroupsData = [[NSMutableArray alloc]init];
   
    [self loadMembershipGroups];
   
}
-(void)viewDidAppear{
    self.view.window.titleVisibility=NSWindowTitleHidden;
    self.view.window.titlebarAppearsTransparent = YES;
    self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
    self.view.window.movableByWindowBackground=YES;
    [self.view.window setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantLight]];
    self.view.window.level = NSFloatingWindowLevel;
    NSVisualEffectView* vibrantView = [[NSVisualEffectView alloc] initWithFrame:self.view.frame];
    vibrantView.material=NSVisualEffectMaterialLight;
    
    vibrantView.blendingMode=NSVisualEffectBlendingModeBehindWindow;
    
    
    //    vibrantView.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
    //    vibrantView.wantsLayer=YES;
    self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
    [vibrantView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    [self.view addSubview:vibrantView positioned:NSWindowBelow relativeTo:self.view];
}
-(void)searchFieldDidStartSearching:(NSSearchField *)sender{
    [self loadSearchMembershipGroups];
}
-(void)searchFieldDidEndSearching:(NSSearchField *)sender{
    
    membershipGroupsData = membershipGroupsDataCopy;
    [membershipGroupsList reloadData];
}
-(void)loadSearchMembershipGroups{
    
    NSInteger counter=0;
    NSMutableArray *membershipGroupsDataTemp=[[NSMutableArray alloc]init];
    membershipGroupsDataCopy = [[NSMutableArray alloc]initWithArray:membershipGroupsData];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:searchBar.stringValue options:NSRegularExpressionCaseInsensitive error:nil];
    [membershipGroupsDataTemp removeAllObjects];
    for(NSDictionary *i in membershipGroupsData){
        
        NSArray *found = [regex matchesInString:i[@"name"]  options:0 range:NSMakeRange(0, [i[@"name"] length])];
        if([found count]>0 && ![searchBar.stringValue isEqual:@""]){
            counter++;
            [membershipGroupsDataTemp addObject:i];
        }
        
    }
    //     NSLog(@"Start search %@", banlistDataTemp);
    if([membershipGroupsDataTemp count]>0){
        membershipGroupsData = membershipGroupsDataTemp;
        [membershipGroupsList reloadData];
    }
    
}
-(void)loadMembershipGroups{
//    if([_groupsHandle readFromFile]!=nil){
//        membershipGroupsData = [_groupsHandle readFromFile];
//        [membershipGroupsList reloadData];
//    }
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    moc = ((AppDelegate*)[[NSApplication sharedApplication] delegate]).managedObjectContext;
    temporaryContext.parentContext = moc;
    //    if([groupsData count]==0){
    //        _groupsHandle = [[groupsHandler alloc] init];
    //        //    NSLog(@"%@", [_groupsHandle readFromFile]);
    //        if ([_groupsHandle readFromFile]!=nil){
    //            groupsData = [_groupsHandle readFromFile];
    //            totalCountGroups.title = [NSString stringWithFormat:@"%li", [groupsData count] ];
    //            loadedCountGroups.title =[NSString stringWithFormat:@"%li", [groupsData count] ];
    ////            NSLog(@"%@", groupsData[0][@"name"]);
    //            //            arrayController1.content=groupsData1;
    //            [groupsList reloadData];
    //        }else{
    //            NSLog(@"Check your groups file");
    //        }
    //    }else{
    //        //        arrayController1.content=groupsData1;
    //        [groupsList reloadData];
    //    }
   
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VKGroups"];
     NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"VKGroups" inManagedObjectContext:temporaryContext];
    [request setEntity:entityDesc];
    [request setReturnsObjectsAsFaults:NO];
    [request setResultType:NSDictionaryResultType];
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if([array count]>0){
        membershipGroupsData = [[NSMutableArray alloc] initWithArray:array];
//        totalCountGroups.title = [NSString stringWithFormat:@"%li", [groupsData count] ];
//        loadedCountGroups.title =[NSString stringWithFormat:@"%li", [groupsData count] ];
        //    NSLog(@"%@", array);
        [membershipGroupsList reloadData];
    }
    //    if (array != nil) {
    //        for(NSDictionary *i in array){
    //            NSLog(@"%@", i);
    //        }
    //    }
    //    else {
    //        NSLog(@"Error");
    //    }
}
- (IBAction)showAlbums:(id)sender {
    NSView *parentCell = [sender superview];
    NSInteger row = [membershipGroupsList rowForView:parentCell];
     NSDictionary *groupData = membershipGroupsData[row];
    if([_recivedData[@"type"] isEqual:@"video"]){
       
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadVideoAlbumsFromMembershipGroups" object:nil  userInfo:groupData];
    }
    else{
          [[NSNotificationCenter defaultCenter] postNotificationName:@"loadPhotoAlbumsFromMembershipGroups" object:nil  userInfo:groupData];
    }
//    NSLog(@"%@",  contr.showCurrentController);
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"showCurrentMainController" object:nil];
//    if([self.parentViewController.childViewControllers[0].title isEqual:@"ShowPhoto"]){
//        NSLog(@"ShowPhoto");
//    }
//    else if([self.parentViewController.childViewControllers[0].title isEqual:@"ShowVideo"]){
//         NSLog(@"ShowVideo");
//    }
    
}
-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if([membershipGroupsData count]>0){
        return [membershipGroupsData count];
    }
    return 0;
}
-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    GroupsFromFileCustomCell *cell = [[GroupsFromFileCustomCell alloc]init];
    cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
    cell.name.stringValue = membershipGroupsData[row][@"name"];
    cell.photo.wantsLayer = YES;
    cell.photo.layer.masksToBounds = YES;
    cell.photo.layer.cornerRadius = 43/2;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", membershipGroupsData[row][@"photo"]]]];
        NSSize imSize=NSMakeSize(80, 80);
        image.size=imSize;
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.photo setImage:image];
        });
    });
    return cell;
}
@end
