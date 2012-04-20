//
//  CGStringDrawing.h
//  KidsPlayer
//
//  Created by Max Seelemann on 19.01.11.
//  Copyright 2011 Blue Technologies Group. All rights reserved.
//

@interface NSString (CGStringDrawing)

- (void)drawInContext:(CGContextRef)context inRect:(CGRect)rect withFont:(UIFont *)font textColor:(UIColor *)color lineBreakMode:(UILineBreakMode)lineBreakMode alignment:(UITextAlignment)alignment centerVertically:(BOOL)center;

@end
