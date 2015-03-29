//
//  ImportImageDelegate.swift
//  ideawork
//
//  Created by Ray Cai on 2015/2/23.
//  Copyright (c) 2015 Ray Cai. All rights reserved.
//

import Foundation
import UIKit

protocol ImportImageDelegate: NSObjectProtocol{
    
    func importImage(importImageController:ImportImageViewController,image:UIImage)
    func importImageDidCancel(importImageController:ImportImageViewController)
}