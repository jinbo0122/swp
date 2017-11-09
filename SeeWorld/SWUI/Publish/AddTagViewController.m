//
//  AddTagViewController.m
//  SeeWorld
//
//  Created by liufz on 15/9/12.
//  Copyright (c) 2015年 SeeWorld. All rights reserved.
//

#import "AddTagViewController.h"
#import "ComposeViewController.h"
#import "WTTagView.h"
#import "WTTagViewItem.h"
#import "WTTag.h"
#import "AddTagSearchViewController.h"

@interface AddTagViewController ()<WTTagViewDataSouce, WTTagViewDelegate>
@property (nonatomic, strong) WTTagView *tagView;
@property (nonatomic, strong) UILabel *lblAdd;
@property (nonatomic, strong) UILabel *lblInfo;
@property (nonatomic, strong) UILabel *lblIntro;
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) NSMutableArray *addedTags;
@property (nonatomic, assign) CGPoint selectedPoint;
@property (nonatomic, assign) CGRect imageFrame;
@end

@implementation AddTagViewController

- (NSMutableArray *)addedTags
{
  if (nil == _addedTags) {
    _addedTags = @[].mutableCopy;
  }
  return _addedTags;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRGBHex:0x152c3e]];
  [self.navigationController.navigationBar setTintColor:[UIColor colorWithRGBHex:0x152c3e]];
  _tagView = [[WTTagView alloc] initWithFrame:CGRectMake(0, 20, UIScreenWidth, UIScreenWidth)];
  [self.view addSubview:[ALLineView lineWithFrame:_tagView.frame colorHex:0x000000]];
  [self.view addSubview:_tagView];
  self.tagView.backgroundImageView.image = self.photoImage;
  self.tagView.delegate = self;
  self.tagView.dataSource = self;
  self.tagView.backgroundColor = [UIColor blackColor];
  CGFloat scale = [UIScreen mainScreen].scale;
  if (self.photoImage.size.width>self.photoImage.size.height) {
    CGFloat height = self.photoImage.size.height * UIScreenWidth/self.photoImage.size.width;
    self.tagView.height = height;
    self.tagView.top = 20+(UIScreenWidth-height)/2.0;
    _imageFrame = CGRectMake(0, (UIScreenWidth-height)*scale/2.0,
                             self.tagView.width * scale, height * scale);
  }else if (self.photoImage.size.width<self.photoImage.size.height){
    CGFloat width = self.photoImage.size.width * UIScreenWidth/self.photoImage.size.height;
    self.tagView.width = width;
    self.tagView.left = (UIScreenWidth-width)/2.0;
    _imageFrame = CGRectMake((UIScreenWidth-width)*scale/2.0, 0,
                             width*scale, self.tagView.height*scale);
    
  }else{
    _imageFrame = CGRectMake(0, 0, self.tagView.width*scale, self.tagView.height*scale);
  }
  
  _icon = [[UIImageView alloc] initWithFrame:CGRectZero];
  _icon.image = [UIImage imageNamed:@"add_photo_iocn_tag"];
  [self.view addSubview:_icon];
  [_icon sizeToFit];
  
  _lblInfo = [UILabel initWithFrame:CGRectZero
                            bgColor:[UIColor clearColor]
                          textColor:[UIColor whiteColor]
                               text:@"點擊圖片加入標籤"
                      textAlignment:NSTextAlignmentLeft font:[UIFont systemFontOfSize:18]];
  [_lblInfo sizeToFit];
  [self.view addSubview:_lblInfo];
  
  _icon.left = (self.view.width-_icon.width-12-_lblInfo.width)/2.0;
  _lblInfo.left = _icon.right+12;
  _icon.top = _lblInfo.top = self.view.height-51-42-45-18-18;
  _icon.top+=2;
  
  _lblIntro = [UILabel initWithFrame:CGRectMake(0, self.view.height-51-42-18, self.view.width, 18)
                             bgColor:[UIColor clearColor]
                           textColor:[UIColor whiteColor]
                                text:@"標記品牌、地點或者人物"
                       textAlignment:NSTextAlignmentCenter font:[UIFont systemFontOfSize:18]];
  [self.view addSubview:_lblIntro];
  
  _lblAdd = [UILabel initWithFrame:CGRectZero
                           bgColor:[UIColor clearColor]
                         textColor:[UIColor whiteColor]
                              text:@"添加標籤"
                     textAlignment:NSTextAlignmentLeft font:[UIFont systemFontOfSize:18]];
  [_lblAdd sizeToFit];
  _lblAdd.top  = self.view.height-51 + (51-_lblAdd.height)/2.0;
  _lblAdd.left = (self.view.width-_lblAdd.width)/2.0;
  [self.view addSubview:_lblAdd];
  
  self.navigationItem.backBarButtonItem = nil;
  self.title = @" ";
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated navigationBarHidden:YES tabBarHidden:YES];
}

