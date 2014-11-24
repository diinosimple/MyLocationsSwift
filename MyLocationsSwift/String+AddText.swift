//
//  String+AddText.swift
//  MyLocationsSwift
//
//  Created by Iino Daisuke on 2014/11/24.
//  Copyright (c) 2014年 Iino Daisuke. All rights reserved.
//

import Foundation

extension String {

    mutating func addText(text: String?,
            withSeparator separator: String = "") {
    
        if let text = text {
            if !self.isEmpty {
                self += separator
            }
            self += text
        }
    }
    
}
