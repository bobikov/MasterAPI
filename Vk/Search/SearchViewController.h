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
    __weak IBOutlet NSComboBox *religionsList;
    __weak IBOutlet NSButton *addBut;
    __weak IBOutlet NSTableView *foundList;
    __weak IBOutlet NSSegmentedControl *searchType;
    __weak IBOutlet NSComboBox *countriesList;
    __weak IBOutlet NSComboBox *citiesList;
    __weak IBOutlet NSScrollView *searchListScrollView;
    __weak IBOutlet NSButton *loadedCountResults;
    __weak IBOutlet NSClipView *searchListClipView;
    __weak IBOutlet NSButton *byId;
    __weak IBOutlet NSButton *searchWithParamsButton;
    
    NSInteger searchOffsetCounter;
    
    NSDictionary *object;
    
    NSMutableArray
        *countries,
        *cities,
        *foundListData;
 
    NSString
        *countryID,
        *cityID,
        *cityQuery,
        *religion,
        *selectedSourceName,
        *url,
        *queryString;

    BOOL
        usedParams,
        peopleLoaded,
        groupsLoaded;

}
@property (nonatomic) appInfo *app;
@property(nonatomic)StringHighlighter *stringHighlighter;
@end
