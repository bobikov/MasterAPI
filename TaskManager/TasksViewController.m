//
//  TasksViewController.m
//  MasterAPI
//
//  Created by sim on 16.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "TasksViewController.h"
#import <EventKit/EventKit.h>
@interface TasksViewController ()

@end

@implementation TasksViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:2016];
    [dateComponents setMonth:12];
    [dateComponents setDay:19];
    [dateComponents setHour:13];
    [dateComponents setMinute:48];
    NSCalendar *calendar = [[NSCalendar alloc]  initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *configuredDate = [calendar dateFromComponents:dateComponents];
    NSTimeInterval interval = [configuredDate timeIntervalSinceNow];
//    EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:configuredDate];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(openURL:) name:nil object:calendar];
//    NSNotification *not = [[NSNotification alloc]init];
//    [self performSelector:@selector(openURL) withObject:nil afterDelay:interval ];
//    NSTimer *timer = [NSTimer time]
    
    NSUserNotification *oo=[[NSUserNotification alloc]init];
    [oo setDeliveryDate:configuredDate];
    [oo performSelector:@selector(openURL:)];

}
-(void)openURL:(NSNotification*)notification{
   [[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:@"https://google.com"]];
}
@end
