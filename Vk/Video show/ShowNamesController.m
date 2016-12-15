//
//  ShowVideoAlbumNamesController.m
//  MasterAPI
//
//  Created by sim on 11.11.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "ShowNamesController.h"

@interface ShowNamesController ()<NSTableViewDataSource, NSTableViewDelegate>

@end

@implementation ShowNamesController

- (void)viewDidLoad {
    [super viewDidLoad];
    namesList.delegate=self;
    namesList.dataSource=self;
    [namesList reloadData];
    
    CSVArray = [[NSMutableArray alloc]init];
    _manager = [NSFileManager defaultManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNamesData:) name:@"ShowNamesData" object:nil];
    NSLog(@"%@", _receivedData);
}
-(void)showNamesData:(NSNotification*)notification{
    _receivedData = [[NSMutableArray alloc]initWithArray:notification.userInfo[@"data"]];
    [namesList reloadData];
    
    
}
- (IBAction)saveCSV:(id)sender {
       
    [self createCSV];
    [self selectDirectory];
    
}
-(void)createCSV{
    [CSVArray removeAllObjects];
    for(NSDictionary *i in _receivedData){
        [CSVArray addObject:i[@"title"]];
    }
    
    CSVString = [CSVArray componentsJoinedByString:@","];
}
-(void)selectDirectory{
    NSSavePanel *saveDlg = [NSSavePanel savePanel];
    [saveDlg setCanCreateDirectories:YES];
    saveDlg.nameFieldStringValue=@"FileWithNames.txt";
    if([saveDlg runModal] == NSFileHandlingPanelOKButton){
        fileName = [saveDlg nameFieldStringValue];
        filePath = [[[[saveDlg URL] absoluteString]  stringByDeletingLastPathComponent] stringByReplacingOccurrencesOfString:@"file:" withString:@""];
        fullPath = [filePath stringByAppendingPathComponent:fileName];
        [self saveFile];
    }
}
-(void)saveFile{
    if([_manager fileExistsAtPath:fullPath]){
        [[CSVString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fullPath atomically:YES];
    }else{
        [_manager createFileAtPath:fullPath contents:[CSVString dataUsingEncoding:NSUTF8StringEncoding]  attributes:nil];
    }

}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [_receivedData count];
    
}
-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSTableCellView *cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
    cell.textField.stringValue=_receivedData[row][@"title"];
    return cell;
}
@end
