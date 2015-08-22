//
//  ImgProcWrapper.m
//  ideawork
//
//  Created by Ray Cai on 2015/2/23.
//  Copyright (c) 2015 Ray Cai. All rights reserved.
//

#import "ImgProcWrapper.h"

#import <UIKit/UIKit.h>

#include <opencv2/opencv.hpp>

struct scalarComparor {
    bool operator()(const cv::Vec4i& a, const cv::Vec4i& b) const {
        return a[0] < b[0];
    }
};

@implementation ImgProcWrapper

cv::Scalar transparentColor =cv::Scalar(0,0,0,0);

// public functions
+(UIImage *) capture:(UIImage *)image scale:(float)scale displacementX:(int)displacementX displacementY:(int)displacementY{
    cv::Mat inputMat = cvMatFromUIImage(image);
    
    int originalWidth = inputMat.cols;
    int originalHeight = inputMat.rows;
    
    
    // consider that movement direction of viewpoint is converse than touch movement
    int outputCenterXOnOriginalImage = int(originalWidth/2-displacementX);
    int outputCenterYOnOriginalImage = int(originalHeight/2-displacementY);
    
    int cropWidth = int(originalWidth/scale);
    int cropHeight = int(originalHeight/scale);
    
    int leftCropPointOnOriginalImage = int(outputCenterXOnOriginalImage-cropWidth/2);
    int rightCropPointOnOriginalImage = leftCropPointOnOriginalImage+cropWidth;
    
    int topCropPointOnOriginalImage = int(outputCenterYOnOriginalImage-cropHeight/2);
    int bottomCropPointOnOriginalImage = topCropPointOnOriginalImage+cropHeight;
    
    // check if entire image is moved out of view
    if(rightCropPointOnOriginalImage<=0 || leftCropPointOnOriginalImage >=originalWidth || topCropPointOnOriginalImage>=originalHeight || bottomCropPointOnOriginalImage<=0){
        //entire image is moved out of view
        cv::Mat outputMat = cv::Mat(originalHeight,originalWidth,CV_8UC4,transparentColor);
        
        UIImage* outputImage = UIImageFromCVMat(outputMat);
        
        return outputImage;
    }
    
    int leftExtend =0;
    int rightExtend = 0;
    int topExtend = 0;
    int bottomExtend = 0;
    
    if(leftCropPointOnOriginalImage<0){
        leftExtend=0-leftCropPointOnOriginalImage;
        leftCropPointOnOriginalImage=0;
    }
    
    if(rightCropPointOnOriginalImage>originalWidth){
        rightExtend = rightCropPointOnOriginalImage-originalWidth;
        rightCropPointOnOriginalImage=originalWidth;
    }
    
    if(topCropPointOnOriginalImage<0){
        topExtend=0-topCropPointOnOriginalImage;
        topCropPointOnOriginalImage=0;
    }
    
    if(bottomCropPointOnOriginalImage>originalHeight){
        bottomExtend=bottomCropPointOnOriginalImage-originalHeight;
        bottomCropPointOnOriginalImage=originalHeight;
    }
    
    //crop on original image
    cv::Rect cropRect(leftCropPointOnOriginalImage,topCropPointOnOriginalImage,rightCropPointOnOriginalImage-leftCropPointOnOriginalImage,bottomCropPointOnOriginalImage-topCropPointOnOriginalImage);
    
    cv::Mat cropedMat = inputMat(cropRect);
    
    cv::Mat extendedMat = cropedMat;
    //extend
    if(leftExtend>0){
        cv::Mat leftExtendMat = cv::Mat(extendedMat.rows,leftExtend,CV_8UC4,transparentColor);
        cv::Mat mergedMat;
        cv::hconcat(leftExtendMat, extendedMat, mergedMat);
        extendedMat = mergedMat;
    }
    if(rightExtend>0){
        cv::Mat rightExtendMat = cv::Mat(extendedMat.rows,rightExtend,CV_8UC4,transparentColor);
        cv::Mat mergedMat;
        cv::hconcat(extendedMat, rightExtendMat, mergedMat);
        extendedMat = mergedMat;
    }
    
    if(topExtend>0){
        cv::Mat topExtendMat = cv::Mat(topExtend,extendedMat.cols,CV_8UC4,transparentColor);
        cv::Mat mergedMat;
        cv::vconcat(topExtendMat, extendedMat, mergedMat);
        extendedMat=mergedMat;
    }
    
    if(bottomExtend>0){
        cv::Mat bottomExtendMat = cv::Mat(bottomExtend,extendedMat.cols,CV_8UC4,transparentColor);
        cv::Mat mergedMat;
        cv::vconcat(extendedMat, bottomExtendMat, mergedMat);
        extendedMat=mergedMat;
    }
    
    // scale
    cv::Size newSize = cv::Size(originalWidth,originalHeight);
    cv::Mat outputMat;
    cv::resize(extendedMat, outputMat, newSize);
    
    UIImage* outputImage = UIImageFromCVMat(outputMat);
    
    return outputImage;
}

