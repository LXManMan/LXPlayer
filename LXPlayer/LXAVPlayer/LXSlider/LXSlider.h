//
//  LXSlider.h
//  LXSlider
//
//  Created by chenergou on 2017/12/16.
//  Copyright © 2017年 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LXSlider : UIView



@property(nonatomic,assign)CGFloat slideValue;

@property(nonatomic,assign)CGFloat cacheValue;

@property(nonatomic,copy)Panbegin panBegin;
@property(nonatomic,copy)PanEnd panEnd;

@property(nonatomic,copy)GetSlideValue getSlideValue;

@property(nonatomic,copy)TapSlider tapSlider;

@end
