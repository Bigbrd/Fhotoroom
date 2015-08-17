//
//  BRDFhotoZoomViewController.m
//  Fhotoroom
//
//  Created by MTSS User on 10/29/14.
//  Copyright (c) 2014 Bryan Dickens. All rights reserved.
//

#import "BRDFhotoZoomViewController.h"
#import "UIScrollView+ZoomScrollView.h"
static const CGFloat minZoomScale = 1.0;
static const CGFloat maxZoomScale = 10.0;

@interface BRDFhotoZoomViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *fhotoImageView;

@end

@implementation BRDFhotoZoomViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setUpScrollView];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //get the new size for the image
    CGSize size = [self.scrollView imageSizeAspectFit:self.scrollView withImage:self.fhoto];
    
    //set frame and contentSize
    _fhotoImageView.frame = CGRectMake(0, 0, size.width, size.height);
    self.scrollView.contentSize = size;
    
    //center the image
    [self.scrollView centerScrollViewContents:self.scrollView  withView:_fhotoImageView];

}

-(void)setUpScrollView
{
    self.scrollView.delegate = self;    
    
    //image view create
    _fhotoImageView = [[UIImageView alloc] initWithImage:self.fhoto];
    
    //manually set aspect fit
    CGSize size = [self.scrollView imageSizeAspectFit:self.scrollView withImage:self.fhoto];
    _fhotoImageView.frame = CGRectMake(0, 0, size.width, size.height);
    
    //add the fhoto
    [self.scrollView addSubview:_fhotoImageView];
    
    //set the correct scrollview size and center
    self.scrollView.contentSize = size;
    [self.scrollView centerScrollViewContents:self.scrollView  withView:_fhotoImageView];
    
    //set scrollview properties
    self.scrollView.minimumZoomScale = minZoomScale;
    self.scrollView.maximumZoomScale = maxZoomScale;
}

#pragma mark - ScrollView Methods

-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.fhotoImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    // The scroll view has zoomed, so you need to re-center the contents of the fhoto
    [scrollView centerScrollViewContents:scrollView withView:_fhotoImageView];
}

@end
