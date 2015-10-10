//
//  WFFDropdownList.h
//  Custom
//
//  Created by 吴非凡 on 15/9/2.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WFFDropdownList;

@protocol WFFDropdownListDelegate <NSObject>

@optional
#pragma mark - 展开下拉列表后，点击某项的代理方法
- (void)dropdownList:(WFFDropdownList *)dropdownList didSelectedIndex:(NSInteger)selectedIndex;

@end

@interface WFFDropdownList : UIView

/**
 *  设置或获取当前选中项
 */
@property (nonatomic, assign) NSInteger selectedIndex;

/**
 *  设置下拉列表最多可显示几项
 */
@property (nonatomic, assign) NSInteger maxCountForShow;

/**
 *  代理
 */
@property (nonatomic, assign) id <WFFDropdownListDelegate> delegate;

/**
 *  初始化方法
 *
 *  @param frame frame
 *  @param array 下拉列表数组
 *
 *  @return 下拉列表对象
 */
- (instancetype)initWithFrame:(CGRect)frame dataSource:(NSArray *)array;

@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, strong) UIFont *font;

@end
