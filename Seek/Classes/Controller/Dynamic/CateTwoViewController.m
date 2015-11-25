//
//  CateTwoViewController.m
//  Seek
//
//  Created by apple on 15/11/25.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "CateTwoViewController.h"
#import "Dynamic_category.h"

@interface CateTwoViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
- (IBAction)exitAtion:(id)sender;
- (IBAction)completAction:(id)sender;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionContent;

@property (nonatomic, retain) NSMutableArray *cate_arr;
@property (nonatomic, retain) NSIndexPath *lastIndex;
@end

static NSString * const reuseIdentifier = @"Cell";
@implementation CateTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionContent registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    self.collectionContent.delegate = self;
    self.collectionContent.dataSource = self;
    self.collectionContent.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction:)];
   
    [self loadData];
}
#pragma mark -重写getter方法
- (NSMutableArray *)cate_arr
{
    if (!_cate_arr) {
        self.cate_arr = [NSMutableArray new];
    }
    return _cate_arr;
}

#pragma mark -分类数据
- (void)loadData
{
    __weak typeof(self) weakSelf = self;
    NSLog(@"%ld", self.parent_id);
    [AFHttpTool getCateGoryWithstate:1 parent_id:self.parent_id success:^(id response) {
        if ([response[@"result"] count] == 0) {
            return;
        }
        for (int i=0; i < [response[@"result"] count]; i++) {
            Dynamic_category *dynamic_cate = [Dynamic_category new];
            [dynamic_cate setValuesForKeysWithDictionary:response[@"result"][i]];
            [weakSelf.cate_arr addObject:dynamic_cate];
        }
        [weakSelf.collectionContent reloadData];
    } failure:^(NSError *err) {
        
    }];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.cate_arr count];
}
#pragma mark -设置每个item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(100, 40);
}
#pragma mark－设置内边距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark -设置每个cell的大小
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:0.894 green:0.886 blue:0.902 alpha:1.000];
    Dynamic_category *cate = self.cate_arr[indexPath.row];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = cate.category_name;
    [cell.contentView addSubview:label];
    return cell;
}

#pragma mark -点击每个cell事件
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //    darkGrayColor
    
    if (indexPath != _lastIndex) {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        cell.backgroundColor = [UIColor colorWithRed:0.369 green:0.027 blue:0.996 alpha:1.000];
        UILabel *label = (UILabel *)[cell.contentView subviews].firstObject;
        label.textColor = [UIColor whiteColor];
        
        UICollectionViewCell *oldCell = [collectionView cellForItemAtIndexPath:_lastIndex];
        oldCell.backgroundColor = [UIColor colorWithRed:0.894 green:0.886 blue:0.902 alpha:1.000];
        UILabel *labelOld = (UILabel *)[cell.contentView subviews].firstObject;
        labelOld.textColor = [UIColor blackColor];
    }
    
    _lastIndex = indexPath;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)doneAction:(id)sender
{
    if (_cateTwoCurrent) {
        Dynamic_category *cate = self.cate_arr[_lastIndex.row];
        _cateTwoCurrent(cate.category_name, cate.ID);
    }
    [self.navigationController popViewControllerAnimated:YES];
//    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)exitAtion:(id)sender {
}

- (IBAction)completAction:(id)sender {
}
@end
