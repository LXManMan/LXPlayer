//
//  LXPlayLoadingView.m
//  LXPlayLoadingView
//
//  Created by chenergou on 2017/12/4.
//  Copyright © 2017年 漫漫. All rights reserved.
//

#import "LXPlayLoadingView.h"

@interface LXPlayLoadingView()
@property(nonatomic,strong)CAShapeLayer *loadingLayer;

@property(nonatomic,strong)UIBezierPath *path;

/*动画持续时间*/
@property(nonatomic,assign)CGFloat animationDuration;

/*stroke颜色*/
@property(nonatomic,strong)UIColor *strokeColor;
@end
@implementation LXPlayLoadingView

-(instancetype)initWithFrame:(CGRect)frame animationDuration:(CGFloat)animationDuration strokeColor:(UIColor *)strokeColor{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        self.strokeColor = strokeColor;
        
        self.animationDuration = animationDuration;
        
        [self setUp];
        
        [self loadingAnimation];
        
        
    }
    return self;
}

-(void)setUp{
    
    
    [self.layer addSublayer:self.loadingLayer];
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    CGFloat radius = MIN(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2) - self.loadingLayer.lineWidth / 2;
    
    self.path =[UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:2 *M_PI clockwise:YES];
    
    self.loadingLayer.path =  self.path.CGPath;
    
    self.loadingLayer.strokeStart = 0.f;
    self.loadingLayer.strokeEnd = 0.f;
    
}

-(CAShapeLayer *)loadingLayer{
    if (!_loadingLayer) {
        
        _loadingLayer =[CAShapeLayer layer];
        
        _loadingLayer.fillColor = [UIColor clearColor].CGColor;
        
        _loadingLayer.strokeColor = self.strokeColor.CGColor ? self.strokeColor.CGColor:[UIColor redColor].CGColor;
        
        _loadingLayer.lineWidth  = 1;
        _loadingLayer.lineCap = kCALineCapRound;
        
    }
    return _loadingLayer;
}
- (void)loadingAnimation {
    CABasicAnimation *beginStart = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    beginStart.fromValue         = @0;
    beginStart.toValue           = @.25;
    beginStart.timingFunction    = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    beginStart.duration = self.animationDuration * 2 / 3.0;
    
    CABasicAnimation *beginEnd   = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    beginEnd.fromValue           = @0;
    beginEnd.toValue             = @1.;
    beginEnd.duration            = self.animationDuration * 2 / 3.0;
    
    
    //剩下的时间用来等待
    CABasicAnimation *endStart = [CABasicAnimation animation];
    endStart.keyPath = @"strokeStart";
    endStart.beginTime = self.animationDuration * 2 / 3.0;
    endStart.duration = self.animationDuration / 3.0;
    endStart.fromValue = @(0.25f);
    endStart.toValue = @(1.f);
    endStart.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *endend = [CABasicAnimation animation];
    endend.keyPath = @"strokeEnd";
    endend.beginTime = self.animationDuration * 2 / 3.0;
    endend.duration =  self.animationDuration / 3.0;
    endend.fromValue = @(1.f);
    endend.toValue = @(1.f);
    endend.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    
    CAAnimationGroup *strokeAniamtionGroup   = [CAAnimationGroup animation];
    strokeAniamtionGroup.duration            = self.animationDuration;
    strokeAniamtionGroup.animations          = @[beginStart,beginEnd,endStart,endend];
    
    strokeAniamtionGroup.removedOnCompletion = NO;
    strokeAniamtionGroup.fillMode            = kCAFillModeForwards;
    strokeAniamtionGroup.repeatCount = INTMAX_MAX;
    [self.loadingLayer addAnimation:strokeAniamtionGroup forKey:@"strokeAniamtionGroup"];
}




@end
