//
//  CGStringDrawing.m
//  KidsPlayer
//
//  Created by Max Seelemann on 19.01.11.
//  Copyright 2011 Blue Technologies Group. All rights reserved.
//

#import "CGStringDrawing.h"

#import <CoreText/CoreText.h>


@implementation NSString (CGStringDrawing)

- (void)drawInContext:(CGContextRef)context inRect:(CGRect)rect withFont:(UIFont *)font textColor:(UIColor *)color lineBreakMode:(UILineBreakMode)lineBreakMode alignment:(UITextAlignment)alignment centerVertically:(BOOL)center
{
	// Get properties
	CTTextAlignment textAlign = ((alignment == UITextAlignmentLeft) ? kCTLeftTextAlignment
								 : (alignment == UITextAlignmentCenter) ? kCTCenterTextAlignment
								 : kCTRightTextAlignment);
	CGFloat heightMultiple = 0.6;
	
	CTParagraphStyleSetting pSettings[] = {
		{kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakMode},
		{kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &textAlign},
		{kCTParagraphStyleSpecifierLineHeightMultiple, sizeof(CGFloat), &heightMultiple}};
	CTParagraphStyleRef pStyle = CTParagraphStyleCreate(pSettings, 3);
	
	CTFontRef ctFont = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
	
	// Build string
	CFIndex length = [self length];
	CFMutableAttributedStringRef string = CFAttributedStringCreateMutable(NULL, 0);
	
	CFAttributedStringReplaceString(string, CFRangeMake(0, 0), (CFStringRef)self);
	CFAttributedStringSetAttribute(string, CFRangeMake(0, length), kCTFontAttributeName, ctFont);
	CFAttributedStringSetAttribute(string, CFRangeMake(0, length), kCTParagraphStyleAttributeName, pStyle);
	CFAttributedStringSetAttribute(string, CFRangeMake(0, length), kCTForegroundColorAttributeName, color.CGColor);
	
	CFRelease(ctFont);
	CFRelease(pStyle);
	
	// Frame
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddRect(path, NULL, rect);
	
	// Typeset
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(string);
	CFRelease(string);
	
	CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, length), path, NULL);
	CFRelease(framesetter);
	CFRelease(path);
	
	// Debug frame
/*	CGContextAddPath(context, path);
	CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
	CGContextStrokePath(context);*/
	
	// Adjust context (flip in y middle)
	CGContextSaveGState(context);
	CGContextSetTextPosition(context, 0, 0);
	
	CGContextTranslateCTM(context, 0, 2 * CGRectGetMidY(rect));
	CGContextScaleCTM(context, 1, -1);
	
	// V center
	if (center) {
		CFArrayRef lines = CTFrameGetLines(frame);
		CFIndex lineCount = CFArrayGetCount(lines);
		
		if (lineCount > 0) {
			CGPoint lastLineOrigin, firstLineOrigin;
			
			CTFrameGetLineOrigins(frame, CFRangeMake(0, 1), &firstLineOrigin);
			CTFrameGetLineOrigins(frame, CFRangeMake(lineCount-1, 1), &lastLineOrigin);
			
			CGRect firstLineRect = CTLineGetImageBounds(CFArrayGetValueAtIndex(lines, 0), context);
			CGRect lastLineRect = CTLineGetImageBounds(CFArrayGetValueAtIndex(lines, lineCount-1), context);
			
			CGContextTranslateCTM(context, 
								  0,
								  ((CGRectGetHeight(rect) - firstLineOrigin.y - CGRectGetMaxY(firstLineRect))
								   - (lastLineOrigin.y + CGRectGetMinY(lastLineRect))
								   ) / 2);
		}
	}
	
	
	// Draw
	CTFrameDraw(frame, context);
	CFRelease(frame);
	
	// Clean up
	CGContextRestoreGState(context);
}

@end
