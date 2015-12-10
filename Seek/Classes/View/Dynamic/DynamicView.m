//
//  DynamicView.m
//  Seek
//
//  Created by apple on 15/11/30.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "DynamicView.h"
#import "Dynamic_category.h"

@implementation DynamicView
/**
 *  初始化方法
 */
- (instancetype)initWithFrame:(CGRect)frame
                      cateArr:(NSArray *)cateArr
{
    if (self = [super initWithFrame:frame]) {
        [self addTableViewCateArr:cateArr];
    }
    return self;
}

//添加tableView
- (void)addTableViewCateArr:(NSArray *)cateArr
{
    CGFloat width = 100;
    CGFloat height = 45;
    CGFloat navH = 64;
    self.scrollView =[[UIScrollView alloc] initWithFrame:CGRectMake(0, navH, kScreenWidth, height)];
    
    _scrollView.contentSize = CGSizeMake(width * [cateArr count], height);
    // 隐藏水平滚动条
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    
    for (int i=0; i < [cateArr count]; i++) {
        Dynamic_category *cateObj = cateArr[i];
        UIButton *catogry_btn =[UIButton buttonWithType:UIButtonTypeSystem];
        catogry_btn.frame = CGRectMake(i * 100, 0, 100, 45);
        [catogry_btn setTitle:cateObj.category_name forState:UIControlStateNormal];
        [catogry_btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        catogry_btn.tag = cateObj.ID;
        [_scrollView addSubview:catogry_btn];
    }
    
    //添加tableView表格
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, height + navH, kScreenWidth, kScreenHeight - height - navH - 49) style:UITableViewStyleGrouped];
    [self addSubview:_scrollView];
    [self addSubview:_tableView];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
