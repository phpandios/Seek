//
//  AutoHeightTextView.h
//  testTextField
//
//  Created by 吴非凡 on 15/10/16.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <UIKit/UIKit.h>


/*
 改变内容 -- 从有内容删除到没有时,应该变为placeholder.待完善
 */
@interface AutoHeightTextView : UITextView

// 为0则忽略. 不设置默认为0
@property (nonatomic, assign) IBInspectable CGFloat minHeight;
// 为0则忽略. 不设置默认为0
@property (nonatomic, assign) IBInspectable CGFloat maxHeight;

@property (nonatomic, copy) IBInspectable NSString *placeholder;
@end
