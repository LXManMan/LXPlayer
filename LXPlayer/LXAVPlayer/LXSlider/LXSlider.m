//
//  LXSlider.m
//  LXSlider
//
//  Created by chenergou on 2017/12/16.
//  Copyright © 2017年 漫漫. All rights reserved.
//

#import "LXSlider.h"
#import "LXSliderView.h"
#import "UIView+LX_Frame.h"
#import "UIColor+Expanded.h"
#import "LXProgressView.h"
#define SLIDEW 25.0
@interface LXSlider()
@property(nonatomic,strong)LXSliderView *slideView;
@property(nonatomic,strong)UIView *containerView;
@property(nonatomic,strong)UIPanGestureRecognizer *panGesture;
@property(nonatomic,strong)LXProgressView *progressView;
@property(nonatomic,strong)UITapGestureRecognizer *tap;
@end

@implementation LXSlider
-(instancetype)initWithFrame:(CGRect)frame{
    self =[super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    return self;
}
-(void)setup{
    
    [self addSubview:self.progressView];
    [self addSubview:self.slideView];
    
    [self addGestureRecognizer:self.panGesture];
    
    [self addGestureRecognizer:self.tap];
    
}
-(void)setSlideValue:(CGFloat)slideValue{
    
    if (_slideValue != slideValue) {
        _slideValue = slideValue;
        
       
        self.slideView.lx_x = _slideValue *(self.lx_width - self.slideView.lx_width);
        
        self.progressView.playValue = _slideValue;
    }
  
    
}
-(void)setCacheValue:(CGFloat)cacheValue{
   
    if (_cacheValue != cacheValue) {
        _cacheValue = cacheValue;
        
        self.progressView.cacheValue = cacheValue;
    }
}
-(void)tapGesture:(UITapGestureRecognizer *)tap{
    
    CGPoint point = [tap locationInView:tap.view];
    
//    NSLog(@"%f",point.x);
    
    if (point.x <= SLIDEW/2) {
        point.x = SLIDEW/2;
    }
    
    if (point.x > self.lx_width - SLIDEW/2) {
        point.x = self.lx_width - SLIDEW/2;
    }
    
    
    self.slideView.lx_centerX = point.x;

  
    
    CGFloat value =  self.slideView.lx_left/(self.lx_width - self.slideView.lx_width);
    
    self.progressView.playValue = value;
    
    if (self.tapSlider) {
        self.tapSlider(value);
    }

}
-(void)panGesture:(UIPanGestureRecognizer *)pan{

    //移动的距离
    CGPoint point = [pan translationInView:pan.view];
    
//    NSLog(@"%f",point.x);

    self.slideView.lx_x +=  point.x;
 
    
    
    if (self.slideView.lx_right >= self.lx_width) {
        self.slideView.lx_right = self.lx_width;
    }
    
    if (self.slideView.lx_left <=0) {
        self.slideView.lx_left = 0;
    }
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        if (self.panBegin) {
            self.panBegin();
        }
    }
   
    
    CGFloat value =  self.slideView.lx_left/(self.lx_width - self.slideView.lx_width);
    
    self.progressView.playValue = value;
    
    if (self.getSlideValue) {
        self.getSlideValue(value);
        
    }
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        if (self.panEnd) {
            self.panEnd(value);
        }
    }
    
    
     [pan setTranslation:CGPointZero inView:pan.view];
    
}
-(void)layoutSubviews{
    [super layoutSubviews];
    _progressView.frame = CGRectMake(0, (self.lx_height -2)/2, self.lx_width , 2);
    _slideView.frame = CGRectMake(0, (CGRectGetHeight(self.frame) -SLIDEW)/2, SLIDEW, SLIDEW);
}
-(LXProgressView *)progressView{
    if (!_progressView) {
        _progressView =[[LXProgressView alloc]initWithFrame:CGRectMake(0, (self.lx_height -2)/2, self.lx_width , 2)];
    }
    return _progressView;
}
-(UIPanGestureRecognizer *)panGesture{
    if (!_panGesture) {
        _panGesture =[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGesture:)];
    }
    return _panGesture;
}
-(UITapGestureRecognizer *)tap{
    if (!_tap) {
        _tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
        _tap.numberOfTapsRequired = 1;
    }
    return _tap;
}
-(LXSliderView *)slideView{
    if (!_slideView) {
        _slideView =[[LXSliderView alloc]init];
        _slideView.frame = CGRectMake(0, (CGRectGetHeight(self.frame) -SLIDEW)/2, SLIDEW, SLIDEW);
        _slideView.backgroundColor =[UIColor clearColor];
        _slideView.layer.shadowOpacity = 0.8;
        _slideView.layer.shadowOffset = CGSizeMake(0, 3);
//        _slideView.layer.masksToBounds = YES;
        _slideView.layer.shadowColor = [UIColor hexStringToColor:@"F5F5F5"].CGColor;
    }
    return _slideView;
}

@end
