//
//  PhotoCutViewController.m
//  Seek
//
//  Created by apple on 15/11/7.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "PhotoCutViewController.h"
#import "AGSimpleImageEditorView.h"

@interface PhotoCutViewController ()
{
    AGSimpleImageEditorView *editorView;
}


@end

@implementation PhotoCutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"图片剪裁";
    
    //保存按钮
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(completeSuccess:)];
    self.navigationItem.rightBarButtonItem = doneItem;
    self.navigationController.navigationBar.translucent = NO;
    
    //image为上一个界面传过来的图片资源
    editorView = [[AGSimpleImageEditorView alloc] initWithImage:self.image];
    editorView.frame = CGRectMake(0, 0, kScreenWidth,self.view.frame.size.width);
    
    //外边框的宽度及颜色
    editorView.borderWidth = 1.f;
    editorView.borderColor = [UIColor blackColor];
    
    //截取框的宽度及颜色
    editorView.ratioViewBorderWidth = 5.f;
    editorView.ratioViewBorderColor = [UIColor orangeColor];
    
    //截取比例，我这里按正方形1:1截取（可以写成 3./2. 16./9. 4./3.）
    editorView.ratio = 1;
    
    [self.view addSubview:editorView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)completeSuccess:(id)sender{
    //output为截取后的图片，UIImage类型
    UIImage *resultImage = editorView.output;
    
    //通过代理回传给上一个界面显示
    [self.delegate passImage:resultImage];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
