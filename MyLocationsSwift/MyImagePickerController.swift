//
//  MyImagePickerController.swift
//  MyLocationsSwift
//
//  Created by Iino Daisuke on 2014/11/24.
//  Copyright (c) 2014年 Iino Daisuke. All rights reserved.
//

import Foundation
import UIkit

class MyImagePickerController: UIImagePickerController {
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}