//
//  main.m
//  opencvtest
//
//  Created by Ray Cai on 15/7/25.
//  Copyright (c) 2015年 Ray Cai. All rights reserved.
//

#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <iostream>
#include <map>

struct scalarComparor {
    bool operator()(const cv::Vec4i& a, const cv::Vec4i& b) const {
        return (a[0]*256+a[1])*256+a[2] < (b[0]*256+b[1])*256+b[2];
    }
};


int vec4i2Int(cv::Vec4i input){
    return (input[0]*256+input[1])*256+input[2];
}

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

void testMergeLayer() {
    cv::Mat backgroundMat;
    cv::Mat colorMat;
    cv::Mat wrinklesMat;

    backgroundMat = cv::imread(
                           "/Users/kkppccdd/workspace/ios_workspace/ideawork/ideawork/resources/designTemplate/defaultTeeShirt/background.png", -1);
    
    colorMat = cv::imread(
                          "/Users/kkppccdd/workspace/ios_workspace/ideawork/ideawork/resources/designTemplate/defaultTeeShirt/color.png", -1);
    wrinklesMat = cv::imread(
                          "/Users/kkppccdd/workspace/ios_workspace/ideawork/ideawork/resources/designTemplate/defaultTeeShirt/wrinkles.png", -1);

    

    
    //cv::Mat colorMask;
    //cv::cvtColor(colorMat, colorMask, cv::COLOR_RGBA);
    
    
    

    
    cv::Scalar cvBaseColor= cv::Scalar(int(0*255),int(0*255),int(0*255),255);
    //cv::Scalar cvBaseColor= cv::Scalar(255,0,0,255);
    
    cv::Mat baseColorMat = cv::Mat(colorMat.rows,colorMat.cols,CV_8UC4,cvBaseColor);
    baseColorMat.copyTo(backgroundMat, colorMat);
    
    // process print
    
    
    // perform wrinkles
    
    
    cv::Mat result = performWrinkles(backgroundMat, wrinklesMat);
    
    cv::imwrite("/Users/kkppccdd/Documents/IdeaWork/result.png",
                result);
}



void countOccur(int element,
                std::map<int, long>& result) {
    if (result.find(element) != result.end()) {
        //std::cout<<result[element]<<std::endl;
        
        result[element] = result[element] +1;
    } else {
        result[element] = 1;
    }
}

int determineBackgroundColor(int borderWidth, cv::Mat& bestLables) {
    std::map<int, long> distribution;
    for (int x = 0; x < borderWidth; x++) {
        for (int y = 0; y < bestLables.rows; y++) {
            int element = bestLables.at<int>(x, y);
            countOccur(element, distribution);
        }
    }
    std::cout << "extracted left border" << std::endl;
    for (int x = bestLables.cols - borderWidth; x < bestLables.cols; x++) {
        for (int y = 0; y < bestLables.rows; y++) {
            int element = bestLables.at<int>(x, y);
            countOccur(element, distribution);
        }
    }
    std::cout << "extracted right border" << std::endl;
    for (int x = borderWidth; x < bestLables.cols - borderWidth; x++) {
        for (int y = 0; y < borderWidth; y++) {
            int element = bestLables.at<int>(x, y);
            countOccur(element, distribution);
        }
    }
    std::cout << "extracted top border" << std::endl;
    for (int x = borderWidth; x < bestLables.cols - borderWidth; x++) {
        for (int y = bestLables.rows - borderWidth; y < bestLables.rows; y++) {
            int element = bestLables.at<int>(x, y);
            countOccur(element, distribution);
            
            std::cout<<"Classification: "<<element<<std::endl;
        }
    }
    std::cout << "extracted bottom border" << std::endl;
    int max;
    int occur = 0;
    
    std::cout<<"key size:"<<distribution.size()<<std::endl;
    for (std::map<int, long>::iterator it = distribution.begin();
         it != distribution.end(); ++it) {
        if (it->second > occur) {
            //std::cout<<it->first<<std::endl;
            occur=it->second;
            max = it->first;
        }
    }
    
    //std::cout<<"query max occur"<<std::endl;
    //std::cout<<"Max:"<<max[0]<<","<<max[1]<<","<<max[2]<<"value:"<<occur<<std::endl;
    
    return max;
}

