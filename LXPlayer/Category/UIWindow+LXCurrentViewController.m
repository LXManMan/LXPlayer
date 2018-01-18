//
//  UIWindow+LXCurrentViewController.m
//  LXPlayer
//
//  Created by chenergou on 2018/1/3.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "UIWindow+LXCurrentViewController.h"

@implementation UIWindow (LXCurrentViewController)
+ (UIViewController*)lx_currentViewController; {
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UIViewController *topViewController = [window rootViewController];
    while (true) {
        if (topViewController.presentedViewController) {
            topViewController = topViewController.presentedViewController;
        } else if ([topViewController isKindOfClass:[UINavigationController class]] && [(UINavigationController*)topViewController topViewController]) {
            topViewController = [(UINavigationController *)topViewController topViewController];
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
        } else {
            break;
        }
    }
    return topViewController;
}
@end
