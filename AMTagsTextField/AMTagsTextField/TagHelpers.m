//
//  TagHelpers.m
//  AMTagsTextField
//
//  Created by Arturo Murillo on 6/19/14.
//  Copyright (c) 2014 Arturo Murillo. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.

#import "TagHelpers.h"

@implementation TagHelpers

+ (NSString *)hexStringForColor:(UIColor *)color
{
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    
    if ([color respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
    } else {
        const CGFloat *components = CGColorGetComponents([color CGColor]);
        red = components[0];
        green = components[1];
        blue = components[2];
        alpha = components[3];
    }
    
    NSString *hexString=[NSString stringWithFormat:@"%02X%02X%02X", (int)(red * 255), (int)(green * 255), (int)(blue * 255)];
    
    NSLog(@"hexString %@",hexString);
    
    return hexString;
}

+ (UIColor *)colorFromHex:(NSString *)hex
{
    unsigned int c;
    if ([hex characterAtIndex:0] == '#') {
        [[NSScanner scannerWithString:[hex substringFromIndex:1]] scanHexInt:&c];
    } else {
        [[NSScanner scannerWithString:hex] scanHexInt:&c];
    }
    return [UIColor colorWithRed:((c & 0xff0000) >> 16)/255.0
                           green:((c & 0xff00) >> 8)/255.0
                            blue:(c & 0xff)/255.0 alpha:1.0];
}

@end
