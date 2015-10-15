//
//  UIView+Category.h
//  Seek
//
//  Created by 吴非凡 on 15/10/14.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Category)

@property (nonatomic, copy) NSString *backgroundColorFromHexColor;


#pragma mark - Animation
#pragma mark - 颤抖
- (void)shake;
- (void)addTransitionWithType:(NSString *)type subType:(NSString *)subType duration:(CGFloat)duration key:(NSString *)key;

- (void)removeAnimationForKey:(NSString *)key;
@end
