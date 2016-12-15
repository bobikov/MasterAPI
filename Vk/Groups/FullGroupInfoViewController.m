//
//  FullGroupInfoViewController.m
//  MasterAPI
//
//  Created by sim on 01.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "FullGroupInfoViewController.h"

@interface FullGroupInfoViewController ()

@end

@implementation FullGroupInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _app = [[appInfo alloc]init];
    groupDataById = [[NSMutableArray alloc]init];
    photo.wantsLayer=YES;
    photo.layer.masksToBounds=YES;
    photo.layer.cornerRadius = 5;
     [self prepareLoadInfo];
    [site setAllowsEditingTextAttributes:YES];
}
-(void)viewDidAppear{
 
}
-(void)prepareLoadInfo{
//    if(_receivedData[@"url"]){
//        [self loadInfoByURLRequest];
//         NSLog(@"%@", [_receivedData[@"id"] componentsSeparatedByString:@"_"][2]);
//    }else{
        [self loadInfoByRecivedData];
       
//    }
}
-(void)loadInfoByRecivedData{
   
    
    desc.stringValue = _receivedData[@"desc"];
    name.stringValue = _receivedData[@"name"];
    screenName.stringValue = _receivedData[@"screen_name"];
    status.stringValue = _receivedData[@"status"];
    site.attributedStringValue = [self getAttributedStringWithURLExternSites:_receivedData[@"site"]];
    [site setFont:[NSFont systemFontOfSize:13 weight:NSFontWeightRegular]];
    groupId.stringValue = _receivedData[@"id"];
//    site.stringValue = _receivedData[@"site"];
    city.stringValue = _receivedData[@"city"];
    country.stringValue = _receivedData[@"country"];
    startDate.stringValue =  [self formatStartDateGroup:0];
    membersCount.stringValue =  [NSString stringWithFormat:@"Members count: %@",_receivedData[@"members_count"]];
    NSLog(@"%@", _receivedData);
//    NSLog(@"%@",[self formatStartDateGroup:0]);
    //    NSLog(@"%@", year, month, day);
    //    NSLog(@"%f", timestamp );
//    [_receivedData[@"desc"] isEqual:@""] ? desc.hidden=YES :  NO;
//    [_receivedData[@"name"] isEqual:@""] ? name.hidden=YES :  NO;
//    [_receivedData[@"screen_name"] isEqual:@""] ? screenName.hidden=YES :  NO;
//    [_receivedData[@"status"] isEqual:@""] ? status.hidden=YES :  NO;
//    [_receivedData[@"id"] isEqual:@""] ? groupId.hidden=YES :  NO;
//    [_receivedData[@"site"] isEqual:@""] ? site.hidden=YES :  NO;
//    [_receivedData[@"city"] isEqual:@""] ? city.hidden=YES :  NO;
//    [_receivedData[@"country"] isEqual:@""] ? country.hidden=YES :  NO;
//    [_receivedData[@"start_date"] isEqual:@""] ? name.hidden=YES :  NO;
//    [_receivedData[@"members_count"] isEqual:@""] ? membersCount.hidden=YES :  NO;
   
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:_receivedData[@"photo"]]];
        NSImageRep *rep = [[image representations] objectAtIndex:0];
        NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
        image.size=imageSize;
        if(image){
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [photo setImage:image];
            });
        }
        
    });
   
}
-(void)loadInfoByURLRequest{
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.getById?group_ids=%@&v=%@&access_token=%@&extended=1&fields=description,city,country,members_count,status,site,start_date,finish_date", [_receivedData[@"id"] componentsSeparatedByString:@"_"][2],  _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *groupGetByIdResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        //        NSLog(@"%@", groupsGetResponse);
        NSString *gdesc;
        NSString *gphoto;
        NSString *gdeactivated;
        NSString *gcity;
        NSString *gcountry;
        NSNumber *gmembersCount;
        NSString *gstatus;
        NSNumber *gstartDate;
        NSNumber *gfinishDate;
        NSNumber *gisAdmin;
        NSNumber *gisClosed;
        NSNumber *gisMember;
        NSString *gsite;
        NSString *gtype;
        NSString *gscreenName;
        for(NSDictionary *i in groupGetByIdResp[@"response"]){
//            NSLog(@"%@",i);
            gdesc = i[@"description"] && i[@"description"] != nil ? i[@"description"] : @"";
            gphoto = i[@"photo_200"] ? i[@"photo_200"] : i[@"photo_100"] ?  i[@"photo_100"] : i[@"photo_50"];
            gdeactivated = i[@"deactivated"] ? i[@"deactivated"] : @"";
            gmembersCount = i[@"members_count"] && i[@"members_count"] != nil ? i[@"members_count"] : @0;
            gstatus = i[@"status"] && i[@"status"]  != nil ? i[@"status"] : @"";
            gstartDate = i[@"start_date"] && i[@"start_date"]!=nil ? i[@"start_date"] : @0;
            gfinishDate = i[@"finish_date"] && i[@"finish_date"]!=nil ? i[@"finish_date"]  : @0;
            gisClosed =  [i[@"is_closed"] intValue] == 0 ? @NO : @YES;
            gisAdmin =  [i[@"is_admin"] intValue]==0 ? @NO : @YES;
            gisMember =  [i[@"is_member"] intValue]==0 ? @NO : @YES;
            gsite = i[@"site"] && i[@"site"] != nil ? i[@"site"] : @"";
            gcountry = i[@"country"] && i[@"country"][@"title"] != nil ? i[@"country"][@"title"] : @"";
            gtype = i[@"type"] && i[@"type"] != nil ? i[@"type"] : @"";
            gscreenName = i[@"screen_name"] && i[@"screen_name"] != nil ? i[@"screen_name"] : @"";
            gcity = i[@"city"] && i[@"city"][@"title"]!=nil ? i[@"city"][@"title"] : @"";
//
            
            [groupDataById addObject:@{@"name":i[@"name"], @"id":[NSString stringWithFormat:@"%@",i[@"id"]], @"deactivated":gdeactivated, @"desc":gdesc, @"photo":gphoto, @"members_count":gmembersCount, @"status":gstatus, @"site":gsite, @"start_date":gstartDate, @"country":gcountry, @"city":gcity, @"type":gtype, @"screen_name":gscreenName, @"is_member":gisMember, @"finish_date":gfinishDate}];
            
            
        }
//
        dispatch_async(dispatch_get_main_queue(), ^{
//               NSLog(@"%@", groupDataById[0]);
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:groupDataById[0][@"photo"]]];
//                
//                image.size = NSMakeSize(200, 200);
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [photo setImage:image];
//                });
//                
//            });
            [desc setStringValue:groupDataById[0][@"desc"]];
            name.stringValue = groupDataById[0][@"name"];
            screenName.stringValue = groupDataById[0][@"screen_name"];
            status.stringValue = groupDataById[0][@"status"];
            groupId.stringValue = groupDataById[0][@"id"];
            site.stringValue = groupDataById[0][@"site"];
            city.stringValue = groupDataById[0][@"city"];
            country.stringValue = groupDataById[0][@"country"];
            membersCount.stringValue = [NSString stringWithFormat:@"Members count: %@", groupDataById[0][@"members_count"]];
            startDate.stringValue =  [self formatStartDateGroup:[groupDataById[0][@"start_date"] intValue] == 0 ? 0 :[groupDataById[0][@"start_date"] intValue]];
            photo.wantsLayer=YES;
            photo.layer.masksToBounds=YES;
            photo.layer.cornerRadius = 5;
            
        });
   

    }]resume];
}
-(id)formatStartDateGroup:(int)stamp{
    NSString *date;
    NSString *year;
    NSString *month;
    NSString *day;
    int timestamp;
    if(stamp){
        timestamp = stamp;
    }
    else{
        timestamp = [_receivedData[@"start_date"] intValue] == 0 ? 0 :[_receivedData[@"start_date"] intValue];
    }
    if(timestamp != 0){
//        NSDate *gotDate = [[NSDate alloc] initWithTimeIntervalSince1970: timestamp ];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSString *templateLateTime= @"yy.MM.dd";
        
        // NSString *todayTemplate =@"d",
        //        [formatter setLocale:[[NSLocale alloc ] initWithLocaleIdentifier:@"ru"]];
        [formatter setDateFormat:templateLateTime];
        date = [NSString stringWithFormat:@"%i", timestamp];
        NSMutableArray *dateArray = [[NSMutableArray alloc]init];
        for(int i = 0; i < [date length] ; i++){
            [dateArray addObject:[NSString stringWithFormat:@"%C", [date characterAtIndex:i]]];
            
        }
        year = [NSString stringWithFormat:@"%@%@%@%@", dateArray[0], dateArray[1], dateArray[2], dateArray[3]];
        month = [NSString stringWithFormat:@"%@%@", dateArray[4], dateArray[5]];
        day = [NSString stringWithFormat:@"%@%@", dateArray[6], dateArray[7]];
        date = [NSString stringWithFormat:@"%@.%@.%@", year, month, day ];
    }else{
        date = @"";
    }
    return date;
}
-(id)getAttributedStringWithURLExternSites:(NSString*)fullString{
    NSMutableAttributedString *string;
    string = [[NSMutableAttributedString alloc]initWithString:fullString];
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?i)\\b((?:[a-z][\\w-]+:(?:/{1,3}|[a-z0-9%])|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?«»“”‘’]))" options:NSRegularExpressionCaseInsensitive error:&error];
    //    NSUInteger numberOfMatches = [regex numberOfMatchesInString:fullString options:0 range:NSMakeRange(0, [_receivedData[@"site"] length])];
    NSArray *matches = [regex matchesInString:fullString options:0 range:NSMakeRange(0, [fullString length])];
    //        NSLog(@"%@", matches);
    //        NSLog(@"Found %li",numberOfMatches);
    for (NSTextCheckingResult *match in matches){
        //            NSRange matchRange = match.range;
        NSRange range = [match rangeAtIndex:[matches indexOfObject:match]];
        //        NSLog(@"match: %@", [fullString substringWithRange:range]);
        
        NSRange foundRange = [string.mutableString rangeOfString:[fullString substringWithRange:range]  options:NSCaseInsensitiveSearch];
        if (foundRange.location != NSNotFound) {
            //                       NSLog(@"range found");
            [string addAttribute:NSLinkAttributeName value:[[NSURL URLWithString:[fullString substringWithRange:range]]absoluteString] range:foundRange];
            [string addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:foundRange];
            [string addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor]  range:foundRange];
       
            
            
        }
        
    }
    [string addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:12 weight:NSFontWeightRegular] range:NSMakeRange(0, [string length])];
    return string;
    
    
}
@end
