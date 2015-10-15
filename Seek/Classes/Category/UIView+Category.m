//
//  UIView+Category.m
//  Seek
//
//  Created by 吴非凡 on 15/10/14.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "UIView+Category.h"

@implementation UIView (Category)

- (void)setBackgroundColorFromHexColor:(NSString *)backgroundColorFromHexColor
{
    self.backgroundColor = kHexColor(backgroundColorFromHexColor);
}

- (NSString *)backgroundColorFromHexColor
{
    return nil;
}





#pragma mark - 令指定view颤抖
- (void)shake
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.values = @[@(0), @(-M_PI / 15), @(0), @(M_PI / 15), @(0)];
    animation.duration = 0.2;
    animation.repeatCount = 2;
    animation.removedOnCompletion = YES;
    [self.layer addAnimation:animation forKey:@""];
}


- (void)addTransitionWithType:(NSString *)type subType:(NSString *)subType duration:(CGFloat)duration key:(NSString *)key
{
    CATransition *animation = [CATransition animation];
    animation.duration = duration;
    animation.type = type;
    animation.subtype = subType;
    animation.removedOnCompletion = YES;
    [self.layer addAnimation:animation forKey:key];
}

- (void)removeAnimationForKey:(NSString *)key
{
    [self.layer removeAnimationForKey:key];
}

@end
