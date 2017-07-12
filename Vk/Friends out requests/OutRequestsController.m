//
//  OutRequestsController.m
//  vkapp
//
//  Created by sim on 29.07.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "OutRequestsController.h"
#import "FullUserInfoPopupViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "MyTableRowView.h"
#import "SYFlatButton+ButtonsStyle.h"
#import <NSColor-HexString/NSColor+HexString.h>
@interface OutRequestsController ()<NSTableViewDelegate, NSTableViewDataSource>
typedef void(^OnGetRequestsComplete)(NSMutableArray* requests);
-(void)getRequests:(OnGetRequestsComplete)completion;
@end

@implementation OutRequestsController

- (void)viewDidLoad {
    [super viewDidLoad];
    outRequestsList.dataSource=self;
    outRequestsList.delegate=self;
    outRequestsData = [[NSMutableArray alloc]init];
    selectedUsers = [[NSMutableArray alloc]init];
    _app = [[appInfo alloc]init];
    _stringHighlighter = [[StringHighlighter alloc]init];
    cachedStatus = [[NSMutableDictionary alloc]init];
    cachedImage = [[NSMutableDictionary alloc]init];
    //     NSBezierPath * path = [NSBezierPath bezierPathWithRoundedRect:favesScrollView.frame xRadius:4 yRadius:4];
    CAShapeLayer * layer = [CAShapeLayer layer];
    [formatter setLocale:[[NSLocale alloc ] initWithLocaleIdentifier:@"ru"]];
    formatter = [[NSDateFormatter alloc]init];
    layer.cornerRadius=4;
    layer.borderWidth=1;
    layer.borderColor=[[NSColor colorWithWhite:0.8 alpha:1]CGColor];
    outRequestsList.enclosingScrollView.wantsLayer = TRUE;
    outRequestsList.enclosingScrollView.layer = layer;
    [self setFlatButtonStyle];
}
-(void)setFlatButtonStyle{
    NSLog(@"%@", self.view.subviews[0].subviews[0].subviews);
    for(NSArray *v in self.view.subviews[0].subviews[0].subviews){
        if([v isKindOfClass:[SYFlatButton class]]){
            button = [[SYFlatButton alloc]initWithFrame:((SYFlatButton*)v).frame];
            [button simpleButton:(SYFlatButton*)v];
        }
    }
}
-(void)viewDidAppear{
    [self loadOutRequests:NO];
}
-(void)viewDidScroll{
    
    
    
    
}

- (IBAction)showFullUserInfo:(id)sender {
    
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Third" bundle:nil];
    FullUserInfoPopupViewController *popuper = [story instantiateControllerWithIdentifier:@"profilePopup"];
//    NSPoint mouseLoc = [NSEvent mouseLocation];
//    int y = mouseLoc.y;
    NSView *parentCell = [sender superview];
    NSInteger row = [outRequestsList rowForView:parentCell];
//    CGRect rect=CGRectMake(0, y, 0, 0);
    popuper.receivedData = outRequestsData[row];
    
//    [self presentViewController:popuper asPopoverRelativeToRect:rect ofView:outRequestsList preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorTransient];
    [popuper setToViewController];
    
    
}
- (IBAction)filterActive:(id)sender {
    [self loadOutRequests:NO];
}
- (IBAction)filterOnline:(id)sender {
    [self loadOutRequests:NO];
}
- (IBAction)filterOffline:(id)sender {
    [self loadOutRequests:NO];
}
- (IBAction)filterMen:(id)sender {
    [self loadOutRequests:NO];
}
- (IBAction)filterWomen:(id)sender {
    [self loadOutRequests:NO];
}

- (IBAction)addToBan:(id)sender {
    NSIndexSet *rows = [outRequestsList selectedRowIndexes];
    [selectedUsers removeAllObjects];
    void(^addToBanBlock)()=^void(){
        for (NSInteger i = [rows firstIndex]; i != NSNotFound; i = [rows indexGreaterThanIndex: i]){
            [selectedUsers addObject:@{@"id":outRequestsData[i][@"id"], @"index":[NSNumber numberWithInteger:i]}] ;
            
            
        }
        for(NSDictionary *i in selectedUsers){
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/account.banUser?user_id=%@&v=%@&access_token=%@", i[@"id"] ,_app.version, _app.token]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *addToBanResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error:nil];
                NSLog(@"%@", addToBanResponse);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [outRequestsList deselectRow:[i[@"index"] intValue]];
                });
            }]resume];
            sleep(1);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [outRequestsData removeObjectsAtIndexes:rows];
            [outRequestsList reloadData];
        });
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        addToBanBlock();
    });
}


