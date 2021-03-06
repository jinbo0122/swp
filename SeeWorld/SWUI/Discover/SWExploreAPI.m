//
//  SWExploreAPI.m
//  SeeWorld
//
//  Created by Albert Lee on 9/13/15.
//  Copyright (c) 2015 SeeWorld. All rights reserved.
//

#import "SWExploreAPI.h"

@implementation SWExploreAPI
- (NSString *)requestUrl{
  return @"/feeds/discovery";
}

- (YTKRequestMethod)requestMethod {
  return YTKRequestMethodGET;
}

- (id)requestArgument{
  NSMutableDictionary *params = [@{@"jwt":[[NSUserDefaults standardUserDefaults] safeStringObjectForKey:@"jwt"],
                                   @"count":@20} mutableCopy];
  
  if (self.lastFeedId && [self.lastFeedId integerValue]>0) {
    [params setObject:self.lastFeedId forKey:@"lastFeedId"];
  }
  return params;
}
@end
