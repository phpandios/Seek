//
//  CommentForDynamicTableViewCell.h
//  Seek
//
//  Created by 吴非凡 on 15/10/14.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Comment;
// 评论动态的cell
@interface CommentForDynamicTableViewCell : UITableViewCell

@property (nonatomic, strong) Comment *comment;
@property (weak, nonatomic) IBOutlet UIView *mainView;

@property (nonatomic, copy) void (^btnClickBlock)(UITableViewCell *cell);
@end