+ (UIImage *)padding:(UIImage *)image newRows:(int)newRows newCols:(int)newCols
{
    //return image;

    cv::Mat inputMat = cvMatFromUIImage(image);
    cv::Mat outputMat=padding(inputMat, newRows, newCols);
    
    // convert mat to image
    UIImage *outputImage = UIImageFromCVMat(outputMat);
    
    return outputImage;
    
}

cv::Mat padding(cv::Mat inputMat,int newRows,int newCols){
    int inputCols = inputMat.cols;
    int inputRows = inputMat.rows;
    
    cv::Mat outputMat = cv::Mat(inputMat);
    
    // padding horizontal
    //cv::Scalar transparentColor = cv::Scalar(255,255,255,255);
    
    int leftPaddingCols = (newCols - inputCols ) /2;
    int rightPaddingCols = newCols-inputCols-leftPaddingCols;
    
    if (leftPaddingCols>0){
        cv::Mat leftPaddingMat = cv::Mat(inputRows,leftPaddingCols,CV_8UC4,transparentColor);
        // merge
        cv::Mat mergedMat = cv::Mat();
        cv::hconcat(leftPaddingMat, inputMat, mergedMat);
        outputMat=mergedMat;
    }
    if(rightPaddingCols>0){
        cv::Mat rightPaddingMat = cv::Mat(inputRows,rightPaddingCols,CV_8UC4,transparentColor);
        //merge
        cv::Mat mergedMat = cv::Mat();
        cv::hconcat(outputMat, rightPaddingMat,mergedMat);
        outputMat=mergedMat;
    }
    
    // padding vertical
    int topPaddingRows = (newRows-outputMat.rows)/2;
    int bottomPaddingRows = newRows-outputMat.rows-topPaddingRows;
    
    if(topPaddingRows>0){
        cv::Mat topPaddingMat = cv::Mat(topPaddingRows,outputMat.cols,CV_8UC4,transparentColor);
        
        //merge
        cv::Mat mergedMat = cv::Mat();
        cv::vconcat(topPaddingMat, outputMat, mergedMat);
        outputMat=mergedMat;
    }
    
    if(bottomPaddingRows>0){
        cv::Mat bottomPaddingMat = cv::Mat(bottomPaddingRows,outputMat.cols,CV_8UC4,transparentColor);
        //merge
        cv::Mat mergedMat = cv::Mat();
        cv::vconcat(outputMat, bottomPaddingMat, mergedMat);
        outputMat=mergedMat;
    }
    
    return outputMat;
}

