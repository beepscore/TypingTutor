//
//  BigLetterView.h
//  TypingTutor
//  Ref Hillegass Ch 19, 20
//  Created by Steve Baker on 11/5/09.
//  Copyright 2009 Beepscore LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BigLetterView : NSView {
#pragma mark Instance variables
    NSColor *bgColor;
    NSString *string;
    BOOL isHighlighted;
    NSShadow *myShadow;
    NSMutableDictionary *attributes;
}
#pragma mark Accessors
@property (readwrite, retain) NSColor *bgColor;
@property (readwrite, copy) NSString *string;
@property (readwrite) BOOL isHighlighted;
@property (nonatomic, retain) NSShadow *myShadow;
@property (nonatomic, retain) NSMutableDictionary *attributes;

- (void)prepareAttributes;
- (void)drawStringCenteredIn:(NSRect)rect;
- (IBAction)savePDF:(id)sender;

@end
