//
//  BRDViewController.m
//  Fhotoroom
//
//  Created by MTSS User on 10/14/14.
//  Copyright (c) 2014 Bryan Dickens. All rights reserved.
//

//static constants
static const CGFloat labelHeight = 100.0;
static const CGFloat labelYVerticalFraction = 8.0;
static const CGFloat labelSize = 48.0;
static const CGFloat arrowTimeInterval = 2.5;
static const CGFloat arrowBounds = 50.0;
static const CGFloat arrowAlpha = 0.6;
static const CGFloat arrowAnimationInterval = 1.0;
static const CGFloat minZoomScale = 1.0;
static const CGFloat maxZoomScale = 10.0;


#define verticalScrollViewTag 2
#define fhotoImageViewTag 3

#import "BRDViewController.h"
#import "BRDModel.h"

@interface BRDViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) NSTimer *arrowsTimer;
@property (nonatomic, strong) UIImageView *downArrowHolder;
@property (nonatomic, strong) UIImageView *leftArrowHolder;
@property (nonatomic, strong) UIImageView *rightArrowHolder;
@property (nonatomic, strong) UIImageView *upArrowHolder;
@property NSInteger fhotoNumber;
@property NSInteger fhotoAlbumNumber;
@property NSInteger fhotoCountForAlbum;
@property CGFloat lastScale;

@property (strong, nonatomic) UIPinchGestureRecognizer *pinchGestureRecognizer;
@property (strong, nonatomic) UIScrollView *zoomScrollView;
@property (strong, nonatomic) UIImageView *zoomImage;

@property (nonatomic, strong) BRDModel *model;

@end

@implementation BRDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self setUpView];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        _model = [BRDModel sharedInstance];
    }
    
    return self;
}

#pragma mark - Set Up View Methods
-(void)setUpView
{
    [self setUpScrollView];
    [self setUpNavigationArrows];
}

-(void)setUpScrollView
{
    self.scrollView.delegate = self;
    
    NSInteger fhotoAlbumCount = [self.model fhotoAlbumCount];
    CGSize scrollSize = self.scrollView.bounds.size;
    
    //set the correct scrollview size
    CGSize newContentSize = CGSizeMake(scrollSize.width*fhotoAlbumCount, scrollSize.height);
    self.scrollView.contentSize = newContentSize;
    self.scrollView.pagingEnabled = YES;
    
    [self setUpFhotoAlbums];
}

-(void)setUpFhotoAlbums
{
    for (int i=0; i<[self.model fhotoAlbumCount]; i++)
    {
        CGSize viewSize = self.scrollView.bounds.size;
        
        //create the individual page view + center
        UIView *pageView = [[UIView alloc] initWithFrame:self.scrollView.bounds];
        pageView.center = CGPointMake(viewSize.width*(i+0.5), viewSize.height/2.0);
        
        //add the vertical scroll view to pageview
        UIScrollView *verticalView = [self setUpFhotosInFhotoAlbum:i];
        [pageView addSubview:verticalView];
        
        //add pageview to main scroll view
        [self.scrollView addSubview:pageView];
        
    }
}

-(UIScrollView*)setUpFhotosInFhotoAlbum:(NSInteger)albumIndex
{
    //create a vertical scroll view
    NSInteger fhotosCountInAlbum = [self.model fhotoCountForAlbum:albumIndex];
    CGRect verticalFrame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
    UIScrollView *verticalScrollView = [[UIScrollView alloc] initWithFrame:verticalFrame];
    
    //set properties for vertical scroll view of fhoto albums
    CGSize fhotoAlbumSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height * fhotosCountInAlbum);
    verticalScrollView.contentSize = fhotoAlbumSize;
    verticalScrollView.delegate = self;
    verticalScrollView.pagingEnabled = YES;
    verticalScrollView.tag = verticalScrollViewTag;
    
    //for loop to add all the pictures
    for (int i=0; i<fhotosCountInAlbum; i++)
    {
        //create fhoto + imageview
        CGRect fhotoFrame = CGRectMake(0.0, i*self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        UIView *fhotoPageView = [[UIView alloc] initWithFrame:fhotoFrame];
        UIImage *fhoto = [self.model imageAt:i forAlbum:albumIndex];
        
        
        UIImageView *fhotoImageView = [self createImageViewFromImage:fhoto];
        
        //center the fhoto
        [self centerScrollViewContents:(UIScrollView *)verticalScrollView withView:(UIView *)fhotoImageView];
        
        //set pinch recognizer to the image view
        fhotoImageView.userInteractionEnabled = YES;
        _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchWithGestureRecognizer:)];
        [fhotoImageView addGestureRecognizer:_pinchGestureRecognizer];
        
        //set background image of that page
        [fhotoPageView addSubview:fhotoImageView];
        
        //add to main scroll view
        [verticalScrollView addSubview:fhotoPageView];
    }
    
    //finally add fhoto album label
    UILabel *fhotoAlbumLabel = [self setUpLabelForFhotoAlbum:albumIndex];
    [verticalScrollView addSubview:fhotoAlbumLabel];
    
   return verticalScrollView;
}

