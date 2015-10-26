//
//  RCDSelectPersonViewController.h
//  RCloudMessage
//
//  Created by Liv on 15/3/27.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "AddressBookViewController.h"
@class RCDUserInfo;


@interface RCDSelectPersonViewController : AddressBookViewController<UIActionSheetDelegate>

typedef void(^clickDone)(RCDSelectPersonViewController *selectPersonViewController, NSArray *seletedUsers);

@property (nonatomic,copy) clickDone clickDoneCompletion;


@end
