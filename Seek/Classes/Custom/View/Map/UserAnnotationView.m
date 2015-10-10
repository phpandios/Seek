//
//  UserAnnotationView.m
//  Seek
//
//  Created by 吴非凡 on 15/10/10.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#define kLabelSize 16
#define kMargin (2)

#import "UserAnnotationView.h"

@interface UserAnnotationView ()

@property (nonatomic, strong) UILabel *countLabel;


@end

@implementation UserAnnotationView

- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        // 背景透明
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
#pragma mark - setter
- (void)setUserArray:(NSArray *)userArray
{
    if (_userArray != userArray) {
        _userArray = nil;
        _userArray = userArray;
        [self updateSubViews];
    }
}
#pragma mark - 私有方法
// 更新子视图
- (void)updateSubViews
{
    if ([_userArray count] <= 1) {
        [_countLabel setHidden:YES];
        return;
    }
    if (!_countLabel) {
        UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kLabelSize, kLabelSize)];
        countLabel.center = CGPointMake(kUserIconSize, 0);
        countLabel.font = [UIFont systemFontOfSize:10];
        countLabel.backgroundColor = [UIColor redColor];
        countLabel.textColor = [UIColor whiteColor];
        countLabel.textAlignment = NSTextAlignmentCenter;
        countLabel.layer.cornerRadius = kLabelSize / 2.0f;
        countLabel.layer.masksToBounds = YES;
        [self addSubview:countLabel];
        self.countLabel = countLabel;
    }
    _countLabel.text = [NSString stringWithFormat:@"%ld", _userArray.count];
}

@end