+(UIImage *) extend:(UIImage *)image topExtend:(int)topExtend rightExtend:(int)rightExtend bottomExtend:(int)bottomExtend leftExtend:(int)leftExtend{
    cv::Mat inputMat=cvMatFromUIImage(image);
    
    cv::Mat outputMat=inputMat;
    
    if(topExtend>0){
        cv::Mat topExtendMat = cv::Mat(topExtend,inputMat.cols,CV_8UC4,transparentColor);
        //merge
        cv::Mat mergedMat;
        cv::vconcat(topExtendMat,outputMat,mergedMat);
        outputMat=mergedMat;
    }
    
    if(rightExtend>0){
        cv::Mat rightExtendMat = cv::Mat(outputMat.rows,rightExtend,CV_8UC4,transparentColor);
        //merge
        cv::Mat mergedMat;
        cv::hconcat(outputMat,rightExtendMat,mergedMat);
        outputMat=mergedMat;
        
    }
    
    if(bottomExtend>0){
        cv::Mat bottomExtendMat = cv::Mat(bottomExtend,outputMat.cols,CV_8UC4,transparentColor);
        //merge
        cv::Mat mergedMat;
        cv::vconcat(outputMat,bottomExtendMat,mergedMat);
        outputMat=mergedMat;
    }
    
    if(leftExtend>0){
        cv::Mat leftExtendMat = cv::Mat(outputMat.rows,leftExtend,CV_8UC4,transparentColor);
        //merge
        cv::Mat mergedMat;
        cv::hconcat(leftExtendMat,outputMat,mergedMat);
        
        outputMat=mergedMat;
    }
    
    UIImage* outputImage = UIImageFromCVMat(outputMat);
    return outputImage;
}

+(UIImage *) zoom:(UIImage *)image scale:(float)scale {
    cv::Mat inputMat = cvMatFromUIImage(image);
    int originalRows = inputMat.rows;
    int originalCols = inputMat.cols;
    
   
    
    if(scale >=1.0){
        // for using lower memory, crop original image first and then resize
        
        // computated the left rect
        int leftRows = int(originalRows/scale);
        int leftCols = int(originalCols/scale);
        
        int leftStartRows = int((originalRows-leftRows)/2);
        int leftStartCols = int((originalCols-leftCols)/2);
        
        cv::Rect leftRect(leftStartCols,leftStartRows,leftCols,leftRows);
        
        cv::Mat leftMat = inputMat(leftRect);
        
        cv::Size newSize = cv::Size(originalCols,originalRows);
        
        cv::Mat outputMat;
        cv::resize(leftMat, outputMat, newSize);
        

        
        UIImage* outputImage = UIImageFromCVMat(outputMat);
        
        return outputImage;
    }else{
        // scale image
        
        int newRows = int(originalRows*scale);
        int newCols = int(originalCols*scale);
        
        cv::Size newSize = cv::Size(newCols,newRows);
        cv::Mat scaledMat;
        
        cv::resize(inputMat, scaledMat, newSize);
        
        // padding
        cv::Mat outputMat = padding(scaledMat, originalRows, originalCols);
        
        UIImage* outputImage = UIImageFromCVMat(outputMat);
        
        return outputImage;
    }
    
    

    
    
    
}


+(UIImage *) resize:(UIImage *)image width:(int)width height:(int)height{
    cv::Mat inputMat = cvMatFromUIImage(image);
    
    cv::Size newSize(width,height);
    
    cv::Mat outputMat;
    
    cv::resize(inputMat, outputMat, newSize);
    
    UIImage* outputImage = UIImageFromCVMat(outputMat);
    
    return outputImage;
}

/*******************************
 * Filters
 *
 */

/***************************
 *
 * cartoonize filter. Make image looks like cartoon.
 * The process to produce the cartoon effect is divided into two branches- one for detecting and boldening the edges, and one for smoothing and quantizing the colors in the image. At the end, the resulting images are combined to archive the effect.
 *
 * this implementation accordinging to the algorithm described on https://stacks.stanford.edu/file/druid:yt916dh6570/Dade_Toonify.pdf.
 *
 */
+(UIImage *) cartoonizeFilter:(UIImage *)image{
    cv::Mat inputMat = cvMatFromUIImage(image);
    
    cv::Mat grayMat;
    
    cv::cvtColor(inputMat, grayMat, cv::COLOR_RGBA2GRAY);
    cv::Mat sampleMat;
    cv::Mat result = cv::Mat(inputMat.size(),grayMat.type());
    
    int k=4;
    cv::Mat bestLables;
    cv::Mat centers;
    sampleMat = grayMat.reshape(1,grayMat.rows*grayMat.cols);
    sampleMat.convertTo(sampleMat, CV_32F);
    cv::kmeans(sampleMat, k, bestLables, cv::TermCriteria( CV_TERMCRIT_EPS+CV_TERMCRIT_ITER, 10, 1.0), 3,cv::KMEANS_PP_CENTERS,centers);
    bestLables = bestLables.reshape(0,grayMat.rows);
    
    uchar whiteValue=0;
    
    double max,min;
    cv::Point min_loc, max_loc;
    cv::minMaxLoc(centers, &min, &max, &min_loc, &max_loc);
    
    centers.at<uchar>(max_loc)=whiteValue;
    
    for(int row=0;row<bestLables.rows;row++){
        for(int col=0;col<bestLables.cols;col++){
            int centerIndex = bestLables.at<int>(row,col);
            result.at<uchar>(row,col) = 255-centers.at<uchar>(centerIndex,0);
            //std::cout<<"gray:"<<gray<<std::endl;
            //result.at<int>(row,col)=255;
        }
    }
    cv::cvtColor(result, result, CV_GRAY2BGRA);
    UIImage* outputImage = UIImageFromCVMat(result);
    return outputImage;
}

