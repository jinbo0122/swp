//
//  SWHomeFeedVC.m
//  SeeWorld
//
//  Created by Albert Lee on 8/31/15.
//  Copyright (c) 2015 SeeWorld. All rights reserved.
//

#import "SWHomeFeedVC.h"
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
#import "SWHomeHeaderView.h"
#import "SWUserListVC.h"
#import <AVKit/AVKit.h>
@interface SWHomeFeedVC ()<UITableViewDataSource,UITableViewDelegate,SWHomeFeedModelDelegate,
SWHomeFeedCellDelegate,SWHomeFeedRecommandViewDelegate,SWFeedInteractVCDelegate,UIDocumentInteractionControllerDelegate,
SWHomeHeaderViewDelegate>
@property(nonatomic, strong)UITableViewController     *tbVC;
@property(nonatomic, strong)SWHomeFeedModel           *model;
@property(nonatomic, strong)SWHomeFeedRecommandView   *recommandView;
@property(nonatomic, strong)SWHomeHeaderView          *postView;
@property(nonatomic, strong)UIDocumentInteractionController *documentController;

@property(nonatomic, strong)SWSearchBar *searchBar;
@property(nonatomic, strong)UIButton    *btnSearch;
@end

@implementation SWHomeFeedVC{
  UIView *_headerView;
}

- (id)init{
  self = [super init];
  if (self) {
    self.model = [[SWHomeFeedModel alloc] init];
    self.model.delegate = self;
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
  self.navigationItem.titleView = [[ALTitleLabel alloc] initWithTitle:SWStringHome
                                                                color:[UIColor colorWithRGBHex:NAV_BAR_COLOR_HEX]
                                                             fontSize:18];
  self.view.backgroundColor = [UIColor whiteColor];
  self.btnSearch = [[UIButton alloc] initWithFrame:CGRectMake(0, iOSNavHeight, self.view.width - 20, 50)];
  self.navigationItem.titleView = self.btnSearch;
  self.automaticallyAdjustsScrollViewInsets = NO;
  self.searchBar = [[SWSearchBar alloc] initWithFrame:CGRectMake(0, 7, self.btnSearch.width, 30)];
  self.searchBar.placeholder = SWStringSearch;
  self.searchBar.userInteractionEnabled = NO;
  self.searchBar.showsCancelButton = NO;
  self.searchBar.layer.borderColor = [UIColor colorWithRGBHex:0xcccccc].CGColor;
  [_searchBar setSearchFieldBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor] size:_searchBar.size] forState:UIControlStateNormal];
  [self.btnSearch addSubview:self.searchBar];
  [self.btnSearch addTarget:self action:@selector(onSearchClicked:) forControlEvents:UIControlEventTouchUpInside];
  
  [self uiInitialize];
  
  __weak typeof(self)wSelf= self;
  [[NSNotificationCenter defaultCenter] addObserverForName:@"onHomeFeedTagClicked"
                                                    object:nil
                                                     queue:[NSOperationQueue mainQueue]
                                                usingBlock:^(NSNotification *note) {
                                                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                    __strong typeof(wSelf)sSelf = wSelf;
                                                    [sSelf homeFeedCellDidPressTag:[note.userInfo safeObjectForKey:@"tag"]];
                                                  });
                                                }];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)viewDidDisappear:(BOOL)animated{
  [super viewDidDisappear:animated];
  [self.tbVC.refreshControl endRefreshing];
}

#pragma mark - Custom Methods
- (void)showNavPostEntry{
  if (self.navigationItem.rightBarButtonItem) {
    return;
  }
  __weak typeof(self)wSelf = self;
  [UIView animateWithDuration:0.2
                   animations:^{
                     wSelf.btnSearch.width = wSelf.view.width - 60;
                     wSelf.searchBar.width = wSelf.btnSearch.width;
                   }];
  UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"home_post"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(onPostClicked:)];
  if (isRunningOnIOS11) {
    item.imageInsets = UIEdgeInsetsMake(0, 0, 0, -5);
  }
  self.navigationItem.rightBarButtonItem = item;
}

- (void)hideNavPostEntry{
  if (self.navigationItem.rightBarButtonItem == nil) {
    return;
  }
  __weak typeof(self)wSelf = self;
  [UIView animateWithDuration:0.2
                   animations:^{
                     wSelf.btnSearch.width = wSelf.view.width - 20;
                     wSelf.searchBar.width = wSelf.btnSearch.width;
                   }];
  self.navigationItem.rightBarButtonItem = nil;
}

