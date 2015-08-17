//
//  BRDCollectionViewController.m
//  Fhotoroom
//
//  Created by MTSS User on 10/23/14.
//  Copyright (c) 2014 Bryan Dickens. All rights reserved.
//

static const CGFloat cellWidth = 100.0;
static const CGFloat cellHeight = 90.0;
static const CGFloat cellSpacing = 5.0;
static const CGFloat cellSectionSpacing = 10.0;

#define fhotoImageViewTag 1

#import "BRDCollectionViewController.h"
#import "BRDModel.h"
#import "BRDCollectionViewCell.h"
#import "BRDHeaderCollectionReusableView.h"
#import "UIScrollView+ZoomScrollView.h"
#import "BRDDetailViewController.h"

@interface BRDCollectionViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) BRDModel *model;
@property (strong, nonatomic) UIScrollView *zoomScrollView;
@property (strong, nonatomic) UICollectionView *collectionMainView;

@property UITapGestureRecognizer *singleTapGestureRecognizer;
@property CGRect initialImageFrame;
@property BRDDetailViewController *detailViewController;
@property BRDCollectionViewCell *cell;


@end

@implementation BRDCollectionViewController

//initializes the decoder model
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _model = [BRDModel sharedInstance];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.collectionView reloadData];
}

#pragma mark - Collection View Layout Protocol
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //set size of the cell
    return CGSizeMake(cellWidth, cellHeight);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    //set spacing between items in section
    return cellSpacing;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    //set spacing for sections
    return cellSectionSpacing;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //set edges for section
    return UIEdgeInsetsMake(cellSectionSpacing*2, cellSectionSpacing/2, cellSectionSpacing*2, cellSectionSpacing/2);
}

#pragma mark - Collection View Data Source
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //return the number of collection view sections which is the number of fhoto albums
    return [self.model fhotoAlbumCount];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //return the number of cells in the section which is the number of fhotos in the album
    return [self.model fhotoCountForAlbum:section];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //return the cell at each index path. we want the image to be set to the cell
    static NSString *cellIdentifier = @"CollectionCell";
    BRDCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    //get image and place in the cell
    UIImage *image = [self.model imageAt:indexPath.row forAlbum:indexPath.section];
    cell.cellFhoto.image = image;
    
    return cell;
}

-(UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView = nil;
    
    //set the header
    if (kind == UICollectionElementKindSectionHeader)
    {
        BRDHeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderCollectionView" forIndexPath:indexPath];
        NSString *parkTitle = [self.model parkNameForAlbum:indexPath.section];
        
        //set the header properties
        headerView.parkTitleLabel.text = parkTitle;
        headerView.parkTitleLabel.textColor = [UIColor whiteColor];
        headerView.backgroundColor = [UIColor blackColor];
        
        reusableView = headerView;
    }
    
    return reusableView;
}

#pragma mark - Collection View Delegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"iPhoneToDetailSegue"])
    {
        BRDDetailViewController *detailViewController = segue.destinationViewController;
        
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
       
        
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
       
        UIImage *fhoto = [self.model imageAt:indexPath.row forAlbum:indexPath.section];
        NSString *caption = [self.model captionForImageAt:indexPath.row forAlbum:indexPath.section];
        NSString *albumTitle = [self.model parkNameForAlbum:indexPath.section];
        
        detailViewController.fhotoImage = fhoto;
        detailViewController.captionLabelText = caption;
        detailViewController.title = albumTitle;
        
    }
}


@end