- (IBAction)backClick:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)nextStepClick:(id)sender {
  
  if (self.addedTags.count == 0)
  {
    [[[SWAlertView alloc] initWithTitle:@"請至少添加一個標籤"
                             cancelText:SWStringOkay
                            cancelBlock:^{
                              
                            } okText:nil
                                okBlock:^{
                                  
                                }] show];
    return;
  }
  
  NSMutableArray *tags = [NSMutableArray array];
  for (int i = 0; i < _addedTags.count; i++)
  {
    WTTag *tag = _addedTags[i];
    NSDictionary *coordDic = @{@"x":@(tag.tagCenterPointPercentage.x),@"y":@(tag.tagCenterPointPercentage.y),@"w":@(0),@"h":@(0)};
    NSDictionary *tagDic = @{@"tagId":@(i),
                             @"tagName":tag.titleString,
                             @"direction":@(!tag.tagDirection),
                             @"coord":coordDic};
    
    [tags addObject:tagDic];
  }
  
  UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Publish" bundle:nil];
  ComposeViewController *vc = [sb instantiateViewControllerWithIdentifier:@"ComposeViewController"];
  vc.photoImage = self.photoImage;
  UIImage *image = [UIImage imageWithView:self.tagView];
  vc.resultImage = image;
  vc.tags = tags;
  [self pushViewController:vc];
}

#pragma mark - WTTagView DataSource

- (NSInteger)numberOfTagViewItemsInTagView:(WTTagView *)tagView
{
  return self.addedTags.count;
}

- (UIView<WTTagViewItemMethods> *)tagView:(WTTagView *)tagView tagViewItemAtIndex:(NSInteger)index
{
  WTTag *tag = self.addedTags[index];
  
  WTTagViewItem *tagViewItem = [[WTTagViewItem alloc] init];
  tagViewItem.titleText = tag.titleString;
  tagViewItem.tagViewItemDirection = tag.tagDirection;
  tagViewItem.centerPointPercentage = tag.tagCenterPointPercentage;
  return tagViewItem;
}


#pragma mark - WTTagView Delegate

- (void)tagView:(WTTagView *)tagView didTappedTagViewItem:(UIView<WTTagViewItemMethods> *)tagViewItem atIndex:(NSInteger)index{
  __weak typeof(self)wSelf = self;
  [[[SWAlertView alloc] initWithTitle:@"你確定要刪除標籤嗎"
                           cancelText:SWStringCancel
                          cancelBlock:^{
                            
                          } okText:SWStringOkay
                              okBlock:^{
                                [wSelf.addedTags removeObjectAtIndex:index];
                                [wSelf.tagView reloadData];
                                [wSelf.tagView makeTagItemsAnimated];
                              }] show];
}

//editMode
- (void)tagView:(WTTagView *)tagView tagViewItem:(UIView<WTTagViewItemMethods> *)tagViewItem didChangedDirection:(WTTagViewItemDirection)tagViewItemDirection AtIndex:(NSInteger)index
{
  WTTag *misc = self.addedTags[index];
  misc.tagDirection = tagViewItemDirection;
}

- (void)tagView:(WTTagView *)tagView didLongPressedTagViewItem:(UIView<WTTagViewItemMethods> *)tagViewItem atIndex:(NSInteger)index
{
  WTTag *misc = self.addedTags[index];
  [tagViewItem reverseTagViewItemDirection];
  misc.tagDirection = tagViewItem.tagViewItemDirection;
}

- (void)tagView:(WTTagView *)tagView didMoveTagViewItem:(UIView<WTTagViewItemMethods> *)tagViewItem atIndex:(NSInteger)index toNewPositonPercentage:(CGPoint)pointPercentage
{
  WTTag *misc = self.addedTags[index];
  misc.tagCenterPointPercentage = pointPercentage;
}

- (void)tagView:(WTTagView *)tagView addNewTagViewItemTappedAtPosition:(CGPoint)ponit
{
  self.selectedPoint = ponit;
  
  UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Publish" bundle:nil];
  AddTagSearchViewController *vc = [sb instantiateViewControllerWithIdentifier:@"AddTagSearchViewController"];
  __weak __typeof(self)weakSelf = self;
  vc.endInputTitleHandler = ^(NSString *inputTitle) {
    __strong __typeof(weakSelf)strongSelf = weakSelf;
    WTTag *tag = [[WTTag alloc] init];
    tag.titleString = inputTitle;
    tag.tagDirection = WTTagViewItemDirectionLeft;
    tag.tagCenterPointPercentage = CGPointMake(strongSelf.selectedPoint.x / strongSelf.tagView.bounds.size.width, strongSelf.selectedPoint.y / strongSelf.tagView.bounds.size.height);
    [strongSelf.addedTags addObject:tag];
    [strongSelf.tagView reloadData];
    [self.tagView makeTagItemsAnimated];
  };
  
  [self presentViewController:vc animated:YES completion:^{
  }];
}
@end
