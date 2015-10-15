//
//  DynamicDetailViewController.m
//  Seek
//
//  Created by 吴非凡 on 15/10/14.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "DynamicDetailViewController.h"
#import "Dynamic.h"
#import "Comment.h"
#import "CommentForCommentTableViewCell.h"
#import "CommentForDynamicTableViewCell.h"
@interface DynamicDetailViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *commentArray;
//@property (nonatomic, strong) NSMutableDictionary *commentDict;
@end

@implementation DynamicDetailViewController

static NSString *cellIdentifierForComment = @"CommentForCommentTableViewCell";
static NSString *cellIdentifierForDynamic = @"CommentForDynamicTableViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"CommentForCommentTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifierForComment];
    [self.tableView registerNib:[UINib nibWithNibName:@"CommentForDynamicTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifierForDynamic];
    // Do any additional setup after loading the view from its nib.
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadData
{
    NSMutableArray *commentArray = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        Comment *comment = [Comment new];
        comment.respondType = RespondTypeByDynamic;
        comment.fromUserHeadImage = @"userIcon";
        comment.fromUserName = [NSString stringWithFormat:@"用户%02d", i];
        comment.content = [NSString stringWithFormat:@"不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么%2d", i];
        NSMutableArray *childCommentArray = [NSMutableArray array];
        for (int j = 0; j < i; j++) {
            Comment *childComment = [Comment new];
            childComment.respondType = RespondTypeByComment;
            childComment.fromUserName = [NSString stringWithFormat:@"**%02d", j];
            childComment.toUserName = [NSString stringWithFormat:@"用户%02d", i];
            childComment.content = [NSString stringWithFormat:@"不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么不知道说点什么%2d", i];
            [childCommentArray addObject:childComment];
        }
        
        comment.childComments = childCommentArray;
        [commentArray addObject:comment];
    }
    self.commentArray = commentArray;
    [self.tableView reloadData];
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
        for (Comment *subModel in model.childComments) {
            if (indexPath.row == index) {
                result = subModel;
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
    if (comment.respondType == RespondTypeByComment) { // 评论的回复
        cell = (CommentForCommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifierForComment forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    } else if (comment.respondType == RespondTypeByDynamic) { // 动态的回复
        cell = (CommentForDynamicTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifierForDynamic forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell performSelector:@selector(setComment:) withObject:comment];
    return cell;
}

#pragma mark - 动态计算cell高度 -- 费时操作.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;

    Comment *comment = [self commentByIndexPath:indexPath];
    CGFloat height;
    if (comment.respondType == RespondTypeByComment) { // 评论的回复
        cell = (CommentForCommentTableViewCell *)([[NSBundle mainBundle] loadNibNamed:@"CommentForCommentTableViewCell" owner:nil options:nil].firstObject);
        [cell performSelector:@selector(setComment:) withObject:comment];
        height = [((CommentForCommentTableViewCell *)cell).mainView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 16;

    } else if (comment.respondType == RespondTypeByDynamic) { // 动态的回复
        cell = (CommentForDynamicTableViewCell *)([[NSBundle mainBundle] loadNibNamed:@"CommentForDynamicTableViewCell" owner:nil options:nil].firstObject);
        ((CommentForDynamicTableViewCell *)cell).btnClickBlock = ^(UITableViewCell *cell) {
            NSIndexPath *indexPath = [tableView indexPathForCell:cell];
            
            Comment *comment = [self commentByIndexPath:indexPath];
            
            SHOWMESSAGE(@"给- %@ -评论", comment.fromUserName);
        };
        [cell performSelector:@selector(setComment:) withObject:comment];
        height = [((CommentForDynamicTableViewCell *)cell).mainView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 16;

    }
    //    SHOWMESSAGE(@"%.2f", height);
    return height;
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
