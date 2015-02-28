//
//  Cam.cpp
//  ideawork
//
//  Created by Ray Cai on 2015/2/25.
//  Copyright (c) 2015 Ray Cai. All rights reserved.
//

#include "Cam.h"

#include <opencv2/opencv.hpp>

int Cam::showCam(){
    
    cv::VideoCapture capture(0); // open default camera
    if ( capture.isOpened() == false )
        return -1;
    
    //cv::namedWindow("Test OpenCV",1);
    //cv::Mat frame;
    /*
    while ( true )
    {
        capture >> frame;
        cv::imshow("Test OpenCV", frame );
        int key = cv::waitKey(1);
        if ( key == 27 )
            break;
    }*/
    return 0;
}
