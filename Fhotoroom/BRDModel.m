//
//  BRDModel.m
//  Fhotoroom
//
//  Created by MTSS User on 10/14/14.
//  Copyright (c) 2014 Bryan Dickens. All rights reserved.
//

#import "BRDModel.h"

@interface BRDModel ()

@property NSMutableArray *fhotoAlbumsArray;

@end

@implementation BRDModel

+(id)sharedInstance
{
    static id singleton;
    @synchronized(self)
    {
        if(!singleton)
        {
            singleton = [[self alloc] init];
        }
    }
    return singleton;
}

#pragma mark - Initializers

-(id)init
{
    self = [super init];
    if (self)
    {
        [self readInRootFhotoArray];
    }
    return self;
}

-(void)readInRootFhotoArray
{
    //take in the plist
    NSString *mainBundleString = [[NSBundle mainBundle] pathForResource:@"Photos" ofType:@"plist"];
    NSArray *rootFhotoAlbumsArray = [[NSArray alloc] initWithContentsOfFile:mainBundleString];
    
    //initialize the fhotoalbums
    [self initializeFhotoAlbumsIn:rootFhotoAlbumsArray];
}

-(void)initializeFhotoAlbumsIn: (NSArray*)rootFhotoAlbumsArray
{
    NSMutableArray *tempFhotoAlbumsArray = [NSMutableArray array];
    for (NSDictionary *fhotoAlbum in rootFhotoAlbumsArray)
    {
        //get the fhoto Album name and array of pictures
        NSString *fhotoAlbumName = fhotoAlbum[@"name"];
        NSArray *rootFhotosArray = fhotoAlbum[@"photos"];
        NSMutableArray *fhotosArray = [self initializeFhotosIn:rootFhotosArray];
        
        //create the new dictionary holding these album values
        NSDictionary *dictionary = @{@"fhotoAlbumName":fhotoAlbumName, @"fhotos":fhotosArray};
        [tempFhotoAlbumsArray addObject:dictionary];
    }
    
    //set to the final fhoto album array
    self.fhotoAlbumsArray = [[NSMutableArray alloc] initWithArray:tempFhotoAlbumsArray];
}

-(NSMutableArray*)initializeFhotosIn: (NSArray*)rootFhotosArray
{
    NSMutableArray *fhotosArray = [NSMutableArray array];
    for (NSDictionary *fhoto in rootFhotosArray)
    {
        //get the fhoto image + caption
        NSString *imageName = fhoto[@"imageName"];
        NSString *fullImageName = [NSString stringWithFormat:@"%@.jpg",imageName];
        UIImage *image = [UIImage imageNamed:fullImageName];
        NSString *caption = fhoto[@"caption"];
        NSString *comments = @"";
        //create the new dictioanry holding these photo values
        NSDictionary *dictionary = @{@"fhoto":image, @"imageName":imageName, @"caption":caption, @"comments":comments};
        NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
        if (image)
        {
            [fhotosArray addObject:mutableDictionary];
        }
    }
    
    return fhotosArray;
}

#pragma mark - Public Getter Methods
-(NSInteger)fhotoAlbumCount
{
    return [self.fhotoAlbumsArray count];
}

-(NSInteger)fhotoCountForAlbum:(NSInteger)albumIndex
{
    NSDictionary *fhotoAlbum = [self.fhotoAlbumsArray objectAtIndex:albumIndex];
    NSArray *fhotosArray = fhotoAlbum[@"fhotos"];
    return [fhotosArray count];
}

-(NSString*)parkNameForAlbum:(NSInteger)albumIndex
{
    NSDictionary *fhotoAlbum = [self.fhotoAlbumsArray objectAtIndex:albumIndex];
    NSString *fhotoAlbumName = fhotoAlbum[@"fhotoAlbumName"];
    return fhotoAlbumName;
}

-(NSString*)captionForImageAt: (NSInteger)imageIndex forAlbum:(NSInteger)albumIndex
{
    NSDictionary *fhotoAlbum = [self.fhotoAlbumsArray objectAtIndex:albumIndex];
    NSArray *fhotosArray = fhotoAlbum[@"fhotos"];
    NSMutableDictionary *fhotoDictionary = [fhotosArray objectAtIndex:imageIndex];
    NSString *fhotoCaption = fhotoDictionary[@"caption"];
    return fhotoCaption;
}

