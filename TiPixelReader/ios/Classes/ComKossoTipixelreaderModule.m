/**
 * TiPixelReader
 *
 * Created by Kosso
 * Copyright (c) 2019 . All rights reserved.
 */

#import "ComKossoTipixelreaderModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

@implementation ComKossoTipixelreaderModule

#pragma mark Internal

// This is generated for your module, please do not change it
- (id)moduleGUID
{
  return @"20c36298-7721-4fea-b2f2-2d7a27f41edb";
}

// This is generated for your module, please do not change it
- (NSString *)moduleId
{
  return @"com.kosso.tipixelreader";
}

#pragma mark Lifecycle

- (void)startup
{
  // This method is called when the module is first loaded
  // You *must* call the superclass
  [super startup];
  DebugLog(@"[DEBUG] %@ loaded", self);
}

#pragma Public APIs

- (id)getImagePixels:(id)args
{
    
    NSString *filepath = [TiUtils stringValue:[args objectAtIndex:0]];
    KrollCallback *cb = [args objectAtIndex:1];
    ENSURE_TYPE(cb, KrollCallback);
    
    if (![[NSFileManager defaultManager]fileExistsAtPath:filepath])
    {
        NSLog(@"[INFO] image not found at %@", filepath);
        return nil;
    }
    
    NSData *imageData = [NSData dataWithContentsOfFile:filepath];
    UIImage *image = [UIImage imageWithData:imageData];
    
    //NSLog(@"[INFO] image loaded");
    //NSLog(@"[INFO] width.  %f", image.size.width);
    //NSLog(@"[INFO] height. %f", image.size.height);
    
    NSMutableArray *lines = [[NSMutableArray alloc] init];

    for (int y = 0; y < image.size.height; y++)
    {
        NSMutableArray *line_data = [[NSMutableArray alloc] init];
        
        [line_data addObject:[NSNumber numberWithInt:y]];
        
        for (int x = 0; x < image.size.width; x++)
        {
            CGPoint point = {x, y};
            UIColor *col = [self colorAtPixel:point fromImage:image];
            CGFloat red, green, blue, alpha;
            [col getRed: &red green: &green blue: &blue alpha: &alpha];
            int red_ = red * 255;
            int green_ = green * 255;
            int blue_ = blue * 255;

            NSInteger rgb[3];
            rgb[0] = red_;
            rgb[1] = green_;
            rgb[2] = blue_;
            
            [line_data addObject:[NSNumber numberWithInt:red_]];
            [line_data addObject:[NSNumber numberWithInt:green_]];
            [line_data addObject:[NSNumber numberWithInt:blue_]];
            
            //NSArray *rgb = [NSArray arrayWithObjects:red_, green_, blue_, nil];
            //NSLog(@"[INFO] %d,%d : %u ,%u, %u",x, y, red_, green_, blue_);
        }
        
        [lines addObject:line_data];
    }
    
    // NSLog(@"[INFO] got all pixels! ");
    
    NSDictionary *cbArgs = @{
                          @"lines": lines
                     };
    [self _fireEventToListener:@"success" withObject:cbArgs listener:cb thisObject:nil];
    cbArgs = nil;
    
}


- (UIColor *)colorAtPixel:(CGPoint)point fromImage:(UIImage*)image {
    // Cancel if point is outside image coordinates
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), point)) {
        return nil;
    }
    // Create a 1x1 pixel byte array and bitmap context to draw the pixel into.
    // Reference: http://stackoverflow.com/questions/1042830/retrieving-a-pixel-alpha-value-for-a-uiimage
    CGImageRef cgImage = image.CGImage;
    NSUInteger width = CGImageGetWidth(cgImage);
    NSUInteger height = CGImageGetHeight(cgImage);
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(height - 1 -  point.y);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);

    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, -pointY);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);

    // Convert color values [0..255] to floats [0.0..1.0]
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
