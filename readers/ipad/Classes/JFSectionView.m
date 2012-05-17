//
//  JFSectionView.m
//  textbook
//
//  Created by Fowler, James on 1/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "JFSectionView.h"
#import "textbookAppDelegate.h"

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
    
    
    textbookAppDelegate *appDelegate = (textbookAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    /*
     *******Uncomment code to change text color*****
     UIColor *color = [UIColor clearColor];     //set color here
     UIGraphicsBeginImageContext(aTile.size);
     CGContextRef context = UIGraphicsGetCurrentContext();
     
     [color setFill];
     CGContextTranslateCTM(context, 0, aTile.size.height);
     CGContextScaleCTM(context, 1.0, -1.0);
     
     CGContextSetBlendMode(context, kCGBlendModeColor);
     CGRect rect = CGRectMake(0, 0, aTile.size.width, aTile.size.height);
     CGContextDrawImage(context, rect, aTile.CGImage);
     
     CGContextClipToMask(context, rect, aTile.CGImage);
     CGContextAddRect(context, rect);
     CGContextDrawPath(context, kCGPathFill);
     
     UIImage *coloredtile = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();*/
    UIImage * aTile = [UIImage imageNamed:filename];
    UIImage *nImage = [self negativeImage:aTile];
    if(appDelegate.night == true){
        return nImage;
    }
    else {
        return aTile;
    }
   // return aTile;
}



- (UIImage *)negativeImage:(UIImage*)tile
{
    CGSize size = tile.size;
    int width = size.width;
    int height = size.height;
    
    // Create a suitable RGB+alpha bitmap context in BGRA colour space
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *memoryPool = (unsigned char *)calloc(width*height*4, 1);
    CGContextRef context = CGBitmapContextCreate(memoryPool, width, height, 8, width * 4, colourSpace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colourSpace);
    
    // draw the current image to the newly created context
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [tile CGImage]);
    
    // run through every pixel, a scan line at a time...
    for(int y = 0; y < height; y++)
    {
        // get a pointer to the start of this scan line
        unsigned char *linePointer = &memoryPool[y * width * 4];
        
        // step through the pixels one by one...
        for(int x = 0; x < width; x++)
        {
            //get rgb values
            int r, g, b; 
            if(linePointer[3])
            {
                r = linePointer[0] * 255 / linePointer[3];
                g = linePointer[1] * 255 / linePointer[3];
                b = linePointer[2] * 255 / linePointer[3];
            }
            else
                r = g = b = 0;
            
            // invert colors
            r = 255 - r;
            g = 255 - g;
            b = 255 - b;
            
            // multiply by alpha again, divide by 255 to undo the
            // scaling before, store the new values and advance
            // the pointer we're reading pixel data from
            linePointer[0] = r * linePointer[3] / 255;
            linePointer[1] = g * linePointer[3] / 255;
            linePointer[2] = b * linePointer[3] / 255;
            linePointer += 4;
        }
    }
    
    // get a CG image from the context, wrap that into a
    // UIImage
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    
    // clean up
    CGImageRelease(cgImage);
    CGContextRelease(context);
    free(memoryPool);
    
    return returnImage;
}



//- (UIImage*)backgroundtileAtCol:(int)col row:(int)row
//{
//    int index = row * 3 + col;
//    NSString* filename = [NSString stringWithFormat: @"tile%03d-%03d.png", section + 1, index];
    
    /* There are some questions about imageNamed caching the images in memory, which might end up causing our app to crash when it can't free memory... */
//    UIImage * aTile = [UIImage imageNamed:filename];
//    
//    return aTile;
//}



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
            // something like [backgroundtile drawInRect: tileRect];
            [tile drawInRect:tileRect];
        }
    }
}

- (void)dealloc
{
    [super dealloc];
}

@end
