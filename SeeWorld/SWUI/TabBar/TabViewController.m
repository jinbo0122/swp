//
//  TabViewController.m
//
//
//  Created by abc on 15/4/17.
//  Copyright (c) 2015年 Abc
//

#import "TabViewController.h"
#import "AppDelegate.h"
#import "UzysAssetsPickerController.h"
#import "Macros.h"
#import "SWAddTagViewVC.h"
#import "SWPostEnterView.h"
#import "SWMineVC.h"
#import "SWChatListVC.h"
#import "SWPostVC.h"
#import "SWPostPreviewVC.h"
#import <AVKit/AVKit.h>
#import "AVAsset+VideoOrientation.h"
#define kTag_TabBar_Base 0
#define kTag_TabBar_FeedList kTag_TabBar_Base + 1
#define kTag_TabBar_Discovertory kTag_TabBar_Base + 2
#define kTag_TabBar_Notice kTag_TabBar_Base + 3
#define kTag_TabBar_Message kTag_TabBar_Base + 3
#define kTag_TabBar_Me kTag_TabBar_Base + 5

@interface TabViewController ()<UITabBarControllerDelegate,UzysAssetsPickerControllerDelegate,
SWPostEnterViewDelegate,SWPostPreviewVCDelegate,PDVideoWhisperRecordVCDelegate>{
  UIViewController *_tuPFEditEntryController;
}

@property (nonatomic, assign) NSInteger doubleClick;
@property (nonatomic, strong) UzysAssetsPickerController *photoPicker;
@property (nonatomic, strong) UINavigationController *noticeNav;
@property (nonatomic, strong) SWNoticeVC *noticeVC;
@property (nonatomic, strong) UINavigationController *mineNav;
@property (nonatomic, strong) SWMineVC *mineVC;
@property (nonatomic, strong) UINavigationController *msgNav;
@property (nonatomic, strong) SWChatListVC *msgVC;

@end

@implementation TabViewController{
  UIImageView *_noticeDot;
  UILabel *_lblNoticeDot;
  
  UIImageView *_msgDot;
  UILabel *_lblMsgDot;
}

