//
//  AddFriendViewController.m
//  Seek
//
//  Created by 吴非凡 on 15/10/26.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "AddFriendViewController.h"

@interface AddFriendViewController ()
@property (weak, nonatomic) IBOutlet UIButton *attensionBtn;

@end

@implementation AddFriendViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.translucent = NO;
    
    self.lblName.text = self.targetUserInfo.name;
    [self.ivAva sd_setImageWithURL:[NSURL URLWithString:self.targetUserInfo.portraitUri] placeholderImage:[UIImage imageNamed:@"placeholderUserIcon"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)actionAddFriend:(UIButton *)sender {
    SHOWMESSAGE(@"发送关注请求中");
    [RCDHTTPTOOL requestFriend:_targetUserInfo.userId complete:^(BOOL result) {
        if (result) {
            [self.attensionBtn setTitle:@"关注成功" forState:UIControlStateNormal];
            SHOWSUCCESS(@"关注请求已发送");
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
