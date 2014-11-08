//
//  HudView.swift
//  MyLocationsSwift
//
//  Created by Iino Daisuke on 2014/11/08.
//  Copyright (c) 2014年 Iino Daisuke. All rights reserved.
//

import UIKit

class HudView: UIView {
    var text = ""
    class func hudInView(view: UIView, animated: Bool) -> HudView {
        let hudView = HudView(frame: view.bounds)
        hudView.opaque = false
        view.addSubview(hudView)
        view.userInteractionEnabled = false
        
        return hudView
    }
}
