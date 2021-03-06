//
//  SWExploreVC.m
//  SeeWorld
//
//  Created by Albert Lee on 9/9/15.
//  Copyright (c) 2015 SeeWorld. All rights reserved.
//

#import "SWExploreVC.h"
#import "SWHomeFeedModel.h"
#import "SWHomeFeedRecommandView.h"
#import "SWHomeFeedCell.h"
#import "SWFeedInteractVC.h"
#import "SWFeedInteractModel.h"
#import "SWHomeFeedShareView.h"
#import "SWHomeFeedReportView.h"
#import "SWFeedTagButton.h"
#import "SWHomeAddFriendVC.h"
#import "SWTagFeedsVC.h"
#import "SWActionSheetView.h"
#import "SWAgreementVC.h"
#import "SWSearchVC.h"
#import <AVKit/AVKit.h>
@interface SWExploreVC ()<UITableViewDataSource,UITableViewDelegate,SWHomeFeedModelDelegate,
SWHomeFeedCellDelegate,SWFeedInteractVCDelegate,UIDocumentInteractionControllerDelegate>
@property(nonatomic, strong)UITableViewController     *tbVC;
@property(nonatomic, strong)SWHomeFeedModel           *model;
@property(nonatomic, strong)UIDocumentInteractionController *documentController;
@end

@implementation SWExploreVC

- (id)init{
  self = [super init];
  if (self) {
    self.model = [[SWHomeFeedModel alloc] init];
    self.model.delegate = self;
    _model.isExplore = YES;
  }
  return self;
}

