
//
//  LXSliderView.m
//  LXSlider
//
//  Created by chenergou on 2017/12/29.
//  Copyright © 2017年 漫漫. All rights reserved.
//

#import "LXSliderView.h"

@implementation LXSliderView

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    CGFloat height = rect.size.height;
    CGFloat width = rect.size.width;
    
//    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self FillPathWithRect:rect fillColor:[UIColor whiteColor]];
    
    [self FillPathWithRect:CGRectMake(width/3, width/3, width - 2 * width/3, height - 2 * height/3) fillColor:[UIColor greenColor]];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self setNeedsDisplay];
}
-(void)FillPathWithRect:(CGRect) rect fillColor:(UIColor *)fillColor{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    
    
    CGContextAddEllipseInRect(context, rect);
    
    CGContextFillPath(context);
    
    
}
@end