+(UIImage *) removeBackground:(UIImage *)image{
    cv::Mat originalMat = cvMatFromUIImage(image);
    
    cv::Mat inputMat;
    int originalChannelNum = originalMat.channels();
    if(originalChannelNum==3){
        //add alpha channel
        cv::Mat originalChannels[4];
        cv::split(originalMat,originalChannels);
        
        cv::Mat alphaChannel = cv::Mat(originalMat.rows,originalMat.cols,CV_8U,cvScalar(255));
        
        originalChannels[3]=alphaChannel;
        // merge
        cv::merge(originalChannels,4,inputMat);
    }else{
        inputMat=originalMat;
    }
    
    cv::Mat imgRGB[4];
    cv::split(inputMat, imgRGB);
    int k = 6;
    int n = inputMat.rows * inputMat.cols;
    cv::Mat img3xN(n, 3, CV_8U);
    for (int i = 0; i != 3; ++i)
        imgRGB[i].reshape(1, n).copyTo(img3xN.col(i));
    img3xN.convertTo(img3xN, CV_32F);
    cv::Mat bestLables;
    
    
    
    
    cv::kmeans(img3xN, k, bestLables, cv::TermCriteria( CV_TERMCRIT_EPS+CV_TERMCRIT_ITER, 3, 1.0), 1,
               cv::KMEANS_PP_CENTERS);
    bestLables = bestLables.reshape(0, inputMat.rows);
    //cv::convertScaleAbs(bestLables, bestLables, int(255 / k));
    //bestLables.convertTo(bestLables,CV_8U);
    
    std::cout<<"finished clustering"<<std::endl;
    
    int borderWidth = int(inputMat.cols/20);
    
    int backgroundColor = determineBackgroundColor(borderWidth, bestLables);
    
    /*
     int r,g,b,a;
     r=int(backgroundColor[0])%256;
     g=int(backgroundColor[1])%256;
     
     b=int(backgroundColor[2])%256;
     
     a=int(backgroundColor[3])%256;
     */
    cv::Scalar color = cv::Scalar(backgroundColor);
    
    //std::cout<<bestLables.at<cv::Vec4i>(1,1)[0]<<","<<bestLables.at<cv::Vec4i>(1,1)[1]<<","<<bestLables.at<cv::Vec4i>(1,1)[2]<<std::endl;
    
    //std::cout<<backgroundColor[0]<<","<<backgroundColor[1]<<","<<backgroundColor[2]<<std::endl;
    //std::cout<<color[0]<<","<<color[1]<<","<<color[2]<<std::endl;
    
    cv::Mat mask;
    cv::inRange(bestLables,color,color+cv::Scalar(0.1),mask);
    
    cv::inRange(bestLables,color,color+cv::Scalar(0.1,0.1,0.1,0.1),mask);
    // inverse mask
    mask = cv::Mat::ones(mask.size(), mask.type()) * 255 - mask;
    
    // keep closed area
    
    std::vector<std::vector<cv::Point> > contours;
    std::vector<cv::Vec4i> hierarchy;
    
    cv::findContours(mask, contours, hierarchy, cv::RETR_CCOMP,
                     cv::CHAIN_APPROX_SIMPLE, cv::Point(0, 0));
    
    std::cout << "Detected contours number: " << contours.size() << std::endl;
    for (int idx = 0; idx >= 0 && idx < contours.size(); idx =
         hierarchy[idx][0]) {
        
        if (hierarchy[idx][2] < 0) //Check if there is a child contour
        {
            // opened contours
        } else {
            //closed contours
        }
        cv::Scalar color(255, 255, 255);
        cv::drawContours(mask, contours, idx, color, CV_FILLED, 8, hierarchy, 0,
                         cv::Point());
    }
    
    cv::Mat result = cv::Mat(inputMat.rows,inputMat.cols,CV_8UC4,cv::Scalar(255,255,255,0));
    
    
    inputMat.copyTo(result,mask);

    
    UIImage* outputImage = UIImageFromCVMat(result);
    return outputImage;
}

