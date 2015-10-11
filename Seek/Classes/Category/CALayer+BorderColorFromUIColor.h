//
//  CALayer+BorderColorFromUIColor.h
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/17.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (BorderColorFromUIColor)

@property (nonatomic, strong) UIColor *borderColorFromUIColor;

@property (nonatomic, copy) NSString *borderColorFromRGBString;

@end