- (void)initControllers
{
  self.delegate = self;
  
  self.noticeVC = [[SWNoticeVC alloc] init];
  self.noticeNav = [[UINavigationController alloc] initWithRootViewController:self.noticeVC];
  
  self.msgVC = [[SWChatListVC alloc] init];
  self.msgNav = [[UINavigationController alloc] initWithRootViewController:self.msgVC];
  
  
  SWHomeFeedVC *homeFeedVC = [[SWHomeFeedVC alloc] init];
  UINavigationController *feedListViewCotroller = [[UINavigationController alloc] initWithRootViewController:homeFeedVC];
  
  UIImage *homeImage = [UIImage imageNamed:@"home"];
//  UIImage *scaledHomeImage = [UIImage imageWithImage:homeImage scaledToSize:CGSizeMake(23.5, 23.5)];
  
  UITabBarItem *feedListItem = [[UITabBarItem alloc] initWithTitle:@""
                                                             image:[homeImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                               tag:kTag_TabBar_FeedList];
  UIImage *selectHomeImage = [UIImage imageNamed:@"home_highlight"];
//  UIImage *scaledSelectHomeImage = [UIImage imageWithImage:selectHomeImage scaledToSize:CGSizeMake(23.5, 23.5)];

  
  feedListItem.selectedImage = [selectHomeImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
  feedListViewCotroller.tabBarItem = feedListItem;
  
  UIImage *exploreImage = [UIImage imageNamed:@"discover"];
//  UIImage *scaledExploreImage = [UIImage imageWithImage:exploreImage scaledToSize:CGSizeMake(23, 23)];

  UITabBarItem *discovertoryItem = [[UITabBarItem alloc] initWithTitle:@""
                                                                 image:[exploreImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                   tag:kTag_TabBar_Discovertory];
  SWExploreVC *discovertoryVC = [[SWExploreVC alloc] init];
  UINavigationController *discovertoryCotroller = [[UINavigationController alloc] initWithRootViewController:discovertoryVC];
  UIImage *selectExploreImage = [UIImage imageNamed:@"discover_highlight"];
//  UIImage *scaledSelectExploreImage = [UIImage imageWithImage:selectExploreImage scaledToSize:CGSizeMake(23, 23)];

  discovertoryItem.selectedImage = [selectExploreImage
                                    imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
  discovertoryCotroller.tabBarItem = discovertoryItem;
  
  
  UITabBarItem *noticeItem = [[UITabBarItem alloc] initWithTitle:@""
                                                           image:[[UIImage imageNamed:@"notification"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                             tag:kTag_TabBar_Notice];
  noticeItem.selectedImage = [[UIImage imageNamed:@"notification_highlight"]
                              imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
  self.noticeNav.tabBarItem = noticeItem;
  
  UITabBarItem *messageItem = [[UITabBarItem alloc] initWithTitle:@""
                                                            image:[[UIImage imageNamed:@"tabbar_message"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                              tag:kTag_TabBar_Message];
  messageItem.selectedImage = [[UIImage imageNamed:@"tabbar_message_highlight"]
                               imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
  self.msgNav.tabBarItem = messageItem;
  
  self.mineVC = [[SWMineVC alloc] init];
  self.mineVC.isFromTab = YES;
  self.mineVC.user = [SWConfigManager sharedInstance].user;
  [_mineVC refreshUserInfo];
  self.mineNav = [[UINavigationController alloc] initWithRootViewController:self.mineVC];
  
  UITabBarItem *meItem = [[UITabBarItem alloc] initWithTitle:@""
                                                       image:[[UIImage imageNamed:@"me"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                         tag:kTag_TabBar_Me];
  meItem.selectedImage = [[UIImage imageNamed:@"me_highlight"]
                          imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
  self.mineNav.tabBarItem = meItem;
  
  [self setTabbarItemInset:feedListItem];
  feedListItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
  [self setTabbarItemInset:discovertoryItem];
  discovertoryItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
  [self setTabbarItemInset:messageItem];
  messageItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
  [self setTabbarItemInset:noticeItem];
  noticeItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
  [self setTabbarItemInset:meItem];
  meItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
  
  self.viewControllers = @[feedListViewCotroller, discovertoryCotroller, _msgNav, _noticeNav, _mineNav];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [[UITabBar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]]];
  [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hidePickerController) name:@"hidePickerController" object:nil];
  // Do any additional setup after loading the view.
  [self initControllers];
}

+ (void)dotAppearance{
  [TabViewController dotNotice:[SWNoticeModel sharedInstance].unreadNoticeCount msg:[[RCIMClient sharedRCIMClient] getTotalUnreadCount]];
}

+ (void)dotNotice:(NSInteger)unreadNoticeCount msg:(NSInteger)totalUnreadCount{
  TabViewController *tab = (TabViewController*)[UIApplication sharedApplication].delegate.window.rootViewController;
  if([tab isKindOfClass:[TabViewController class]]){
    [tab hideMsgDotView:totalUnreadCount<=0 noticeDotView:unreadNoticeCount<=0 msgNum:totalUnreadCount noticeNum:unreadNoticeCount];
  }
}

- (void)hideMsgDotView:(BOOL)hideMsgDotView noticeDotView:(BOOL)hideNoticeDotView msgNum:(NSInteger)msgNum noticeNum:(NSInteger)noticeNum{
  [_msgDot removeFromSuperview];
  [_noticeDot removeFromSuperview];
  [_lblMsgDot removeFromSuperview];
  [_lblNoticeDot removeFromSuperview];
  if (!hideMsgDotView) {
    _msgDot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_pubup_notice"]];
    _msgDot.frame = CGRectMake(UIScreenWidth *5.1/10.0 + 15, -5, 26, 26);
    _lblMsgDot = [UILabel initWithFrame:CGRectMake(0, 0, _msgDot.width, 24)
                                bgColor:[UIColor clearColor]
                              textColor:[UIColor whiteColor]
                                   text:msgNum>99?@"...":[@(msgNum) stringValue]
                          textAlignment:NSTextAlignmentCenter
                                   font:[UIFont systemFontOfSize:12]];
    [_msgDot addSubview:_lblMsgDot];
    [self.tabBar addSubview:_msgDot];
    _msgDot.hidden = msgNum==0;
  }
  
  if (!hideNoticeDotView) {
    _noticeDot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_pubup_notice"]];
    _noticeDot.frame = CGRectMake(UIScreenWidth *7.1/10.0 + 15, -5, 26, 26);
    _lblMsgDot = [UILabel initWithFrame:CGRectMake(0, 0, _noticeDot.width, 24)
                                bgColor:[UIColor clearColor]
                              textColor:[UIColor whiteColor]
                                   text:noticeNum>99?@"...":[@(noticeNum) stringValue]
                          textAlignment:NSTextAlignmentCenter
                                   font:[UIFont systemFontOfSize:12]];
    [_noticeDot addSubview:_lblMsgDot];
    [self.tabBar addSubview:_noticeDot];
    _noticeDot.hidden = noticeNum==0;
  }
  
  
  if (msgNum+noticeNum > 0) {
    [UIApplication sharedApplication].applicationIconBadgeNumber = msgNum+noticeNum;
  }else{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
  }
}

- (void)pushChat:(UIViewController *)vc{
  [self.msgNav popToRootViewControllerAnimated:NO];
  [self.msgNav pushViewController:vc animated:YES];
}
- (void)popChatSetting{
  [self.msgNav popViewControllerAnimated:NO];
}

- (void)hidePickerController{
  WS(weakSelf);
  [self dismissViewControllerAnimated:YES completion:^{
    UINavigationController *nav = weakSelf.viewControllers.firstObject;
    SWHomeFeedVC *vc = [nav.viewControllers safeObjectAtIndex:0];
    [vc forceRefresh];
    weakSelf.selectedIndex = 0;
    [weakSelf.mineVC refresh];
  }];
}

- (void)setTabbarItemInset:(UITabBarItem *)items
{
  //设置TabBar图片的偏移量
  [items setTitlePositionAdjustment:UIOffsetMake(0, 15)];
}


- (void)selectedTabBarAtIndex:(NSNotification *)notify
{
  NSInteger selectedIndex = [[[notify userInfo] objectForKey:@"tabBarIndex"] integerValue];
  [self setSelectedIndex:selectedIndex];
}

- (void)showComposeView{
  [SWPostEnterView showWithDelegate:self];
}

- (void)compose{
  SWPostVC *vc = [[SWPostVC alloc] init];
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
  [self presentViewController:nav animated:YES completion:nil];
}

- (void)composeWithLBS{
  SWPostVC *vc = [[SWPostVC alloc] init];
  vc.enableLBS = YES;
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
  [self presentViewController:nav animated:YES completion:nil];
}



- (void)composeWithAlbum{
  UzysAssetsPickerController *photoPicker = [[UzysAssetsPickerController alloc] init];
  photoPicker.delegate = self;
  photoPicker.maximumNumberOfSelectionVideo = 1;
  photoPicker.maximumNumberOfSelectionPhoto = 9;
  _photoPicker = photoPicker;
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:photoPicker];
  [nav.navigationBar setBarTintColor:[UIColor blackColor]];
  [nav setNavigationBarHidden:YES];
  [self presentViewController:nav animated:YES completion:^{
  }];
}

- (void)composeWithCamera{
  __weak typeof(self)wSelf = self;
  if ([SWUtility checkCameraWithBlock:^{[wSelf composeWithCamera];}]) {
    [SWUtility checkMicWithBlock:^{
      PDVideoWhisperRecordVC *vc = [[PDVideoWhisperRecordVC alloc] init];
      vc.delegate = self;
      vc.startIndex = 1000;
      UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
      [self presentViewController:nav animated:YES completion:nil];
    }];
  }
}

- (void)startChat{
  SWSelectContactVC *vc = [[SWSelectContactVC alloc] init];
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
  [self presentViewController:nav animated:YES
                   completion:nil];
}

#pragma mark Camera
- (void)videoWhisperRecordVCDidReturnVideoUrl:(NSURL *)videoUrl{
  AVURLAsset *asset = [AVURLAsset assetWithURL:videoUrl];
  CGSize videoSize = [[[asset tracksWithMediaType:AVMediaTypeVideo] safeObjectAtIndex:0] naturalSize];
  LBVideoOrientation orientation = [asset videoOrientation];
  if (orientation == LBVideoOrientationUp ||
      orientation == LBVideoOrientationDown) {
    videoSize = CGSizeMake(videoSize.height, videoSize.width);
  }
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
  [self dismissViewControllerAnimated:NO
                           completion:^{
                             SWPostVC *vc = [[SWPostVC alloc] init];
                             vc.videoURLAsset = asset;
                             vc.videoThumbImage = [asset.URL.absoluteString getThumnailImageWithURL:videoSize.width height:videoSize.height];
                             UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                             [self presentViewController:nav animated:YES completion:nil];
                           }];
}

#pragma mark - UzysAssetsPickerControllerDelegate
- (void)uzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets preview:(BOOL)preview{
  NSMutableArray *imageArray = [NSMutableArray array];
  [assets enumerateObjectsUsingBlock:^(ALAsset *asset, NSUInteger idx, BOOL *stop) {
    struct CGImage *fullScreenImage = asset.defaultRepresentation.fullScreenImage;
    UIImage *image = [UIImage imageWithCGImage:fullScreenImage];
    BOOL isVideo = NO;
    if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
      isVideo = YES;
    }
    
    if (isVideo) {
      [self dismissViewControllerAnimated:NO
                               completion:^{
                                 SWPostVC *vc = [[SWPostVC alloc] init];
                                 vc.videoAsset = asset;
                                 vc.videoThumbImage = image;
                                 UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                                 [self presentViewController:nav animated:YES completion:nil];
                               }];
    }else{
      if (image && [image isKindOfClass:[UIImage class]]){
        [imageArray addObject:image];
      }
      
      if (idx == assets.count-1) {
        if (preview) {
          SWPostPreviewVC *vc = [[SWPostPreviewVC alloc] init];
          vc.images = [imageArray mutableCopy];
          vc.delegate = self;
          vc.startIndex = 1000;
          [picker.navigationController setNavigationBarHidden:NO];
          [picker.navigationController pushViewController:vc animated:YES];
        }else{
          [self dismissViewControllerAnimated:NO
                                   completion:^{
                                     SWPostVC *vc = [[SWPostVC alloc] init];
                                     vc.images = [imageArray mutableCopy];
                                     UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                                     [self presentViewController:nav animated:YES completion:nil];
                                   }];
        }
      }
    }
  }];
}

- (void)uzysAssetsPickerControllerDidExceedMaximumNumberOfSelection:(UzysAssetsPickerController *)picker{
  
}

- (void)postPreviewVCDidPressFinish:(SWPostPreviewVC *)previewVC images:(NSArray *)images tags:(NSArray *)tags{
  __weak typeof(self)wSelf = self;
  [self dismissViewControllerAnimated:YES
                           completion:^{
                             SWPostVC *vc = [[SWPostVC alloc] init];
                             vc.images = [images mutableCopy];
                             vc.tags = [tags mutableCopy];
                             UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                             [wSelf presentViewController:nav animated:YES completion:nil];
                           }];
}

//保存图片
- (NSString *)savePic:(UIImage *)image
{
  if (nil == image)
  {
    return nil;
  }
  
  //根据时间格式确保文件名唯一性
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  NSDate *date = [[NSDate alloc] init];
  [formatter setDateFormat:@"YYYY_MM_dd_HH_mm_ss"];
  //避免时间相同
  NSString *formatStr = [formatter stringFromDate:date];
  NSString *keyStr = [formatStr stringByAppendingString:@".png"];
  
  //写入文件
  NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *path = paths.count > 0? [paths objectAtIndex:0]:@"";
  NSString *fullPath = [path stringByAppendingPathComponent:keyStr];
  
  //保存到沙盒
  [imageData writeToFile:fullPath atomically:NO];
  return fullPath;
}
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
  if (viewController == tabBarController.selectedViewController) {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
      UINavigationController *nav = (UINavigationController *)viewController;
      if ([[nav.viewControllers safeObjectAtIndex:0] isKindOfClass:[SWHomeFeedVC class]]) {
        SWHomeFeedVC *vc = [nav.viewControllers safeObjectAtIndex:0];
        [vc forceRefresh];
      }else if ([[nav.viewControllers safeObjectAtIndex:0] isKindOfClass:[SWNoticeVC class]]) {
        SWNoticeVC *vc = [nav.viewControllers safeObjectAtIndex:0];
        [vc reloadModelData];
      }
    }
    return YES;
  }
  return YES;
}

#pragma mark Post Enter
- (void)postEnterViewDidReturnAction:(SWPostEnterView *)view{
  if (view.isNeedPhoto) {
    [self compose];
  }else if (view.isNeedChat){
    [self startChat];
  }
}
@end
