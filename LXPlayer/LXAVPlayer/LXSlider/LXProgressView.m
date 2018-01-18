//
//  LXProgressView.m
//  LXSlider
//
//  Created by chenergou on 2017/12/29.
//  Copyright © 2017年 漫漫. All rights reserved.
//

#import "LXProgressView.h"
#import "UIView+LX_Frame.h"
#import "UIColor+Expanded.h"
@interface LXProgressView()
@property(nonatomic,strong)UIView *cacheView;

@property(nonatomic,strong)UIView *playProgressView;
@end
@implementation LXProgressView
-(instancetype)initWithFrame:(CGRect)frame{
   self =  [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor =[UIColor hexStringToColor:@"A9A9A9"];
        
        [self addSubview:self.cacheView];
        
        [self addSubview:self.playProgressView];
    }
    return self;
}
-(void)setPlayValue:(CGFloat)playValue{
    _playValue = playValue;
    
   self.playProgressView.lx_width = playValue * self.lx_width;
   
}

-(void)setCacheValue:(CGFloat)cacheValue{
    _cacheValue = cacheValue;
    self.cacheView.lx_width = cacheValue * self.lx_width;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    
     self.playProgressView.lx_width = self.playValue * self.lx_width;
    
    self.cacheView.lx_width = self.cacheValue * self.lx_width;

}
-(UIView *)cacheView{
    if (!_cacheView) {
        _cacheView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, self.lx_height)];
        
        _cacheView.backgroundColor =[UIColor hexStringToColor:@"D3D3D3"];
    }
    return _cacheView;
}
-(UIView *)playProgressView{
  
        if (!_playProgressView) {
            _playProgressView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, self.lx_height)];
            
            _playProgressView.backgroundColor =[UIColor whiteColor];
        }
    return _playProgressView;
}
@end
