//
//  StringHighlighter.h
//  MasterAPI
//
//  Created by sim on 28.11.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface StringHighlighter : NSObject
-(NSMutableAttributedString*)highlightStringWithURLs:(NSString*)fullString Emails:(BOOL)Emails fontSize:(NSInteger)fontSize;
-(NSMutableAttributedString*)createLinkFromSubstring:(NSString*)fullString URL:(NSString *)URL subString:(NSString*)subString;
@end