+(UIImage *) removeWhiteBackground:(UIImage *)image{
    
    cv::Mat originalMat = cvMatFromUIImage(image);
    
    cv::Mat inputMat;
    int originalChannelNum = originalMat.channels();
    if(originalChannelNum==3){
        //add alpha channel
        cv::Mat originalChannels[4];
        cv::split(originalMat,originalChannels);
        
        cv::Mat alphaChannel = cv::Mat(originalMat.rows,originalMat.cols,CV_8U,cvScalar(255));
        
        originalChannels[3]=alphaChannel;
        // merge
        cv::merge(originalChannels,4,inputMat);
    }else{
        inputMat=originalMat;
    }
    

    
    cv::Mat mask;
    cv::inRange(inputMat,cv::Scalar(240,240,240,0),cv::Scalar(256,256,256,256),mask);
    // inverse mask
    mask = cv::Mat::ones(mask.size(), mask.type()) * 255 - mask;

    
    cv::Mat result = cv::Mat(inputMat.rows,inputMat.cols,CV_8UC4,cv::Scalar(255,255,255,0));
    
    
    inputMat.copyTo(result,mask);
    
    UIImage* outputImage = UIImageFromCVMat(result);
    
    return outputImage;
}

+(UIImage *) createImage:(int) width height:(int)height{
    cv::Mat transparentMat(height,width,CV_8UC4,transparentColor);
    
    UIImage* outputImage = UIImageFromCVMat(transparentMat);
    
    return outputImage;
}

+(UIImage *) renderDesign:(UIImage *)backgroundImage wrinkles:(UIImage *)wrinkles colorImage:(UIImage *)colorImage printImage:(UIImage *)printImage baseColor:(UIColor *)baseColor{
    // process background
    cv::Mat backgroundMat = cvMatFromUIImage(backgroundImage);
    

    
    // process color
    cv::Mat colorMat = cvMatFromUIImage(colorImage);

    
    
    const CGFloat* colorComponents = CGColorGetComponents(baseColor.CGColor);
    CGFloat redComponent = colorComponents[0];
    CGFloat greenComponent = colorComponents[1];
    CGFloat blueComponent = colorComponents[2];
    //CGFloat alphaComponent = colorComponents[3];
    
    cv::Scalar cvBaseColor= cv::Scalar(int(redComponent*255),int(greenComponent*255),int(blueComponent*255),255);
    //cv::Scalar cvBaseColor= cv::Scalar(255,0,0,255);
    
    cv::Mat baseColorMat = cv::Mat(colorMat.rows,colorMat.cols,CV_8UC4,cvBaseColor);
    baseColorMat.copyTo(backgroundMat, colorMat);
    
    // process print
    cv::Mat printMat = cvMatFromUIImage(printImage);
    //A4 on template scale is 290x385
    cv::resize(printMat, printMat, cv::Size(290,385));
    // construct target area which print locates on result image
    // fixed position of print on result
    int startY=220;
    int startX = int((backgroundMat.cols-printMat.cols)/2);
    
    cv::Rect printLocatedRect = cv::Rect(startX,startY,printMat.cols,printMat.rows);
    
    cv::Mat printMatChannels[4];
    cv::split(printMat,printMatChannels);
    cv::Mat printMask = printMatChannels[3];
    
    printMat.copyTo(backgroundMat(printLocatedRect),printMask);
    
    
    // perform wrinkles
    
    cv::Mat wrinklesMat = cvMatFromUIImage(wrinkles);
    
    cv::Mat result = performWrinkles(backgroundMat, wrinklesMat);
    
    UIImage* output = UIImageFromCVMat(result);
    
    return output;
    
}

