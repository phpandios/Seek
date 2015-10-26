//
//  AddFriendViewController.h
//  Seek
//
//  Created by 吴非凡 on 15/10/26.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddFriendViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *ivAva;

@property (nonatomic,strong) RCUserInfo *targetUserInfo;
@end
