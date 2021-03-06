//
//  BigLetterView.h
//  TypingTutor
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
    NSEvent *mouseDownEvent;
}
#pragma mark Accessors
@property (readwrite, retain) NSColor *bgColor;
@property (readwrite, copy) NSString *string;
@property (readwrite) BOOL isHighlighted;
@property (nonatomic, retain) NSShadow *myShadow;
@property (nonatomic, copy) NSMutableDictionary *attributes;

- (void)prepareAttributes;
- (void)drawStringCenteredIn:(NSRect)rect;
- (IBAction)savePDF:(id)sender;

- (IBAction)cut:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;

@end
