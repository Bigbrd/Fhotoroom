//
//  UIScrollView+ZoomScrollView.m
//  Fhotoroom
//
//  Created by MTSS User on 10/25/14.
//  Copyright (c) 2014 Bryan Dickens. All rights reserved.
//

static const CGFloat minZoomScale = 1.0;
static const CGFloat maxZoomScale = 10.0;
#define fhotoImageViewTag 1

#import "UIScrollView+ZoomScrollView.h"

@implementation UIScrollView (ZoomScrollView)

- (UIScrollView *)createZoomScrollViewFrom: (UIScrollView *)rootView withFhoto: (UIImage *)fhoto
{
    
    //create zoom scroll view
    CGRect zoomFrame = CGRectMake(0.0, 0.0, rootView.frame.size.width, rootView.frame.size.height);
    UIScrollView *zoomScrollView = [[UIScrollView alloc] initWithFrame:zoomFrame];
    
    //set zoom scroll view properties
    zoomScrollView.minimumZoomScale=minZoomScale;
    zoomScrollView.maximumZoomScale=maxZoomScale;
    
    //image view create
    UIImageView *fhotoImageView = [[UIImageView alloc] initWithImage:fhoto];
    fhotoImageView.tag = fhotoImageViewTag;
    
    //manually set aspect fit
    CGSize size = [self imageSizeAspectFit:rootView withImage:fhoto];
    fhotoImageView.contentMode = UIViewContentModeScaleAspectFit;

    fhotoImageView.frame = CGRectMake(0, 0, size.width, size.height);


    //center the fhoto in scroll view
    [self centerScrollViewContents:(UIScrollView *)zoomScrollView withView:(UIView *)fhotoImageView];
    
    [zoomScrollView addSubview:fhotoImageView];
    return zoomScrollView;

}

//Method centers the scrollview contents
- (void)centerScrollViewContents:(UIScrollView *)scrollView withView:(UIView *)view
{
    CGSize boundsSize = scrollView.bounds.size;
    CGRect contentsFrame = view.frame;
    
    
    if (contentsFrame.size.width < boundsSize.width)
    {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    }
    else
    {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height)
    {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    }
    else
    {
        contentsFrame.origin.y = 0.0f;
    }
    
    view.frame = contentsFrame;
    
}

-(CGSize)imageSizeAspectFit:(UIScrollView*)rootView withImage:(UIImage*)fhoto
{
    
    //manually set aspect fit
    CGFloat widthRatio = fhoto.size.width / rootView.frame.size.width;
    CGFloat heightRatio = fhoto.size.height / rootView.frame.size.height;
    CGFloat width = 0.0;
    CGFloat height = 0.0;
    if(widthRatio > heightRatio)
    {
        height = fhoto.size.height / widthRatio;
        width = rootView.frame.size.width;
    }
    else
    {
        height = rootView.frame.size.height;
        width = fhoto.size.width / heightRatio;
    }
    
    return CGSizeMake(width, height);
}


@end