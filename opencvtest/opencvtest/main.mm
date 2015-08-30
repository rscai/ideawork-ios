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
    
    uchar whiteValue=255;
    uchar blackValue=0;
    uchar otherValue=128;
    
    double max,min;
    cv::Point min_loc, max_loc;
    cv::minMaxLoc(centers, &min, &max, &min_loc, &max_loc);
    //centers=otherValue;
    centers.at<uchar>(max_loc)=whiteValue;
    centers.at<uchar>(min_loc)=blackValue;
    
    for(int row=0;row<bestLables.rows;row++){
        for(int col=0;col<bestLables.cols;col++){
            int centerIndex = bestLables.at<int>(row,col);
            result.at<uchar>(row,col) = centers.at<uchar>(centerIndex,0);
            //int gray =result.at<uchar>(row,col);
            //std::cout<<"gray:"<<gray<<std::endl;
            //result.at<int>(row,col)=255;
        }
    }
    
    cv::Mat otherValueMask;
    cv::inRange(result, cv::Scalar(1), cv::Scalar(254), otherValueMask);
    
    int laneWidth = result.cols/200;
    cv::Mat otherValueMat(result.size(),result.type(),cv::Scalar(whiteValue));
    for(int r=0;r<otherValueMat.rows;r++){
        for(int c=0;c<otherValueMat.cols;c++){
            if(((r+c)/laneWidth)%3==0){
                otherValueMat.at<uchar>(r,c)=otherValue;
            }
        }
    }
    
    otherValueMat.copyTo(result, otherValueMask);
    
    cv::imwrite("/Users/kkppccdd/Documents/IdeaWork/result.png",result);
}


std::vector<cv::Vec3b> unique(cv::Mat input){
    std::cout<<"Start caculate uniuqe color list"<<std::endl;
    std::vector<cv::Vec3b> uniqueOut;
    
    for(int r=0;r<input.rows;r++){
        for(int c=0;c<input.cols;c++){
            cv::Vec3b value = input.at<cv::Vec3b>(r,c);
            
            if ( std::find(uniqueOut.begin(), uniqueOut.end(), value) == uniqueOut.end() ){
                uniqueOut.push_back(value);
            }
        }
    }
    std::cout<<"Completed caculate uniuqe color list"<<std::endl;

    return uniqueOut;
}

int nearTo(cv::Vec3b point,std::vector<cv::Vec3b> colorList){
    int nearestIndex =0;
    int minDistance= std::numeric_limits<int>::max();
    
    for(int index=0;index<colorList.size();index++){
        cv::Vec3b color = colorList.at(index);
        
        int distance = std::sqrt(std::abs(color[0]-point[0])^2+std::abs(color[1]-point[1])^2+std::abs(color[2]-point[2])^2);
        
        if(distance<minDistance){
            nearestIndex=index;
            minDistance=distance;
        }
    }
    
    return nearestIndex;
}

void testCartoonize(){
    cv::Mat inputMat = cv::imread("/Users/kkppccdd/Documents/IdeaWork/resources/23376054_1.jpg",-1);
    
    cv::Mat colorSetMat = cv::imread("/Users/kkppccdd/Documents/IdeaWork/resources/23376054_2.jpg",-1);


    // 由于算法复杂，因此需减少图像尺寸
    
    cv::Size size = inputMat.size();
    
    cv::Size reduceSize;
    
    reduceSize.width = size.width / 2;
    
    reduceSize.height = size.height / 2;
    
    cv::Mat reduceImage = cv::Mat(reduceSize, CV_8UC3);
    
    
    
    cv::resize(inputMat, reduceImage, reduceSize);
    
    
    
    // 双边滤波器实现过程
    /*
    cv::Mat tmp = cv::Mat(size, CV_8UC3);
    
    int repetitions = 14;
    
    for (int i=0 ; i < repetitions; i++)
    {
        int kernelSize = 9;
        double sigmaColor = 9;
        double sigmaSpace = 7;
        cv::bilateralFilter(reduceImage, tmp, kernelSize, sigmaColor, sigmaSpace);
        cv::bilateralFilter(tmp, reduceImage, kernelSize, sigmaColor, sigmaSpace);
    }*/
    
    std::vector<cv::Vec3b> colorMap(256*256*256);
    
    //std::vector<cv::Vec3b> colorList = unique(colorSetMat);
    
    uchar reduceLevel=64;
    // generate test colormap
    /*
    for(int i=0;i<256;i++){
        for(int j=0;j<256;j++){
            for(int k=0;k<256;k++){
                
                int nearestIndex = nearTo(cv::Vec3b(i,j,k), colorList);
                
                colorMap[i*256*256+j*256+k]=colorList[nearestIndex];
                
                //colorMap[i*256*256+j*256+k]=cv::Vec3b((uchar)(i/reduceLevel),(uchar)(j/reduceLevel),(uchar)(k/reduceLevel));

            }
        }
    }*/
    
    cv::Mat output = reduceImage.clone();
    for(int r=0;r<reduceImage.rows;r++){
        for(int c=0;c<reduceImage.cols;c++){
            cv::Vec3b ele = reduceImage.at<cv::Vec3b>(r,c);
            //int index = ele[0]*256*256+ele[1]*256+ele[2];
            //cv::Vec3b color = colorMap[index];
            cv::Vec3b color = cv::Vec3b((uchar)(ele[0]/reduceLevel*reduceLevel),(uchar)(ele[1]/reduceLevel*reduceLevel),(uchar)(ele[2]/reduceLevel*reduceLevel));
            
            output.at<cv::Vec3b>(r,c)=color;
        }
    }
    
    cv::imwrite("/Users/kkppccdd/Documents/IdeaWork/result.png",output);

}

int main(int argc, char **argv) {
    //testMergeLayer();
    testGray();
    return 0;
}
