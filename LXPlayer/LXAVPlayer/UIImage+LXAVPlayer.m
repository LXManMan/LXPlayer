//
//  UIImage+LXAVPlayer.m
//  LXPlayer
//
//  Created by chenergou on 2018/1/19.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "UIImage+LXAVPlayer.h"

@implementation UIImage (LXAVPlayer)
+(UIImage *)LXPlayer_ImageName:(NSString *)imageName{
    
    NSString *bundlePath =  [[NSBundle mainBundle] pathForResource:@"LXAVPlayer" ofType:@"bundle"];
    
    NSString *path   = [bundlePath stringByAppendingString:[NSString stringWithFormat:@"/%@",imageName]];
    return [UIImage imageWithContentsOfFile:path];
}
@end
