//
//  ViewController.m
//  demo_商品详情
//
//  Created by 张家欢 on 16/8/17.
//  Copyright © 2016年 zhangjiahuan. All rights reserved.
//

#import "ViewController.h"
#import "YX.h"
#import "MainTableView.h"
#import "YXTabView.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabView;

@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabViewPre;

@property (nonatomic, assign) BOOL canScroll;

@end

@implementation ViewController
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"商品详情";
    [self setupUI];
}

- (void)setupUI{
    _tableView = [[MainTableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.tag = 1000;
    [self.view addSubview:_tableView];

    [self initBottomView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:kLeaveTopNotificationName object:nil];

    
}
//tab离开顶部时候调用
-(void)acceptMsg:(NSNotification *)notification{
    //NSLog(@"%@",notification);
    NSDictionary *userInfo = notification.userInfo;
    NSString *canScroll = userInfo[@"canScroll"];
    if ([canScroll isEqualToString:@"1"]) {
        _canScroll = YES;
    }
}

-(void)initBottomView{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-kBottomBarHeight, CGRectGetWidth(self.view.frame), kBottomBarHeight)];
    bottomView.backgroundColor = [UIColor lightGrayColor];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:bottomView.bounds];
    textLabel.text = @"底部BAR";
    textLabel.textAlignment = NSTextAlignmentCenter;
    [bottomView addSubview:textLabel];
//    [self.view addSubview:bottomView];
}
#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    CGFloat height = 0.;
    if (section==0) {
        height = 164;
    }else if(section==1){
        height = CGRectGetHeight(self.view.frame)-kBottomBarHeight;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSInteger section  = indexPath.section;
    
    if (section == 0) {
        UILabel *textlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 164)];
        [cell.contentView addSubview:textlabel];
        textlabel.text = @"价格区";
        textlabel.backgroundColor = [UIColor cyanColor];
        textlabel.textAlignment = NSTextAlignmentCenter;
    }else if(section == 1){
        YXTabView *tabView = [[YXTabView alloc] init];
        [cell.contentView addSubview:tabView];
    }
    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat tabOffsetY = [_tableView rectForSection:1].origin.y-64;
    CGFloat offsetY = scrollView.contentOffset.y;

    _isTopIsCanNotMoveTabViewPre = _isTopIsCanNotMoveTabView;
    if (offsetY>=tabOffsetY) {
        scrollView.contentOffset = CGPointMake(0, tabOffsetY); //tab滑动到了顶部，外层的tableview就一直停留在现在的偏移量上面
        NSLog(@"_isTopIsCanNotMoveTabView = yes");
        _isTopIsCanNotMoveTabView = YES;                       //tab滑动到了顶部
    }else{
        _isTopIsCanNotMoveTabView = NO;
        NSLog(@"_isTopIsCanNotMoveTabView = NO");
    }
    if (_isTopIsCanNotMoveTabView != _isTopIsCanNotMoveTabViewPre) {
        if (!_isTopIsCanNotMoveTabViewPre && _isTopIsCanNotMoveTabView) {
//            NSLog(@"滑动到顶端");
            [[NSNotificationCenter defaultCenter] postNotificationName:kGoTopNotificationName object:nil userInfo:@{@"canScroll":@"1"}];
            _canScroll = NO;
        }
        if(_isTopIsCanNotMoveTabViewPre && !_isTopIsCanNotMoveTabView){
//            NSLog(@"离开顶端");
            if (!_canScroll) {
                scrollView.contentOffset = CGPointMake(0, tabOffsetY);
            }
        }
    }
}

@end
