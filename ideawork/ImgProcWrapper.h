//
//  ImgProcWrapper.h
//  ideawork
//
//  Created by Ray Cai on 2015/2/23.
//  Copyright (c) 2015 Ray Cai. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface ImgProcWrapper : NSObject 


// public functions
+(UIImage *) capture:(UIImage *)image scale:(float)scale displacementX:(int)displacementX displacementY:(int)displacementY;

+(UIImage *) padding:(UIImage *)image newRows:(int)newRows newCols:(int)newCols;

+(UIImage *) extend:(UIImage *)image topExtend:(int)topExtend rightExtend:(int)rightExtend bottomExtend:(int)bottomExtend leftExtend:(int)leftExtend;

/**
 * zoom in/out image by scale. when scale is negative, perform zoom out. when scale is positive, perform zoom in. The image keep size.
 */
+(UIImage *) zoom:(UIImage *)image scale:(float)scale;


/*******************************
 * Filters
 *
 */

/***************************
 *
 * cartoonize filter. Make image looks like cartoon
 */
+(UIImage *) cartoonizeFilter:(UIImage *)image;

// type converters
//-(cv::Mat)cvMatFromUIImage:(UIImage *)image;
//-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;

@end
