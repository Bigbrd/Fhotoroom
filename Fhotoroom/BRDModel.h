//
//  BRDModel.h
//  Fhotoroom
//
//  Created by MTSS User on 10/14/14.
//  Copyright (c) 2014 Bryan Dickens. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRDModel : NSObject

+(id)sharedInstance;
-(id)__unavailable init;


-(NSInteger)fhotoAlbumCount;
-(NSString*)parkNameForAlbum:(NSInteger)albumIndex;

-(NSString*)captionForImageAt: (NSInteger)imageIndex forAlbum:(NSInteger)albumIndex;
-(NSString*)commentsForImageAt: (NSInteger)imageIndex forAlbum:(NSInteger)albumIndex;
-(UIImage*)imageAt: (NSInteger)imageIndex forAlbum:(NSInteger)albumIndex;

-(NSInteger)fhotoCountForAlbum:(NSInteger)albumIndex;

//Remove Fhoto
-(void)removeFhoto:(NSInteger)imageIndex inAlbum:(NSInteger)albumIndex;

//Adders
-(void)addAlbumWithTitle:(NSString*)albumTitle;
-(void)addFhoto:(UIImage*)image inAlbumIndex:(NSInteger)albumIndex withCaption:(NSString*)caption;

//Move Fhoto
-(void)moveFhotoFromIndex:(NSInteger)initialIndex toIndex:(NSInteger)finalIndex forAlbum:(NSInteger)albumIndex;

//Setters
-(void)setCaption:(NSString*)caption ofFhoto:(NSInteger)imageIndex forAlbum:(NSInteger)albumIndex;
-(void)setComments:(NSString*)comments ofFhoto:(NSInteger)imageIndex forAlbum:(NSInteger)albumIndex;

@end
