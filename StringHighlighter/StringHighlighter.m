//
//  StringHighlighter.m
//  MasterAPI
//
//  Created by sim on 28.11.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "StringHighlighter.h"

@implementation StringHighlighter
-(id)init{
    self = [super self];
    cachedStrings = [[NSMutableDictionary alloc]init];
    return self;
}
-(void)highlightStringWithURLs:(NSString *)fullString Emails:(BOOL)Emails fontSize:(NSInteger)fontSize completion:(OnComplete)completion{
    if(cachedStrings[fullString]){
        completion(cachedStrings[fullString]);
    }else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if(fullString){
                NSMutableAttributedString *string;
                string = [[NSMutableAttributedString alloc]initWithString:fullString];
                NSError *error = NULL;
                //\\U0001F300-\\U0001F5FF\\U0001F910-\\U0001F9C0\\U00002070-\\U0000209C
                
                //\\U00000000-\\U0000FFFF
                if(string){
                    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?i)\\b((?:https?|ftp:(?:/{1,3}|[a-z0-9%])|www\\d{0,3}[.]|[\\w0-9.\\-]+[.][\\w]{2,4}/)(?:[^|\\U00000410-\\U0000044F\\U00002700-\\U000027BF\\U0001F300-\\U0001F5FF\\U0001F910-\\U0001F9C0\\U00002070-\\U0000209C\\s()<>]+|\\(([^|\\s()<>]+|(\\([^|\\U00000410-\\U0000044F\\U00002700-\\U000027BF\\U0001F300-\\U0001F5FF\\U0001F910-\\U0001F9C0\\U00002070-\\U0000209C\\s()<>]+\\)))*\\))+(?:\\(([^|\\U00000410-\\U0000044F\\U00002700-\\U000027BF\\U0001F300-\\U0001F5FF\\U0001F910-\\U0001F9C0\\U00002070-\\U0000209C\\s()<>]+|(\\([^|\\s()<>]+\\)))*\\)|[^|\\U00000410-\\U0000044F\\U00002700-\\U000027BF\\U0001F300-\\U0001F5FF\\U0001F910-\\U0001F9C0\\U00002070-\\U0000209C\\s`!()\\[\\]{};:'\".,<>?«»“”‘’]))" options:NSRegularExpressionCaseInsensitive error:&error];
                    //    NSUInteger numberOfMatches = [regex numberOfMatchesInString:fullString options:0 range:NSMakeRange(0, [_receivedData[@"site"] length])];
                    NSArray *matches = [regex matchesInString:fullString options:0 range:NSMakeRange(0, [fullString length])];
                    //        NSLog(@"%@", matches);
                    //        NSLog(@"Found %li",numberOfMatches);
                    if([matches lastObject]){
                        for (NSTextCheckingResult *match in matches){
                            //            NSRange matchRange = match.range;
                            
                            //        NSLog(@"match: %@", [fullString substringWithRange:range]);
                            
                            NSRange foundRange = [string.mutableString rangeOfString:[fullString substringWithRange:match.range]  options:NSCaseInsensitiveSearch];
                            if (foundRange.location != NSNotFound) {
                                //                       NSLog(@"range found");
                                [string addAttribute:NSLinkAttributeName value:[[NSURL URLWithString:[fullString substringWithRange:match.range]]absoluteString] range:foundRange];
                                [string addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:foundRange];
                                [string addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor]  range:foundRange];
                                
                                
                            }
                            
                        }
                    }
                    NSRegularExpression *regex2 = [NSRegularExpression regularExpressionWithPattern:@"(?i)(?<!(//|\\w|(www\\.)|@))(?:[a-z0-9-_\\.])+\\.(?:ru|com|net|info|tv|uk|de|ua)/?(?![^\\w/|\\U00000410-\\U0000044F\\U00002700-\\U000027BF\\U0001F300-\\U0001F5FF\\U0001F910-\\U0001F9C0\\U00002070-\\U0000209C\\s()<>])" options:NSRegularExpressionCaseInsensitive error:&error];
                    //    NSUInteger numberOfMatches = [regex numberOfMatchesInString:fullString options:0 range:NSMakeRange(0, [_receivedData[@"site"] length])];
                    NSArray *matches2 = [regex2 matchesInString:fullString options:0 range:NSMakeRange(0, [fullString length])];
                    //        NSLog(@"%@", matches);
                    //        NSLog(@"Found %li",numberOfMatches);
                    if([matches2 lastObject])
                        for (NSTextCheckingResult *match in matches2){
                            //            NSRange matchRange = match.range;
                            
                            //        NSLog(@"match: %@", [fullString substringWithRange:range]);
                            
                            NSRange foundRange = [string.mutableString rangeOfString:[fullString substringWithRange:match.range]  options:NSCaseInsensitiveSearch];
                            if (foundRange.location != NSNotFound) {
                                //                       NSLog(@"range found");
                                [string addAttribute:NSLinkAttributeName value:[[NSURL URLWithString:[fullString substringWithRange:match.range]]absoluteString] range:foundRange];
                                [string addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:foundRange];
                                [string addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor]  range:foundRange];
                                
                                
                            }
                            
                        }
                    if(Emails){
                        NSRegularExpression *regex3 = [NSRegularExpression regularExpressionWithPattern:@"[\\.a-zA-Z0-9_-]*@[a-z0-9-_]+\\.\\w{2,4}" options:NSRegularExpressionCaseInsensitive error:&error];
                        //    NSUInteger numberOfMatches = [regex numberOfMatchesInString:fullString options:0 range:NSMakeRange(0, [_receivedData[@"site"] length])];
                        NSArray *matches3 = [regex3 matchesInString:fullString options:0 range:NSMakeRange(0, [fullString length])];
                        //        NSLog(@"%@", matches);
                        //        NSLog(@"Found %li",numberOfMatches);
                        if([matches3 lastObject])
                            for (NSTextCheckingResult *match in matches3){
                                //            NSRange matchRange = match.range;
                                
                                //        NSLog(@"match: %@", [fullString substringWithRange:range]);
                                
                                NSRange foundRange = [string.mutableString rangeOfString:[fullString substringWithRange:match.range]  options:NSCaseInsensitiveSearch];
                                if (foundRange.location != NSNotFound) {
                                    //                       NSLog(@"range found");
                                    [string addAttribute:NSLinkAttributeName value:[[NSURL URLWithString:[fullString substringWithRange:match.range]]absoluteString] range:foundRange];
                                    [string addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:foundRange];
                                    [string addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor]  range:foundRange];
                                    
                                    
                                }
                                
                            }
                    }
                    
                    //
                    NSRegularExpression *tagsRegex = [NSRegularExpression regularExpressionWithPattern:@"#[\\W0-9a-zа-яё][^\\s]+" options:NSRegularExpressionCaseInsensitive error:&error];
                    //    NSUInteger numberOfMatches = [regex numberOfMatchesInString:fullString options:0 range:NSMakeRange(0, [_receivedData[@"site"] length])];
                    NSArray *tagsRegexMatches = [tagsRegex matchesInString:fullString options:0 range:NSMakeRange(0, [fullString length])];
                    //        NSLog(@"%@", matches);
                    //        NSLog(@"Found %li",numberOfMatches);
                    for (NSTextCheckingResult *match in tagsRegexMatches){
                        //            NSRange matchRange = match.range;
                        
                        //        NSLog(@"match: %@", [fullString substringWithRange:range]);
                        
                        NSRange foundRange = [string.mutableString rangeOfString:[fullString substringWithRange:match.range]  options:NSCaseInsensitiveSearch];
                        if (foundRange.location != NSNotFound) {
                            //                       NSLog(@"range found");
                            //            [string addAttribute:NSLinkAttributeName value:[[NSURL URLWithString:[fullString substringWithRange:match.range]]absoluteString] range:foundRange];
                            //            [string addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:foundRange];
                            [string addAttribute:NSForegroundColorAttributeName value:[NSColor keyboardFocusIndicatorColor]  range:foundRange];
                            
                            
                        }
                        
                    }
                    
                    [string addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:fontSize weight:NSFontWeightRegular] range:NSMakeRange(0, [string length])];
                    if(string){
                        cachedStrings[fullString]=string;
                        dispatch_async(dispatch_get_main_queue(),^{
                            completion(string);
                        });
                    }
                }
                
            }
        });
    }
}
-(NSMutableAttributedString*)createLinkFromSubstring:(NSString*)fullString URL:(NSString *)URL subString:(NSString*)subString{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:fullString];
    
    NSRange foundRange = [string.mutableString rangeOfString:subString];
    if (foundRange.location != NSNotFound) {
        //                       NSLog(@"range found");
        [string addAttribute:NSLinkAttributeName value:[[NSURL URLWithString:URL]absoluteString] range:foundRange];
        [string addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:foundRange];
        [string addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor]  range:foundRange];
        
        
    }
    [string addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:11 weight:NSFontWeightRegular] range:NSMakeRange(0, [string length])];
    
    return string;
}
@end
