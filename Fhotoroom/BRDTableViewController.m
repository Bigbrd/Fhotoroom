//
//  BRDTableViewController.m
//  Fhotoroom
//
//  Created by MTSS User on 10/23/14.
//  Copyright (c) 2014 Bryan Dickens. All rights reserved.

// Assignment 8
// Grade: 4
// Why are your tab bar and nav bar not at the bottom/top of the screen on the 4" iPhone simulator?
// Collapsing/Expanding sections would look better with built-in animation provided by reload section method
//
static const CGFloat tableHeaderHeight = 40.0;
#define fhotoImageViewTag 1
#define addTitleAlertViewTag 2

#import "BRDTableViewController.h"
#import "BRDModel.h"
#import "BRDTableViewCell.h"
#import "UIScrollView+ZoomScrollView.h"
#import "BRDDetailViewController.h"
#import "BRDNewFhotoViewController.h"


@interface BRDTableViewController () <UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) BRDModel *model;
@property (strong, nonatomic) UITableView *rootView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;

@property UITapGestureRecognizer *singleTapGestureRecognizer;
@property BRDDetailViewController *detailViewController;
@property BRDNewFhotoViewController *addFhotoViewController;


- (IBAction)addBarButtonPressed:(id)sender;


@property CGRect initialImageFrame;
@property NSMutableArray *toggledSections;

@end

@implementation BRDTableViewController

//initializes the decoder model
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _model = [BRDModel sharedInstance];
    }
    return self;
}

