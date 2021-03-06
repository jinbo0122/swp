//
//  SWFeedItem.m
//  SeeWorld
//
//  Created by Albert Lee on 8/31/15.
//  Copyright (c) 2015 SeeWorld. All rights reserved.
//

#import "SWFeedItem.h"
#import "SWMineVC.h"
@implementation SWFeedItem
+ (SWFeedItem *)feedItemByDic:(NSDictionary *)feedDic{
  SWFeedItem *feed = [[SWFeedItem alloc] init];
  feed.likeCount = [feedDic safeNumberObjectForKey:@"likeCount"];
  feed.commentCount = [feedDic safeNumberObjectForKey:@"commentCount"];
  if ([[feedDic safeStringObjectForKey:@"isLiked"] boolValue]||
      [[feedDic safeNumberObjectForKey:@"isLiked"] boolValue]) {
    feed.isLiked = @1;
  }else{
    feed.isLiked = @0;
  }
  
  NSDictionary *feedInfoDic = [feedDic safeDicObjectForKey:@"feed"];
  feed.feed = [SWFeedInfoItem feedInfoItemByDic:feedInfoDic];
  
  
  NSDictionary *feedUserDic = [feedDic safeDicObjectForKey:@"user"];
  feed.user = [SWFeedUserItem feedUserItemByDic:feedUserDic];
  
  NSArray *likesArray = [feedDic safeArrayObjectForKey:@"likes"];
  feed.likes = [NSMutableArray array];
  for (NSInteger j=0; j<[likesArray count]; j++) {
    NSDictionary *likeDic = [likesArray safeDicObjectAtIndex:j];
    [feed.likes addObject:[SWFeedLikeItem feedLikeItem:likeDic]];
  }
  
  NSArray *commentArray = [feedDic safeArrayObjectForKey:@"comments"];
  feed.comments = [NSMutableArray array];
  for (NSInteger j=0; j<[commentArray count]; j++) {
    NSDictionary *commentDic = [commentArray safeDicObjectAtIndex:j];
    [feed.comments addObject:[SWFeedCommentItem feedCommentItem:commentDic]];
  }
  
  return feed;
}
@end

@implementation SWFeedInfoItem
+ (SWFeedInfoItem *)feedInfoItemByDic:(NSDictionary *)feedInfoDic{
  SWFeedInfoItem *feed = [[SWFeedInfoItem alloc] init];
  feed.fId = [feedInfoDic safeNumberObjectForKey:@"id"];
  feed.type = [[feedInfoDic safeNumberObjectForKey:@"type"] integerValue];
  feed.content = [feedInfoDic safeStringObjectForKey:@"description"];
  feed.time = [feedInfoDic safeNumberObjectForKey:@"time"];
  if (feed.type == SWFeedTypeImage) {
    feed.photos = [SWFeedImageItem feedImagesByPhotos:[feedInfoDic safeStringObjectForKey:@"photo"]
                                                 tags:[feedInfoDic safeArrayObjectForKey:@"tags"]];
  }else if (feed.type == SWFeedTypeVideo){
    feed.photos = [SWFeedImageItem feedImagesByPhotos:[feedInfoDic safeStringObjectForKey:@"photo"]
                                                 tags:[feedInfoDic safeArrayObjectForKey:@"tags"]];
    feed.videoUrl = [feedInfoDic safeStringObjectForKey:@"video"];
  }else if (feed.type == SWFeedTypeLink){
    feed.link = [SWFeedLinkItem feedLinkItem:[feedInfoDic safeStringObjectForKey:@"link"]];
  }
  feed.location = [feedInfoDic safeStringObjectForKey:@"location"];
  return feed;
}

- (SWFeedInfoItem *)copy{
  SWFeedInfoItem *feed = [[SWFeedInfoItem alloc] init];
  feed.fId = [self.fId copy];
  feed.type = self.type;
  feed.content = [self.content copy];
  feed.time = [self.time copy];
  if (self.type == SWFeedTypeImage) {
    feed.photos = [NSMutableArray array];
    for (NSInteger i=0; i<self.photos.count; i++) {
      SWFeedImageItem *photoItem = [self.photos safeObjectAtIndex:i];
      [feed.photos addObject:[photoItem copy]];
    }
  }else if (self.type == SWFeedTypeVideo){
    feed.photos = [NSMutableArray array];
    for (NSInteger i=0; i<self.photos.count; i++) {
      SWFeedImageItem *photoItem = [self.photos safeObjectAtIndex:i];
      [feed.photos addObject:[photoItem copy]];
    }
    feed.videoUrl = [self.videoUrl copy];
  }else if (self.type == SWFeedTypeLink){
    feed.link = [self.link copy];
  }
  feed.location = [self.location copy];
  return feed;
}

