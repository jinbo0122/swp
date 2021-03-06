
#import "SWFeedComposeAPI.h"

@implementation SWFeedComposeAPI
- (NSString *)requestUrl{
  return [NSString stringWithFormat:@"/feeds"];
}

- (YTKRequestMethod)requestMethod {
  return YTKRequestMethodPOST;
}

- (id)requestArgument{
  if (_feedType == SWFeedTypeLink) {
    return @{@"jwt":[[NSUserDefaults standardUserDefaults] safeStringObjectForKey:@"jwt"],
             @"link":_link?_link:@"",
             @"longitude":@(self.longitude),
             @"latitude":@(self.latitude),
             @"description":self.feedDescription,
             @"version":@1,
             @"photo":_photoJson?_photoJson:@"",
             @"location":_location?_location:@"",
             @"type":@(SWFeedTypeLink)};
  }else if (_feedType == SWFeedTypeText) {
    return @{@"jwt":[[NSUserDefaults standardUserDefaults] safeStringObjectForKey:@"jwt"],
             @"longitude":@(self.longitude),
             @"latitude":@(self.latitude),
             @"description":self.feedDescription,
             @"version":@1,
             @"photo":_photoJson?_photoJson:@"",
             @"location":_location?_location:@"",
             @"type":@(SWFeedTypeText)};
  }else if (_feedType == SWFeedTypeVideo){
    return @{@"jwt":[[NSUserDefaults standardUserDefaults] safeStringObjectForKey:@"jwt"],
             @"video":_videoUrl?_videoUrl:@"",
             @"photo":_photoJson?_photoJson:@"",
             @"longitude":@(self.longitude),
             @"latitude":@(self.latitude),
             @"description":self.feedDescription,
             @"version":@1,
             @"location":_location?_location:@"",
             @"type":@(SWFeedTypeVideo)};
  }else{
    return @{@"jwt":[[NSUserDefaults standardUserDefaults] safeStringObjectForKey:@"jwt"],
             @"photo":_photoJson?_photoJson:@"",
             @"longitude":@(self.longitude),
             @"latitude":@(self.latitude),
             @"description":self.feedDescription,
             @"version":@1,
             @"tags":[self.tags JSONString],
             @"location":_location?_location:@"",
             @"type":@(SWFeedTypeImage)};
  }
}
@end
