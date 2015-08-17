//
//  BRDDetailViewController.m
//  Fhotoroom
//
//  Created by MTSS User on 10/29/14.
//  Copyright (c) 2014 Bryan Dickens. All rights reserved.
//

#import "BRDDetailViewController.h"
#import "BRDFhotoZoomViewController.h"

@interface BRDDetailViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic,weak) IBOutlet UINavigationItem *navigationBarItem;
@property (nonatomic,strong) UIPopoverController *masterPopoverController;
@property UITapGestureRecognizer *selectedImageRecognizer;

@property (strong, nonatomic) IBOutlet UILabel *captionLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UITextField *textField;

@property (nonatomic,strong) UIResponder *activeResponder;


@end

@implementation BRDDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //set initial edit button, hidden text field and scrollview for keyboard
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.textField.hidden = YES;
    self.scrollView = (UIScrollView*)self.view;
    
    if(self.title == nil)
    {
        self.title = @"Fhotoroom App";
    }

    if(self.captionLabelText != nil)
    {
        self.fhotoCaptionLabel.text = self.captionLabelText;
    }
    else
    {
        self.fhotoCaptionLabel.text = @"Welcome to the best F-hoto app you'll ever experience! Have fun exploring these images.";
    }
    if(self.fhotoImage != nil)
    {
        self.fhotoImageView.image = self.fhotoImage;
    }
    if([self.fhotoComments isEqualToString:@""])
    {
        self.textView.text = @"Enter comments here about the fhoto...";
        self.textView.textColor = [UIColor lightGrayColor];
    }
    else
    {
        self.textView.text = self.fhotoComments;
        self.textView.textColor = [UIColor blackColor];
    }
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    //set the tap gesture recognizer with the image
    _selectedImageRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(segueToZoomView:)];
    [self.fhotoImageView addGestureRecognizer:_selectedImageRecognizer];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.scrollView.contentSize = self.view.bounds.size;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //return and store the caption/comment changes
    NSDictionary *dictionary = @{@"caption":self.captionLabelText, @"comments":self.textView.text};
    self.completionBlock(dictionary);
}

#pragma mark - Keyboard Methods
-(void)keyboardWillBeShown:(NSNotification*)notification
{
    NSDictionary *info = [notification userInfo];
    CGRect frame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize kbSize = frame.size;
    
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, kbSize.height, 0);
    [self.scrollView scrollRectToVisible:self.textView.frame animated:YES];
    
}

-(void)keyboardWillHide:(NSNotification*)notification
{
    self.scrollView.contentInset = UIEdgeInsetsZero;
}

#pragma mark - Navigation

-(void)segueToZoomView:(UITapGestureRecognizer*)recognizer
{
    //ignore if no image
    if(self.fhotoImageView.image != nil)
    {
        [self performSegueWithIdentifier:@"SegueToZoomView" sender:nil];
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SegueToZoomView"])
    {
        BRDFhotoZoomViewController *fhotoZoomViewController = segue.destinationViewController;
        fhotoZoomViewController.fhoto = self.fhotoImageView.image;
        fhotoZoomViewController.title = self.fhotoCaptionLabel.text;
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    //VC about to be hidden, set the main details here
    
    //bar button for the nav bar set up
    barButtonItem.title = NSLocalizedString(@"Fhotoroom", @"Fhotoroom");
    [_navigationBarItem setLeftBarButtonItem:barButtonItem animated:YES];
    
    //set master popover to the table controller
    self.masterPopoverController = popoverController;
}


- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [_navigationBarItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Editing
-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    self.editButton.enabled = !editing;
    
    if (editing)
    {
        //turn caption text into label and let editing begin
        self.textField.text = self.captionLabelText;
        self.captionLabel.hidden = YES;
        self.textField.hidden = NO;
        [self.textView becomeFirstResponder];
    }
    else
    {
        self.captionLabelText = self.textField.text;
        self.captionLabel.text = self.captionLabelText;
        self.captionLabel.hidden = NO;
        self.textField.hidden = YES;
        [self.textView resignFirstResponder];
        [self.textField resignFirstResponder];
    }
    
}

#pragma mark - Text Field Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeResponder = textField;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeResponder = nil;
    
}

#pragma mark - Text View Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (!self.editing)
    {
        [self setEditing:YES animated:YES];
    }
    if ([textView.text isEqualToString:@"Enter comments here about the fhoto..."])
    {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""])
    {
        textView.text = @"Enter comments here about the fhoto...";
        textView.textColor = [UIColor lightGrayColor];
    }
    [textView resignFirstResponder];
}

@end