// perform wrinkles

cv::Mat performWrinkles(cv::Mat baseImage,cv::Mat wrinkles){
    cv::Mat result;
    
    
    cv::Mat baseImageChannels[4];
    cv::Mat wrinklesChannels[4];
    
    cv::split(baseImage, baseImageChannels);
    cv::split(wrinkles, wrinklesChannels);
    
    cv::Mat resultChannels[4];
    
    cv::Mat alphaRatio = wrinklesChannels[3].clone();
    
    cv::Mat fullAlphaMat = wrinklesChannels[3].clone();
    fullAlphaMat = cv::Scalar(255);
    
    cv::divide(wrinklesChannels[3], fullAlphaMat, alphaRatio);
    
    cv::Mat computedChannels[3];
    cv::multiply(256 - wrinklesChannels[0], alphaRatio, computedChannels[0]);
    cv::multiply(256 - wrinklesChannels[1], alphaRatio, computedChannels[1]);
    cv::multiply(256 - wrinklesChannels[2], alphaRatio, computedChannels[2]);
    
    cv::subtract(baseImageChannels[0], computedChannels[0], resultChannels[0]);
    cv::subtract(baseImageChannels[1], computedChannels[1], resultChannels[1]);
    cv::subtract(baseImageChannels[2], computedChannels[2], resultChannels[2]);
    
    resultChannels[3] = baseImageChannels[3];
    
    cv::merge(resultChannels, 4,result);
    
    return result;
}

/*************
 *support methonds
 *
 */

void countOccur(int element,
                std::map<int, int>& result) {
    if (result.find(element) != result.end()) {
        //std::cout<<result[element]<<std::endl;
        
        result[element] = result[element] +1;
    } else {
        result[element] = 1;
    }
}

int determineBackgroundColor(int borderWidth, cv::Mat& bestLables) {
    std::map<int, int> distribution;
    for (int x = 0; x < borderWidth; x++) {
        for (int y = 0; y < bestLables.rows; y++) {
            // at(row,col)
            int element = bestLables.at<int>(y, x);
            countOccur(element, distribution);
        }
    }
    std::cout << "extracted left border" << std::endl;
    for (int x = bestLables.cols - borderWidth; x < bestLables.cols; x++) {
        for (int y = 0; y < bestLables.rows; y++) {
            int element = bestLables.at<int>(y, x);
            countOccur(element, distribution);
        }
    }
    std::cout << "extracted right border" << std::endl;
    for (int x = borderWidth; x < bestLables.cols - borderWidth; x++) {
        for (int y = 0; y < borderWidth; y++) {
            int element = bestLables.at<int>(y, x);
            countOccur(element, distribution);
        }
    }
    std::cout << "extracted top border" << std::endl;
    for (int x = borderWidth; x < bestLables.cols - borderWidth; x++) {
        for (int y = bestLables.rows - borderWidth; y < bestLables.rows; y++) {
            int element = bestLables.at<int>(y, x);
            countOccur(element, distribution);
            
            //std::cout<<"Classification: "<<element<<std::endl;
        }
    }
    std::cout << "extracted bottom border" << std::endl;
    int max;
    int occur = 0;
    
    std::cout<<"key size:"<<distribution.size()<<std::endl;
    for (std::map<int, int>::iterator it = distribution.begin();
         it != distribution.end(); ++it) {
        if (it->second > occur) {
            //std::cout<<it->first<<std::endl;
            occur = it->second;
            max = it->first;
        }
    }
    
    //std::cout<<"query max occur"<<std::endl;
    //std::cout<<"Max:"<<max[0]<<","<<max[1]<<","<<max[2]<<"value:"<<occur<<std::endl;
    
    return max;
}
//type converter

cv::Mat cvMatFromUIImage(UIImage* image)
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4,transparentColor); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    //kCGImageAlphaNoneSkipLast |
                                                    kCGImageAlphaPremultipliedLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

UIImage* UIImageFromCVMat(cv::Mat cvMat)
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaPremultipliedLast|
                                        kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}



@end
