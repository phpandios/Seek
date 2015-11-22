//
//  DynamicDetailViewController.m
//  Seek
//
//  Created by 吴非凡 on 15/10/14.
//  Copyright © 2015年 吴非凡. All rights reserved.
//
#define kdynamicDetail @"dynamicDetail"

#import "DynamicDetailViewController.h"
#import "Dynamic.h"
#import "Comment.h"
#import "CommentForCommentTableViewCell.h"
#import "CommentForDynamicTableViewCell.h"
#import "DetailHeaderView.h"
#import "NSString+textHeightAndWidth.h"
@interface DynamicDetailViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
- (IBAction)commentButtonAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constaintForBottom;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *commentArray;

// 选中的回复
@property (nonatomic, strong) Comment *selectedComment;


@end


#warning 第一个cell要放当前动态内容.当点击当前动态时,selectedComment要设置为nil. 因为最终点击回复,是根据selectedComment是否为空.来决定当前回复的是动态还是某条回复
@implementation DynamicDetailViewController

static NSString *cellIdentifierForComment = @"CommentForCommentTableViewCell";
static NSString *cellIdentifierForDynamic = @"CommentForDynamicTableViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
#warning self.commentTextField占位   例如:回复***  初始时,回复当前动态的用户
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
    DetailHeaderView *headerView = [[NSBundle mainBundle] loadNibNamed:@"DetailHeaderView" owner:nil options:nil].firstObject;
    //计算文字高度
    CGFloat height = [NSString calcWithTextHeightStr:self.dnamicObj.content width:kScreenWidth font:[UIFont systemFontOfSize:18.0]];
    headerView.frame = CGRectMake(0, 0, kScreenWidth, 70 + height);

    [headerView.head_portrait sd_setImageWithURL:[NSURL URLWithString:self.dnamicObj.head_portrait] placeholderImage:nil];
    headerView.head_portrait.contentMode = UIViewContentModeScaleAspectFit;
    headerView.name.text = self.dnamicObj.nick_name;
    headerView.insert_time.text = self.dnamicObj.timestamp;
    headerView.publish_content.text =self.dnamicObj.content;
    self.tableView.tableHeaderView = headerView;
    
    self.tableView.userInteractionEnabled = YES;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CommentForCommentTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifierForComment];
    [self.tableView registerNib:[UINib nibWithNibName:@"CommentForDynamicTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifierForDynamic];
    // Do any additional setup after loading the view from its nib.
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

#pragma mark - 键盘
- (void)keyboardDidChangeFrame:(NSNotification *)sender {
    CGRect endRect = [sender.userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    self.constaintForBottom.constant = kScreenHeight - endRect.origin.y;
}

#pragma mark - 加载数据
- (void)loadData
{
    NSMutableArray *commentArray = [NSMutableArray array];
//    for (int i = 0; i < 10; i++) {
//        Comment *comment = [Comment new];
//        comment.respondType = 1;
//        comment.fromUserHeadImage = @"userIcon";
//        comment.fromUserName = [NSString stringWithFormat:@"用户%02d", i];
//        comment.content = [NSString stringWithFormat:@"不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么%2d", i];
////        comment.timestamp = [NSDate date];
//        NSMutableArray *childCommentArray = [NSMutableArray array];
//        for (int j = 0; j < i; j++) {
//            Comment *childComment = [Comment new];
//            childComment.respondType = 2;
//            childComment.fromUserName = [NSString stringWithFormat:@"**%02d", j];
//            childComment.toUserName = [NSString stringWithFormat:@"用户%02d", i];
//            childComment.content = [NSString stringWithFormat:@"不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么%2d", i];
////            comment.timestamp = [NSDate date];
//            [childCommentArray addObject:childComment];
//        }
//        
//        comment.childComments = childCommentArray;
//        [commentArray addObject:comment];
//    }
//    self.commentArray = commentArray;
//    [self.tableView reloadData];
    __weak typeof(self) weakSelf = self;
    [AFHttpTool getReplyWithUser_id:self.dnamicObj.userId Success:^(id response) {
        NSLog(@"%@", response);
        if ([response[@"result"] count] == 0) {
            return;
        }
        for (int i=0; i < [response[@"result"] count]; i++) {
            Comment *comment = [Comment new];
            NSLog(@"%@", response[@"result"][i]);
            [comment setValuesForKeysWithDictionary:response[@"result"][i]];
            [commentArray addObject:comment];
        }

        //判断本地缓存存在进行移除
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kdynamicDetail]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kdynamicDetail];
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:commentArray] forKey:kdynamicDetail];
        weakSelf.commentArray = commentArray;
        [weakSelf.tableView reloadData];
    } failure:^(NSError *err) {
        NSLog(@"%@", err);
    }];
    
    
    
}

#pragma mark - 根据当前点击行获取对应的Comment
- (Comment *)commentByIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"---------------%ld---------------", indexPath.row);
    Comment *result = nil;
    NSInteger index = 0;
    for (Comment *model in self.commentArray) {
        if (indexPath.row == index) {
            result = model;
            break;
        }
        index++;
        
        if (result) {
            break;
        }
        for (NSDictionary *subModel in model.childComments) {
            Comment *subModelNew =[Comment new];
            [subModelNew setValuesForKeysWithDictionary:subModel];
            if (indexPath.row == index) {
                result = subModelNew;
                break;
            } else {
                index++;
            }
        }
        if (result) {
            break;
        }
    }
