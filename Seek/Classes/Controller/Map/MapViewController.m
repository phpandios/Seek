//
//  MapViewController.m
//  Seek
//
//  Created by 吴非凡 on 15/10/8.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "MapViewController.h"
#import <MAMapKit/MAMapKit.h>
#import "UserAnnotationView.h"
#import "UserInfoForMap.h"
#import "WFFDropdownList.h"
#import "UserForMapCollectionViewCell.h"

#define kMaxColOfCollectionView 4
#define kMaxRowOfCollectionView 3
#define kCellMargin 5
@interface MapViewController ()<MAMapViewDelegate, WFFDropdownListDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) MAAnnotationView *selectedAnnotationView; // 记录点击的标注view

@property (nonatomic, assign) double oldZoomLevel; // 记录缩放级别

@property (nonatomic, strong) NSArray *otherUserNearByArray; // 周边用户信息

@property (nonatomic, strong) NSMutableArray *otherAnnotationArray; // 显示在界面上的周边用户标注

@property (nonatomic, strong) NSMutableDictionary *otherUserNearByDict; // 周边用户信息分组 -- [根据当前缩放级别,当标注重叠自动组合.]

@property (nonatomic, strong) NSArray *otherUsersShowOnCollectionView; // 显示再collectionView上的用户信息

@property (weak, nonatomic) IBOutlet UIView *collectionShadeView; // 遮罩层
@property (weak, nonatomic) IBOutlet UICollectionView *otherUsersCollectionView;// 用于多个用户重叠时,点击弹出显示所有用户

@property (nonatomic, strong) MAUserLocation *currentUserLocation;

@property (nonatomic, strong) MAPointAnnotation *currentUserAnnotation;

#pragma mark 控件组
@property (weak, nonatomic) IBOutlet UISwitch *locationSwitch;
- (IBAction)locationSwitchValueChanged:(UISwitch *)sender;
@property (weak, nonatomic) IBOutlet UIView *dropDownView;
@property (nonatomic, strong) WFFDropdownList *dropDownList;
- (IBAction)locationButtonAction:(UIButton *)sender;
- (IBAction)collectionShadeViewTapGRAction:(UITapGestureRecognizer *)sender;

@end


@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.otherUsersCollectionView registerNib:[UINib nibWithNibName:@"UserForMapCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"otherUserCell"];
    
    // 模拟器没有定位.手动创建
    self.currentUserLocation = [[MAUserLocation alloc] init];
    _currentUserLocation.coordinate = CLLocationCoordinate2DMake(39.989631, 116.481018);
    
    // 屏幕旋转通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    // 配置key
    [MAMapServices sharedServices].apiKey = kLBSAppKey;
    
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    _mapView.delegate = self;
    
    [self.view insertSubview:_mapView atIndex:0];
    // 开启定位
    _mapView.showsUserLocation = YES;
    // 定位用户位置的模式
    _mapView.userTrackingMode = MAUserTrackingModeFollow;//追踪用户的location与heading更新
    // 设置缩放级别
    [_mapView setZoomLevel:16 animated:YES];
    
    self.dropDownList = [[WFFDropdownList alloc] initWithFrame:_dropDownView.bounds dataSource:@[@"全部", @"筛选1", @"筛选2", @"筛选3"]];
    _dropDownList.delegate = self;
    _dropDownList.selectedIndex = 0;
    _dropDownList.maxCountForShow = 5;
    _dropDownList.textColor = [UIColor blackColor];
    _dropDownList.font = [UIFont systemFontOfSize:17];
    [self.dropDownView addSubview:_dropDownList];
    
    
    [self loadOtherUserNearByWithCompletionHandle:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    
    
    // 大头针标注
//    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
//    pointAnnotation.coordinate = CLLocationCoordinate2DMake(39.989631, 116.481018);
//    pointAnnotation.title = @"方恒国际";
//    pointAnnotation.subtitle = @"阜通东大街6号";
//    
//    [_mapView addAnnotation:pointAnnotation];
}

// BEGIN
// 视图切换时,对子视图的frame进行了设置. 因此子视图的frame如果不再手动改变的话,是恒定值,里面的子视图也就不会按autolaytou来布局
// 也可以代码添加view后,给view添加约束
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _dropDownList.frame = _dropDownView.bounds;
}
#pragma mark 屏幕旋转
- (void)handleDeviceOrientationDidChange:(NSNotification *)notification
{
    _dropDownList.frame = _dropDownView.bounds;
}
// END

