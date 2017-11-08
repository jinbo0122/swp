//
//  MJZoomingScrollView.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast
//

#import <UIKit/UIKit.h>

@class MJPhotoBrowser, MJPhoto, MJPhotoView;

@protocol MJPhotoViewDelegate <NSObject>
- (void)photoViewImageFinishLoad:(MJPhotoView *)photoView;
- (void)viewWillHide:(MJPhotoView *)photoView;
- (void)viewDidHided:(MJPhotoView *)photoView;
- (void)photoViewDidEndZoom:(MJPhotoView *)photoView;
@end

@interface MJPhotoView : UIScrollView <UIScrollViewDelegate>
// 图片
@property (nonatomic, strong) MJPhoto *photo;
// 代理
@property (nonatomic, weak) id<MJPhotoViewDelegate> photoViewDelegate;
@end