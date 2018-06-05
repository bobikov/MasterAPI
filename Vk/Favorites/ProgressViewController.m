//
//  ProgressViewController.m
//  MasterAPI
//
//  Created by sim on 06/06/18.
//  Copyright © 2018 sim. All rights reserved.
//

#import "ProgressViewController.h"

@interface ProgressViewController ()

@end

@implementation ProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _current=0;
    _total=_total?_total:0;
    proccessLabel.stringValue = [NSString stringWithFormat:@"%li/%li",_current,_total];
}

@end
