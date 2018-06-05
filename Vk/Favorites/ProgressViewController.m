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
    
    _app = [[appInfo alloc]init];
    [self setProcess];
    [self unlike];
}
-(void)setProcess{
    proccessLabel.stringValue = [NSString stringWithFormat:@"%li/%li",_current,_total];
}
-(void)unlike{
    for (NSDictionary *i in _items){
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/likes.delete?type=video&item_id=%@&owner_id=%@&access_token=%@&v=%@", i[@"id"], i[@"owner_id"], _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(data){
                NSDictionary *obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSLog(@"%@", obj);
                if(obj[@"response"][@"likes"]){
                    _current+=1;
                }else{
                    
                }
            }else{
                NSLog(@"No data");
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setProcess];
                if(_current==_total){
                     [self dismissController:self];
                }
            });
            sleep(1);
        }]resume];
        
    }
   
}
@end