- (NSString *)firstPicUrl{
  SWFeedImageItem *imageItem = [self.photos safeObjectAtIndex:0];
  if ([imageItem isKindOfClass:[SWFeedImageItem class]]) {
    return imageItem.picUrl;
  }
  return @"";
}
- (NSArray *)photoUrls{
  return [self photoUrlsWithSuffix:@""];
}

- (NSArray *)photoUrlsWithSuffix:(NSString *)suffix{
  NSMutableArray *photoUrls = [NSMutableArray array];
  for (SWFeedImageItem *item in self.photos) {
    [photoUrls safeAddObject:[item.picUrl stringByAppendingString:suffix]];
  }
  return photoUrls;
}
@end

@implementation SWFeedImageItem
+ (NSMutableArray *)feedImagesByPhotos:(NSString *)photoJson tags:(NSArray *)tags{
  NSArray *photos = [photoJson safeArrayFromJsonString];
  NSMutableArray *images = [NSMutableArray array];
  for (NSInteger i=0; i<photos.count; i++) {
    SWFeedImageItem *imageItem = [[SWFeedImageItem alloc] init];
    imageItem.index = i;
    NSDictionary *info = [photos safeDicObjectAtIndex:i];
    imageItem.picUrl = [info safeStringObjectForKey:@"src"];
    imageItem.width = [[info safeNumberObjectForKey:@"width"] floatValue];
    imageItem.height = [[info safeNumberObjectForKey:@"height"] floatValue];
    imageItem.tags = [NSMutableArray array];
    [images addObject:imageItem];
  }
  
  for (NSDictionary *tagInfo in tags) {
    NSInteger index = [[tagInfo safeNumberObjectForKey:@"imageId"] integerValue];
    for (SWFeedImageItem *photoItem in images) {
      if (photoItem.index == index) {
        [photoItem.tags addObject:[SWFeedTagItem feedTagItemByDic:tagInfo]];
      }
    }
  }
  
  return images;
}

- (SWFeedImageItem *)copy{
  SWFeedImageItem *imageItem = [[SWFeedImageItem alloc] init];
  imageItem.picUrl = [self.picUrl copy];
  imageItem.width = self.width;
  imageItem.height = self.height;
  imageItem.index = self.index;
  imageItem.tags = [NSMutableArray array];
  for (NSInteger j=0; j<[self.tags count]; j++) {
    SWFeedTagItem *tag = [self.tags safeObjectAtIndex:j];
    [imageItem.tags safeAddObject:[tag copy]];
  }
  return imageItem;
}
@end

@implementation SWFeedLinkItem
+ (SWFeedLinkItem *)feedLinkItem:(NSString *)linkJson{
  NSDictionary *linkInfo = [linkJson safeJsonDicFromJsonString];
  SWFeedLinkItem *link = [[SWFeedLinkItem alloc] init];
  link.linkUrl = [linkInfo safeStringObjectForKey:@"link"];
  link.title = [linkInfo safeStringObjectForKey:@"title"];
  link.imageUrl = [linkInfo safeStringObjectForKey:@"image"];
  return link;
}

- (SWFeedLinkItem *)copy{
  SWFeedLinkItem *link = [[SWFeedLinkItem alloc] init];
  link.linkUrl = [self.linkUrl copy];
  link.title = [self.title copy];
  link.imageUrl = [self.imageUrl copy];
  return link;

}
@end



@implementation SWFeedCommentItem
+ (SWFeedCommentItem *)feedCommentItem:(NSDictionary *)feedCommentDic{
  SWFeedCommentItem *commentItem = [[SWFeedCommentItem alloc] init];
  commentItem.time = [feedCommentDic safeNumberObjectForKey:@"time"];
  commentItem.commentId = [feedCommentDic safeNumberObjectForKey:@"id"];
  commentItem.text = [feedCommentDic safeStringObjectForKey:@"text"];
  commentItem.user = [SWFeedUserItem feedUserItemByDic:[feedCommentDic safeDicObjectForKey:@"user"]];
  return commentItem;
}
@end

