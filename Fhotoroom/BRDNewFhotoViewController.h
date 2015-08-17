//
//  BRDNewFhotoViewController.h
//  Fhotoroom
//
//  Created by MTSS User on 11/3/14.
//  Copyright (c) 2014 Bryan Dickens. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRDNewFhotoViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIPickerView *fhotoAlbumPickerView;

@property NSInteger numberOfAlbums;
@property NSArray *albumTitles;
@property NSNumber *selectedAlbumIndex;

@property (nonatomic,strong) CompletionBlock completionBlock;

@end
