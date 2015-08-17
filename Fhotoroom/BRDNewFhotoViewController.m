//
//  BRDNewFhotoViewController.m
//  Fhotoroom
//
//  Created by MTSS User on 11/3/14.
//  Copyright (c) 2014 Bryan Dickens. All rights reserved.
//

#import "BRDNewFhotoViewController.h"

@interface BRDNewFhotoViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITextField *fhotoCaptionTextField;
@property (nonatomic,strong) UIResponder *activeResponder;


- (IBAction)selectFhotoButtonPressed:(id)sender;
- (IBAction)takeFhotoButtonPressed:(id)sender;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;

@end

@implementation BRDNewFhotoViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    
    //if there is no camera throw an alert, needed for ios simulation
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Device has no camera" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [myAlertView show];
        
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    //set initial choice for picker
    self.selectedAlbumIndex = [NSNumber numberWithInteger:0];
    [self.fhotoAlbumPickerView selectRow:0 inComponent:0 animated:NO];
}

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

#pragma mark - Fhoto Selection Methods

- (IBAction)selectFhotoButtonPressed:(id)sender
{
    //open up album and pick a photo to populate uiimageview
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)takeFhotoButtonPressed:(id)sender
{
    //open up camera and take a picture
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return _numberOfAlbums;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return _albumTitles[row];
}

#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
   _selectedAlbumIndex = [NSNumber numberWithInteger:row];
}

- (IBAction)cancelButtonPressed:(id)sender
{
    self.completionBlock(nil);
}

- (IBAction)doneButtonPressed:(id)sender
{
    if (self.imageView.image == nil)
    {
        //no image throw error
        UIAlertView *errorAlertView = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Make sure to choose or take a fhoto!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [errorAlertView show];
    }
    else
    {
        NSDictionary *dictionary = @{@"selectedAlbumIndex":self.selectedAlbumIndex, @"fhoto":self.imageView.image, @"caption":self.fhotoCaptionTextField.text};
        self.completionBlock(dictionary);
    }
}
@end
