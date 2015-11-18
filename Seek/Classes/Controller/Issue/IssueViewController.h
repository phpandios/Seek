//
//  IssueViewController.h
//  Seek
//
//  Created by 吴非凡 on 15/10/8.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IssueViewController : UIViewController
@property (nonatomic, copy)NSString *tokePhoto;

@property (nonatomic, copy) void(^currentIssue)(id obj);

@property (nonatomic, strong) NSDictionary *selectedAddressDict;// 键值对,latitude, longitude, address, name
@property (nonatomic, assign) BOOL isNotHave;

@end