-(UIImageView*)createImageViewFromImage:(UIImage*)fhoto
{
    UIImageView *fhotoImageView = [[UIImageView alloc] initWithImage:fhoto];
    
    //set frame to be within bounds
    CGFloat fhotoWidth = fhoto.size.width > self.view.frame.size.width ? self.view.frame.size.width: fhoto.size.width;
    CGFloat fhotoHeight = fhoto.size.height > self.view.frame.size.height ? self.view.frame.size.height: fhoto.size.height;
    fhotoImageView.frame = CGRectMake(0.0, 0.0,fhotoWidth, fhotoHeight);
    
    return fhotoImageView;
}

-(UILabel*)setUpLabelForFhotoAlbum:(NSInteger)albumIndex
{
    //create label
    CGRect parkNameLabelFrame = CGRectMake(0.0, self.view.frame.size.height/labelYVerticalFraction, self.view.frame.size.width, labelHeight);
    UILabel *parkNameLabel = [[UILabel alloc] initWithFrame:parkNameLabelFrame];
    
    //set label's properties
    parkNameLabel.text = [self.model parkNameForAlbum:albumIndex];
    parkNameLabel.textAlignment = NSTextAlignmentCenter;
    parkNameLabel.textColor = [UIColor purpleColor];
    [parkNameLabel setFont:[UIFont boldSystemFontOfSize:labelSize]];
    
    return parkNameLabel;
}

-(void)setUpNavigationArrows
{
    //create the arrow images
    UIImage *downArrow = [UIImage imageNamed:@"arrowDown.png"];
    UIImage *leftArrow = [UIImage imageNamed:@"arrowLeft.png"];
    UIImage *rightArrow = [UIImage imageNamed:@"arrowRight.png"];
    UIImage *upArrow = [UIImage imageNamed:@"arrowUp.png"];
    
    //create imageviews for the images
    _downArrowHolder = [[UIImageView alloc] initWithImage:downArrow];
    _leftArrowHolder = [[UIImageView alloc] initWithImage:leftArrow];
    _rightArrowHolder = [[UIImageView alloc] initWithImage:rightArrow];
    _upArrowHolder = [[UIImageView alloc] initWithImage:upArrow];
    
    //set the center for the image views
    _downArrowHolder.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - arrowBounds);
    _leftArrowHolder.center = CGPointMake(arrowBounds, self.view.frame.size.height/2);
    _rightArrowHolder.center = CGPointMake(self.view.frame.size.width - arrowBounds, self.view.frame.size.height/2);
    _upArrowHolder.center = CGPointMake(self.view.frame.size.width/2,  arrowBounds);
    
    //set the alpha for the image views
    _downArrowHolder.alpha = arrowAlpha;
    _leftArrowHolder.alpha = arrowAlpha;
    _rightArrowHolder.alpha = arrowAlpha;
    _upArrowHolder.alpha = arrowAlpha;
    
    //set initial arrow alphas
    [self updateArrowAlphas];
    [self startArrowsTimer];
    
    //add imageviews to the main view
    [self.view addSubview:_downArrowHolder];
    [self.view addSubview:_leftArrowHolder];
    [self.view addSubview:_rightArrowHolder];
    [self.view addSubview:_upArrowHolder];
    
}

#pragma mark - Gesture Handler Methods
-(void)handlePinchWithGestureRecognizer:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    if(pinchGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        
        //create zoom scroll view
        CGRect zoomFrame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
        _zoomScrollView = [[UIScrollView alloc] initWithFrame:zoomFrame];
        
        //set zoom scroll view properties
        CGSize fhotoAlbumSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
        _zoomScrollView.contentSize = fhotoAlbumSize;
        _zoomScrollView.delegate = self;
        _zoomScrollView.minimumZoomScale=minZoomScale;
        _zoomScrollView.maximumZoomScale=maxZoomScale;
        
        //get the fhotoImageView for this scroll view
        UIImage *fhoto = [self.model imageAt:_fhotoNumber forAlbum:_fhotoAlbumNumber];
        UIImageView *fhotoImageView = [self createImageViewFromImage:fhoto];
        fhotoImageView.tag = fhotoImageViewTag;

        //center the fhoto in scroll view
        [self centerScrollViewContents:(UIScrollView *)_zoomScrollView withView:(UIView *)fhotoImageView];
        
        //hide the regular screen
        _scrollView.hidden = YES;
        [self toggleArrowsVisibility];
        
        [_zoomScrollView addSubview:fhotoImageView];
        [self.view addSubview:_zoomScrollView];
    }
    
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        _zoomScrollView.zoomScale = pinchGestureRecognizer.scale;
    }

}

#pragma mark - ScrollView Methods
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


