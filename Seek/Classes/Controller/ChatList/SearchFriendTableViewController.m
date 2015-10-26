//
//  SearchFriendTableViewController.m
//  Seek
//
//  Created by 吴非凡 on 15/10/23.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "SearchFriendTableViewController.h"
#import "SearchResultTableViewCell.h"
#import "AddFriendViewController.h"
@interface SearchFriendTableViewController () <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchControllerDelegate>


@property (strong, nonatomic) NSMutableArray *searchResult;

@end

@implementation SearchFriendTableViewController

- (void)viewDidLoad {
    
    
    self.navigationItem.title = @"查找好友";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //initial data
    self.searchResult = [[NSMutableArray alloc] init];
}

+(instancetype) searchFriendViewController
{
    SearchFriendTableViewController *searchController = [[SearchFriendTableViewController alloc] initWithNibName:@"SearchFriendTableViewController" bundle:nil];
    return searchController;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - searchResultDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.searchDisplayController.searchResultsTableView)
        return _searchResult.count;
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.searchDisplayController.searchResultsTableView)
        return 80.f;
    return 0.f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *reusableCellWithIdentifier = @"SearchResultTableViewCell";
    SearchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        cell = [[SearchResultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableCellWithIdentifier];
        RCDUserInfo *user =_searchResult[indexPath.row];
        if(user){
            cell.lblName.text = user.name;
            [cell.ivAva sd_setImageWithURL:[NSURL URLWithString:user.portraitUri] placeholderImage:[UIImage imageNamed:@"placeholderUserIcon"]];
        }
    }
    
    
    return cell;
}


#pragma mark - searchResultDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCDUserInfo *user = _searchResult[indexPath.row];
    RCUserInfo *userInfo = [RCUserInfo new];
    userInfo.userId = user.userId;
    userInfo.name = user.name;
    userInfo.portraitUri = user.portraitUri;
    
    if(user && tableView == self.searchDisplayController.searchResultsTableView){
        AddFriendViewController *addViewController = [[AddFriendViewController
                                                      alloc]initWithNibName:@"AddFriendViewController" bundle:nil];
        addViewController.targetUserInfo = userInfo;
        [self.navigationController pushViewController:addViewController animated:YES];
    }
    
}


#pragma mark - UISearchBarDelegate


/**
 *  执行delegate搜索好友
 *
 *  @param searchBar  searchBar description
 *  @param searchText searchText description
 */
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    __weak typeof(self) weakSelf = self;
    // 网速延迟大的时候,会出现多次返回集中一起.导致搜出重复结果
    // 此处两个数组分别存储,当获取到对应结果时,删除后再加入结果数组中.
    if ([searchText length]) {
        [RCDHTTPTOOL searchFriendListByTel:searchText complete:^(NSMutableArray *result) {
            if (result) {
                [weakSelf addUsersFromArray:result];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.searchDisplayController.searchResultsTableView reloadData];
                });
            }
        }];
        
        [RCDHTTPTOOL searchFriendListByName:searchText complete:^(NSMutableArray *result) {
            if (result) {
                [weakSelf addUsersFromArray:result];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.searchDisplayController.searchResultsTableView reloadData];
                    
                });
            }
            
        }];
        
    }
}

- (void)addUsersFromArray:(NSArray *)array {
    for (RCDUserInfo *user in array) {
        BOOL flag = NO;
        for (RCDUserInfo *hasUser in _searchResult) {
            if ([user.userId isEqualToString:hasUser.userId]) {
                flag = YES;
            }
        }
        if (!flag) {
            [_searchResult addObject:user];
        }
    }
}

@end
