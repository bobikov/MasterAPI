//
//  NSString+MyNSStringCategory.m
//  MasterAPI
//
//  Created by sim on 11.02.17.
//  Copyright © 2017 sim. All rights reserved.
//

#import "NSString+MyNSStringCategory.h"

@implementation NSString (MyNSStringCategory)
+(id)createSuperString:(NSString*)string{
    return [self stringWithFormat:@"%@", string];
}
@end