-(void)loadOutRequests:(BOOL)makeOffset{
    loading=YES;
    
    if(makeOffset){
        NSLog(@"offset");
        offsetRequests = offsetRequests+500;
    }else{
        NSLog(@"no offset");
        [outRequestsData removeAllObjects];
        offsetRequests = 0;
        counter=0;
    }
    [progressSpin startAnimation:self];
    
    
    __block NSDictionary *object;
   
    __block void(^getRequstesWrap)();
    getRequstesWrap=^(){
        [self getRequests:^(NSMutableArray *requests) {
            NSLog(@"%li", [requests count]);
            if([requests count]>0){
                [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/users.get?user_ids=%@&fields=photo_100,photo_200,domain,country,city,online,last_seen,status,bdate,books,about,sex,site,contacts,verified,music,schools,education,relation&access_token=%@&v=%@", [requests componentsJoinedByString:@","], _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if(data){
                        NSDictionary *getUsersResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        if(getUsersResponse[@"error"]){
                            
                        }else if(getUsersResponse[@"response"]){
                            //NSLog(@"%@", getUsersResponse);
                            
                            for (NSDictionary *a in getUsersResponse[@"response"]){
                                firstName = a[@"first_name"];
                                lastName = a[@"last_name"];
                                fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                                city = a[@"city"] && a[@"city"][@"title"]!=nil ? a[@"city"][@"title"] : @"";
                                status = a[@"status"] && a[@"status"]!=nil ? a[@"status"] : @"";
                                online = [NSString stringWithFormat:@"%@", a[@"online"]];
                                music = a[@"music"] && a[@"music"]!=nil ? a[@"music"] : @"";
                                domain = a[@"domain"] && a[@"domain"]!=nil ? a[@"domain"] : @"";
                                if(a[@"last_seen"] && a[@"last_seen"][@"time"]!=nil){
                                    //                            last_seen = i[@"last_seen"][@"time"];
                                    double timestamp = [a[@"last_seen"][@"time"] intValue];
                                    NSDate *gotDate = [[NSDate alloc] initWithTimeIntervalSince1970: timestamp];
                                    NSString *templateLateTime= @"dd.MM.yy HH:mm";
                                    [formatter setDateFormat:templateLateTime];
                                    last_seen = [NSString stringWithFormat:@"%@", [formatter stringFromDate:gotDate]];
                                }else{
                                    last_seen = @"";
                                }
                                if(a[@"bdate"] && a[@"bdate"]!=nil){
                                    bdate=a[@"bdate"];
                                    templateLateTime2= @"yyyy";
                                    templateLateTime1= @"dd.MM.yyyy";
                                    //                            NSString *todayTemplate =@"d",
                                    [formatter setLocale:[[NSLocale alloc ] initWithLocaleIdentifier:@"ru"]];
                                    [formatter setDateFormat:templateLateTime1];
                                    NSDate *date = [formatter dateFromString:bdate];
                                    [formatter setDateFormat:templateLateTime2];
                                    if(![bdate isEqual:@""]){
                                        bdate = [NSString stringWithFormat:@"%d лет", 2016 - [[formatter stringFromDate:date] intValue]];
                                    }
                                    if([bdate isEqual:@"2016 лет" ]){
                                        bdate=@"";
                                    }
                                    
                                }
                                else{
                                    bdate=@"";
                                }
                                
                                if([online intValue]==1){
                                    last_seen=@"";
                                }
                                countryName = a[@"country"] && a[@"country"]!=nil ? a[@"country"][@"title"] : @"";
                                site = a[@"site"] && a[@"site"]!=nil ? a[@"site"] :  @"";
                                photoBig = a[@"photo_200"] ? a[@"photo_200"] : a[@"photo_200_orig"] ? a[@"photo_200_orig"] : a[@"photo_100"] ? a[@"photo_100"] : a[@"photo_50"];
                                photo = a[@"photo_100"];
                                mobilePhone = a[@"mobile_phone"] && a[@"mobile_phone"]!=nil ? a[@"mobile_phone"] : @"";
                                sex = a[@"sex"] && [a[@"sex"] intValue]==1 ? @"W" :[a[@"sex"] intValue]==2 ?  @"M" : [a[@"sex"] intValue]==0 ? @"n/a" : @"";
                                books = a[@"books"] && a[@"books"]!=nil ? a[@"books"] : @"";
                                about = a[@"about"] && a[@"about"]!=nil ? a[@"about"] : @"";
                                verified = a[@"verified"] && a[@"verified"]!=nil ? a[@"verified"] : @"";
                                education = a[@"university_name"] && a[@"university_name"]!=nil ? a[@"university_name"] : @"";
                                schools = a[@"schools"] && a[@"schools"]!=nil &&  [a[@"schools"] count] > 0  ? a[@"schools"][0][@"name"] : @"";
                                quotes = a[@"quotes"] && a[@"quotes"]!=nil ? a[@"quotes"] : @"";
                                relation = a[@"relation"] && a[@"relation"]!=nil ? a[@"relation"] : @"";
                                object = @{@"id":a[@"id"], @"full_name":fullName, @"city":city, @"status":status, @"user_photo":photo, @"bdate":@"", @"country":countryName, @"online":online, @"user_photo_big":photoBig,  @"last_seen":last_seen, @"books":books, @"site":site, @"about":about, @"mobile":mobilePhone, @"sex":sex, @"verified":verified, @"music":music, @"schools":schools, @"university_name":education, @"quotes":quotes, @"relation":relation,@"domain":domain};
                                
                                
                                if(filterOnline.state==1 && filterOffline.state ==1 && filterActive.state == 1){
                                    
                                    //                            if(searchByName){
                                    //                                NSArray *found = [regex matchesInString:fullName  options:0 range:NSMakeRange(0, [fullName length])];
                                    //                                if([found count]>0 && ![searchBar.stringValue isEqual:@""]){
                                    //                                    counter++;
                                    //                                    [outRequestsData addObject:object];
                                    //                                }
                                    //                            }
                                    //                            else{
                                    
                                    if(!a[@"deactivated"]){
                                        if(filterWomen.state==1 && filterMen.state==1){
                                            if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] ==2){
                                                counter++;
                                                [outRequestsData addObject:object];
                                            }
                                        }
                                        else if(filterWomen.state==1 && filterMen.state==0){
                                            if([a[@"sex"] intValue]==1){
                                                counter++;
                                                [outRequestsData addObject:object];
                                            }
                                            
                                        }
                                        else if(filterWomen.state==0 && filterMen.state==1){
                                            if([a[@"sex"] intValue]==2){
                                                counter++;
                                                [outRequestsData addObject:object];
                                            }
                                            
                                        }
                                        else if(filterWomen.state==0 && filterMen.state==0){
                                            if([a[@"sex"] intValue]==0){
                                                counter++;
                                                [outRequestsData addObject:object];
                                            }
                                            
                                        }
                                        
                                    }
                                    //                            }
                                }
                                else if(filterOnline.state==0 && filterOffline.state ==1 && filterActive.state == 1 ) {
                                    
                                    
                                    if(!a[@"deactivated"]){
                                        if ([online intValue] != 1){
                                            
                                            if(filterWomen.state==1 && filterMen.state==1){
                                                if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] ==2){
                                                    counter++;
                                                    [outRequestsData addObject:object];
                                                }
                                            }
                                            else if(filterWomen.state==1 && filterMen.state==0){
                                                if([a[@"sex"] intValue]==1){
                                                    counter++;
                                                    [outRequestsData addObject:object];
                                                }
                                                
                                            }
                                            else if(filterWomen.state==0 && filterMen.state==1){
                                                if([a[@"sex"] intValue]==2){
                                                    counter++;
                                                    [outRequestsData addObject:object];
                                                }
                                                
                                            }
                                            else if(filterWomen.state==0 && filterMen.state==0){
                                                if([a[@"sex"] intValue]==0){
                                                    counter++;
                                                    [outRequestsData addObject:object];
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                                else if(filterOnline.state==1 && filterOffline.state ==0 && filterActive.state == 1) {
                                    
                                    if ([online  isEqual: @"1"]){
                                        
                                        if(filterWomen.state==1 && filterMen.state==1){
                                            if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] ==2){
                                                counter++;
                                                [outRequestsData addObject:object];
                                            }
                                        }
                                        else if(filterWomen.state==1 && filterMen.state==0){
                                            if([a[@"sex"] intValue]==1){
                                                counter++;
                                                [outRequestsData addObject:object];
                                            }
                                        }
                                        else if(filterWomen.state==0 && filterMen.state==1){
                                            if([a[@"sex"] intValue]==2){
                                                counter++;
                                                [outRequestsData addObject:object];
                                            }
                                        }
                                        else if(filterWomen.state==0 && filterMen.state==0){
                                            if([a[@"sex"] intValue]==0){
                                                counter++;
                                                [outRequestsData addObject:object];
                                            }
                                        }
                                    }
                                }
                                else if(filterOnline.state==0 && filterOffline.state == 1 && filterActive.state == 0) {
                                    
                                    if (a[@"deactivated"]){
                                        
                                        if(filterWomen.state==1 && filterMen.state==1){
                                            if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] ==2){
                                                counter++;
                                                [outRequestsData addObject:object];
                                            }
                                        }
                                        else if(filterWomen.state==1 && filterMen.state==0){
                                            if([a[@"sex"] intValue]==1){
                                                counter++;
                                                [outRequestsData addObject:object];
                                            }
                                        }
                                        else if(filterWomen.state==0 && filterMen.state==1){
                                            if([a[@"sex"] intValue]==2){
                                                counter++;
                                                [outRequestsData addObject:object];
                                            }
                                        }
                                        else if(filterWomen.state==0 && filterMen.state==0){
                                            if([a[@"sex"] intValue]==0){
                                                counter++;
                                                [outRequestsData addObject:object];
                                            }
                                        }
                                    }
                                }
                                else if(filterOnline.state==1 && filterOffline.state == 1 && filterActive.state == 0) {
                                    
                                    if (a[@"deactivated"] && ([online intValue]==1 || [online intValue]==0)){
                                        
                                        if(filterWomen.state==1 && filterMen.state==1){
                                            if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] ==2){
                                                counter++;
                                                [outRequestsData addObject:object];
                                            }
                                        }
                                        else if(filterWomen.state==1 && filterMen.state==0){
                                            if([a[@"sex"] intValue]==1){
                                                counter++;
                                                [outRequestsData addObject:object];
                                            }
                                        }
                                        else if(filterWomen.state==0 && filterMen.state==1){
                                            if([a[@"sex"] intValue]==2){
                                                counter++;
                                                [outRequestsData addObject:object];
                                            }
                                        }
                                        else if(filterWomen.state==0 && filterMen.state==0){
                                            if([a[@"sex"] intValue]==0){
                                                counter++;
                                                [outRequestsData addObject:object];
                                            }
                                        }
                                    }
                                }
                            }
                            
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            loading=NO;
                            NSLog(@"%li",[outRequestsData count]);
                            [outRequestsList reloadData];
                            
                            [progressSpin stopAnimation:self];
                            loadedCount.title = [NSString stringWithFormat:@"%i",counter];
                            
                        });
                    }
                    NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
                    if (!error && statusCode == 200) {
                        // even fancier code goes here
                    } else {
                        // omg!!!!!!!!!
                        NSLog(@"Server error code on Friends Out Requests request:%li", statusCode);
                        if(![outRequestsData count]){
                            getRequstesWrap();
                            sleep(2);
                        }
                    }
                  
                  
                    
                }]resume];
            }
        }];
    };
    getRequstesWrap();
    
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row{
    MyTableRowView *rowView = [[MyTableRowView alloc]init];
    return rowView;
}
-(void)getRequests:(OnGetRequestsComplete)completion{
    NSMutableArray *requests=[[NSMutableArray alloc]init];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/friends.getRequests?offset=%lu&count=500&out=1&access_token=%@&v=%@", offsetRequests, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data){
            NSDictionary *getOutRequestsResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                totalCount.title = [NSString stringWithFormat:@"%@",getOutRequestsResponse[@"response"][@"count"]];
            });
            if(getOutRequestsResponse[@"error"]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [progressSpin stopAnimation:self];
                });
            }else{
                for(NSString *i in getOutRequestsResponse[@"response"][@"items"]){
                    [requests addObject:i];
                    //NSLog(@"%@", i);
                }
                
                completion(requests);
                
            }
        }
        
    }]resume];
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [outRequestsData count];
}
-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
        OutRequestsCustomCell *cell = [[OutRequestsCustomCell alloc]init];
        cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
        cell.fullName.stringValue = outRequestsData[row][@"full_name"];
        cell.lastSeen.stringValue = outRequestsData[row][@"last_seen"];
