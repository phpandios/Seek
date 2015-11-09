//
//  CateViewController.m
//  Seek
//
//  Created by apple on 15/11/9.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "CateViewController.h"

@interface CateViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
- (IBAction)exitAction:(id)sender;
- (IBAction)completeAction:(id)sender;
@property (weak, nonatomic) IBOutlet UICollectionView *collectView;

@end
static NSString * const reuseIdentifier = @"Cell";
@implementation CateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectView.delegate = self;
    self.collectView.dataSource = self;
    self.collectView.backgroundColor = [UIColor whiteColor];
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
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
    cell.backgroundColor = [UIColor lightGrayColor];
    // Configure the cell
    
    return cell;
}

- (IBAction)exitAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)completeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