- (void)viewWillDisappear:(BOOL)animated{
  [super viewWillDisappear:animated];
  BOOL isMenuVisible = [[UIMenuController sharedMenuController] isMenuVisible];
  if (isMenuVisible) {
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationItem.titleView = [[ALTitleLabel alloc] initWithTitle:SWStringExplore
                                                                color:[UIColor colorWithRGBHex:NAV_BAR_COLOR_HEX]];
  self.view.backgroundColor = [UIColor whiteColor];
  [self uiInitialize];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)viewDidDisappear:(BOOL)animated{
  [super viewDidDisappear:animated];
  [self.tbVC.refreshControl endRefreshing];
}

#pragma mark - Custom Methods
- (void)uiInitialize{
  self.tbVC = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
  self.tbVC.view.frame = self.view.bounds;
  self.tbVC.tableView.dataSource = self;
  self.tbVC.tableView.delegate   = self;
  self.tbVC.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  self.tbVC.tableView.backgroundColor= [UIColor colorWithRGBHex:0xE8EDF3];
  self.tbVC.tableView.contentInset   = UIEdgeInsetsMake(iOSNavHeight, 0, 49+iphoneXBottomAreaHeight, 0);
  self.tbVC.tableView.estimatedRowHeight = 0;
  self.tbVC.tableView.estimatedSectionFooterHeight = 0;
  self.tbVC.tableView.estimatedSectionHeaderHeight = 0;
  self.tbVC.refreshControl = [[UIRefreshControl alloc] init];
  [self.tbVC.refreshControl addTarget:self action:@selector(onHomeRefreshed) forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:self.tbVC.tableView];
  if (@available(iOS 11.0, *)) {
    _tbVC.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
  }
  [self onHomeRefreshed];
}

- (void)forceRefresh{
  [self.tbVC.tableView setContentOffset:CGPointMake(0, -64-64) animated:NO];
  [self.tbVC.refreshControl beginRefreshing];
  [self onHomeRefreshed];
}

- (void)onHomeRefreshed{
  [self.model getLatestFeeds];
  [self.model getRecommandUser];
}
#pragma mark Table View Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  return [self.model.feeds count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
  return [SWHomeFeedCell heightByFeed:[self.model.feeds safeObjectAtIndex:indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  static NSString *identifier = @"feed";
  SWHomeFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (!cell) {
    cell = [[SWHomeFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
  }
  [cell refreshHomeFeed:[self.model.feeds safeObjectAtIndex:indexPath.row] row:indexPath.row];
  cell.delegate = self;
  return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
  CGSize size = scrollView.contentSize;
  float y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom;
  float h = size.height;
  
  float reload_distance = -10;
  if(y > h + reload_distance && size.height>300) {
    [self.model loadMoreFeeds];
  }
}
#pragma mark Model Delegate
- (void)homeFeedModelDidLoadContents:(SWHomeFeedModel *)model{
  [self.tbVC.tableView reloadData];
  [self.tbVC.refreshControl endRefreshing];
}

- (void)homeFeedModelDidPressLike:(SWHomeFeedModel *)model row:(NSInteger)row{
  [self.tbVC.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]
                             withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark Header Delegate
- (void)feedRecommandDidPressUser:(SWFeedUserItem *)user{
  [self homeFeedCellDidPressUser:user];
}

- (void)feedRecommandDidPressAdd:(SWFeedUserItem *)user{
  [self.model addFollowUser:user];
}

- (void)feedRecommandDidPressHide:(SWHomeFeedRecommandView *)view{
  __weak typeof(self)wSelf = self;
  __weak typeof(view)wRec = view;
  
  [UIView animateWithDuration:0.5
                   animations:^{
                     wRec.btnHide.customImageView.transform = CGAffineTransformRotate(wRec.btnHide.customImageView.transform, -M_PI);
                   }];
  
  SWActionSheetView *action = [[SWActionSheetView alloc] initWithFrame:[UIScreen mainScreen].bounds title:nil content:@"隱藏推薦好友"];
  action.cancelBlock = ^{
    [UIView animateWithDuration:0.5
                     animations:^{
                       wRec.btnHide.customImageView.transform = CGAffineTransformIdentity;
                     }];
  };
  action.completeBlock = ^{
    SWActionSheetView *confirmView = [[SWActionSheetView alloc] initWithFrame:[UIScreen mainScreen].bounds title:@"確定隱藏推薦好友？" content:@"確定隱藏"];
    confirmView.cancelBlock = ^{
      [UIView animateWithDuration:0.5
                       animations:^{
                         wRec.btnHide.customImageView.transform = CGAffineTransformIdentity;
                       }];
    };
    confirmView.completeBlock = ^{
      [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"disableHomeFeedRecommandUser"];
      [[NSUserDefaults standardUserDefaults] synchronize];
      wSelf.tbVC.tableView.tableHeaderView = nil;
    };
    [confirmView show];
  };
  [action show];
}

#pragma mark Cell Delegate
- (void)homeFeedCellDidPressUser:(SWFeedUserItem *)userItem{
  [SWFeedUserItem pushUserVC:userItem nav:self.navigationController];
}

- (void)homeFeedCellDidPressLike:(SWFeedItem *)feedItem row:(NSInteger)row{
  [self.model likeClickedByRow:row];
}

- (void)homeFeedCellDidPressReply:(SWFeedItem *)feedItem row:(NSInteger)row enableKeyboard:(BOOL)enableKeyboard{
  SWFeedDetailScrollVC *vc = [[SWFeedDetailScrollVC alloc] init];
  vc.model = _model;
  vc.currentIndex = row;
  vc.hidesBottomBarWhenPushed = YES;
  vc.needEnableKeyboardOnLoad = enableKeyboard;
  [self.navigationController pushViewController:vc animated:YES];
}

- (void)homeFeedCellDidPressUrl:(NSURL *)url row:(NSInteger)row{
  ALWebVC *vc = [[ALWebVC alloc] init];
  vc.url = url.absoluteString;
  vc.hidesBottomBarWhenPushed = YES;
  [self.navigationController pushViewController:vc animated:YES];
}

- (void)homeFeedCellDidPressShare:(SWFeedItem *)feedItem row:(NSInteger)row{
  SWHomeFeedShareView *shareView = [[SWHomeFeedShareView alloc] initWithFrame:[UIScreen mainScreen].bounds];
  [shareView show];
  
  SWHomeFeedCell *cell = (SWHomeFeedCell*)[self.tbVC.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
  
  for (SWFeedTagButton *button in [cell.feedImageView subviews]) {
    if ([button isKindOfClass:[SWFeedTagButton class]]) {
      button.tagHoverImageView.hidden = YES;
      button.tagHoverImageView2.hidden = YES;
    }
  }
  
  UIImage *shareImage = [UIImage imageWithView:cell.feedImageView];
  shareView.shareImage = shareImage;
  
  for (SWFeedTagButton *button in [cell.feedImageView subviews]) {
    if ([button isKindOfClass:[SWFeedTagButton class]]) {
      button.tagHoverImageView.hidden = NO;
      button.tagHoverImageView2.hidden = NO;
    }
  }
  
  __weak typeof(feedItem)wFeed = feedItem;
  shareView.reportBlock = ^{
    SWHomeFeedReportView *reportView = [[SWHomeFeedReportView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    __strong typeof(wFeed)sFeed = wFeed;
    reportView.feedItem = sFeed;
    [reportView show];
  };
  
  __weak typeof(self)wSelf = self;
  __weak typeof(shareView)wShareView = shareView;
  shareView.instaBlock = ^(UIImage *image){
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if([[UIApplication sharedApplication] canOpenURL:instagramURL]) //check for App is install or not
    {
      NSData *imageData = UIImagePNGRepresentation(image); //convert image into .png format.
      NSFileManager *fileManager = [NSFileManager defaultManager];//create instance of NSFileManager
      NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
      NSString *documentsDirectory = [paths objectAtIndex:0]; //create NSString object, that holds our exact path to the documents directory
      NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"insta.igo"]]; //add our image to the path
      [fileManager createFileAtPath:fullPath contents:imageData attributes:nil]; //finally save the path (image)
      CGRect rect = CGRectMake(0 ,0 , 0, 0);
      UIGraphicsBeginImageContextWithOptions(wSelf.view.bounds.size, wSelf.view.opaque, 0.0);
      [wSelf.view.layer renderInContext:UIGraphicsGetCurrentContext()];
      UIGraphicsEndImageContext();
      NSString *fileNameToSave = [NSString stringWithFormat:@"Documents/insta.igo"];
      NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:fileNameToSave];
      NSString *newJpgPath = [NSString stringWithFormat:@"file://%@",jpgPath];
      NSURL *igImageHookFile = [NSURL URLWithString:newJpgPath];
      wSelf.documentController.UTI = @"com.instagram.exclusivegram";
      wSelf.documentController = [wSelf setupControllerWithURL:igImageHookFile usingDelegate:wSelf];
      wSelf.documentController=[UIDocumentInteractionController interactionControllerWithURL:igImageHookFile];
      NSString *caption = @"#Your Text"; //settext as Default Caption
      wSelf.documentController.annotation=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",caption],@"InstagramCaption", nil];
      [wSelf.documentController presentOpenInMenuFromRect:rect inView: wSelf.view animated:YES];
      [wShareView dismiss];
    }
    else{
      [MBProgressHUD showTip:@"未安装Instagram"];
    }
  };
  
  shareView.fbBlock = ^(UIImage *image){
    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
    photo.image = image;
    photo.userGenerated = YES;
    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
    content.photos = @[photo];
    [FBSDKShareDialog showFromViewController:wSelf
                                 withContent:content
                                    delegate:nil];
    
  };
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
  NSLog(@"file url %@",fileURL);
  UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
  interactionController.delegate = interactionDelegate;
  
  return interactionController;
}

- (void)homeFeedCellDidPressLikeList:(SWFeedItem *)feedItem row:(NSInteger)row{
  SWFeedInteractVC *vc = [[SWFeedInteractVC alloc] init];
  vc.delegate = self;
  vc.defaultIndex = SWFeedInteractIndexLikes;
  vc.feedRow  = row;
  vc.isModal  = YES;
  vc.model.feedItem  = feedItem;
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
  [self presentViewController:nav animated:YES completion:nil];
}

- (void)homeFeedCellDidPressTag:(SWFeedTagItem *)tagItem{
  SWTagFeedsVC *vc = [[SWTagFeedsVC alloc] init];
  vc.model.tagItem = tagItem;
  vc.hidesBottomBarWhenPushed = YES;
  [self.navigationController pushViewController:vc animated:YES];
}

- (void)homeFeedCellDidPressImage:(SWFeedItem *)feedItem rects:(NSArray *)rects atIndex:(NSInteger)index{
  ALPhotoListFullView *view = [[ALPhotoListFullView alloc] initWithFrames:rects
                                                                photoList:[feedItem.feed photoUrlsWithSuffix:FEED_SMALL]
                                                                    index:index];
  [view setFeedItem:feedItem];
  [[UIApplication sharedApplication].delegate.window addSubview:view];
}

- (void)homeFeedCellDidPressUrl:(SWFeedItem *)feedItem{
  ALWebVC *vc = [[ALWebVC alloc] init];
  vc.url = [feedItem.feed.link.linkUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  vc.hidesBottomBarWhenPushed = YES;
  [self.navigationController pushViewController:vc animated:YES];
}

- (void)homeFeedCellDidPressVideo:(SWFeedItem *)feedItem row:(NSInteger)row{
  AVPlayerViewController *vc = [[AVPlayerViewController alloc] init];
  AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:feedItem.feed.videoUrl]];
  AVPlayerItem *item = [AVPlayerItem playerItemWithAsset: asset];
  AVPlayer * player = [[AVPlayer alloc] initWithPlayerItem: item];
  vc.player = player;
  [vc.view setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width)];
  vc.showsPlaybackControls = YES;
  [self presentViewController:vc animated:YES completion:nil];
  [player play];
}

#pragma mark Feed Interact VC Delegate
- (void)feedInteractVCDidDismiss:(SWFeedInteractVC *)vc row:(NSInteger)row likes:(NSMutableArray *)likes comments:(NSMutableArray *)comments{
  __weak typeof(self)wSelf = self;
  [wSelf dismissViewControllerAnimated:YES completion:^{
    SWFeedItem *feedItem = [wSelf.model.feeds safeObjectAtIndex:row];
    feedItem.likeCount = [NSNumber numberWithInteger:likes.count];
    feedItem.commentCount = [NSNumber numberWithInteger:comments.count];
    feedItem.likes = likes;
    feedItem.comments = comments;
    
    [wSelf.tbVC.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]
                                withRowAnimation:UITableViewRowAnimationNone];
  }];
}
@end
