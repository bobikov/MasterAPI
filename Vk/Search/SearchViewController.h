//
//  SearchViewController.h
//  vkapp
//
//  Created by sim on 02.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
#import "CustomSearchCell.h"
#import "StringHighlighter.h"
//#import "RFOverlayScrollView.h"
@interface SearchViewController : NSViewController{
    
    __weak IBOutlet NSButton *cancelBut;
    __weak IBOutlet NSSearchField *searchBar;
   
   
    __weak IBOutlet NSButton *addBut;
    __weak IBOutlet NSTableView *foundList;
    __weak IBOutlet NSSegmentedControl *searchType;
    NSMutableArray *foundListData;
     NSDictionary *object;
    BOOL groupsLoaded;
    BOOL peopleLoaded;
    NSString *url;
    NSString *queryString;
    __weak IBOutlet NSButton *byId;
    NSMutableArray *countries;
    __weak IBOutlet NSComboBox *countriesList;
    __weak IBOutlet NSScrollView *searchListScrollView;

    __weak IBOutlet NSButton *loadedCountResults;
    __weak IBOutlet NSClipView *searchListClipView;
    NSInteger searchOffsetCounter;
    NSString *country;
    BOOL usedParams;
}
@property (nonatomic) appInfo *app;
@property(nonatomic)StringHighlighter *stringHighlighter;
@end
