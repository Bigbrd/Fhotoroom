//
//  UIScrollView+ZoomScrollView.h
//  Fhotoroom
//
//  Created by MTSS User on 10/25/14.
//  Copyright (c) 2014 Bryan Dickens. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (ZoomScrollView)
- (UIScrollView *)createZoomScrollViewFrom: (UIScrollView *)rootView withFhoto: (UIImage *)fhoto;
- (void)centerScrollViewContents:(UIScrollView *)scrollView withView:(UIView *)view;
-(CGSize)imageSizeAspectFit:(UIScrollView*)rootView withImage:(UIImage*)fhoto;

@end
