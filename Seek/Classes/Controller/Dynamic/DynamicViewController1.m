//
//  DynamicViewController.m
//  Seek
//
//  Created by apple on 15/10/9.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "DynamicViewController.h"
#import "KnowPersonCell.h"
#import "OnePhotoCell.h"
#import "PulishCell.h"
#import "towPhotoCell.h"
#import "ThreePhotoCell.h"
@interface DynamicViewController ()

@end
static NSString *onePhotoIdentifier = @"oneCell";
static NSString *twoPhotoIdentifier = @"twoCell";
static NSString *threePhotoIdentifier = @"twoCell";
static NSString *pulishIdentifier = @"pulishCell";
@implementation DynamicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
#pragma mark -每行高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        return 140;
    }
    return 450;
}
#pragma mark -显示行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OnePhotoCell *oneCell = [tableView dequeueReusableCellWithIdentifier:onePhotoIdentifier];
    towPhotoCell *twoCell = [tableView dequeueReusableCellWithIdentifier:twoPhotoIdentifier];
    ThreePhotoCell *threeCell = [tableView dequeueReusableCellWithIdentifier:threePhotoIdentifier];
    PulishCell *pulishCell = [tableView dequeueReusableCellWithIdentifier:pulishIdentifier];
    if(indexPath.row == 0)
    {
        if(!pulishCell)
        {
            pulishCell = [[NSBundle mainBundle] loadNibNamed:@"PulishCell.xib" owner:nil options:nil].firstObject;
        }
        pulishCell.head_portrait.image = [UIImage imageNamed:@"potrai.png"];
        pulishCell.contentMode = UIViewContentModeScaleAspectFit;
        return pulishCell;
    }else if (indexPath.row%2==0)
    {
        
        if(!oneCell)
        {
            oneCell = [[NSBundle mainBundle] loadNibNamed:@"OnePhotoCell" owner:nil options:nil].firstObject;
        }
        oneCell.head_portrait.image = [UIImage imageNamed:@"potrai.png"];
        oneCell.contentMode = UIViewContentModeScaleAspectFit;
        oneCell.name.text = @"Marray LiLay";
        oneCell.insert_time.text = @"2015-10-08 下午3点";
        oneCell.publish_content.text =@"您的用户昵称和头像变更时，您的 App Server 应该调用此接口刷新在融云侧保存的用户信息，以便融云发送推送消息的时候，能够正确显示用户信息。您的用户昵称和头像变更时，您的 App Server 应该调用此接口刷新在融云侧保存的用户信息，以便融云发送推送消息的时候，能够正确显示用户信息。您的用户昵称和头像变更时，您的 App Server 应该调用此接口刷新在融云侧保存的用户信息，以便融云发送推送消息的时候，能够正确显示用户信息。";
        oneCell.photo.image = [UIImage imageNamed:@"potrai.png"];
        oneCell.comments_nums.text = @"23评论";
        return oneCell;
    }else if (indexPath.row%2==1)
    {
        if(!twoCell)
        {
            twoCell = [[NSBundle mainBundle] loadNibNamed:@"towPhotoCell" owner:nil options:nil].firstObject;
        }
        twoCell.head_portrait.image = [UIImage imageNamed:@"potrai.png"];
        twoCell.contentMode = UIViewContentModeScaleAspectFit;
        twoCell.name.text = @"Marray LiLay";
        twoCell.insert_time.text = @"2015-10-08 下午3点";
        twoCell.publish_content.text =@"您的用户昵称和头像变更时，您的 App Server 应该调用此接口刷新在融云侧保存的用户信息，以便融云发送推送消息的时候，能够正确显示用户信息。您的用户昵称和头像变更时，您的 App Server 应该调用此接口刷新在融云侧保存的用户信息，以便融云发送推送消息的时候，能够正确显示用户信息。您的用户昵称和头像变更时，您的 App Server 应该调用此接口刷新在融云侧保存的用户信息，以便融云发送推送消息的时候，能够正确显示用户信息。";
        twoCell.onePhoto.image = [UIImage imageNamed:@"potrai.png"];
        twoCell.twoPhoto.image = [UIImage imageNamed:@"potrai.png"];
        twoCell.comments_nums.text = @"23评论";
        return twoCell;
    }else{
        if(!threeCell)
        {
            threeCell = [[NSBundle mainBundle] loadNibNamed:@"ThreePhotoCell" owner:nil options:nil].firstObject;
        }
        threeCell.head_portrait.image = [UIImage imageNamed:@"potrai.png"];
        threeCell.contentMode = UIViewContentModeScaleAspectFit;
        threeCell.name.text = @"Marray LiLay";
        threeCell.insert_time.text = @"2015-10-08 下午3点";
        threeCell.publish_content.text =@"您的用户昵称和头像变更时，您的 App Server 应该调用此接口刷新在融云侧保存的用户信息，以便融云发送推送消息的时候，能够正确显示用户信息。您的用户昵称和头像变更时，您的 App Server 应该调用此接口刷新在融云侧保存的用户信息，以便融云发送推送消息的时候，能够正确显示用户信息。您的用户昵称和头像变更时，您的 App Server 应该调用此接口刷新在融云侧保存的用户信息，以便融云发送推送消息的时候，能够正确显示用户信息。";
        threeCell.onePhoto.image = [UIImage imageNamed:@"potrai.png"];
        threeCell.twoPhoto.image = [UIImage imageNamed:@"potrai.png"];
        threeCell.threePhoto.image = [UIImage imageNamed:@"potrai.png"];
        threeCell.comments_nums.text = @"23评论";
        return threeCell;
    }

}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