#pragma mark - Setter
// collectionView数据源获取值后,根据数据源内容数量,更改collectionView的frame
// 进入方法.说明数量肯定  >1
- (void)setOtherUsersShowOnCollectionView:(NSArray *)otherUsersShowOnCollectionView
{
    if (_otherUsersShowOnCollectionView != otherUsersShowOnCollectionView) {
        _otherUsersShowOnCollectionView = nil;
        _otherUsersShowOnCollectionView = otherUsersShowOnCollectionView;
        NSInteger rowNum, colNum;
        if (_otherUsersShowOnCollectionView.count <= kMaxColOfCollectionView) {
            colNum = _otherUsersShowOnCollectionView.count;
            rowNum = 1;
        } else if (_otherUsersShowOnCollectionView.count / 4 <= kMaxRowOfCollectionView){ // 不大于最大行数
            rowNum = _otherUsersShowOnCollectionView.count % 4 == 0 ? _otherUsersShowOnCollectionView.count / 4 : _otherUsersShowOnCollectionView.count / 4 + 1;
            colNum = kMaxColOfCollectionView;
        } else { // 大于最大行数
            rowNum = kMaxRowOfCollectionView;
            colNum = kMaxColOfCollectionView;
        }
        CGFloat height = kUserIconSize * rowNum + kCellMargin * (rowNum + 1);
        CGFloat width = kUserIconSize * colNum + kCellMargin * (colNum + 1);
        self.otherUsersCollectionView.frame = CGRectMake(0, 0, width, height);
        self.otherUsersCollectionView.center = self.mapView.center;
    }
}
- (void)setCurrentUserLocation:(MAUserLocation *)currentUserLocation
{
    if (_currentUserLocation != currentUserLocation) {
        _currentUserLocation = nil;
        _currentUserLocation = currentUserLocation;
        
        // 代表用户的大头针 -- 不存在则创建
        if (!_currentUserAnnotation) {
            self.currentUserAnnotation = [[MAPointAnnotation alloc] init];
            
            self.currentUserAnnotation.title = @"当前位置";
            
            [_mapView addAnnotation:self.currentUserAnnotation];
        }
        // 更新大头针坐标
        self.currentUserAnnotation.coordinate = CLLocationCoordinate2DMake(self.currentUserLocation.coordinate.latitude, self.currentUserLocation.coordinate.longitude);
    }
}

#pragma mark - MAMapViewDelegate
// 设置标注样式
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        if (![self.otherAnnotationArray containsObject:annotation]) { // 不是周边用户
            static NSString *pointReuseIndentifier = @"currentUserReuserIndentifier";
            MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
            if (annotationView == nil)
            {
                annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
            }
            annotationView.canShowCallout= NO;       //设置气泡可以弹出，默认为NO
            annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
            annotationView.draggable = NO;        //设置标注可以拖动，默认为NO
            annotationView.pinColor = MAPinAnnotationColorRed;
            return annotationView;
        } else { // 周边用户
            NSInteger index = [self.otherAnnotationArray indexOfObject:annotation];
            NSValue *key = self.otherUserNearByDict.allKeys[index];
            UserInfoForMap *model = [self.otherUserNearByDict[key] firstObject];
            
            // 获取当前用户对应的地图坐标
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(model.latitude, model.longitude);
            // 获取当前用户在当前地图缩放级别下,在view上的坐标
            CGPoint currentPoint = [_mapView convertCoordinate:coordinate toPointToView:_mapView];
            // 获取当前分组
            NSMutableArray *sectionArray = self.otherUserNearByDict[[NSValue valueWithCGPoint:currentPoint]];
            
            static NSString *pointReuseIndentifier = @"otherUserReuseIndentifier";
            UserAnnotationView *annotationView = (UserAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
            if (annotationView == nil)
            {
                annotationView = [[UserAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
            }
            annotationView.userArray = sectionArray;
            annotationView.canShowCallout= NO;       //设置气泡可以弹出，默认为NO[自定义气泡的时候,需要设置为NO]//http://lbs.amap.com/api/ios-sdk/guide/mapkit/
            
            annotationView.image = [UIImage imageNamed:model.imageUrl];
            //设置中心点偏移，使得标注底部中间点成为经纬度对应点
            annotationView.centerOffset = CGPointMake(0, -kUserIconSize);
            
            ((MAPointAnnotation *)annotation).subtitle = [NSString stringWithFormat:@"分组个数%ld", sectionArray.count];
            return annotationView;
        }
    }
    return nil;
    
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    // 点击先居中.
    [mapView showAnnotations:@[view.annotation] animated:YES];
    // 先为空,防止点的速度过快,点到其他单个的之后,动画结束.而该属性有值.造成错误操作
    self.selectedAnnotationView = nil;
    if ([view isKindOfClass:[UserAnnotationView class]]) { // 点击的周边用户
        UserAnnotationView *userView = (UserAnnotationView *)view;
        if (userView.userArray.count == 1) { // 只有一个 直接推出
            NSLog(@"选中用户ID:%@",[userView.userArray.firstObject userID]);
        } else { // 弹出collectionView
            // 移动动画结束后,再根据选中的项进行操作
            self.selectedAnnotationView = view;
        }
    }
    

    
    
    
}

// 用户位置变化时
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    if(updatingLocation)
    {
        self.currentUserLocation = userLocation;// 用户位置修改后,自动修改用户标注
        if (!_otherUserNearByArray) {// 还没有周边信息,则获取
            [self loadOtherUserNearByWithCompletionHandle:^() {
                
            }];
        }
    }
}


