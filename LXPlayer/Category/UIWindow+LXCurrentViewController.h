//
//  UIWindow+LXCurrentViewController.h
//  LXPlayer
//
//  Created by chenergou on 2018/1/3.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (LXCurrentViewController)
/*!
 @method currentViewController
 
 @return Returns the topViewController in stack of topMostController.
 */
+ (UIViewController*)lx_currentViewController;
@end