-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    //this method enables the zooming of the imageview by returning the imageview
    UIView *selectedView;
    NSArray *subviews = scrollView.subviews;
    for(UIView *subview in subviews)
    {
        if(subview.tag == fhotoImageViewTag)
            selectedView = subview;
    }
    return selectedView;
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    //scrollView.contentSize = view.frame.size;
    //delete the zoomscrollview if scale = minZoomScale
    if(scale == minZoomScale)
    {
        for(UIView *subview in _zoomScrollView.subviews)
        {
            [subview removeFromSuperview];
        }
        
        [_zoomScrollView removeFromSuperview];
        
        //toggle back the regular screen
        _scrollView.hidden = NO;
        [self toggleArrowsVisibility];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so you need to re-center the contents of the fhoto
    UIView *fhotoView;
    NSArray *subviews = scrollView.subviews;
    for(UIView *subview in subviews)
    {
        if(subview.tag == fhotoImageViewTag)
            fhotoView = subview;
    }
    [self centerScrollViewContents:scrollView withView:fhotoView];
}

-(void)updateScrollViewData:(UIScrollView *)scrollView
{
    if(scrollView == self.scrollView)
    {
        //if on the main scroll view get the horizontal offset and album #
        CGPoint horizontalOffset = scrollView.contentOffset;
        _fhotoAlbumNumber = horizontalOffset.x / self.view.bounds.size.width;
    }
    else if(scrollView.tag == verticalScrollViewTag)
    {
        //if on the vertical scroll view get the vertical offset and fhotos
        CGPoint verticalOffset = scrollView.contentOffset;
        _fhotoNumber = verticalOffset.y / self.view.bounds.size.height;
        _fhotoCountForAlbum = [self.model fhotoCountForAlbum:_fhotoAlbumNumber] - 1;
    }
    
    [self updateArrowAlphas];
    [self startArrowsTimer];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //first point to grab the user's touch
    [self updateScrollViewData:scrollView];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //last point to hand off the user's touch
    [self updateScrollViewData:scrollView];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //vertical scrollview being used
    if(scrollView.tag == verticalScrollViewTag)
    {
        //if not on the first page disable the horizontal main scroll view
        if(_fhotoNumber != 0)
        {
            self.scrollView.scrollEnabled = NO;
        }
        else
        {
            self.scrollView.scrollEnabled = YES;
        }
    }
}

#pragma mark - Navigation Arrows Methods
-(void)animateArrows:(UITapGestureRecognizer*)recognizer
{
    recognizer.enabled = NO;
    
    [UIView animateWithDuration:arrowAnimationInterval animations:^
    {
        _leftArrowHolder.alpha = 0.0;
        _upArrowHolder.alpha = 0.0;
        _rightArrowHolder.alpha = 0.0;
        _downArrowHolder.alpha = 0.0;
        
    } completion:^(BOOL finished)
    {
        recognizer.enabled = YES;
        [self startArrowsTimer];
    }];

}

-(void)startArrowsTimer
{
    _arrowsTimer = [NSTimer scheduledTimerWithTimeInterval:arrowTimeInterval target:self selector:@selector(arrowTimerFired:) userInfo:nil repeats:NO];
}

-(void)arrowTimerFired:(NSTimer*)timer
{
    [self animateArrows:nil];
}

-(void)toggleArrowsVisibility
{
    _leftArrowHolder.hidden = !_leftArrowHolder.hidden;
    _rightArrowHolder.hidden = !_rightArrowHolder.hidden;
    _downArrowHolder.hidden = !_downArrowHolder.hidden;
    _upArrowHolder.hidden = !_upArrowHolder.hidden;
}

-(void)updateArrowAlphas
{
    if(_fhotoNumber == 0)
    {
        //if on the first row disable up arrow
        _upArrowHolder.alpha = 0.0;
        
        //if more than one image enable down arrow
        if([self.model fhotoAlbumCount] > 1)
        {
            _downArrowHolder.alpha = arrowAlpha;
        }
        else
        {
            _downArrowHolder.alpha = 0.0;
        }
        
        //if far left album disable left arrow, if far right album disable right arrow
        if(_fhotoAlbumNumber == 0)
        {
            _leftArrowHolder.alpha = 0.0;
            _rightArrowHolder.alpha = arrowAlpha;
        }
        else if(_fhotoAlbumNumber == ([self.model fhotoAlbumCount] - 1))
        {
            _rightArrowHolder.alpha = 0.0;
            _leftArrowHolder.alpha = arrowAlpha;
        }
        else
        {
            _leftArrowHolder.alpha = arrowAlpha;
            _rightArrowHolder.alpha = arrowAlpha;
        }
    }
    else
    {
        //if not on the first row disable left and right arrows and enable up arrow
        _leftArrowHolder.alpha = 0.0;
        _rightArrowHolder.alpha = 0.0;
        _upArrowHolder.alpha = arrowAlpha;
        
        //if on the last image disable down arrow
        if(_fhotoNumber == _fhotoCountForAlbum)
        {
            _downArrowHolder.alpha = 0.0;
        }
        else
        {
            _downArrowHolder.alpha = arrowAlpha;
        }
    }
}

@end
