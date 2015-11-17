//
//  Suggestions ViewController.m
//  Seek
//
//  Created by 吴非凡 on 15/11/17.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "SuggestionsViewController.h"

#define kKeywordLimitNumber 500

@interface SuggestionsViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *limitLabel;
@property (weak, nonatomic) IBOutlet UIButton *commitButton;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;

@end

@implementation SuggestionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view bringSubviewToFront:self.limitLabel];
    self.navigationController.navigationBarHidden = YES;
    
   
}
- (IBAction)dismissButtonAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)commitButtonAction:(UIButton *)sender {
    [KVNProgress show];
    __weak typeof(self) weakSelf = self;
    [AFHttpTool SuggestionsWithContent:self.contentTextView.text success:^(id response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress showSuccessWithStatus:@"提交成功,感谢您的建议!" completion:^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
            
        });
    } failure:^(NSError *err) {
       dispatch_async(dispatch_get_main_queue(), ^{
           [KVNProgress showErrorWithStatus:@"网络故障,请重试!"];
       });
    }];
    
    
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([textView.text length] >= kKeywordLimitNumber && [text length] > 0) {
        return NO;
    }

    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.commitButton.enabled = [textView.text length];
    self.limitLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)[textView.text length], (long)kKeywordLimitNumber];
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
