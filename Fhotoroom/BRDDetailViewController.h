//
//  BRDDetailViewController.h
//  Fhotoroom
//
//  Created by MTSS User on 10/29/14.
//  Copyright (c) 2014 Bryan Dickens. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRDDetailViewController : UIViewController <UISplitViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *fhotoImageView;
@property (strong, nonatomic) IBOutlet UILabel *fhotoCaptionLabel;

@property NSString *captionLabelText;
@property UIImage *fhotoImage;
@property NSString *fhotoComments;

@property (nonatomic,strong) CompletionBlock completionBlock;

@end
