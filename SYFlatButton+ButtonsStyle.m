//
//  SYFlatButton+ButtonsStyle.m
//  Pods
//
//  Created by sim on 09/07/17.
//
//

#import "SYFlatButton+ButtonsStyle.h"
#import <NSColor-HexString/NSColor+HexString.h>
@implementation SYFlatButton (ButtonsStyle)

-(id)simpleButton:(SYFlatButton*)button{
    button.state=0;
    button.momentary = YES;
    button.cornerRadius = 4.0;
    button.borderWidth=1;
    button.backgroundNormalColor = [NSColor colorWithHexString:@"ecf0f1"];
    button.backgroundHighlightColor = [NSColor colorWithHexString:@"bdc3c7"];
    button.titleHighlightColor = [NSColor colorWithHexString:@"2c3e50"];
    button.spacing=0;
    //button.titleNormalColor = [NSColor colorWithHexString:@"95a5a6"];
    button.titleNormalColor = [NSColor colorWithHexString:@"34495e"];
    button.borderHighlightColor = [NSColor colorWithHexString:@"7f8c8d"];
    button.borderNormalColor = [NSColor colorWithHexString:@"95a5a6"];
    
    return button;
}
-(id)simpleWithBlackStorkes:(SYFlatButton*)button{
    button.state=0;
    button.momentary = YES;
    button.cornerRadius = 4.0;
    button.borderWidth=1;
    button.titleHighlightColor = [NSColor colorWithHexString:@"8E8E8E"];
    button.spacing=0;
    
    //button.titleNormalColor = [NSColor colorWithHexString:@"95a5a6"];
    button.titleNormalColor = [NSColor colorWithHexString:@"3F3F3F"];
    button.borderHighlightColor = [NSColor colorWithHexString:@"8E8E8E"];
    button.borderNormalColor = [NSColor colorWithHexString:@"000000"];
    return button;
}
@end
