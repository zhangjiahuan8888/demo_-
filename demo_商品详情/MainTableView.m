//
//  MainTableView.m
//  demo_商品详情
//
//  Created by 张家欢 on 16/8/17.
//  Copyright © 2016年 zhangjiahuan. All rights reserved.
//

#import "MainTableView.h"

@implementation MainTableView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
@end
