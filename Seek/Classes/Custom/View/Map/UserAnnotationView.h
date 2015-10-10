//
//  UserAnnotationView.h
//  Seek
//
//  Created by 吴非凡 on 15/10/10.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

@interface UserAnnotationView : MAAnnotationView

@property (nonatomic, strong) NSArray *userArray; // 标注所对应的用户的数量

@end
