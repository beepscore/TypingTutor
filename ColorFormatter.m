//
//  ColorFormatter.m
//  TypingTutor
//
//  Created by Steve Baker on 11/8/09.
//  Copyright 2009 Beepscore LLC. All rights reserved.
//

#import "ColorFormatter.h"
#import "BSGlobalValues.h"

#pragma mark Private methods
// Ref Hillegass Ch 22 pg 297
@interface ColorFormatter () 
- (NSString *)firstColorKeyForPartialString:(NSString *)string;
@end

@implementation ColorFormatter
#pragma mark Initializers
- (id)init {
    self = [super init];
    if (self) {
        colorList = [[NSColorList colorListNamed:@"Apple"] retain];
    }
    return self;
}

- (void)dealloc {
    [colorList release];
    [super dealloc];
}

#pragma mark -
- (NSString *)firstColorKeyForPartialString:(NSString *)string {
    
    // Is the key zero-length?
    if (0 == [string length]) {
        return nil;
    }
    
    // Loop through the color list
    for (NSString *key in [colorList allKeys]) {
        
        NSRange whereFound = [key rangeOfString:string
                                        options:NSCaseInsensitiveSearch];
        // Does the string match the beginning of the color name?
        if ((0 == whereFound.location) && (whereFound.length > 0)) {
            return key;
        }
    }
    // If no match is found, return nil
    return nil;
}

- (NSString *)stringForObjectValue:(id)obj {
    
    // Not a color?
    if (![obj isKindOfClass:[NSColor class]]) {
        return nil;
    }
    
    // Convert to an RGB Color Space
    NSColor *color;
    color = [obj colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    
    // Get components as floats between 0 and 1
    CGFloat red, green, blue;
    [color getRed:&red
            green:&green
             blue:&blue
            alpha:NULL];
    
    // Initialize the distance to something large
    float minDistanceSquared = 3.0;
    NSString *closestKey = nil;
    
    // Find the closest color
    for (NSString *key in [colorList allKeys]) {
        NSColor *c = [colorList colorWithKey:key];
        CGFloat r, g, b;
        [c getRed:&r
            green:&g
             blue:&b
            alpha:NULL];
        
        // How far apart are 'color' and 'c'?
        float distanceSquared;
        distanceSquared = pow(red - r, 2) + pow(green - g, 2) + pow(blue - b, 2);
        
        // Is this the closest yet?
        if (distanceSquared < minDistanceSquared) {
            minDistanceSquared = distanceSquared;
            closestKey = key;
        }
    }
    // Return the name of the closest color
    return closestKey;
}

- (BOOL) getObjectValue:(id *)obj
              forString:(NSString *)string
       errorDescription:(NSString **)errorString {
    
    // Look up the color for 'string'
    NSString *matchingKey = [self firstColorKeyForPartialString:string];
    if (matchingKey) {
        *obj = [colorList colorWithKey:matchingKey];
        return YES;
    } else {
        // Occasionally, 'errorString is NULL
        if (errorString != NULL) {
            *errorString = [NSString stringWithFormat:
                            @"'%@' is not a color", string];
        }
        return NO;
    }
}

- (BOOL)isPartialStringValid:(NSString *)partialString
            newEditingString:(NSString **)newString
            errorDescription:(NSString **)error {
    
    // Zero length strings are OK
    if (0 == [partialString length]) {
        return YES;
    }
    NSString *match = [self firstColorKeyForPartialString:partialString];
    if (match) {
        return YES;
    } else {
        if (error) {
            *error = @"No such color";
            DLog(@"%@", *error);
        }
        return NO;
    }
}
@end
