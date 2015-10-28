//
//  RCDFriendInvitationTableViewCell.m
//  RCloudMessage
//
//  Created by litao on 15/7/30.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "FriendInvitationTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "RCDHttpTool.h"
#import "AFHttpTool.h"
#import "RCDataBaseManager.h"
#import "MBProgressHUD.h"

@interface FriendInvitationTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *portrait;
@property (weak, nonatomic) IBOutlet UIView *additionInfo;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *message;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;


@end

@implementation FriendInvitationTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (IBAction)onAgree:(id)sender {
    
    __weak __typeof(self)weakSelf = self;
    
    RCContactNotificationMessage *_contactNotificationMsg = (RCContactNotificationMessage *)weakSelf.model.content;
    if (_contactNotificationMsg.sourceUserId == nil || _contactNotificationMsg.sourceUserId .length ==0) {
        return;
    }
    SHOWMESSAGE(@"添加中");
    [AFHttpTool processRequestFriend:_contactNotificationMsg.sourceUserId withIsAccess:YES success:^(id response) {
        if ([response[@"code"] intValue] == 200) {
            SHOWSUCCESS(@"添加成功");
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.acceptButton setEnabled:NO];
            });
        } else {
            SHOWERROR(@"%@", response[@"message"]);
        }
        
    } failure:^(NSError *err) {
        SHOWERROR(@"网络故障,请检查后重试!");
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.acceptButton setEnabled:YES];
        });
    }];
}

- (void)setModel:(RCMessage *)model {
    _model = model;
    if (![model.content isMemberOfClass:[RCContactNotificationMessage class]])
    {
        return;
    }
    RCContactNotificationMessage *_contactNotificationMsg = (RCContactNotificationMessage *)model.content;
    self.message.text = _contactNotificationMsg.message;
    if (_contactNotificationMsg.sourceUserId == nil || _contactNotificationMsg.sourceUserId.length == 0) {
        return;
    }
    NSDictionary *_cache_userinfo = [[NSUserDefaults standardUserDefaults]objectForKey:_contactNotificationMsg.sourceUserId];
    if (_cache_userinfo) {
        self.userName.text = _cache_userinfo[@"username"];
        [self.portrait sd_setImageWithURL:[NSURL URLWithString:_cache_userinfo[@"portraitUri"]] placeholderImage:[UIImage imageNamed:@"placeholderUserIcon"]];
    } else {
        self.userName.text = [NSString stringWithFormat:@"user<%@>", _contactNotificationMsg.sourceUserId];
        [self.portrait setImage:[UIImage imageNamed:@"placeholderUserIcon"]];
    }
    
    //    __weak RCDFriendInvitationTableViewCell *weakSelf = self;
    //    RCDUserInfo *_userInfo = [[RCDUserInfo alloc] initWithUserId:_contactNotificationMsg.sourceUserId name:@"" portrait:@""];
    //    [RCDHTTPTOOL isMyFriendWithUserInfo:_userInfo completion:^(BOOL isFriend) {
    ////        dispatch_async(dispatch_get_main_queue(), ^{
    //            if (weakSelf.model.messageId != model.messageId) {
    //                return ;
    //            }
    //            if (isFriend) {
    //                [weakSelf.acceptButton setEnabled:NO];
    //            } else {
    //                [weakSelf.acceptButton setEnabled:NO];
    //            }
    ////        });
    //    }];
}
@end
