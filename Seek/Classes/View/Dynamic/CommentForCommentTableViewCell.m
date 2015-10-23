//
//  CommentForCommentTableViewCell.m
//  Seek
//
//  Created by 吴非凡 on 15/10/14.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "CommentForCommentTableViewCell.h"
#import "Comment.h"
@interface CommentForCommentTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation CommentForCommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setComment:(Comment *)comment
{
    
    
    
    _comment = nil;
    _comment = comment;
    
    
    NSString *strTipsMessage = [NSString stringWithFormat:@"%@回复%@:%@", comment.fromUserName, comment.toUserName, comment.content];
    NSRange fromUserRange = [strTipsMessage rangeOfString:comment.fromUserName];
    NSRange toUserRange = [strTipsMessage rangeOfString:comment.toUserName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:strTipsMessage];
    [attrString addAttribute:(NSString *)kCTForegroundColorAttributeName
                       value:(id)kNavBgColor.CGColor
                       range:fromUserRange];
    [attrString addAttribute:(NSString *)kCTForegroundColorAttributeName
                       value:(id)kNavBgColor.CGColor
                       range:toUserRange];
    self.infoLabel.attributedText = attrString;
    
    [self setNeedsUpdateConstraints];
    
    [self updateConstraintsIfNeeded];
}
@end