@implementation SWFeedLikeItem
+ (SWFeedLikeItem *)feedLikeItem:(NSDictionary *)feedLikeDic{
  SWFeedLikeItem *likeItem = [[SWFeedLikeItem alloc] init];
  likeItem.time = [feedLikeDic safeNumberObjectForKey:@"time"];
  likeItem.user = [SWFeedUserItem feedUserItemByDic:[feedLikeDic safeDicObjectForKey:@"user"]];
  return likeItem;
}
@end

@implementation SWFeedUserItem
+ (SWFeedUserItem *)feedUserItemByDic:(NSDictionary *)feedUserDic{
  SWFeedUserItem *user = [[SWFeedUserItem alloc] init];
  user.uId = [feedUserDic safeNumberObjectForKey:@"id"];
  user.name = [feedUserDic safeStringObjectForKey:@"name"];
  user.picUrl = [feedUserDic safeStringObjectForKey:@"head"];
  user.intro = [feedUserDic safeStringObjectForKey:@"description"];
  user.gender = [feedUserDic safeNumberObjectForKey:@"gender"];
  user.relation = [feedUserDic safeNumberObjectForKey:@"relation"];
  user.feedCount = [feedUserDic safeNumberObjectForKey:@"feedCount"];
  user.followerCount = [feedUserDic safeNumberObjectForKey:@"followerCount"];
  user.followedCount = [feedUserDic safeNumberObjectForKey:@"followedCount"];
  user.bghead = [feedUserDic safeStringObjectForKey:@"bghead"];
  user.issecret = [feedUserDic safeNumberObjectForKey:@"issecret"];
  user.admin = [feedUserDic safeNumberObjectForKey:@"admin"];
  return user;
}

+ (SWFeedUserItem *)feedUserItemBySelfDic:(NSDictionary *)feedUserDic{
  SWFeedUserItem *user = [[SWFeedUserItem alloc] init];
  user.uId = [feedUserDic safeNumberObjectForKey:@"uId"];
  user.name = [feedUserDic safeStringObjectForKey:@"name"];
  user.picUrl = [feedUserDic safeStringObjectForKey:@"picUrl"];
  user.intro = [feedUserDic safeStringObjectForKey:@"intro"];
  user.gender = [feedUserDic safeNumberObjectForKey:@"gender"];
  user.relation = [feedUserDic safeNumberObjectForKey:@"relation"];
  user.feedCount = [feedUserDic safeNumberObjectForKey:@"feedCount"];
  user.followerCount = [feedUserDic safeNumberObjectForKey:@"followerCount"];
  user.followedCount = [feedUserDic safeNumberObjectForKey:@"followedCount"];
  user.bghead = [feedUserDic safeStringObjectForKey:@"bghead"];
  user.issecret = [feedUserDic safeNumberObjectForKey:@"issecret"];
  user.admin = [feedUserDic safeNumberObjectForKey:@"admin"];
  return user;
}

- (SWFeedUserItem *)copy{
  SWFeedUserItem *user = [[SWFeedUserItem alloc] init];
  user.uId = [self.uId copy];
  user.name = [self.name copy];
  user.picUrl = [self.picUrl copy];
  user.intro = [self.intro copy];
  user.gender = [self.gender copy];
  user.relation = [self.relation copy];
  user.feedCount = [self.feedCount copy];
  user.followedCount = [self.followedCount copy];
  user.followerCount = [self.followerCount copy];
  user.bghead = [self.bghead copy];
  user.issecret = [self.issecret copy];
  user.admin = [self.admin copy];
  return user;
}

+ (SWFeedUserItem *)myself{
//  SWFeedUserItem *user = [[SWFeedUserItem alloc] init];
//  user.uId = [[[NSUserDefaults standardUserDefaults] safeStringObjectForKey:@"userId"] numberValue];
//  user.name = [[NSUserDefaults standardUserDefaults] safeStringObjectForKey:@"userName"];
//  user.picUrl = [[NSUserDefaults standardUserDefaults] safeStringObjectForKey:@"userPicUrl"];
//  user.intro = [[NSUserDefaults standardUserDefaults] safeStringObjectForKey:@"userDescription"];
//  user.gender = [[NSUserDefaults standardUserDefaults] safeNumberObjectForKey:@"userGender"];
//  user.relation = [NSNumber numberWithInteger:SWUserRelationTypeSelf];
//  user.feedCount = @0;
  return [SWConfigManager sharedInstance].user;
}

