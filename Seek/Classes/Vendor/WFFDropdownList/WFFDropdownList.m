//
//  WFFDropdownList.m
//  Custom
//
//  Created by 吴非凡 on 15/9/2.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import "WFFDropdownList.h"
@interface WFFDropdownList () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
{
    CGFloat _lineHeight;
    CGFloat _lineWidth;
    CGRect _rectOnKeyWindow;
}

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, assign) BOOL isOpen;// 是否打开下拉列表

@property (nonatomic, strong) UITableView *dropdownTalbeView;

@property (nonatomic, strong) UILabel *currentLabel;

@property (nonatomic, assign) NSInteger countOfLinesForShow;

@property (nonatomic, strong) UIView *shadeView;
@end

@implementation WFFDropdownList

#pragma mark - 初始化方法
- (instancetype)initWithFrame:(CGRect)frame dataSource:(NSArray *)array
{
    if (self = [super initWithFrame:frame]) {
        // 屏幕旋转通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
        
        self.dataArray = array;
        _lineHeight = frame.size.height;
        _lineWidth = frame.size.width;
        
        self.maxCountForShow = 5;
        [self addAllViews];
        self.isOpen = NO;
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}
#pragma mark 屏幕旋转
- (void)handleDeviceOrientationDidChange:(NSNotification *)notification
{
    self.shadeView.frame = [UIApplication sharedApplication].keyWindow.bounds;
    // 旋转后,self.frame = ** 外界手动调用. 从而调用本类内的frame的setter方法,更新label和tableview和遮罩层
}
#pragma mark - 私有方法
- (void)addAllViews
{

    UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
    [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(currentLabelTapGRAction:)]];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.userInteractionEnabled = YES;
    label.textColor = [UIColor whiteColor];
    self.currentLabel = label;
    [self addSubview:_currentLabel];
    
    
    UIView *shadeView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    shadeView.backgroundColor = [UIColor clearColor];
    [shadeView addGestureRecognizer:({
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shadeViewTapGRAction:)];
        tapGR.delegate = self;
        tapGR;
    })];
    [[UIApplication sharedApplication].keyWindow addSubview:shadeView];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, _lineWidth, _lineHeight * _countOfLinesForShow)];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.layer.borderWidth = 1;
    self.dropdownTalbeView = tableView;
    
    [shadeView addSubview:_dropdownTalbeView];
    
    
    self.shadeView = shadeView;
    
}

- (void)updateUI
{
    if (_isOpen) {
        _shadeView.hidden = NO;
        CGRect rectOnShadeView = [self convertRect:self.bounds toView:_shadeView];
        self.dropdownTalbeView.frame = CGRectMake(CGRectGetMinX(rectOnShadeView), CGRectGetMinY(rectOnShadeView) - _lineHeight * _countOfLinesForShow, _lineWidth, _lineHeight * _countOfLinesForShow);
        //
        if (_dataArray) {
            [_dropdownTalbeView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        }
        
    } else {
        _shadeView.hidden = YES;
    }
}

#pragma mark - setter
- (void)setTextColor:(UIColor *)textColor
{
    if (_textColor != textColor) {
        _textColor = nil;
        _textColor = textColor;
        _currentLabel.textColor = textColor;
    }
}

- (void)setFont:(UIFont *)font
{
    if (_font != font) {
        _font = nil;
        _font = font;
        _currentLabel.font = font;
    }
}

- (void)setIsOpen:(BOOL)isOpen
{
    _isOpen = isOpen;
    [self updateUI];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    if (_dataArray) {
        if (_selectedIndex > [_dataArray count] - 1) {
            _selectedIndex = [_dataArray count] - 1;
        }
        _currentLabel.text = _dataArray[_selectedIndex];
    } else {
        _selectedIndex = -1;
    }
}

- (void)setMaxCountForShow:(NSInteger)maxCountForShow
{
    _maxCountForShow = maxCountForShow;
    _countOfLinesForShow = [_dataArray count] > _maxCountForShow ? _maxCountForShow : [_dataArray count];
    CGRect frame = self.dropdownTalbeView.frame;
    frame.size.height = _lineHeight * _countOfLinesForShow;
    self.dropdownTalbeView.frame = frame;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _lineHeight = frame.size.height;
    _lineWidth = frame.size.width;
    CGRect rectOnShadeView = [self convertRect:self.bounds toView:_shadeView];
    self.dropdownTalbeView.frame = CGRectMake(CGRectGetMinX(rectOnShadeView), CGRectGetMaxY(rectOnShadeView), _lineWidth, _lineHeight * _countOfLinesForShow);
    self.currentLabel.frame = self.bounds;
}
#pragma mark - 轻拍手势
#pragma mark Label手势
- (void)currentLabelTapGRAction:(UITapGestureRecognizer *)sender
{
    self.isOpen = !self.isOpen;
}
#pragma mark 遮罩层手势
- (void)shadeViewTapGRAction:(UITapGestureRecognizer *)sender{
    self.isOpen = NO;
}

#pragma mark - 遮罩层手势代理
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint point = [touch locationInView:gestureRecognizer.view];
    if (CGRectContainsPoint(_dropdownTalbeView.frame, point)) {
        return NO;
    }
    return YES;
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray ? _dataArray.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    
    UILabel *label = (UILabel *)[cell viewWithTag:100];
    if (!label) {
        label = [[UILabel alloc] initWithFrame:cell.bounds];
        [cell addSubview:label];
    }
    label.tag = 100;
    label.text = _dataArray[indexPath.row];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = self.font;
    
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _lineHeight;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath.row;
    self.isOpen = NO;
    if ([_delegate respondsToSelector:@selector(dropdownList:didSelectedIndex:)]) {
        [_delegate dropdownList:self didSelectedIndex:_selectedIndex];
    }
}
@end
