//
//  JFSectionView.m
//  textbook
//
//  Created by Fowler, James on 1/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "JFSectionView.h"


@implementation JFSectionView

@synthesize section;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ layerClass
{
    return [CATiledLayer class];
}

- (UIImage*)tileAtCol:(int)col row:(int)row
{
    int index = row * 3 + col;
    NSString* filename = [NSString stringWithFormat: @"tile%03d-%03d.png", section + 1, index];
    
    /* There are some questions about imageNamed caching the images in memory, which might end up causing our app to crash when it can't free memory... */
    UIImage * aTile = [UIImage imageNamed:filename];

    return aTile;
}

- (void)drawRect:(CGRect)rect {
    CGSize tileSize = (CGSize){256, 256};
    
    int firstCol = floorf(CGRectGetMinX(rect) / tileSize.width);
    int lastCol = floorf((CGRectGetMaxX(rect)-1) / tileSize.width);
    int firstRow = floorf(CGRectGetMinY(rect) / tileSize.height);
    int lastRow = floorf((CGRectGetMaxY(rect)-1) / tileSize.height);
    
    for (int row = firstRow; row <= lastRow; row++) {
        for (int col = firstCol; col <= lastCol; col++) {
            UIImage *tile = [self tileAtCol:col row:row];
            
            CGRect tileRect = CGRectMake(tileSize.width * col, 
                                         tileSize.height * row,
                                         tileSize.width, tileSize.height);
            
            tileRect = CGRectIntersection(self.bounds, tileRect);
            
            [tile drawInRect:tileRect];
        }
    }
}

- (void)dealloc
{
    [super dealloc];
}

@end