-(void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        UINavigationController *navController = [self.splitViewController.viewControllers lastObject];
        self.detailViewController = (id)navController.topViewController;
        
        self.splitViewController.delegate =  self.detailViewController;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    [self setUpToggledSections];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UITabBarItem *item1 = self.tabBarController.tabBar.items[0];
    item1.image = [[UIImage imageNamed:@"fhotoroomIcon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]; // unselected image
    item1.selectedImage = [[UIImage imageNamed:@"fhotoroomIcon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *item2 = self.tabBarController.tabBar.items[1];
    item2.image = [[UIImage imageNamed:@"collectionIcon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]; // unselected image
    item2.selectedImage = [[UIImage imageNamed:@"collectionIcon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUpToggledSections
{
    NSInteger count = [self.model fhotoAlbumCount];
    _toggledSections = [[NSMutableArray alloc] initWithCapacity:count];
    for (int i=0; i<count; i++)
    {
        _toggledSections[i] = [NSNumber numberWithBool:TRUE];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.model fhotoAlbumCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger rowCount = 0;
    if([[_toggledSections objectAtIndex:section] isEqualToNumber:[NSNumber numberWithBool:TRUE]])
    {
        rowCount = [self.model fhotoCountForAlbum:section];
    }
    return rowCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BRDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableCellIdentifier" forIndexPath:indexPath];
    
    //set the caption title
    NSString *fhotoCaption = [self.model captionForImageAt:indexPath.row forAlbum:indexPath.section];
    cell.imageCaptionTitle.text = fhotoCaption;
    cell.imageCaptionTitle.adjustsFontSizeToFitWidth = YES;
    
    //set the image
    UIImage *image = [self.model imageAt:indexPath.row forAlbum:indexPath.section];
    cell.imageThumbnail.image = image;
    
    return cell;
}

#pragma mark - Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //get the fhoto, title, and caption from the model
    NSString *albumTitle = [self.model parkNameForAlbum:indexPath.section];
    UIImage *fhoto = [self.model imageAt:indexPath.row forAlbum:indexPath.section];
    NSString *caption = [self.model captionForImageAt:indexPath.row forAlbum:indexPath.section];
    
    //set fhoto and caption on the detail view controller
    self.detailViewController.fhotoImageView.image = fhoto;
    self.detailViewController.fhotoCaptionLabel.text = caption;
    self.detailViewController.title = albumTitle;
    
    [self.detailViewController.navigationController popToRootViewControllerAnimated:YES];
    
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.model removeFhoto:indexPath.row inAlbum:indexPath.section];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

//update the model when object is moved
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [self.model moveFhotoFromIndex:fromIndexPath.row toIndex:toIndexPath.row forAlbum:fromIndexPath.section];
}

//method that limits to only move within the section
-(NSIndexPath*)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    NSInteger sectionCount = [self.model fhotoCountForAlbum:sourceIndexPath.section];
    if (sourceIndexPath.section != proposedDestinationIndexPath.section)
    {
        NSUInteger rowInSourceSection =
        (sourceIndexPath.section > proposedDestinationIndexPath.section) ? 0 : sectionCount - 1;
        return [NSIndexPath indexPathForRow:rowInSourceSection inSection:sourceIndexPath.section];
    } else if (proposedDestinationIndexPath.row >= sectionCount) {
        return [NSIndexPath indexPathForRow:sectionCount - 1 inSection:sourceIndexPath.section];
    }
    // Allow the proposed destination.
    return proposedDestinationIndexPath;
}


#pragma mark - Table view section customizing
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //set the park title
    NSString *parkTitle = [self.model parkNameForAlbum:section];
    
    return parkTitle;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return tableHeaderHeight;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //create header view
    CGRect headerFrame = CGRectMake(0.0, 0.0, tableView.frame.size.width, tableHeaderHeight);
    UIView *headerView = [[UIView alloc] initWithFrame:headerFrame];
    
    //set header view properties
    headerView.tag = section;
    headerView.backgroundColor = [UIColor blackColor];
    
    //create label of title
    NSString *parkTitle = [self.model parkNameForAlbum:section];
    UILabel *parkLabel = [[UILabel alloc] initWithFrame:headerFrame];
    parkLabel.text = parkTitle;
    parkLabel.textColor = [UIColor whiteColor];
    parkLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:parkLabel];
    
    //set header recognizer
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toggleTableExpansion:)];
    [headerView addGestureRecognizer:singleTap];
    
    return headerView;
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"iPhoneToDetailSegue"])
    {
        BRDDetailViewController *detailViewController = segue.destinationViewController;
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        UIImage *fhoto = [self.model imageAt:indexPath.row forAlbum:indexPath.section];
        NSString *caption = [self.model captionForImageAt:indexPath.row forAlbum:indexPath.section];
        NSString *albumTitle = [self.model parkNameForAlbum:indexPath.section];
        NSString *comments = [self.model commentsForImageAt:indexPath.row forAlbum:indexPath.section];
        
        detailViewController.fhotoImage = fhoto;
        detailViewController.captionLabelText = caption;
        detailViewController.title = albumTitle;
        detailViewController.fhotoComments = comments;
        
        //set completion block
        detailViewController.completionBlock = ^(NSDictionary* dictionary)
        {
            [self dismissViewControllerAnimated:YES completion:NULL];
            if (dictionary)
            {
                //get the values changed
                NSString *caption = dictionary[@"caption"];
                NSString *comments = dictionary[@"comments"];
                
                //set them in the model
                [self.model setCaption:caption ofFhoto:indexPath.row forAlbum:indexPath.section];
                [self.model setComments:comments ofFhoto:indexPath.row forAlbum:indexPath.section];
                
                //reload the data
                [self.tableView reloadData];
            }
            
        };
    }
    else if ([segue.identifier isEqualToString:@"AddSegue"])
    {
        BRDNewFhotoViewController *addFhotoViewController = segue.destinationViewController;
        
        //get the number of albums
        NSInteger albumCount = [self.model fhotoAlbumCount];
        addFhotoViewController.numberOfAlbums = albumCount;
        
        //get the titles
        NSMutableArray *albumTitlesArray = [NSMutableArray array];
        for (int i=0; i<albumCount; i++)
        {
            [albumTitlesArray addObject:[self.model parkNameForAlbum:i]];
        }
        addFhotoViewController.albumTitles = [[NSArray alloc] initWithArray:albumTitlesArray];
        
        //set completion block
        addFhotoViewController.completionBlock = ^(NSDictionary* dictionary)
        {
            [self dismissViewControllerAnimated:YES completion:NULL];
            if (dictionary)
            {
                NSInteger albumIndex =  [dictionary[@"selectedAlbumIndex"] integerValue];
                UIImage *fhoto = dictionary[@"fhoto"];
                NSString *caption = dictionary[@"caption"];
                [self.model addFhoto:fhoto inAlbumIndex:albumIndex withCaption:caption];
                [self.tableView reloadData];
            }
            
        };
    }
}

#pragma mark - Expansion Table

-(void)toggleTableExpansion:(UITapGestureRecognizer*)recognizer
{
    //toggle the value
    NSInteger index = recognizer.view.tag;
    NSNumber *value = _toggledSections[index];
    NSNumber *valueInverse = [NSNumber numberWithBool:![value boolValue]];
    _toggledSections[index] = valueInverse;
    
    NSIndexSet *section = [NSIndexSet indexSetWithIndex:index];
    
    [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Action Sheet Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"New Album"])
    {
        //new album is just a regular pop up to type the name in
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Enter Album Name?" message:@"Be creative!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        alertView.tag = addTitleAlertViewTag;
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        [alertView show];
    }
    else if ([title isEqualToString:@"New Fhoto"])
    {
        //new fhoto brings up a new View modally added
        [self performSegueWithIdentifier:@"AddSegue" sender:self];
    }
    else
    {
        
    }
}

#pragma mark - Alert View Delegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == addTitleAlertViewTag)
    {
         NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:@"OK"])
        {
            //validate text field is entered and create new section
            UITextField *textField = [alertView textFieldAtIndex:0];
            if (textField.text && textField.text.length > 0)
            {
                //create a new section with this title
                [self.model addAlbumWithTitle:textField.text];
                
                [_toggledSections addObject:[NSNumber numberWithBool:TRUE]];
                [self.tableView reloadData];
            }
            else
            {
                //show alert didnt work because text field was empty
                UIAlertView *errorAlertView = [[UIAlertView alloc]initWithTitle:@"Error" message:@"No title entered" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [errorAlertView show];
            }

        }
        else
        {
            //cancel is pressed and do nothing
        }
    }
}


#pragma mark - Button Pressed Methods

- (IBAction)addBarButtonPressed:(id)sender
{
    //have a pop up come from the bottom and ask for new album or new photo
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"What do you want to create?" delegate:self cancelButtonTitle:@"Nothing, nevermind" destructiveButtonTitle:nil otherButtonTitles:@"New Album", @"New Fhoto", nil];
    [actionSheet showInView:self.view];
    
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
    self.editButton.enabled = !editing;
    if (editing)
    {
        _addButton.enabled = NO;
    } else
    {
        _addButton.enabled = YES;
    }
}
@end