- (void)onPostClicked:(UIBarButtonItem *)item{
  [self homeHeaderViewDidPressPost:_postView];
}

- (void)onAddFriendClicked:(UIBarButtonItem *)item{
  SWHomeAddFriendVC *vc = [[SWHomeAddFriendVC alloc] init];
  vc.hidesBottomBarWhenPushed = YES;
  [self.navigationController pushViewController:vc animated:YES];
}

- (void)onSearchClicked:(UIButton *)button{
  SWSearchVC *vc = [[SWSearchVC alloc] init];
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
  [self presentViewController:nav animated:YES completion:nil];
}

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
  _postView = [[SWHomeHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 110)];
  _postView.delegate = self;
  _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, _postView.height)];
  [_headerView addSubview:_postView];
  
  _recommandView = [[SWHomeFeedRecommandView alloc] initWithFrame:CGRectMake(0, _postView.bottom+7, UIScreenWidth, 183)];
  _recommandView.delegate = self;
  [_headerView addSubview:_recommandView];
  _recommandView.hidden = YES;

  _tbVC.tableView.tableHeaderView = _headerView;

  [self onHomeRefreshed];
}

- (void)forceRefresh{
  [self.tbVC.tableView setContentOffset:CGPointMake(0, -64-64-iOSTopHeight) animated:NO];
  [self.tbVC.refreshControl beginRefreshing];
  [self onHomeRefreshed];
}

- (void)onHomeRefreshed{
  [self.model getLatestFeeds];
  [self.model getRecommandUser];
}

#pragma mark Header View Delegate
- (void)homeHeaderViewDidPressPost:(SWHomeHeaderView *)headerView{
  TabViewController *tabVC = (TabViewController *)[UIApplication sharedApplication].delegate.window.rootViewController;
  if ([tabVC isKindOfClass:[TabViewController class]]) {
    [tabVC compose];
  }
}

- (void)homeHeaderViewDidPressCamera:(SWHomeHeaderView *)headerView{
  TabViewController *tabVC = (TabViewController *)[UIApplication sharedApplication].delegate.window.rootViewController;
  if ([tabVC isKindOfClass:[TabViewController class]]) {
    [tabVC composeWithCamera];
  }
}

- (void)homeHeaderViewDidPressAlbum:(SWHomeHeaderView *)headerView{
  TabViewController *tabVC = (TabViewController *)[UIApplication sharedApplication].delegate.window.rootViewController;
  if ([tabVC isKindOfClass:[TabViewController class]]) {
    [tabVC composeWithAlbum];
  }
}

- (void)homeHeaderViewDidPressLBS:(SWHomeHeaderView *)headerView{
  TabViewController *tabVC = (TabViewController *)[UIApplication sharedApplication].delegate.window.rootViewController;
  if ([tabVC isKindOfClass:[TabViewController class]]) {
    [tabVC composeWithLBS];
  }
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
  
  if (scrollView.contentOffset.y > _postView.height - iOSNavHeight) {
    [self showNavPostEntry];
  }else{
    [self hideNavPostEntry];
  }
  
  if(y > h + reload_distance && size.height>300) {
    [self.model loadMoreFeeds];
  }
}
#pragma mark Model Delegate
- (void)homeFeedModelDidLoadContents:(SWHomeFeedModel *)model{
  [self.tbVC.tableView reloadData];
  [self.tbVC.refreshControl endRefreshing];
}

- (void)homeFeedModelDidRecommandUser:(NSArray *)users{
  [_recommandView refreshWithUsers:users];
  _recommandView.hidden = NO;
  _headerView.height = _recommandView.bottom;
  self.tbVC.tableView.tableHeaderView = _headerView;
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

- (void)feedRecommandDidPressMore:(SWHomeFeedRecommandView *)view{  
  SWUserListVC *vc = [[SWUserListVC alloc] init];
  vc.model.uId = [[SWConfigManager sharedInstance].user.uId stringValue];
  vc.model.title = @"推薦列表";
  vc.model.type = SWUserListAPITypeGetRecommand;
  vc.hidesBottomBarWhenPushed = YES;
  [self.navigationController pushViewController:vc animated:YES];
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
  vc.url = feedItem.feed.link.linkUrl;
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