//        cell.status.stringValue = outRequestsData[row][@"status"];
        [cell.status setAllowsEditingTextAttributes:YES];
       
        cell.city.stringValue = outRequestsData[row][@"city"];
        cell.country.stringValue = outRequestsData[row][@"country"];
        cell.bdate.stringValue = outRequestsData[row][@"bdate"];
        cell.sex.stringValue = outRequestsData[row][@"sex"];

        cell.verified.hidden=![outRequestsData[row][@"verified"] intValue];
       
        [_stringHighlighter highlightStringWithURLs:outRequestsData[row][@"status"] Emails:YES fontSize:12 completion:^(NSMutableAttributedString *highlightedString) {
            cell.status.attributedStringValue=highlightedString;
        }];
        
        
        [cell.photo sd_setImageWithURL: [NSURL URLWithString:[NSString stringWithFormat:@"%@", outRequestsData[row][@"user_photo"]]] placeholderImage:nil options:SDWebImageRefreshCached progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
            
        } completed:^(NSImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            NSImageRep *rep = [[image representations] objectAtIndex:0];
            NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
            image.size=imageSize;
            [cell.photo setImage:image];
        }];
        if([outRequestsData[row][@"online"] intValue] == 1){
            [cell.online setImage:[NSImage imageNamed:NSImageNameStatusAvailable]];
        }
        else{
             [cell.online setImage:[NSImage imageNamed:NSImageNameStatusNone]];
        }
        
        return cell;

}


@end
