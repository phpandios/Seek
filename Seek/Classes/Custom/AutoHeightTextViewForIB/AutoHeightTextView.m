//
//  AutoHeightTextView.m
//  testTextField
//
//  Created by 吴非凡 on 15/10/16.
//  Copyright © 2015年 吴非凡. All rights reserved.
//


#import "AutoHeightTextView.h"


#define kEdgeInsetFromIB 8

@interface AutoHeightTextView()

@property (nonatomic, strong) UIColor* realTextColor;
@property (nonatomic, readonly) NSString* realText;

@end

@implementation AutoHeightTextView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChange:) name:UITextViewTextDidChangeNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewEndEditing:) name:UITextViewTextDidEndEditingNotification object:self];
        
        self.realTextColor = [[super textColor] copy];
        self.textContainerInset = UIEdgeInsetsMake(8, 0, 8, 0);
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    CGFloat height = self.contentSize.height;
    
    if (_minHeight != 0) {
        if (height < _minHeight) {
            height = _minHeight;
        }
    }
    
    if (_maxHeight != 0) {
        if (height > _maxHeight) {
            height = _maxHeight;
        }
    }
   
    return CGSizeMake(UIViewNoIntrinsicMetric, height);
}

- (void)setMinHeight:(CGFloat)minHeight
{
    if (_minHeight != minHeight) {
        _minHeight = minHeight;
    }
}

- (void)setMaxHeight:(CGFloat)maxHeight
{
    if (_maxHeight != maxHeight) {
        _maxHeight = maxHeight;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self invalidateIntrinsicContentSize];
//    [self textViewEndEditing:nil];
}

- (void) setPlaceholder:(NSString *)aPlaceholder {
    if (_placeholder != aPlaceholder) {
        
        
        if ([self.realText isEqualToString:_placeholder]) {
            self.text = aPlaceholder;
        }
        
        _placeholder = nil;
        _placeholder = [aPlaceholder copy];
        
        if ([self.realText isEqualToString:@""] || self.realText == nil) {
            [self showPlaceholder];
        }
        
        
//        [self textViewEndEditing:nil];
    }
    
}

- (NSString *) text {
    NSString* text = [super text];
    if ([text isEqualToString:self.placeholder]) return @"";
    return text;
}

- (void) setText:(NSString *)text {
    if ([text isEqualToString:@""] || text == nil) {
        [self showPlaceholder];
    }
    else {
        [self hidePlaceholder];
    }
}

- (void)showPlaceholder
{
    [super setText:self.placeholder];
    [super setTextColor:[UIColor lightGrayColor]];
//    self.selectable = NO;
}

- (void)hidePlaceholder
{
    [super setText:self.realText];
    [super setTextColor:self.realTextColor];
//    self.selectable = YES;
}

- (NSString *) realText {
    return [super text];
}

- (void) textViewBeginEditing:(NSNotification*) notification {
    if (notification.object != self) {
        return;
    }
    if ([self.realText isEqualToString:self.placeholder]) {
        super.text = nil;
        [super setTextColor:self.realTextColor];
    } else {
        [self hidePlaceholder];
    }
}

- (void) textViewEndEditing:(NSNotification*) notification {
    if (notification.object != self) {
        return;
    }
    if ([self.realText isEqualToString:@""] || self.realText == nil) {
        [self showPlaceholder];
    } else {
        [self hidePlaceholder];
    }
}

//- (void)textViewDidChange:(NSNotification *)notification {
//    if (notification.object != self) {
//        return;
//    }
//    if ([self.realText isEqualToString:@""] || self.realText == nil) {
//        [self showPlaceholder];
//        self.selectedRange = NSMakeRange(0, 0);
//    } else {
//        [self hidePlaceholder];
//    }
//    if (self.selectedRange.location == 0 && self.selectedRange.length == 0 && [self.realText isEqualToString:self.placeholder]) {
//        [super setText:nil];
//        [super setTextColor:self.realTextColor];
//    }
//}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if ([self.realText isEqualToString:self.placeholder]) {
        if (action == @selector(select:)) {
            [super setText:nil];
            [super setTextColor:self.realTextColor];
        }
        if (action == @selector(paste:)) {
            [super setText:nil];
            [super setTextColor:self.realTextColor];
//            self.textColor = self.realTextColor;
        }
        

    }
        return YES;
}

- (void) setTextColor:(UIColor *)textColor {
    [super setTextColor:textColor];
    self.realTextColor = [textColor copy];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
