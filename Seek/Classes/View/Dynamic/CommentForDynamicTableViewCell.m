//
//  CommentForDynamicTableViewCell.m
//  Seek
//
//  Created by 吴非凡 on 15/10/14.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "CommentForDynamicTableViewCell.h"
#import "Comment.h"
@interface CommentForDynamicTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
- (IBAction)commentButtonAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;


@end

@implementation CommentForDynamicTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//
- (void)setComment:(Comment *)comment
{
    _comment = nil;
    _comment = comment;
//    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:comment.fromUserHeadImage]];
    self.headImageView.image = [UIImage imageNamed:comment.fromUserHeadImage];
    self.userNameLabel.text = comment.fromUserName;
    self.timestampLabel.text = [NSString stringWithDate:comment.timestamp];
    self.contentLabel.text = comment.content;
    
    [self setNeedsUpdateConstraints];
    
    [self updateConstraintsIfNeeded];
}

- (IBAction)commentButtonAction:(UIButton *)sender {
    if (self.btnClickBlock) {
        self.btnClickBlock(self);
    }
}
@end
