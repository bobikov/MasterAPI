//
//  StringHighlighter.h
//  MasterAPI
//
//  Created by sim on 28.11.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface StringHighlighter : NSObject{
    NSMutableDictionary *cachedStrings;
}
typedef void(^OnComplete)(NSMutableAttributedString *highlightedString);
-(void)highlightStringWithURLs:(NSString*)fullString Emails:(BOOL)Emails fontSize:(NSInteger)fontSize completion:(OnComplete)completion;
-(NSMutableAttributedString*)createLinkFromSubstring:(NSString*)fullString URL:(NSString *)URL subString:(NSString*)subString;
@end
