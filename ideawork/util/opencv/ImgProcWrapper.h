//
//  ImgProcWrapper.h
//  ideawork
//
//  Created by Ray Cai on 2015/2/23.
//  Copyright (c) 2015 Ray Cai. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


//#import "ideawork-Swift.h"


@interface ImgProcWrapper : NSObject 


// public functions
+(UIImage *) capture:(UIImage *)image scale:(float)scale displacementX:(int)displacementX displacementY:(int)displacementY;

+(UIImage *) padding:(UIImage *)image newRows:(int)newRows newCols:(int)newCols;

+(UIImage *) extend:(UIImage *)image topExtend:(int)topExtend rightExtend:(int)rightExtend bottomExtend:(int)bottomExtend leftExtend:(int)leftExtend;

/**
 * zoom in/out image by scale. when scale is negative, perform zoom out. when scale is positive, perform zoom in. The image keep size.
 */
+(UIImage *) zoom:(UIImage *)image scale:(float)scale;

+(UIImage *) createImage:(int) width height:(int)height;

+(UIImage *) resize:(UIImage *)image width:(int)width height:(int)height;

/*********
 render design with specific base color
 */
+(UIImage *) renderDesign:(UIImage *)backgroundImage wrinkles:(UIImage *)wrinkles colorImage:(UIImage *)colorImage printImage:(UIImage *)printImage baseColor:(UIColor *)baseColor;


/*******************************s
 * Filters
 *
 */

/***************************
 *
 * cartoonize filter. Make image looks like cartoon
 */
+(UIImage *) cartoonizeFilter:(UIImage *)image;

/**************
 * remove background
 *
 */

+(UIImage *) removeBackground:(UIImage *)image;

/*********
 * remove white background
 *
 */
+(UIImage *) removeWhiteBackground:(UIImage *)image;
// type converters
//-(cv::Mat)cvMatFromUIImage:(UIImage *)image;
//-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;

@end