//    if (result.respondType == RespondTypeByDynamic) {
//        printf("动态\n");
//    } else {
//        printf("回复\n");
//    }
    return result;
}


#pragma mark - 获取评论总数(包含子评论)
- (NSInteger)countOfAllComments
{
    NSInteger result = 0;
    for (Comment *model in self.commentArray) {
        result += 1;
        if ([model.childComments count] > 0) { // 大于0,有子评论
            result += [model.childComments count];
        }
    }
//    NSLog(@"%ld", result);
    return result;
}


#pragma mark - UITableViewDelegate && UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self countOfAllComments];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    Comment *comment = [self commentByIndexPath:indexPath];
    if (comment.respondType == 2) { // 评论的回复
        cell = (CommentForCommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifierForComment forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    } else if (comment.respondType == 1) { // 动态的回复
        cell = (CommentForDynamicTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifierForDynamic forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell performSelector:@selector(setComment:) withObject:comment];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Comment *comment = [self commentByIndexPath:indexPath];
    self.selectedComment = comment;
#warning 根据模型改变当前选中的回复,同时更新清空self.commentTextField的值,重置其占位文字 
}

#pragma mark - 动态计算cell高度 -- 费时操作.
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IOS8_OR_ABOVE) {
        
        return UITableViewAutomaticDimension;
    } else {
#warning IOS8以下自适应高度未解决,(app版本8.0+,暂不考虑)
        UITableViewCell *cell = nil;
        Comment *comment = [self commentByIndexPath:indexPath];
        if (comment.respondType == 2) { // 评论的回复
            cell = (CommentForCommentTableViewCell *)([[NSBundle mainBundle] loadNibNamed:@"CommentForCommentTableViewCell" owner:nil options:nil].firstObject);
    
        } else if (comment.respondType == 1) {
             cell = (CommentForDynamicTableViewCell *)([[NSBundle mainBundle] loadNibNamed:@"CommentForDynamicTableViewCell" owner:nil options:nil].firstObject);
        }
        [cell performSelector:@selector(setComment:) withObject:comment];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
        CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        return height + 1;//由于分割线，所以contentView的高度要小于row 一个像素。
    }
//    UITableViewCell *cell = nil;
//
//    Comment *comment = [self commentByIndexPath:indexPath];
//    CGFloat height;
//    if (comment.respondType == RespondTypeByComment) { // 评论的回复
//        cell = (CommentForCommentTableViewCell *)([[NSBundle mainBundle] loadNibNamed:@"CommentForCommentTableViewCell" owner:nil options:nil].firstObject);
//        [cell performSelector:@selector(setComment:) withObject:comment];
//        height = [((CommentForCommentTableViewCell *)cell).mainView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 16;
//
//    } else if (comment.respondType == RespondTypeByDynamic) { // 动态的回复
//        cell = (CommentForDynamicTableViewCell *)([[NSBundle mainBundle] loadNibNamed:@"CommentForDynamicTableViewCell" owner:nil options:nil].firstObject);
//        ((CommentForDynamicTableViewCell *)cell).btnClickBlock = ^(UITableViewCell *cell) {
//            NSIndexPath *indexPath = [tableView indexPathForCell:cell];
//            
//            Comment *comment = [self commentByIndexPath:indexPath];
//            
//            SHOWMESSAGE(@"给- %@ -评论", comment.fromUserName);
//        };
//        [cell performSelector:@selector(setComment:) withObject:comment];
//        height = [((CommentForDynamicTableViewCell *)cell).mainView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 16;
//
//    }
//    //    SHOWMESSAGE(@"%.2f", height);
//    return height;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#warning 不走
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.commentTextField resignFirstResponder];
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)commentButtonAction:(UIButton *)sender {
#warning 根据selectedComment是否为空,判断是选中了回复还是选中了动态.   
    /*
     selectedComment为空,说明回复的是动态,
     不为空,说明回复的是某条回复,
     据此来构造回复对象,并提交
     */
    __weak typeof(self) weakSelf = self;
    if(_selectedComment)
    {
        
        [AFHttpTool replyCommentWithReplyid:_selectedComment.reply_id content:self.commentTextField.text toUserId:[_selectedComment.fromUserId integerValue] success:^(id response) {
            NSLog(@"%@", response);
            [weakSelf loadData];
            [weakSelf.tableView reloadData];
        } failure:^(NSError *err) {
            NSLog(@"%@", err);
        }];
    }
    else
    {
        [AFHttpTool commentsDynamicWithDynamicId:self.dnamicObj.dynamicId content:self.commentTextField.text toUserId:self.dnamicObj.userId success:^(id response) {
            [weakSelf loadData];
            [weakSelf.tableView reloadData];
        } failure:^(NSError *err) {
            NSLog(@"%@", err);
        }];
    }
}
@end
