//
//  AddFriendViewController.m
//  Seek
//
//  Created by 吴非凡 on 15/10/26.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "AddFriendViewController.h"

@interface AddFriendViewController ()

@end

@implementation AddFriendViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.lblName.text = self.targetUserInfo.name;
    [self.ivAva sd_setImageWithURL:[NSURL URLWithString:self.targetUserInfo.portraitUri] placeholderImage:[UIImage imageNamed:@"placeholderUserIcon"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)actionAddFriend:(id)sender {
    SHOWMESSAGE(@"发送好友请求中");
    [RCDHTTPTOOL requestFriend:_targetUserInfo.userId complete:^(BOOL result) {
        if (result) {
            SHOWSUCCESS(@"好友请求已发送");
        }
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