//// 自定义定位标注和精度圈的样式
//- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views
//{
//    MAAnnotationView *view = views[0];
//    
//    // 放到该方法中用以保证userlocation的annotationView已经添加到地图上了。
//    if ([view.annotation isKindOfClass:[MAUserLocation class]])
//    {
//        MAUserLocationRepresentation *pre = [[MAUserLocationRepresentation alloc] init];
//        pre.fillColor = [UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:0.3];
//        pre.strokeColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.9 alpha:1.0];
//        pre.image = [UIImage imageNamed:@"location.png"];
//        pre.lineWidth = 3;
//        pre.lineDashPattern = @[@6, @3];
//        
//        [self.mapView updateUserLocationRepresentation:pre];
//        
//        view.calloutOffset = CGPointMake(0, 0);
//    }
//}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"地图区域变更后");
    // 缩放才重新更新周边用户的标注
    if (self.oldZoomLevel != 0) {
        if (self.oldZoomLevel != mapView.zoomLevel) {
            [self updateAnnotationOfOtherUser];
        }
    }
    // 记录当前缩放级别
    self.oldZoomLevel = mapView.zoomLevel;
    
    if (_selectedAnnotationView) { // 只有选中多个组合的标注,该属性才有值
        UserAnnotationView *userView = (UserAnnotationView *)_selectedAnnotationView;
        self.otherUsersShowOnCollectionView = userView.userArray;
        [self.otherUsersCollectionView reloadData];
        self.collectionShadeView.hidden = NO;
        
        self.selectedAnnotationView = nil;
    }
}

#pragma mark - WFFDropdownListDelegate
- (void)dropdownList:(WFFDropdownList *)dropdownList didSelectedIndex:(NSInteger)selectedIndex
{
    NSLog(@"选中第%ld个筛选项目", selectedIndex);
}

#pragma mark - UICollectionViewDatasource && UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.otherUsersShowOnCollectionView.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UserForMapCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"otherUserCell" forIndexPath:indexPath];
    UserInfoForMap *model = self.otherUsersShowOnCollectionView[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:model.imageUrl];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UserInfoForMap *model = self.otherUsersShowOnCollectionView[indexPath.row];
    NSLog(@"选中的用户ID%@", model.userID);
}
#pragma mark - 私有方法
#pragma mark 计算两点距离
- (CGFloat)distanceFromPointX:(CGPoint)start distanceToPointY:(CGPoint)end{
    CGFloat distance;
    //下面就是高中的数学，不详细解释了
    CGFloat xDist = (end.x - start.x);
    CGFloat yDist = (end.y - start.y);
    distance = sqrt((xDist * xDist) + (yDist * yDist));
    return distance;
}

