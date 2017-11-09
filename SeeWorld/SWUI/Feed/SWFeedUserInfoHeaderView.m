//
//  SWFeedUserInfoHeaderView.m
//  SeeWorld
//
//  Created by Albert Lee on 8/31/15.
//  Copyright (c) 2015 SeeWorld. All rights reserved.
//

#import "SWFeedUserInfoHeaderView.h"

@implementation SWFeedUserInfoHeaderView{
  UIImageView *_iconAvatar;
  UILabel     *_lblName;
  UILabel     *_lblTime;
}
- (id)initWithFrame:(CGRect)frame{
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor colorWithRGBHex:0xffffff];
    
    _iconAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 35, 35)];
    _iconAvatar.layer.masksToBounds = YES;
    _iconAvatar.layer.cornerRadius  = _iconAvatar.width/2.0;
    [self addSubview:_iconAvatar];
    
    _lblName    = [UILabel initWithFrame:CGRectZero
                                 bgColor:[UIColor clearColor]
                               textColor:[UIColor colorWithRGBHex:0x191d28]
                                    text:@""
                           textAlignment:NSTextAlignmentLeft
                                    font:[UIFont systemFontOfSize:16.2]];
    [self addSubview:_lblName];
    
    _lblTime    = [UILabel initWithFrame:CGRectZero
                                 bgColor:[UIColor clearColor]
                               textColor:[UIColor colorWithRGBHex:0x8A9BAC]
                                    text:@""
                           textAlignment:NSTextAlignmentLeft
                                    font:[UIFont systemFontOfSize:13]];
    [self addSubview:_lblTime];
  }
  return self;
}


- (void)refresshWithFeed:(SWFeedItem *)feedItem{
  [_iconAvatar sd_setImageWithURL:[NSURL URLWithString:[feedItem.user.picUrl stringByAppendingString:@"-avatar120"]]
                 placeholderImage:nil];
  _lblTime.text = [NSString time:[feedItem.feed.time doubleValue] format:MHPrettyDateShortRelativeTime];
  CGSize timeSize = [_lblTime.text sizeWithAttributes:@{NSFontAttributeName:_lblTime.font}];
  _lblTime.frame = CGRectMake(self.width-15-timeSize.width, (self.height-timeSize.height)/2.0, timeSize.width, timeSize.height);
  
  _lblName.text = feedItem.user.name;
  CGRect nameRect = [_lblName.text boundingRectWithSize:CGSizeMake(_lblName.left-10-_iconAvatar.right-10, self.height)
                                                options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                             attributes:@{NSFontAttributeName:_lblName.font}
                                                context:nil];
  _lblName.frame = CGRectMake(_iconAvatar.right+10, (self.height-CGRectGetHeight(nameRect))/2.0, CGRectGetWidth(nameRect), CGRectGetHeight(nameRect));
}
@end
