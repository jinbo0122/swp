//
//  AVAsset+VideoOrientation.h
//  pandora
//
//  Created by Albert Lee on 31/10/2016.
//  Copyright © 2016 Albert Lee. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

typedef enum {
  LBVideoOrientationUp,               //Device starts recording in Portrait
  LBVideoOrientationDown,             //Device starts recording in Portrait upside down
  LBVideoOrientationLeft,             //Device Landscape Left  (home button on the left side)
  LBVideoOrientationRight,            //Device Landscape Right (home button on the Right side)
  LBVideoOrientationNotFound = 99     //An Error occurred or AVAsset doesn't contains video track
} LBVideoOrientation;

@interface AVAsset (VideoOrientation)

/**
 Returns a LBVideoOrientation that is the orientation
 of the iPhone / iPad whent starst recording
 
 @return A LBVideoOrientation that is the orientation of the video
 */
@property (nonatomic, readonly) LBVideoOrientation videoOrientation;

@end
