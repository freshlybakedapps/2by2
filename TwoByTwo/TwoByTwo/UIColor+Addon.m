//
//  UIColor+Addon.m
//
//
//  Created by Joseph Lin on 9/9/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "UIColor+Addon.h"


@implementation UIColor (Addon)

+ (UIColor *)colorFromHexString:(NSString *)hexString
{
    hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    if(hexString.length == 3)
    {
        const char *temp = [hexString cStringUsingEncoding:NSASCIIStringEncoding];
        const unsigned short t[] = {temp[0], temp[0], temp[1], temp[1], temp[2], temp[2]};
        hexString = [NSString stringWithCharacters:t length:6];
    }
    
	UIColor *result = nil;
	unsigned int colorCode = 0;
	unsigned char redByte, greenByte, blueByte;
	
	if (nil != hexString)
	{
		NSScanner *scanner = [NSScanner scannerWithString:hexString];
		(void) [scanner scanHexInt:&colorCode];	// ignore error
	}
	redByte		= (unsigned char) (colorCode >> 16);
	greenByte	= (unsigned char) (colorCode >> 8);
	blueByte	= (unsigned char) (colorCode);	// masks off high bits
	
    result      = [UIColor
                   colorWithRed: (float)redByte	 / 0xff
                   green:        (float)greenByte / 0xff
                   blue:         (float)blueByte	 / 0xff
                   alpha:1.0];
    
	return result;
}

- (UIColor *)darkenColor
{
    CGFloat hue, saturation, brightness, alpha;
    [self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    brightness = brightness * 0.5;
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
    return color;
}

@end