void testColorClustoring() {
    cv::Mat originalMat = cv::imread("/Users/kkppccdd/Documents/Documents/IdeaWork/resources/20140825212121_NePFj.jpg", -1);
    
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
    int k = 4;
    int n = inputMat.rows * inputMat.cols;
    cv::Mat img3xN(n, 3, CV_8U);
    for (int i = 0; i != 3; ++i)
        imgRGB[i].reshape(1, n).copyTo(img3xN.col(i));
    img3xN.convertTo(img3xN, CV_32F);
    cv::Mat bestLables;
    cv::kmeans(img3xN, k, bestLables, cv::TermCriteria( CV_TERMCRIT_EPS+CV_TERMCRIT_ITER, 10, 1.0), 3,
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
    // inverse mask
    mask = cv::Mat::ones(mask.size(), mask.type()) * 255 - mask;
    
    cv::Mat result = cv::Mat(inputMat.rows,inputMat.cols,CV_8UC4,cv::Scalar(255,255,255,0));
    // keep closed area
    
    std::vector<std::vector<cv::Point> > contours;
    std::vector<cv::Vec4i> hierarchy;
    
    cv::findContours( mask, contours, hierarchy, cv::RETR_CCOMP, cv::CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
    
    std::cout<<"Detected contours number: "<<contours.size()<<std::endl;
    for( int idx=0; idx >= 0 && idx<contours.size(); idx = hierarchy[idx][0] )
    {
        
        if(hierarchy[idx][2]<0) //Check if there is a child contour
        {
            // opened contours
        }else{
            //closed contours
        }
        cv::Scalar color( 255, 255, 255 );
        cv::drawContours( mask, contours, idx, color, CV_FILLED, 8, hierarchy, 0, cv::Point() );
    }
    
    
    
    
    
    inputMat.copyTo(result,mask);
    
    cv::imwrite("/Users/kkppccdd/Documents/Documents/IdeaWork/result.png",
                result);
}


void testRemoveWhiteBackground(){
    cv::Mat originalMat = cv::imread("/Users/kkppccdd/Pictures/20120625200704_NreVX.thumb.600_0.jpg", -1);
    
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
    
    std::cout<<"preprocess done"<<std::endl;
    
    cv::Mat mask;
    cv::inRange(inputMat,cv::Scalar(240,240,240,0),cv::Scalar(255,255,255,255),mask);
    // inverse mask
    mask = cv::Mat::ones(mask.size(), mask.type()) * 255 - mask;
    std::cout<<"extract mask"<<std::endl;
    
    cv::Mat result = cv::Mat(inputMat.rows,inputMat.cols,CV_8UC4,cv::Scalar(255,255,255,0));
    
    
    inputMat.copyTo(result,mask);
    std::cout<<"copy"<<std::endl;
    
    cv::imwrite("/Users/kkppccdd/Documents/Documents/IdeaWork/result.png",
                result);
}

void testGray(){
    cv::Mat inputMat = cv::imread("/Users/kkppccdd/Documents/IdeaWork/resources/80cb39dbb6fd52666264211aa918972bd4073674.jpg",-1);
    
    cv::Mat grayMat;
    
    cv::cvtColor(inputMat, grayMat, cv::COLOR_RGBA2GRAY);
    cv::Mat sampleMat;
    cv::Mat result = cv::Mat(inputMat.size(),grayMat.type());

    int k=3;
    cv::Mat bestLables;
    cv::Mat centers;
    sampleMat = grayMat.reshape(1,grayMat.rows*grayMat.cols);
    sampleMat.convertTo(sampleMat, CV_32F);
    cv::kmeans(sampleMat, k, bestLables, cv::TermCriteria( CV_TERMCRIT_EPS+CV_TERMCRIT_ITER, 10, 1.0), 10,cv::KMEANS_PP_CENTERS,centers);
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
    
    cv::imwrite("/Users/kkppccdd/Documents/IdeaWork/result.png",result);
}

int main(int argc, char **argv) {
    //testMergeLayer();
    testGray();
    return 0;
}