+ (void)pushUserVC:(SWFeedUserItem *)user nav:(UINavigationController *)nav{
  [nav setNavigationBarHidden:NO];

  SWMineVC *vc = [[SWMineVC alloc] init];
  vc.user = user;
  vc.hidesBottomBarWhenPushed = YES;
  [nav pushViewController:vc animated:YES];
  
}

- (NSDictionary *)vcDicValue{
  return @{@"id":self.uId?self.uId:@0,
           @"name":self.name?self.name:@"",
           @"head":self.picUrl?self.picUrl:@"",
           @"description":self.intro?self.intro:@"",
           @"gender":self.gender?self.gender:@0,
           @"relation":self.relation?self.relation:@0,
           @"feedCount":self.feedCount?self.feedCount:@0,
           @"followedCount":self.followedCount?self.followedCount:@0,
           @"followerCount":self.followerCount?self.followerCount:@0,
           @"bghead":self.bghead?self.bghead:@"",
           @"issecret":self.issecret?self.issecret:@"",
           @"admin":self.admin?self.admin:@""};
}

- (NSDictionary *)dicValue{
  return @{@"uId":self.uId?self.uId:@0,
           @"name":self.name?self.name:@"",
           @"picUrl":self.picUrl?self.picUrl:@"",
           @"head":self.picUrl?self.picUrl:@"",
           @"intro":self.intro?self.intro:@"",
           @"gender":self.gender?self.gender:@0,
           @"relation":self.relation?self.relation:@0,
           @"feedCount":self.feedCount?self.feedCount:@0,
           @"followedCount":self.followedCount?self.followedCount:@0,
           @"followerCount":self.followerCount?self.followerCount:@0,
           @"bghead":self.bghead?self.bghead:@"",
           @"issecret":self.issecret?self.issecret:@"",
           @"admin":self.admin?self.admin:@""};
}
@end

@implementation SWFeedTagItem
+ (SWFeedTagItem *)feedTagItemByDic:(NSDictionary *)tagDic{
  SWFeedTagItem *tagItem = [[SWFeedTagItem alloc] init];
  tagItem.tagId = [tagDic safeNumberObjectForKey:@"tagId"];
  tagItem.tagName = [tagDic safeStringObjectForKey:@"tagName"];
  tagItem.direction = [tagDic safeNumberObjectForKey:@"direction"];
  tagItem.coord = [SWFeedTagCoordItem feedTagCoordItemByDic:[tagDic safeDicObjectForKey:@"coord"]];
  return tagItem;
}

- (SWFeedTagItem *)copy{
  SWFeedTagItem *tagItem = [[SWFeedTagItem alloc] init];
  tagItem.tagId = [self.tagId copy];
  tagItem.tagName = [self.tagName copy];
  tagItem.direction = [self.direction copy];
  tagItem.coord = [self.coord copy];
  return tagItem;
}
@end

@implementation SWTagItem
+ (SWTagItem *)tagItemByDic:(NSDictionary *)tagDic{
  SWTagItem *tagItem = [[SWTagItem alloc] init];
  tagItem.tagId = [tagDic safeNumberObjectForKey:@"id"];
  tagItem.tagName = [tagDic safeStringObjectForKey:@"name"];
  tagItem.tagCount = [tagDic safeNumberObjectForKey:@"count"];
  return tagItem;
}
@end

@implementation SWFeedTagCoordItem
+ (SWFeedTagCoordItem *)feedTagCoordItemByDic:(NSDictionary *)coordDic{
  SWFeedTagCoordItem *coord = [[SWFeedTagCoordItem alloc] init];
  coord.x = [coordDic safeNumberObjectForKey:@"x"];
  coord.y = [coordDic safeNumberObjectForKey:@"y"];
  coord.w = [coordDic safeNumberObjectForKey:@"w"];
  coord.h = [coordDic safeNumberObjectForKey:@"h"];
  return coord;
}

- (SWFeedTagCoordItem *)copy{
  SWFeedTagCoordItem *coord = [[SWFeedTagCoordItem alloc] init];
  coord.x = [self.x copy];
  coord.y = [self.y copy];
  coord.w = [self.w copy];
  coord.h = [self.h copy];
  return coord;
}
@end