#pragma mark 更新其他用户的地图标注
- (void)updateAnnotationOfOtherUser
{
    // 移除标注
    [self.mapView removeAnnotations:self.otherAnnotationArray];
    self.otherAnnotationArray = [NSMutableArray array]; // 清空其中的annotation
    self.otherUserNearByDict = [NSMutableDictionary dictionary];

    
    for (UserInfoForMap *model in self.otherUserNearByArray) {
        // 获取当前用户对应的地图坐标
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(model.latitude, model.longitude);
        // 获取当前用户在当前地图缩放级别下,在view上的坐标
        CGPoint currentPoint = [_mapView convertCoordinate:coordinate toPointToView:_mapView];
        
        NSValue *mergedPoint = nil;// 当前点若会与其他点重合,则该值不为nil
        for (NSValue *pointValue in self.otherUserNearByDict.allKeys) {
            CGPoint point = [pointValue CGPointValue];
            if ([self distanceFromPointX:point distanceToPointY:currentPoint] <= kUserIconSize) { // 会发生重合.
                mergedPoint = pointValue;
                break;
            }
        }
        if (mergedPoint) { // 说明会与这个key对应的标注点重合.
            [self.otherUserNearByDict[mergedPoint] addObject:model];
        } else { // 不与其他标注点重合.
            NSMutableArray *array = [NSMutableArray arrayWithObject:model];
            [self.otherUserNearByDict setObject:array forKey:[NSValue valueWithCGPoint:currentPoint]];
        }
    }
    
    for (NSValue *key in self.otherUserNearByDict.allKeys) {
        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
        UserInfoForMap *model = [self.otherUserNearByDict[key] firstObject];
        pointAnnotation.coordinate = CLLocationCoordinate2DMake(model.latitude, model.longitude);
        pointAnnotation.title = model.userID;
        pointAnnotation.subtitle = nil;
        
        [self.otherAnnotationArray addObject:pointAnnotation];
    }
//
//
//        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
//        pointAnnotation.coordinate = CLLocationCoordinate2DMake(model.latitude, model.longitude);
//        pointAnnotation.title = model.userID;
//        pointAnnotation.subtitle = nil;
//        [self.otherAnnotationArray addObject:pointAnnotation];
//        
//        
//        NSLog(@"%@", NSStringFromCGPoint([_mapView convertCoordinate:pointAnnotation.coordinate toPointToView:_mapView]));
//    }
    
    // 把周边用户的标注添加到地图上[一个个添加到地图上,每添加一次就执行一轮viewFor标注.]
    if (_otherAnnotationArray.count > 0) {
        [_mapView addAnnotations:self.otherAnnotationArray];
    }
    
    for (UIView *view in self.mapView.subviews) {
        [view.layer removeAnimationForKey:@"transition"];
        [self addAnimationToView:view];
    }

    // 刷新标注视图
    [self.mapView reloadInputViews];
}

#pragma mark 给指定view添加过场动画
- (void)addAnimationToView:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.5;
    [view.layer addAnimation:animation forKey:@"transition"];
}
#pragma mark - 网络请求
#pragma mark 获取周边用户信息列表
- (void)loadOtherUserNearByWithCompletionHandle:(void (^)())completionHandle
{
    /*
    [[NetHelper shareNetHelper] getDataWithUrlString:nil completionHandle:^(NSData *data) {
        
    }];*/
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        int dLa = (arc4random() % 50 - 25);
        int dLo = (arc4random() % 50 - 25);
        double dLatitude = dLa / (double)5000.0;
        double dLongitude = dLo / (double)5000.0;
        UserInfoForMap *model = [UserInfoForMap new];
        model.userID = [NSString stringWithFormat:@"用户%2d", i];
        model.imageUrl = @"userIcon";
        model.latitude = self.currentUserLocation.coordinate.latitude + dLatitude;
        model.longitude = self.currentUserLocation.coordinate.longitude + dLongitude;
        [array addObject:model];
    }
    //
    self.otherUserNearByArray = array;
    // 更新其他用户的地图标注
    [self updateAnnotationOfOtherUser];
    
    if (completionHandle) {
        completionHandle();
    }
    
}

#pragma mark - 控件
- (IBAction)locationSwitchValueChanged:(UISwitch *)sender {
}
- (IBAction)locationButtonAction:(UIButton *)sender {
    
    // 设置缩放级别
    [_mapView setZoomLevel:16 animated:YES];
    [_mapView showAnnotations:@[self.currentUserAnnotation] animated:YES];
    [self loadOtherUserNearByWithCompletionHandle:^{
        // 定位结束[周边用户信息加载,显示结束]
    }];
}

- (IBAction)collectionShadeViewTapGRAction:(UITapGestureRecognizer *)sender {
    
    self.collectionShadeView.hidden = YES;
}
@end
