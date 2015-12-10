//
//  DynamicView.h
//  Seek
//
//  Created by apple on 15/11/30.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DynamicView : UIView
@property (nonatomic, retain) UITableView *tableView;

@property (nonatomic, retain) UIScrollView *scrollView;

- (instancetype)initWithFrame:(CGRect)frame
                      cateArr:(NSArray *)cateArr;
@end
