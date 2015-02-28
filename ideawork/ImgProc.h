//
//  ImgProc.h
//  ideawork
//
//  Created by Ray Cai on 2015/2/25.
//  Copyright (c) 2015 Ray Cai. All rights reserved.
//

#ifndef ideawork_ImgProc_h
#define ideawork_ImgProc_h

#include <UIKit/UIKit.h>
#include <stdio.h>

class ImgProc{
public:
    static UIImage* padding(UIImage* image, int newRows,int newCols);
};

#endif
