//
//  PhotoCutViewController.h
//  Seek
//
//  Created by apple on 15/11/7.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoCueDelegate <NSObject>

-(void)passImage:(UIImage *)image;

@end

@interface PhotoCutViewController : UIViewController
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, assign) id<PhotoCueDelegate> delegate;
@end
