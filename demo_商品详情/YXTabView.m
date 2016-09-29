//
//  YXTabView.m
//  仿造淘宝商品详情页
//
//  Created by yixiang on 16/3/25.
//  Copyright © 2016年 yixiang. All rights reserved.
//

#import "YXTabView.h"
#import "YX.h"
#import <WebKit/WebKit.h>
@interface YXTabView()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property (nonatomic, strong) UIView *tabTitleView;
@property (nonatomic, strong) UITableView *tabContentView;
//@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, assign) BOOL canScroll;
@end

@implementation YXTabView

-(instancetype)init{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64);
        
        _tabTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kTabTitleViewHeight)];
        _tabTitleView.backgroundColor = [UIColor lightGrayColor];
        UIButton *picDetailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [picDetailBtn setTitle:@"图文详情" forState:UIControlStateNormal];
        picDetailBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH/2, kTabTitleViewHeight);
        [picDetailBtn addTarget:self action:@selector(clickPicDetail) forControlEvents:UIControlEventTouchUpInside];
        [_tabTitleView addSubview:picDetailBtn];
        [self addSubview:_tabTitleView];
        
        UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [commentBtn setTitle:@"评价" forState:UIControlStateNormal];
        commentBtn.frame = CGRectMake(SCREEN_WIDTH/2, 0, SCREEN_WIDTH/2, kTabTitleViewHeight);
        [commentBtn addTarget:self action:@selector(clickComment) forControlEvents:UIControlEventTouchUpInside];
        [_tabTitleView addSubview:commentBtn];
        [self addSubview:_tabTitleView];

        //评论视图
        _tabContentView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_tabTitleView.frame), SCREEN_WIDTH, CGRectGetHeight(self.frame) - CGRectGetHeight(_tabTitleView.frame)) style:UITableViewStylePlain];
        _tabContentView.dataSource = self;
        _tabContentView.delegate = self;
        _tabContentView.hidden = YES;
        [self addSubview:_tabContentView];
       
        
        //////  WKWebView内存在7兆左右，UIWebView在100兆左右
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_tabTitleView.frame), SCREEN_WIDTH, CGRectGetHeight(self.frame) - CGRectGetHeight(_tabTitleView.frame))];
        _webView.scrollView.delegate = self;
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.zol.com.cn"]]];
        [self addSubview:_webView];
        
        ///////
        
        //图文详情
//        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_tabTitleView.frame), SCREEN_WIDTH, CGRectGetHeight(self.frame) - CGRectGetHeight(_tabTitleView.frame))];
//        _webView.backgroundColor = [UIColor redColor];
//        _webView.scrollView.delegate = self;
//        [self addSubview:_webView];
//        NSURL *url = [NSURL URLWithString:@"http://www.zol.com.cn"];
//        NSURLRequest *request = [NSURLRequest requestWithURL:url];
//        [_webView loadRequest:request];

        //注册通知的观察者
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:kGoTopNotificationName object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:kLeaveTopNotificationName object:nil];//其中一个TAB离开顶部的时候，如果其他几个偏移量不为0的时候，要把他们都置为0
        
    }
    return self;
}
- (void)clickPicDetail{
    NSLog(@"点击了图文详情");
    _webView.hidden = NO;
    _tabContentView.hidden = YES;
}
- (void)clickComment{
    _webView.hidden = YES;
    _tabContentView.hidden = NO;

}
-(void)acceptMsg : (NSNotification *)notification{
    
    NSString *notificationName = notification.name;
    //tab滚动到了顶端
    if ([notificationName isEqualToString:kGoTopNotificationName]) {
        NSDictionary *userInfo = notification.userInfo;
        NSString *canScroll = userInfo[@"canScroll"];
        if ([canScroll isEqualToString:@"1"]) {
            self.canScroll = YES;
            
        }
    }else if([notificationName isEqualToString:kLeaveTopNotificationName]){
        _tabContentView.contentOffset = CGPointZero;
        self.canScroll = NO;
        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = @"评价";
    return cell;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    //内层tableview不可以滑动时候是通过设置setContentOffset:CGPointZero来实现的
    if (!self.canScroll) {
        [scrollView setContentOffset:CGPointZero];
    }
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY<0) {
        NSLog(@"offsetY<0)");
        //图文详情及评价按钮将要离开顶部向下的时候，发送通知kLeaveTopNotificationName
        [[NSNotificationCenter defaultCenter] postNotificationName:kLeaveTopNotificationName object:nil userInfo:@{@"canScroll":@"1"}];
    }
}
@end
