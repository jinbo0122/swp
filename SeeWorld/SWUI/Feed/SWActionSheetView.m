//
//  SWActionSheetView.m
//  SeeWorld
//
//  Created by Albert Lee on 10/8/15.
//  Copyright © 2015 SeeWorld. All rights reserved.
//

#import "SWActionSheetView.h"

@interface SWActionSheetView()
@property(nonatomic, strong)UIView    *bgView;
@property(nonatomic, strong)UIButton  *btnConfirm;
@property(nonatomic, strong)UIButton  *btnTitle;
@end

@implementation SWActionSheetView
- (id)initWithFrame:(CGRect)frame title:(NSString *)title content:(NSString *)content{
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor colorWithRGBHex:0x000000 alpha:0.44];
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height, self.width,title?151:100.5)];
    _bgView.backgroundColor = [UIColor colorWithRGBHex:0x203647];
    [self addSubview:_bgView];
    
    _btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, _bgView.height-50, self.width, 50)];
    [_btnCancel setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRGBHex:0x1a2537] size:_btnCancel.size] forState:UIControlStateNormal];
    [_btnCancel setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRGBHex:0x2d516d] size:_btnCancel.size] forState:UIControlStateHighlighted];
    [_btnCancel setTitle:SWStringCancel forState:UIControlStateNormal];
    [_btnCancel setTitleColor:[UIColor colorWithRGBHex:0xcacaca] forState:UIControlStateNormal];
    [_btnCancel.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [_bgView addSubview:_btnCancel];
    [_btnCancel addTarget:self action:@selector(onCancelClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    _btnConfirm = [[UIButton alloc] initWithFrame:CGRectMake(0, _btnCancel.top-50.5, self.width, 50)];
    [_btnConfirm setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRGBHex:0x1a2537] size:_btnConfirm.size] forState:UIControlStateNormal];
    [_btnConfirm setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRGBHex:0x2d516d] size:_btnConfirm.size] forState:UIControlStateHighlighted];
    [_btnConfirm setTitle:content forState:UIControlStateNormal];
    [_btnConfirm setTitleColor:[UIColor colorWithRGBHex:0xffffff] forState:UIControlStateNormal];
    [_btnConfirm.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [_bgView addSubview:_btnConfirm];
    [_btnConfirm addTarget:self action:@selector(onConfirmClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    if (title) {
      _btnTitle = [[UIButton alloc] initWithFrame:CGRectMake(0, _btnConfirm.top-50.5, self.width, 50)];
      [_btnTitle setBackgroundColor:[UIColor colorWithRGBHex:0x1a2537]];
      [_btnTitle setTitle:title forState:UIControlStateNormal];
      [_btnTitle setTitleColor:[UIColor colorWithRGBHex:0xffffff] forState:UIControlStateNormal];
      [_btnTitle.titleLabel setFont:[UIFont systemFontOfSize:16]];
      [_bgView addSubview:_btnTitle];
    }
  }
  return self;
}

- (void)show{
  [[UIApplication sharedApplication].delegate.window addSubview:self];
  
  if (_bgView.top==self.height) {
    __weak typeof(self)wSelf = self;
    [UIView animateWithDuration:0.3
                     animations:^{
                       wSelf.bgView.top = wSelf.height-wSelf.bgView.height;
                     }];
  }
}

- (void)dismiss{
  [self dismissWithBlock:nil];
}

- (void)dismissWithBlock:(COMPLETION_BLOCK)block{
  if (_bgView.top==self.height-self.bgView.height) {
    __weak typeof(self)wSelf = self;
    [UIView animateWithDuration:0.3
                     animations:^{
                       wSelf.bgView.top = wSelf.height;
                     } completion:^(BOOL finished) {
                       if (block) {
                         block();
                       }
                       [wSelf removeFromSuperview];
                     }];
  }
}

- (void)onConfirmClicked:(UIButton *)button{
  __weak typeof(self)wSelf = self;
  [self dismissWithBlock:^{
    if (wSelf.completeBlock) {
      wSelf.completeBlock();
    }
  }];
}

- (void)onCancelClicked:(UIButton *)button{
  __weak typeof(self)wSelf = self;
  [self dismissWithBlock:^{
    if (wSelf.cancelBlock) {
      wSelf.cancelBlock();
    }
  }];
}
@end
