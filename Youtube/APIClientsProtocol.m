//
//  APIClientsProtocol.m
//  MasterAPI
//
//  Created by sim on 15.02.17.
//  Copyright © 2017 sim. All rights reserved.
//

#import "APIClientsProtocol.h"

@implementation APIClientsProtocol
@synthesize youtubeClient;
-(id)init{
    self = [super self];
    youtubeClient = [[YoutubeClient alloc]initWithTokensFromCoreData];
    return self;
}
@end