-(NSString*)commentsForImageAt: (NSInteger)imageIndex forAlbum:(NSInteger)albumIndex
{
    NSDictionary *fhotoAlbum = [self.fhotoAlbumsArray objectAtIndex:albumIndex];
    NSArray *fhotosArray = fhotoAlbum[@"fhotos"];
    NSMutableDictionary *fhotoDictionary = [fhotosArray objectAtIndex:imageIndex];
    NSString *fhotoComments = fhotoDictionary[@"comments"];
    return fhotoComments;
}

-(UIImage*)imageAt: (NSInteger)imageIndex forAlbum:(NSInteger)albumIndex
{
    NSDictionary *fhotoAlbum = [self.fhotoAlbumsArray objectAtIndex:albumIndex];
    NSArray *fhotosArray = fhotoAlbum[@"fhotos"];
    NSMutableDictionary *fhotoDictionary = [fhotosArray objectAtIndex:imageIndex];
    UIImage *fhoto = fhotoDictionary[@"fhoto"];
    return fhoto;
}

#pragma mark - Editing Methods

-(void)removeFhoto:(NSInteger)imageIndex inAlbum:(NSInteger)albumIndex
{
    NSDictionary *fhotoAlbum = [self.fhotoAlbumsArray objectAtIndex:albumIndex];
    NSMutableArray *fhotosArray = fhotoAlbum[@"fhotos"];
    [fhotosArray removeObjectAtIndex:imageIndex];
}

-(void)addAlbumWithTitle:(NSString*)albumTitle
{
    NSMutableArray *fhotosArray = [NSMutableArray array];
    NSDictionary *dictionary = @{@"fhotoAlbumName":albumTitle, @"fhotos":fhotosArray};
    [self.fhotoAlbumsArray addObject:dictionary];
    
    //compare and sort here
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"fhotoAlbumName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSMutableArray *sortDescriptors = [NSMutableArray arrayWithObject:sortByName];
    NSMutableArray *sortedArray = [[self.fhotoAlbumsArray sortedArrayUsingDescriptors:sortDescriptors]mutableCopy];
    self.fhotoAlbumsArray = sortedArray;
}

-(void)addFhoto:(UIImage*)image inAlbumIndex:(NSInteger)albumIndex withCaption:(NSString*)caption
{
    NSDictionary *fhotoAlbum = [self.fhotoAlbumsArray objectAtIndex:albumIndex];
    NSMutableArray *fhotosArray = fhotoAlbum[@"fhotos"];
    
    NSString *imageName = @"";
    NSString *comments = @"";
    
    //create the new dictioanry holding these photo values
    NSDictionary *dictionary = @{@"fhoto":image, @"imageName":imageName, @"caption":caption, @"comments":comments};
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
    [fhotosArray addObject:mutableDictionary];
}

-(void)moveFhotoFromIndex:(NSInteger)initialIndex toIndex:(NSInteger)finalIndex forAlbum:(NSInteger)albumIndex
{
    NSDictionary *fhotoAlbum = [self.fhotoAlbumsArray objectAtIndex:albumIndex];
    NSMutableArray *fhotosArray = fhotoAlbum[@"fhotos"];
    
    id item = [fhotosArray objectAtIndex:initialIndex];
    [fhotosArray removeObjectAtIndex:initialIndex];
    [fhotosArray insertObject:item atIndex:finalIndex];

}

-(void)setCaption:(NSString*)caption ofFhoto:(NSInteger)imageIndex forAlbum:(NSInteger)albumIndex
{
    NSDictionary *fhotoAlbum = [self.fhotoAlbumsArray objectAtIndex:albumIndex];
    NSMutableArray *fhotosArray = fhotoAlbum[@"fhotos"];
    
    NSMutableDictionary *fhotoDictionary = [fhotosArray objectAtIndex:imageIndex];
    
    [fhotoDictionary setValue:caption forKey:@"caption"];
}

-(void)setComments:(NSString*)comments ofFhoto:(NSInteger)imageIndex forAlbum:(NSInteger)albumIndex
{
    NSDictionary *fhotoAlbum = [self.fhotoAlbumsArray objectAtIndex:albumIndex];
    NSMutableArray *fhotosArray = fhotoAlbum[@"fhotos"];
    
    NSMutableDictionary *fhotoDictionary = [fhotosArray objectAtIndex:imageIndex];
    
    [fhotoDictionary setValue:comments forKey:@"comments"];
}

@end
