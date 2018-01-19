//
//  LXAVPlayer.h
//  LXPlayer
//
//  Created by chenergou on 2017/12/4.
//  Copyright © 2017年 漫漫. All rights reserved.
//

#ifndef LXAVPlayer_h
#define LXAVPlayer_h
typedef void (^GetSlideValue) (CGFloat value);

typedef void (^Panbegin) ();

typedef void (^PanEnd) (CGFloat value);

typedef void (^TapSlider) (CGFloat value);

typedef void (^BackBlock)();

#import "LXAVPlayView.h"
#import "LXAVPlayControllView.h"
#import "LXPlayModel.h"
#import "LXSlider.h"
#import "LXPlayLoadingView.h"
#import "UIImage+LXAVPlayer.h"
#import "UIViewController+LXPlayerRotation.h"
#import "UIWindow+LXCurrentViewController.h"
#import "UINavigationController+LXPlayerRotation.h"
#import "UITabBarController+LXPlayerRotation.h"
#endif /* LXAVPlayer_h */
