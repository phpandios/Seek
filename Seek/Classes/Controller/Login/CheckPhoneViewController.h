//
//  CheckPhoneViewController.h
//  Seek
//
//  Created by 吴非凡 on 15/10/14.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CheckPhoneTypeForRegister,
    CheckPhoneTypeForFindPwd
} CheckPhoneType;
@interface CheckPhoneViewController : UIViewController

@property (nonatomic, assign) CheckPhoneType type;

@end
