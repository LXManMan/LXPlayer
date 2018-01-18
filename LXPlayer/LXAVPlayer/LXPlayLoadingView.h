//
//  LXPlayLoadingView.h
//  LXPlayLoadingView
//
//  Created by chenergou on 2017/12/4.
//  Copyright © 2017年 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXPlayLoadingView : UIView

/*
 *
 * animationDuration 动画持续时长
 *
 * strokeColor       绘制颜色
 */
-(instancetype)initWithFrame:(CGRect)frame animationDuration:(CGFloat)animationDuration strokeColor:(UIColor *)strokeColor;
@end
